-- Harden the public community RPCs against spam / oversized payloads.
-- Adds input-length bounds and a per-device cap on how many distinct classes
-- one creator can publish, so the anon-callable functions can't be used to
-- flood public.community_timetables.

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
  v_count integer;
begin
  -- Reject absurd / abusive payloads outright.
  if p_match_key is null or length(p_match_key) > 300
     or length(coalesce(p_university, '')) > 120
     or length(coalesce(p_branch, '')) > 120
     or length(coalesce(p_semester, '')) > 20
     or length(coalesce(p_section, '')) > 20
     or length(coalesce(p_creator_name, '')) > 60
     or length(coalesce(p_json, '')) > 200000 then
    raise exception 'invalid payload';
  end if;

  -- Anti-spam: cap the number of distinct classes a single device may create.
  -- Editing your own existing rows is always allowed.
  if p_creator_id is not null then
    select count(*) into v_count
      from public.community_timetables
      where creator_id = p_creator_id;
    if v_count >= 50
       and not exists (select 1 from public.community_timetables
                       where match_key = p_match_key) then
      raise exception 'publish limit reached';
    end if;
  end if;

  select * into r from public.community_timetables where match_key = p_match_key;

  if r.match_key is null then
    insert into public.community_timetables (
      match_key, university, branch, semester, section,
      creator_name, creator_id, verified, updated_at_ms, user_count, json)
    values (
      p_match_key, p_university, p_branch, p_semester, p_section,
      p_creator_name, p_creator_id, p_verified, p_updated_at_ms, 1, p_json)
    returning * into r;
  elsif r.creator_id is not distinct from p_creator_id then
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

  return r;
end;
$$;

-- Bound report/suggestion notes too.
create or replace function public.report_timetable(
  p_match_key text, p_kind text, p_note text)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if p_match_key is null or length(p_match_key) > 300
     or length(coalesce(p_note, '')) > 1000 then
    raise exception 'invalid report';
  end if;
  insert into public.timetable_reports (match_key, kind, note)
  values (p_match_key, coalesce(p_kind, 'report'), left(coalesce(p_note, ''), 1000));
end;
$$;
