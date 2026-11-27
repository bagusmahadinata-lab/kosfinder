# ARSITEKTUR APLIKASI: KOSFINDER

**Dokumen:** `docs/ARCHITECTURE.md`  
**Acuan:** `docs/PRD.md` dan `AGENTS.md`  
**Pola Desain:** Screen – Provider – Repository – Supabase  

---

## 1. Komponen Aplikasi & Tanggung Jawab

Arsitektur KosFinder menggunakan pola berlapis (*layered architecture*) yang sederhana dan mudah diuji:

```
[ Screen (UI) ] <---> [ Provider (State) ] <---> [ Repository (Data) ] <---> [ Supabase SDK / RLS ]
```

1. **Screen / View (UI Layer):**
   - Menampilkan antarmuka Material Design untuk pencari dan pemilik kos.
   - Menerima interaksi pengguna dan mendengarkan perubahan state dari Provider via `Consumer` / `context.watch`.
   - *Terkait:* Seluruh story US01 – US07.
2. **Provider (State Management Layer):**
   - Menggunakan `ChangeNotifier` bawaan package `provider`.
   - Mengelola state loading, pesan error, daftar kos, filter aktif, dan sesi pengguna (auth).
   - Memanggil fungsi pada Repository dan memberi tahu widget via `notifyListeners()`.
   - *Terkait:* Seluruh story US01 – US07.
3. **Repository (Data Access Layer):**
   - Mengisolasi pemanggilan Supabase SDK (`supabase_flutter`).
   - Melakukan serialisasi/deserialisasi antara JSON Supabase dan Model Dart (`KosModel`).
   - Menangani error jaringan atau database dan mengubahnya menjadi pesan error ramah pengguna.
   - *Terkait:* Seluruh story US01 – US07.
4. **Supabase Client (Backend Layer):**
   - Mengelola koneksi jaringan, otentikasi sesi JWT, dan query PostgreSQL.
   - Penegakan otorisasi data dilakukan langsung di PostgreSQL melalui **Row Level Security (RLS)**.

---

## 2. Daftar Layar & Alur Navigasi

```
[HomeScreen (Katalog & Filter)]  ----(tap kos)---->  [KosDetailScreen (Detail & Tombol WA)]
         |                                                       |
   (menu pemilik)                                           (tombol wa)
         |                                                       v
  [LoginScreen / RegisterScreen]                          [Aplikasi WhatsApp]
         |
   (setelah login)
         v
[OwnerDashboardScreen (Kelola Kos Milik Sendiri)]
   |                      |
(tambah kos)         (edit kos)
   v                      v
[KosFormScreen]      [KosFormScreen]

[AboutScreen] -> Menampilkan identitas: 2415051023 - Dewa Putu Bagus Mahadinata
```

- **`HomeScreen`:** Katalog publik kos, search bar area, panel filter harga dan fasilitas (US01, US03).
- **`KosDetailScreen`:** Informasi mendetail kos, foto URL, fasilitas, sisa kamar, dan tombol "Hubungi via WhatsApp" via `url_launcher` (US02).
- **`LoginScreen` & `RegisterScreen`:** Form masuk/daftar bagi pemilik kos via Supabase Auth (US04).
- **`OwnerDashboardScreen`:** Daftar kos milik pemilik yang sedang login, toggle aktif/nonaktif, dan tombol aksi edit/hapus (US05, US06, US07).
- **`KosFormScreen`:** Formulir input tambah/ubah kos dengan validasi lengkap (US05, US06).
- **`AboutScreen`:** Informasi pengembang aplikasi (`2415051023 - Dewa Putu Bagus Mahadinata`).

---

## 3. Rencana Database & Aturan Akses (RLS)

### Tabel: `kos`
| Kolom | Tipe Data | Keterangan & Relasi |
|---|---|---|
| `id` | `uuid` (PK) | Default `gen_random_uuid()` |
| `owner_id` | `uuid` (FK) | Relasi ke `auth.users(id)` ON DELETE CASCADE |
| `name` | `text` (NOT NULL) | Nama properti kos |
| `address` | `text` (NOT NULL) | Alamat lengkap kos |
| `area` | `text` (NOT NULL) | Nama area/kampus untuk pencarian teks |
| `price` | `numeric` (NOT NULL) | Harga sewa kos (**bertipe angka**) |
| `rental_period` | `text` (NOT NULL) | Periode sewa: `'monthly'` atau `'yearly'` |
| `type` | `text` (NOT NULL) | Tipe kos: `'putra'`, `'putri'`, atau `'campur'` |
| `image_url` | `text` | URL foto kos eksternal (fallback placeholder jika kosong) |
| `whatsapp_number`| `text` (NOT NULL) | Nomor WhatsApp pemilik untuk dihubungi |
| `facilities` | `text[]` (NOT NULL) | Array daftar fasilitas (misal: WiFi, AC, Kamar Mandi Dalam) |
| `total_rooms` | `integer` (NOT NULL)| Total seluruh kamar |
| `available_rooms`| `integer` (NOT NULL)| Jumlah kamar tersisa (0 = penuh) |
| `is_available` | `boolean` (NOT NULL)| Status ketersediaan (default `true`) |
| `is_active` | `boolean` (NOT NULL)| Toggle aktif/nonaktif oleh pemilik (default `true`) |
| `created_at` | `timestamptz` | Default `now()` |
| `updated_at` | `timestamptz` | Default `now()` |

### Aturan Akses (Row Level Security):
- **SELECT (Membaca):** Publik (anon & authenticated) dapat membaca semua data yang berstatus `is_active = true`. Pemilik kos yang login juga dapat melihat kos miliknya sendiri meskipun `is_active = false`.
- **INSERT (Menambah):** Hanya pengguna yang telah login (`authenticated`) dan nilai `owner_id` wajib sama dengan ID user login (`auth.uid() = owner_id`).
- **UPDATE (Mengubah):** Hanya pengguna yang login dan merupakan pemilik sah (`auth.uid() = owner_id`).
- **DELETE (Menghapus):** Hanya pengguna yang login dan merupakan pemilik sah (`auth.uid() = owner_id`).

---

## 4. Cara Konfigurasi

Kredensial Supabase dibaca secara dinamis saat kompilasi menggunakan `--dart-define`:
```dart
// lib/core/config/app_config.dart
class AppConfig {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
}
```
**Larangan:** Tidak ada penulisan URL, password, atau key sensitif (`service_role`) di berkas kode sumber repository.

---

## 5. Cara Rilis

1. Menjalankan verifikasi akhir: `flutter analyze` dan `flutter test`.
2. Melakukan build APK release:
   ```bash
   flutter build apk --release --dart-define=SUPABASE_URL=<URL> --dart-define=SUPABASE_ANON_KEY=<ANON_KEY>
   ```
3. Membuat Git Tag `v0.1.0` dan push ke GitHub.
4. Mengunggah berkas `app-release.apk` dari direktori `build/app/outputs/flutter-apk/` ke halaman GitHub Releases.

---

## 6. Package yang Dibutuhkan & Alasannya

Untuk menjaga aplikasi tetap ringan dan terhindar dari ketergantungan yang tidak perlu, hanya 4 package tambahan yang digunakan:

1. **`supabase_flutter`:** SDK resmi Supabase untuk otentikasi pemilik kos dan operasi database PostgreSQL ber-RLS (US01 s.d. US07).
2. **`provider`:** State management resmi rekomendasi Flutter untuk memisahkan UI dan business logic secara efisien (US01 s.d. US07).
3. **`url_launcher`:** Membuka tautan WhatsApp (`https://wa.me/...`) langsung ke aplikasi WhatsApp di HP pengguna (US02-AC2).
4. **`intl`:** Melakukan format mata uang Rupiah (`Rp1.500.000`) pada harga kos secara terstandarisasi (US01, US02, US03).
