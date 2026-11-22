import Link from "next/link";

export const metadata = {
  title: "Terms of Use | DISCOVERLY",
  description: "DISCOVERLY terms of use and community standards.",
};

export default function TermsPage() {
  return <main style={{maxWidth:860,margin:"0 auto",padding:"48px 22px 80px",color:"#201d19",lineHeight:1.65}}>
    <Link href="/" style={{textDecoration:"none",fontWeight:800,color:"#b95a0b"}}>← DISCOVERLY</Link>
    <p style={{marginTop:34,fontSize:12,letterSpacing:2,fontWeight:900,color:"#b95a0b"}}>PLATFORM RULES</p>
    <h1 style={{fontSize:42,lineHeight:1.1,margin:"10px 0 12px"}}>Terms of Use</h1>
    <p style={{color:"#6e655d"}}>Last updated: 22 November 2026</p>
    <p>These Terms govern your access to DISCOVERLY, a business discovery and opportunity marketplace. By creating an account or using posting features, you agree to follow these Terms and the community rules below.</p>
    <h2>1. Accurate information</h2>
    <p>You are responsible for the accuracy, legality and ownership of the business details, service descriptions, contact information, requirements, quotations and other content you submit. Do not impersonate another person or business.</p>
    <h2>2. Prohibited content and behaviour</h2>
    <ul>
      <li>Fake businesses, fraudulent offers, scams, deceptive claims or misleading contact details.</li>
      <li>Illegal goods or services, prohibited transactions or content that violates applicable law.</li>
      <li>Spam, duplicate listings, unsolicited bulk messages or attempts to manipulate search or reviews.</li>
      <li>Threats, harassment, hate speech, discriminatory abuse or sharing another person&apos;s private information without permission.</li>
      <li>Copyright, trademark or other intellectual-property infringement.</li>
    </ul>
    <h2>3. Reporting, blocking and moderation</h2>
    <p>You can report a business listing from its profile and block its owner. Reports are reviewed by platform moderators. We may restrict, suspend or remove content or accounts when we reasonably believe these Terms or applicable policies have been breached. Reporting does not guarantee a particular outcome.</p>
    <h2>4. Business discovery is not a guarantee</h2>
    <p>DISCOVERLY helps people discover businesses and exchange requirements and quotations. We do not guarantee a business, service, quotation, transaction, payment, licence, credential or claim made by another user. Conduct your own checks before entering into agreements or making payments.</p>
    <h2>5. Your account</h2>
    <p>Keep your sign-in credentials secure. You are responsible for activity performed through your account. Do not share one-time verification codes. You may request account deletion from the app profile controls.</p>
    <h2>6. Suspension and changes</h2>
    <p>We may update the service or these Terms to improve safety, comply with law or reflect product changes. Continued use after updated Terms are presented means you accept the revised Terms.</p>
    <h2>7. Contact</h2>
    <p>For questions about these Terms, use the support contact published on the DISCOVERLY Google Play listing.</p>
    <p style={{marginTop:36}}><Link href="/privacy" style={{color:"#b95a0b"}}>Read the Privacy Policy →</Link></p>
  </main>;
}
