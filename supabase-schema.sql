-- ============================================================
-- Schema untuk LAPSTORE (versi standalone Supabase)
-- Aman dijalankan berkali-kali (idempotent) -- kalau tabel/kebijakan
-- sudah ada dari percobaan sebelumnya, tidak akan error lagi.
--
-- CATATAN: mulai versi ini, akses ke data WAJIB login (Supabase Auth).
-- Pastikan kamu sudah membuat akun untuk dirimu sendiri di
-- Authentication > Users sebelum menjalankan schema ini, supaya
-- tidak sampai terkunci dari data sendiri.
-- ============================================================

create table if not exists kv_store (
  key text primary key,
  value text not null,
  updated_at timestamptz not null default now()
);

alter table kv_store enable row level security;

drop policy if exists "Izinkan baca untuk semua" on kv_store;
drop policy if exists "Izinkan baca untuk user login" on kv_store;
create policy "Izinkan baca untuk user login"
  on kv_store for select
  using (auth.role() = 'authenticated');

drop policy if exists "Izinkan tulis untuk semua" on kv_store;
drop policy if exists "Izinkan tulis untuk user login" on kv_store;
create policy "Izinkan tulis untuk user login"
  on kv_store for insert
  with check (auth.role() = 'authenticated');

drop policy if exists "Izinkan update untuk semua" on kv_store;
drop policy if exists "Izinkan update untuk user login" on kv_store;
create policy "Izinkan update untuk user login"
  on kv_store for update
  using (auth.role() = 'authenticated');

drop policy if exists "Izinkan hapus untuk semua" on kv_store;
drop policy if exists "Izinkan hapus untuk user login" on kv_store;
create policy "Izinkan hapus untuk user login"
  on kv_store for delete
  using (auth.role() = 'authenticated');

create index if not exists kv_store_key_prefix_idx on kv_store (key text_pattern_ops);
