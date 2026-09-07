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
  List<Kontak> items = [];

  // FUNGSI UNTUK MEMBUKA HALAMAN TAMBAH KONTAK
  Future<void> tambahKontak() async {
    final hasil = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TambahKontakPage(),
      ),
    );

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
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Ibra Al Tabian'),
            subtitle: const Text(
              'ibraaaaa@gmail.com\n'
              '0851737264384',
            ),
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
        final kontak = items[index];

        return ListTile(
          // Avatar berisi huruf pertama nama
          leading: CircleAvatar(
            child: Text(
              kontak.nama.isNotEmpty
                  ? kontak.nama[0].toUpperCase()
                  : '?',
            ),
          ),

          // Nama kontak
          title: Text(
            kontak.nama,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),

          // Informasi kontak
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(kontak.email),
              Text(kontak.noHandphone),

              const SizedBox(height: 5),

              // Kategori
              Chip(
                label: Text(
                  kontak.kategori ?? 'Tanpa kategori',
                ),
                avatar: const Icon(
                  Icons.label,
                  size: 18,
                ),
              ),
            ],
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
  // GLOBAL KEY FORM
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // CONTROLLER
  final TextEditingController namaController = TextEditingController();

  final TextEditingController emailController = TextEditingController();

  final TextEditingController noHandphoneController =
      TextEditingController();

  final TextEditingController kategoriController =
      TextEditingController();

  @override
  void dispose() {
    namaController.dispose();
    emailController.dispose();
    noHandphoneController.dispose();
    kategoriController.dispose();

    super.dispose();
  }

  // FUNGSI SIMPAN KONTAK
  void simpanKontak() {
    Kontak kontak = Kontak(
      nama: namaController.text,
      email: emailController.text,
      noHandphone: noHandphoneController.text,
      kategori: kategoriController.text.isEmpty
          ? null
          : kategoriController.text,
    );

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

        // FORM
        child: Form(
          key: _formKey,

          child: Column(
            children: [
              // =========================
              // NAMA
              // =========================
              TextFormField(
                controller: namaController,
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap',
                ),

                // VALIDATOR NAMA
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama wajib diisi';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 15),

              // =========================
              // EMAIL
              // =========================
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                ),

                // VALIDATOR EMAIL
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Email wajib diisi';
                  }

                  if (!value.contains('@')) {
                    return 'Email harus mengandung karakter @';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 15),

              // =========================
              // NOMOR HANDPHONE
              // =========================
              TextFormField(
                controller: noHandphoneController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'No Handphone',
                ),

                // VALIDATOR NOMOR HANDPHONE
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'No Handphone wajib diisi';
                  }

                  if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                    return 'No Handphone hanya boleh berisi angka';
                  }

                  if (value.length < 10) {
                    return 'No Handphone minimal 10 digit';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 15),

              // =========================
              // KATEGORI
              // =========================
              TextFormField(
                controller: kategoriController,
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  hintText: 'Contoh: Keluarga, Teman, Kerja',
                ),
              ),

              const SizedBox(height: 20),

              // =========================
              // TOMBOL SIMPAN
              // =========================
              ElevatedButton(
                onPressed: () {
                  // CEK VALIDASI FORM
                  if (_formKey.currentState!.validate()) {
                    // Jika semua valid, simpan kontak
                    simpanKontak();
                  }
                },
                child: const Text('Simpan'),
              ),
            ],
          ),
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
          padding: EdgeInsets.all(20),

          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage(
                  'assets/images/profile.png',
                ),
              ),

              SizedBox(height: 20),

              Text(
                'Dhani Arrgiawan W',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 10),

              Text(
                'XII RPL B',
                style: TextStyle(fontSize: 16),
              ),

              SizedBox(height: 10),

              Text(
                'SMK Negeri 5 Surakarta',
                style: TextStyle(fontSize: 16),
              ),
            ],
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

  // Kategori boleh null
  String? kategori;

  Kontak({
    required this.nama,
    required this.email,
    required this.noHandphone,
    this.kategori,
  });
}