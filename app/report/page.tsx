"use client";
import Link from "next/link";
import {useEffect,useState,type FormEvent} from "react";
import {useRouter} from "next/navigation";
import {createClient} from "@/lib/supabase/client";

type Target={id:string;label:string};
type Kind="company"|"review"|"offering";
const reasons=[
  ["spam","Spam or fake listing"],
  ["fake_business","Business appears fake"],
  ["misleading_information","Misleading information"],
  ["abuse","Abusive or harmful content"],
  ["copyright","Copyright / intellectual property"],
  ["other","Other concern"]
] as const;

export default function ReportContentPage(){
  const router=useRouter();
  const [kind,setKind]=useState<Kind>("company");
  const [targets,setTargets]=useState<Target[]>([]);
  const [targetId,setTargetId]=useState("");
  const [reason,setReason]=useState<(typeof reasons)[number][0]>("misleading_information");
  const [details,setDetails]=useState("");
  const [loading,setLoading]=useState(true);
  const [saving,setSaving]=useState(false);
  const [error,setError]=useState("");
  const [notice,setNotice]=useState("");

  useEffect(()=>{
    let active=true;
    void Promise.resolve().then(async()=>{
      const sb=createClient();
      if(!sb){if(active){setError("Supabase connection settings are missing.");setLoading(false);}return;}
      const {data:{user}}=await sb.auth.getUser();
      if(!user){router.replace("/auth?mode=login&next=/report");return;}
      const [companies,reviews,offerings]=await Promise.all([
        sb.from("companies").select("id,display_name").eq("status","published").order("display_name").limit(500),
        sb.from("reviews").select("id,title,company_id").eq("moderation_status","published").order("created_at",{ascending:false}).limit(500),
        sb.from("offerings").select("id,title,company_id").eq("is_published",true).order("title").limit(500)
      ]);
      if(!active)return;
      if(companies.error||reviews.error||offerings.error){setError("Public listings could not be loaded. Please refresh.");setLoading(false);return;}
      const companyRows=(companies.data||[]) as {id:string;display_name:string}[];
      const companyName=new Map(companyRows.map(c=>[c.id,c.display_name]));
      if(kind==="company")setTargets(companyRows.map(c=>({id:c.id,label:c.display_name})));
      if(kind==="review")setTargets(((reviews.data||[]) as {id:string;title:string|null;company_id:string}[]).map(r=>({id:r.id,label:(r.title||"Customer review")+" · "+(companyName.get(r.company_id)||"Business")})));
      if(kind==="offering")setTargets(((offerings.data||[]) as {id:string;title:string;company_id:string}[]).map(o=>({id:o.id,label:o.title+" · "+(companyName.get(o.company_id)||"Business")})));
      setLoading(false);
    }).catch(()=>{if(active){setError("Could not load listings. Please refresh.");setLoading(false);}});
    return()=>{active=false;};
  },[kind,router]);

  async function submit(e:FormEvent<HTMLFormElement>){
    e.preventDefault();setError("");setNotice("");
    const sb=createClient();if(!sb)return;
    const {data:{user}}=await sb.auth.getUser();
    if(!user){router.replace("/auth?mode=login&next=/report");return;}
    setSaving(true);
    const {error:insertError}=await sb.from("content_reports").insert({
      reporter_user_id:user.id,target_type:kind,target_id:targetId,reason,details:details.trim()||null
    });
    setSaving(false);
    if(insertError){setError(insertError.code==="23505"?"You have already reported this item. Our reviewers can see your existing report.":insertError.message);return;}
    setNotice("Thank you. Your report has been sent to the DISCOVERLY moderation team.");
    setDetails("");setTargetId("");
  }

  return <main className="registerShell">
    <header className="registerNav"><Link className="brand" href="/">D<span>.</span> &nbsp; DISCOVERLY</Link><Link href="/account">My account ↗</Link></header>
    <section className="registerIntro"><small className="eyebrow">COMMUNITY SAFETY</small><h1>Help keep it<br/><em>trustworthy.</em></h1><p>Report a business, product/service listing or customer review that may break our platform rules.</p></section>
    <section className="registerCard">
      <div className="formHeader"><div><small className="eyebrow">CONTENT REPORT</small><h2>What should we review?</h2></div><span>PRIVATE REPORT</span></div>
      {error&&<p className="formError" role="alert">{error}</p>}{notice&&<p className="formSuccess" role="status">{notice}</p>}
      <form className="businessForm" onSubmit={submit}>
        <div className="fieldGrid">
          <label>Content type<select value={kind} onChange={e=>{setKind(e.target.value as Kind);setTargetId("");setLoading(true);}}><option value="company">Business</option><option value="offering">Product or service</option><option value="review">Customer review</option></select></label>
          <label>Reason<select value={reason} onChange={e=>setReason(e.target.value as typeof reason)}>{reasons.map(([v,label])=><option value={v} key={v}>{label}</option>)}</select></label>
          <label className="fullField">Select the listing<select required value={targetId} onChange={e=>setTargetId(e.target.value)}><option value="">{loading?"Loading listings…":"Choose an item"}</option>{targets.map(t=><option key={t.id} value={t.id}>{t.label}</option>)}</select></label>
          <label className="fullField">Additional details<textarea rows={4} maxLength={2000} value={details} onChange={e=>setDetails(e.target.value)} placeholder="Tell us what looks wrong. Do not include sensitive personal information."/></label>
        </div>
        <p className="privacyNote">Reports are private. Your name is not shown publicly on the listing. Please report only genuine concerns.</p>
        <button className="registerSubmit" disabled={saving||loading||!targetId}>{saving?"Sending report…":"Send report to moderators →"}</button>
      </form>
    </section>
    <footer className="registerFooter">DISCOVERLY · TRUST IS EARNED, NOT ASSUMED</footer>
  </main>;
}