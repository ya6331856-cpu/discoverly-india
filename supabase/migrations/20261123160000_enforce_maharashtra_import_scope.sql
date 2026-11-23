-- Enforce DISCOVERLY's approved initial coverage at the database boundary.
-- Only India records whose state is explicitly Maharashtra (or MH) can be approved.
-- Out-of-scope named records are retained as rejected staging rows for auditability.

create or replace function private.is_maharashtra_import_state(p_state text)
returns boolean
language sql
immutable
security invoker
set search_path = pg_catalog
as $$
  select upper(btrim(coalesce(p_state, ''))) in ('MAHARASHTRA', 'MH');
$$;

revoke all on function private.is_maharashtra_import_state(text) from public, anon, authenticated;

create or replace function private.admin_stage_business_import_rows(p_batch_id uuid, p_rows jsonb)
returns jsonb
language plpgsql
security definer
set search_path = pg_catalog, public, pg_temp
as $function$
declare
  v_uid uuid := auth.uid();
  v_batch public.data_import_batches%rowtype;
  v_item jsonb;
  v_name text;
  v_city text;
  v_state text;
  v_country_code text;
  v_key text;
  v_status text;
  v_review_note text;
  v_company uuid;
  v_duplicate_staging uuid;
  v_count integer := 0;
  v_dupes integer := 0;
  v_rejected integer := 0;
begin
  if v_uid is null or not exists (
    select 1 from public.user_roles
    where user_id = v_uid and role in ('admin', 'moderator')
  ) then
    raise exception 'Admin or moderator access required';
  end if;

  if coalesce(jsonb_typeof(p_rows), '') <> 'array' or jsonb_array_length(p_rows) > 1000 then
    raise exception 'Provide an array of up to 1000 records per batch';
  end if;

  select * into v_batch
  from public.data_import_batches
  where id = p_batch_id
  for update;

  if not found or v_batch.created_by <> v_uid then
    raise exception 'Import batch not found or not owned by current reviewer';
  end if;

  if not exists (
    select 1 from public.data_sources ds
    where ds.id = v_batch.source_id
      and ds.status = 'active'
      and ds.ingestion_enabled
  ) then
    raise exception 'This source is not approved for ingestion';
  end if;

  update public.data_import_batches set status = 'staging' where id = p_batch_id;

  for v_item in select value from jsonb_array_elements(p_rows)
  loop
    v_name := nullif(btrim(coalesce(
      v_item->>'business_name',
      v_item->>'name',
      v_item->>'company_name',
      ''
    )), '');
    v_city := nullif(btrim(coalesce(v_item->>'city', '')), '');
    v_state := nullif(btrim(coalesce(v_item->>'state', '')), '');
    v_country_code := case
      when upper(coalesce(nullif(btrim(v_item->>'country_code'), ''), 'IN')) = 'IN' then 'IN'
      else 'ZZ'
    end;

    if v_name is null then
      v_rejected := v_rejected + 1;
      continue;
    end if;

    v_key := regexp_replace(lower(v_name), '[^a-z0-9]+', '', 'g')
      || '|' || regexp_replace(lower(coalesce(v_city, '')), '[^a-z0-9]+', '', 'g');

    v_company := null;
    v_duplicate_staging := null;
    v_review_note := null;

    if v_country_code <> 'IN' or not private.is_maharashtra_import_state(v_state) then
      v_status := 'rejected';
      v_review_note := 'Outside DISCOVERLY initial coverage: only India records explicitly identifying Maharashtra are accepted.';
      v_rejected := v_rejected + 1;
    else
      v_state := 'Maharashtra';

      select c.id into v_company
      from public.companies c
      left join public.company_locations l on l.company_id = c.id
      where c.status in ('draft', 'published', 'pending_review')
        and regexp_replace(lower(coalesce(c.display_name, c.legal_name)), '[^a-z0-9]+', '', 'g') = split_part(v_key, '|', 1)
        and (v_city is null or regexp_replace(lower(coalesce(l.city, '')), '[^a-z0-9]+', '', 'g') = split_part(v_key, '|', 2))
      limit 1;

      if v_company is null then
        select id into v_duplicate_staging
        from public.business_import_staging
        where batch_id = p_batch_id and duplicate_key = v_key
        limit 1;
      end if;

      v_status := case
        when v_company is not null or v_duplicate_staging is not null then 'duplicate'
        else 'needs_review'
      end;

      if v_status = 'duplicate' then
        v_dupes := v_dupes + 1;
      end if;
    end if;

    insert into public.business_import_staging (
      batch_id, source_id, external_id, source_record_url, source_record_hash,
      raw_data, business_name, legal_name, city, state, country_code,
      category_name, website_url, public_phone, public_email,
      duplicate_of_company_id, duplicate_of_staging_id, status, review_note,
      license_snapshot
    )
    values (
      p_batch_id,
      v_batch.source_id,
      nullif(v_item->>'external_id', ''),
      nullif(v_item->>'source_record_url', ''),
      coalesce(
        nullif(v_item->>'source_record_hash', ''),
        md5(v_key || '|' || coalesce(v_item->>'external_id', '') || '|' || coalesce(v_item->>'source_record_url', ''))
      ),
      v_item,
      v_name,
      nullif(v_item->>'legal_name', ''),
      v_city,
      v_state,
      v_country_code,
      nullif(v_item->>'category_name', ''),
      nullif(v_item->>'website_url', ''),
      nullif(v_item->>'public_phone', ''),
      nullif(v_item->>'public_email', ''),
      v_company,
      v_duplicate_staging,
      v_status,
      v_review_note,
      (
        select jsonb_build_object(
          'license_name', license_name,
          'license_url', license_url,
          'attribution_text', attribution_text,
          'share_alike_required', share_alike_required
        )
        from public.data_sources
        where id = v_batch.source_id
      )
    );

    v_count := v_count + 1;
  end loop;

  update public.data_import_batches
  set status = 'needs_review',
      staged_count = staged_count + v_count,
      duplicate_count = duplicate_count + v_dupes,
      rejected_count = rejected_count + v_rejected
  where id = p_batch_id;

  return jsonb_build_object(
    'staged_count', v_count,
    'duplicate_count', v_dupes,
    'rejected_count', v_rejected
  );
end;
$function$;

create or replace function private.admin_review_business_import(
  p_staging_id uuid,
  p_decision text,
  p_review_note text default null
)
returns uuid
language plpgsql
security definer
set search_path = pg_catalog, public, pg_temp
as $function$
declare
  v_uid uuid := auth.uid();
  v_item public.business_import_staging%rowtype;
  v_source public.data_sources%rowtype;
  v_company_id uuid;
  v_slug text;
  v_category_id uuid;
begin
  if v_uid is null or not exists (
    select 1 from public.user_roles
    where user_id = v_uid and role in ('admin', 'moderator')
  ) then
    raise exception 'Admin or moderator access required';
  end if;

  select * into v_item
  from public.business_import_staging
  where id = p_staging_id
  for update;

  if not found then
    raise exception 'Import record not found';
  end if;

  select * into v_source
  from public.data_sources
  where id = v_item.source_id;

  if p_decision not in ('approve', 'reject', 'duplicate') then
    raise exception 'Invalid review decision';
  end if;

  if p_decision = 'reject' then
    update public.business_import_staging
    set status = 'rejected',
        review_note = coalesce(p_review_note, review_note),
        reviewed_by = v_uid,
        reviewed_at = now()
    where id = p_staging_id;

    if v_item.status <> 'rejected' then
      update public.data_import_batches
      set rejected_count = rejected_count + 1
      where id = v_item.batch_id;
    end if;
    return null;
  end if;

  if v_item.status in ('imported', 'rejected') then
    raise exception 'This record cannot be approved or changed in its current state';
  end if;

  if p_decision = 'duplicate' then
    update public.business_import_staging
    set status = 'duplicate',
        review_note = p_review_note,
        reviewed_by = v_uid,
        reviewed_at = now()
    where id = p_staging_id;
    return null;
  end if;

  -- Re-check scope at approval time; never trust only the staging-time check.
  if upper(btrim(coalesce(v_item.country_code, ''))) <> 'IN'
     or not private.is_maharashtra_import_state(v_item.state) then
    raise exception 'Approval blocked: only India records explicitly identifying Maharashtra are in the initial coverage';
  end if;

  if v_item.duplicate_of_company_id is not null then
    raise exception 'This record matches an existing company; mark it duplicate instead';
  end if;

  v_slug := trim(both '-' from regexp_replace(lower(v_item.business_name), '[^a-z0-9]+', '-', 'g'))
    || '-' || substr(replace(gen_random_uuid()::text, '-', ''), 1, 7);

  select id into v_category_id
  from public.categories
  where is_active = true and lower(name) = lower(v_item.category_name)
  order by case when category_type = 'industry' then 0 else 1 end
  limit 1;

  insert into public.companies (
    legal_name, display_name, slug, description, website_url, status, created_by
  )
  values (
    coalesce(v_item.legal_name, v_item.business_name),
    v_item.business_name,
    v_slug,
    'Imported business record. Owner confirmation and verification are required.',
    v_item.website_url,
    'draft',
    v_uid
  )
  returning id into v_company_id;

  if v_category_id is not null then
    insert into public.company_categories(company_id, category_id, is_primary)
    values (v_company_id, v_category_id, true)
    on conflict do nothing;
  end if;

  insert into public.company_profiles(company_id, public_phone, public_email, address_visibility)
  values (v_company_id, v_item.public_phone, v_item.public_email, 'city');

  insert into public.company_locations(company_id, country_code, state, city, is_head_office, is_public)
  values (v_company_id, 'IN', 'Maharashtra', v_item.city, true, false);

  insert into public.company_data_sources (
    company_id, source_id, staging_id, external_id,
    source_record_url, source_record_hash, license_snapshot
  )
  values (
    v_company_id, v_item.source_id, v_item.id, v_item.external_id,
    v_item.source_record_url, v_item.source_record_hash, v_item.license_snapshot
  )
  on conflict(source_id, source_record_hash) do nothing;

  update public.business_import_staging
  set status = 'imported',
      review_note = p_review_note,
      reviewed_by = v_uid,
      reviewed_at = now(),
      imported_company_id = v_company_id
  where id = p_staging_id;

  update public.data_import_batches
  set approved_count = approved_count + 1
  where id = v_item.batch_id;

  insert into public.audit_logs(actor_user_id, action, entity_type, entity_id, metadata)
  values (
    v_uid,
    'business_import_approved',
    'company',
    v_company_id,
    jsonb_build_object(
      'staging_id', p_staging_id,
      'source_id', v_item.source_id,
      'source_key', v_source.source_key
    )
  );

  return v_company_id;
end;
$function$;

-- Keep the helper private; authenticated access remains through the existing
-- public RPC wrappers, whose private functions perform their own role checks.
