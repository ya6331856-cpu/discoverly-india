import type { Metadata } from "next";
import "./globals.css";
export const metadata:Metadata={title:"DISCOVERLY — Find the right business",description:"Discover businesses, compare capabilities and connect with the right people across India."};
export default function RootLayout({children}:{children:React.ReactNode}){return <html lang="en"><body>{children}</body></html>}