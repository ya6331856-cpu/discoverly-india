"use client";
import Link from "next/link";
import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";

type Notification={id:string;notification_type:string;title:string;body:string;entity_type:string|null;entity_id:string|null;read_at:string|null;created_at:string};

export default function NotificationsPage(){
  const router=useRouter();const [items,setItems]=useState<Notification[]>([]);const [loading,setLoading]=useState(true);
  const [error,setError]=useState("");const [working,setWorking]=useState(false);
  async function load(){
    const sb=createClient();if(!sb){setError("Supabase connection settings are missing.");setLoading(false);return;}
    const {data:{user}}=await sb.auth.getUser();if(!user){router.replace("/auth?mode=login&next=/notifications");return;}
    const {data,error:queryError}=await sb.from("notifications").select("id,notification_type,title,body,entity_type,entity_id,read_at,created_at").order("created_at",{ascending:false}).limit(60);
    if(queryError)setError(queryError.message);else setItems((data||[]) as Notification[]);
    setLoading(false);
  }
  useEffect(()=>{void Promise.resolve().then(()=>load());},[]);
  async function markRead(id:string){
    const sb=createClient();if(!sb)return;setWorking(true);
    const {error:updateError}=await sb.from("notifications").update({read_at:new Date().toISOString()}).eq("id",id);
    if(updateError)setError(updateError.message);else setItems(old=>old.map(n=>n.id===id?{...n,read_at:new Date().toISOString()}:n));
    setWorking(false);
  }
  async function markAllRead(){
    const sb=createClient();if(!sb)return;setWorking(true);
    const stamp=new Date().toISOString();
    const {error:updateError}=await sb.from("notifications").update({read_at:stamp}).is("read_at",null);
    if(updateError)setError(updateError.message);else setItems(old=>old.map(n=>n.read_at? n : {...n,read_at:stamp}));
    setWorking(false);
  }
  const unread=items.filter(n=>!n.read_at).length;
  return <main className="registerShell">
    <header className="registerNav"><Link className="brand" href="/">D<span>.</span> &nbsp; DISCOVERLY</Link><Link href="/account">My account ↗</Link></header>
    <section className="registerIntro"><small className="eyebrow">YOUR ACTIVITY</small><h1>Stay in the<br/><em>loop.</em></h1><p>Updates about buyer requests, quotations, business reviews and verification decisions.</p></section>
    <section className="registerCard notificationPanel">
      <div className="accountPanelHead"><div><small className="eyebrow">INBOX · {unread} UNREAD</small><h2>Notifications</h2></div><button className="textAction" onClick={markAllRead} disabled={working||unread===0}>Mark all read</button></div>
      {error&&<p className="formError" role="alert">{error}</p>}
      {loading?<p className="accountMuted">Loading notifications…</p>:items.length===0?<div className="accountEmpty"><span>✳</span><h3>You are all caught up</h3><p>New platform activity will appear here.</p><Link href="/account">Go to your account →</Link></div>:
        <div className="notificationList">{items.map(item=><article className={"notificationItem "+(!item.read_at?"unread":"")} key={item.id}><div className="notificationDot"/><div className="notificationText"><h3>{item.title}</h3><p>{item.body}</p><small>{new Date(item.created_at).toLocaleString()}</small></div>{!item.read_at&&<button className="textAction" disabled={working} onClick={()=>markRead(item.id)}>Mark read</button>}</article>)}</div>}
    </section>
    <footer className="registerFooter">DISCOVERLY · YOUR BUSINESS, MORE DISCOVERABLE</footer>
  </main>;
}