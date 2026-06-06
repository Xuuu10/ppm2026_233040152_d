import 'package:flutter/material.dart';
import 'catatan.dart';
import 'db_helper.dart';

class CatatanFormPage extends StatefulWidget {
  final Catatan? catatan;

  const CatatanFormPage({super.key, this.catatan});

  @override
  State<CatatanFormPage> createState() => _CatatanFormPageState();
}

class _CatatanFormPageState extends State<CatatanFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _judulController;
  late TextEditingController _isiController;
  late int _kategori;

  bool get _isEdit => widget.catatan != null;

  @override
  void initState() {
    super.initState();
    _judulController = TextEditingController(text: widget.catatan?.judul ?? '');
    _isiController = TextEditingController(text: widget.catatan?.isi ?? '');
    _kategori = widget.catatan?.kategori ?? 0;
  }

  @override
  void dispose() {
    _judulController.dispose();
    _isiController.dispose();
    super.dispose();
  }

  Future<void> _simpan() async {
    if (_formKey.currentState!.validate()) {
      try {
        final dbHelper = DbHelper();
        String pesan = '';
        if (_isEdit) {
          final catatanBaru = widget.catatan!.copyWith(
            judul: _judulController.text,
            isi: _isiController.text,
            kategori: _kategori,
          );
          await dbHelper.updateCatatan(catatanBaru);
          pesan = 'Catatan diperbarui';
        } else {
          final catatanBaru = Catatan(
            judul: _judulController.text,
            isi: _isiController.text,
            kategori: _kategori,
            dibuatPada: DateTime.now(),
          );
          await dbHelper.insertCatatan(catatanBaru);
          pesan = 'Catatan ditambahkan';
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(pesan)),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Catatan' : 'Tambah Catatan'),
        actions: [
          IconButton(
            onPressed: _simpan,
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _judulController,
              decoration: const InputDecoration(
                labelText: 'Judul',
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.isEmpty) ? 'Judul wajib diisi' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _isiController,
              decoration: const InputDecoration(
                labelText: 'Isi Catatan',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
              validator: (v) => (v == null || v.isEmpty) ? 'Isi wajib diisi' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              initialValue: _kategori,
              decoration: const InputDecoration(
                labelText: 'Kategori',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 0, child: Text('Umum')),
                DropdownMenuItem(value: 1, child: Text('Penting')),
                DropdownMenuItem(value: 2, child: Text('Tugas')),
              ],
              onChanged: (v) => setState(() => _kategori = v!),
            ),
          ],
        ),
      ),
    );
  }
}
