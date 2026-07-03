-- Community timetables: a single shared table every install reads from, so
-- discovery / search / "use existing" work across different users and devices.
--
-- Security model: RLS lets anyone READ, but there is NO direct INSERT/UPDATE
-- from clients. All mutations happen through SECURITY DEFINER functions below,
-- which lets us (a) keep an atomic user_count and (b) stop a random user from
-- overwriting another class's published timetable.

create table if not exists public.community_timetables (
  match_key      text primary key,               -- university|branch|semester|section (lowercased)
  university     text not null,
  branch         text not null,
  semester       text not null,
  section        text not null,
  creator_name   text,
  creator_id     text,                            -- stable per-device UUID of the publisher
  verified       boolean not null default false,
  updated_at_ms  bigint  not null default 0,
  user_count     integer not null default 1,
  json           text    not null,               -- full Timetable JSON (Timetable.toJsonString)
  created_at     timestamptz not null default now()
);

create index if not exists idx_ct_university on public.community_timetables (lower(university));
create index if not exists idx_ct_branch     on public.community_timetables (lower(branch));

alter table public.community_timetables enable row level security;

-- Public read (both anon and signed-in roles).
drop policy if exists ct_select on public.community_timetables;
create policy ct_select
  on public.community_timetables
  for select
  to anon, authenticated
  using (true);

-- ── publish (insert new / update own) ───────────────────────────────────────
create or replace function public.publish_timetable(
  p_match_key     text,
  p_university    text,
  p_branch        text,
  p_semester      text,
  p_section       text,
  p_creator_name  text,
  p_creator_id    text,
  p_verified      boolean,
  p_updated_at_ms bigint,
  p_json          text
) returns public.community_timetables
language plpgsql
security definer
set search_path = public
as $$
declare
  r public.community_timetables;
begin
  select * into r from public.community_timetables where match_key = p_match_key;

  if r.match_key is null then
    -- First publisher for this class.
    insert into public.community_timetables (
      match_key, university, branch, semester, section,
      creator_name, creator_id, verified, updated_at_ms, user_count, json)
    values (
      p_match_key, p_university, p_branch, p_semester, p_section,
      p_creator_name, p_creator_id, p_verified, p_updated_at_ms, 1, p_json)
    returning * into r;

  elsif r.creator_id is not distinct from p_creator_id then
    -- Only the original creator may edit; keep the existing user_count.
    update public.community_timetables set
      university    = p_university,
      branch        = p_branch,
      semester      = p_semester,
      section       = p_section,
      creator_name  = p_creator_name,
      verified      = p_verified,
      updated_at_ms = p_updated_at_ms,
      json          = p_json
    where match_key = p_match_key
    returning * into r;
  end if;
  -- Otherwise a different user "published" an existing class: no-op, return the
  -- current row so they simply join what already exists.

  return r;
end;
$$;

grant execute on function public.publish_timetable(
  text, text, text, text, text, text, text, boolean, bigint, text
) to anon, authenticated;

-- ── join (atomically bump the student count) ────────────────────────────────
create or replace function public.join_timetable(p_match_key text)
returns public.community_timetables
language plpgsql
security definer
set search_path = public
as $$
declare
  r public.community_timetables;
begin
  update public.community_timetables
    set user_count = user_count + 1
    where match_key = p_match_key
    returning * into r;
  return r;   -- null row if the class no longer exists
end;
$$;

grant execute on function public.join_timetable(text) to anon, authenticated;

-- ── reports / change suggestions ────────────────────────────────────────────
create table if not exists public.timetable_reports (
  id         bigint generated always as identity primary key,
  match_key  text not null,
  kind       text not null default 'report',   -- 'report' | 'suggestion'
  note       text,
  created_at timestamptz not null default now()
);

alter table public.timetable_reports enable row level security;
-- No client SELECT; only the definer function writes.

create or replace function public.report_timetable(
  p_match_key text, p_kind text, p_note text)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.timetable_reports (match_key, kind, note)
  values (p_match_key, coalesce(p_kind, 'report'), p_note);
end;
$$;

grant execute on function public.report_timetable(text, text, text)
  to anon, authenticated;
