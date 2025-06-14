import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/matakuliahmahasiswa.dart';

Future<void> generatePdf(List<MataKuliahMahasiswa> transkrip) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.MultiPage(
      build: (context) => [
        pw.Text(
          'Transkrip Mahasiswa',
          style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 20),
        pw.Table.fromTextArray(
          headers: ['Nama', 'Kode', 'SKS', 'UTS', 'UAS', 'Kuis', 'Total', 'Grade'],
          data: transkrip.map((data) {
            final mk = data.mataKuliah;
            return [
              mk.nama,
              mk.kode,
              mk.sks.toString(),
              data.uts.toString(),
              data.uas.toString(),
              data.kuis.toString(),
              data.total.toString(),
              data.grade ?? '-',
            ];
          }).toList(),
        ),
      ],
    ),
  );

  await Printing.layoutPdf(onLayout: (format) async => pdf.save());
}
