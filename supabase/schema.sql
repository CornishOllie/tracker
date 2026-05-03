-- Tracker app — solo cross-device sync. Reuses the Georgia Supabase project.
-- Run once in the Supabase SQL Editor. Idempotent.

create table if not exists tracker_state (
  sync_code text primary key,
  habits jsonb,
  entries jsonb,
  todos jsonb,
  updated_at timestamptz not null default now()
);

alter table tracker_state enable row level security;

drop policy if exists tracker_state_anon_read on tracker_state;
drop policy if exists tracker_state_anon_insert on tracker_state;
drop policy if exists tracker_state_anon_update on tracker_state;
drop policy if exists tracker_state_anon_delete on tracker_state;

create policy tracker_state_anon_read   on tracker_state for select to anon using (length(sync_code) >= 4);
create policy tracker_state_anon_insert on tracker_state for insert to anon with check (length(sync_code) >= 4);
create policy tracker_state_anon_update on tracker_state for update to anon using (length(sync_code) >= 4) with check (length(sync_code) >= 4);
create policy tracker_state_anon_delete on tracker_state for delete to anon using (length(sync_code) >= 4);

do $rt$
begin
  begin alter publication supabase_realtime add table tracker_state; exception when duplicate_object then null; end;
end
$rt$;
