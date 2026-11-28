# KosFinder 🏠

Aplikasi mobile pencarian dan pengelolaan kos berbasis **Flutter** dan **Supabase**. Dibangun dengan pendekatan *Vibe Coding Terstruktur* pada Worksheet 11b.

---

## 👨‍💻 Identitas Pengembang
- **Nama:** Dewa Putu Bagus Mahadinata
- **NIM:** 2415051023
- **Kelas:** PTI 5 IKI
- **Program Studi:** Pendidikan Teknik Informatika, Universitas Pendidikan Ganesha

---

## 🌟 Fitur Utama (Versi 1.0)

1. **Katalog Kos Publik (Tanpa Login):**
   - Melihat daftar kos aktif secara langsung tanpa perlu mendaftar/login.
   - Penanganan kondisi offline dengan pesan ramah dan tombol "Coba Lagi" tanpa crash.
2. **Detail Kos & Kontak WhatsApp:**
   - Melihat detail lengkap harga, tipe (Putra/Putri/Campur), periode sewa, checklist fasilitas, dan sisa kamar.
   - Tombol langsung mengarahkan ke obrolan WhatsApp pemilik (`wa.me`).
3. **Pencarian & Filter Pintar:**
   - Pencarian teks nama, area, atau alamat secara *case-insensitive*.
   - Filter harga maksimum dan checklist fasilitas (WiFi, AC, Parkir Motor, dll).
4. **Autentikasi Pemilik Kos:**
   - Pendaftaran akun pemilik baru, login aman, dan logout via Supabase Auth.
5. **Dashboard & Manajemen Kos (CRUD):**
   - Tambah kos baru dengan validasi formulir lengkap.
   - Edit kos milik sendiri dan pembaruan jumlah sisa kamar.
   - Toggle switch nonaktif sementara (kos disembunyikan dari katalog publik).
   - Hapus kos permanen dengan dialog konfirmasi.
6. **Keamanan Data Level Database (Row Level Security):**
   - Penegakan otorisasi di level database PostgreSQL Supabase: Pemilik B ditolak secara absolut oleh sistem RLS jika mencoba mengubah atau menghapus data milik Pemilik A.
7. **Ketersediaan Kamar Dinamis (Bonus):**
   - Ketika pemilik mengatur sisa kamar menjadi 0, badge status otomatis berubah menjadi **"PENUH"**.

---

## 🚫 Batasan Versi 1.0 (Scope V1)
- Pembayaran dan transaksi sewa tidak diproses di dalam aplikasi (transaksi langsung via WhatsApp/pemilik).
- Fitur rating dan review pengguna ditunda untuk Versi 2.
- Gambar properti menggunakan direct URL link (belum upload file langsung ke object storage).

---

## 🚀 Cara Menjalankan Aplikasi

Aplikasi ini menggunakan `--dart-define` untuk menjaga kerahasiaan kredensial Supabase. Jangan pernah menuliskan API key atau URL secara hardcoded di kode sumber.

### 1. Jalankan di Terminal (Android Emulator / Device Fisik)
```powershell
flutter run --dart-define=SUPABASE_URL=YOUR_SUPABASE_URL --dart-define=SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY
```

### 2. Jalankan di Windows Desktop
```powershell
flutter run -d windows --dart-define=SUPABASE_URL=YOUR_SUPABASE_URL --dart-define=SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY
```

### 3. Menjalankan Pengujian
```powershell
# Analisis kode (harus 0 issues)
flutter analyze

# Menjalankan seluruh test suite (30 test)
flutter test
```
