-- Запустите в SQL Editor проекта Supabase, созданного именно для listo.
create table if not exists public.listings (
 id uuid primary key default gen_random_uuid(),
 seller_id uuid not null references auth.users(id) on delete cascade,
 game text not null check (game in ('minecraft','telegram','roblox')),
 category text not null check (length(category) between 1 and 40),
 title text not null check (length(trim(title)) between 1 and 120),
 description text not null default '' check (length(description)<=2000),
 price_rub integer not null check (price_rub between 1 and 10000000),
 created_at timestamptz not null default now()
);
create index if not exists listings_game_category_idx on public.listings(game,category,created_at desc);
alter table public.listings enable row level security;
create policy "public can view listings" on public.listings for select to anon,authenticated using (true);
create policy "seller can create own listings" on public.listings for insert to authenticated with check ((select auth.uid())=seller_id);
create policy "seller can update own listings" on public.listings for update to authenticated using ((select auth.uid())=seller_id) with check ((select auth.uid())=seller_id);
create policy "seller can delete own listings" on public.listings for delete to authenticated using ((select auth.uid())=seller_id);
grant select on public.listings to anon;
grant select,insert,update,delete on public.listings to authenticated;
