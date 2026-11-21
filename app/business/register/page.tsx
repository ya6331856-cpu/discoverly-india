"use client";
import Link from "next/link";
import {useEffect,useMemo,useState} from "react";
import {useRouter} from "next/navigation";
import {createClient} from "@/lib/supabase/client";

type Category={id:string;name:string;slug:string;category_type:"industry"|"business_type"};
const entityTypes=["Proprietorship","Partnership","Limited Liability Partnership (LLP)","Private Limited Company","Public Limited Company","Trust / Society / Non-profit","Other"];

export default function BusinessRegisterPage(){
 const router=useRouter();
 const[loading,setLoading]=useState(true);
 const[saving,setSaving]=useState(false);
 const[error,setError]=useState("");
 const[success,setSuccess]=useState("");
 const[categories,setCategories]=useState<Category[]>([]);
 const[legalName,setLegalName]=useState("");
 const[displayName,setDisplayName]=useState("");
 const[entityType,setEntityType]=useState("Proprietorship");
 const[description,setDescription]=useState("");
 const[tagline,setTagline]=useState("");
 const[website,setWebsite]=useState("");
 const[email,setEmail]=useState("");
 const[phone,setPhone]=useState("");
 const[city,setCity]=useState("");
 const[stateName,setStateName]=useState("");
 const[businessType,setBusinessType]=useState("");
 const[industry,setIndustry]=useState("");

 useEffect(()=>{
  let active=true;
  async function init(){
   const sb=createClient();
   if(!sb){if(active){setError("Supabase configuration is missing. This page is ready, but the deployment needs its public connection settings.");setLoading(false);}return;}
   const {data:{user}}=await sb.auth.getUser();
   if(!user){router.replace("/auth?next=/business/register");return;}
   const {data,error:loadError}=await sb.from("categories").select("id,name,slug,category_type").eq("is_active",true).in("category_type",["industry","business_type"]).order("name");
   if(active){
    if(loadError)setError("Business categories could not be loaded. Please refresh the page.");
    else setCategories((data??[]) as Category[]);
    setLoading(false);
   }
  }
  void init();
  return()=>{active=false;};
 },[router]);

 const businessTypes=useMemo(()=>categories.filter(c=>c.category_type==="business_type"),[categories]);
 const industries=useMemo(()=>categories.filter(c=>c.category_type==="industry"),[categories]);

 async function submit(event:React.FormEvent<HTMLFormElement>){
  event.preventDefault();setError("");setSuccess("");
  const sb=createClient();if(!sb){setError("Supabase configuration is missing.");return;}
  setSaving(true);
  const slugBase=displayName.toLowerCase().normalize("NFKD").replace(/[\u0300-\u036f]/g,"").replace(/[^a-z0-9]+/g,"-").replace(/^-|-$/g,"").slice(0,48)||"business";
  const {error:saveError}=await sb.rpc("create_business_profile",{
   p_legal_name:legalName.trim(),
   p_display_name:displayName.trim(),
   p_slug:slugBase+"-"+crypto.randomUUID().slice(0,6),
   p_entity_type:entityType,
   p_description:description.trim()||null,
   p_website_url:website.trim()||null,
   p_tagline:tagline.trim()||null,
   p_public_email:email.trim()||null,
   p_public_phone:phone.trim()||null,
   p_city:city.trim(),
   p_state:stateName.trim(),
   p_business_type_category_id:businessType,
   p_industry_category_id:industry
  });
  if(saveError)setError(saveError.message.includes("duplicate key")?"A similar business URL already exists. Please change the public business name slightly and try again.":saveError.message);
  else setSuccess("Your business profile has been saved as a draft. It is not publicly listed yet. You can continue adding details before submitting it for review.");
  setSaving(false);
 }

 if(loading)return <main className="registerShell"><p className="loadingText">Preparing your business registration…</p></main>;

 return <main className="registerShell">
  <header className="registerNav"><Link className="brand" href="/">D<span>.</span> &nbsp; DISCOVERLY</Link><Link href="/">Back to discovery ↗</Link></header>
  <section className="registerIntro"><small className="eyebrow">BUSINESS ONBOARDING · INDIA</small><h1>Put your business<br/>on the <em>map.</em></h1><p>Create a business profile to help customers, buyers and partners discover what you offer.</p></section>
  <section className="registerCard">
   <div className="formHeader"><div><small className="eyebrow">STEP 1 · BASIC DETAILS</small><h2>Tell us about your business</h2></div><span>DRAFT PROFILE</span></div>
   {error&&<p className="formError" role="alert">{error}</p>}
   {success?<div className="formSuccess"><span>✓</span><h3>Business profile created</h3><p>{success}</p><Link href="/account">Open my account ↗</Link></div>:
   <form onSubmit={submit} className="businessForm">
    <div className="fieldGrid">
     <label>Public business name *<input required maxLength={120} value={displayName} onChange={e=>setDisplayName(e.target.value)} placeholder="e.g. Sunrise Engineering"/></label>
     <label>Legal / registered name *<input required maxLength={160} value={legalName} onChange={e=>setLegalName(e.target.value)} placeholder="Name on registration documents"/></label>
     <label>Business legal structure<select value={entityType} onChange={e=>setEntityType(e.target.value)}>{entityTypes.map(v=><option key={v}>{v}</option>)}</select></label>
     <label>Business type *<select required value={businessType} onChange={e=>setBusinessType(e.target.value)}><option value="">Choose business type</option>{businessTypes.map(c=><option key={c.id} value={c.id}>{c.name}</option>)}</select></label>
     <label className="fullField">Industry *<select required value={industry} onChange={e=>setIndustry(e.target.value)}><option value="">Choose your main industry</option>{industries.map(c=><option key={c.id} value={c.id}>{c.name}</option>)}</select></label>
     <label className="fullField">Short tagline<input maxLength={120} value={tagline} onChange={e=>setTagline(e.target.value)} placeholder="What makes your business useful?"/></label>
     <label className="fullField">About the business<textarea rows={4} maxLength={800} value={description} onChange={e=>setDescription(e.target.value)} placeholder="Describe your products, services or capabilities in a few clear sentences."/></label>
     <label>Website (optional)<input type="url" value={website} onChange={e=>setWebsite(e.target.value)} placeholder="https://example.com"/></label>
     <label>Public contact email<input type="email" value={email} onChange={e=>setEmail(e.target.value)} placeholder="business@example.com"/></label>
     <label>Public phone / WhatsApp<input type="tel" maxLength={20} value={phone} onChange={e=>setPhone(e.target.value)} placeholder="+91…"/></label>
     <label>City *<input required maxLength={100} value={city} onChange={e=>setCity(e.target.value)} placeholder="e.g. Mumbai"/></label>
     <label>State *<input required maxLength={100} value={stateName} onChange={e=>setStateName(e.target.value)} placeholder="e.g. Maharashtra"/></label>
    </div>
    <p className="privacyNote">Only your city and state are added as the initial business location. We do not ask for your private street address in this step.</p>
    <button className="registerSubmit" disabled={saving||!businessTypes.length||!industries.length}>{saving?"Saving your profile…":"Create draft business profile →"}</button>
    <p className="draftNote">Your profile starts as a private draft. It will not appear in public search until it has been reviewed and published.</p>
   </form>}
  </section>
  <footer className="registerFooter">DISCOVERLY · BUSINESS DISCOVERY NETWORK</footer>
 </main>;
}