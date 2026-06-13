import { NextResponse } from 'next/server';

export async function POST(request: Request) {
  try {
    const { password } = await request.json();
    const adminPassword = process.env.ADMIN_PASSWORD || 'BOLDfit@14';

    if (password === adminPassword) {
      const response = NextResponse.json({ success: true, message: 'Logged in successfully' });
      
      // Set a secure, HTTP-only session cookie valid for 2 hours
      response.cookies.set('classsync_admin_session', 'authenticated', {
        httpOnly: true,
        secure: process.env.NODE_ENV === 'production',
        sameSite: 'strict',
        maxAge: 60 * 60 * 2, // 2 hours
        path: '/',
      });

      return response;
    }

    return NextResponse.json({ success: false, message: 'Invalid admin password' }, { status: 401 });
  } catch (err) {
    return NextResponse.json({ success: false, message: 'Server error' }, { status: 500 });
  }
}
