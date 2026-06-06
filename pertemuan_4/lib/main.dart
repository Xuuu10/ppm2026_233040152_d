import 'package:flutter/material.dart';
import 'catatan.dart';
import 'db_helper.dart';
import 'catatan_form_page.dart';
import 'catatan_detail_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catatan SQLite',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        if (settings.name == '/form') {
          final arg = settings.arguments as Catatan?;
          return MaterialPageRoute(
            builder: (_) => CatatanFormPage(catatan: arg),
          );
        }
        if (settings.name == '/detail') {
          final arg = settings.arguments as Catatan;
          return MaterialPageRoute(
            builder: (_) => CatatanDetailPage(catatan: arg),
          );
        }
        return MaterialPageRoute(builder: (_) => const MyHomePage(title: 'Catatan Mahasiswa'));
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<List<Catatan>> _catatanFuture;

  @override
  void initState() {
    super.initState();
    _refreshCatatan();
  }

  void _refreshCatatan() {
    setState(() {
      _catatanFuture = DbHelper().getCatatan();
    });
  }

  Future<void> _hapusCatatan(int id) async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Catatan?'),
        content: const Text('Catatan yang dihapus tidak dapat dikembalikan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (konfirmasi == true) {
      await DbHelper().deleteCatatan(id);
      _refreshCatatan();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: FutureBuilder<List<Catatan>>(
        future: _catatanFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Belum ada catatan.'));
          }

          final listCatatan = snapshot.data!;
          return ListView.builder(
            itemCount: listCatatan.length,
            itemBuilder: (context, index) {
              final catatan = listCatatan[index];
              return ListTile(
                title: Text(catatan.judul),
                subtitle: Text(
                  catatan.isi,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _hapusCatatan(catatan.id!),
                ),
                onTap: () async {
                  final refresh = await Navigator.pushNamed(
                    context,
                    '/detail',
                    arguments: catatan,
                  );
                  if (refresh == true) _refreshCatatan();
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final refresh = await Navigator.pushNamed(context, '/form');
          if (refresh == true) _refreshCatatan();
        },
        tooltip: 'Tambah Catatan',
        child: const Icon(Icons.add),
      ),
    );
  }
}
