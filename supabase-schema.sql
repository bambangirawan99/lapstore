-- ============================================================
-- Schema untuk Buku Kas Griya Ikan BSD (versi standalone Supabase)
-- Aman dijalankan berkali-kali (idempotent) -- kalau tabel/kebijakan
-- sudah ada dari percobaan sebelumnya, tidak akan error lagi.
-- ============================================================

create table if not exists kv_store (
  key text primary key,
  value text not null,
  updated_at timestamptz not null default now()
);

alter table kv_store enable row level security;

drop policy if exists "Izinkan baca untuk semua" on kv_store;
create policy "Izinkan baca untuk semua"
  on kv_store for select
  using (true);

drop policy if exists "Izinkan tulis untuk semua" on kv_store;
create policy "Izinkan tulis untuk semua"
  on kv_store for insert
  with check (true);

drop policy if exists "Izinkan update untuk semua" on kv_store;
create policy "Izinkan update untuk semua"
  on kv_store for update
  using (true);

drop policy if exists "Izinkan hapus untuk semua" on kv_store;
create policy "Izinkan hapus untuk semua"
  on kv_store for delete
  using (true);

create index if not exists kv_store_key_prefix_idx on kv_store (key text_pattern_ops);
