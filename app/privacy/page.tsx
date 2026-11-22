import Link from "next/link";

export const metadata = {
  title: "Privacy Policy | DISCOVERLY",
  description: "How DISCOVERLY collects, uses and protects account and marketplace information.",
};

const supportEmail = 'ya6331856@gmail.com';

export default function PrivacyPage() {
  return <main style={{maxWidth:860,margin:"0 auto",padding:"48px 22px 80px",color:"#201d19",lineHeight:1.65}}>
    <Link href="/" style={{textDecoration:"none",fontWeight:800,color:"#b95a0b"}}>← DISCOVERLY</Link>
    <p style={{marginTop:34,fontSize:12,letterSpacing:2,fontWeight:900,color:"#b95a0b"}}>YOUR INFORMATION</p>
    <h1 style={{fontSize:42,lineHeight:1.1,margin:"10px 0 12px"}}>Privacy Policy</h1>
    <p style={{color:"#6e655d"}}>Last updated: 22 November 2026</p>
    <p>This policy explains how DISCOVERLY processes information when you use our business discovery and opportunity marketplace.</p>
    <h2>1. Information we collect</h2>
    <ul>
      <li><b>Account information:</b> email address and optional display name.</li>
      <li><b>Business information:</b> business name, description, category, city, state, website and public contact details you choose to submit.</li>
      <li><b>Marketplace content:</b> requirements, enquiries, quotations, reports and other content you submit through the service.</li>
      <li><b>Service activity:</b> search queries and selected business results may be recorded to operate and improve discovery.</li>
    </ul>
    <h2>2. Location and device permissions</h2>
    <p>DISCOVERLY uses city and state information that you enter for business and requirement matching. The current Android app does not request precise GPS location, contacts, call logs, SMS, camera or microphone access.</p>
    <h2>3. How we use information</h2>
    <p>We use information to create and secure accounts, show business results, match requirements with businesses, deliver quotations and leads, moderate content, prevent abuse and provide support.</p>
    <h2>4. Public and private information</h2>
    <p>Business details and other content may be visible to other users when you submit them for publication and they are approved. Requirements and quotations are shared with the relevant matched businesses or buyer. Do not submit information you do not want shared with the intended recipients.</p>
    <h2>5. Service providers</h2>
    <p>DISCOVERLY uses Supabase for hosted authentication and database services. These providers process information to operate the service on our behalf. We do not sell personal information.</p>
    <h2>6. Security and retention</h2>
    <p>Connections to the service use HTTPS/TLS. Database access is restricted through authentication and Row Level Security. We retain information while your account is active and as reasonably necessary for platform operations, safety, dispute resolution and legal obligations.</p>
    <h2>7. Account and data deletion</h2>
    <p>You can delete your account in the Android app from Profile → Delete account. If you cannot access the app, use the <Link href="/delete-account" style={{color:"#b95a0b"}}>Account Deletion page</Link>. When a business has other active members, its business information may remain available to those members; personal account information is removed. Some audit records may be retained in de-identified form.</p>
    <h2>8. Children</h2>
    <p>DISCOVERLY is a general business service and is not designed for children.</p>
    <h2>9. Changes</h2>
    <p>We may update this policy when our features or legal obligations change. The latest version will be published on this page.</p>
    <h2>10. Contact</h2>
    {supportEmail ? <p>For privacy questions, contact <a href={"mailto:"+supportEmail} style={{color:"#b95a0b"}}>{supportEmail}</a>.</p> : <p>Developer support contact must be configured before public release. The support email will be published here before the app is submitted to Google Play.</p>}
    <p style={{marginTop:36}}><Link href="/terms" style={{color:"#b95a0b"}}>Read the Terms of Use →</Link></p>
  </main>;
}
