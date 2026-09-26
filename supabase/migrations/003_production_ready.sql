-- Production hardening for GRS VISION.
-- Run after 001_initial_schema.sql and 002_studio_management.sql.

alter table profiles enable row level security;
alter table services enable row level security;
alter table training_courses enable row level security;
alter table training_sessions enable row level security;
alter table training_registrations enable row level security;
alter table inquiries enable row level security;
alter table downloads enable row level security;
alter table site_settings enable row level security;
alter table social_links enable row level security;
alter table activity_logs enable row level security;

create or replace function public.is_studio_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from profiles
    where id = auth.uid() and role in ('SUPER_ADMIN', 'ADMIN')
  );
$$;

grant execute on function public.is_studio_admin() to authenticated;

create policy "profile owner reads profile" on profiles
  for select to authenticated using (id = auth.uid());
create policy "admins manage profiles" on profiles
  for all to authenticated using (public.is_studio_admin()) with check (public.is_studio_admin());

create policy "public reads published services" on services
  for select to anon, authenticated using (published = true);
create policy "admins manage public services" on services
  for all to authenticated using (public.is_studio_admin()) with check (public.is_studio_admin());

create policy "public reads published courses" on training_courses
  for select to anon, authenticated using (published = true);
create policy "admins manage courses" on training_courses
  for all to authenticated using (public.is_studio_admin()) with check (public.is_studio_admin());
create policy "public reads training sessions" on training_sessions
  for select to anon, authenticated using (true);
create policy "admins manage training sessions" on training_sessions
  for all to authenticated using (public.is_studio_admin()) with check (public.is_studio_admin());
create policy "public registers for training" on training_registrations
  for insert to anon, authenticated with check (true);
create policy "admins read training registrations" on training_registrations
  for select to authenticated using (public.is_studio_admin());

create policy "public creates inquiries" on inquiries
  for insert to anon, authenticated with check (true);
create policy "admins manage inquiries" on inquiries
  for all to authenticated using (public.is_studio_admin()) with check (public.is_studio_admin());

create policy "public records analytics" on analytics_events
  for insert to anon, authenticated with check (event_type in ('PAGE_VIEW','DOWNLOAD','GALLERY_OPEN','SHARE'));
create policy "public records downloads" on downloads
  for insert to anon, authenticated with check (true);
create policy "admins manage downloads" on downloads
  for all to authenticated using (public.is_studio_admin()) with check (public.is_studio_admin());

create policy "public reads site settings" on site_settings
  for select to anon, authenticated using (true);
create policy "admins manage site settings" on site_settings
  for all to authenticated using (public.is_studio_admin()) with check (public.is_studio_admin());
create policy "public reads social links" on social_links
  for select to anon, authenticated using (active = true);
create policy "admins manage social links" on social_links
  for all to authenticated using (public.is_studio_admin()) with check (public.is_studio_admin());
create policy "admins read activity logs" on activity_logs
  for select to authenticated using (public.is_studio_admin());

insert into storage.buckets (id, name, public)
values
  ('branding', 'branding', true),
  ('portfolio-images', 'portfolio-images', true),
  ('public-projects', 'public-projects', true),
  ('private-deliverables', 'private-deliverables', false),
  ('training', 'training', true),
  ('documents', 'documents', false)
on conflict (id) do update set public = excluded.public;

create policy "public reads public studio assets" on storage.objects
  for select to anon, authenticated
  using (bucket_id in ('branding','portfolio-images','public-projects','training'));
create policy "admins upload studio assets" on storage.objects
  for insert to authenticated with check (public.is_studio_admin());
create policy "admins update studio assets" on storage.objects
  for update to authenticated using (public.is_studio_admin()) with check (public.is_studio_admin());
create policy "admins delete studio assets" on storage.objects
  for delete to authenticated using (public.is_studio_admin());

insert into site_settings (key, value)
values ('studio', '{"name":"GRS VISION","city":"Conakry","country":"Guinée"}'::jsonb)
on conflict (key) do nothing;
