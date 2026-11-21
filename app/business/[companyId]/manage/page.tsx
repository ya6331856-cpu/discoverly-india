"use client";
import Link from "next/link";
import { useEffect, useMemo, useState, type FormEvent } from "react";
import { useParams, useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";

type Category={id:string;name:string;category_type:"industry"|"business_type"};
type Company={id:string;legal_name:string;display_name:string;entity_type:string|null;description:string|null;website_url:string|null;status:string};
type Profile={tagline:string|null;public_email:string|null;public_phone:string|null;logo_path:string|null};
type Location={city:string|null;state:string|null};
type RoleCategory={category_id:string;is_primary:boolean};

const entityTypes=["Proprietorship","Partnership","Limited Liability Partnership (LLP)","Private Limited Company","Public Limited Company","Trust / Society / Non-profit","Other"];

export default function ManageBusinessPage(){
  const params=useParams<{companyId:string}>();
  const companyId=String(params.companyId||"");
  const router=useRouter();
  const [userId,setUserId]=useState("");
  const [loading,setLoading]=useState(true);
  const [saving,setSaving]=useState(false);
  const [error,setError]=useState("");
  const [notice,setNotice]=useState("");
  const [company,setCompany]=useState<Company|null>(null);
  const [profile,setProfile]=useState<Profile|null>(null);
  const [categories,setCategories]=useState<Category[]>([]);
  const [companyCategories,setCompanyCategories]=useState<RoleCategory[]>([]);
  const [legalName,setLegalName]=useState("");
  const [displayName,setDisplayName]=useState("");
  const [entityType,setEntityType]=useState("Proprietorship");
  const [description,setDescription]=useState("");
  const [tagline,setTagline]=useState("");
  const [website,setWebsite]=useState("");
  const [email,setEmail]=useState("");
  const [phone,setPhone]=useState("");
  const [city,setCity]=useState("");
  const [stateName,setStateName]=useState("");
  const [businessType,setBusinessType]=useState("");
  const [industry,setIndustry]=useState("");
  const [logoPath,setLogoPath]=useState("");
  const [logoFile,setLogoFile]=useState<File|null>(null);

  useEffect(()=>{
    let active=true;
    async function load(){
      const sb=createClient();
      if(!sb){if(active){setError("Supabase connection settings are missing on this deployment.");setLoading(false);}return;}
      const {data:{user}}=await sb.auth.getUser();
      if(!user){router.replace("/auth?mode=login&next="+encodeURIComponent("/business/"+companyId+"/manage"));return;}
      const [co,pr,loc,cc,cats]=await Promise.all([
        sb.from("companies").select("id,legal_name,display_name,entity_type,description,website_url,status").eq("id",companyId).maybeSingle(),
        sb.from("company_profiles").select("tagline,public_email,public_phone,logo_path").eq("company_id",companyId).maybeSingle(),
        sb.from("company_locations").select("city,state").eq("company_id",companyId).eq("is_head_office",true).maybeSingle(),
        sb.from("company_categories").select("category_id,is_primary").eq("company_id",companyId),
        sb.from("categories").select("id,name,category_type").eq("is_active",true)
      ]);
      if(!active)return;
      if(co.error||!co.data){setError(co.error?.message||"Business not found or you do not have permission to manage it.");setLoading(false);return;}
      const c=co.data as Company; const p=(pr.data??null) as Profile|null; const l=loc.data as Location|null;
      const rel=(cc.data??[]) as RoleCategory[]; const all=(cats.data??[]) as Category[];
      setUserId(user.id);setCompany(c);setProfile(p);setCategories(all);setCompanyCategories(rel);
      setLegalName(c.legal_name);setDisplayName(c.display_name);setEntityType(c.entity_type||"Other");setDescription(c.description||"");
      setWebsite(c.website_url||"");setTagline(p?.tagline||"");setEmail(p?.public_email||"");setPhone(p?.public_phone||"");
      setCity(l?.city||"");setStateName(l?.state||"");setLogoPath(p?.logo_path||"");
      setIndustry(rel.find(x=>x.is_primary)?.category_id||all.find(x=>x.category_type==="industry")?.id||"");
      setBusinessType(rel.find(x=>!x.is_primary)?.category_id||"");
      setLoading(false);
    }
    void load();return()=>{active=false;};
  },[companyId,router]);

  const industryCategories=useMemo(()=>categories.filter(c=>c.category_type==="industry"),[categories]);
  const businessTypes=useMemo(()=>categories.filter(c=>c.category_type==="business_type"),[categories]);

  async function save(event:FormEvent<HTMLFormElement>){
    event.preventDefault();setError("");setNotice("");
    const sb=createClient();if(!sb||!company){setError("Business profile is not available.");return;}
    if(!userId){setError("Please sign in again.");return;}
    setSaving(true);
    let nextLogo=logoPath||null;
    if(logoFile){
      const allowed=["image/jpeg","image/png","image/webp"];
      if(!allowed.includes(logoFile.type)||logoFile.size>5*1024*1024){setSaving(false);setError("Logo must be JPG, PNG or WebP and 5 MB or smaller.");return;}
      const ext=logoFile.type==="image/png"?"png":logoFile.type==="image/webp"?"webp":"jpg";
      const path=companyId+"/"+userId+"/logo."+ext;
      const {error:uploadError}=await sb.storage.from("company-media").upload(path,logoFile,{upsert:true,contentType:logoFile.type,cacheControl:"3600"});
      if(uploadError){setSaving(false);setError("Logo upload failed: "+uploadError.message);return;}
      nextLogo=sb.storage.from("company-media").getPublicUrl(path).data.publicUrl;
    }
    const {data,error:saveError}=await sb.rpc("update_business_profile",{
      p_company_id:companyId,p_legal_name:legalName.trim(),p_display_name:displayName.trim(),p_entity_type:entityType,
      p_description:description.trim()||null,p_website_url:website.trim()||null,p_tagline:tagline.trim()||null,
      p_public_email:email.trim()||null,p_public_phone:phone.trim()||null,p_city:city.trim(),p_state:stateName.trim(),
      p_business_type_category_id:businessType,p_industry_category_id:industry,p_logo_path:nextLogo
    });
    setSaving(false);
    if(saveError){setError(saveError.message);return;}
    setLogoPath(nextLogo||"");setLogoFile(null);
    setCompany({...company,legal_name:legalName.trim(),display_name:displayName.trim(),entity_type:entityType,description:description.trim()||null,website_url:website.trim()||null,status:String(data||company.status)});
    setNotice(data==="pending_review"?"Changes saved. Because the business was published, it has been moved back to review and is temporarily hidden from public search.":"Changes saved successfully.");
  }

  async function submitForReview(){
    const sb=createClient();if(!sb||!company)return;
    setError("");setNotice("");setSaving(true);
    const {data,error:submitError}=await sb.from("companies").update({status:"pending_review"}).eq("id",companyId).select("status").single();
    setSaving(false);
    if(submitError){setError(submitError.message);return;}
    setCompany({...company,status:data.status});setNotice("Your business has been submitted for platform review.");
  }

  if(loading)return <main className="registerShell"><p className="loadingText">Loading business profile…</p></main>;
  if(error&&!company)return <main className="registerShell"><header className="registerNav"><Link className="brand" href="/">D<span>.</span> &nbsp; DISCOVERLY</Link><Link href="/account">My account ↗</Link></header><section className="registerCard"><p className="formError">{error}</p></section></main>;

  return <main className="registerShell">
    <header className="registerNav"><Link className="brand" href="/">D<span>.</span> &nbsp; DISCOVERLY</Link><Link href="/account">My account ↗</Link></header>
    <section className="registerIntro"><small className="eyebrow">BUSINESS WORKSPACE</small><h1>Manage your<br/><em>presence.</em></h1><p>Edit your public details, upload your logo and send your profile for review.</p></section>
    <section className="registerCard">
      <div className="formHeader"><div><small className="eyebrow">PROFILE SETTINGS</small><h2>{company?.display_name}</h2></div><span className={"statusPill status-"+company?.status}>{company?.status.replaceAll("_"," ")}</span></div>
      <div className="accountQuickLinks"><Link href={"/business/"+companyId+"/verification"}>Business verification ↗</Link><Link href="/notifications">Notifications ↗</Link></div>
      {error&&<p className="formError" role="alert">{error}</p>}{notice&&<p className="formSuccess" role="status">{notice}</p>}
      <form className="businessForm" onSubmit={save}>
        <div className="fieldGrid">
          <label>Public business name *<input required maxLength={120} value={displayName} onChange={e=>setDisplayName(e.target.value)}/></label>
          <label>Legal / registered name *<input required maxLength={160} value={legalName} onChange={e=>setLegalName(e.target.value)}/></label>
          <label>Legal structure<select value={entityType} onChange={e=>setEntityType(e.target.value)}>{entityTypes.map(v=><option key={v}>{v}</option>)}</select></label>
          <label>Business type *<select required value={businessType} onChange={e=>setBusinessType(e.target.value)}><option value="">Choose business type</option>{businessTypes.map(c=><option key={c.id} value={c.id}>{c.name}</option>)}</select></label>
          <label className="fullField">Industry *<select required value={industry} onChange={e=>setIndustry(e.target.value)}><option value="">Choose industry</option>{industryCategories.map(c=><option key={c.id} value={c.id}>{c.name}</option>)}</select></label>
          <label className="fullField">Tagline<input maxLength={120} value={tagline} onChange={e=>setTagline(e.target.value)}/></label>
          <label className="fullField">About the business<textarea rows={4} maxLength={800} value={description} onChange={e=>setDescription(e.target.value)}/></label>
          <label>Website<input type="url" value={website} onChange={e=>setWebsite(e.target.value)} placeholder="https://example.com"/></label>
          <label>Public email<input type="email" value={email} onChange={e=>setEmail(e.target.value)}/></label>
          <label>Public phone / WhatsApp<input type="tel" maxLength={20} value={phone} onChange={e=>setPhone(e.target.value)}/></label>
          <label>City *<input required maxLength={100} value={city} onChange={e=>setCity(e.target.value)}/></label>
          <label>State *<input required maxLength={100} value={stateName} onChange={e=>setStateName(e.target.value)}/></label>
          <label className="fullField">Business logo (JPG, PNG, WebP · max 5 MB)<input type="file" accept="image/jpeg,image/png,image/webp" onChange={e=>setLogoFile(e.target.files?.[0]||null)}/>{logoPath&&<small>Current logo is saved. Choose a new file to replace it.</small>}</label>
        </div>
        <p className="privacyNote">Your public contact details and city/state may be visible to visitors. Do not add private home addresses or personal documents here.</p>
        <button className="registerSubmit" disabled={saving}>{saving?"Saving changes…":"Save business profile →"}</button>
      </form>
      <div className="reviewSubmitPanel"><div><strong>Ready for customers to discover you?</strong><p>Send your draft or updated profile to the DISCOVERLY review team. Only reviewers can publish it.</p></div><button type="button" className="authSubmit" disabled={saving||company?.status==="pending_review"} onClick={submitForReview}>{company?.status==="pending_review"?"Under review":"Submit for review →"}</button></div>
    </section>
    <footer className="registerFooter">DISCOVERLY · BUSINESS WORKSPACE</footer>
  </main>;
}