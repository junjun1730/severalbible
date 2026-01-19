// Edge Function: verify-android-receipt
// Description: Verifies Android Google Play purchases
// Phase: 4-1 (Monetization)

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

interface VerifyRequest {
  purchaseToken: string;
  productId: string;
  userId: string;
  packageName?: string;
}

interface GoogleSubscriptionResponse {
  kind: string;
  startTimeMillis: string;
  expiryTimeMillis: string;
  autoRenewing: boolean;
  priceCurrencyCode: string;
  priceAmountMicros: string;
  orderId: string;
  paymentState?: number;
  cancelReason?: number;
  acknowledgementState?: number;
}

interface VerifyResult {
  success: boolean;
  valid?: boolean;
  orderId?: string;
  productId?: string;
  expiresAt?: string;
  autoRenewing?: boolean;
  error?: string;
}

// Helper to get Google API access token using service account
async function getGoogleAccessToken(): Promise<string> {
  const serviceAccountKey = Deno.env.get("GOOGLE_SERVICE_ACCOUNT_KEY");
  if (!serviceAccountKey) {
    throw new Error("GOOGLE_SERVICE_ACCOUNT_KEY not configured");
  }

  const serviceAccount = JSON.parse(serviceAccountKey);

  // Create JWT for Google OAuth
  const header = {
    alg: "RS256",
    typ: "JWT",
  };

  const now = Math.floor(Date.now() / 1000);
  const payload = {
    iss: serviceAccount.client_email,
    scope: "https://www.googleapis.com/auth/androidpublisher",
    aud: "https://oauth2.googleapis.com/token",
    exp: now + 3600,
    iat: now,
  };

  // Import RSA key
  const key = await crypto.subtle.importKey(
    "pkcs8",
    pemToBinary(serviceAccount.private_key),
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"]
  );

  // Create JWT
  const headerB64 = btoa(JSON.stringify(header));
  const payloadB64 = btoa(JSON.stringify(payload));
  const toSign = `${headerB64}.${payloadB64}`;

  const signature = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    key,
    new TextEncoder().encode(toSign)
  );

  const signatureB64 = btoa(String.fromCharCode(...new Uint8Array(signature)));
  const jwt = `${toSign}.${signatureB64}`;

  // Exchange JWT for access token
  const tokenResponse = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: `grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=${jwt}`,
  });

  const tokenData = await tokenResponse.json();
  return tokenData.access_token;
}

// Helper to convert PEM to binary
function pemToBinary(pem: string): ArrayBuffer {
  const base64 = pem
    .replace("-----BEGIN PRIVATE KEY-----", "")
    .replace("-----END PRIVATE KEY-----", "")
    .replace(/\n/g, "");
  const binary = atob(base64);
  const bytes = new Uint8Array(binary.length);
  for (let i = 0; i < binary.length; i++) {
    bytes[i] = binary.charCodeAt(i);
  }
  return bytes.buffer;
}

Deno.serve(async (req: Request): Promise<Response> => {
  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const { purchaseToken, productId, userId, packageName }: VerifyRequest = await req.json();

    if (!purchaseToken || !productId || !userId) {
      return new Response(
        JSON.stringify({ success: false, error: "Missing required fields" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const appPackageName = packageName || Deno.env.get("ANDROID_PACKAGE_NAME") || "com.onemessage.app";

    // Get Google API access token
    const accessToken = await getGoogleAccessToken();

    // Verify subscription with Google Play Developer API
    const googleApiUrl = `https://androidpublisher.googleapis.com/androidpublisher/v3/applications/${appPackageName}/purchases/subscriptions/${productId}/tokens/${purchaseToken}`;

    const response = await fetch(googleApiUrl, {
      headers: {
        Authorization: `Bearer ${accessToken}`,
      },
    });

    if (!response.ok) {
      const errorData = await response.json();
      console.error("[verify-android-receipt] Google API error:", errorData);
      return new Response(
        JSON.stringify({
          success: false,
          valid: false,
          error: errorData.error?.message || "Failed to verify purchase",
        }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const subscriptionData: GoogleSubscriptionResponse = await response.json();

    // Check if subscription is valid
    const expiryTime = parseInt(subscriptionData.expiryTimeMillis);
    const isValid = expiryTime > Date.now();

    if (!isValid) {
      return new Response(
        JSON.stringify({
          success: false,
          valid: false,
          error: "Subscription has expired",
        }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Acknowledge purchase if not yet acknowledged
    if (subscriptionData.acknowledgementState === 0) {
      const acknowledgeUrl = `${googleApiUrl}:acknowledge`;
      await fetch(acknowledgeUrl, {
        method: "POST",
        headers: {
          Authorization: `Bearer ${accessToken}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({}),
      });
      console.log("[verify-android-receipt] Purchase acknowledged");
    }

    // Activate subscription in database
    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

    if (supabaseUrl && supabaseServiceKey) {
      const supabase = createClient(supabaseUrl, supabaseServiceKey);

      // Map Android product ID to our product ID
      const productIdMap: Record<string, string> = {
        "monthly_premium_sub": "monthly_premium",
        "annual_premium_sub": "annual_premium",
      };

      const mappedProductId = productIdMap[productId] || productId;

      const { error: activateError } = await supabase.rpc("activate_subscription", {
        p_user_id: userId,
        p_product_id: mappedProductId,
        p_platform: "android",
        p_transaction_id: subscriptionData.orderId,
        p_original_transaction_id: subscriptionData.orderId,
      });

      if (activateError) {
        console.error("[verify-android-receipt] Failed to activate subscription:", activateError);
      }
    }

    const verifyResult: VerifyResult = {
      success: true,
      valid: true,
      orderId: subscriptionData.orderId,
      productId: productId,
      expiresAt: new Date(expiryTime).toISOString(),
      autoRenewing: subscriptionData.autoRenewing,
    };

    console.log(`[verify-android-receipt] Successfully verified purchase for user ${userId}`);

    return new Response(JSON.stringify(verifyResult), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (error) {
    const errorMessage = error instanceof Error ? error.message : "Unknown error";
    console.error(`[verify-android-receipt] Error: ${errorMessage}`);

    return new Response(
      JSON.stringify({ success: false, error: errorMessage }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
