# Product Requirements Document (PRD): KosFinder

**Versi:** 1.0  
**Status:** Draf untuk Review SE  
**Sasaran Platform:** Mobile Android (Flutter)  
**Backend:** Supabase (Auth, PostgreSQL, Row Level Security)

---

## 1. Masalah & Tujuan Terukur

### Masalah
- Informasi sewa kos tersebar di berbagai media sosial dan grup WhatsApp tanpa format terstandarisasi.
- Pencari kos kesulitan membandingkan harga, fasilitas, dan ketersediaan kamar secara cepat.
- Pemilik kos kesulitan memperbarui ketersediaan kamar yang dinamis dan menjangkau calon penyewa.

### Tujuan Terukur
- **100%** pencari kos dapat mencari, memfilter, dan melihat detail kos tanpa perlu membuat akun atau login.
- Waktu pencarian dan pemfilteran kos berdasarkan area dan harga berespons dalam waktu **< 2 detik** pada kondisi jaringan normal.
- Pemilik kos dapat mendaftar, menambah properti, dan memperbarui status ketersediaan/jumlah kamar secara instan (**< 3 detik**).

---

## 2. Pengguna

1. **Pencari Kos (Mahasiswa & Masyarakat):**
   - Mengakses aplikasi secara publik tanpa login.
   - Kebutuhan: Melihat daftar kos, mencari berdasarkan area, memfilter harga dan fasilitas, melihat detail kos, dan menghubungi pemilik langsung via WhatsApp.
2. **Pemilik Kos:**
   - Memiliki akun terdaftar (email & password via Supabase Auth).
   - Kebutuhan: Mengelola data kos miliknya (tambah, lihat, ubah, hapus), memperbarui ketersediaan kamar (status ketersediaan & jumlah kamar sisa), serta menyematkan kontak WhatsApp dan URL foto kos.

---

## 3. Scope Versi 1

### A. Yang Masuk (In-Scope V1)
1. **Autentikasi Pemilik:** Pendaftaran akun baru, login, dan logout menggunakan Supabase Auth.
2. **Katalog & Detail Kos Publik:**
   - Menampilkan daftar kos beserta gambar utama (berbasis URL eksternal direct-link).
   - Detail kos: nama, alamat/area, harga sewa (per bulan / per tahun), tipe kos (Putra/Putri/Campur), checklist fasilitas, status ketersediaan & jumlah kamar tersisa.
   - Tombol aksi *"Hubungi via WhatsApp"* yang mengarah langsung ke nomor WA pemilik.
3. **Pencarian & Filter:**
   - Pencarian berbasis teks bebas (*case-insensitive*) pada nama kos, alamat, atau area sekitar kampus.
   - Filter harga maksimum dan checklist fasilitas (WiFi, AC, Kamar Mandi Dalam, Kasur, Lemari).
4. **Manajemen Properti oleh Pemilik (CRUD):**
   - Pemilik dapat mengelola satu atau lebih kos miliknya.
   - Pembaruan status ketersediaan (*Tersedia* / *Penuh*) dan angka sisa kamar.
   - Fitur toggle status *Aktif / Nonaktif* (menonaktifkan kos sementara tanpa menghapus data).
   - Hapus permanen kos miliknya sendiri.

### B. Yang TIDAK Masuk (Out-of-Scope V1)
- Pembayaran online dan sistem booking in-app.
- Fitur chat internal antar pengguna.
- Ulasan (*review*) dan sistem rating bintang (disimpan untuk V2).
- Rekomendasi kos berbasis AI.
- Verifikasi identitas resmi pemilik kos (KTP/dokumen legal).
- Fitur upload file gambar langsung ke storage (V1 murni input URL gambar).
- Integrasi peta interaktif (*Google Maps / GPS tracking*).

---

## 4. Non-Functional Requirements (NFR)

- **NFR01 (Keamanan & Otorisasi Backend):** Hak akses ditegakkan di backend melalui Supabase **Row Level Security (RLS)**. Modifikasi (UPDATE/DELETE) kos milik Pemilik A oleh Pemilik B wajib ditolak di level database (error 403 / policy violation), bukan sekadar menyembunyikan tombol UI.
- **NFR02 (Keamanan Kredensial):** Tidak ada kredensial sensitif (`service_role` key atau password) yang disimpan di kode sumber. Konfigurasi client hanya menggunakan publishable/anon key yang dibaca via `--dart-define`.
- **NFR03 (Keandalan / Error Handling):** Saat koneksi internet terputus atau backend gagal dijangkau, aplikasi tidak boleh crash dan wajib menampilkan pesan error informatif disertai opsi muat ulang.
- **NFR04 (Performa):** Tampilan daftar kos pertama kali memuat dalam waktu < 2 detik pada koneksi internet seluler standar.
- **NFR05 (Privasi):** Password pengguna dienkripsi penuh oleh Supabase Auth; nomor kontak WhatsApp hanya ditampilkan jika pemilik menyetujui untuk mencantumkannya saat menerbitkan kos.

---

## 5. User Stories & Acceptance Criteria

### US01: Menjelajahi Daftar Kos Publik
*Sebagai Pencari Kos, saya ingin melihat katalog kos tanpa harus login, agar saya dapat menemukan pilihan hunian dengan cepat.*
- **US01-AC1 (Data Kos Tampil):**  
  *Given* aplikasi terhubung ke internet  
  *When* pencari membuka halaman utama  
  *Then* daftar kartu kos tampil berisi foto (URL), nama kos, tipe gender, harga/periode, dan status ketersediaan kamar.
- **US01-AC2 (Koneksi Internet Gagal):**  
  *Given* perangkat tidak memiliki koneksi internet  
  *When* halaman utama dibuka atau ditarik untuk refresh (*pull-to-refresh*)  
  *Then* aplikasi menampilkan pesan gagal koneksi ("Gagal memuat data kos. Periksa koneksi internet Anda") dan tombol "Coba Lagi" tanpa crash.
- **US01-AC3 (Kondisi Data Kos Kosong):**  
  *Given* belum ada data kos yang terdaftar di database  
  *When* pencari membuka halaman utama  
  *Then* aplikasi menampilkan pesan informatif ("Belum ada kos yang tersedia saat ini").

---

### US02: Melihat Detail Kos dan Menghubungi Pemilik
*Sebagai Pencari Kos, saya ingin melihat rincian fasilitas dan kontak pemilik, agar saya dapat menghubungi pemilik untuk survei atau tanya ketersediaan.*
- **US02-AC1 (Detail Kos Lengkap):**  
  *Given* pencari berada di halaman katalog kos  
  *When* pencari memilih salah satu kartu kos  
  *Then* halaman detail terbuka menampilkan gambar, nama, alamat lengkap/area, harga & periode sewa, checklist fasilitas, sisa kamar, dan tombol "Hubungi via WhatsApp".
- **US02-AC2 (Aksi Hubungi WhatsApp):**  
  *Given* pencari berada di halaman detail kos yang memiliki nomor WhatsApp pemilik  
  *When* pencari menekan tombol "Hubungi via WhatsApp"  
  *Then* aplikasi membuka tautan WhatsApp resmi (`https://wa.me/<nomor>`) menuju chat dengan pemilik kos.

---

### US03: Mencari dan Memfilter Kos
*Sebagai Pencari Kos, saya ingin mencari berdasarkan teks area dan menyaring harga serta fasilitas, agar saya menemukan kos yang sesuai anggaran dan kebutuhan.*
- **US03-AC1 (Pencarian Teks Area Case-Insensitive):**  
  *Given* pencari berada di bilah pencarian  
  *When* pencari mengetik "singaraja" atau "Singaraja"  
  *Then* daftar kos yang ditampilkan hanya kos dengan nama atau area yang mengandung kata tersebut secara case-insensitive.
- **US03-AC2 (Filter Harga dan Fasilitas):**  
  *Given* pencari membuka panel filter  
  *When* mengatur harga maksimal Rp1.000.000 dan mencentang fasilitas "WiFi"  
  *Then* katalog hanya menampilkan kos dengan harga <= Rp1.000.000 yang memiliki fasilitas WiFi.
- **US03-AC3 (Hasil Pencarian / Filter Kosong):**  
  *Given* pencari memasukkan kata kunci atau kombinasi filter yang tidak cocok dengan kos mana pun  
  *When* pencarian/filter diterapkan  
  *Then* muncul pemberitahuan ("Tidak ada kos yang cocok dengan kriteria pencarian Anda").

---

### US04: Autentikasi Pemilik Kos
*Sebagai Pemilik Kos, saya ingin mendaftar dan masuk ke akun saya, agar saya dapat mengelola properti kos saya secara mandiri.*
- **US04-AC1 (Registrasi Akun Baru):**  
  *Given* pengguna berada di halaman pendaftaran  
  *When* memasukkan email valid dan password minimal 6 karakter lalu menekan "Daftar"  
  *Then* akun terbuat di Supabase Auth dan pengguna langsung diarahkan ke halaman pengelolaan kos.
- **US04-AC2 (Login Gagal dengan Kredensial Salah):**  
  *Given* pengguna berada di halaman login  
  *When* memasukkan kombinasi email atau password yang tidak terdaftar/salah  
  *Then* aplikasi menampilkan notifikasi error ("Email atau kata sandi salah") dan tidak berpindah halaman.
- **US04-AC3 (Logout):**  
  *Given* pemilik kos dalam keadaan login  
  *When* memilih tombol "Keluar / Logout"  
  *Then* sesi login dihapus dan pengguna diarahkan kembali ke halaman publik/login.

---

### US05: Menambah Kos Baru
*Sebagai Pemilik Kos, saya ingin menambahkan data kos baru beserta fasilitas dan nomor WhatsApp, agar kos saya terdaftar dan dapat dilihat calon penyewa.*
- **US05-AC1 (Tambah Kos Sukses):**  
  *Given* pemilik kos telah login dan berada di formulir tambah kos  
  *When* mengisi nama, alamat/area, harga (angka), tipe (Putra/Putri/Campur), periode sewa, URL gambar, nomor WhatsApp, jumlah kamar sisa, mencentang fasilitas, dan menekan "Simpan"  
  *Then* data kos tersimpan di database dengan `owner_id` pemilik saat ini dan langsung muncul di daftar kelolaan pemilik.
- **US05-AC2 (Validasi Form Input Wajib Kosong):**  
  *Given* pemilik berada di formulir tambah kos  
  *When* mengosongkan field wajib (seperti nama kos, harga, atau nomor WA) lalu menekan "Simpan"  
  *Then* form menampilkan pesan validasi merah pada field terkait dan data tidak dikirim ke backend.

---

### US06: Mengubah Data Kos dan Ketersediaan Kamar
*Sebagai Pemilik Kos, saya ingin memperbarui data kos dan sisa kamar, agar informasi kamar selalu akurat bagi pencari kos.*
- **US06-AC1 (Pembaruan Data Kos Milik Sendiri):**  
  *Given* pemilik kos sedang mengedit kos miliknya  
  *When* mengubah jumlah kamar tersisa menjadi 0 dan status menjadi "Penuh", lalu menekan "Simpan"  
  *Then* data berhasil diperbarui di database dan pada katalog publik status langsung berubah menjadi "Penuh".
- **US06-AC2 (Penolakan Akses Edit Kos Milik Pemilik Lain - RLS Backend):**  
  *Given* Pemilik B login ke aplikasi  
  *When* Pemilik B mencoba mengirim perintah update/delete pada kos milik Pemilik A  
  *Then* Supabase menolak eksekusi melalui Policy RLS (operasi gagal dengan pesan izin ditolak) dan data Pemilik A tidak mengalami perubahan.

---

### US07: Menghapus dan Menonaktifkan Kos
*Sebagai Pemilik Kos, saya ingin menonaktifkan sementara atau menghapus kos, agar kos yang tidak aktif tidak muncul di pencarian publik.*
- **US07-AC1 (Hapus Kos Sendiri):**  
  *Given* pemilik berada di daftar kelolaan kos miliknya  
  *When* memilih "Hapus", lalu mengonfirmasi dialog peringatan  
  *Then* data kos terhapus permanen dari database dan tidak lagi muncul di halaman publik maupun dashboard pemilik.
- **US07-AC2 (Toggle Nonaktifkan Kos Sementara):**  
  *Given* pemilik kos memiliki kos yang sedang direnovasi  
  *When* mengubah status aktif menjadi "Nonaktif"  
  *Then* kos tersebut tidak tampil di pencarian publik pencari kos, namun tetap tersimpan dan dapat diaktifkan kembali di dashboard pemilik.

---

## 6. Hal yang Masih Ambigu & Rencana Versi Berikutnya

1. **Ulasan & Rating (Review):**  
   - Pada jawaban klarifikasi disebutkan *"beri ulasan"*. Karena batasan tegas V1 di worksheet dan `ide.md` melarang ulasan & rating, fitur ini **ditunda ke Versi 2**. Tabel ulasan akan membutuhkan relasi dengan akun penyewa yang terverifikasi agar tidak terjadi ulasan palsu.
2. **Validasi URL Gambar:**  
   - Jika pemilik memasukkan link gambar yang salah/rusak, aplikasi akan menggunakan gambar fallback (*placeholder default*) lokal agar kartu kos tidak rusak.
