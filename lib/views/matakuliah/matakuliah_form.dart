import 'package:flutter/material.dart';
import '../../models/matakuliah.dart';
import '../../services/matakuliah_service.dart';

class MataKuliahForm extends StatefulWidget {
  final MataKuliah? mk;
  const MataKuliahForm({super.key, this.mk});

  @override
  State<MataKuliahForm> createState() => _MataKuliahFormState();
}

class _MataKuliahFormState extends State<MataKuliahForm> {
  final _formKey = GlobalKey<FormState>();
  final _service = MataKuliahService();

  late TextEditingController _kodeController;
  late TextEditingController _namaController;
  late TextEditingController _sksController;
  late TextEditingController _startTimeController;
  late TextEditingController _endTimeController;

  String? _selectedDay;

  final List<String> _days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat'];

  @override
  void initState() {
    super.initState();
    _kodeController = TextEditingController(text: widget.mk?.kode ?? '');
    _namaController = TextEditingController(text: widget.mk?.nama ?? '');
    _sksController = TextEditingController(text: widget.mk?.sks.toString() ?? '');
    _selectedDay = widget.mk?.day;
    _startTimeController = TextEditingController(text: widget.mk?.startTime ?? '');
    _endTimeController = TextEditingController(text: widget.mk?.endTime ?? '');
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final mk = MataKuliah(
      id: widget.mk?.id ?? 0,
      kode: _kodeController.text,
      nama: _namaController.text,
      sks: int.parse(_sksController.text),
      day: _selectedDay ?? '',
      startTime: _startTimeController.text,
      endTime: _endTimeController.text,
    );

    bool success = widget.mk == null
        ? await _service.add(mk)
        : await _service.update(mk);

    if (success) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan data')),
      );
    }
  }

  Future<void> _selectTime(TextEditingController controller) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time != null) {
      // Format 24 jam: HH:mm
      final hour = time.hour.toString().padLeft(2, '0');
      final minute = time.minute.toString().padLeft(2, '0');
      controller.text = '$hour:$minute';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.mk == null ? 'Tambah Mata Kuliah' : 'Edit Mata Kuliah')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _kodeController,
                decoration: InputDecoration(labelText: 'Kode'),
                validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
              ),
              TextFormField(
                controller: _namaController,
                decoration: InputDecoration(labelText: 'Nama'),
                validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
              ),
              TextFormField(
                controller: _sksController,
                decoration: InputDecoration(labelText: 'SKS'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
              ),
              DropdownButtonFormField<String>(
                value: _selectedDay,
                decoration: InputDecoration(labelText: 'Hari'),
                items: _days.map((day) {
                  return DropdownMenuItem(value: day, child: Text(day));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDay = value;
                  });
                },
                validator: (value) => value == null ? 'Wajib pilih hari' : null,
              ),
              TextFormField(
                controller: _startTimeController,
                readOnly: true,
                onTap: () => _selectTime(_startTimeController),
                decoration: InputDecoration(labelText: 'Jam Mulai'),
                validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
              ),
              TextFormField(
                controller: _endTimeController,
                readOnly: true,
                onTap: () => _selectTime(_endTimeController),
                decoration: InputDecoration(labelText: 'Jam Selesai'),
                validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
