// Edge Function: cleanup-old-notes
// Description: Deletes prayer notes older than 7 days for non-premium users
// Schedule: Run daily via cron (pg_cron or external scheduler)
// Phase: 3-1 (Prayer Note System)

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

interface CleanupResult {
  success: boolean;
  deleted_count: number;
  error?: string;
  timestamp: string;
}

Deno.serve(async (req: Request): Promise<Response> => {
  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    // Create Supabase client with service role key (bypasses RLS)
    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

    if (!supabaseUrl || !supabaseServiceKey) {
      throw new Error("Missing environment variables");
    }

    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    // Calculate the cutoff date (7 days ago)
    const cutoffDate = new Date();
    cutoffDate.setDate(cutoffDate.getDate() - 7);
    const cutoffDateStr = cutoffDate.toISOString();

    // Get non-premium user IDs
    const { data: nonPremiumUsers, error: userError } = await supabase
      .from("user_profiles")
      .select("id")
      .neq("tier", "premium");

    if (userError) {
      throw new Error(`Failed to fetch users: ${userError.message}`);
    }

    if (!nonPremiumUsers || nonPremiumUsers.length === 0) {
      const result: CleanupResult = {
        success: true,
        deleted_count: 0,
        timestamp: new Date().toISOString(),
      };
      return new Response(JSON.stringify(result), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const nonPremiumUserIds = nonPremiumUsers.map((u) => u.id);

    // Delete old notes for non-premium users
    const { data: deletedNotes, error: deleteError } = await supabase
      .from("prayer_notes")
      .delete()
      .in("user_id", nonPremiumUserIds)
      .lt("created_at", cutoffDateStr)
      .select("id");

    if (deleteError) {
      throw new Error(`Failed to delete notes: ${deleteError.message}`);
    }

    const deletedCount = deletedNotes?.length || 0;

    // Log the cleanup action
    console.log(
      `[cleanup-old-notes] Deleted ${deletedCount} notes older than ${cutoffDateStr}`
    );

    const result: CleanupResult = {
      success: true,
      deleted_count: deletedCount,
      timestamp: new Date().toISOString(),
    };

    return new Response(JSON.stringify(result), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (error) {
    const errorMessage =
      error instanceof Error ? error.message : "Unknown error";
    console.error(`[cleanup-old-notes] Error: ${errorMessage}`);

    const result: CleanupResult = {
      success: false,
      deleted_count: 0,
      error: errorMessage,
      timestamp: new Date().toISOString(),
    };

    return new Response(JSON.stringify(result), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
