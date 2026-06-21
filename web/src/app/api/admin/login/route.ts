import { NextResponse } from 'next/server';
import {
  ADMIN_COOKIE,
  createSessionToken,
  getAdminPassword,
  passwordMatches,
} from '@/lib/admin-auth';

export async function POST(request: Request) {
  try {
    // Fail closed: if no password is configured on the server, nobody gets in.
    if (!getAdminPassword()) {
      return NextResponse.json(
        {
          success: false,
          message: 'Admin is not configured. Set the ADMIN_PASSWORD environment variable.',
        },
        { status: 503 },
      );
    }

    const { password } = await request.json();

    if (!passwordMatches(password)) {
      return NextResponse.json(
        { success: false, message: 'Invalid admin password' },
        { status: 401 },
      );
    }

    const { value, maxAge } = createSessionToken();
    const response = NextResponse.json({ success: true, message: 'Logged in successfully' });
    response.cookies.set(ADMIN_COOKIE, value, {
      httpOnly: true,
      secure: process.env.NODE_ENV === 'production',
      sameSite: 'strict',
      maxAge,
      path: '/',
    });
    return response;
  } catch {
    return NextResponse.json({ success: false, message: 'Server error' }, { status: 500 });
  }
}
