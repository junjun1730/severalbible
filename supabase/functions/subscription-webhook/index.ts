// Edge Function: subscription-webhook
// Description: Handles subscription webhooks from Apple/Google
// Phase: 4-1 (Monetization)

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

// Apple App Store Server Notification types
enum AppleNotificationType {
  CONSUMPTION_REQUEST = "CONSUMPTION_REQUEST",
  DID_CHANGE_RENEWAL_PREF = "DID_CHANGE_RENEWAL_PREF",
  DID_CHANGE_RENEWAL_STATUS = "DID_CHANGE_RENEWAL_STATUS",
  DID_FAIL_TO_RENEW = "DID_FAIL_TO_RENEW",
  DID_RENEW = "DID_RENEW",
  EXPIRED = "EXPIRED",
  GRACE_PERIOD_EXPIRED = "GRACE_PERIOD_EXPIRED",
  OFFER_REDEEMED = "OFFER_REDEEMED",
  PRICE_INCREASE = "PRICE_INCREASE",
  REFUND = "REFUND",
  REFUND_DECLINED = "REFUND_DECLINED",
  RENEWAL_EXTENDED = "RENEWAL_EXTENDED",
  REVOKE = "REVOKE",
  SUBSCRIBED = "SUBSCRIBED",
  TEST = "TEST",
}

// Google Play Real-time Developer Notification types
enum GoogleNotificationType {
  SUBSCRIPTION_RECOVERED = 1,
  SUBSCRIPTION_RENEWED = 2,
  SUBSCRIPTION_CANCELED = 3,
  SUBSCRIPTION_PURCHASED = 4,
  SUBSCRIPTION_ON_HOLD = 5,
  SUBSCRIPTION_IN_GRACE_PERIOD = 6,
  SUBSCRIPTION_RESTARTED = 7,
  SUBSCRIPTION_PRICE_CHANGE_CONFIRMED = 8,
  SUBSCRIPTION_DEFERRED = 9,
  SUBSCRIPTION_PAUSED = 10,
  SUBSCRIPTION_PAUSE_SCHEDULE_CHANGED = 11,
  SUBSCRIPTION_REVOKED = 12,
  SUBSCRIPTION_EXPIRED = 13,
}

interface WebhookResult {
  success: boolean;
  platform?: string;
  notificationType?: string;
  action?: string;
  error?: string;
}

Deno.serve(async (req: Request): Promise<Response> => {
  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

    if (!supabaseUrl || !supabaseServiceKey) {
      throw new Error("Missing environment variables");
    }

    const supabase = createClient(supabaseUrl, supabaseServiceKey);
    const body = await req.json();

    // Determine platform from webhook payload
    const platform = body.signedPayload ? "ios" : body.message ? "android" : "unknown";

    let result: WebhookResult;

    if (platform === "ios") {
      result = await handleAppleWebhook(supabase, body);
    } else if (platform === "android") {
      result = await handleGoogleWebhook(supabase, body);
    } else {
      result = { success: false, error: "Unknown webhook format" };
    }

    console.log(`[subscription-webhook] ${platform}: ${result.notificationType} - ${result.action}`);

    return new Response(JSON.stringify(result), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (error) {
    const errorMessage = error instanceof Error ? error.message : "Unknown error";
    console.error(`[subscription-webhook] Error: ${errorMessage}`);

    return new Response(
      JSON.stringify({ success: false, error: errorMessage }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});

async function handleAppleWebhook(
  supabase: ReturnType<typeof createClient>,
  payload: { signedPayload: string }
): Promise<WebhookResult> {
  // In production, verify the JWT signature with Apple's public key
  // For now, we'll decode the payload (simplified)

  try {
    // Decode JWT payload (without verification for simplicity)
    const parts = payload.signedPayload.split(".");
    if (parts.length !== 3) {
      throw new Error("Invalid JWT format");
    }

    const payloadB64 = parts[1].replace(/-/g, "+").replace(/_/g, "/");
    const decodedPayload = JSON.parse(atob(payloadB64));

    const notificationType = decodedPayload.notificationType as AppleNotificationType;
    const transactionInfo = decodedPayload.data?.signedTransactionInfo;

    // Get user ID from original transaction (you'd need to look this up)
    const originalTransactionId = transactionInfo?.originalTransactionId;

    // Find user by original_transaction_id
    const { data: subscription } = await supabase
      .from("user_subscriptions")
      .select("user_id")
      .eq("original_transaction_id", originalTransactionId)
      .single();

    if (!subscription) {
      return {
        success: false,
        platform: "ios",
        notificationType,
        error: "User not found for transaction",
      };
    }

    const userId = subscription.user_id;
    let action = "none";

    switch (notificationType) {
      case AppleNotificationType.DID_RENEW:
      case AppleNotificationType.SUBSCRIBED:
        // Renewal or new subscription
        await supabase
          .from("user_subscriptions")
          .update({
            subscription_status: "active",
            auto_renew: true,
            updated_at: new Date().toISOString(),
          })
          .eq("user_id", userId);
        action = "activated";
        break;

      case AppleNotificationType.DID_CHANGE_RENEWAL_STATUS:
        // User changed auto-renew status
        const autoRenewStatus = decodedPayload.data?.autoRenewStatus;
        await supabase
          .from("user_subscriptions")
          .update({
            auto_renew: autoRenewStatus,
            updated_at: new Date().toISOString(),
          })
          .eq("user_id", userId);
        action = autoRenewStatus ? "enabled_auto_renew" : "disabled_auto_renew";
        break;

      case AppleNotificationType.DID_FAIL_TO_RENEW:
        // Payment failed - enter grace period
        await supabase
          .from("user_subscriptions")
          .update({
            subscription_status: "grace_period",
            updated_at: new Date().toISOString(),
          })
          .eq("user_id", userId);
        action = "grace_period";
        break;

      case AppleNotificationType.EXPIRED:
      case AppleNotificationType.GRACE_PERIOD_EXPIRED:
        // Subscription expired
        await supabase
          .from("user_subscriptions")
          .update({
            subscription_status: "expired",
            auto_renew: false,
            updated_at: new Date().toISOString(),
          })
          .eq("user_id", userId);

        // Downgrade user tier
        await supabase
          .from("user_profiles")
          .update({ tier: "member", updated_at: new Date().toISOString() })
          .eq("id", userId);
        action = "expired_and_downgraded";
        break;

      case AppleNotificationType.REFUND:
      case AppleNotificationType.REVOKE:
        // Refund or revoke - immediate downgrade
        await supabase
          .from("user_subscriptions")
          .update({
            subscription_status: "canceled",
            auto_renew: false,
            cancellation_reason: notificationType === "REFUND" ? "refund" : "revoked",
            updated_at: new Date().toISOString(),
          })
          .eq("user_id", userId);

        await supabase
          .from("user_profiles")
          .update({ tier: "member", updated_at: new Date().toISOString() })
          .eq("id", userId);
        action = "refunded_and_downgraded";
        break;

      case AppleNotificationType.TEST:
        action = "test_notification";
        break;

      default:
        action = "unhandled";
    }

    return {
      success: true,
      platform: "ios",
      notificationType,
      action,
    };
  } catch (error) {
    return {
      success: false,
      platform: "ios",
      error: error instanceof Error ? error.message : "Unknown error",
    };
  }
}

async function handleGoogleWebhook(
  supabase: ReturnType<typeof createClient>,
  payload: { message: { data: string } }
): Promise<WebhookResult> {
  try {
    // Decode base64 message data
    const messageData = JSON.parse(atob(payload.message.data));
    const notification = messageData.subscriptionNotification;

    if (!notification) {
      return {
        success: false,
        platform: "android",
        error: "No subscription notification in payload",
      };
    }

    const notificationType = notification.notificationType as GoogleNotificationType;
    const purchaseToken = notification.purchaseToken;

    // Find user by purchase token (store_transaction_id)
    const { data: subscription } = await supabase
      .from("user_subscriptions")
      .select("user_id")
      .eq("store_transaction_id", purchaseToken)
      .single();

    if (!subscription) {
      return {
        success: false,
        platform: "android",
        notificationType: GoogleNotificationType[notificationType],
        error: "User not found for purchase token",
      };
    }

    const userId = subscription.user_id;
    let action = "none";

    switch (notificationType) {
      case GoogleNotificationType.SUBSCRIPTION_PURCHASED:
      case GoogleNotificationType.SUBSCRIPTION_RENEWED:
      case GoogleNotificationType.SUBSCRIPTION_RECOVERED:
      case GoogleNotificationType.SUBSCRIPTION_RESTARTED:
        await supabase
          .from("user_subscriptions")
          .update({
            subscription_status: "active",
            auto_renew: true,
            updated_at: new Date().toISOString(),
          })
          .eq("user_id", userId);
        action = "activated";
        break;

      case GoogleNotificationType.SUBSCRIPTION_CANCELED:
        await supabase
          .from("user_subscriptions")
          .update({
            subscription_status: "canceled",
            auto_renew: false,
            updated_at: new Date().toISOString(),
          })
          .eq("user_id", userId);
        action = "canceled";
        break;

      case GoogleNotificationType.SUBSCRIPTION_IN_GRACE_PERIOD:
      case GoogleNotificationType.SUBSCRIPTION_ON_HOLD:
        await supabase
          .from("user_subscriptions")
          .update({
            subscription_status: "grace_period",
            updated_at: new Date().toISOString(),
          })
          .eq("user_id", userId);
        action = "grace_period";
        break;

      case GoogleNotificationType.SUBSCRIPTION_EXPIRED:
      case GoogleNotificationType.SUBSCRIPTION_REVOKED:
        await supabase
          .from("user_subscriptions")
          .update({
            subscription_status: "expired",
            auto_renew: false,
            updated_at: new Date().toISOString(),
          })
          .eq("user_id", userId);

        await supabase
          .from("user_profiles")
          .update({ tier: "member", updated_at: new Date().toISOString() })
          .eq("id", userId);
        action = "expired_and_downgraded";
        break;

      case GoogleNotificationType.SUBSCRIPTION_PAUSED:
        await supabase
          .from("user_subscriptions")
          .update({
            subscription_status: "pending",
            updated_at: new Date().toISOString(),
          })
          .eq("user_id", userId);
        action = "paused";
        break;

      default:
        action = "unhandled";
    }

    return {
      success: true,
      platform: "android",
      notificationType: GoogleNotificationType[notificationType],
      action,
    };
  } catch (error) {
    return {
      success: false,
      platform: "android",
      error: error instanceof Error ? error.message : "Unknown error",
    };
  }
}
