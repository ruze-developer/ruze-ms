-- Run in Supabase SQL Editor. Requires Supabase Auth and Realtime.
create extension if not exists pgcrypto;
create table if not exists public.spaces (id uuid primary key default gen_random_uuid(),name text not null check(length(name) between 1 and 64),owner_id uuid not null references auth.users(id),created_at timestamptz not null default now());
create table if not exists public.rooms (id uuid primary key default gen_random_uuid(),name text not null check(length(name) between 1 and 64),space_id uuid references public.spaces(id) on delete cascade,kind text not null check(kind in ('channel','dm')),created_by uuid not null references auth.users(id),created_at timestamptz not null default now(),check((kind='channel' and space_id is not null) or (kind='dm' and space_id is null)));
create table if not exists public.room_members (room_id uuid not null references public.rooms(id) on delete cascade,user_id uuid not null references auth.users(id),primary key(room_id,user_id));
create table if not exists public.messages (id uuid primary key default gen_random_uuid(),room_id uuid not null references public.rooms(id) on delete cascade,user_id uuid not null references auth.users(id),body text not null check(length(body) between 1 and 4000),created_at timestamptz not null default now());
create index if not exists messages_room_time on public.messages(room_id,created_at);
create index if not exists rooms_space on public.rooms(space_id);
alter table public.spaces enable row level security;
alter table public.rooms enable row level security;
alter table public.room_members enable row level security;
alter table public.messages enable row level security;
-- Beta: all authenticated users can see public spaces and their channels.
create policy "spaces read" on public.spaces for select to authenticated using(true);
create policy "spaces create" on public.spaces for insert to authenticated with check(owner_id=auth.uid());
create policy "rooms read" on public.rooms for select to authenticated using(space_id is not null or exists(select 1 from public.room_members m where m.room_id=rooms.id and m.user_id=auth.uid()));
create policy "rooms channel create" on public.rooms for insert to authenticated with check(created_by=auth.uid() and kind='channel' and exists(select 1 from public.spaces s where s.id=space_id and s.owner_id=auth.uid()));
create policy "members read" on public.room_members for select to authenticated using(user_id=auth.uid());
create policy "messages read" on public.messages for select to authenticated using(exists(select 1 from public.rooms r where r.id=messages.room_id and (r.space_id is not null or exists(select 1 from public.room_members m where m.room_id=r.id and m.user_id=auth.uid()))));
create policy "messages send" on public.messages for insert to authenticated with check(user_id=auth.uid() and exists(select 1 from public.rooms r where r.id=messages.room_id and (r.space_id is not null or exists(select 1 from public.room_members m where m.room_id=r.id and m.user_id=auth.uid()))));
-- SECURITY DEFINER avoids exposing other users' emails through public tables.
create or replace function public.create_dm_by_email(target_email text) returns public.rooms language plpgsql security definer set search_path='' as $$
declare target_id uuid; r public.rooms;
begin
 if auth.uid() is null then raise exception 'Not authenticated'; end if;
 select id into target_id from auth.users where lower(email)=lower(trim(target_email)) limit 1;
 if target_id is null then raise exception 'User not found'; end if;
 if target_id=auth.uid() then raise exception 'Cannot message yourself'; end if;
 select x.* into r from public.rooms x
 join public.room_members a on a.room_id=x.id and a.user_id=auth.uid()
 join public.room_members b on b.room_id=x.id and b.user_id=target_id
 where x.kind='dm' and (select count(*) from public.room_members m where m.room_id=x.id)=2 limit 1;
 if r.id is null then
  insert into public.rooms(name,kind,created_by) values ('личная беседа','dm',auth.uid()) returning * into r;
  insert into public.room_members(room_id,user_id) values(r.id,auth.uid()),(r.id,target_id);
 end if;
 return r;
end $$;
revoke all on function public.create_dm_by_email(text) from public;
grant execute on function public.create_dm_by_email(text) to authenticated;
do $$ begin alter publication supabase_realtime add table public.messages; exception when duplicate_object then null; end $$;
