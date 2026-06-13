import { NextResponse } from 'next/server';
import nodemailer from 'nodemailer';

export async function POST(request: Request) {
  try {
    const { name, email } = await request.json();

    if (!name || !email) {
      return NextResponse.json({ success: false, message: 'Name and email are required.' }, { status: 400 });
    }

    // SMTP Configuration from env
    const smtpHost = process.env.SMTP_HOST || '';
    const smtpPort = Number(process.env.SMTP_PORT || '587');
    const smtpUser = process.env.SMTP_USER || '';
    const smtpPass = process.env.SMTP_PASSWORD || '';

    const isSmtpConfigured = !!(smtpHost && smtpUser && smtpPass);

    if (isSmtpConfigured) {
      const transporter = nodemailer.createTransport({
        host: smtpHost,
        port: smtpPort,
        secure: smtpPort === 465, // true for 465, false for 587
        auth: {
          user: smtpUser,
          pass: smtpPass,
        },
      });

      const mailOptions = {
        from: `"ClassSync Team" <${smtpUser}>`,
        replyTo: smtpUser,
        to: email,
        subject: 'ClassSync - Registered Successfully!',
        text: `Hi ${name},\n\nRegistered Successfully!\n\nComing Soon! Since ClassSync is currently in developer testing, we will automatically deliver the official app download link to your email from hello@dhrruwa.com as soon as we launch on the Play Store.\n\nBest regards,\nThe ClassSync Team\n${smtpUser}`,
        html: `
          <div style="font-family: sans-serif; max-width: 600px; margin: 0 auto; padding: 25px; border: 1px solid #e2e8f0; border-radius: 16px; background-color: #ffffff; color: #334155;">
            <div style="text-align: center; margin-bottom: 25px;">
              <h2 style="color: #0ea5e9; margin: 0; font-size: 24px; font-weight: 800;">ClassSync Timetable</h2>
              <p style="color: #64748b; font-size: 14px; margin: 5px 0 0 0; font-weight: 600;">Early Access Registration</p>
            </div>
            <hr style="border: 0; border-top: 1px solid #e2e8f0; margin-bottom: 25px;" />
            <p style="font-size: 15px; line-height: 1.6;">Hi <strong>${name}</strong>,</p>
            
            <div style="background-color: #f8fafc; padding: 20px; border-radius: 12px; border: 1px solid #e2e8f0; margin: 25px 0;">
              <h4 style="margin: 0 0 10px 0; color: #10b981; font-size: 16px; font-weight: 700;">🚀 Registered Successfully!</h4>
              <p style="margin: 0; font-size: 14px; color: #334155; line-height: 1.6; font-weight: 500;">
                <strong>Coming Soon!</strong> Since ClassSync is currently in developer testing, we will automatically deliver the official app download link to your email from <strong>hello@dhrruwa.com</strong> as soon as we launch on the Play Store.
              </p>
            </div>
            
            <p style="font-size: 14px; color: #64748b; line-height: 1.6;">
              If you have any questions or suggestions, feel free to reply directly to this email or contact <a href="mailto:${smtpUser}" style="color: #0ea5e9; text-decoration: none;">${smtpUser}</a>.
            </p>
            
            <hr style="border: 0; border-top: 1px solid #e2e8f0; margin: 25px 0;" />
            
            <p style="margin: 0; font-size: 14px; color: #64748b; line-height: 1.6;">
              Best regards,<br />
              <strong>The ClassSync Team</strong><br />
              <a href="mailto:${smtpUser}" style="color: #0ea5e9; text-decoration: none; font-weight: 600;">${smtpUser}</a>
            </p>
          </div>
        `,
      };

      await transporter.sendMail(mailOptions);
      console.log(`[SMTP] Success: Early access email sent to ${email} via ${smtpHost}`);
      return NextResponse.json({ success: true, message: 'Early access confirmation email sent!' });
    } else {
      // Simulation mode
      console.log(`[SMTP SIMULATION] Auto-sending early access email to ${email} (Name: ${name}) from ${smtpUser || 'hello@dhrruwa.com'}...`);
      return NextResponse.json({ 
        success: true, 
        simulated: true, 
        message: 'Early access confirmation registered (Simulated SMTP).' 
      });
    }
  } catch (err: any) {
    console.error('SMTP Email dispatch error:', err);
    return NextResponse.json({ success: false, message: err.message || 'Failed to dispatch email.' }, { status: 500 });
  }
}
