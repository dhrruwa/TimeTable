import type { Metadata } from 'next';
import { Plus_Jakarta_Sans, Outfit } from 'next/font/google';
import './globals.css';

const plusJakartaSans = Plus_Jakarta_Sans({
  subsets: ['latin'],
  display: 'swap',
  variable: '--font-sans',
});

const outfit = Outfit({
  subsets: ['latin'],
  display: 'swap',
  variable: '--font-outfit',
});

export const metadata: Metadata = {
  title: 'Timetable ClassSync - Smart Student Timetable & Attendance Tracker',
  description: 'The premium student timetable companion. Track current/next periods, daily completion progress, and subject attendance in one dashboard. Download the Android APK directly.',
  keywords: ['timetable', 'class sync', 'college schedule', 'attendance tracker', 'student app', 'android apk', 'class tracking'],
  authors: [{ name: 'ClassSync Team' }],
  openGraph: {
    title: 'Timetable ClassSync - Never Miss a Class Again',
    description: 'The smart timetable companion that tells you exactly which class is running, how much of the day is completed, and keeps your attendance under control.',
    type: 'website',
  },
  twitter: {
    card: 'summary_large_image',
    title: 'Timetable ClassSync',
    description: 'Smart student timetable and attendance tracking app. Sideload the APK today.',
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" className={`${plusJakartaSans.variable} ${outfit.variable} h-full antialiased no-scrollbar scroll-smooth`}>
      <body className="min-h-full flex flex-col selection:bg-sky-500/30 selection:text-white font-sans">
        {children}
      </body>
    </html>
  );
}
