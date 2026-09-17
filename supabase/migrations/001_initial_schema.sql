create extension if not exists "pgcrypto";

create table if not exists public.goals (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null check (char_length(trim(title)) between 1 and 120),
  description text not null default '',
  status text not null default 'active' check (status in ('active', 'completed', 'archived')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.time_entries (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  goal_id uuid not null references public.goals(id) on delete cascade,
  started_at timestamptz not null default now(),
  ended_at timestamptz,
  duration_seconds integer check (duration_seconds is null or duration_seconds >= 0)
);

create unique index if not exists one_open_time_entry_per_user
  on public.time_entries (user_id) where ended_at is null;

create table if not exists public.comments (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  goal_id uuid not null references public.goals(id) on delete cascade,
  body text not null check (char_length(trim(body)) between 1 and 2000),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists goals_user_id_idx on public.goals(user_id, created_at desc);
create index if not exists time_entries_goal_id_idx on public.time_entries(goal_id, started_at desc);
create index if not exists comments_goal_id_idx on public.comments(goal_id, created_at desc);

alter table public.goals enable row level security;
alter table public.time_entries enable row level security;
alter table public.comments enable row level security;

create policy "Users manage their own goals" on public.goals for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "Users manage their own time" on public.time_entries for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "Users manage their own comments" on public.comments for all using (auth.uid() = user_id) with check (auth.uid() = user_id);