import 'package:flutter/material.dart';

String _formatTanggal(DateTime dt) {
  const bulan = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  final day = dt.day.toString().padLeft(2, '0');
  final month = bulan[dt.month - 1];
  final year = dt.year;
  final hour = dt.hour.toString().padLeft(2, '0');
  final minute = dt.minute.toString().padLeft(2, '0');

  return '$day $month $year, $hour:$minute';
}

void main() {
  runApp(const MyApp());
}

class Catatan {
  final String id;
  final String judul;
  final String isi;
  final String kategori;
  final DateTime dibuatPada;

  Catatan({
    required this.id,
    required this.judul,
    required this.isi,
    required this.kategori,
    required this.dibuatPada,
  });
}

class DetailCatatanArgs {
  final Catatan catatan;
  final ValueChanged<Catatan> onUpdated;

  DetailCatatanArgs({required this.catatan, required this.onUpdated});
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catatan Mahasiswa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      initialRoute: '/',
      routes: {'/': (context) => const HomePage()},
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/tambah':
            final catatan = settings.arguments as Catatan?;
            return MaterialPageRoute(
              builder: (_) => TambahCatatanPage(catatan: catatan),
            );
          case '/detail':
            final args = settings.arguments as DetailCatatanArgs;
            return MaterialPageRoute(
              builder: (_) => DetailCatatanPage(
                catatan: args.catatan,
                onUpdated: args.onUpdated,
              ),
            );
        }
        return null;
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // === STATE ===
  final List<Catatan> _catatan = [
    Catatan(
      id: 'seed-1',
      judul: 'Belajar Flutter',
      isi: 'Mempelajari Stateful Widget, Form, dan Navigation.',
      kategori: 'Kuliah',
      dibuatPada: DateTime.now(),
    ),
  ];

  Future<void> _bukaTambahCatatan() async {
    final hasil = await Navigator.pushNamed(context, '/tambah');

    if (hasil is Catatan) {
      setState(() => _catatan.add(hasil));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Catatan "${hasil.judul}" ditambahkan')),
      );
    }
  }

  void _perbaruiCatatan(Catatan catatanBaru) {
    final index = _catatan.indexWhere((item) => item.id == catatanBaru.id);
    if (index == -1) return;

    setState(() => _catatan[index] = catatanBaru);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Catatan "${catatanBaru.judul}" diperbarui')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Catatan Mahasiswa')),
      // tambahkan _EmptyState
      body: _catatan.isEmpty
          ? const Center(child: Text('Belum ada catatan'))
          : ListView.builder(
              itemCount: _catatan.length,
              itemBuilder: (context, i) {
                final c = _catatan[i];
                return ListTile(
                  title: Text(c.judul),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/detail',
                      arguments: DetailCatatanArgs(
                        catatan: c,
                        onUpdated: _perbaruiCatatan,
                      ),
                    );
                  },
                  // tambahkan tombol delete di ListTile
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      setState(() => _catatan.remove(c));
                    },
                  ),

                  // tambahkan helper _formatTanggal
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c.kategori),
                      Text(_formatTanggal(c.dibuatPada)),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _bukaTambahCatatan,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TambahCatatanPage extends StatefulWidget {
  final Catatan? catatan;

  const TambahCatatanPage({super.key, this.catatan});

  @override
  State<TambahCatatanPage> createState() => _TambahCatatanPageState();
}

class _TambahCatatanPageState extends State<TambahCatatanPage> {
  final _formKey = GlobalKey<FormState>();
  final _judulCtrl = TextEditingController();
  final _isiCtrl = TextEditingController();

  final _kategoriOpsi = const ['Kuliah', 'Tugas', 'Pribadi', 'Lainnya'];
  late String _kategori;

  bool get _isEdit => widget.catatan != null;

  @override
  void initState() {
    super.initState();
    _judulCtrl.text = widget.catatan?.judul ?? '';
    _isiCtrl.text = widget.catatan?.isi ?? '';
    _kategori = widget.catatan?.kategori ?? _kategoriOpsi.first;
  }

  @override
  void dispose() {
    _judulCtrl.dispose();
    _isiCtrl.dispose();
    super.dispose();
  }

  void _simpan() {
    if (!_formKey.currentState!.validate()) return;

    final catatanBaru = Catatan(
      id:
          widget.catatan?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      judul: _judulCtrl.text.trim(),
      isi: _isiCtrl.text.trim(),
      kategori: _kategori,
      dibuatPada: widget.catatan?.dibuatPada ?? DateTime.now(),
    );

    Navigator.pop(context, catatanBaru);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Edit Catatan' : 'Tambah Catatan')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _judulCtrl,
              decoration: const InputDecoration(
                labelText: 'Judul',
                prefixIcon: Icon(Icons.title),
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Judul wajib diisi';
                if (v.trim().length < 3) return 'Minimal 3 karakter';
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _kategori,
              decoration: const InputDecoration(
                labelText: 'Kategori',
                prefixIcon: Icon(Icons.category),
                border: OutlineInputBorder(),
              ),
              items: _kategoriOpsi
                  .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                  .toList(),
              onChanged: (v) {
                if (v == null) return;
                setState(() => _kategori = v);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _isiCtrl,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Isi',
                prefixIcon: Icon(Icons.notes),
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Isi wajib diisi' : null,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _simpan,
              icon: const Icon(Icons.save),
              label: Text(_isEdit ? 'Simpan Perubahan' : 'Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}

class DetailCatatanPage extends StatefulWidget {
  final Catatan catatan;
  final ValueChanged<Catatan> onUpdated;

  const DetailCatatanPage({
    super.key,
    required this.catatan,
    required this.onUpdated,
  });

  @override
  State<DetailCatatanPage> createState() => _DetailCatatanPageState();
}

class _DetailCatatanPageState extends State<DetailCatatanPage> {
  late Catatan _catatan;

  @override
  void initState() {
    super.initState();
    _catatan = widget.catatan;
  }

  Future<void> _bukaEdit() async {
    final hasil = await Navigator.pushNamed(
      context,
      '/tambah',
      arguments: _catatan,
    );

    if (!mounted || hasil is! Catatan) return;

    setState(() => _catatan = hasil);
    widget.onUpdated(hasil);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Catatan'),
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: _bukaEdit),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // tampilkan tanggal dengan helper _formatTanggal
            Text(
              _formatTanggal(_catatan.dibuatPada),
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            Text(
              _catatan.judul,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Chip(label: Text(_catatan.kategori)),
            const Divider(height: 32),
            Text(
              _catatan.isi,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
