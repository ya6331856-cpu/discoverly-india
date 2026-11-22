create or replace function public.block_business_owner(p_company_id uuid)
returns void
language plpgsql
security invoker
set search_path = public
as $$
declare
  v_owner uuid;
begin
  if auth.uid() is null then
    raise exception 'Authentication required' using errcode = '42501';
  end if;
  select created_by into v_owner
  from public.companies
  where id = p_company_id and status = 'published';
  if v_owner is null then
    raise exception 'Business is not available';
  end if;
  if v_owner = auth.uid() then
    raise exception 'You cannot block your own business';
  end if;
  insert into public.blocked_users(blocker_user_id, blocked_user_id)
  values (auth.uid(), v_owner)
  on conflict do nothing;
end;
$$;
revoke all on function public.block_business_owner(uuid) from public, anon;
grant execute on function public.block_business_owner(uuid) to authenticated;

create or replace function public.list_blocked_accounts()
returns table(blocked_user_id uuid, display_name text, blocked_at timestamptz)
language sql
stable
security invoker
set search_path = public
as $$
  select bu.blocked_user_id,
         'Blocked member'::text as display_name,
         bu.created_at
  from public.blocked_users bu
  where bu.blocker_user_id = auth.uid()
  order by bu.created_at desc;
$$;
revoke all on function public.list_blocked_accounts() from public, anon;
grant execute on function public.list_blocked_accounts() to authenticated;
