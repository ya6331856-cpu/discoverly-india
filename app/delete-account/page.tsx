import Link from "next/link";

export const metadata = {
  title: "Delete Your Account | DISCOVERLY",
  description: "How to request deletion of your DISCOVERLY account and associated personal data.",
};

const supportEmail = 'ya6331856@gmail.com';

export default function DeleteAccountPage() {
  const subject = encodeURIComponent("DISCOVERLY account deletion request");
  const body = encodeURIComponent("I am requesting deletion of my DISCOVERLY account. My registered email address is: ");
  return <main style={{maxWidth:780,margin:"0 auto",padding:"48px 22px 80px",color:"#201d19",lineHeight:1.65}}>
    <Link href="/" style={{textDecoration:"none",fontWeight:800,color:"#b95a0b"}}>← DISCOVERLY</Link>
    <p style={{marginTop:34,fontSize:12,letterSpacing:2,fontWeight:900,color:"#b95a0b"}}>ACCOUNT CONTROL</p>
    <h1 style={{fontSize:42,lineHeight:1.1,margin:"10px 0 12px"}}>Delete your account</h1>
    <p style={{color:"#6e655d"}}>You can permanently delete your DISCOVERLY account and associated personal account data.</p>
    <h2>Option 1 — Delete inside the app</h2>
    <ol>
      <li>Open DISCOVERLY and sign in.</li>
      <li>Open Profile.</li>
      <li>Select Delete account.</li>
      <li>Type DELETE and confirm.</li>
    </ol>
    <p>The in-app deletion flow removes your authentication account and personal account data. If you are the only member managing a business, that business profile and its dependent content are also removed. If other active members manage the business, its business information may remain with those members.</p>
    <h2>Option 2 — Request deletion if you cannot sign in</h2>
    {supportEmail ? <p>Send an email from the email address registered to your DISCOVERLY account. Include the registered email address and write “Account deletion request” in the subject. We may ask you to verify account ownership before processing the request. <a href={"mailto:"+supportEmail+"?subject="+subject+"&body="+body} style={{color:"#b95a0b",fontWeight:800}}>Email the DISCOVERLY support team →</a></p> : <p>The external support email must be configured before public release. You can currently use the in-app deletion option from Profile → Delete account.</p>}
    <h2>Data that may be retained</h2>
    <p>Some records may be retained where required for legal compliance, security, fraud prevention or dispute resolution. Such records are restricted and retained only as necessary. Business information may remain where another active company member continues to manage the business.</p>
    <p style={{marginTop:36}}><Link href="/privacy" style={{color:"#b95a0b"}}>Read the Privacy Policy →</Link></p>
  </main>;
}
