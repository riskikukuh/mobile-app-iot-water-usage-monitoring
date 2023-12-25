## Mobile App - IoT Water Usage Monitoring 

Aplikasi Mobile yang digunakan client untuk memantau pemakaian air.



### Requirements

- Flutter



### Installation

1. Install Flutter packages

   ```bash
   flutter pub get
   ```

2. Tambahkan aplikasi ke Firebase Project yang sama digunakan dengan aplikasi backend, dan akan mendapatkan File `google-services.json`

3. Masukkan file `google-services.json` ke `[IOT_WATER_MONITORING]/android/app`

4. Ubah `HOST` pada `[IOT_WATER_MONITORING]/lib/repository/mainRepository.dart` dengan IP server Backend anda



### Features

1. Live Update water usage
2. History usage
3. Bill usage
4. Profile settings
