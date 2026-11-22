"use client";
import Link from "next/link";
import {useEffect,useState} from "react";
import {useRouter} from "next/navigation";
import {createClient} from "@/lib/supabase/client";
export default function AuthPage(){
 const router=useRouter();
 const[mode,setMode]=useState<"login"|"signup">("login"),[stage,setStage]=useState<"details"|"otp">("details");
 const[name,setName]=useState(""),[email,setEmail]=useState(""),[password,setPassword]=useState(""),[otp,setOtp]=useState("");
 const[busy,setBusy]=useState(false),[notice,setNotice]=useState(""),[error,setError]=useState(""),[acceptedTerms,setAcceptedTerms]=useState(false);
 useEffect(()=>{const target=new URLSearchParams(window.location.search).get("next");const safe=target&&target.startsWith("/")&&!target.startsWith("//")?target:"/account";const sb=createClient();if(sb)void sb.auth.getUser().then(({data})=>{if(data.user)router.replace(safe);});},[router]);
 function destination(){const requested=new URLSearchParams(window.location.search).get("next");return requested&&requested.startsWith("/")&&!requested.startsWith("//")?requested:"/account";}
 async function submit(event:React.FormEvent<HTMLFormElement>){event.preventDefault();if(mode==="signup"&&stage==="details"&&!acceptedTerms){setError("Please accept the Terms of Use and Privacy Policy before creating an account.");return;}setBusy(true);setError("");setNotice("");const sb=createClient();if(!sb){setError("Supabase is not configured on this deployment yet.");setBusy(false);return;}
  if(mode==="signup"&&stage==="details"){const{error:e}=await sb.auth.signInWithOtp({email:email.trim(),options:{shouldCreateUser:true,data:{display_name:name.trim(),terms_version:"1.0",terms_accepted_at:new Date().toISOString()}}});if(e)setError(e.message);else{setStage("otp");setNotice("A 6-digit verification code has been sent to your email. Enter it below to activate your DISCOVERLY account.");}}
  else if(mode==="signup"){const{data,error:e}=await sb.auth.verifyOtp({email:email.trim(),token:otp.trim(),type:"email"});if(e)setError(e.message);else{if(data.user)await sb.from("profiles").upsert({id:data.user.id,terms_accepted_at:new Date().toISOString(),terms_version:"1.0"},{onConflict:"id"});router.replace(destination());}}
  else{const{error:e}=await sb.auth.signInWithPassword({email:email.trim(),password});if(e)setError(e.message);else router.replace(destination());}setBusy(false);}
 async function resend(){const sb=createClient();if(!sb)return;setBusy(true);setError("");setNotice("");const{error:e}=await sb.auth.signInWithOtp({email:email.trim(),options:{shouldCreateUser:true,data:{display_name:name.trim()}}});if(e)setError(e.message);else setNotice("A fresh verification code has been sent. Check your inbox and spam folder.");setBusy(false);}
 function changeMode(next:"login"|"signup"){setMode(next);setStage("details");setError("");setNotice("");setOtp("");setAcceptedTerms(false);}
 return <main className="authShell"><Link className="authBack" href="/">← Back to Discoverly</Link><section className="authCard">
 <Link className="brand authBrand" href="/">D<span>.</span> &nbsp; DISCOVERLY</Link><small className="eyebrow">{mode==="signup"?"JOIN THE BUSINESS NETWORK":"WELCOME BACK"}</small>
 <h1>{mode==="signup"?(stage==="otp"?"Verify your email.":"Create your account."):"Good to see you."}</h1>
 <p className="authIntro">{mode==="signup"?(stage==="otp"?"Enter the one-time code we sent to "+email:"One account to discover businesses or build your own business presence."):"Sign in to manage your profile and business connections."}</p>
 <div className="authTabs"><button type="button" className={mode==="signup"?"active":""} onClick={()=>changeMode("signup")}>Create account</button><button type="button" className={mode==="login"?"active":""} onClick={()=>changeMode("login")}>Log in</button></div>
 <form onSubmit={submit} className="authForm">
 {mode==="signup"&&stage==="details"&&<label>Your name<input required autoComplete="name" value={name} onChange={e=>setName(e.target.value)} placeholder="Full name"/></label>}
 <label>Email address<input required type="email" autoComplete="email" value={email} onChange={e=>setEmail(e.target.value)} placeholder="you@example.com" readOnly={stage==="otp"}/></label>
 {mode==="login"&&<label>Password<input required minLength={8} type="password" autoComplete="current-password" value={password} onChange={e=>setPassword(e.target.value)} placeholder="Your password"/></label>}
 {mode==="signup"&&stage==="details"&&<label style={{display:"flex",alignItems:"flex-start",gap:10,fontSize:13,lineHeight:1.45,color:"#665D55"}}><input type="checkbox" checked={acceptedTerms} onChange={e=>setAcceptedTerms(e.target.checked)} style={{marginTop:3}}/> <span>I agree to the <Link href="/terms" style={{textDecoration:"underline"}}>Terms of Use</Link> and <Link href="/privacy" style={{textDecoration:"underline"}}>Privacy Policy</Link>.</span></label>}
 {mode==="signup"&&stage==="otp"&&<label>6-digit verification code<input required inputMode="numeric" autoComplete="one-time-code" pattern="[0-9]{6}" maxLength={6} value={otp} onChange={e=>setOtp(e.target.value.replace(/\D/g,"").slice(0,6))} placeholder="Enter 6-digit code"/></label>}
 <button className="authSubmit" disabled={busy}>{busy?"Please wait…":mode==="signup"?(stage==="otp"?"Verify & create account →":"Send verification code →"):"Log in →"}</button></form>
 {mode==="signup"&&stage==="otp"&&<div className="otpActions"><button type="button" onClick={resend} disabled={busy}>Resend code</button><button type="button" onClick={()=>{setStage("details");setOtp("");setNotice("");setError("");}}>Change email</button></div>}
 {error&&<p className="authError" role="alert">{error}</p>}{notice&&<p className="authNotice" role="status">{notice}</p>}
 <p className="authFine">Email verification protects your account. Never share your one-time code with anyone, including people claiming to be DISCOVERLY support.</p></section></main>;
}