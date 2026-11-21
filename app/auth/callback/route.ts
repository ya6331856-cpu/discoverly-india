import {NextResponse,type NextRequest} from "next/server";
import {createServerSupabaseClient} from "@/lib/supabase/server";

export async function GET(request:NextRequest){
 const code=request.nextUrl.searchParams.get("code");
 const requested=request.nextUrl.searchParams.get("next");
 const next=requested&&requested.startsWith("/")&&!requested.startsWith("//")?requested:"/business/register";
 const supabase=await createServerSupabaseClient();
 if(code&&supabase){
  const {error}=await supabase.auth.exchangeCodeForSession(code);
  if(!error)return NextResponse.redirect(new URL(next,request.url));
 }
 return NextResponse.redirect(new URL("/auth?error=verification",request.url));
}