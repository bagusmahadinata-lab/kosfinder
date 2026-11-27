# DAFTAR TASK PENGEMBANGAN: KOSFINDER

**Dokumen:** `docs/TASKS.md`  
**Acuan:** `docs/PRD.md`, `docs/ARCHITECTURE.md`, `AGENTS.md`  
**Aturan Kerja:** Kerjakan hanya satu task per permintaan. Hanya ubah file yang terdaftar pada task aktif. Lulus `flutter analyze` dan `flutter test` sebelum commit.

---

## Ringkasan Vertical Slice

| Slice | Deskripsi | Target Hasil yang Bisa Dijalankan |
|---|---|---|
| **Slice 1** | Katalog & Detail Kos (Publik) | Aplikasi menampilkan daftar kos dari Supabase, buka detail, tombol WhatsApp, dan info About. |
| **Slice 2** | Pencarian & Filter | Pencari dapat mencari teks area (*case-insensitive*) dan memfilter harga serta fasilitas. |
| **Slice 3** | Login Pemilik | Registrasi, login, dan logout pemilik kos via Supabase Auth tanpa mengganggu akses publik. |
| **Slice 4** | Kelola Kos Milik Sendiri (CRUD & RLS) | Pemilik dapat menambah, mengubah, menonaktifkan, dan menghapus kos miliknya dengan proteksi RLS backend. |
| **Slice 5 (Bonus)** | Ketersediaan Kamar | Pembaruan instan ketersediaan kamar (sisa kamar 0 otomatis menampilkan status "Penuh"). |

---

## Rincian Task Per Vertical Slice

### Slice 1: Katalog & Detail Kos (Publik)
| ID | Tujuan | Story & AC Terkait | Berkas yang Boleh Diubah | Cara Menguji | Status |
|---|---|---|---|---|---|
| **T01** | Setup dependencies, konfigurasi Supabase Client via `--dart-define`, dan Model Data Kos | NFR02, US01-AC1 | `pubspec.yaml`, `lib/core/config/app_config.dart`, `lib/models/kos_model.dart`, `lib/repositories/kos_repository.dart`, `test/models/kos_model_test.dart` | Jalankan unit test model; verifikasi parsing JSON dan fallback nilai default berhasil. | Selesai |
| **T02** | Menampilkan daftar katalog kos publik dengan penanganan koneksi gagal & data kosong | US01-AC1, US01-AC2, US01-AC3, NFR03, NFR04 | `lib/providers/kos_provider.dart`, `lib/screens/home_screen.dart`, `lib/widgets/kos_card.dart`, `lib/main.dart`, `test/providers/kos_provider_test.dart` | Jalankan aplikasi di HP/emulator; daftar kos tampil dari Supabase; matikan internet untuk verifikasi pesan error dan tombol reload tanpa crash. | Selesai |
| **T03** | Menampilkan detail lengkap kos, aksi Hubungi WhatsApp, dan Halaman About | US02-AC1, US02-AC2, DoD Identitas | `lib/screens/kos_detail_screen.dart`, `lib/screens/about_screen.dart`, `test/screens/kos_detail_screen_test.dart` | Tap salah satu kos; buka detail; tekan tombol WA (membuka link `wa.me`); buka layar About dan periksa identitas: `2415051023 - Dewa Putu Bagus Mahadinata`. | Selesai |

### Slice 2: Pencarian dan Filter
| ID | Tujuan | Story & AC Terkait | Berkas yang Boleh Diubah | Cara Menguji | Status |
|---|---|---|---|---|---|
| **T04** | Pencarian kos berdasarkan teks area secara case-insensitive | US03-AC1, US03-AC3 | `lib/providers/kos_provider.dart`, `lib/screens/home_screen.dart`, `test/providers/kos_search_test.dart` | Ketik "singaraja" dan "Singaraja" di search bar; hasil identik; ketik teks acak untuk memverifikasi tampilan pesan data kosong. | Selesai |
| **T05** | Filter rentang harga maksimum dan checklist fasilitas | US03-AC2, US03-AC3 | `lib/providers/kos_provider.dart`, `lib/widgets/filter_dialog.dart`, `lib/screens/home_screen.dart`, `test/providers/kos_filter_test.dart` | Atur harga maksimum Rp1.000.000 dan centang "WiFi"; verifikasi hanya kos yang memenuhi kedua kriteria yang ditampilkan. | Selesai |

### Slice 3: Login Pemilik
| ID | Tujuan | Story & AC Terkait | Berkas yang Boleh Diubah | Cara Menguji | Status |
|---|---|---|---|---|---|
| **T06** | Otentikasi Pemilik Kos (Daftar, Masuk, Keluar) via Supabase Auth | US04-AC1, US04-AC2, US04-AC3, NFR05 | `lib/repositories/auth_repository.dart`, `lib/providers/auth_provider.dart`, `lib/screens/login_screen.dart`, `lib/screens/register_screen.dart`, `test/providers/auth_provider_test.dart` | Uji daftar akun baru; coba login dengan sandi salah (pesan error muncul); login dengan benar; logout; pencari tetap dapat melihat kos tanpa login. | Selesai |

### Slice 4: Kelola Kos Milik Sendiri (CRUD & RLS)
| ID | Tujuan | Story & AC Terkait | Berkas yang Boleh Diubah | Cara Menguji | Status |
|---|---|---|---|---|---|
| **T07** | Menambah kos baru oleh pemilik terotentikasi dengan validasi formulir | US05-AC1, US05-AC2 | `lib/screens/owner_dashboard_screen.dart`, `lib/screens/kos_form_screen.dart`, `lib/repositories/kos_repository.dart`, `lib/providers/kos_provider.dart`, `test/screens/kos_form_test.dart` | Login sebagai pemilik; buka dashboard; tambah kos dengan form kosong (validasi muncul); isi lengkap lalu simpan; kos baru tampil di daftar. | Pending |
| **T08** | Mengubah data kos milik sendiri dan verifikasi penolakan RLS untuk pemilik lain | US06-AC1, US06-AC2, NFR01 | `lib/screens/kos_form_screen.dart`, `lib/repositories/kos_repository.dart`, `lib/providers/kos_provider.dart`, `test/repositories/kos_repository_test.dart` | Edit kos milik sendiri dan simpan; login dengan akun Pemilik B lalu coba modifikasi data Pemilik A (verifikasi backend RLS menolak akses). | Pending |
| **T09** | Menghapus permanen dan toggle nonaktif sementara kos milik sendiri | US07-AC1, US07-AC2 | `lib/screens/owner_dashboard_screen.dart`, `lib/repositories/kos_repository.dart`, `lib/providers/kos_provider.dart` | Ubah toggle kos menjadi nonaktif (hilang dari katalog publik tapi tetap ada di dashboard); hapus kos dengan konfirmasi dialog. | Pending |

### Slice 5 (Bonus): Ketersediaan Kamar
| ID | Tujuan | Story & AC Terkait | Berkas yang Boleh Diubah | Cara Menguji | Status |
|---|---|---|---|---|---|
| **T10** | Pembaruan ketersediaan kamar dinamis dan label "Penuh" otomatis | US06-AC1 (Bonus) | `lib/screens/kos_form_screen.dart`, `lib/widgets/kos_card.dart`, `lib/screens/kos_detail_screen.dart`, `lib/providers/kos_provider.dart` | Ubah sisa kamar menjadi 0; periksa katalog dan detail kos langsung menampilkan badge "Penuh". | Pending |
