import 'package:flutter/material.dart';
import 'catatan.dart';
import 'package:intl/intl.dart';

class CatatanDetailPage extends StatelessWidget {
  final Catatan catatan;

  const CatatanDetailPage({super.key, required this.catatan});

  @override
  Widget build(BuildContext context) {
    final daftarKategori = ['Umum', 'Penting', 'Tugas'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Catatan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final refresh = await Navigator.pushNamed(
                context,
                '/form',
                arguments: catatan,
              );
              if (refresh == true) {
                if (context.mounted) Navigator.pop(context, true);
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            catatan.judul,
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Chip(label: Text(daftarKategori[catatan.kategori])),
              const SizedBox(width: 12),
              Text(
                DateFormat('dd MMM yyyy, HH:mm').format(catatan.dibuatPada),
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
          const Divider(height: 32),
          Text(
            catatan.isi,
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
        ],
      ),
    );
  }
}
