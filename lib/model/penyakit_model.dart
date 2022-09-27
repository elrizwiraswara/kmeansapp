class PenyakitModel {
  int kodePenyakit;
  String namaPenyakit;

  PenyakitModel({
    required this.kodePenyakit,
    required this.namaPenyakit,
  });

  factory PenyakitModel.fromJson(Map<String, dynamic> json) {
    return PenyakitModel(
      kodePenyakit: json['kode_penyakit'],
      namaPenyakit: json['nama_penyakit'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'kode_penyakit': kodePenyakit,
      'nama_penyakit': namaPenyakit,
    };
  }
}
