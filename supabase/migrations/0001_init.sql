-- EvolutionCam: schema inicial (idempotente).
-- Caminho dos ficheiros no Storage: {user_id}/{collection_id}/{ficheiro}

-- Perfis ------------------------------------------------------------------
create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  display_name text not null default '',
  categories text[] not null default array['Paisagem', 'Limpeza', 'Construção'],
  created_at timestamptz not null default now()
);

-- Coleções ----------------------------------------------------------------
create table if not exists public.collections (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  title text not null,
  category text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists collections_user_updated_idx
  on public.collections (user_id, updated_at desc);

-- Imagens -----------------------------------------------------------------
create table if not exists public.images (
  id uuid primary key default gen_random_uuid(),
  collection_id uuid not null references public.collections (id) on delete cascade,
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  path text not null,
  name text not null,
  position integer not null default 0,
  created_at timestamptz not null default now()
);
create index if not exists images_collection_position_idx
  on public.images (collection_id, position);
create index if not exists images_user_idx on public.images (user_id);

-- RLS ---------------------------------------------------------------------
alter table public.profiles enable row level security;
alter table public.collections enable row level security;
alter table public.images enable row level security;

drop policy if exists profiles_select_own on public.profiles;
create policy profiles_select_own on public.profiles
  for select to authenticated using (id = (select auth.uid()));
drop policy if exists profiles_update_own on public.profiles;
create policy profiles_update_own on public.profiles
  for update to authenticated
  using (id = (select auth.uid())) with check (id = (select auth.uid()));

drop policy if exists collections_select_own on public.collections;
create policy collections_select_own on public.collections
  for select to authenticated using (user_id = (select auth.uid()));
drop policy if exists collections_insert_own on public.collections;
create policy collections_insert_own on public.collections
  for insert to authenticated with check (user_id = (select auth.uid()));
drop policy if exists collections_update_own on public.collections;
create policy collections_update_own on public.collections
  for update to authenticated
  using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));
drop policy if exists collections_delete_own on public.collections;
create policy collections_delete_own on public.collections
  for delete to authenticated using (user_id = (select auth.uid()));

drop policy if exists images_select_own on public.images;
create policy images_select_own on public.images
  for select to authenticated using (user_id = (select auth.uid()));
drop policy if exists images_insert_own on public.images;
create policy images_insert_own on public.images
  for insert to authenticated with check (
    user_id = (select auth.uid())
    and exists (
      select 1 from public.collections c
      where c.id = collection_id and c.user_id = (select auth.uid())
    )
  );
drop policy if exists images_delete_own on public.images;
create policy images_delete_own on public.images
  for delete to authenticated using (user_id = (select auth.uid()));

-- Novo utilizador -> perfil ------------------------------------------------
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (id, display_name)
  values (new.id, coalesce(new.raw_user_meta_data ->> 'display_name', ''))
  on conflict (id) do nothing;
  return new;
end;
$$;
revoke all on function public.handle_new_user() from public, anon, authenticated;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- Nova imagem -> atualiza a coleção ----------------------------------------
create or replace function public.touch_collection_on_image()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  update public.collections
     set updated_at = now()
   where id = coalesce(new.collection_id, old.collection_id);
  return null;
end;
$$;
revoke all on function public.touch_collection_on_image() from public, anon, authenticated;

drop trigger if exists images_touch_collection on public.images;
create trigger images_touch_collection
  after insert or delete on public.images
  for each row execute function public.touch_collection_on_image();

-- Storage (bucket privado) -------------------------------------------------
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'photos', 'photos', false, 15728640,
  array['image/jpeg', 'image/png', 'image/webp', 'image/heic', 'image/heif']
)
on conflict (id) do nothing;

drop policy if exists photos_select_own on storage.objects;
create policy photos_select_own on storage.objects
  for select to authenticated
  using (bucket_id = 'photos' and (storage.foldername(name))[1] = (select auth.uid())::text);
drop policy if exists photos_insert_own on storage.objects;
create policy photos_insert_own on storage.objects
  for insert to authenticated
  with check (bucket_id = 'photos' and (storage.foldername(name))[1] = (select auth.uid())::text);
drop policy if exists photos_delete_own on storage.objects;
create policy photos_delete_own on storage.objects
  for delete to authenticated
  using (bucket_id = 'photos' and (storage.foldername(name))[1] = (select auth.uid())::text);
