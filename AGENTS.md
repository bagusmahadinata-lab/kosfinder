# ATURAN KERJA AGEN AI (AGENTS.md)

Dokumen ini adalah pedoman dan batasan kerja mutlak bagi agen AI selama mengembangkan proyek **KosFinder**.

---

## 1. Konteks Proyek & Dokumen Acuan

Proyek ini adalah aplikasi mobile pencarian dan pengelolaan kos berbasis **Flutter** dan **Supabase**. Seluruh pekerjaan wajib mengacu pada:
- `docs/PRD.md`: Berisi masalah, scope V1, user story (US01–US07), dan acceptance criteria (AC).
- `docs/ARCHITECTURE.md`: Pola arsitektur, rencana database, alur layar, dan daftar package yang diizinkan.
- `docs/TASKS.md`: Rincian task vertical slice yang aktif dikerjakan.

---

## 2. Cara Kerja Agen

1. **Satu Task Per Permintaan:** Kerjakan hanya satu task yang sedang diinstruksikan oleh Software Engineer (SE). Jangan melompati task atau mengerjakan beberapa task sekaligus.
2. **Batasan Perubahan Berkas:** Hanya ubah atau buat berkas yang secara eksplisit dicantumkan pada task yang sedang aktif di `docs/TASKS.md`. Dilarang menyentuh berkas lain tanpa izin.
3. **Prinsip Kesederhanaan (*Simplicity*):** Selalu pilih solusi yang paling sederhana, bersih, dan langsung memenuhi kriteria AC. Hindari over-engineering (misal: dilarang menambahkan microservice, caching rumit, atau multiple state management).
4. **Larangan Menambah Package Sembarangan:** Dilarang menambahkan package / dependency baru di `pubspec.yaml` di luar yang telah disepakati di `docs/ARCHITECTURE.md` tanpa persetujuan eksplisit dari SE.
5. **Rencanakan Perubahan Besar:** Jika suatu perubahan berdampak luas, jelaskan dampaknya terlebih dahulu kepada SE dan tunggu persetujuan sebelum menulis kode.

---

## 3. Standar Teknologi

- **Framework:** Flutter (Android).
- **State Management:** `Provider` (`ChangeNotifier`).
- **Backend:** Supabase (`supabase_flutter`) untuk Autentikasi dan Database PostgreSQL.

---

## 4. Keamanan & Privasi

1. **Kerahasiaan Kredensial:** Dilarang keras menuliskan API key, secret, anon key, token, URL Supabase, atau password di dalam kode sumber repository (`.dart`, `.env`, atau `.md`).
2. **Koneksi Supabase:** Wajib membaca `SUPABASE_URL` dan `SUPABASE_ANON_KEY` dari `--dart-define` (`String.fromEnvironment`).
3. **Larangan Service Role:** `service_role` key **TIDAK PERNAH** boleh dimasukkan atau digunakan di dalam aplikasi client.
4. **Penegakan Akses (RLS):** Keamanan dan hak akses data ditegakkan di backend melalui Supabase **Row Level Security (RLS)**, bukan hanya dengan menyembunyikan tombol di antarmuka (UI).

---

## 5. Konvensi Git

1. **Satu Task, Satu Commit:** Lakukan commit hanya setelah satu task selesai, lulus pengujian, dan disetujui oleh SE.
2. **Format Pesan Commit:** Pesan commit wajib mencantumkan ID task dan deskripsi singkat, contoh:
   - `T01: inisialisasi koneksi Supabase via dart-define`
   - `T03: filter harga dan fasilitas (US03-AC2)`

---

## 6. Definition of Done (DoD)

Sebuah task dianggap selesai hanya jika memenuhi seluruh kriteria berikut:
1. `flutter analyze` berjalan bersih tanpa error dan tanpa warning.
2. `flutter test` lulus seluruh unit/widget test yang terkait dengan logika task tersebut.
3. Kode terverifikasi dapat berjalan di device/emulator sesuai dengan AC yang relevan.
4. Agen memberikan laporan transparan kepada SE mengenai:
   - Berkas apa saja yang diubah dan fungsinya.
   - Hasil eksekusi `flutter analyze` dan `flutter test`.
   - Apa yang belum atau tidak bisa diuji secara otomatis.

---

## 7. Identitas Pengembang pada Aplikasi

Aplikasi wajib mencantumkan identitas SE pada layar **About**:
- **Format:** `2415051023 - Dewa Putu Bagus Mahadinata`
