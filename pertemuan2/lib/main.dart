import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io' show File;

void main() {
  runApp(const MyApp());
}

class ProfileData {
  String name;
  String role;
  String? profileImagePath;
  Uint8List? profileImageBytes;
  String about;
  String education;
  String location;
  String contact;
  List<String> skills;
  List<Experience> experiences;

  ProfileData({
    required this.name,
    required this.role,
    this.profileImagePath,
    this.profileImageBytes,
    required this.about,
    required this.education,
    required this.location,
    required this.contact,
    required this.skills,
    required this.experiences,
  });
}

class Experience {
  String title;
  String description;
  String? imagePath;
  Uint8List? imageBytes;

  Experience({
    required this.title,
    required this.description,
    this.imagePath,
    this.imageBytes,
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Profile Quiz 2026',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ProfilePage(),
    );
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late ProfileData _profile;

  @override
  void initState() {
    super.initState();
    _profile = ProfileData(
      name: 'Rudol Prasetyo Sinurat',
      role: 'Mahasiswa Teknik Informatika',
      about: 'Saya Suka Berolahraga',
      education: 'Universitas Pasundan — Semester 6',
      location: 'Bandung, Indonesia',
      contact: 'Prasss@example.com\n+62 828480131402',
      skills: ['Flutter', 'Dart', 'Kotlin', 'Java', 'Git'],
      experiences: [
        Experience(
          title: 'Asisten Praktikum',
          description: 'Membantu mahasiswa dalam memahami materi praktikum pemrograman.',
        ),
      ],
    );
  }

  ImageProvider _getProfileImage(ProfileData profile) {
    if (kIsWeb && profile.profileImageBytes != null) {
      return MemoryImage(profile.profileImageBytes!);
    } else if (!kIsWeb && profile.profileImagePath != null) {
      return FileImage(File(profile.profileImagePath!));
    }
    return const NetworkImage('https://github.com/identicons/.png');
  }

  Widget _getExperienceImage(Experience exp) {
    if (kIsWeb && exp.imageBytes != null) {
      return Image.memory(exp.imageBytes!, width: 50, height: 50, fit: BoxFit.cover);
    } else if (!kIsWeb && exp.imagePath != null) {
      return Image.file(File(exp.imagePath!), width: 50, height: 50, fit: BoxFit.cover);
    }
    return const Icon(Icons.work, size: 40);
  }

  void _updateProfile(ProfileData newData) {
    setState(() {
      _profile = newData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(_profile.name),
              accountEmail: Text(_profile.role),
              currentAccountPicture: CircleAvatar(
                backgroundImage: _getProfileImage(_profile),
              ),
              decoration: BoxDecoration(color: Colors.blue.shade700),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Beranda'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Profil'),
              onTap: () async {
                Navigator.pop(context);
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => EditProfilePage(profile: _profile)),
                );
                if (result != null) _updateProfile(result);
              },
            ),
            ListTile(
              leading: const Icon(Icons.work),
              title: const Text('Edit Pengalaman'),
              onTap: () async {
                Navigator.pop(context);
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => EditExperiencePage(experiences: _profile.experiences)),
                );
                if (result != null) {
                  setState(() {
                    _profile.experiences = result;
                  });
                }
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: _getProfileImage(_profile),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _profile.name,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _profile.role,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _SectionCard(icon: Icons.info_outline, title: 'Tentang Saya', content: _profile.about),
            _SectionCard(icon: Icons.school, title: 'Pendidikan', content: _profile.education),
            _SectionCard(icon: Icons.location_on, title: 'Lokasi', content: _profile.location),
            _SectionCard(icon: Icons.email, title: 'Kontak', content: _profile.contact),
            _SectionCard(
              icon: Icons.star,
              title: 'Skills',
              content: '',
              child: Wrap(
                spacing: 8,
                children: _profile.skills.map((s) => Chip(label: Text(s))).toList(),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Pengalaman', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            ..._profile.experiences.map((exp) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: _getExperienceImage(exp),
                title: Text(exp.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(exp.description),
              ),
            )),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => EditProfilePage(profile: _profile)),
          );
          if (result != null) _updateProfile(result);
        },
        child: const Icon(Icons.edit),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  final Widget? child;
  const _SectionCard({required this.icon, required this.title, required this.content, this.child});
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.blue, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  if (content.isNotEmpty) const SizedBox(height: 6),
                  if (content.isNotEmpty) Text(content, style: const TextStyle(height: 1.4)),
                  if (child != null) const SizedBox(height: 8),
                  if (child != null) child!,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EditProfilePage extends StatefulWidget {
  final ProfileData profile;
  const EditProfilePage({super.key, required this.profile});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameCtrl;
  late TextEditingController _roleCtrl;
  late TextEditingController _aboutCtrl;
  late TextEditingController _eduCtrl;
  late TextEditingController _locCtrl;
  late TextEditingController _contactCtrl;
  late TextEditingController _skillsCtrl;
  String? _imagePath;
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.profile.name);
    _roleCtrl = TextEditingController(text: widget.profile.role);
    _aboutCtrl = TextEditingController(text: widget.profile.about);
    _eduCtrl = TextEditingController(text: widget.profile.education);
    _locCtrl = TextEditingController(text: widget.profile.location);
    _contactCtrl = TextEditingController(text: widget.profile.contact);
    _skillsCtrl = TextEditingController(text: widget.profile.skills.join(', '));
    _imagePath = widget.profile.profileImagePath;
    _imageBytes = widget.profile.profileImageBytes;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _roleCtrl.dispose();
    _aboutCtrl.dispose();
    _eduCtrl.dispose();
    _locCtrl.dispose();
    _contactCtrl.dispose();
    _skillsCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _imageBytes = bytes;
          _imagePath = pickedFile.path;
        });
      } else {
        setState(() {
          _imagePath = pickedFile.path;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _imageBytes != null
                    ? MemoryImage(_imageBytes!) as ImageProvider
                    : (_imagePath != null && !kIsWeb
                    ? FileImage(File(_imagePath!)) as ImageProvider
                    : const NetworkImage('https://github.com/identicons/ghani.png')),
                child: const Align(
                  alignment: Alignment.bottomRight,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 15,
                    child: Icon(Icons.camera_alt, size: 18, color: Colors.blue),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Nama')),
            TextField(controller: _roleCtrl, decoration: const InputDecoration(labelText: 'Role')),
            TextField(controller: _aboutCtrl, decoration: const InputDecoration(labelText: 'Tentang'), maxLines: 3),
            TextField(controller: _eduCtrl, decoration: const InputDecoration(labelText: 'Pendidikan')),
            TextField(controller: _locCtrl, decoration: const InputDecoration(labelText: 'Lokasi')),
            TextField(controller: _contactCtrl, decoration: const InputDecoration(labelText: 'Kontak'), maxLines: 2),
            TextField(controller: _skillsCtrl, decoration: const InputDecoration(labelText: 'Skills (pisahkan dengan koma)')),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final updatedProfile = ProfileData(
                    name: _nameCtrl.text,
                    role: _roleCtrl.text,
                    profileImagePath: _imagePath,
                    profileImageBytes: _imageBytes,
                    about: _aboutCtrl.text,
                    education: _eduCtrl.text,
                    location: _locCtrl.text,
                    contact: _contactCtrl.text,
                    skills: _skillsCtrl.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
                    experiences: widget.profile.experiences,
                  );
                  Navigator.pop(context, updatedProfile);
                },
                child: const Text('Simpan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EditExperiencePage extends StatefulWidget {
  final List<Experience> experiences;
  const EditExperiencePage({super.key, required this.experiences});

  @override
  State<EditExperiencePage> createState() => _EditExperiencePageState();
}

class _EditExperiencePageState extends State<EditExperiencePage> {
  late List<Experience> _tempExp;
  // Memindahkan controller ke state agar tidak re-create saat mengetik teks
  final List<TextEditingController> _titleControllers = [];
  final List<TextEditingController> _descControllers = [];

  @override
  void initState() {
    super.initState();
    _tempExp = List.from(widget.experiences);
    for (var exp in _tempExp) {
      _titleControllers.add(TextEditingController(text: exp.title));
      _descControllers.add(TextEditingController(text: exp.description));
    }
  }

  @override
  void dispose() {
    for (var c in _titleControllers) {
      c.dispose();
    }
    for (var c in _descControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addExperience() {
    setState(() {
      _tempExp.add(Experience(title: '', description: ''));
      _titleControllers.add(TextEditingController());
      _descControllers.add(TextEditingController());
    });
  }

  void _removeExperience(int index) {
    setState(() {
      _tempExp.removeAt(index);
      _titleControllers[index].dispose();
      _titleControllers.removeAt(index);
      _descControllers[index].dispose();
      _descControllers.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Pengalaman')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _tempExp.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final picker = ImagePicker();
                          final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                          if (pickedFile != null) {
                            if (kIsWeb) {
                              final bytes = await pickedFile.readAsBytes();
                              setState(() {
                                _tempExp[index].imageBytes = bytes;
                                _tempExp[index].imagePath = pickedFile.path;
                              });
                            } else {
                              setState(() {
                                _tempExp[index].imagePath = pickedFile.path;
                              });
                            }
                          }
                        },
                        child: Container(
                          width: 60, height: 60,
                          decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
                          child: _tempExp[index].imageBytes != null
                              ? Image.memory(_tempExp[index].imageBytes!, fit: BoxFit.cover)
                              : (_tempExp[index].imagePath != null && !kIsWeb
                              ? Image.file(File(_tempExp[index].imagePath!), fit: BoxFit.cover)
                              : const Icon(Icons.add_a_photo)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _titleControllers[index],
                          onChanged: (v) => _tempExp[index].title = v,
                          decoration: const InputDecoration(labelText: 'Judul Pengalaman'),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removeExperience(index),
                      ),
                    ],
                  ),
                  TextField(
                    controller: _descControllers[index],
                    onChanged: (v) => _tempExp[index].description = v,
                    decoration: const InputDecoration(labelText: 'Deskripsi Singkat'),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(onPressed: _addExperience, child: const Icon(Icons.add)),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context, _tempExp),
          child: const Text('Simpan Pengalaman'),
        ),
      ),
    );
  }
}