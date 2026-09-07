# LEMBAR KERJA MURID (LKM)
## Navigasi dan Routing
**Mata Pelajaran:** Pemrograman Perangkat Bergerak  
**Nama:** Ibra Al Tabian  
**Kelas:** XII RPL B  
**Tanggal:** 31 Agustus 2026  
**Sekolah:** SMK Negeri 5 Surakarta  

---

## TUGAS 1: Rancangan Pengembangan Aplikasi Buku Kontak

### 1. Deskripsi Pengembangan
Pada kegiatan kali ini, aplikasi Buku Kontak dikembangkan menjadi aplikasi lengkap dengan menerapkan **Material Design, Navigasi, dan Routing**:
- **Halaman Beranda:** Memiliki `AppBar`, `Navigation Drawer`, `TabBar`, `TabBarView`, dan `FloatingActionButton`.
- **FloatingActionButton:** Tombol `(+)` pada halaman daftar kontak untuk berpindah ke **Halaman Tambah Kontak**.
- **Navigation Drawer:** Menyediakan menu navigasi:
  - Kontak (berpindah ke Tab Kontak)
  - Tambah Kontak (berpindah ke Halaman Tambah Kontak)
  - Favorit (berpindah ke Tab Favorit)
  - Tentang (berpindah ke Halaman Tentang)
- **Halaman Tambah Kontak:** Berisi form input:
  - Nama Lengkap
  - Email
  - No Handphone
  - Tombol Simpan (mengirim data kontak kembali ke Halaman Kontak)
- **Halaman Kontak:** Menampilkan daftar list kontak yang telah ditambahkan.
- **Halaman Favorit:** Menampilkan daftar kontak favorit.
- **Halaman Tentang:** Menampilkan profil data diri (Foto Profil, Nama, Kelas, Sekolah).

---

### 2. Kode Program Lengkap (`lib/main.dart`)

```dart
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// MY APP
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Buku Kontak',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const DefaultTabController(
        length: 2,
        child: MyHomePage(),
      ),
    );
  }
}

// HALAMAN UTAMA
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Menyimpan data kontak
  List<Kontak> items = [];

  // FUNGSI UNTUK MEMBUKA HALAMAN TAMBAH KONTAK
  Future<void> tambahKontak() async {
    final hasil = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TambahKontakPage(),
      ),
    );

    // Jika ada data kontak yang dikirim kembali
    if (hasil != null) {
      setState(() {
        items.add(hasil);
      });
      DefaultTabController.of(context).animateTo(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: const Text('BUKU KONTAK'),

        // TAB BAR
        bottom: const TabBar(
          tabs: [
            Tab(
              icon: Icon(Icons.account_circle),
              text: 'Kontak',
            ),
            Tab(
              icon: Icon(Icons.star),
              text: 'Favorit',
            ),
          ],
        ),
      ),

      // DRAWER
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'BUKU KONTAK',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),

            // MENU KONTAK
            ListTile(
              leading: const Icon(Icons.contact_page),
              title: const Text('Kontak'),
              onTap: () {
                DefaultTabController.of(context).animateTo(0);
                Navigator.pop(context);
              },
            ),

            // MENU TAMBAH KONTAK
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Tambah Kontak'),
              onTap: () {
                Navigator.pop(context);
                tambahKontak();
              },
            ),

            // MENU FAVORIT
            ListTile(
              leading: const Icon(Icons.star),
              title: const Text('Favorit'),
              onTap: () {
                DefaultTabController.of(context).animateTo(1);
                Navigator.pop(context);
              },
            ),

            // MENU TENTANG
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Tentang'),
              onTap: () {
                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TentangPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),

      // TAB BAR VIEW
      body: TabBarView(
        children: [
          // TAB KONTAK
          daftarKontak(),

          // TAB FAVORIT
          const Center(
            child: Text('Belum ada kontak favorit'),
          ),
        ],
      ),

      // FLOATING ACTION BUTTON
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          tambahKontak();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // WIDGET DAFTAR KONTAK
  Widget daftarKontak() {
    if (items.isEmpty) {
      return const Center(
        child: Text(
          'Belum ada kontak',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: const Icon(Icons.person),
          title: Text(
            items[index].nama,
          ),
          subtitle: Text(
            '${items[index].email}\n'
            '${items[index].noHandphone}',
          ),
        );
      },
    );
  }
}

// HALAMAN TAMBAH KONTAK
class TambahKontakPage extends StatefulWidget {
  const TambahKontakPage({super.key});

  @override
  State<TambahKontakPage> createState() => _TambahKontakPageState();
}

class _TambahKontakPageState extends State<TambahKontakPage> {
  // Controller untuk mengambil input
  final TextEditingController namaController = TextEditingController();

  final TextEditingController emailController = TextEditingController();

  final TextEditingController noHandphoneController = TextEditingController();

  @override
  void dispose() {
    namaController.dispose();
    emailController.dispose();
    noHandphoneController.dispose();
    super.dispose();
  }

  // FUNGSI SIMPAN KONTAK
  void simpanKontak() {
    // Membuat objek kontak dari input
    Kontak kontak = Kontak(
      nama: namaController.text,
      email: emailController.text,
      noHandphone: noHandphoneController.text,
    );

    // Mengirim data kontak kembali ke halaman sebelumnya
    Navigator.pop(context, kontak);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: const Text('Tambah Kontak'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // NAMA
            TextField(
              controller: namaController,
              decoration: const InputDecoration(
                labelText: 'Nama Lengkap',
              ),
            ),

            const SizedBox(height: 15),

            // EMAIL
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
            ),

            const SizedBox(height: 15),

            // NOMOR HANDPHONE
            TextField(
              controller: noHandphoneController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'No Handphone',
              ),
            ),

            const SizedBox(height: 20),

            // TOMBOL SIMPAN
            ElevatedButton(
              onPressed: () {
                simpanKontak();
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}

// HALAMAN TENTANG
class TentangPage extends StatelessWidget {
  const TentangPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: const Text('Tentang'),
      ),
      body: const Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('assets/images/profile.png'),
                ),
                const SizedBox(height: 20),
                Text(
                  'Ibra Al Tabian',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  'XII RPL B',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                Text(
                  'SMK Negeri 5 Surakarta',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// CLASS KONTAK
class Kontak {
  String nama;
  String email;
  String noHandphone;

  Kontak({
    required this.nama,
    required this.email,
    required this.noHandphone,
  });
}
```

---

### 3. Penjelasan Kode Program (Untuk Lembar LKM Halaman 4)

1. **`DefaultTabController`, `TabBar`, dan `TabBarView`:**
   - Digunakan untuk membuat navigasi tab pada bagian atas layar (`AppBar.bottom`).
   - Memiliki 2 tab: **Kontak** (menampilkan daftar kontak dinamis) dan **Favorit** (menampilkan kontak favorit).

2. **`Navigation Drawer`:**
   - Menyediakan menu navigasi samping dengan `DrawerHeader` dan 4 item `ListTile` (*Kontak*, *Tambah Kontak*, *Favorit*, *Tentang*).
   - Menggunakan `Navigator.pop(context)` untuk menutup drawer, `DefaultTabController.of(context).animateTo()` untuk berpindah tab, serta `Navigator.push()` untuk berpindah halaman.

3. **`FloatingActionButton`:**
   - Tombol mengambang di pojok kanan bawah yang memanggil fungsi `tambahKontak()` untuk membuka halaman form input kontak baru.

4. **`TambahKontakPage` & Pengiriman Data (`Navigator.pop`):**
   - Mengambil input pengguna dari `TextEditingController` untuk Nama, Email, dan No Handphone.
   - Saat tombol **Simpan** ditekan, data dibungkus dalam objek class `Kontak` lalu dikirim kembali ke halaman utama melalui `Navigator.pop(context, kontak)`.
   - Halaman utama menerima data melalui `await Navigator.push(...)`, kemudian memasukkannya ke dalam list `items` menggunakan `setState()`.

5. **`TentangPage`:**
   - Menampilkan profil murid menggunakan widget `CircleAvatar` dengan gambar profil lokal (`AssetImage('assets/images/profile.png')`), diikuti teks Nama, Kelas, dan Nama Sekolah.

---

## TUGAS 2: Push Project ke GitHub

### Petunjuk Pengerjaan
1. Buat repository baru di akun GitHub masing-masing dengan format nama: `Nama_BukuKontak` (contoh: `Ibra_BukuKontak`).
2. Jalankan perintah Git di terminal direktori project:
   ```bash
   git init
   git add .
   git commit -m "Initial commit - Buku Kontak"
   git branch -M main
   git remote add origin https://github.com/<Username_GitHub>/Ibra_BukuKontak.git
   git push -u origin main
   ```
3. Pastikan seluruh file project berhasil tersimpan di repository GitHub.

### Data Isian Tugas 2:
- **Nama Akun GitHub:** `ibratabian17` *(sesuaikan dengan username GitHub Anda)*
- **Link Repository:** `https://github.com/ibratabian17/Ibra_BukuKontak`

---

## TUGAS 3: Fork – Clone – Commit – Push – Pull Request

### Alur Kerja Kolaborasi:
1. **Bertukar Repository:** Bertukar link repository dengan pasangan/teman.
   - **Nama Teman:** Annisa Kusumastuti
   - **Username GitHub Teman:** `annisaakundua`
   - **Link Repository Teman:** `https://github.com/annisaakundua/Annisaka_BukuKontak`

2. **Fork Repository Teman:**
   - Buka link repository teman di browser.
   - Klik tombol **Fork** di pojok kanan atas → Klik **Create Fork**.
   - Repository hasil fork akan muncul di akun GitHub milikmu (`https://github.com/ibratabian17/Annisaka_BukuKontak`).

3. **Clone Repository Hasil Fork:**
   - Buka terminal / VS Code, jalankan perintah clone:
     ```bash
     git clone https://github.com/ibratabian17/Annisaka_BukuKontak.git
     ```

4. **Menambahkan Data Diri pada Kontak Favorit:**
   - Buka project yang telah diclone di VS Code.
   - Buka file `lib/main.dart`.
   - Pada bagian `TabBarView` -> `Favorit`, ubah menjadi data dirimu:
     ```dart
     // TAB FAVORIT
     const ListTile(
       leading: Icon(Icons.person),
       title: Text('Ibra Al Tabian'),
       subtitle: Text('ibra@gmail.com\n0895421903057'),
     ),
     ```

5. **Commit Perubahan:**
   - Periksa status dan simpan commit:
     ```bash
     git status
     git add .
     git commit -m "Menambahkan kontak pada menu favorit"
     ```

6. **Push ke Repository Hasil Fork:**
   ```bash
   git push -u origin main
   ```

7. **Membuat Pull Request (PR):**
   - Buka repository hasil fork di GitHub.
   - Klik tombol **Contribute** atau tab **Pull requests** → Klik **Open pull request** / **Create Pull request**.
   - Beri judul: `Menambahkan kontak favorit`
   - Klik **Create Pull Request**.

8. **Merge Pull Request (Oleh Pemilik Repository):**
   - Pemilik repositori asli membuka tab **Pull requests**.
   - Klik pull request yang masuk dari pasangan → Klik **Merge pull request** → **Confirm merge**.

---

## BUKTI KEGIATAN (Isian LKM Halaman 7 - 9)

### 1. Repository Pribadi
- **Link Repository:** `https://github.com/ibratabian17/Ibra_BukuKontak`
- *(Tempelkan screenshot halaman utama repository GitHub pribadimu)*

### 2. Repository Hasil Fork
- **Link Repository Fork:** `https://github.com/ibratabian17/Annisaka_BukuKontak`
- *(Tempelkan screenshot repository hasil Fork yang berada di akun GitHub-mu dengan keterangan "forked from annisaakundua/Annisaka_BukuKontak")*

### 3. Screenshot Kontak Favorit
- *(Tempelkan screenshot tampilan aplikasi saat Tab Favorit dibuka, menampilkan data kontak diri: Ibra Al Tabian / ibra@gmail.com / 0895421903057)*

### 4. Screenshot Commit
- *(Tempelkan screenshot riwayat commit atau terminal dengan pesan: `git commit -m "Menambahkan kontak pada menu favorit"`)*

### 5. Screenshot Pull Request
- *(Tempelkan screenshot halaman pembuatan Pull Request dari repository Fork menuju repository asli milik teman)*

### 6. Screenshot Pull Request Pasangan yang Telah Diterima (Merged)
- *(Tempelkan screenshot pada repository pribadimu yang menunjukkan status Pull Request dari pasangan sudah berlabel ungu **Merged**)*
