"use client";
import Link from "next/link";
import { useEffect, useState, type FormEvent } from "react";
import { useParams, useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";

type Company={id:string;display_name:string};
type Verification={id:string;verification_type:string;status:string;reference_value:string|null;reviewer_note:string|null;submitted_at:string|null;created_at:string};

const types=[
  {value:"business_document",label:"Business registration document",needsFile:true},
  {value:"gstin",label:"GSTIN supporting document",needsFile:true},
  {value:"address",label:"Business address proof",needsFile:true},
  {value:"website",label:"Official website / domain reference",needsFile:false},
  {value:"reference",label:"Other business reference",needsFile:false}
];

export default function BusinessVerificationPage(){
  const params=useParams<{companyId:string}>();const companyId=String(params.companyId||"");const router=useRouter();
  const [userId,setUserId]=useState("");const [company,setCompany]=useState<Company|null>(null);
  const [cases,setCases]=useState<Verification[]>([]);const [loading,setLoading]=useState(true);const [saving,setSaving]=useState(false);
  const [error,setError]=useState("");const [notice,setNotice]=useState("");const [kind,setKind]=useState("business_document");
  const [reference,setReference]=useState("");const [file,setFile]=useState<File|null>(null);
  const selected=types.find(t=>t.value===kind)||types[0];

  async function load(){
    const sb=createClient();if(!sb){setError("Supabase connection settings are missing.");setLoading(false);return;}
    const {data:{user}}=await sb.auth.getUser();
    if(!user){router.replace("/auth?mode=login&next="+encodeURIComponent("/business/"+companyId+"/verification"));return;}
    setUserId(user.id);
    const [c,v]=await Promise.all([
      sb.from("companies").select("id,display_name").eq("id",companyId).maybeSingle(),
      sb.from("verification_cases").select("id,verification_type,status,reference_value,reviewer_note,submitted_at,created_at").eq("company_id",companyId).order("created_at",{ascending:false})
    ]);
    if(c.error||!c.data){setError(c.error?.message||"Business not found or access denied.");setLoading(false);return;}
    if(v.error){setError(v.error.message);setLoading(false);return;}
    setCompany(c.data as Company);setCases((v.data||[]) as Verification[]);setLoading(false);
  }
  useEffect(()=>{void load();},[companyId]);

  async function submit(event:FormEvent<HTMLFormElement>){
    event.preventDefault();setError("");setNotice("");
    const sb=createClient();if(!sb||!company||!userId)return;
    if(selected.needsFile&&!file){setError("Please attach the supporting document for this verification type.");return;}
    if(file&&(file.size>10*1024*1024||!["application/pdf","image/jpeg","image/png"].includes(file.type))){setError("File must be PDF, JPG or PNG and 10 MB or smaller.");return;}
    setSaving(true);let documentPath:string|null=null;
    if(file){
      const ext=file.type==="application/pdf"?"pdf":file.type==="image/png"?"png":"jpg";
      documentPath=companyId+"/"+userId+"/"+crypto.randomUUID()+"."+ext;
      const {error:uploadError}=await sb.storage.from("company-verification").upload(documentPath,file,{upsert:false,contentType:file.type});
      if(uploadError){setSaving(false);setError("Private document upload failed: "+uploadError.message);return;}
    }
    const {error:insertError}=await sb.from("verification_cases").insert({
      company_id:companyId,verification_type:kind,status:"submitted",
      reference_value:reference.trim()||null,document_path:documentPath,submitted_at:new Date().toISOString()
    });
    if(insertError){
      if(documentPath)await sb.storage.from("company-verification").remove([documentPath]);
      setSaving(false);setError(insertError.message);return;
    }
    setSaving(false);setFile(null);setReference("");setNotice("Your request has been submitted. A platform reviewer will inspect it; no government or GSTIN database check happens automatically.");
    await load();
  }

  if(loading)return <main className="registerShell"><p className="loadingText">Loading verification…</p></main>;
  return <main className="registerShell">
    <header className="registerNav"><Link className="brand" href="/">D<span>.</span> &nbsp; DISCOVERLY</Link><Link href={"/business/"+companyId+"/manage"}>Back to business ↗</Link></header>
    <section className="registerIntro"><small className="eyebrow">TRUST & VERIFICATION</small><h1>Build business<br/><em>trust.</em></h1><p>Submit supporting details for a human review. Your documents stay private and are visible only to authorized company admins and platform reviewers.</p></section>
    <section className="registerCard">
      <div className="formHeader"><div><small className="eyebrow">BUSINESS PROFILE</small><h2>{company?.display_name}</h2></div><span>PRIVATE REVIEW</span></div>
      {error&&<p className="formError" role="alert">{error}</p>}{notice&&<p className="formSuccess" role="status">{notice}</p>}
      <form className="businessForm" onSubmit={submit}>
        <div className="fieldGrid">
          <label className="fullField">What do you want reviewed?<select value={kind} onChange={e=>{setKind(e.target.value);setFile(null);}}>{types.map(t=><option key={t.value} value={t.value}>{t.label}</option>)}</select></label>
          <label className="fullField">Reference number / website (optional)<input maxLength={160} value={reference} onChange={e=>setReference(e.target.value)} placeholder="Enter only the reference needed for this review"/></label>
          <label className="fullField">Supporting file {selected.needsFile?"*":"(optional)"}<input type="file" accept=".pdf,image/jpeg,image/png,application/pdf" required={selected.needsFile} onChange={e=>setFile(e.target.files?.[0]||null)}/><small>PDF, JPG or PNG · maximum 10 MB. Avoid uploading unrelated personal information.</small></label>
        </div>
        <p className="privacyNote">Verification is reviewed by a person. A “Verified” status means DISCOVERLY reviewed the submitted evidence; it does not mean we have an automatic government GSTIN or company-registry connection.</p>
        <button className="registerSubmit" disabled={saving}>{saving?"Uploading securely…":"Submit for verification →"}</button>
      </form>
      <div className="verificationHistory"><div className="accountPanelHead"><div><small className="eyebrow">SUBMISSION HISTORY</small><h2>Your verification requests</h2></div></div>
        {cases.length===0?<p className="accountMuted">No verification request submitted yet.</p>:cases.map(item=><article className="verificationRow" key={item.id}><div><strong>{types.find(t=>t.value===item.verification_type)?.label||item.verification_type}</strong><small>{item.reference_value||"No reference added"} · {item.submitted_at?new Date(item.submitted_at).toLocaleDateString():"Not dated"}</small>{item.reviewer_note&&<p>{item.reviewer_note}</p>}</div><span className={"statusPill status-"+item.status}>{item.status.replaceAll("_"," ")}</span></article>)}
      </div>
    </section>
    <footer className="registerFooter">DISCOVERLY · TRUST IS EARNED, NOT ASSUMED</footer>
  </main>;
}