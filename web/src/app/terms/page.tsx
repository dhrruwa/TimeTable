import type { Metadata } from 'next';
import Link from 'next/link';

export const metadata: Metadata = {
  title: 'Terms of Use — Timetable ClassSync',
  description:
    'Terms of Use and End User License Agreement for the Timetable ClassSync app, including the community content policy.',
};

const UPDATED = '4 July 2026';
const CONTACT = 'support@dhrruwa.com';

function Section({ title, children }: { title: string; children: React.ReactNode }) {
  return (
    <section className="mt-8">
      <h2 className="text-xl font-bold text-slate-900">{title}</h2>
      <div className="mt-2 space-y-3 text-slate-700 leading-relaxed">{children}</div>
    </section>
  );
}

export default function TermsPage() {
  return (
    <main className="min-h-screen bg-white">
      <div className="mx-auto max-w-3xl px-6 py-16">
        <Link href="/" className="text-sm font-semibold text-sky-600 hover:text-sky-700">
          ← Back to home
        </Link>

        <h1 className="mt-6 text-3xl font-extrabold text-slate-900">Terms of Use</h1>
        <p className="mt-2 text-sm text-slate-500">Last updated: {UPDATED}</p>

        <p className="mt-6 text-slate-700 leading-relaxed">
          These Terms of Use (the &ldquo;Terms&rdquo;) and End User License Agreement govern your use
          of the Timetable ClassSync mobile app (&ldquo;the app&rdquo;, &ldquo;we&rdquo;,
          &ldquo;us&rdquo;). By downloading, installing, or using the app you agree to these Terms.
          If you do not agree, do not use the app.
        </p>

        <Section title="License">
          <p>
            We grant you a personal, non-exclusive, non-transferable, revocable license to use the
            app for your own personal, non-commercial timetable and attendance needs, subject to
            these Terms and the applicable app store terms.
          </p>
        </Section>

        <Section title="Community timetables (user-generated content)">
          <p>
            The app lets students publish and share class timetables with others (&ldquo;community
            content&rdquo;). You are solely responsible for any content you publish, and you confirm
            you have the right to share it.
          </p>
          <p className="font-semibold text-slate-900">
            There is zero tolerance for objectionable, abusive, unlawful, hateful, harassing, or
            otherwise inappropriate content or behaviour.
          </p>
          <p>By publishing or using community content you agree that you will not:</p>
          <ul className="list-disc pl-6 space-y-1">
            <li>post content that is offensive, obscene, defamatory, misleading, or unlawful;</li>
            <li>impersonate any person or institution, or misrepresent a class;</li>
            <li>harass, threaten, or abuse other users;</li>
            <li>upload spam, malware, or content that infringes others&rsquo; rights.</li>
          </ul>
        </Section>

        <Section title="Moderation, reporting & blocking">
          <p>
            You can <strong>report</strong> any community timetable that is incorrect or
            objectionable, and you can <strong>block/hide</strong> content so it no longer appears
            for you — both directly inside the app.
          </p>
          <p>
            We review reported content and will remove content and, where necessary, remove or ban
            contributors who violate these Terms, typically within 24 hours of a report. We may
            remove any content or restrict any user at our discretion.
          </p>
        </Section>

        <Section title="No warranty">
          <p>
            Community timetables are provided by other users on an &ldquo;as is&rdquo; basis. We do
            not guarantee their accuracy or completeness. Always verify class details with your
            institution. The app is provided without warranties of any kind to the extent permitted
            by law.
          </p>
        </Section>

        <Section title="Limitation of liability">
          <p>
            To the maximum extent permitted by law, we are not liable for any indirect, incidental,
            or consequential damages arising from your use of the app or reliance on community
            content.
          </p>
        </Section>

        <Section title="Changes & termination">
          <p>
            We may update these Terms from time to time; continued use of the app after changes
            means you accept them. We may suspend or terminate access for anyone who violates these
            Terms.
          </p>
        </Section>

        <Section title="Contact">
          <p>
            Questions or content reports can also be sent to{' '}
            <a className="text-sky-600 hover:text-sky-700" href={`mailto:${CONTACT}`}>
              {CONTACT}
            </a>
            .
          </p>
        </Section>

        <p className="mt-10 text-sm text-slate-500">
          See also our{' '}
          <Link href="/privacy" className="text-sky-600 hover:text-sky-700">
            Privacy Policy
          </Link>
          .
        </p>
      </div>
    </main>
  );
}
