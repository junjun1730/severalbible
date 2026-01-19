// Edge Function: check-expired-subscriptions
// Description: Checks for expired subscriptions and downgrades user tiers
// Schedule: Run daily via cron (e.g., daily at 2 AM UTC)
// Phase: 4-1 (Monetization)

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

interface CheckResult {
  success: boolean;
  expired_count: number;
  grace_period_count: number;
  downgraded_count: number;
  error?: string;
  timestamp: string;
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
    const now = new Date().toISOString();

    // 1. Find active subscriptions that have expired
    const { data: expiredSubs, error: expiredError } = await supabase
      .from("user_subscriptions")
      .select("id, user_id")
      .eq("subscription_status", "active")
      .not("expires_at", "is", null)
      .lt("expires_at", now);

    if (expiredError) {
      throw new Error(`Failed to fetch expired subscriptions: ${expiredError.message}`);
    }

    let expiredCount = 0;
    let downgradeCount = 0;

    // Process expired subscriptions
    for (const sub of expiredSubs || []) {
      // Update subscription status to expired
      const { error: updateSubError } = await supabase
        .from("user_subscriptions")
        .update({
          subscription_status: "expired",
          auto_renew: false,
          updated_at: now,
        })
        .eq("id", sub.id);

      if (!updateSubError) {
        expiredCount++;

        // Downgrade user tier to member
        const { error: updateUserError } = await supabase
          .from("user_profiles")
          .update({ tier: "member", updated_at: now })
          .eq("id", sub.user_id);

        if (!updateUserError) {
          downgradeCount++;
        }
      }
    }

    // 2. Find grace period subscriptions that have fully expired (grace period = 3 days)
    const gracePeriodCutoff = new Date();
    gracePeriodCutoff.setDate(gracePeriodCutoff.getDate() - 3);
    const gracePeriodCutoffStr = gracePeriodCutoff.toISOString();

    const { data: gracePeriodExpired, error: graceError } = await supabase
      .from("user_subscriptions")
      .select("id, user_id")
      .eq("subscription_status", "grace_period")
      .not("expires_at", "is", null)
      .lt("expires_at", gracePeriodCutoffStr);

    if (graceError) {
      console.error(`Failed to fetch grace period subscriptions: ${graceError.message}`);
    }

    // Process grace period subscriptions that have fully expired
    for (const sub of gracePeriodExpired || []) {
      const { error: updateSubError } = await supabase
        .from("user_subscriptions")
        .update({
          subscription_status: "expired",
          auto_renew: false,
          updated_at: now,
        })
        .eq("id", sub.id);

      if (!updateSubError) {
        expiredCount++;

        const { error: updateUserError } = await supabase
          .from("user_profiles")
          .update({ tier: "member", updated_at: now })
          .eq("id", sub.user_id);

        if (!updateUserError) {
          downgradeCount++;
        }
      }
    }

    // 3. Move subscriptions that are about to expire to grace period
    // (only for subscriptions with auto_renew = true that failed to renew)
    const threeDaysFromNow = new Date();
    threeDaysFromNow.setDate(threeDaysFromNow.getDate() + 3);
    const threeDaysStr = threeDaysFromNow.toISOString();

    const { data: soonExpiring, error: soonError } = await supabase
      .from("user_subscriptions")
      .select("id")
      .eq("subscription_status", "active")
      .eq("auto_renew", true)
      .not("expires_at", "is", null)
      .lt("expires_at", threeDaysStr)
      .gt("expires_at", now);

    let gracePeriodCount = 0;

    if (!soonError) {
      for (const sub of soonExpiring || []) {
        // Note: In a real implementation, you might want to check with Apple/Google
        // if the renewal has failed before moving to grace period
        // For now, we just log these subscriptions
        gracePeriodCount++;
      }
    }

    const result: CheckResult = {
      success: true,
      expired_count: expiredCount,
      grace_period_count: gracePeriodCount,
      downgraded_count: downgradeCount,
      timestamp: now,
    };

    console.log(`[check-expired-subscriptions] Processed: ${expiredCount} expired, ${downgradeCount} downgraded, ${gracePeriodCount} approaching expiry`);

    return new Response(JSON.stringify(result), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (error) {
    const errorMessage = error instanceof Error ? error.message : "Unknown error";
    console.error(`[check-expired-subscriptions] Error: ${errorMessage}`);

    const result: CheckResult = {
      success: false,
      expired_count: 0,
      grace_period_count: 0,
      downgraded_count: 0,
      error: errorMessage,
      timestamp: new Date().toISOString(),
    };

    return new Response(JSON.stringify(result), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
