alter table public.data_import_batches
  alter column created_by drop not null;

alter table public.data_import_batches
  drop constraint if exists data_import_batches_created_by_fkey;

alter table public.data_import_batches
  add constraint data_import_batches_created_by_fkey
  foreign key (created_by) references auth.users(id) on delete set null;
