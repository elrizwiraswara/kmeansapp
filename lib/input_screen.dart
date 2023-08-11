// ignore: avoid_web_libraries_in_flutter, unused_import
import 'dart:html' as html;

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:excel_dart/excel_dart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:kmeansapp/analyzer.dart';
import 'package:kmeansapp/extension/capitalization.dart';
import 'package:kmeansapp/model/pasien_model.dart';
import 'package:kmeansapp/model/penyakit_model.dart';
import 'package:kmeansapp/theme/theme.dart';

class InputScreen extends StatefulWidget {
  const InputScreen({Key? key}) : super(key: key);

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final GlobalKey key = GlobalKey();
  ScrollController scrollController = ScrollController();

  TextEditingController nama = TextEditingController();
  TextEditingController jenisKelamin = TextEditingController();
  TextEditingController umur = TextEditingController();
  TextEditingController namaPenyakit = TextEditingController();
  TextEditingController lamaMengidap = TextEditingController();

  PenyakitModel? penyakitModel;
  String? selectedJenisKelamin;

  bool editData = false;
  int? dataNo;

  List<PasienModel> selectedData = [];

  String excelCellHeader(int i) {
    if (i == 0) {
      return 'id';
    }
    if (i == 1) {
      return 'nama';
    }
    if (i == 2) {
      return 'jenis_kelamin';
    }
    if (i == 3) {
      return 'umur';
    }
    if (i == 4) {
      return 'kode_penyakit';
    }
    if (i == 5) {
      return 'nama_penyakit';
    }
    if (i == 6) {
      return 'lama_mengidap';
    }

    return '';
  }

  dynamic excelCellValue(int j, PasienModel data) {
    if (j == 0) {
      return data.id;
    }
    if (j == 1) {
      return data.nama;
    }
    if (j == 2) {
      return data.jenisKelamin;
    }
    if (j == 3) {
      return data.umur;
    }
    if (j == 4) {
      return data.penyakitModel.kodePenyakit;
    }
    if (j == 5) {
      return data.penyakitModel.namaPenyakit;
    }
    if (j == 6) {
      return data.lamaMengidap;
    }

    return '';
  }

  void onTapDownload() async {
    var excel = Excel.createExcel();

    Sheet sheetObject = excel['DATA PASIEN'];
    Sheet sheetObject2 = excel['DATA PENYAKIT'];

    for (int i = 0; i < 7; i++) {
      var cell = sheetObject.cell(
        CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
      );
      cell.value = excelCellHeader(i);
      cell.cellStyle = CellStyle(backgroundColorHex: "#B0B0B0");
    }

    for (int i = 0; i < 2; i++) {
      var cell = sheetObject2.cell(
        CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
      );
      cell.value = excelCellHeader(i + 4);
      cell.cellStyle = CellStyle(backgroundColorHex: "#B0B0B0");
    }

    for (int i = 0; i < dataPasien.length; i++) {
      for (int j = 0; j < 7; j++) {
        var cell = sheetObject.cell(
          CellIndex.indexByColumnRow(columnIndex: j, rowIndex: i + 1),
        );

        cell.value = excelCellValue(j, dataPasien[i]);
      }
    }

    for (int i = 0; i < dataPenyakit.length; i++) {
      for (int j = 0; j < 2; j++) {
        var cell = sheetObject2.cell(
          CellIndex.indexByColumnRow(columnIndex: j, rowIndex: i + 1),
        );

        cell.value = j == 0 ? dataPenyakit[i].kodePenyakit : dataPenyakit[i].namaPenyakit;
      }
    }

    String now = DateTime.now().toIso8601String();
    String fileName = 'DATA-PENYAKIT-' + now;

    excel.save(fileName: "$fileName.xlsx");
  }

  void penyakitValidator() {
    if (dataPenyakit.map((e) => e.namaPenyakit).contains(namaPenyakit.text.toUpperCase())) {
      penyakitModel = dataPenyakit.firstWhere(
        (e) => e.namaPenyakit == namaPenyakit.text.toUpperCase(),
      );
    } else {
      var newData = PenyakitModel(
        kodePenyakit: dataPenyakit.length + 1,
        namaPenyakit: namaPenyakit.text.toUpperCase(),
      );

      dataPenyakit.add(newData);
      penyakitModel = newData;
    }
  }

  void onTapClear() {
    nama.clear();
    jenisKelamin.clear();
    umur.clear();
    namaPenyakit.clear();
    lamaMengidap.clear();

    penyakitModel = null;
    selectedJenisKelamin = null;
    key.currentState!.setState(() {});
    setState(() {});
  }

  void onTapCancel() {
    editData = false;
    onTapClear();
  }

  void onTapEdit(int i) {
    editData = true;

    dataNo = i;

    nama.text = dataPasien[i].nama;
    jenisKelamin.text = dataPasien[i].jenisKelamin == 'L' ? 'LAKI-LAKI' : 'PEREMPUAN';
    umur.text = dataPasien[i].umur.toString();
    namaPenyakit.text = dataPasien[i].penyakitModel.namaPenyakit;
    lamaMengidap.text = dataPasien[i].lamaMengidap.toString();

    penyakitModel = dataPasien[i].penyakitModel;
    selectedJenisKelamin = dataPasien[i].jenisKelamin;

    setState(() {});
  }

  void onTapUpdate(int i) {
    editData = false;

    penyakitValidator();

    dataPasien[i].nama = nama.text;
    dataPasien[i].jenisKelamin = selectedJenisKelamin ?? 'L';
    dataPasien[i].umur = int.parse(umur.text);
    dataPasien[i].penyakitModel = penyakitModel!;
    dataPasien[i].lamaMengidap = int.parse(lamaMengidap.text);

    onTapClear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(18),
        content: Text(
          'Data berhasil diperbarui!',
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'Montserrat'),
        ),
      ),
    );
  }

  void onTapAdd() {
    if (nama.text.isEmpty ||
        jenisKelamin.text.isEmpty ||
        umur.text.isEmpty ||
        namaPenyakit.text.isEmpty ||
        lamaMengidap.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(18),
          content: Text(
            'Semua field wajib diisi!',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Montserrat'),
          ),
        ),
      );
      return;
    }

    penyakitValidator();

    PasienModel newData = PasienModel(
      id: dataPasien.length + 1,
      nama: nama.text,
      jenisKelamin: selectedJenisKelamin!,
      umur: int.parse(umur.text),
      penyakitModel: penyakitModel!,
      lamaMengidap: int.parse(lamaMengidap.text),
      cluster: null,
      distance: null,
    );

    dataPasien.add(newData);

    onTapClear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(18),
        content: Text(
          'Data berhasil ditambah!',
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'Montserrat'),
        ),
      ),
    );
  }

  void onTapDelete(List<PasienModel> data) async {
    if (selectedData.isEmpty) {
      return;
    }

    final status = await showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: 400,
          ),
          padding: EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: AppColors.blackLv2,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Hapus Data',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 6),
              Text(
                data.length == 1
                    ? 'apakah kamu yakin ingin menghapus data ${data.first.nama}?'
                    : 'apakah kamu yakin ingin menghapus ${data.length} data ini?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white60,
                ),
              ),
              SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: EdgeInsets.all(14),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.blackLv3.withOpacity(0.84),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Batal',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 18),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        for (PasienModel d in data) {
                          dataPasien.remove(d);
                        }
                        Navigator.pop(context, 'success');
                      },
                      child: Container(
                        padding: EdgeInsets.all(14),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.blackLv3.withOpacity(0.54),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Hapus',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );

    if (status == 'success') {
      editData = false;
      selectedData.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(18),
          content: Text(
            'Data berhasil dihapus!',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Montserrat'),
          ),
        ),
      );
      setState(() {});
      onTapClear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blackLv1,
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          width: MediaQuery.of(context).size.width,
          constraints: BoxConstraints(
            minWidth: 920,
          ),
          child: Column(
            children: [
              appBar(),
              body(),
            ],
          ),
        ),
      ),
    );
  }

  Widget appBar() {
    return Container(
      constraints: BoxConstraints(
        minWidth: 1440,
      ),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
      child: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Container(
          color: Colors.transparent,
          padding: EdgeInsets.all(2),
          child: Row(
            children: [
              Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Update Data',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget body() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18.0),
        constraints: BoxConstraints(
          minWidth: 1440,
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.blackLv2,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(
                        editData ? Icons.edit_note_rounded : Icons.add,
                        color: Colors.white70,
                        size: editData ? 18 : 14,
                      ),
                      SizedBox(width: 6),
                      Text(
                        editData ? 'Edit Data No. ${dataNo! + 1}' : 'Tambah Data',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 22),
                  fieldsWidget(),
                  SizedBox(height: 22),
                  saveButton(),
                ],
              ),
            ),
            SizedBox(height: 22),
            dataTable(),
          ],
        ),
      ),
    );
  }

  Widget fieldsWidget() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nama Pasien',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: nama,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.87),
                ),
                inputFormatters: [
                  UpperCaseTextFormatter(),
                ],
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 16,
                  ),
                  filled: true,
                  fillColor: AppColors.blackLv1.withOpacity(0.84),
                  hintText: 'nama pasien...',
                  hintStyle: TextStyle(
                    fontSize: 14,
                    color: Colors.white24,
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Jenis Kelamin',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 10),
              DropdownButtonFormField2(
                key: key,
                isDense: false,
                buttonPadding: EdgeInsets.fromLTRB(16, 0, 16, 3),
                alignment: Alignment.centerLeft,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.87),
                ),
                decoration: InputDecoration(
                  filled: true,
                  contentPadding: EdgeInsets.zero,
                  fillColor: AppColors.blackLv1.withOpacity(0.84),
                  hintText: 'jenis kelamin',
                  hintStyle: TextStyle(
                    fontSize: 14,
                    color: Colors.white24,
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                dropdownDecoration: BoxDecoration(
                  color: AppColors.blackLv2,
                  border: Border.all(
                    width: 1,
                    color: AppColors.blackLv2,
                  ),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(8),
                  ),
                ),
                // dropdownMaxHeight: 300,
                // scrollbarThickness: 3,
                hint: Text(
                  'jenis kelamin...',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 14,
                    color: Colors.white24,
                  ),
                ),
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 20,
                  color: AppColors.blackLv3,
                ),
                value: selectedJenisKelamin == 'L'
                    ? 'LAKI-LAKI'
                    : selectedJenisKelamin == 'P'
                        ? 'PEREMPUAN'
                        : null,
                items: ['LAKI-LAKI', 'PEREMPUAN']
                    .map(
                      (i) => DropdownMenuItem(
                        value: i,
                        child: Text(
                          i,
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.87),
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  selectedJenisKelamin = value == 'LAKI-LAKI' ? 'L' : 'P';
                  jenisKelamin.text = (value ?? '').toString();
                  setState(() {});
                },
                onSaved: (value) {
                  selectedJenisKelamin = value == 'LAKI-LAKI' ? 'L' : 'P';
                  jenisKelamin.text = (value ?? '').toString();
                  setState(() {});
                },
              ),
            ],
          ),
        ),
        SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Umur',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: umur,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.87),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 16,
                  ),
                  filled: true,
                  fillColor: AppColors.blackLv1.withOpacity(0.84),
                  hintText: 'umur...',
                  hintStyle: TextStyle(
                    fontSize: 14,
                    color: Colors.white24,
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nama Penyakit',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 10),
              TypeAheadField(
                textFieldConfiguration: TextFieldConfiguration(
                  controller: namaPenyakit,
                  autofocus: false,
                  textInputAction: TextInputAction.search,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.87),
                  ),
                  inputFormatters: [
                    UpperCaseTextFormatter(),
                  ],
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 16,
                    ),
                    filled: true,
                    fillColor: AppColors.blackLv1.withOpacity(0.84),
                    hintText: 'nama penyakit...',
                    hintStyle: TextStyle(
                      fontSize: 14,
                      color: Colors.white24,
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    suffixIcon: GestureDetector(
                      onTap: () {
                        namaPenyakit.clear();
                        setState(() {});
                      },
                      child: Icon(
                        namaPenyakit.text.isNotEmpty ? Icons.clear : Icons.keyboard_arrow_down_rounded,
                        size: 20,
                        color: AppColors.blackLv3,
                      ),
                    ),
                    suffixIconConstraints: const BoxConstraints(
                      minHeight: 42,
                      minWidth: 42,
                    ),
                  ),
                ),
                suggestionsCallback: (pattern) async {
                  if (pattern == '') {
                    return const Iterable<PenyakitModel>.empty();
                  }

                  return dataPenyakit.where((PenyakitModel option) {
                    return RegExp(
                      pattern,
                      caseSensitive: false,
                    ).hasMatch(option.namaPenyakit);
                  });
                },
                suggestionsBoxDecoration: SuggestionsBoxDecoration(
                  color: AppColors.blackLv2,
                  borderRadius: BorderRadius.circular(12),
                ),
                itemBuilder: (context, PenyakitModel suggestion) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      suggestion.namaPenyakit,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.87),
                      ),
                    ),
                  );
                },
                onSuggestionSelected: (PenyakitModel suggestion) {
                  namaPenyakit.text = suggestion.namaPenyakit;
                  penyakitModel = suggestion;
                  setState(() {});
                },
                noItemsFoundBuilder: (context) {
                  return SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
        SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Lama Mengidap (Hari)',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: lamaMengidap,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.87),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 16,
                  ),
                  filled: true,
                  fillColor: AppColors.blackLv1.withOpacity(0.84),
                  hintText: 'lama mengidap...',
                  hintStyle: TextStyle(
                    fontSize: 14,
                    color: Colors.white24,
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget saveButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: () {
            if (editData) {
              if (dataNo == null) {
                editData = false;
                onTapClear();
                return;
              }

              onTapUpdate(dataNo!);
            } else {
              onTapAdd();
            }
          },
          child: Container(
            width: 150,
            padding: EdgeInsets.all(12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.blackLv3.withOpacity(0.84),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  editData ? Icons.check_circle_rounded : Icons.check,
                  color: Colors.white70,
                  size: 14,
                ),
                SizedBox(width: 6),
                Text(
                  editData ? 'Perbarui' : 'Tambah',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 18),
        GestureDetector(
          onTap: () {
            onTapClear();
          },
          child: Container(
            width: 150,
            padding: EdgeInsets.all(12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.blackLv3.withOpacity(0.44),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.clear_rounded,
                  color: Colors.white70,
                  size: 14,
                ),
                SizedBox(width: 6),
                Text(
                  'Clear',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        editData ? SizedBox(width: 18) : SizedBox.shrink(),
        editData
            ? GestureDetector(
                onTap: () {
                  onTapCancel();
                },
                child: Container(
                  width: 150,
                  padding: EdgeInsets.all(12),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.blackLv3.withOpacity(0.44),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.cancel,
                        color: Colors.white70,
                        size: 14,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Batal',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : SizedBox.shrink()
      ],
    );
  }

  Widget dataTable() {
    return Expanded(
      child: Container(
        padding: EdgeInsets.fromLTRB(18, 18, 18, 0),
        decoration: BoxDecoration(
          color: AppColors.blackLv2,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.description_outlined,
                      color: Colors.white70,
                      size: 14,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Semua Data',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () async {
                    onTapDownload();
                  },
                  child: Container(
                    width: 120,
                    padding: EdgeInsets.all(8),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.blackLv3.withOpacity(0.44),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.download_rounded,
                          color: Colors.white70,
                          size: 14,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Download',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 14),
            action(),
            SizedBox(height: 18),
            header(),
            Expanded(
              child: dataPasien.isNotEmpty
                  ? ListView.builder(
                      controller: scrollController,
                      shrinkWrap: true,
                      itemCount: dataPasien.length,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, i) {
                        return row(i);
                      },
                    )
                  : Center(
                      child: Text(
                        '(Kosong)',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget action() {
    return Row(
      children: [
        GestureDetector(
          onTap: () async {
            if (selectedData.length == 1) {
              onTapEdit(dataPasien.indexWhere((e) => e == selectedData.first));
            }
          },
          child: Container(
            width: 85,
            padding: EdgeInsets.all(6),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selectedData.length == 1
                  ? AppColors.yellowLv1.withOpacity(0.10)
                  : AppColors.blackLv3.withOpacity(0.10),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.edit_note_rounded,
                  color: selectedData.length == 1 ? AppColors.yellowLv1 : AppColors.blackLv4.withOpacity(0.50),
                  size: 13,
                ),
                SizedBox(width: 6),
                Text(
                  'Edit',
                  style: TextStyle(
                    fontSize: 11,
                    color: selectedData.length == 1 ? AppColors.yellowLv1 : AppColors.blackLv4.withOpacity(0.50),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 8),
        GestureDetector(
          onTap: () async {
            onTapDelete(selectedData);
          },
          child: Container(
            width: 85,
            padding: EdgeInsets.all(6),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color:
                  selectedData.length >= 1 ? AppColors.redLv1.withOpacity(0.10) : AppColors.blackLv3.withOpacity(0.10),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.delete_rounded,
                  color: selectedData.length >= 1 ? AppColors.redLv1 : AppColors.blackLv4.withOpacity(0.50),
                  size: 13,
                ),
                SizedBox(width: 6),
                Text(
                  'Hapus',
                  style: TextStyle(
                    fontSize: 11,
                    color: selectedData.length >= 1 ? AppColors.redLv1 : AppColors.blackLv4.withOpacity(0.50),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 12),
      ],
    );
  }

  Widget row(int i) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 1,
            color: AppColors.blackLv1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            margin: EdgeInsets.only(right: 18),
            child: Checkbox(
              activeColor: AppColors.blackLv1,
              value: selectedData.contains(dataPasien[i]),
              visualDensity: VisualDensity(horizontal: -4, vertical: -4),
              onChanged: (value) {
                if (value != null) {
                  if (value && !selectedData.contains(dataPasien[i])) {
                    selectedData.add(dataPasien[i]);
                  } else {
                    selectedData.remove(dataPasien[i]);
                  }
                  setState(() {});
                }
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              alignment: Alignment.centerLeft,
              child: Text(
                (i + 1).toString(),
                textAlign: TextAlign.left,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 12,
            child: Container(
              alignment: Alignment.centerLeft,
              child: Text(
                dataPasien[i].nama,
                textAlign: TextAlign.left,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              alignment: Alignment.centerLeft,
              child: Text(
                dataPasien[i].jenisKelamin,
                textAlign: TextAlign.left,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              alignment: Alignment.centerLeft,
              child: Text(
                dataPasien[i].umur.toString(),
                textAlign: TextAlign.left,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 12,
            child: Container(
              alignment: Alignment.centerLeft,
              child: Text(
                dataPasien[i].penyakitModel.namaPenyakit,
                textAlign: TextAlign.left,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              alignment: Alignment.centerLeft,
              child: Text(
                dataPasien[i].lamaMengidap.toString(),
                textAlign: TextAlign.left,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget header() {
    return Container(
      padding: EdgeInsets.fromLTRB(12, 0, 12, 14),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 1,
            color: AppColors.blackLv1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            margin: EdgeInsets.only(right: 18),
            child: Checkbox(
              activeColor: AppColors.blackLv1,
              value: dataPasien.isNotEmpty && selectedData.length == dataPasien.length,
              visualDensity: VisualDensity(horizontal: -4, vertical: -4),
              onChanged: (value) {
                if (value != null) {
                  if (value) {
                    if (selectedData.isEmpty) {
                      selectedData.addAll(dataPasien);
                    } else {
                      selectedData.clear();
                      selectedData.addAll(dataPasien);
                    }
                  } else {
                    selectedData.clear();
                  }
                  setState(() {});
                }
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              alignment: Alignment.centerLeft,
              child: Text(
                'NO',
                textAlign: TextAlign.left,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.87),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 12,
            child: Container(
              alignment: Alignment.centerLeft,
              child: Text(
                'NAMA',
                textAlign: TextAlign.left,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.87),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(right: 8),
              child: Text(
                'JENIS KELAMIN',
                textAlign: TextAlign.left,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.87),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              alignment: Alignment.centerLeft,
              child: Text(
                'UMUR',
                textAlign: TextAlign.left,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.87),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 12,
            child: Container(
              alignment: Alignment.centerLeft,
              child: Text(
                'NAMA PENYAKIT',
                textAlign: TextAlign.left,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.87),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              alignment: Alignment.centerLeft,
              child: Text(
                'LAMA MENGIDAP',
                textAlign: TextAlign.left,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.87),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
