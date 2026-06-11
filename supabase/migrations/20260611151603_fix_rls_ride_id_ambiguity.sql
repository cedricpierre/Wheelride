-- Fix ambiguous ride_id references in RLS subqueries.
-- Unqualified ride_id was resolved against the inner alias, allowing
-- cross-ride reads for any user participating in at least one ride.

drop policy if exists "Ride members can read locations" on public.ride_locations;

create policy "Ride members can read locations"
  on public.ride_locations for select
  to authenticated
  using (
    exists (
      select 1
      from public.ride_participants viewer
      where viewer.ride_id = ride_locations.ride_id
        and viewer.user_id = (select auth.uid())
    )
  );

drop policy if exists "Ride members can read new messages" on public.ride_messages;

create policy "Ride members can read new messages"
  on public.ride_messages for select
  to authenticated
  using (
    exists (
      select 1
      from public.ride_participants viewer
      where viewer.ride_id = ride_messages.ride_id
        and viewer.user_id = (select auth.uid())
    )
  );

drop policy if exists "Ride members can read participants" on public.ride_participants;

create policy "Ride members can read participants"
  on public.ride_participants for select
  to authenticated
  using (
    user_id = (select auth.uid())
    or exists (
      select 1
      from public.ride_participants viewer
      where viewer.ride_id = ride_participants.ride_id
        and viewer.user_id = (select auth.uid())
    )
  );
