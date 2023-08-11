import 'dart:convert';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:dolumns/dolumns.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'config/app_config.dart';
import 'extension/round.dart';
import 'model/chart_model.dart';
import 'model/pasien_model.dart';
import 'model/penyakit_model.dart';
import 'model/user_model.dart';
import 'theme/theme.dart';

Function deepEquality = const DeepCollectionEquality().equals;

int k = 2;
int maxIteration = 100;
double pointsRadius = 4;

List<PasienModel> dataPasien = [];
List<PenyakitModel> dataPenyakit = [];

List<List<PasienModel>> iterasiDataPenyakit = [];
List<ChartModel> caseByDiseases = [];

double higestCase = 0;
List<ChartModel> higestCaseC0 = [];
List<ChartModel> higestCaseC1 = [];

void clearData() {
  iterasiDataPenyakit = [];
  caseByDiseases = [];
  higestCase = 0;
  higestCaseC0 = [];
  higestCaseC1 = [];
}

Future<void> getData() async {
  var rawDataUser = await rootBundle.loadString('assets/data/user.json');
  var rawDataPasien = await rootBundle.loadString('assets/data/data_pasien.json');
  var rawDataPenyakit = await rootBundle.loadString('assets/data/data_penyakit.json');

  var decodedDataUser = json.decode(rawDataUser);
  var decodedDataPasien = json.decode(rawDataPasien) as List;
  var decodedDataPenyakit = json.decode(rawDataPenyakit) as List;

  AppConfig.admin = UserModel.fromJson(decodedDataUser);

  for (var data in decodedDataPasien) {
    print('DECODED DATA PASIEN = $data');

    PasienModel model = PasienModel.fromJson(data);
    dataPasien.add(model);
  }

  for (var data in decodedDataPenyakit) {
    print('DECODED DATA PENYAKIT = $data');

    PenyakitModel model = PenyakitModel.fromJson(data);
    dataPenyakit.add(model);
  }
}

Future<void> analyze() async {
  print('[ITERATION ${iterasiDataPenyakit.length + 1} START]');

  if (iterasiDataPenyakit.length > 0) {
    List<List<double>> ci = [];

    double c01 = dataPasien.where((e) => e.cluster == 0).map((j) => j.umur).reduce((x, y) => x + y) /
        dataPasien.where((e) => e.cluster == 0).map((j) => j.umur).length;
    double c02 = dataPasien.where((e) => e.cluster == 0).map((j) => j.lamaMengidap).reduce((x, y) => x + y) /
        dataPasien.where((e) => e.cluster == 0).map((j) => j.lamaMengidap).length;

    double c11 = dataPasien.where((e) => e.cluster == 1).map((j) => j.umur).reduce((x, y) => x + y) /
        dataPasien.where((e) => e.cluster == 1).map((j) => j.umur).length;
    double c12 = dataPasien.where((e) => e.cluster == 1).map((j) => j.lamaMengidap).reduce((x, y) => x + y) /
        dataPasien.where((e) => e.cluster == 1).map((j) => j.lamaMengidap).length;

    ci = [
      [c01.toPrecision(3), c02.toPrecision(3)],
      [c11.toPrecision(3), c12.toPrecision(3)],
    ];

    print('[NEW CENTROID Ci = $ci]');

    calculateEuclideanDistance(ci[0], ci[1]);
  } else {
    List<List<double>> c0 = [
      [
        dataPasien
            .map((e) => e.umur)
            .sorted((a, b) => a.compareTo(b))[((dataPasien.length + 1) / 2).floor()]
            .toDouble(),
        dataPasien.map((e) => e.lamaMengidap).reduce((x, y) => x > y ? y : x).toDouble()
      ],
      [
        dataPasien
            .map((e) => e.umur)
            .sorted((a, b) => a.compareTo(b))[((dataPasien.length + 1) / 2).floor()]
            .toDouble(),
        dataPasien.map((e) => e.lamaMengidap).reduce((x, y) => x > y ? x : y).toDouble()
      ],
    ];

    print('[INIT CENTROID C0 = $c0]');

    calculateEuclideanDistance(c0[0], c0[1]);
  }
}

void calculateEuclideanDistance(List<double> c0, List<double> c1) async {
  for (int i = 0; i < dataPasien.length; i++) {
    double di1 = sqrt(pow(dataPasien[i].umur - c0[0], 2) + pow(dataPasien[i].lamaMengidap - c0[1], 2)).toPrecision(3);
    double di2 = sqrt(pow(dataPasien[i].umur - c1[0], 2) + pow(dataPasien[i].lamaMengidap - c1[1], 2)).toPrecision(3);

    List<double> distance = [di1, di2];
    int cluster = di1.compareTo(di2) == -1 ? 0 : 1;

    dataPasien[i] = PasienModel(
      id: dataPasien[i].id,
      nama: dataPasien[i].nama,
      jenisKelamin: dataPasien[i].jenisKelamin,
      umur: dataPasien[i].umur,
      penyakitModel: dataPasien[i].penyakitModel,
      lamaMengidap: dataPasien[i].lamaMengidap,
      cluster: cluster,
      distance: distance,
    );
  }

  clustering();
}

void clustering() async {
  List<List<double>> oldDistance = [];
  List<List<double>> newDistance = [];
  List<List<int>> oldCluster = [];
  List<List<int>> newCluster = [];

  for (PasienModel xn in dataPasien) {
    int cluster0 = 0;
    int cluster1 = 0;

    if (xn.cluster == 0) {
      cluster0 = 1;
    } else {
      cluster1 = 1;
    }

    newDistance.add([xn.distance![0], xn.distance![1]]);
    newCluster.add([cluster0, cluster1]);
  }

  if (iterasiDataPenyakit.length > 0) {
    for (PasienModel xb in iterasiDataPenyakit[iterasiDataPenyakit.length - 1]) {
      int cluster0 = 0;
      int cluster1 = 0;

      if (xb.cluster == 0) {
        cluster0 = 1;
      } else {
        cluster1 = 1;
      }

      oldDistance.add([xb.distance![0], xb.distance![1]]);
      oldCluster.add([cluster0, cluster1]);
    }

    if (deepEquality(oldCluster, newCluster) || (iterasiDataPenyakit.length + 1) >= maxIteration) {
      printClusteringResult(newDistance, newCluster);

      print('[IS THERE ANY DATA CHANGE? ${!deepEquality(oldCluster, newCluster)}]'.toUpperCase());
      print('[ITERATION END]');
      print('----------------------------------------------------------------');

      // END ITERATION
      return;
    } else {
      printClusteringResult(newDistance, newCluster);

      print('[IS THERE ANY DATA CHANGE? ${!deepEquality(oldCluster, newCluster)}]'.toUpperCase());

      iterasiDataPenyakit.add(dataPasien.toList());

      await analyze();
    }
  } else {
    printClusteringResult(newDistance, newCluster);
    iterasiDataPenyakit.add(dataPasien.toList());

    await analyze();
  }
}

Future<void> sumCaseByDiseases() async {
  for (int i = 0; i < dataPasien.length; i++) {
    if (dataPasien[i].cluster != null) {
      bool isHasAdded = false;

      for (ChartModel data in caseByDiseases) {
        if (data.x.kodePenyakit == dataPasien[i].penyakitModel.kodePenyakit) {
          isHasAdded = true;
        }
      }

      if (isHasAdded) {
        if (dataPasien[i].cluster == 0) {
          caseByDiseases.where((e) => e.x.kodePenyakit == dataPasien[i].penyakitModel.kodePenyakit).first.c0 += 1;
        }
        if (dataPasien[i].cluster == 1) {
          caseByDiseases.where((e) => e.x.kodePenyakit == dataPasien[i].penyakitModel.kodePenyakit).first.c1 += 1;
        }
      } else {
        int sumC0 = 0;
        int sumC1 = 0;

        if (dataPasien[i].cluster == 0) {
          sumC0 += 1;
        }
        if (dataPasien[i].cluster == 1) {
          sumC1 += 1;
        }

        caseByDiseases.add(ChartModel(dataPasien[i].penyakitModel, sumC0, sumC1));
      }
    }
  }
}

Future<void> sumHigestCase() async {
  List<int> cases = [];

  for (ChartModel data in caseByDiseases) {
    cases.add(data.c0 + data.c1);
  }

  higestCase = cases.reduce((x, y) => x > y ? x : y).toDouble();

  higestCaseC0.addAll(
    caseByDiseases.where((e) => e.c0 == caseByDiseases.map((e) => e.c0).reduce((x, y) => x > y ? x : y)),
  );
  higestCaseC1.addAll(
    caseByDiseases.where((e) => e.c1 == caseByDiseases.map((e) => e.c1).reduce((x, y) => x > y ? x : y)),
  );
}

void printClusteringResult(
  List<List<double>> newDistance,
  List<List<int>> newCluster,
) {
  List<List<String>> printNewData = [
    ['NO', 'UMUR', 'LAMA MENGIDAP', 'DISTANCE C0', 'DISTANCE C1', 'C0', 'C1'],
  ];

  for (int i = 0; i < dataPasien.length; i++) {
    printNewData.add([
      '${i + 1}',
      '${dataPasien[i].umur}',
      '${dataPasien[i].lamaMengidap}',
      '${newDistance[i][0]}',
      '${newDistance[i][1]}',
      '${newCluster[i][0] == 1 ? '*' : ''}',
      '${newCluster[i][1] == 1 ? '*' : ''}'
    ]);
  }

  print(dolumnify(printNewData, columnSplitter: ' | ', headerIncluded: true, headerSeparator: '-'));

  print('----------------------------------------------------------------');
  print('TOTAL ITEMS               = ${dataPasien.length} items');
  print('CLUSTER 1                 = ${newCluster.map((e) => e[0]).reduce((x, y) => x + y)} items');
  print('CLUSTER 2                 = ${newCluster.map((e) => e[1]).reduce((x, y) => x + y)} items');
  print('----------------------------------------------------------------');
}

void printFinalResult() {
  // RESULT
  int totalItemC0 = dataPasien.where((e) => e.cluster == 0).length;
  double c0Mean = dataPasien.where((e) => e.cluster == 0).map((e) => e.distance![0]).reduce((x, y) => x + y) /
      dataPasien.where((e) => e.cluster == 0).length;

  int totalItemC1 = dataPasien.where((e) => e.cluster == 1).length;
  double c1Mean = dataPasien.where((e) => e.cluster == 1).map((e) => e.distance![1]).reduce((x, y) => x + y) /
      dataPasien.where((e) => e.cluster == 1).length;

  double cenX0c0 = dataPasien.where((e) => e.cluster == 0).map((e) => e.umur).reduce((x, y) => x + y) /
      dataPasien.where((e) => e.cluster == 0).map((e) => e.umur).length;
  double cenX0c1 = dataPasien.where((e) => e.cluster == 1).map((e) => e.umur).reduce((x, y) => x + y) /
      dataPasien.where((e) => e.cluster == 1).map((e) => e.umur).length;
  double cenX1c0 = dataPasien.where((e) => e.cluster == 0).map((e) => e.lamaMengidap).reduce((x, y) => x + y) /
      dataPasien.where((e) => e.cluster == 0).map((e) => e.lamaMengidap).length;
  double cenX1c1 = dataPasien.where((e) => e.cluster == 1).map((e) => e.lamaMengidap).reduce((x, y) => x + y) /
      dataPasien.where((e) => e.cluster == 1).map((e) => e.lamaMengidap).length;

  print('TOTAL ITERATIONS          = ${iterasiDataPenyakit.length + 1}');
  print('TOTAL ITEMS               = ${dataPasien.length} items');
  print('CLUSTER 1                 = $totalItemC0 items');
  print('CLUSTER 2                 = $totalItemC1 items');
  print('MEAN CLUSTER 1            = ${c0Mean.toPrecision(3)}');
  print('MEAN CLUSTER 2            = ${c1Mean.toPrecision(3)}');
  print('CENTROID UMUR C0          = ${cenX0c0.toPrecision(3)}');
  print('CENTROID UMUR C1          = ${cenX0c1.toPrecision(3)}');
  print('CENTROID LAMA MENGIDAP C0 = ${cenX1c0.toPrecision(3)}');
  print('CENTROID LAMA MENGIDAP C1 = ${cenX1c1.toPrecision(3)}');
}

List<ScatterSpot> data() {
  List<ScatterSpot> scatters = [];

  // Points
  for (int i = 0; i < dataPasien.length; i++) {
    scatters.add(ScatterSpot(
      dataPasien[i].umur.toDouble(),
      dataPasien[i].lamaMengidap.toDouble(),
      color: pointColor(dataPasien[i].cluster),
      radius: pointsRadius,
    ));
  }

  double cenX0c0 = dataPasien.where((e) => e.cluster == 0).map((e) => e.umur).reduce((x, y) => x + y) /
      dataPasien.where((e) => e.cluster == 0).map((e) => e.umur).length;
  double cenX1c0 = dataPasien.where((e) => e.cluster == 0).map((e) => e.lamaMengidap).reduce((x, y) => x + y) /
      dataPasien.where((e) => e.cluster == 0).map((e) => e.lamaMengidap).length;

  scatters.add(ScatterSpot(
    cenX0c0,
    cenX1c0,
    color: Colors.white,
    radius: pointsRadius,
  ));

  double cenX0c1 = dataPasien.where((e) => e.cluster == 1).map((e) => e.umur).reduce((x, y) => x + y) /
      dataPasien.where((e) => e.cluster == 1).map((e) => e.umur).length;
  double cenX1c1 = dataPasien.where((e) => e.cluster == 1).map((e) => e.lamaMengidap).reduce((x, y) => x + y) /
      dataPasien.where((e) => e.cluster == 1).map((e) => e.lamaMengidap).length;

  scatters.add(ScatterSpot(
    cenX0c1,
    cenX1c1,
    color: Colors.white,
    radius: pointsRadius,
  ));

  return scatters;
}

Color pointColor(i) {
  if (i == 0) {
    return AppColors.yellowLv1;
  }
  if (i == 1) {
    return AppColors.redLv1;
  }
  if (i == 2) {
    return AppColors.whiteLv3;
  }
  if (i == 3) {
    return AppColors.brownLv1;
  }

  return AppColors.blackLv1;
}
