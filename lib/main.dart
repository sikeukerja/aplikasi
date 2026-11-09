import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart' as ex;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

void main() {
  runApp(const SpdEditorApp());
}

String formatRupiah(num number) {
  final formatter = NumberFormat('#,###', 'id_ID');
  return formatter.format(number).replaceAll(',', '.');
}

class SpdEditorApp extends StatefulWidget {
  const SpdEditorApp({super.key});

  @override
  State<SpdEditorApp> createState() => _SpdEditorAppState();
}

class _SpdEditorAppState extends State<SpdEditorApp> {
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SPD Editor Mobile',
      debugShowCheckedModeBanner: false,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
      ),
      home: MainHomePage(
        onThemeChanged: (val) {
          setState(() {
            _isDarkMode = val;
          });
        },
        isDarkMode: _isDarkMode,
      ),
    );
  }
}

class MainHomePage extends StatefulWidget {
  final ValueChanged<bool> onThemeChanged;
  final bool isDarkMode;

  const MainHomePage({
    super.key,
    required this.onThemeChanged,
    required this.isDarkMode,
  });

  @override
  State<MainHomePage> createState() => _MainHomePageState();
}

class _MainHomePageState extends State<MainHomePage> {
  int _selectedIndex = 0;

  Map<String, dynamic> data = {
    "header": {
      "baris1": "KEPOLISIAN NEGARA REPUBLIK INDONESIA",
      "baris2": "DAERAH ACEH",
      "baris3": "RESOR ACEH TAMIANG",
      "judul": "DAFTAR LAMPIRAN RINCIAN PENERIMA",
    },
    "rows": [
      {
        "nama": "SIMSON, S.H.",
        "pangkat": "KOMPOL",
        "tujuan": "Banda Aceh",
        "tanggal": DateTime.now().toIso8601String().substring(0, 10),
        "lama": 11,
        "auto": true,
        "tarif": 50000,
        "uang_harian": 550000,
        "penginapan": 710000,
        "transport": 400000,
        "ikut": false,
      },
      {
        "nama": "ROY ALVAN NOOR PANE, S.H.",
        "pangkat": "BRIGADIR",
        "tujuan": "Banda Aceh",
        "tanggal": DateTime.now().toIso8601String().substring(0, 10),
        "lama": 11,
        "auto": true,
        "tarif": 40000,
        "uang_harian": 440000,
        "penginapan": 0,
        "transport": 400000,
        "ikut": true,
      },
    ],
    "footer": {
      "kiri_baris1": "Menyetujui :",
      "kiri_baris2": "Kuasa Pengguna Anggaran",
      "kiri_baris3": "Polres Aceh Tamiang",
      "kiri_nama": "ROBBY ANSYARI, S.I.K., M.H.",
      "kiri_pangkat": "AJUN KOMISARIS BESAR POLISI",
      "kiri_nrp": "85011696",
      "tempat": "Karang Baru",
      "tanggal": DateTime.now().toIso8601String().substring(0, 10),
      "kanan_jabatan": "Kasikeu Polres Aceh Tamiang",
      "kanan_nama": "WILLIARDY TANJUNG, S.H.",
      "kanan_pangkat": "AJUN INSPEKTUR POLISI DUA",
      "kanan_nrp": "86091264",
    },
    "rincian": {
      "nomor": "74",
      "bulan": "X",
      "transport_mode": "pp",
      "malam": 0,
      "dibayar": "",
      "jabatan_bendahara": "Bendahara Pengeluaran",
      "jabatan_kepala": "",
      "penerima_nrp": "",
      "penerima_nama": "",
      "penerima_pangkat": "",
    }
  };

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      DaftarPenerimaTab(data: data, onUpdate: () => setState(() {})),
      RincianBiayaTab(data: data, onUpdate: () => setState(() {})),
      KwitansiTab(data: data, onUpdate: () => setState(() {})),
      PengaturanTab(
        data: data,
        onUpdate: () => setState(() {}),
        isDarkMode: widget.isDarkMode,
        onThemeChanged: widget.onThemeChanged,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('SPD Editor - Polres Aceh Tamiang'),
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => widget.onThemeChanged(!widget.isDarkMode),
            tooltip: 'Ganti Tema',
          )
        ],
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (idx) => setState(() => _selectedIndex = idx),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.people), label: 'Penerima'),
          NavigationDestination(
              icon: Icon(Icons.receipt_long), label: 'Rincian'),
          NavigationDestination(
              icon: Icon(Icons.print), label: 'Kwitansi'),
          NavigationDestination(
              icon: Icon(Icons.settings), label: 'Pengaturan'),
        ],
      ),
    );
  }
}

class DaftarPenerimaTab extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onUpdate;

  const DaftarPenerimaTab({super.key, required this.data, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    List rows = data["rows"];

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Daftar Penerima (${rows.length} Orang)",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                onPressed: () => _editRow(context, null, rows.isEmpty ? null : rows[0]),
                icon: const Icon(Icons.add),
                label: const Text("Tambah"),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: rows.isEmpty
                ? const Center(child: Text("Belum ada data penerima."))
                : ListView.builder(
                    itemCount: rows.length,
                    itemBuilder: (context, index) {
                      var r = rows[index];
                      int jumlah = (r["auto"] ? (r["tarif"] * r["lama"]) : r["uang_harian"]) +
                          (r["penginapan"] as int) +
                          (r["transport"] as int);

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          title: Text("${index + 1}. ${r["nama"]}",
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                              "Pangkat: ${r["pangkat"]} | Tujuan: ${r["tujuan"]}\nTotal: Rp ${formatRupiah(jumlah)}"),
                          isThreeLine: true,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _editRow(context, index, rows[0]),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  rows.removeAt(index);
                                  onUpdate();
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _editRow(BuildContext context, int? index, Map? firstRow) {
    bool isEdit = index != null;
    Map rowData = isEdit
        ? Map.from(data["rows"][index])
        : {
            "nama": "",
            "pangkat": "BRIPDA",
            "tujuan": firstRow?["tujuan"] ?? "Banda Aceh",
            "tanggal": DateTime.now().toIso8601String().substring(0, 10),
            "lama": firstRow?["lama"] ?? 5,
            "auto": true,
            "tarif": 40000,
            "uang_harian": 200000,
            "penginapan": 0,
            "transport": 300000,
            "ikut": index == 0 ? false : true,
          };

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEdit ? "Ubah Penerima" : "Tambah Penerima"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: "Nama Lengkap"),
                  controller: TextEditingController(text: rowData["nama"]),
                  onChanged: (v) => rowData["nama"] = v,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: "Pangkat"),
                  controller: TextEditingController(text: rowData["pangkat"]),
                  onChanged: (v) => rowData["pangkat"] = v,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: "Tujuan"),
                  controller: TextEditingController(text: rowData["tujuan"]),
                  onChanged: (v) => rowData["tujuan"] = v,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: "Lama (Hari)"),
                  keyboardType: TextInputType.number,
                  controller: TextEditingController(text: rowData["lama"].toString()),
                  onChanged: (v) => rowData["lama"] = int.tryParse(v) ?? 1,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: "Tarif Uang Harian/Hari"),
                  keyboardType: TextInputType.number,
                  controller: TextEditingController(text: rowData["tarif"].toString()),
                  onChanged: (v) => rowData["tarif"] = int.tryParse(v) ?? 0,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: "Transport (Rp)"),
                  keyboardType: TextInputType.number,
                  controller: TextEditingController(text: rowData["transport"].toString()),
                  onChanged: (v) => rowData["transport"] = int.tryParse(v) ?? 0,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () {
                if (isEdit) {
                  data["rows"][index] = rowData;
                } else {
                  data["rows"].add(rowData);
                }
                onUpdate();
                Navigator.pop(context);
              },
              child: const Text("Simpan"),
            ),
          ],
        );
      },
    );
  }
}

class RincianBiayaTab extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onUpdate;

  const RincianBiayaTab({super.key, required this.data, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    var rc = data["rincian"];
    num totalBiaya = 0;
    for (var r in data["rows"]) {
      num uh = r["auto"] ? (r["tarif"] * r["lama"]) : r["uang_harian"];
      totalBiaya += uh + (r["penginapan"] as num) + (r["transport"] as num);
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          const Text("Pengaturan Lampiran SPD",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          TextField(
            decoration: const InputDecoration(labelText: "Nomor SPD (Angka)"),
            controller: TextEditingController(text: rc["nomor"]),
            onChanged: (v) {
              rc["nomor"] = v;
              onUpdate();
            },
          ),
          TextField(
            decoration: const InputDecoration(labelText: "Bulan Romawi (Contoh: X)"),
            controller: TextEditingController(text: rc["bulan"]),
            onChanged: (v) {
              rc["bulan"] = v;
              onUpdate();
            },
          ),
          const SizedBox(height: 20),
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Ringkasan Rincian Biaya",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text("Total Penerima: ${data["rows"].length} Orang"),
                  Text("Total Anggaran: Rp ${formatRupiah(totalBiaya)}",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            onPressed: () => _exportExcel(context),
            icon: const Icon(Icons.table_chart),
            label: const Text("Ekspor Rincian ke Excel (.xlsx)"),
          ),
        ],
      ),
    );
  }

  Future<void> _exportExcel(BuildContext context) async {
    try {
      var excel = ex.Excel.createExcel();
      ex.Sheet sheetObject = excel['Rincian'];
      sheetObject.appendRow([ex.TextCellValue("RINCIAN BIAYA PERJALANAN DINAS")]);
      sheetObject.appendRow([ex.TextCellValue("Nomor SPD: SPD/${data["rincian"]["nomor"]}/${data["rincian"]["bulan"]}/KEU.9/2026")]);
      
      var directory = await getApplicationDocumentsDirectory();
      String outputFile = "${directory.path}/Rincian_Biaya_${DateTime.now().millisecondsSinceEpoch}.xlsx";
      
      File(outputFile)
        ..createSync(recursive: true)
        ..writeAsBytesSync(excel.encode()!);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Berhasil disimpan ke: $outputFile")),
      );
      OpenFilex.open(outputFile);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal ekspor: $e")),
      );
    }
  }
}

class KwitansiTab extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onUpdate;

  const KwitansiTab({super.key, required this.data, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    num totalBiaya = 0;
    for (var r in data["rows"]) {
      num uh = r["auto"] ? (r["tarif"] * r["lama"]) : r["uang_harian"];
      totalBiaya += uh + (r["penginapan"] as num) + (r["transport"] as num);
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          const Text("Kwitansi Umum (Bentuk KU-17)",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          TextField(
            decoration: const InputDecoration(labelText: "Untuk Keperluan / Maksud Perjalanan"),
            onChanged: (v) {},
          ),
          const SizedBox(height: 10),
          Text("Jumlah Uang: Rp ${formatRupiah(totalBiaya)}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => _exportPdf(context),
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text("Cetak / Ekspor Kwitansi ke PDF"),
          ),
        ],
      ),
    );
  }

  Future<void> _exportPdf(BuildContext context) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text("KWITANSI UMUM (KU-17)", style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 20),
                pw.Text("Polres Aceh Tamiang"),
              ],
            ),
          );
        },
      ),
    );

    try {
      final output = await getTemporaryDirectory();
      final file = File("${output.path}/Kwitansi_KU17.pdf");
      await file.writeAsBytes(await pdf.save());
      OpenFilex.open(file.path);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal membuat PDF: $e")),
      );
    }
  }
}

class PengaturanTab extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onUpdate;
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  const PengaturanTab({
    super.key,
    required this.data,
    required this.onUpdate,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    var h = data["header"];
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          const Text("Pengaturan Kop Surat & Tampilan",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          TextField(
            decoration: const InputDecoration(labelText: "Kop Baris 1"),
            controller: TextEditingController(text: h["baris1"]),
            onChanged: (v) => h["baris1"] = v,
          ),
          TextField(
            decoration: const InputDecoration(labelText: "Kop Baris 2"),
            controller: TextEditingController(text: h["baris2"]),
            onChanged: (v) => h["baris2"] = v,
          ),
          TextField(
            decoration: const InputDecoration(labelText: "Kop Baris 3"),
            controller: TextEditingController(text: h["baris3"]),
            onChanged: (v) => h["baris3"] = v,
          ),
          const SizedBox(height: 20),
          SwitchListTile(
            title: const Text("Mode Gelap (Dark Mode)"),
            value: isDarkMode,
            onChanged: onThemeChanged,
          ),
        ],
      ),
    );
  }
}
