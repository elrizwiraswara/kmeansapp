import 'package:kmeansapp/model/penyakit_model.dart';

class PasienModel {
  int id;
  String nama;
  String jenisKelamin;
  int umur;
  PenyakitModel penyakitModel;
  int lamaMengidap;
  int? cluster;
  List<double>? distance;

  PasienModel({
    required this.id,
    required this.nama,
    required this.jenisKelamin,
    required this.umur,
    required this.penyakitModel,
    required this.lamaMengidap,
    required this.cluster,
    required this.distance,
  });

  factory PasienModel.fromJson(Map<String, dynamic> json) {
    return PasienModel(
      id: json['id'],
      nama: json['nama'],
      jenisKelamin: json['jenis_kelamin'],
      umur: json['umur'],
      penyakitModel: PenyakitModel(
        kodePenyakit: json['kode_penyakit'],
        namaPenyakit: json['nama_penyakit'],
      ),
      lamaMengidap: json['lama_mengidap'],
      cluster: json['cluster'],
      distance: json['distance'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'jenis_kelamin': jenisKelamin,
      'umur': umur,
      'kode_penyakit': penyakitModel.kodePenyakit,
      'nama_penyakit': penyakitModel.namaPenyakit,
      'lama_mengidap': lamaMengidap,
      'cluster': cluster,
      'distance': distance,
    };
  }
}
