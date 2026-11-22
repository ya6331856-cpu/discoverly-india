import { createClient } from "npm:@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return Response.json({ error: "Method not allowed" }, { status: 405, headers: corsHeaders });

  try {
    const authorization = req.headers.get("Authorization");
    if (!authorization?.startsWith("Bearer ")) {
      return Response.json({ error: "Authentication required" }, { status: 401, headers: corsHeaders });
    }
    const body = await req.json().catch(() => ({}));
    if (body?.confirmation !== "DELETE") {
      return Response.json({ error: "Explicit deletion confirmation is required" }, { status: 400, headers: corsHeaders });
    }
    const url = Deno.env.get("SUPABASE_URL");
    const anonKey = Deno.env.get("SUPABASE_ANON_KEY");
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
    if (!url || !anonKey || !serviceRoleKey) throw new Error("Supabase server configuration is incomplete");

    const userClient = createClient(url, anonKey, {
      global: { headers: { Authorization: authorization } },
      auth: { persistSession: false, autoRefreshToken: false },
    });
    const { data: authData, error: authError } = await userClient.auth.getUser();
    if (authError || !authData.user) {
      return Response.json({ error: "Your session is invalid. Sign in again." }, { status: 401, headers: corsHeaders });
    }

    const userId = authData.user.id;
    const admin = createClient(url, serviceRoleKey, { auth: { persistSession: false, autoRefreshToken: false } });
    const { data: ownedCompanies, error: ownedError } = await admin.from("companies").select("id").eq("created_by", userId);
    if (ownedError) throw ownedError;

    for (const company of ownedCompanies ?? []) {
      const { data: members, error: memberError } = await admin.from("company_members")
        .select("user_id,created_at").eq("company_id", company.id).neq("user_id", userId)
        .order("created_at", { ascending: true }).limit(1);
      if (memberError) throw memberError;

      if (members && members.length > 0) {
        const { error } = await admin.from("companies").update({ created_by: members[0].user_id }).eq("id", company.id);
        if (error) throw error;
      } else {
        const { error: clearDuplicate } = await admin.from("business_import_staging")
          .update({ duplicate_of_company_id: null }).eq("duplicate_of_company_id", company.id);
        if (clearDuplicate) throw clearDuplicate;
        const { error: clearImported } = await admin.from("business_import_staging")
          .update({ imported_company_id: null }).eq("imported_company_id", company.id);
        if (clearImported) throw clearImported;
        const { error } = await admin.from("companies").delete().eq("id", company.id);
        if (error) throw error;
      }
    }

    const cleanup = [
      ["business_import_staging", "reviewed_by"],
      ["content_reports", "reviewer_user_id"],
      ["data_sources", "last_license_reviewed_by"],
      ["verification_cases", "reviewer_id"],
    ] as const;
    for (const [table, column] of cleanup) {
      const { error } = await admin.from(table).update({ [column]: null }).eq(column, userId);
      if (error) throw error;
    }

    const { error: deleteError } = await admin.auth.admin.deleteUser(userId);
    if (deleteError) throw deleteError;
    return Response.json({ success: true }, { status: 200, headers: corsHeaders });
  } catch (error) {
    console.error("delete-account failed", error);
    return Response.json({ error: "Account deletion could not be completed. Contact support." }, { status: 500, headers: corsHeaders });
  }
});
