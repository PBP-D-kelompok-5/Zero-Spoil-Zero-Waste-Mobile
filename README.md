# 🧟‍♂️ Pantry Necromancer Mobile

> Aplikasi mobile Flutter dari situs web **Pantry Necromancer** untuk Proyek Akhir Semester
> Pemrograman Berbasis Platform (CSGE602022), Fakultas Ilmu Komputer, Universitas Indonesia,
> Semester Gasal 2026/2027. Kelas PBP D, Kelompok 5.

## 🔗 Tautan

| | |
|---|---|
| Unduh APK | _menyusul setelah Checkpoint 1_ |
| Desain aplikasi mobile (Figma) | _menyusul_ |
| Design system situs (Figma, acuan tema) | https://www.figma.com/design/CSdxa6zQOO9W5WI4mnlaJF/Pantry-Necromancer-%E2%80%94-Design-System |
| Situs web (PWS) | https://michael-evan51-pantry-necromancer.pws.cs.ui.ac.id/ |
| Repositori situs web Django + API DRF | https://github.com/PBP-D-kelompok-5/Zero-Spoil-Zero-Waste |

## 👥 Anggota Kelompok dan Pembagian Modul

| Nama | NPM | Modul | Folder Flutter | App Django |
|---|---|---|---|---|
| Michael Evan Putra Nugroho | 2506616674 | Modul 1: Pantry Death Clock | `lib/modules/death_clock/` | `death_clock` |
| Nuno Mikael Nugroho | 2506624865 | Modul 2: Recipe Alchemist | `lib/modules/recipe_alchemist/` | `recipe_alchemist` |
| Joshua Carnsyn Suyanto Sidik | 2506593821 | Modul 3: The Dead Drop | `lib/modules/dead_drop/` | `dead_drop` |
| Adam Wahyu Syaputra | 2506534964 | Modul 4: The Graveyard & Waste Analytics | `lib/modules/graveyard/` | `graveyard` |
| Muhammad Syarifudin | 2506657112 | Modul 5: Preservation Grimoire & Smell Test | `lib/modules/grimoire/` | `preservation_grimoire` |

Setiap anggota membangun endpoint DRF modulnya di repo Django, lalu halaman Flutter yang
memakai endpoint itu di folder modulnya sendiri di repo ini. Kerangka bersama (tema, klien HTTP,
login, navigasi, dan README) dikerjakan oleh Michael Evan.

## 📖 Deskripsi Aplikasi

Limbah makanan rumah tangga menyumbang porsi besar sampah makanan dunia. Mahasiswa dan perantau
di kost termasuk kelompok yang rentan: belanja tidak terencana, jadwal padat, dan bahan di kulkas
bersama sering membusuk tanpa disadari.

**Pantry Necromancer** membantu menyelamatkan bahan makanan sebelum terbuang, lewat pemantauan
masa kedaluwarsa ("Death Clock"), resep dari sisa bahan, berbagi surplus dengan tetangga kost,
pencatatan limbah, dan panduan pengawetan. Aplikasi mobile ini memakai data dan akun yang
**sama persis** dengan situs web, jadi perubahan di aplikasi langsung terlihat di situs dan sebaliknya.

## 🧩 Modul

| Modul | Fungsi di aplikasi |
|---|---|
| **Pantry Death Clock** | Inventaris bahan pribadi dengan status Stable, Critical, dan Flatlining serta hitung mundur kedaluwarsa. |
| **Recipe Alchemist** | Koleksi resep pribadi, resep komunitas, dan pencarian resep dari bahan lewat Spoonacular. |
| **The Dead Drop** | Papan berbagi surplus bahan dengan status available, reserved, dan claimed, lengkap dengan lokasi. |
| **The Graveyard & Waste Analytics** | Pencatatan bahan yang terbuang dengan estimasi berat, kerugian rupiah, dan jejak karbon. |
| **Preservation Grimoire & Smell Test** | Wiki teknik pengawetan dan indikator bau, tekstur, serta visual bahan yang tidak layak. |

## 🎭 Peran Pengguna

- **Tamu (belum login):** membaca konten publik, yaitu panduan Grimoire, resep komunitas, dan
  listing Dead Drop. Modul privat menampilkan ajakan untuk masuk.
- **Pengguna terdaftar:** mengelola inventaris, resep, listing, dan catatan limbah miliknya sendiri,
  memesan (reserve) dan mengambil (claim) listing pengguna lain, serta memberi upvote panduan.
  Akunnya sama dengan akun situs web.

## 🔄 Alur Integrasi Data dengan Situs Web (PWS)

```
Aplikasi Flutter ──HTTP/JSON──▶ Django REST Framework (/api/...) ──▶ Model Django ──▶ Database PWS
       ▲                                                                                  │
       └───────────────────────────── JSON ◀──────────────────────────────────────────────┘
```

1. Pengguna login lewat `POST /api/auth/login/`. Django membuat **session** yang sama dengan login
   di situs web. `ApiClient` menyimpan cookie `sessionid` dan token CSRF dari respons.
2. Setiap halaman modul memanggil endpoint DRF modulnya secara asinkron
   (`await context.read<ApiClient>().get('/api/<modul>/...')`), dengan cookie session terlampir.
3. Di Django, **serializer** DRF memvalidasi input dan mengubah data model menjadi JSON. Data privat
   difilter berdasarkan pengguna yang login, jadi data milik orang lain dibalas 404 atau 403.
4. Flutter mem-parsing JSON ke **model Dart** (`fromJson`) lalu menampilkannya dengan widget.
5. Request yang mengubah data (POST/PUT/PATCH/DELETE) membawa header `X-CSRFToken` dan `Origin`,
   sesuai syarat `SessionAuthentication` DRF. `ApiClient` menambahkannya otomatis.
6. Karena aplikasi dan situs memakai database yang sama di PWS, data yang diubah di aplikasi
   langsung muncul di situs web, dan sebaliknya.

Panduan lengkap API ada di
[`docs/API_MOBILE.md`](https://github.com/PBP-D-kelompok-5/Zero-Spoil-Zero-Waste/blob/main/docs/API_MOBILE.md)
di repo Django.

### Endpoint Django REST Framework

Base URL: `https://michael-evan51-pantry-necromancer.pws.cs.ui.ac.id`

| Modul | Endpoint (Checkpoint 1) | Fungsi |
|---|---|---|
| Auth | `POST /api/auth/login/` | Login, membuat session |
| Auth | `POST /api/auth/register/` | Daftar akun |
| Auth | `POST /api/auth/logout/` | Logout |
| Auth | `GET /api/auth/me/` | Status login saat ini |
| Auth | `GET /api/auth/csrf/` | Token CSRF untuk request tulis |
| Death Clock | `GET /api/death-clock/items/`, `GET /api/death-clock/items/{id}/` | Daftar dan detail bahan milik pengguna |
| Recipe Alchemist | `GET /api/recipes/?scope=mine\|community`, `GET /api/recipes/{id}/` | Daftar dan detail resep |
| Dead Drop | `GET /api/dead-drop/listings/?status=`, `GET /api/dead-drop/listings/{id}/` | Daftar dan detail listing |
| Graveyard | `GET /api/graveyard/items/`, `GET /api/graveyard/items/{id}/` | Riwayat dan detail catatan limbah |
| Grimoire | `GET /api/grimoire/guides/`, `GET /api/grimoire/guides/{id}/` | Daftar dan detail panduan |

Endpoint tambah, ubah, hapus, dan aksi khusus setiap modul ditambahkan untuk pengumpulan akhir.

## 🗂️ Struktur Proyek

```
lib/
├── main.dart                  # Provider ApiClient, tema, cek session saat start
├── core/
│   ├── api_client.dart        # Klien HTTP bersama: session, CSRF, error JSON
│   └── config.dart            # BASE_URL server
├── theme/app_theme.dart       # Tema Almanak Grimoire (Malam/Siang), selaras dengan situs
├── models/app_user.dart
├── screens/                   # Login, daftar, kerangka navigasi, beranda, akun
├── widgets/                   # Drawer, placeholder modul, ajakan login
└── modules/
    ├── module_registry.dart   # Daftar modul untuk drawer dan beranda
    ├── death_clock/           # Michael Evan
    ├── recipe_alchemist/      # Nuno
    ├── dead_drop/             # Joshua
    ├── graveyard/             # Adam
    └── grimoire/              # Syarif
```

Navigasi: **bottom navigation** untuk Beranda dan Akun, **drawer** untuk kelima modul.

### Panduan untuk anggota

1. Kerjakan hanya di `lib/modules/<modulmu>/`: halaman di `<modul>_screen.dart`,
   model Dart di `models/`, widget tambahan di `widgets/`.
2. Ambil data dengan klien bersama:

   ```dart
   final api = context.read<ApiClient>();
   final data = await api.get('/api/grimoire/guides/', query: {'q': keyword});
   final guides = (data as List).map((item) => Guide.fromJson(item)).toList();
   ```

   Error dari server dilempar sebagai `ApiException` (`message`, `fieldError('nama_field')`).
3. Warna aksen modul ada di `PnPalette.of(context)` (`ecto`, `ember`, `blood`, `hex`, `frost`).
4. Commit dari akun GitHub masing-masing.

## ▶️ Menjalankan Aplikasi

```bash
flutter pub get
flutter run                                              # memakai server PWS
flutter run --dart-define=BASE_URL=http://10.0.2.2:8000  # Django lokal dari emulator Android
flutter run -d chrome --web-port 5000 --dart-define=BASE_URL=http://localhost:8000  # Flutter web
flutter test
```

Untuk Flutter web, port **5000** wajib dipakai karena hanya origin itu yang diizinkan CORS di Django.
