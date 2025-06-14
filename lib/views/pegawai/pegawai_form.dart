import 'package:flutter/material.dart';
import '../../models/pegawai.dart';
import '../../services/pegawai_service.dart';

class PegawaiForm extends StatefulWidget {
  final Pegawai? pegawai;

  const PegawaiForm({Key? key, this.pegawai}) : super(key: key);

  @override
  State<PegawaiForm> createState() => _PegawaiFormState();
}

class _PegawaiFormState extends State<PegawaiForm> {
  final _formKey = GlobalKey<FormState>();
  final _service = PegawaiService();

  late TextEditingController _usernameController;
  late TextEditingController _nipController;
  late TextEditingController _posisiController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.pegawai?.username ?? '');
    _nipController = TextEditingController(text: widget.pegawai?.nip ?? '');
    _posisiController = TextEditingController(text: widget.pegawai?.posisi ?? '');
    _passwordController = TextEditingController(); // optional jika edit
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final newPegawai = Pegawai(
      id: widget.pegawai?.id ?? 0,
      username: _usernameController.text,
      nip: _nipController.text,
      posisi: _posisiController.text,
      // password only included if new or changed
    );

    bool success;
    if (widget.pegawai == null) {
      success = await _service.addPegawai(newPegawai, _passwordController.text);
    } else {
      success = await _service.updatePegawai(newPegawai);
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
        title: Text(widget.pegawai == null ? 'Tambah Pegawai' : 'Edit Pegawai'),
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
                controller: _nipController,
                decoration: const InputDecoration(labelText: 'NIP'),
                validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
              ),
              TextFormField(
                controller: _posisiController,
                decoration: const InputDecoration(labelText: 'Posisi'),
                validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
              ),
              if (widget.pegawai == null)
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
