-- Supabase SQL Editor 里运行本文件。
-- 先把下面两个邮箱改成你们实际登录用的邮箱。

create table if not exists public.allowed_users (
  email text primary key
);

insert into public.allowed_users (email)
values
  ('1159630611@qq.com'),
  ('litao_marx@163.com')
on conflict (email) do nothing;

create schema if not exists private;
revoke all on schema private from public;
grant usage on schema private to authenticated;

create or replace function private.is_allowed_user()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.allowed_users
    where lower(email) = lower(coalesce(auth.jwt() ->> 'email', ''))
  );
$$;

grant execute on function private.is_allowed_user() to authenticated;

create table if not exists public.weekend_plans (
  week_start date primary key,
  tasks jsonb not null default '[]'::jsonb,
  updated_at timestamptz not null default now()
);

create table if not exists public.weight_records (
  date date primary key,
  zhaojun numeric(5, 1),
  litao numeric(5, 1),
  note text not null default '',
  updated_at timestamptz not null default now()
);

create table if not exists public.memories (
  id text primary key,
  title text not null,
  text text not null,
  date date,
  updated_at timestamptz not null default now()
);

create table if not exists public.app_settings (
  key text primary key,
  value jsonb not null,
  updated_at timestamptz not null default now()
);

create table if not exists public.album_photos (
  id text primary key,
  file_name text not null,
  file_type text not null,
  file_path text not null unique,
  iv text not null,
  created_at timestamptz not null default now()
);

insert into storage.buckets (id, name, public)
values ('couple-album', 'couple-album', false)
on conflict (id) do nothing;

alter table public.allowed_users enable row level security;
alter table public.weekend_plans enable row level security;
alter table public.weight_records enable row level security;
alter table public.memories enable row level security;
alter table public.app_settings enable row level security;
alter table public.album_photos enable row level security;

drop policy if exists "allowed users can read allowed list" on public.allowed_users;
create policy "allowed users can read allowed list"
on public.allowed_users
for select
to authenticated
using (private.is_allowed_user());

drop policy if exists "allowed users manage weekend plans" on public.weekend_plans;
create policy "allowed users manage weekend plans"
on public.weekend_plans
for all
to authenticated
using (private.is_allowed_user())
with check (private.is_allowed_user());

drop policy if exists "allowed users manage weight records" on public.weight_records;
create policy "allowed users manage weight records"
on public.weight_records
for all
to authenticated
using (private.is_allowed_user())
with check (private.is_allowed_user());

drop policy if exists "allowed users manage memories" on public.memories;
create policy "allowed users manage memories"
on public.memories
for all
to authenticated
using (private.is_allowed_user())
with check (private.is_allowed_user());

drop policy if exists "allowed users manage app settings" on public.app_settings;
create policy "allowed users manage app settings"
on public.app_settings
for all
to authenticated
using (private.is_allowed_user())
with check (private.is_allowed_user());

drop policy if exists "allowed users manage album metadata" on public.album_photos;
create policy "allowed users manage album metadata"
on public.album_photos
for all
to authenticated
using (private.is_allowed_user())
with check (private.is_allowed_user());

drop policy if exists "allowed users read album files" on storage.objects;
create policy "allowed users read album files"
on storage.objects
for select
to authenticated
using (bucket_id = 'couple-album' and private.is_allowed_user());

drop policy if exists "allowed users upload album files" on storage.objects;
create policy "allowed users upload album files"
on storage.objects
for insert
to authenticated
with check (bucket_id = 'couple-album' and private.is_allowed_user());

drop policy if exists "allowed users update album files" on storage.objects;
create policy "allowed users update album files"
on storage.objects
for update
to authenticated
using (bucket_id = 'couple-album' and private.is_allowed_user())
with check (bucket_id = 'couple-album' and private.is_allowed_user());

drop policy if exists "allowed users delete album files" on storage.objects;
create policy "allowed users delete album files"
on storage.objects
for delete
to authenticated
using (bucket_id = 'couple-album' and private.is_allowed_user());
