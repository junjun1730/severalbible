// Edge Function: verify-ios-receipt
// Description: Verifies iOS App Store receipts with Apple's server
// Phase: 4-1 (Monetization)

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

const APPLE_VERIFY_URL_PRODUCTION = "https://buy.itunes.apple.com/verifyReceipt";
const APPLE_VERIFY_URL_SANDBOX = "https://sandbox.itunes.apple.com/verifyReceipt";

interface VerifyRequest {
  receipt: string;
  userId: string;
}

interface AppleReceiptResponse {
  status: number;
  receipt?: {
    in_app?: Array<{
      transaction_id: string;
      original_transaction_id: string;
      product_id: string;
      expires_date_ms?: string;
    }>;
  };
  latest_receipt_info?: Array<{
    transaction_id: string;
    original_transaction_id: string;
    product_id: string;
    expires_date_ms?: string;
  }>;
}

interface VerifyResult {
  success: boolean;
  valid?: boolean;
  transactionId?: string;
  originalTransactionId?: string;
  productId?: string;
  expiresAt?: string;
  error?: string;
}

Deno.serve(async (req: Request): Promise<Response> => {
  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const { receipt, userId }: VerifyRequest = await req.json();

    if (!receipt || !userId) {
      return new Response(
        JSON.stringify({ success: false, error: "Missing receipt or userId" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const sharedSecret = Deno.env.get("APPLE_SHARED_SECRET");
    if (!sharedSecret) {
      throw new Error("APPLE_SHARED_SECRET not configured");
    }

    // Try production first
    let response = await fetch(APPLE_VERIFY_URL_PRODUCTION, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        "receipt-data": receipt,
        "password": sharedSecret,
        "exclude-old-transactions": true,
      }),
    });

    let result: AppleReceiptResponse = await response.json();

    // If status 21007, it's a sandbox receipt - retry with sandbox URL
    if (result.status === 21007) {
      console.log("[verify-ios-receipt] Sandbox receipt detected, retrying with sandbox URL");
      response = await fetch(APPLE_VERIFY_URL_SANDBOX, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          "receipt-data": receipt,
          "password": sharedSecret,
          "exclude-old-transactions": true,
        }),
      });
      result = await response.json();
    }

    // Check for errors
    // Status codes: https://developer.apple.com/documentation/appstorereceipts/status
    if (result.status !== 0) {
      const errorMessages: Record<number, string> = {
        21000: "App Store could not read the JSON",
        21002: "Receipt data is malformed",
        21003: "Receipt could not be authenticated",
        21004: "Shared secret mismatch",
        21005: "Receipt server unavailable",
        21006: "Receipt valid but subscription expired",
        21007: "Sandbox receipt sent to production",
        21008: "Production receipt sent to sandbox",
        21010: "Account not found",
      };

      return new Response(
        JSON.stringify({
          success: false,
          valid: false,
          error: errorMessages[result.status] || `Unknown error: ${result.status}`,
        }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Extract latest receipt info (for subscriptions, use latest_receipt_info)
    const latestReceiptInfo =
      result.latest_receipt_info?.[0] || result.receipt?.in_app?.[0];

    if (!latestReceiptInfo) {
      return new Response(
        JSON.stringify({
          success: false,
          valid: false,
          error: "No purchase found in receipt",
        }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Convert expires_date_ms to ISO string
    const expiresAt = latestReceiptInfo.expires_date_ms
      ? new Date(parseInt(latestReceiptInfo.expires_date_ms)).toISOString()
      : undefined;

    // Activate subscription in database
    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

    if (supabaseUrl && supabaseServiceKey) {
      const supabase = createClient(supabaseUrl, supabaseServiceKey);

      // Map iOS product ID to our product ID
      const productIdMap: Record<string, string> = {
        "com.onemessage.monthly": "monthly_premium",
        "com.onemessage.annual": "annual_premium",
      };

      const productId = productIdMap[latestReceiptInfo.product_id] || latestReceiptInfo.product_id;

      const { error: activateError } = await supabase.rpc("activate_subscription", {
        p_user_id: userId,
        p_product_id: productId,
        p_platform: "ios",
        p_transaction_id: latestReceiptInfo.transaction_id,
        p_original_transaction_id: latestReceiptInfo.original_transaction_id,
      });

      if (activateError) {
        console.error("[verify-ios-receipt] Failed to activate subscription:", activateError);
      }
    }

    const verifyResult: VerifyResult = {
      success: true,
      valid: true,
      transactionId: latestReceiptInfo.transaction_id,
      originalTransactionId: latestReceiptInfo.original_transaction_id,
      productId: latestReceiptInfo.product_id,
      expiresAt,
    };

    console.log(`[verify-ios-receipt] Successfully verified receipt for user ${userId}`);

    return new Response(JSON.stringify(verifyResult), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (error) {
    const errorMessage = error instanceof Error ? error.message : "Unknown error";
    console.error(`[verify-ios-receipt] Error: ${errorMessage}`);

    return new Response(
      JSON.stringify({ success: false, error: errorMessage }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
