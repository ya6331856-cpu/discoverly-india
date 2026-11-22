create or replace function public.list_blocked_accounts()
returns table(blocked_user_id uuid, display_name text, blocked_at timestamptz)
language sql
stable
security definer
set search_path = public
as $$
  select bu.blocked_user_id,
         coalesce(nullif(p.display_name, ''), 'DISCOVERLY member') as display_name,
         bu.created_at
  from public.blocked_users bu
  left join public.profiles p on p.id = bu.blocked_user_id
  where bu.blocker_user_id = auth.uid()
  order by bu.created_at desc;
$$;
revoke all on function public.list_blocked_accounts() from public, anon;
grant execute on function public.list_blocked_accounts() to authenticated;
