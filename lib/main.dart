import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Buku Kontak',
      debugShowCheckedModeBanner: false,
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

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController searchController =
      TextEditingController();

  String kataKunci = '';

  final CollectionReference kontakCollection =
      FirebaseFirestore.instance.collection('kontak');

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> tambahKontak() async {
    final hasil = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TambahKontakPage(),
      ),
    );

    if (!mounted) return;

    if (hasil == true) {
      DefaultTabController.of(context).animateTo(0);
    }
  }

  Future<void> editKontak(Kontak kontak) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TambahKontakPage(
          kontak: kontak,
        ),
      ),
    );
  }

  Future<void> hapusKontak(Kontak kontak) async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Kontak'),
        content: Text(
          'Hapus kontak ${kontak.nama}?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (!mounted) return;

    if (konfirmasi == true) {
      try {
        await kontakCollection
            .doc(kontak.id)
            .delete();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kontak berhasil dihapus'),
          ),
        );
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal menghapus kontak: $e',
            ),
          ),
        );
      }
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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
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
            ListTile(
              leading: const Icon(Icons.contact_page),
              title: const Text('Kontak'),
              onTap: () {
                DefaultTabController.of(context).animateTo(0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Tambah Kontak'),
              onTap: () {
                Navigator.pop(context);
                tambahKontak();
              },
            ),
            ListTile(
              leading: const Icon(Icons.star),
              title: const Text('Favorit'),
              onTap: () {
                DefaultTabController.of(context).animateTo(1);
                Navigator.pop(context);
              },
            ),
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
      body: TabBarView(
        children: [
          daftarKontak(),
          const ListTile(
            leading: Icon(Icons.person),
            title: Text('Ibra Al Tabian'),
            subtitle: Text(
              'ibraaaaa@gmail.com\n'
              '0851737264384',
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: tambahKontak,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget daftarKontak() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              labelText: 'Cari Kontak',
              hintText: 'Cari berdasarkan nama atau kategori',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: kataKunci.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        searchController.clear();

                        setState(() {
                          kataKunci = '';
                        });
                      },
                      icon: const Icon(Icons.clear),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onChanged: (teks) {
              setState(() {
                kataKunci = teks.toLowerCase().trim();
              });
            },
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: kontakCollection.snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'Terjadi kesalahan:\n\n${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              if (!snapshot.hasData) {
                return const Center(
                  child: Text('Tidak ada data'),
                );
              }

              final data = snapshot.data!.docs;

              if (data.isEmpty) {
                return const Center(
                  child: Text(
                    'Belum ada kontak',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                );
              }

              final daftar = data
                  .map(
                    (doc) => Kontak.fromFirestore(doc),
                  )
                  .where((kontak) {
                    final nama =
                        kontak.nama.toLowerCase();

                    final kategori =
                        (kontak.kategori ?? '')
                            .toLowerCase();

                    return nama.contains(kataKunci) ||
                        kategori.contains(kataKunci);
                  })
                  .toList();

              if (daftar.isEmpty) {
                return const Center(
                  child: Text(
                    'Kontak tidak ditemukan',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                );
              }

              return ListView.builder(
                itemCount: daftar.length,
                itemBuilder: (context, index) {
                  final kontak = daftar[index];

                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(
                        kontak.nama.isNotEmpty
                            ? kontak.nama[0].toUpperCase()
                            : '?',
                      ),
                    ),
                    title: Text(
                      kontak.nama,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(kontak.email),
                        Text(kontak.noHandphone),
                        const SizedBox(height: 5),
                        Chip(
                          label: Text(
                            kontak.kategori ??
                                'Tanpa kategori',
                          ),
                          avatar: const Icon(
                            Icons.label,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                    trailing:
                        PopupMenuButton<String>(
                      onSelected: (aksi) {
                        if (aksi == 'edit') {
                          editKontak(kontak);
                        }

                        if (aksi == 'hapus') {
                          hapusKontak(kontak);
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: 'edit',
                          child: Text('Edit'),
                        ),
                        PopupMenuItem(
                          value: 'hapus',
                          child: Text('Hapus'),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class TambahKontakPage extends StatefulWidget {
  final Kontak? kontak;

  const TambahKontakPage({
    super.key,
    this.kontak,
  });

  @override
  State<TambahKontakPage> createState() =>
      _TambahKontakPageState();
}

class _TambahKontakPageState
    extends State<TambahKontakPage> {
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  final TextEditingController namaController =
      TextEditingController();

  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController noHandphoneController =
      TextEditingController();

  final TextEditingController kategoriController =
      TextEditingController();

  final CollectionReference kontakCollection =
      FirebaseFirestore.instance.collection('kontak');

  bool get modeEdit => widget.kontak != null;

  @override
  void initState() {
    super.initState();

    if (widget.kontak != null) {
      namaController.text = widget.kontak!.nama;
      emailController.text = widget.kontak!.email;
      noHandphoneController.text =
          widget.kontak!.noHandphone;
      kategoriController.text =
          widget.kontak!.kategori ?? '';
    }
  }

  @override
  void dispose() {
    namaController.dispose();
    emailController.dispose();
    noHandphoneController.dispose();
    kategoriController.dispose();
    super.dispose();
  }

  Future<void> simpanKontak() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final data = {
        'nama': namaController.text.trim(),
        'email': emailController.text.trim(),
        'noHandphone':
            noHandphoneController.text.trim(),
        'kategori':
            kategoriController.text.trim().isEmpty
                ? null
                : kategoriController.text.trim(),
      };

      if (modeEdit) {
        await kontakCollection
            .doc(widget.kontak!.id)
            .update(data);
      } else {
        await kontakCollection.add(data);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            modeEdit
                ? 'Kontak berhasil diperbarui'
                : 'Kontak berhasil disimpan',
          ),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal menyimpan kontak:\n$e',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: Text(
          modeEdit
              ? 'Edit Kontak'
              : 'Tambah Kontak',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: namaController,
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap',
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Nama wajib diisi';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: emailController,
                keyboardType:
                    TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Email wajib diisi';
                  }

                  if (!value.contains('@')) {
                    return 'Email harus mengandung karakter @';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: noHandphoneController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'No Handphone',
                ),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty) {
                    return 'No Handphone wajib diisi';
                  }

                  if (!RegExp(r'^[0-9]+$')
                      .hasMatch(value)) {
                    return 'No Handphone hanya boleh berisi angka';
                  }

                  if (value.length < 10) {
                    return 'No Handphone minimal 10 digit';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: kategoriController,
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  hintText:
                      'Contoh: Keluarga, Teman, Kerja',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: simpanKontak,
                child: Text(
                  modeEdit ? 'Update' : 'Simpan',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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

class Kontak {
  String id;
  String nama;
  String email;
  String noHandphone;
  String? kategori;

  Kontak({
    required this.id,
    required this.nama,
    required this.email,
    required this.noHandphone,
    this.kategori,
  });

  factory Kontak.fromFirestore(
    DocumentSnapshot doc,
  ) {
    final data =
        doc.data() as Map<String, dynamic>;

    return Kontak(
      id: doc.id,
      nama: data['nama']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
      noHandphone:
          data['noHandphone']?.toString() ?? '',
      kategori:
          data['kategori']?.toString(),
    );
  }
}