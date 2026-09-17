grant select, insert, update, delete on public.goals to authenticated;
grant select, insert, update, delete on public.time_entries to authenticated;
grant select, insert, update, delete on public.comments to authenticated;

alter table public.goals enable row level security;
alter table public.time_entries enable row level security;
alter table public.comments enable row level security;

drop policy if exists "Users manage their own goals" on public.goals;
drop policy if exists "Users manage their own time" on public.time_entries;
drop policy if exists "Users manage their own comments" on public.comments;

drop policy if exists "Users can read own goals" on public.goals;
drop policy if exists "Users can create own goals" on public.goals;
drop policy if exists "Users can update own goals" on public.goals;
drop policy if exists "Users can delete own goals" on public.goals;
drop policy if exists "Users can read own time" on public.time_entries;
drop policy if exists "Users can create own time" on public.time_entries;
drop policy if exists "Users can update own time" on public.time_entries;
drop policy if exists "Users can delete own time" on public.time_entries;
drop policy if exists "Users can read own comments" on public.comments;
drop policy if exists "Users can create own comments" on public.comments;
drop policy if exists "Users can update own comments" on public.comments;
drop policy if exists "Users can delete own comments" on public.comments;

create policy "Users can read own goals"
  on public.goals for select
  to authenticated
  using ((select auth.uid()) = user_id);

create policy "Users can create own goals"
  on public.goals for insert
  to authenticated
  with check ((select auth.uid()) = user_id);

create policy "Users can update own goals"
  on public.goals for update
  to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

create policy "Users can delete own goals"
  on public.goals for delete
  to authenticated
  using ((select auth.uid()) = user_id);

create policy "Users can read own time"
  on public.time_entries for select
  to authenticated
  using ((select auth.uid()) = user_id);

create policy "Users can create own time"
  on public.time_entries for insert
  to authenticated
  with check ((select auth.uid()) = user_id);

create policy "Users can update own time"
  on public.time_entries for update
  to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

create policy "Users can delete own time"
  on public.time_entries for delete
  to authenticated
  using ((select auth.uid()) = user_id);

create policy "Users can read own comments"
  on public.comments for select
  to authenticated
  using ((select auth.uid()) = user_id);

create policy "Users can create own comments"
  on public.comments for insert
  to authenticated
  with check ((select auth.uid()) = user_id);

create policy "Users can update own comments"
  on public.comments for update
  to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

create policy "Users can delete own comments"
  on public.comments for delete
  to authenticated
  using ((select auth.uid()) = user_id);
