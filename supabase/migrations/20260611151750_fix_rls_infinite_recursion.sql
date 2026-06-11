-- Break RLS cycles between rides and ride_participants using
-- security definer helpers that bypass RLS for membership checks.

create or replace function public.is_ride_member(ride_uuid uuid)
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select exists (
    select 1
    from public.ride_participants
    where ride_id = ride_uuid
      and user_id = (select auth.uid())
  );
$$;

create or replace function public.is_active_ride(ride_uuid uuid)
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select exists (
    select 1
    from public.rides
    where id = ride_uuid
      and status = 'active'
  );
$$;

revoke all on function public.is_ride_member(uuid) from public;
grant execute on function public.is_ride_member(uuid) to authenticated;

revoke all on function public.is_active_ride(uuid) from public;
grant execute on function public.is_active_ride(uuid) to authenticated;

drop policy if exists "Authenticated users can read active rides" on public.rides;

create policy "Authenticated users can read active rides"
  on public.rides for select
  to authenticated
  using (
    status = 'active'
    or owner_id = (select auth.uid())
    or public.is_ride_member(id)
  );

drop policy if exists "Users can join active rides" on public.ride_participants;

create policy "Users can join active rides"
  on public.ride_participants for insert
  to authenticated
  with check (
    user_id = (select auth.uid())
    and public.is_active_ride(ride_id)
  );

drop policy if exists "Ride members can read participants" on public.ride_participants;

create policy "Ride members can read participants"
  on public.ride_participants for select
  to authenticated
  using (
    user_id = (select auth.uid())
    or public.is_ride_member(ride_id)
  );

drop policy if exists "Ride members can read locations" on public.ride_locations;

create policy "Ride members can read locations"
  on public.ride_locations for select
  to authenticated
  using (public.is_ride_member(ride_id));

drop policy if exists "Ride members can read new messages" on public.ride_messages;

create policy "Ride members can read new messages"
  on public.ride_messages for select
  to authenticated
  using (public.is_ride_member(ride_id));
