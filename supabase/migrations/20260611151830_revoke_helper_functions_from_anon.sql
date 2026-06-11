-- Helper functions are only for RLS policies, not public RPC calls.
revoke execute on function public.is_ride_member(uuid) from anon;
revoke execute on function public.is_active_ride(uuid) from anon;
