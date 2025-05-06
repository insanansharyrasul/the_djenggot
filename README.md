<h1 align="center">
  <img src="docs/images/app_icon2.png" alt="App Icon" width="100" height="100" align="center">
 &nbsp TheDjenggot
</h1>

Proyek ini merupakan tugas mata kuliah Rekayasa Perangkat Lunak (RPL)
di semester 4, Institut Pertanian Bogor (IPB).

## Team Members

| Name                            | NIM         |
| ------------------------------- | ----------- |
| Ludwig Alven Tama Lumban Tobing | G6401231006 |
| Kivi Adelio                     | G6401231047 |
| Jofattan Faiz Betryan           | G6401231066 |
| Jason Bagaskara Mulyono         | G6401231088 |
| Insan Anshary Rasul             | G6401231132 |

## Overview

Proyek ini adalah aplikasi kasir yang dirancang untuk membantu warung makan mencatat
hasil penjualan dan mengelola stok barang. Setiap kali pelanggan membayar, transaksi
akan dicatat oleh aplikasi. Selain itu, aplikasi ini juga memungkinkan pengguna untuk
menambah atau mengurangi data stok sesuai kebutuhan. Terakhir, aplikasi juga menerima
pencatatan pesanan dari WhatsApp.

## Features

- **Pencatatan Penjualan**: Mencatat setiap transaksi penjualan yang dilakukan oleh pelanggan.
- **Manajemen Stok**: Menyimpan data stok barang dan memungkinkan penambahan atau pengurangan stok sesuai kebutuhan.
- **Menerima pesanan**: Menerima pesanan melalui WhatsApp yang akan muncul sebagai notifikasi
dari aplikasi dan mencatatnya di aplikasi.
- **Analisis Keuangan**: Melihat laporan keuntungan dan kerugian untuk membantu pengelolaan keuangan.
- **UI yang Responsif**: Antarmuka pengguna yang mudah digunakan dan ramah pengguna.

## Tech Stack

- **Framework**: Flutter 3.29.2
- **State Management**: Flutter Bloc (v9.1.0)
- **Database**: SQLite (sqflite v2.4.2)
- **Navigation**: GoRouter (v14.8.1)
- **Charts & Visualization**: FL Chart (v0.64.0)
- **UI Components**: Custom widgets with Lexend font family

## Prerequisites

- Flutter SDK: 3.29.2
- Dart: 3.7.2
- Android Studio / VS Code with Flutter plugins

## Installation

1. **Clone the repository**:
   ```sh
   git clone <repository-url>
   cd the_djenggot
   ```

2. **Install dependencies** 
    ```sh
    flutter pub get
    ```

3. **Run the app**
    ```sh
    flutter run
    ```

## Project Structure

```
lib/
  ├── bloc/            # State management with Flutter Bloc
  ├── database/        # Local database operations with SQLite
  ├── models/          # Data models for the application
  ├── repository/      # Repository pattern implementation
  ├── routing/         # App navigation with GoRouter
  ├── screens/         # UI screens of the application
  ├── utils/           # Helper functions and utilities
  ├── widgets/         # Reusable UI components
  └── main.dart        # Entry point of the application
```

## Dependencies

- **State Management**: flutter_bloc
- **Navigation**: go_router
- **Database**: sqflite
- **UI Components**: flutter_speed_dial, iconsax
- **Data Handling**: equatable, intl, uuid
- **File Operations**: image_picker, path_provider
- **Visualization**: fl_chart
- **External Communication**: url_launcher, share_plus

## Development Mode

The application includes dummy images for development. To use them, ensure this line is uncommented in pubspec.yaml:
```yaml
# Comment this if you want release mode
- assets/dummy_images/
```

## Contact

For questions or feedback, please contact the project maintainers.

---

© 2025 TheDjenggot Team | Made with ❤️ at Institut Pertanian Bogor
