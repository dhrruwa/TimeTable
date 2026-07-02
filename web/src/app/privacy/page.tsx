import type { Metadata } from 'next';
import Link from 'next/link';

export const metadata: Metadata = {
  title: 'Privacy Policy — Timetable ClassSync',
  description:
    'How the Timetable ClassSync app collects, uses, and protects your data.',
};

const UPDATED = '2 July 2026';
const CONTACT = 'support@dhrruwa.com';

function Section({ title, children }: { title: string; children: React.ReactNode }) {
  return (
    <section className="mt-8">
      <h2 className="text-xl font-bold text-slate-900">{title}</h2>
      <div className="mt-2 space-y-3 text-slate-700 leading-relaxed">{children}</div>
    </section>
  );
}

export default function PrivacyPolicyPage() {
  return (
    <main className="min-h-screen bg-white">
      <div className="mx-auto max-w-3xl px-6 py-16">
        <Link href="/" className="text-sm font-semibold text-sky-600 hover:text-sky-700">
          ← Back to home
        </Link>

        <h1 className="mt-6 text-3xl font-extrabold text-slate-900">Privacy Policy</h1>
        <p className="mt-2 text-sm text-slate-500">Last updated: {UPDATED}</p>

        <p className="mt-6 text-slate-700 leading-relaxed">
          Timetable ClassSync (&ldquo;the app&rdquo;, &ldquo;we&rdquo;, &ldquo;us&rdquo;) is a
          student timetable and attendance app. We designed it to be privacy-friendly: there is no
          account or login, no advertising, and no third-party tracking SDKs. Most of your data
          stays on your device. This policy explains the limited data we do handle and why.
        </p>

        <Section title="Data we store on your device">
          <p>
            Your timetable, subjects, attendance records, chosen theme, and app settings are stored
            locally on your device. This data is not transmitted to us and is removed when you
            uninstall the app.
          </p>
        </Section>

        <Section title="Anonymous device identifier">
          <p>
            On first launch the app generates a random identifier stored on your device. It is not
            linked to your name, email, phone number, or any Google/Apple account. It is used only
            to mark which shared community timetable you created, so that only you can edit it.
          </p>
        </Section>

        <Section title="Timetable image import (Google Gemini)">
          <p>
            If you choose to import a timetable from a photo or screenshot, that image is sent to
            Google&rsquo;s Gemini API (via our secure backend) purely to extract the class schedule
            text. We do not store the image on our servers after processing. Google processes the
            image under its own terms; see Google&rsquo;s privacy policy at{' '}
            <a
              className="text-sky-600 hover:text-sky-700"
              href="https://policies.google.com/privacy"
            >
              policies.google.com/privacy
            </a>
            . This only happens when you explicitly use the image-import feature.
          </p>
        </Section>

        <Section title="Community timetables (optional)">
          <p>
            If you choose to publish your timetable to the community directory, the timetable
            content and the labels you enter (university, branch, semester, section) are stored on
            our backend (Supabase) so other students can find and join it. Do not include personal
            information in these fields. You can ask us to remove a published timetable at any time
            using the contact details below.
          </p>
        </Section>

        <Section title="Camera">
          <p>
            The app requests camera access only if you use the in-app scanner to capture a
            timetable. Camera frames are processed for that purpose and are not uploaded or stored
            by us beyond the image-import flow described above.
          </p>
        </Section>

        <Section title="Website & support">
          <p>
            If you contact support or request the download link through our website, we process the
            name and email you provide solely to respond to you. We keep an aggregate, anonymous
            count of app downloads for basic analytics. We do not sell your data.
          </p>
        </Section>

        <Section title="Data sharing">
          <p>
            We do not sell or rent personal data. We share data only with the service providers
            needed to run the app: Google (Gemini, for image import you initiate) and Supabase (our
            backend and database). Each processes data on our behalf under their own terms.
          </p>
        </Section>

        <Section title="Data retention & your rights">
          <p>
            On-device data lives until you delete it or uninstall the app. Community timetables and
            support messages are retained until you ask us to delete them. You may request access
            to, or deletion of, any data we hold about you by emailing us.
          </p>
        </Section>

        <Section title="Children's privacy">
          <p>
            The app is intended for students and general audiences and is not directed at children
            under 13. We do not knowingly collect personal information from children under 13.
          </p>
        </Section>

        <Section title="Changes to this policy">
          <p>
            We may update this policy from time to time. Material changes will be reflected here
            with a new &ldquo;Last updated&rdquo; date.
          </p>
        </Section>

        <Section title="Contact">
          <p>
            Questions or requests? Email{' '}
            <a className="text-sky-600 hover:text-sky-700" href={`mailto:${CONTACT}`}>
              {CONTACT}
            </a>
            .
          </p>
        </Section>
      </div>
    </main>
  );
}
