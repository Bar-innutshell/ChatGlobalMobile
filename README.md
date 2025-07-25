# Chat App Flutter

Aplikasi chat real-time yang dibangun dengan Flutter dan Firebase.

## 🚀 Setup untuk Development

### Prerequisites
- Flutter SDK (versi terbaru)
- Android Studio / VS Code
- Firebase account

### Langkah Setup:

1. **Clone Repository**
   ```bash
   git clone <repo-url>
   cd uas
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```


3. **Setup Environment Variables (.env) untuk Firebase**
   
   a. Buat project baru di [Firebase Console](https://console.firebase.google.com/)
   
   b. Enable Authentication (Email/Password)
   
   c. Enable Firestore Database
   
   d. Install package flutter_dotenv di pubspec.yaml:
   ```yaml
   dependencies:
     flutter_dotenv: ^5.1.0
   ```

   e. Copy file `.env.example` ke `.env` dan isi dengan konfigurasi Firebase Anda:
   ```env
   FIREBASE_API_KEY_WEB=isi_api_key_web_anda
   FIREBASE_APP_ID_WEB=isi_app_id_web_anda
   FIREBASE_MESSAGING_SENDER_ID=isi_sender_id_anda
   FIREBASE_PROJECT_ID=isi_project_id_anda
   FIREBASE_AUTH_DOMAIN=isi_auth_domain_anda
   FIREBASE_STORAGE_BUCKET=isi_storage_bucket_anda
   FIREBASE_MEASUREMENT_ID_WEB=isi_measurement_id_web_anda
   # dst untuk android, ios, windows
   ```

   f. Tambahkan `.env` ke `.gitignore` agar tidak ter-push ke repo:
   ```ignore
   .env
   ```

   g. Pastikan file `firebase_options.dart` sudah membaca konfigurasi dari `.env` menggunakan `flutter_dotenv` (lihat contoh di repo).

4. **Setup Android (Opsional)**
   - Download `google-services.json` dari Firebase Console
   - Letakkan di `android/app/google-services.json`

5. **Run Application**
   ```bash
   flutter run
   ```

### Firestore Rules
Tambahkan rules berikut di Firestore:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read, write: if request.auth != null;
    }
    
    // Global messages
    match /messages/{messageId} {
      allow read, write: if request.auth != null;
    }
    
    // Private chats
    match /private_chats/{chatId}/messages/{messageId} {
      allow read, write: if request.auth != null && 
        (request.auth.token.email in resource.data.participants ||
         request.auth.token.email in request.resource.data.participants);
    }
  }
}
```

## 🛠️ Troubleshooting


### Firebase Configuration Error
Jika terjadi error Firebase configuration:
1. Pastikan file `.env` sudah ada dan berisi konfigurasi yang benar
2. Pastikan package `flutter_dotenv` sudah diinstall dan di-load di `main.dart`
3. Restart aplikasi setelah mengubah `.env`

### Build Error
Jika terjadi build error:
```bash
flutter clean
flutter pub get
flutter run
```

### Android Build Issues
```bash
cd android
./gradlew clean
cd ..
flutter run
```


## 📱 Features
- ✅ Authentication (Login/Register)
- ✅ Global Chat Room
- ✅ Private Chat
- ✅ Real-time Messaging
- ✅ User Management
- ✅ API key Firebase tidak terekspos di repo (menggunakan .env)


## 🚀 Fitur

### Autentikasi
- **Login & Register**: Sistem autentikasi menggunakan Firebase Authentication
- **Validasi Email**: Validasi format email dan password minimal 6 karakter
- **Auto Login**: Otomatis login jika user sudah masuk sebelumnya
- **Logout Aman**: Konfirmasi logout dengan dialog

### Chat Global
- **Real-time Messaging**: Pesan real-time menggunakan Firestore StreamBuilder
- **Nama Pengirim**: Menampilkan nama pengirim dari email
- **Timestamp**: Menampilkan waktu pengiriman pesan
- **UI Responsif**: Bubble chat dengan warna berbeda untuk pesan sendiri dan orang lain
- **Auto Scroll**: Otomatis scroll ke pesan terbaru

### Private Chat
- **Chat Pribadi**: Chat one-on-one dengan pengguna lain
- **Daftar User**: Melihat daftar pengguna terdaftar untuk memulai chat
- **Room Chat Terpisah**: Setiap pasangan user memiliki room chat terpisah
- **UI Konsisten**: Interface yang sama dengan chat global

### Antarmuka
- **No Debug Banner**: Debug banner dihilangkan untuk tampilan bersih
- **Material Design**: Menggunakan Material Design dengan tema biru
- **Loading States**: Indikator loading yang jelas
- **Error Handling**: Penanganan error dengan SnackBar
- **Info Akun**: Dialog untuk melihat informasi akun

## 🛠️ Teknologi

- **Flutter**: Framework untuk pengembangan aplikasi
- **Firebase Authentication**: Untuk autentikasi pengguna
- **Cloud Firestore**: Database real-time untuk pesan
- **Material Design**: Untuk komponen UI

## 📱 Struktur Aplikasi

```
lib/
├── main.dart                 # Entry point aplikasi
├── firebase_options.dart     # Konfigurasi Firebase
└── screens/
    ├── auth_wrapper.dart     # Wrapper untuk cek status login
    ├── login_screen.dart     # Halaman login
    ├── register_screen.dart  # Halaman registrasi
    ├── chat_screen.dart      # Halaman chat global
    ├── user_list_screen.dart # Daftar user untuk private chat
    └── private_chat_screen.dart # Halaman private chat
```

## 🔥 Struktur Database Firestore

### Collection: `users`
```javascript
{
  "email": "user@example.com",
  "displayName": "user",
  "createdAt": timestamp
}
```

### Collection: `messages` (Chat Global)
```javascript
{
  "text": "Isi pesan",
  "senderEmail": "user@example.com",
  "senderName": "user",
  "timestamp": timestamp
}
```

### Collection: `private_chats/{chatId}/messages` (Private Chat)
```javascript
{
  "text": "Isi pesan",
  "senderEmail": "user@example.com",
  "senderName": "user",
  "timestamp": timestamp
}
```

## 🚦 Cara Menjalankan

1. **Prasyarat**:
   - Flutter SDK terinstall
   - Akun Firebase dan project Firebase
   - Android Studio / VS Code

2. **Setup Firebase**:
   - Buat project Firebase baru
   - Aktifkan Authentication (Email/Password)
   - Aktifkan Cloud Firestore
   - Download `google-services.json` untuk Android
   - Jalankan `flutterfire configure`

3. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

4. **Jalankan Aplikasi**:
   ```bash
   flutter run
   ```

## 📋 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^3.3.1
  firebase_auth: ^5.2.0
  cloud_firestore: ^5.2.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
```


## 🔒 Keamanan

- **API key Firebase tidak pernah di-push ke repo.** Semua konfigurasi disimpan di file `.env` yang di-ignore dari version control.
- **Setiap kontributor WAJIB membuat file `.env` sendiri sesuai instruksi setup.**
- **Pastikan Firestore rules sudah dikonfigurasi dengan benar:**

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read, write: if request.auth != null;
    }
    
    // Global messages
    match /messages/{messageId} {
      allow read, create: if request.auth != null;
      allow update, delete: if request.auth != null && 
        request.auth.token.email == resource.data.senderEmail;
    }
    
    // Private chats
    match /private_chats/{chatId}/messages/{messageId} {
      allow read, create: if request.auth != null && 
        request.auth.token.email in chatId.split('_');
      allow update, delete: if request.auth != null && 
        request.auth.token.email == resource.data.senderEmail;
    }
  }
}
```

## 📱 Screenshot

### Login Screen
- Form login dengan validasi
- Link ke halaman register
- Loading indicator

### Chat Global
- Daftar pesan real-time
- Input pesan di bawah
- Menu dengan info akun dan logout

### Private Chat
- Chat one-on-one
- Daftar pengguna untuk memulai chat
- UI konsisten dengan chat global


## 🤝 Kontribusi

1. Fork repository
2. Buat branch baru (`git checkout -b feature/fitur-baru`)
3. Commit perubahan (`git commit -am 'Tambah fitur baru'`)
4. Push ke branch (`git push origin feature/fitur-baru`)
5. Buat Pull Request
6. **JANGAN pernah commit file `.env` atau API key ke repo!**

## 📄 Lisensi

Project ini menggunakan lisensi MIT. Lihat file `LICENSE` untuk detail lebih lanjut.

## 👨‍💻 Developer

Dikembangkan sebagai project UAS untuk mata kuliah pengembangan aplikasi mobile.
