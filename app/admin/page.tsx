"use client";
import Link from "next/link";
import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";

type Company={id:string;display_name:string;legal_name:string;slug:string;status:string;created_at:string};
type Verification={id:string;company_id:string;verification_type:string;status:string;reference_value:string|null;document_path:string|null;submitted_at:string|null};
type Review={id:string;company_id:string;rating:number;title:string|null;body:string|null;created_at:string};
type Report={id:string;target_type:string;target_id:string;reason:string;details:string|null;status:string;created_at:string};
type DataSource={id:string;source_key:string;name:string;license_name:string;status:string;ingestion_enabled:boolean;source_url:string;terms_url:string|null;attribution_text:string|null};
type ImportItem={id:string;business_name:string;city:string|null;state:string|null;category_name:string|null;status:string;duplicate_of_company_id:string|null;source_record_url:string|null;created_at:string};
type ImportBatch={id:string;status:string;file_name:string|null;input_count:number;staged_count:number;duplicate_count:number;rejected_count:number;approved_count:number;created_at:string};
function parseCsv(text:string):Record<string,string>[]{
  const rows:string[][]=[];let row:string[]=[];let cell="";let quoted=false;
  for(let i=0;i<text.length;i++){const ch=text[i];if(ch==='"'){if(quoted&&text[i+1]==='"'){cell+='"';i++;}else quoted=!quoted;}else if(ch===','&&!quoted){row.push(cell);cell="";}else if((ch==='\n'||ch==='\r')&&!quoted){if(ch==='\r'&&text[i+1]==='\n')i++;row.push(cell);if(row.some(v=>v.trim()))rows.push(row);row=[];cell="";}else cell+=ch;}
  row.push(cell);if(row.some(v=>v.trim()))rows.push(row);if(rows.length<2)return [];
  const headers=rows[0].map(h=>h.trim().toLowerCase().replace(/[\s-]+/g,"_"));
  return rows.slice(1).map(values=>Object.fromEntries(headers.map((h,i)=>[h,(values[i]||"").trim()])));
}


export default function AdminPage(){
  const router=useRouter();
  const [loading,setLoading]=useState(true);const [allowed,setAllowed]=useState(false);const [userId,setUserId]=useState("");
  const [error,setError]=useState("");const [notice,setNotice]=useState("");const [busyId,setBusyId]=useState("");
  const [companies,setCompanies]=useState<Company[]>([]);const [verifications,setVerifications]=useState<Verification[]>([]);
  const [reviews,setReviews]=useState<Review[]>([]);const [reports,setReports]=useState<Report[]>([]);
  const [companyNames,setCompanyNames]=useState<Record<string,string>>({});const [notes,setNotes]=useState<Record<string,string>>({});
  const [dataSources,setDataSources]=useState<DataSource[]>([]);
  const [importItems,setImportItems]=useState<ImportItem[]>([]);
  const [importBatches,setImportBatches]=useState<ImportBatch[]>([]);
  const [selectedSource,setSelectedSource]=useState("");
  const [importBusy,setImportBusy]=useState(false);
  const [importSummary,setImportSummary]=useState("");


  async function load(){
    const sb=createClient();if(!sb){setError("Supabase connection settings are missing.");setLoading(false);return;}
    const {data:{user}}=await sb.auth.getUser();if(!user){router.replace("/auth?mode=login&next=/admin");return;}
    setUserId(user.id);
    const {data:roles,error:roleError}=await sb.from("user_roles").select("role").eq("user_id",user.id);
    if(roleError){setError(roleError.message);setLoading(false);return;}
    if(!(roles||[]).some((r:{role:string})=>r.role==="admin"||r.role==="moderator")){setAllowed(false);setLoading(false);return;}
    setAllowed(true);
    const [co,ve,re,cr,ds,st,ba]=await Promise.all([
      sb.from("companies").select("id,display_name,legal_name,slug,status,created_at").eq("status","pending_review").order("created_at",{ascending:true}),
      sb.from("verification_cases").select("id,company_id,verification_type,status,reference_value,document_path,submitted_at").in("status",["submitted","in_review"]).order("submitted_at",{ascending:true}),
      sb.from("reviews").select("id,company_id,rating,title,body,created_at").eq("moderation_status","pending").order("created_at",{ascending:true}),
      sb.from("content_reports").select("id,target_type,target_id,reason,details,status,created_at").in("status",["open","in_review"]).order("created_at",{ascending:true}),
      sb.from("data_sources").select("id,source_key,name,license_name,status,ingestion_enabled,source_url,terms_url,attribution_text").eq("status","active").eq("ingestion_enabled",true).order("name"),
      sb.from("business_import_staging").select("id,business_name,city,state,category_name,status,duplicate_of_company_id,source_record_url,created_at").in("status",["needs_review","duplicate"]).order("created_at",{ascending:false}).limit(100),
      sb.from("data_import_batches").select("id,status,file_name,input_count,staged_count,duplicate_count,rejected_count,approved_count,created_at").order("created_at",{ascending:false}).limit(10)
    ]);
    const firstError=co.error||ve.error||re.error||cr.error||ds.error||st.error||ba.error;
    if(firstError)setError(firstError.message);
    const companyRows=(co.data||[]) as Company[];const verRows=(ve.data||[]) as Verification[];
    const reviewRows=(re.data||[]) as Review[];const reportRows=(cr.data||[]) as Report[];
    const ids=Array.from(new Set([...companyRows.map(x=>x.id),...verRows.map(x=>x.company_id),...reviewRows.map(x=>x.company_id)]));
    const names:Record<string,string>={};
    if(ids.length){const {data}=await sb.from("companies").select("id,display_name").in("id",ids);for(const row of data||[])names[row.id]=row.display_name;}
    setCompanies(companyRows);setVerifications(verRows);setReviews(reviewRows);setReports(reportRows);setCompanyNames(names);setDataSources((ds.data||[]) as DataSource[]);setImportItems((st.data||[]) as ImportItem[]);setImportBatches((ba.data||[]) as ImportBatch[]);if(!selectedSource&&ds.data?.length)setSelectedSource(ds.data[0].id);
    setLoading(false);
  }
  useEffect(()=>{void Promise.resolve().then(()=>load());},[]);


  async function importCsvFile(file:File){
    const sb=createClient();if(!sb||!selectedSource)return;
    setImportBusy(true);setError("");setNotice("");setImportSummary("");
    try{
      const parsed=parseCsv(await file.text());
      const rows=parsed.map(r=>({
        business_name:r.business_name||r.name||r.company_name||r.company||"",
        legal_name:r.legal_name||r.registered_name||"",
        city:r.city||r.district||"",state:r.state||r.state_name||"",
        category_name:r.category_name||r.category||r.industry||"",
        website_url:r.website_url||r.website||"",public_phone:r.public_phone||r.phone||r.mobile||"",
        public_email:r.public_email||r.email||"",external_id:r.external_id||r.cin||r.udyam_number||r.id||"",
        source_record_url:r.source_record_url||r.source_url||r.url||"",source_record_hash:r.source_record_hash||""
      })).filter(r=>r.business_name.trim()).slice(0,1000);
      if(!rows.length)throw new Error("No business_name/name/company_name column or valid rows found.");
      const {data:batch,error:batchError}=await sb.from("data_import_batches").insert({source_id:selectedSource,created_by:userId,status:"created",file_name:file.name,input_count:rows.length}).select("id").single();
      if(batchError)throw batchError;
      const totals={staged_count:0,duplicate_count:0,rejected_count:0};
      for(let i=0;i<rows.length;i+=200){
        const {data,error:stageError}=await sb.rpc("admin_stage_business_import_rows",{p_batch_id:batch.id,p_rows:rows.slice(i,i+200)});
        if(stageError)throw stageError;
        if(data){totals.staged_count+=Number(data.staged_count||0);totals.duplicate_count+=Number(data.duplicate_count||0);totals.rejected_count+=Number(data.rejected_count||0);}
      }
      setImportSummary(`Staged ${totals.staged_count} records · ${totals.duplicate_count} likely duplicates · ${totals.rejected_count} rejected rows`);
      setNotice("CSV staged successfully. Nothing has been published.");await load();
    }catch(e){setError(e instanceof Error?e.message:"CSV import failed.");}
    finally{setImportBusy(false);}
  }
  async function reviewImportItem(item:ImportItem,decision:"approve"|"reject"|"duplicate"){
    const sb=createClient();if(!sb)return;setBusyId(item.id);setError("");setNotice("");
    const {error:reviewError}=await sb.rpc("admin_review_business_import",{p_staging_id:item.id,p_decision:decision,p_review_note:notes[item.id]?.trim()||null});
    setBusyId("");if(reviewError){setError(reviewError.message);return;}
    setNotice(decision==="approve"?"Imported business saved as a private draft. Owner confirmation is required before publication.":`Import record marked ${decision}.`);
    await load();
  }
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

    <section className="registerCard adminQueue">
      <div className="formHeader"><div><small className="eyebrow">DATA ENGINE · INDIA</small><h2>Business data acquisition</h2></div><span>{dataSources.length} APPROVED SOURCES</span></div>
      <p className="accountMuted">Import CSV exports only from approved source terms. Each record keeps source and licence provenance. Imported businesses remain pending review and are not published automatically.</p>
      <div className="formField"><label>Approved source</label><select value={selectedSource} onChange={e=>setSelectedSource(e.target.value)}>{dataSources.map(source=><option key={source.id} value={source.id}>{source.name} · {source.license_name}</option>)}</select></div>
      {dataSources.filter(x=>x.id===selectedSource).map(source=><div className="sourceNotice" key={source.id}><p><strong>{source.license_name}</strong></p><p>{source.attribution_text||"Attribution required as stated by source terms."}</p><p><a href={source.source_url} target="_blank" rel="noreferrer">Open official source ↗</a>{source.terms_url&&<> · <a href={source.terms_url} target="_blank" rel="noreferrer">Licence terms ↗</a></>}</p></div>)}
      <div className="formField"><label>Upload CSV file</label><input type="file" accept=".csv,text/csv" disabled={importBusy||!selectedSource} onChange={e=>{const file=e.target.files?.[0];if(file)void importCsvFile(file);e.currentTarget.value="";}}/></div>
      <p className="accountMuted">Headers: name/business_name, city, state, category, website, phone, email, external_id, source_url. Maximum 1,000 rows per upload. <a href="/templates/discoverly-business-import-template.csv" download>Download CSV template ↧</a></p>
      {importBusy&&<p className="formSuccess">Staging CSV records…</p>}{importSummary&&<p className="formSuccess">{importSummary}</p>}
      <div className="formHeader"><div><small className="eyebrow">IMPORT HISTORY</small><h2>Recent data batches</h2></div><span>{importBatches.length} BATCHES</span></div>
      {importBatches.length===0?<p className="accountMuted">No import batches yet.</p>:importBatches.map(batch=><article className="adminItem" key={batch.id}><div className="adminItemMain"><h3>{batch.file_name||"Business data import"}</h3><p>{batch.status} · {new Date(batch.created_at).toLocaleString()}</p><small>{batch.input_count} input · {batch.staged_count} staged · {batch.duplicate_count} duplicates · {batch.rejected_count} rejected · {batch.approved_count} imported</small></div></article>)}
      <div className="formHeader"><div><small className="eyebrow">QUEUE 00</small><h2>Imported records awaiting review</h2></div><span>{importItems.length} ITEMS</span></div>
      {importItems.length===0?<p className="accountMuted">No imported records awaiting review.</p>:importItems.map(item=><article className="adminItem" key={item.id}><div className="adminItemMain"><h3>{item.business_name}</h3><p>{[item.city,item.state,item.category_name].filter(Boolean).join(" · ")||"Location/category not supplied"}</p><small>{item.status==="duplicate"?"Possible duplicate":"Needs review"}{item.source_record_url?<> · <a href={item.source_record_url} target="_blank" rel="noreferrer">Source record ↗</a></>:null}</small><textarea rows={2} placeholder="Reviewer note" value={notes[item.id]||""} onChange={e=>setNotes(old=>({...old,[item.id]:e.target.value}))}/></div><div className="adminActions"><button disabled={busyId===item.id||item.status==="duplicate"} onClick={()=>reviewImportItem(item,"approve")}>Approve import</button><button className="dangerAction" disabled={busyId===item.id} onClick={()=>reviewImportItem(item,item.status==="duplicate"?"duplicate":"reject")}>{item.status==="duplicate"?"Confirm duplicate":"Reject"}</button></div></article>)}
    </section>
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