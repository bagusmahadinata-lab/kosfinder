# Test Plan & Hasil Uji Terima: KosFinder

**Dokumen:** `docs/test-plan.md`  
**Acuan:** `docs/PRD.md` (US01 – US07, NFR01 – NFR05)  
**Penguji / Software Engineer:** Dewa Putu Bagus Mahadinata (NIM: 2415051023)  
**Target Platform:** Android (Flutter) & Backend Supabase  

---

## 1. Ringkasan Pengujian

Pengujian dilakukan untuk memverifikasi seluruh Acceptance Criteria (AC) pada setiap User Story (US01–US07) dan Non-Functional Requirements (NFR), mencakup skenario positif maupun skenario negatif (tanpa internet, hasil kosong, input tidak valid, dan penolakan RLS backend).

- **Total Skenario Uji:** 16 Skenario
- **Hasil:** 16 Lulus / 0 Gagal (100% Lulus)

---

## 2. Tabel Rencana & Hasil Uji Terima

| ID Uji | AC Terkait | Skenario & Langkah Pengujian | Hasil yang Diharapkan | Hasil Nyata | Status |
|:---:|:---:|---|---|---|:---:|
| **TC01** | US01-AC1 | Buka aplikasi dalam kondisi online tanpa login. | Daftar kos publik tampil memuat nama, tipe, harga, sisa kamar, dan gambar. | Daftar kos berhasil dimuat dari database Supabase dengan kartu rapi. | **Lulus** |
| **TC02** | US01-AC2 | Matikan koneksi internet (Airplane mode), lalu buka aplikasi / pull-to-refresh. | Muncul tampilan peringatan tidak ada internet dan tombol "Coba Lagi" tanpa crash. | Tampil ikon wifi mati, pesan offline ramah, dan tombol "Coba Lagi". Tidak ada force close. | **Lulus** |
| **TC03** | US01-AC3 | Buka aplikasi saat tabel database `kos` belum memiliki data sama sekali. | Muncul tampilan data kosong dengan pesan informatif. | Tampil ilustrasi/pesan "Belum ada kos yang tersedia saat ini". | **Lulus** |
| **TC04** | US02-AC1 | Klik salah satu kartu kos di katalog publik. | Halaman detail terbuka memuat alamat, tipe, harga, sisa kamar, dan daftar fasilitas. | Halaman detail terbuka lengkap dengan seluruh informasi properti. | **Lulus** |
| **TC05** | US02-AC2 | Klik tombol "Hubungi via WhatsApp" pada halaman detail kos. | Aplikasi mengarahkan ke link WhatsApp resmi `https://wa.me/<nomor>` dengan nomor pemilik. | Membuka aplikasi WhatsApp langsung ke ruang obrolan nomor pemilik kos. | **Lulus** |
| **TC06** | US03-AC1 | Ketik "singaraja" dan "Singaraja" di kolom pencarian. | Hasil pencarian teks bersifat *case-insensitive* dan menampilkan hasil yang sama. | Kedua kata kunci menghasilkan daftar kos yang identik di area Singaraja. | **Lulus** |
| **TC07** | US03-AC2 | Buka filter, atur harga maksimal Rp1.000.000 dan centang fasilitas "WiFi". | Hanya kos dengan harga <= Rp1.000.000 yang memiliki fasilitas WiFi yang tampil. | Kos yang berharga di atas 1 juta atau tanpa WiFi otomatis tersaring keluar. | **Lulus** |
| **TC08** | US03-AC3 | Masukkan kata kunci pencarian yang tidak ada (misal: "xyz999area"). | Muncul pesan bahwa tidak ada kos yang cocok dengan kriteria pencarian. | Tampil pesan "Tidak ada kos yang cocok dengan kriteria pencarian Anda". | **Lulus** |
| **TC09** | US04-AC1 | Buka "Area Pemilik", klik "Daftar", isi email baru dan password >= 6 karakter. | Akun terdaftar di Supabase Auth dan otomatis diarahkan ke Dashboard Pemilik. | Akun baru berhasil dibuat di Supabase Auth dan masuk ke dashboard pemilik. | **Lulus** |
| **TC10** | US04-AC2 | Di halaman login, masukkan email atau kata sandi yang salah. | Muncul notifikasi error "Email atau kata sandi salah" dan tetap di halaman login. | Muncul snackbar merah error kredensial salah, login ditolak. | **Lulus** |
| **TC11** | US04-AC3 | Di Dashboard Pemilik, tekan tombol "Keluar / Logout". | Sesi login terhapus dan pengguna dikembalikan ke halaman katalog publik. | Sesi auth terhapus, kembali ke tampilan publik; menu pemilik tertutup. | **Lulus** |
| **TC12** | US05-AC1 | Login pemilik, klik Tambah Kos, isi seluruh field valid, klik Simpan. | Kos tersimpan ke Supabase dengan `owner_id` pemilik dan tampil di dashboard. | Kos baru berhasil tersimpan dan langsung muncul di daftar kelolaan pemilik. | **Lulus** |
| **TC13** | US05-AC2 | Di formulir Tambah Kos, kosongkan field wajib lalu tekan Simpan. | Validasi form muncul berwarna merah pada field wajib, data tidak dikirim. | Pesan validasi merah muncul di nama, harga, dan nomor WA; submit dibatalkan. | **Lulus** |
| **TC14** | US06-AC1 | Edit kos milik sendiri, ubah sisa kamar menjadi 0, lalu simpan. | Data terupdate dan status kos di katalog publik otomatis menjadi "PENUH". | Di katalog publik dan detail kos, badge otomatis berubah merah "PENUH". | **Lulus** |
| **TC15** | US06-AC2 & NFR01 | Login sebagai Pemilik B, lalu coba memodifikasi/menghapus data kos milik Pemilik A. | Supabase RLS menolak akses (PostgrestException 403 / policy violation). | Operasi ditolak oleh RLS Supabase; data Pemilik A tetap aman dan tidak berubah. | **Lulus** |
| **TC16** | US07-AC1 & US07-AC2 | Uji tombol toggle switch nonaktif dan tombol Hapus (dengan dialog konfirmasi). | Kos nonaktif hilang dari publik tapi ada di dashboard; kos hapus hilang permanen. | Toggle nonaktif menyembunyikan kos dari katalog publik; hapus permanen berhasil setelah konfirmasi. | **Lulus** |

---

## 3. Verifikasi Identitas Pengembang (DoD Wajib)
- **Halaman About:** Memuat teks identitas pengembang:
  ```
  2415051023 - Dewa Putu Bagus Mahadinata
  Universitas Pendidikan Ganesha
  ```
- **Status:** **Terverifikasi Lulus** (diuji via unit/widget test dan tampilan aplikasi).
