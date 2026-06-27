-- Autito Seco — esquema cloud (correr una sola vez en Supabase SQL Editor)

create table public.vehicles (
  id           bigint generated always as identity primary key,
  user_id      uuid not null references auth.users(id) on delete cascade,
  brand        text not null,
  model        text not null,
  year         int,
  plate        text not null,
  km           numeric not null default 0,
  color        text,
  added_date   timestamptz not null default now(),
  is_favorite  boolean not null default false,
  maints       jsonb not null default '[]'::jsonb
);

create table public.history (
  id          bigint generated always as identity primary key,
  user_id     uuid not null references auth.users(id) on delete cascade,
  vehicle_id  bigint not null references public.vehicles(id) on delete cascade,
  mid         int not null,
  km          numeric,
  date        timestamptz,
  product     text
);

create table public.workshop_entries (
  id           bigint generated always as identity primary key,
  user_id      uuid not null references auth.users(id) on delete cascade,
  vehicle_id   bigint references public.vehicles(id) on delete cascade,
  date         date,
  place        text,
  person       text,
  phone        text,
  description  text,
  result       text,
  cost         text,
  created_at   timestamptz not null default now()
);

create table public.documents (
  id         bigint generated always as identity primary key,
  user_id    uuid not null references auth.users(id) on delete cascade,
  name       text not null,
  type       text not null,
  date       date,
  added_at   timestamptz not null default now()
);

-- Row Level Security: cada usuario solo puede ver/tocar sus propias filas
alter table public.vehicles enable row level security;
alter table public.history enable row level security;
alter table public.workshop_entries enable row level security;
alter table public.documents enable row level security;

create policy "vehicles_own" on public.vehicles for all
  using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "history_own" on public.history for all
  using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "workshop_own" on public.workshop_entries for all
  using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "documents_own" on public.documents for all
  using (auth.uid() = user_id) with check (auth.uid() = user_id);
