import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart'; // Import the QR scanner package
import '../../models/matakuliah.dart';
import '../../services/matakuliahmahasiswa_service.dart';
import '../../services/matakuliah_service.dart';
import '../../services/mahasiswa_service.dart';

class ScanMatkulPage extends StatefulWidget {
  const ScanMatkulPage({super.key});

  @override
  State<ScanMatkulPage> createState() => _ScanMatkulPageState();
}

class _ScanMatkulPageState extends State<ScanMatkulPage> {
  int? _mahasiswaId;
  MataKuliah? _scannedMataKuliah;
  bool _isRegistered = false;
  // This now only controls the main page loading (initial load, scan processing)
  bool _isLoading = false;
  String _message = '';

  MobileScannerController cameraController = MobileScannerController();
  final MataKuliahMahasiswaService _matakuliahmahasiswaService =
  MataKuliahMahasiswaService();
  final MataKuliahService _matakuliahService = MataKuliahService();
  final MahasiswaService _mahasiswaService = MahasiswaService();

  @override
  void initState() {
    super.initState();
    _initPage();
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  Future<void> _initPage() async {
    setState(() => _isLoading = true);
    try {
      final id = await _mahasiswaService.fetchMahasiswaId();
      if (id == null) {
        _message = 'Mahasiswa ID tidak ditemukan. Harap login kembali.';
      }
      setState(() {
        _mahasiswaId = id;
      });
    } catch (e) {
      _message = 'Gagal memuat Mahasiswa ID: $e';
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleScanResult(String rawContent) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _message = 'Memproses QR Code...';
      _scannedMataKuliah = null;
      _isRegistered = false;
    });

    if (_mahasiswaId == null) {
      setState(() {
        _message = 'Mahasiswa ID belum tersedia. Coba lagi.';
        _isLoading = false;
      });
      cameraController.start();
      return;
    }

    try {
      final matkulId = int.parse(rawContent);
      final fetchedMatkul = await _matakuliahService.fetchById(matkulId);
      final transkrip = await _matakuliahmahasiswaService.fetchTranskrip();
      final selectedMatkulIds = transkrip.map((e) => e.mataKuliah.id).toSet();
      final isCurrentlyRegistered = selectedMatkulIds.contains(matkulId);

      setState(() {
        _scannedMataKuliah = fetchedMatkul;
        _isRegistered = isCurrentlyRegistered;
        _message = '';
        _isLoading = false; // Stop loading once data is fetched
      });

      // Show dialog and restart camera when it closes
      await _showMatkulDialog();
      cameraController.start();

    } catch (e) {
      setState(() {
        _message = 'Gagal memproses QR Code: ${e.toString()}';
        _isLoading = false;
      });
      cameraController.start();
    }
  }

  // --- REFACTORED METHOD ---
  // Now uses a StatefulBuilder to manage its own button loading state
  Future<void> _showMatkulDialog() async {
    if (_scannedMataKuliah == null) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        // Use StatefulBuilder to manage state inside the dialog
        return StatefulBuilder(
          builder: (context, dialogSetState) {
            bool isDialogLoading = false; // Local loading state for the dialog buttons

            return AlertDialog(
              title: Text(_scannedMataKuliah!.nama),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Kode: ${_scannedMataKuliah!.kode}'),
                  Text('SKS: ${_scannedMataKuliah!.sks}'),
                  Text('Jadwal: ${_formatJadwal(_scannedMataKuliah!)}'),
                  const SizedBox(height: 12),
                  Text(
                    _isRegistered
                        ? 'Status: Sudah Terdaftar'
                        : 'Status: Belum Terdaftar',
                    style: TextStyle(
                      color: _isRegistered ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              actions: [
                if (!_isRegistered)
                  ElevatedButton.icon(
                    icon: const Icon(Icons.app_registration),
                    label: isDialogLoading
                        ? const Text('Memproses...')
                        : const Text('Daftar'),
                    onPressed: isDialogLoading
                        ? null
                        : () async {
                      dialogSetState(() => isDialogLoading = true);
                      await _assignMataKuliah();
                      dialogSetState(() => isDialogLoading = false);
                      Navigator.of(context).pop(); // Close dialog AFTER operation
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                if (_isRegistered)
                  ElevatedButton.icon(
                    icon: const Icon(Icons.cancel),
                    label: isDialogLoading
                        ? const Text('Memproses...')
                        : const Text('Batalkan Registrasi'),
                    onPressed: isDialogLoading
                        ? null
                        : () async {
                      dialogSetState(() => isDialogLoading = true);
                      await _confirmCancel();
                      dialogSetState(() => isDialogLoading = false);
                      // _confirmCancel now handles its own pop
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Tutup'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // --- REFACTORED METHOD ---
  // No longer manages the global _isLoading state
  Future<void> _assignMataKuliah() async {
    if (_mahasiswaId == null || _scannedMataKuliah == null) return;

    try {
      final success = await _matakuliahmahasiswaService.assignMataKuliah(
        _mahasiswaId!,
        _scannedMataKuliah!.id,
      );
      if (mounted) { // Check if the widget is still in the tree
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(success
              ? 'Registrasi berhasil!'
              : 'Gagal melakukan registrasi.'),
        ));
        if (success) {
          setState(() => _isRegistered = true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: ${e.toString()}')),
        );
      }
    }
  }

  // --- REFACTORED METHOD ---
  // Now handles its own confirmation dialog and pops the main dialog
  Future<void> _confirmCancel() async {
    if (_mahasiswaId == null || _scannedMataKuliah == null) return;

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Pembatalan'),
        content: Text(
            'Anda yakin ingin membatalkan registrasi mata kuliah ${_scannedMataKuliah!.nama}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Tidak'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final success =
        await _matakuliahmahasiswaService.cancelAssignMataKuliah(
          _mahasiswaId!,
          _scannedMataKuliah!.id,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(success
                ? 'Registrasi berhasil dibatalkan.'
                : 'Gagal membatalkan registrasi.'),
          ));
          if (success) {
            setState(() => _isRegistered = false);
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Terjadi kesalahan: ${e.toString()}')),
          );
        }
      } finally {
        // Pop the main dialog (_showMatkulDialog) after the operation
        if (mounted) Navigator.of(context).pop();
      }
    } else {
      // If user cancels, just pop the main dialog
      if (mounted) Navigator.of(context).pop();
    }
  }

  String _formatJadwal(MataKuliah mk) {
    if (mk.day != null && mk.startTime != null && mk.endTime != null) {
      return '${mk.day} (${mk.startTime} - ${mk.endTime})';
    }
    return 'Jadwal tidak tersedia';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR Mata Kuliah')),
      body: Stack(
        alignment: Alignment.center,
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) {
              if (_isLoading) return; // Prevent multiple scans while processing
              final barcode = capture.barcodes.firstOrNull;
              if (barcode?.rawValue != null) {
                cameraController.stop();
                _handleScanResult(barcode!.rawValue!);
              }
            },
          ),
          // QR Code Scan Area Overlay (optional but good for UX)
          Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.green, width: 4),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          if (_isLoading) const CircularProgressIndicator(color: Colors.white),
          if (_message.isNotEmpty)
            Positioned(
              bottom: 32,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _message,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}