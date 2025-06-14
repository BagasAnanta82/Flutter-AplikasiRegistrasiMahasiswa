import 'package:flutter/material.dart';
import '../../models/mahasiswa.dart';
import '../../services/mahasiswa_service.dart';

class MahasiswaForm extends StatefulWidget {
  final Mahasiswa? mahasiswa;

  const MahasiswaForm({Key? key, this.mahasiswa}) : super(key: key);

  @override
  State<MahasiswaForm> createState() => _MahasiswaFormState();
}

class _MahasiswaFormState extends State<MahasiswaForm> {
  final _formKey = GlobalKey<FormState>();
  final _service = MahasiswaService();

  late TextEditingController _usernameController;
  late TextEditingController _nimController;
  late TextEditingController _prodiController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.mahasiswa?.username ?? '');
    _nimController = TextEditingController(text: widget.mahasiswa?.nim ?? '');
    _prodiController = TextEditingController(text: widget.mahasiswa?.prodi ?? '');
    _passwordController = TextEditingController(); // hanya diisi saat create
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final newMahasiswa = Mahasiswa(
      id: widget.mahasiswa?.id ?? 0,
      username: _usernameController.text,
      nim: _nimController.text,
      prodi: _prodiController.text,
    );

    bool success;
    if (widget.mahasiswa == null) {
      success = await _service.addMahasiswa(newMahasiswa, _passwordController.text);
    } else {
      success = await _service.updateMahasiswa(newMahasiswa);
    }

    if (success) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menyimpan data')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mahasiswa == null ? 'Tambah Mahasiswa' : 'Edit Mahasiswa'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
                validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
              ),
              TextFormField(
                controller: _nimController,
                decoration: const InputDecoration(labelText: 'NIM'),
                validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
              ),
              TextFormField(
                controller: _prodiController,
                decoration: const InputDecoration(labelText: 'Prodi'),
                validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
              ),
              if (widget.mahasiswa == null)
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
