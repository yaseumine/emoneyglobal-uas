# Dompet Stardew

Dompet Stardew adalah aplikasi e-wallet berbasis Flutter untuk membantu pengguna melakukan pembayaran, transfer, top up, melihat riwayat transaksi, serta autentikasi akun dengan Firebase dan verifikasi keamanan lanjutan.

## Identitas Mahasiswa

Nama: Aulia Yasmin Maharani  
NIM: 1123150146  
Jurusan: Teknik Informatika Software Engineering

## Deskripsi Aplikasi

Aplikasi ini dikembangkan sebagai sistem dompet digital dengan tampilan bertema pink dan identitas aplikasi Dompet Stardew. Fitur utama yang tersedia meliputi login dan registrasi, autentikasi Firebase, verifikasi OTP/2FA, halaman beranda saldo, transfer, top up, pembayaran, simulasi pembayaran merchant, riwayat transaksi, serta halaman akun.

## Integrasi Deeplink dengan Catalog

Dompet Stardew mendukung integrasi deeplink untuk kebutuhan pembayaran dari aplikasi catalog/e-commerce. Pada alur ini, aplikasi catalog akan mengarahkan pengguna ke Dompet Stardew melalui link pembayaran, lalu Dompet Stardew menampilkan detail transaksi seperti merchant, nominal, deskripsi, dan referensi pembayaran.

Setelah pengguna mengonfirmasi pembayaran di Dompet Stardew, transaksi akan diproses melalui PIN dan mekanisme keamanan akun. Integrasi ini digunakan agar aplikasi catalog dapat memakai Dompet Stardew sebagai metode pembayaran digital.

## Fitur Utama

- Login menggunakan email dan Google.
- Registrasi akun dengan verifikasi OTP.
- Verifikasi keamanan menggunakan metode 2FA.
- Beranda saldo dan ringkasan transaksi.
- Top up saldo.
- Transfer saldo.
- Pembayaran menggunakan PIN.
- Simulasi pembayaran merchant/e-commerce.
- Riwayat transaksi.
- Halaman akun pengguna.
- Tema aplikasi pink dengan brand Dompet Stardew.

## Struktur Project

```text
lib/
|-- core/
|   |-- constants/        # Konstanta aplikasi dan endpoint API
|   |-- error/            # Exception dan failure handling
|   |-- network/          # Konfigurasi Dio API client
|   |-- router/           # Konfigurasi route aplikasi
|   |-- services/         # Service deeplink dan callback
|   |-- theme/            # Warna, typography, dan tema aplikasi
|   `-- utils/            # Helper formatter dan observer
|-- data/
|   |-- datasources/      # Data source lokal dan remote
|   |-- models/           # Model data
|   `-- repositories/     # Implementasi repository
|-- domain/
|   |-- entities/         # Entity domain
|   |-- repositories/     # Kontrak repository
|   `-- usecases/         # Use case aplikasi
|-- injection/            # Dependency injection
|-- presentation/
|   |-- blocs/            # State management BLoC
|   |-- pages/            # Halaman aplikasi
|   `-- widgets/          # Komponen UI reusable
`-- main.dart             # Entry point aplikasi
```

## Lampiran Screenshot

Bagian ini disediakan untuk lampiran screenshot aplikasi.

| No | Halaman | Screenshot |
| --- | --- | --- |
| 1 | Splash Screen |  |
| 2 | Login |  |
| 3 | Register |  |
| 4 | Home |  |
| 5 | Top Up |  |
| 6 | Transfer |  |
| 7 | Payment |  |
| 8 | History |  |
| 9 | Account |  |
| 10 | Deeplink dari Catalog |  |

## Link Video YouTube

Link demo aplikasi:

## Repository Terkait

Repository aplikasi catalog/e-commerce yang terhubung dengan Dompet Stardew melalui deeplink:
[yaseumine/UAS-CATALOG.git](https://github.com/yaseumine/UAS-CATALOG.git)

## Teknologi yang Digunakan

- Flutter
- Dart
- Firebase Authentication
- Firebase Core
- Dio
- Flutter BLoC
- Go Router
- Shared Preferences
- Flutter Secure Storage
