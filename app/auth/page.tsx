"use client";
import {useEffect,useState} from "react";
import {useRouter} from "next/navigation";
import {createClient} from "@/lib/supabase/client";

export default function AuthPage(){
 const router=useRouter();
 const[mode,setMode]=useState<"login"|"signup">("signup");
 const[name,setName]=useState("");
 const[email,setEmail]=useState("");
 const[password,setPassword]=useState("");
 const[busy,setBusy]=useState(false);
 const[notice,setNotice]=useState("");
 const[error,setError]=useState("");
 const[nextPath,setNextPath]=useState("/business/register");

 useEffect(()=>{
  const params=new URLSearchParams(window.location.search);
  const target=params.get("next");
  const safe=target&&target.startsWith("/")&&!target.startsWith("//")?target:"/account";
  setNextPath(safe);
  if(params.get("mode")==="login")setMode("login");
  if(params.get("error")==="verification")setError("Email verification link could not be completed. Please sign in and try again.");
  const sb=createClient();
  if(sb)void sb.auth.getUser().then(({data})=>{if(data.user)router.replace(safe);});
 },[router]);

 async function submit(event:React.FormEvent<HTMLFormElement>){
  event.preventDefault();setBusy(true);setError("");setNotice("");
  const sb=createClient();
  if(!sb){setError("Supabase is not configured on this deployment yet.");setBusy(false);return;}
  if(mode==="signup"){
   const {data,error:authError}=await sb.auth.signUp({
    email:email.trim(),
    password,
    options:{
     data:{display_name:name.trim()},
     emailRedirectTo:window.location.origin+"/auth/callback?next="+encodeURIComponent(nextPath)
    }
   });
   if(authError)setError(authError.message);
   else if(data.session)router.replace(nextPath);
   else setNotice("Account request received. Check your email and open the verification link to activate your account.");
  }else{
   const {error:authError}=await sb.auth.signInWithPassword({email:email.trim(),password});
   if(authError)setError(authError.message);else router.replace(nextPath);
  }
  setBusy(false);
 }

 return <main className="authShell">
  <a className="authBack" href="/">← Back to Discoverly</a>
  <section className="authCard">
   <a className="brand authBrand" href="/">D<span>.</span> &nbsp; DISCOVERLY</a>
   <small className="eyebrow">{mode==="signup"?"JOIN THE BUSINESS NETWORK":"WELCOME BACK"}</small>
   <h1>{mode==="signup"?"Create your account.":"Good to see you."}</h1>
   <p className="authIntro">{mode==="signup"?"One account to discover businesses or build your own business presence.":"Sign in to manage your profile and business connections."}</p>
   <div className="authTabs"><button type="button" className={mode==="signup"?"active":""} onClick={()=>{setMode("signup");setError("");setNotice("");}}>Create account</button><button type="button" className={mode==="login"?"active":""} onClick={()=>{setMode("login");setError("");setNotice("");}}>Log in</button></div>
   <form onSubmit={submit} className="authForm">
    {mode==="signup"&&<label>Your name<input required autoComplete="name" value={name} onChange={e=>setName(e.target.value)} placeholder="Full name"/></label>}
    <label>Email address<input required type="email" autoComplete="email" value={email} onChange={e=>setEmail(e.target.value)} placeholder="you@example.com"/></label>
    <label>Password<input required minLength={8} type="password" autoComplete={mode==="signup"?"new-password":"current-password"} value={password} onChange={e=>setPassword(e.target.value)} placeholder="At least 8 characters"/></label>
    <button className="authSubmit" disabled={busy}>{busy?"Please wait…":mode==="signup"?"Create account →":"Log in →"}</button>
   </form>
   {error&&<p className="authError" role="alert">{error}</p>}
   {notice&&<p className="authNotice" role="status">{notice}</p>}
   <p className="authFine">By continuing, you agree to use DISCOVERLY responsibly. Your account details are protected by Supabase authentication.</p>
  </section>
 </main>;
}