"use client";
import Link from "next/link";
import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";

type Company={id:string;display_name:string;legal_name:string;slug:string;status:string;created_at:string};
type Verification={id:string;company_id:string;verification_type:string;status:string;reference_value:string|null;document_path:string|null;submitted_at:string|null};
type Review={id:string;company_id:string;rating:number;title:string|null;body:string|null;created_at:string};
type Report={id:string;target_type:string;target_id:string;reason:string;details:string|null;status:string;created_at:string};

export default function AdminPage(){
  const router=useRouter();
  const [loading,setLoading]=useState(true);const [allowed,setAllowed]=useState(false);const [userId,setUserId]=useState("");
  const [error,setError]=useState("");const [notice,setNotice]=useState("");const [busyId,setBusyId]=useState("");
  const [companies,setCompanies]=useState<Company[]>([]);const [verifications,setVerifications]=useState<Verification[]>([]);
  const [reviews,setReviews]=useState<Review[]>([]);const [reports,setReports]=useState<Report[]>([]);
  const [companyNames,setCompanyNames]=useState<Record<string,string>>({});const [notes,setNotes]=useState<Record<string,string>>({});

  async function load(){
    const sb=createClient();if(!sb){setError("Supabase connection settings are missing.");setLoading(false);return;}
    const {data:{user}}=await sb.auth.getUser();if(!user){router.replace("/auth?mode=login&next=/admin");return;}
    setUserId(user.id);
    const {data:roles,error:roleError}=await sb.from("user_roles").select("role").eq("user_id",user.id);
    if(roleError){setError(roleError.message);setLoading(false);return;}
    if(!(roles||[]).some((r:{role:string})=>r.role==="admin"||r.role==="moderator")){setAllowed(false);setLoading(false);return;}
    setAllowed(true);
    const [co,ve,re,cr]=await Promise.all([
      sb.from("companies").select("id,display_name,legal_name,slug,status,created_at").eq("status","pending_review").order("created_at",{ascending:true}),
      sb.from("verification_cases").select("id,company_id,verification_type,status,reference_value,document_path,submitted_at").in("status",["submitted","in_review"]).order("submitted_at",{ascending:true}),
      sb.from("reviews").select("id,company_id,rating,title,body,created_at").eq("moderation_status","pending").order("created_at",{ascending:true}),
      sb.from("content_reports").select("id,target_type,target_id,reason,details,status,created_at").in("status",["open","in_review"]).order("created_at",{ascending:true})
    ]);
    const firstError=co.error||ve.error||re.error||cr.error;
    if(firstError)setError(firstError.message);
    const companyRows=(co.data||[]) as Company[];const verRows=(ve.data||[]) as Verification[];
    const reviewRows=(re.data||[]) as Review[];const reportRows=(cr.data||[]) as Report[];
    const ids=Array.from(new Set([...companyRows.map(x=>x.id),...verRows.map(x=>x.company_id),...reviewRows.map(x=>x.company_id)]));
    let names:Record<string,string>={};
    if(ids.length){const {data}=await sb.from("companies").select("id,display_name").in("id",ids);for(const row of data||[])names[row.id]=row.display_name;}
    setCompanies(companyRows);setVerifications(verRows);setReviews(reviewRows);setReports(reportRows);setCompanyNames(names);
    setLoading(false);
  }
  useEffect(()=>{void load();},[]);

  async function changeCompany(id:string,status:"published"|"rejected"){
    const sb=createClient();if(!sb)return;setBusyId(id);setError("");setNotice("");
    const {error:updateError}=await sb.from("companies").update({status}).eq("id",id);
    setBusyId("");if(updateError){setError(updateError.message);return;}
    setNotice("Business review updated.");await load();
  }
  async function reviewVerification(item:Verification,status:"verified"|"rejected"){
    const sb=createClient();if(!sb)return;setBusyId(item.id);setError("");setNotice("");
    const {error:updateError}=await sb.from("verification_cases").update({status,reviewer_id:userId,reviewer_note:notes[item.id]?.trim()||null,reviewed_at:new Date().toISOString()}).eq("id",item.id);
    setBusyId("");if(updateError){setError(updateError.message);return;}
    setNotice("Verification decision saved. The company members have been notified.");await load();
  }
  async function openDocument(path:string){
    const sb=createClient();if(!sb)return;setError("");
    const {data,error:signedError}=await sb.storage.from("company-verification").createSignedUrl(path,300);
    if(signedError){setError(signedError.message);return;}
    window.open(data.signedUrl,"_blank","noopener,noreferrer");
  }
  async function moderateReview(id:string,status:"published"|"rejected"){
    const sb=createClient();if(!sb)return;setBusyId(id);setError("");setNotice("");
    const {error:updateError}=await sb.from("reviews").update({moderation_status:status}).eq("id",id);
    setBusyId("");if(updateError){setError(updateError.message);return;}
    setNotice("Review moderation updated.");await load();
  }
  async function resolveReport(item:Report,status:"resolved"|"dismissed"){
    const sb=createClient();if(!sb)return;setBusyId(item.id);setError("");setNotice("");
    const {error:updateError}=await sb.from("content_reports").update({status,reviewer_user_id:userId,reviewer_note:notes[item.id]?.trim()||null}).eq("id",item.id);
    setBusyId("");if(updateError){setError(updateError.message);return;}
    setNotice("Report status saved.");await load();
  }

  if(loading)return <main className="registerShell"><p className="loadingText">Checking reviewer access…</p></main>;
  if(!allowed)return <main className="registerShell"><header className="registerNav"><Link className="brand" href="/">D<span>.</span> &nbsp; DISCOVERLY</Link><Link href="/">Back to discovery ↗</Link></header><section className="registerCard"><small className="eyebrow">RESTRICTED AREA</small><h1>Reviewer access only.</h1><p>This page is available only to an authorized DISCOVERLY administrator or moderator.</p>{error&&<p className="formError">{error}</p>}<Link href="/account">Return to account →</Link></section></main>;

  return <main className="registerShell adminShell">
    <header className="registerNav"><Link className="brand" href="/">D<span>.</span> &nbsp; DISCOVERLY</Link><Link href="/account">My account ↗</Link></header>
    <section className="registerIntro"><small className="eyebrow">PLATFORM OPERATIONS · PRIVATE</small><h1>Trust &<br/><em>moderation.</em></h1><p>Review business listings, evidence documents, customer reviews and user reports.</p></section>
    <section className="adminStats"><div><strong>{companies.length}</strong><span>Businesses</span></div><div><strong>{verifications.length}</strong><span>Verifications</span></div><div><strong>{reviews.length}</strong><span>Reviews</span></div><div><strong>{reports.length}</strong><span>Reports</span></div></section>
    {error&&<p className="formError" role="alert">{error}</p>}{notice&&<p className="formSuccess" role="status">{notice}</p>}
    <section className="registerCard adminQueue"><div className="formHeader"><div><small className="eyebrow">QUEUE 01</small><h2>Business profiles awaiting review</h2></div><span>{companies.length} ITEMS</span></div>
      {companies.length===0?<p className="accountMuted">No business profiles are waiting.</p>:companies.map(c=><article className="adminItem" key={c.id}><div className="adminItemMain"><h3>{c.display_name}</h3><p>{c.legal_name} · /{c.slug}</p><small>Submitted {new Date(c.created_at).toLocaleString()}</small></div><div className="adminActions"><button disabled={busyId===c.id} onClick={()=>changeCompany(c.id,"published")}>Approve & publish</button><button className="dangerAction" disabled={busyId===c.id} onClick={()=>changeCompany(c.id,"rejected")}>Reject</button></div></article>)}
    </section>
    <section className="registerCard adminQueue"><div className="formHeader"><div><small className="eyebrow">QUEUE 02</small><h2>Business verification documents</h2></div><span>{verifications.length} ITEMS</span></div>
      {verifications.length===0?<p className="accountMuted">No verification documents awaiting review.</p>:verifications.map(v=><article className="adminItem" key={v.id}><div className="adminItemMain"><h3>{companyNames[v.company_id]||"Business"} · {v.verification_type}</h3><p>Reference: {v.reference_value||"Not provided"} · {v.status}</p><small>Submitted {v.submitted_at?new Date(v.submitted_at).toLocaleString():"date unavailable"}</small>{v.document_path&&<button className="textAction" onClick={()=>openDocument(v.document_path!)}>Open private document ↗</button>}<textarea rows={2} placeholder="Reviewer note (optional)" value={notes[v.id]||""} onChange={e=>setNotes(old=>({...old,[v.id]:e.target.value}))}/></div><div className="adminActions"><button disabled={busyId===v.id} onClick={()=>reviewVerification(v,"verified")}>Mark verified</button><button className="dangerAction" disabled={busyId===v.id} onClick={()=>reviewVerification(v,"rejected")}>Reject</button></div></article>)}
    </section>
    <section className="registerCard adminQueue"><div className="formHeader"><div><small className="eyebrow">QUEUE 03</small><h2>Customer reviews</h2></div><span>{reviews.length} ITEMS</span></div>
      {reviews.length===0?<p className="accountMuted">No customer reviews awaiting moderation.</p>:reviews.map(r=><article className="adminItem" key={r.id}><div className="adminItemMain"><h3>{companyNames[r.company_id]||"Business"} · {r.rating}/5</h3><p>{r.title||"Customer review"}</p><small>{r.body||"No written review"} · {new Date(r.created_at).toLocaleString()}</small></div><div className="adminActions"><button disabled={busyId===r.id} onClick={()=>moderateReview(r.id,"published")}>Publish</button><button className="dangerAction" disabled={busyId===r.id} onClick={()=>moderateReview(r.id,"rejected")}>Reject</button></div></article>)}
    </section>
    <section className="registerCard adminQueue"><div className="formHeader"><div><small className="eyebrow">QUEUE 04</small><h2>Reports & safety issues</h2></div><span>{reports.length} ITEMS</span></div>
      {reports.length===0?<p className="accountMuted">No open reports.</p>:reports.map(r=><article className="adminItem" key={r.id}><div className="adminItemMain"><h3>{r.target_type} · {r.reason.replaceAll("_"," ")}</h3><p>Target ID: {r.target_id}</p><small>{r.details||"No additional detail"} · {new Date(r.created_at).toLocaleString()}</small><textarea rows={2} placeholder="Internal reviewer note" value={notes[r.id]||""} onChange={e=>setNotes(old=>({...old,[r.id]:e.target.value}))}/></div><div className="adminActions"><button disabled={busyId===r.id} onClick={()=>resolveReport(r,"resolved")}>Resolve</button><button className="dangerAction" disabled={busyId===r.id} onClick={()=>resolveReport(r,"dismissed")}>Dismiss</button></div></article>)}
    </section>
    <footer className="registerFooter">DISCOVERLY · PLATFORM TRUST OPERATIONS</footer>
  </main>;
}