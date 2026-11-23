-- DISCOVERLY initial ingestion is limited to Maharashtra.
-- Reject missing/unknown states and any record outside Maharashtra at the database boundary.
-- Accepted source spellings are the full state name and the ISO-style state abbreviation.
-- This applies to inserts and updates, including records staged outside the RPC workflow.

alter table public.business_import_staging
  add constraint business_import_staging_maharashtra_only_check
  check (
    state is not null
    and lower(btrim(state)) in ('maharashtra', 'mh')
  );

comment on constraint business_import_staging_maharashtra_only_check
  on public.business_import_staging
  is 'DISCOVERLY initial data coverage is Maharashtra only; missing or non-Maharashtra state values are not eligible for staging or approval.';
