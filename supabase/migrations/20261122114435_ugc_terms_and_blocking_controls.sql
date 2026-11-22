alter table public.profiles
  add column if not exists terms_accepted_at timestamptz,
  add column if not exists terms_version text;

create table if not exists public.blocked_users (
  blocker_user_id uuid not null references auth.users(id) on delete cascade,
  blocked_user_id uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (blocker_user_id, blocked_user_id),
  constraint blocked_users_no_self_block check (blocker_user_id <> blocked_user_id)
);
create index if not exists blocked_users_blocked_user_id_idx on public.blocked_users(blocked_user_id);
alter table public.blocked_users enable row level security;
drop policy if exists blocked_users_read_own on public.blocked_users;
create policy blocked_users_read_own on public.blocked_users
  for select to authenticated using (blocker_user_id = (select auth.uid()));
drop policy if exists blocked_users_insert_own on public.blocked_users;
create policy blocked_users_insert_own on public.blocked_users
  for insert to authenticated with check (blocker_user_id = (select auth.uid()) and blocked_user_id <> (select auth.uid()));
drop policy if exists blocked_users_delete_own on public.blocked_users;
create policy blocked_users_delete_own on public.blocked_users
  for delete to authenticated using (blocker_user_id = (select auth.uid()));

create or replace function public.block_business_owner(p_company_id uuid)
returns void
language plpgsql
security definer
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

create or replace function public.search_businesses(
  search_query text default null,
  category_slug text default null,
  state_filter text default null,
  city_filter text default null,
  result_limit integer default 20,
  result_offset integer default 0
)
returns table(
  company_id uuid,
  display_name text,
  slug text,
  description text,
  website_url text,
  city text,
  state text,
  category_names text[],
  relevance_score real
)
language sql
stable
set search_path to 'public', 'extensions'
as $function$
  with q as (select nullif(trim(search_query),'') as term),
  public_companies as (
    select c.id,c.display_name,c.slug,c.description,c.website_url,
      coalesce(loc.city,'') as city,coalesce(loc.state,'') as state,
      coalesce(cat.names,array[]::text[]) as category_names,
      case when q.term is null then 0.25::real
        else greatest(similarity(c.display_name,q.term),
          similarity(coalesce(c.description,''),q.term)*0.55,
          coalesce(off.best_offering_similarity,0))::real
      end as relevance_score
    from public.companies c cross join q
    left join lateral (
      select l.city,l.state from public.public_company_locations l
      where l.company_id=c.id order by l.is_head_office desc limit 1
    ) loc on true
    left join lateral (
      select array_agg(distinct ca.name) as names
      from public.company_categories cc join public.categories ca on ca.id=cc.category_id
      where cc.company_id=c.id and ca.is_active=true
    ) cat on true
    left join lateral (
      select max(similarity(o.title,q.term)) as best_offering_similarity
      from public.offerings o where o.company_id=c.id and o.is_published=true
    ) off on true
    where c.status='published'
      and not exists (
        select 1 from public.blocked_users bu
        where bu.blocker_user_id = auth.uid()
          and bu.blocked_user_id = c.created_by
      )
      and (state_filter is null or lower(coalesce(loc.state,''))=lower(state_filter))
      and (city_filter is null or lower(coalesce(loc.city,''))=lower(city_filter))
      and (category_slug is null or exists (
        select 1 from public.company_categories cc
        join public.categories ca on ca.id=cc.category_id
        where cc.company_id=c.id and ca.slug=category_slug and ca.is_active=true
      ))
      and (q.term is null
        or c.display_name ilike '%'||q.term||'%'
        or coalesce(c.description,'') ilike '%'||q.term||'%'
        or exists (select 1 from public.offerings o where o.company_id=c.id and o.is_published=true
          and (o.title ilike '%'||q.term||'%' or coalesce(o.description,'') ilike '%'||q.term||'%'))
        or similarity(c.display_name,q.term)>0.12)
  )
  select p.id,p.display_name,p.slug,p.description,p.website_url,
    nullif(p.city,''),nullif(p.state,''),p.category_names,p.relevance_score
  from public_companies p
  order by p.relevance_score desc,p.display_name asc
  limit least(greatest(coalesce(result_limit,20),1),100)
  offset greatest(coalesce(result_offset,0),0);
$function$;
