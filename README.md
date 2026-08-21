# Buku Kas Griya Ikan BSD (Versi Standalone)

Aplikasi pencatatan keuangan UMKM: pembelian bahan baku, produksi (konversi
bahan baku jadi produk jadi), penjualan dengan resi & integrasi WhatsApp,
stok, piutang, HPP otomatis, dan laporan laba rugi PDF.

Versi ini berjalan mandiri di luar Claude, memakai **Supabase** sebagai
database backend, dan bisa di-hosting gratis lewat **GitHub Pages**.

---

## 1. Yang kamu butuhkan

- Akun [Supabase](https://supabase.com) (gratis)
- Akun GitHub (gratis)
- (Opsional) Akun Anthropic + API key, kalau mau fitur AI (isi otomatis & analisis AI) aktif

---

## 2. Setup Supabase (database)

1. Buka [supabase.com](https://supabase.com) → **New project**. Catat *nama project* dan *password database* (simpan baik-baik).
2. Setelah project selesai dibuat, buka menu **SQL Editor** di sidebar kiri → **New query**.
3. Buka file [`supabase-schema.sql`](./supabase-schema.sql) di repo ini, salin seluruh isinya, tempel ke SQL Editor, lalu klik **Run**.
   - Ini akan membuat tabel `kv_store` tempat semua data transaksi disimpan.
4. Buka menu **Project Settings > API**. Catat dua hal ini:
   - **Project URL** (contoh: `https://xxxxx.supabase.co`)
   - **anon public key** (kunci panjang di bagian "Project API keys")

---

## 3. Hubungkan aplikasi ke Supabase

1. Buka file `index.html` di editor teks apa pun.
2. Cari baris ini (dekat awal file, di dalam tag `<script>` pertama):
   ```js
   const SUPABASE_URL = 'GANTI_DENGAN_SUPABASE_PROJECT_URL';
   const SUPABASE_ANON_KEY = 'GANTI_DENGAN_SUPABASE_ANON_KEY';
   ```
3. Ganti dengan nilai yang kamu catat di langkah 2 tadi. Contoh:
   ```js
   const SUPABASE_URL = 'https://abcduvwxyz.supabase.co';
   const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
   ```
4. Simpan file. Coba buka `index.html` langsung di browser (dobel klik) — aplikasi harusnya sudah bisa mencatat transaksi dan tersimpan ke Supabase.

> **Catatan keamanan:** `anon key` ini memang didesain aman untuk ditaruh di kode publik/frontend — tapi karena kebijakan akses (RLS) di `supabase-schema.sql` mengizinkan siapa pun membaca & menulis data, siapa pun yang tahu URL situsmu bisa mencatat/menghapus transaksi. Ini cocok untuk tim kecil yang saling percaya. Kalau butuh kontrol akses lebih (login per kasir, dsb.), itu perlu pengembangan tambahan di luar setup dasar ini.

---

## 4. Push ke GitHub & deploy dengan GitHub Pages

1. Buat repo baru di GitHub (bisa privat atau publik).
2. Upload semua file di folder ini ke repo (lewat GitHub Desktop, web upload, atau command line):
   ```bash
   git init
   git add .
   git commit -m "Setup awal buku kas"
   git branch -M main
   git remote add origin https://github.com/USERNAME/NAMA_REPO.git
   git push -u origin main
   ```
3. Di GitHub, buka repo → **Settings > Pages**.
4. Di bagian **Source**, pilih branch `main` dan folder `/ (root)`, lalu **Save**.
5. Tunggu 1-2 menit, GitHub akan memberi alamat situs seperti:
   `https://USERNAME.github.io/NAMA_REPO/`
6. Buka alamat itu — aplikasi kamu sudah online dan bisa diakses siapa saja yang tahu link-nya (mirip cara kerja artifact Claude sebelumnya, tapi sekarang datanya di Supabase milikmu sendiri).

> Kalau repo-nya publik, kode `index.html` (termasuk `SUPABASE_URL` dan `SUPABASE_ANON_KEY`) akan terlihat siapa saja. Ini **normal dan aman** untuk anon key Supabase (asal kebijakan RLS-nya sudah kamu atur sesuai kebutuhan). Yang **tidak boleh** pernah dimasukkan ke `index.html` adalah API key Anthropic — lihat bagian 5.

---

## 5. Mengaktifkan fitur AI (opsional)

Fitur "Isi otomatis (AI)" dan "Analisis AI" butuh akses ke Anthropic API. Karena `index.html` bersifat publik, **API key Anthropic tidak boleh ditaruh langsung di sana** — siapa pun bisa mengambilnya dan memakai kuota API-mu.

Solusinya: pakai Supabase Edge Function sebagai perantara aman (API key disimpan di server Supabase, bukan di kode publik).

1. Install [Supabase CLI](https://supabase.com/docs/guides/cli).
2. Login & hubungkan ke project:
   ```bash
   supabase login
   supabase link --project-ref XXXX   # XXXX ada di Project Settings > General
   ```
3. Simpan API key Anthropic sebagai secret (server-side, tidak akan terlihat publik):
   ```bash
   supabase secrets set ANTHROPIC_API_KEY=sk-ant-xxxxxxxxxxxxxxxx
   ```
4. Deploy function-nya (sudah disiapkan di `supabase/functions/ai-proxy/index.ts`):
   ```bash
   supabase functions deploy ai-proxy --no-verify-jwt
   ```
5. Setelah deploy, Supabase akan memberi URL seperti:
   `https://xxxxx.supabase.co/functions/v1/ai-proxy`
6. Buka `index.html`, isi baris ini dengan URL tadi:
   ```js
   const AI_PROXY_URL = 'https://xxxxx.supabase.co/functions/v1/ai-proxy';
   ```
7. Push perubahan ini ke GitHub, tunggu GitHub Pages update otomatis.

Kalau `AI_PROXY_URL` dikosongkan, fitur AI akan menampilkan pesan yang jelas ("Fitur AI belum diatur") alih-alih gagal diam-diam.

---

## 6. Fitur yang tersedia

- Catat pembelian bahan baku & penjualan (dengan opsi resi atau tanpa resi)
- Resi otomatis + kirim ke pelanggan lewat WhatsApp (`wa.me` link, tidak perlu API WhatsApp berbayar)
- Produksi: konversi bahan baku jadi produk jadi, mendukung banyak bahan & banyak hasil
- Stok otomatis (pembelian, penjualan, produksi saling terhubung lewat nama item)
- Piutang / belum lunas + pengingat WhatsApp
- HPP otomatis (metode rata-rata bergerak) & estimasi HPP real-time saat input produksi
- Laporan laba rugi PDF per bulan
- Edit & hapus transaksi, termasuk hapus massal
- Tampilan responsif desktop & HP

## 7. Struktur file

```
├── index.html                          # Aplikasi utama (satu file, HTML+CSS+JS)
├── supabase-schema.sql                 # Skrip setup tabel & keamanan Supabase
├── supabase/functions/ai-proxy/        # Edge Function proxy AI (opsional)
├── README.md                           # File ini
└── .gitignore
```

## 8. Batasan yang perlu diketahui

- Tidak ada sistem login/peran pengguna — siapa pun dengan link situs bisa mencatat & menghapus data.
- HPP dihitung dari riwayat transaksi secara berurutan waktu — data yang tidak lengkap atau tidak berurutan akan membuat perhitungan kurang akurat.
- WhatsApp memakai `wa.me` (membuka chat manual), bukan pengiriman otomatis tanpa klik.
