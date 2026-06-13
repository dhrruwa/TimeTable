-- ====================================================================
-- CLASSSYNC (TIMETABLE) LANDING PAGE - SUPABASE DATABASE SCHEMA
-- ====================================================================
-- Copy and paste this script into the SQL Editor of your Supabase project.

-- 1. Create downloads table
CREATE TABLE IF NOT EXISTS downloads (
  id BIGSERIAL PRIMARY KEY,
  timestamp TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Create newsletter_subscribers table
CREATE TABLE IF NOT EXISTS newsletter_subscribers (
  id BIGSERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  timestamp TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Enable Row Level Security (RLS)
ALTER TABLE downloads ENABLE ROW LEVEL SECURITY;
ALTER TABLE newsletter_subscribers ENABLE ROW LEVEL SECURITY;

-- 4. Enable public inserts (for the frontend forms)
CREATE POLICY "Allow public insert to downloads" 
  ON downloads FOR INSERT TO anon WITH CHECK (true);

CREATE POLICY "Allow public insert to newsletter_subscribers" 
  ON newsletter_subscribers FOR INSERT TO anon WITH CHECK (true);

-- 5. Restrict public read queries (to protect user data)
CREATE POLICY "Restrict public select on downloads"
  ON downloads FOR SELECT TO anon USING (false);

CREATE POLICY "Restrict public select on newsletter_subscribers"
  ON newsletter_subscribers FOR SELECT TO anon USING (false);

-- 6. Grant SELECT permission to admin operations. 
-- Note: Next.js API endpoints / Server Actions that query stats/subscribers 
-- should bypass RLS by using the Service Role Key (SUPABASE_SERVICE_ROLE_KEY)
-- on the server side to securely view data without exposing it to the public client.

-- 7. Create support_messages table
CREATE TABLE IF NOT EXISTS support_messages (
  id BIGSERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT NOT NULL,
  message TEXT NOT NULL,
  timestamp TIMESTAMPTZ DEFAULT NOW()
);

-- 8. Enable Row Level Security (RLS) on support_messages
ALTER TABLE support_messages ENABLE ROW LEVEL SECURITY;

-- 9. Enable public inserts (for the contact support form)
CREATE POLICY "Allow public insert to support_messages" 
  ON support_messages FOR INSERT TO anon WITH CHECK (true);

-- 10. Restrict public read queries
CREATE POLICY "Restrict public select on support_messages"
  ON support_messages FOR SELECT TO anon USING (false);
