create extension if not exists pgcrypto;

create table if not exists public.users (
  id uuid primary key references auth.users(id) on delete cascade,
  name text not null,
  email text not null,
  avatar_url text,
  created_at timestamptz not null default now()
);

create table if not exists public.rides (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  description text,
  owner_id uuid not null references public.users(id) on delete cascade,
  join_code text not null unique,
  status text not null default 'active' check (status in ('active', 'ended')),
  created_at timestamptz not null default now()
);

create table if not exists public.ride_participants (
  ride_id uuid not null references public.rides(id) on delete cascade,
  user_id uuid not null references public.users(id) on delete cascade,
  joined_at timestamptz not null default now(),
  primary key (ride_id, user_id)
);

create table if not exists public.ride_locations (
  ride_id uuid not null,
  user_id uuid not null,
  latitude double precision not null,
  longitude double precision not null,
  speed double precision,
  heading double precision,
  updated_at timestamptz not null default now(),
  primary key (ride_id, user_id),
  foreign key (ride_id, user_id)
    references public.ride_participants(ride_id, user_id)
    on delete cascade
);

create table if not exists public.ride_messages (
  id uuid primary key default gen_random_uuid(),
  ride_id uuid not null,
  user_id uuid not null,
  message text not null check (length(message) between 1 and 1000),
  created_at timestamptz not null default now(),
  foreign key (ride_id, user_id)
    references public.ride_participants(ride_id, user_id)
    on delete cascade
);

create index if not exists rides_join_code_idx on public.rides(join_code);
create index if not exists ride_participants_user_id_idx
  on public.ride_participants(user_id);
create index if not exists ride_messages_ride_created_idx
  on public.ride_messages(ride_id, created_at desc);
create index if not exists ride_locations_ride_updated_idx
  on public.ride_locations(ride_id, updated_at desc);

alter table public.users enable row level security;
alter table public.rides enable row level security;
alter table public.ride_participants enable row level security;
alter table public.ride_locations enable row level security;
alter table public.ride_messages enable row level security;

create policy "Users can read rider profiles"
  on public.users for select
  to authenticated
  using (true);

create policy "Users can insert own profile"
  on public.users for insert
  to authenticated
  with check ((select auth.uid()) = id);

create policy "Users can update own profile"
  on public.users for update
  to authenticated
  using ((select auth.uid()) = id)
  with check ((select auth.uid()) = id);

create policy "Authenticated users can read active rides"
  on public.rides for select
  to authenticated
  using (
    status = 'active'
    or owner_id = (select auth.uid())
    or exists (
      select 1
      from public.ride_participants rp
      where rp.ride_id = id
        and rp.user_id = (select auth.uid())
    )
  );

create policy "Ride owners can create rides"
  on public.rides for insert
  to authenticated
  with check (owner_id = (select auth.uid()));

create policy "Ride owners can update rides"
  on public.rides for update
  to authenticated
  using (owner_id = (select auth.uid()))
  with check (owner_id = (select auth.uid()));

create policy "Ride members can read participants"
  on public.ride_participants for select
  to authenticated
  using (
    user_id = (select auth.uid())
    or exists (
      select 1
      from public.ride_participants viewer
      where viewer.ride_id = ride_id
        and viewer.user_id = (select auth.uid())
    )
  );

create policy "Users can join active rides"
  on public.ride_participants for insert
  to authenticated
  with check (
    user_id = (select auth.uid())
    and exists (
      select 1
      from public.rides r
      where r.id = ride_id
        and r.status = 'active'
    )
  );

create policy "Ride members can read locations"
  on public.ride_locations for select
  to authenticated
  using (
    exists (
      select 1
      from public.ride_participants viewer
      where viewer.ride_id = ride_id
        and viewer.user_id = (select auth.uid())
    )
  );

create policy "Users can publish own location"
  on public.ride_locations for insert
  to authenticated
  with check (user_id = (select auth.uid()));

create policy "Users can update own location"
  on public.ride_locations for update
  to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));

create policy "Ride members can read new messages"
  on public.ride_messages for select
  to authenticated
  using (
    exists (
      select 1
      from public.ride_participants viewer
      where viewer.ride_id = ride_id
        and viewer.user_id = (select auth.uid())
    )
  );

create policy "Ride members can send messages"
  on public.ride_messages for insert
  to authenticated
  with check (user_id = (select auth.uid()));

do $$
begin
  alter publication supabase_realtime add table public.ride_locations;
exception
  when duplicate_object then null;
end $$;

do $$
begin
  alter publication supabase_realtime add table public.ride_messages;
exception
  when duplicate_object then null;
end $$;

do $$
begin
  alter publication supabase_realtime add table public.ride_participants;
exception
  when duplicate_object then null;
end $$;
