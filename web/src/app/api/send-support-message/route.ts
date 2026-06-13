import { NextResponse } from 'next/server';
import nodemailer from 'nodemailer';

export async function POST(request: Request) {
  try {
    const { name, email, message } = await request.json();

    if (!name || !email || !message) {
      return NextResponse.json({ success: false, message: 'Name, email, and message are required.' }, { status: 400 });
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
        replyTo: email, // If admin replies to the BCC copy, it goes to the user
        to: email,      // Sends to the user who filled the form
        bcc: [smtpUser, 'support@dhrruwa.com'], // BCC admin and support email
        subject: `ClassSync Support - Message Received from ${name}`,
        text: `Hi ${name},\n\nThank you for contacting ClassSync support. We have received your message and our team will get back to you shortly.\n\nHere is a summary of your message:\n\nName: ${name}\nEmail: ${email}\nMessage:\n${message}\n\nBest regards,\nThe ClassSync Team\n${smtpUser}`,
        html: `
          <div style="font-family: sans-serif; max-width: 600px; margin: 0 auto; padding: 25px; border: 1px solid #e2e8f0; border-radius: 16px; background-color: #ffffff; color: #334155;">
            <div style="text-align: center; margin-bottom: 25px;">
              <h2 style="color: #0ea5e9; margin: 0; font-size: 24px; font-weight: 800;">ClassSync Support</h2>
              <p style="color: #64748b; font-size: 14px; margin: 5px 0 0 0; font-weight: 600;">We've received your query</p>
            </div>
            <hr style="border: 0; border-top: 1px solid #e2e8f0; margin-bottom: 25px;" />
            <p style="font-size: 15px; line-height: 1.6;">Hi <strong>${name}</strong>,</p>
            <p style="font-size: 15px; line-height: 1.6;">Thank you for reaching out to <strong>ClassSync support</strong>. We have successfully logged your query and our team will reply to this email thread shortly.</p>
            
            <div style="background-color: #f8fafc; padding: 20px; border-radius: 12px; border: 1px solid #e2e8f0; margin: 25px 0;">
              <h4 style="margin: 0 0 10px 0; color: #0f172a; font-size: 14px; font-weight: 700; border-b: 1px solid #e2e8f0; padding-bottom: 5px;">📝 Message Summary</h4>
              <p style="margin: 5px 0; font-size: 13px; color: #475569;"><strong>Name:</strong> ${name}</p>
              <p style="margin: 5px 0; font-size: 13px; color: #475569;"><strong>Email:</strong> ${email}</p>
              <div style="margin: 15px 0 5px 0; padding: 10px; background-color: #ffffff; border-radius: 8px; border: 1px solid #e2e8f0; font-size: 13px; color: #334155; white-space: pre-wrap; font-style: italic;">
                "${message}"
              </div>
            </div>
            
            <p style="font-size: 14px; color: #64748b; line-height: 1.6;">
              If you have any additional details or want to update your request, you can reply directly to this email or write to <a href="mailto:${smtpUser}" style="color: #0ea5e9; text-decoration: none;">${smtpUser}</a>.
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
      console.log(`[SMTP] Success: Support message confirmation email sent to ${email} (BCC to admin)`);
      return NextResponse.json({ success: true, message: 'Support ticket email confirmation sent!' });
    } else {
      // Simulation mode
      console.log(`[SMTP SIMULATION] Support message received from ${name} (${email}): "${message}"`);
      return NextResponse.json({ 
        success: true, 
        simulated: true, 
        message: 'Support message registered (Simulated SMTP).' 
      });
    }
  } catch (err: any) {
    console.error('SMTP Support message dispatch error:', err);
    return NextResponse.json({ success: false, message: err.message || 'Failed to dispatch support email.' }, { status: 500 });
  }
}
