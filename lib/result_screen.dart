import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'analyzer.dart';
import 'config/app_config.dart';
import 'extension/round.dart';
import 'input_screen.dart';
import 'login_screen.dart';
import 'model/chart_model.dart';
import 'theme/theme.dart';

class ResultScreen extends StatefulWidget {
  ResultScreen({Key? key}) : super(key: key);

  @override
  _ResultScreenState createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  @override
  void initState() {
    init();
    super.initState();
  }

  Future<void> init() async {
    await getData();
    await initialize();
  }

  Future<void> initialize() async {
    if (dataPasien.isNotEmpty) {
      clearData();

      await analyze();
      await sumCaseByDiseases();
      await sumHigestCase();

      printFinalResult();
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blackLv1,
      body: dataPenyakit.isNotEmpty || dataPasien.isNotEmpty
          ? SingleChildScrollView(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    appBar(),
                    SizedBox(height: 18),
                    dataPasien.isNotEmpty ? body() : empty(),
                  ],
                ),
              ),
            )
          : Center(child: CircularProgressIndicator()),
    );
  }

  Widget empty() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height - 100,
      child: Center(
        child: Text(
          '(DATA KOSONG)',
          style: TextStyle(
            fontSize: 12,
            color: Colors.white70,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget appBar() {
    return Container(
      width: MediaQuery.of(context).size.width,
      constraints: BoxConstraints(
        minWidth: 1034,
      ),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          title(),
          userInfo(),
        ],
      ),
    );
  }

  Widget title() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Analisa Data Penyakit',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Pasien Puskesmas Bukit Kayu Kapur',
          style: TextStyle(
            fontSize: 12,
            color: Colors.white54,
          ),
        ),
      ],
    );
  }

  Widget userInfo() {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            AppConfig.user != null
                ? Text(
                    AppConfig.user?.name ?? "",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                : loginButton(),
            SizedBox(height: 4),
            AppConfig.user != null
                ? Row(
                    children: [
                      updateDataButton(),
                      Text(
                        '  •  ',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white54,
                        ),
                      ),
                      logoutButton(),
                    ],
                  )
                : SizedBox.shrink()
          ],
        ),
        SizedBox(width: 12),
        AppConfig.user != null
            ? Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.blackLv2,
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: Image.asset(AppConfig.user!.photo),
                ),
              )
            : SizedBox.shrink()
      ],
    );
  }

  Widget loginButton() {
    return GestureDetector(
      onTap: () async {
        var status = await showDialog(
          context: context,
          builder: (context) {
            return LoginDialog();
          },
        );

        if (status == 'success') {
          setState(() {});
        }
      },
      child: Container(
        color: Colors.transparent,
        padding: EdgeInsets.all(2),
        child: Row(
          children: [
            Icon(
              Icons.login,
              size: 13,
              color: Colors.white70,
            ),
            SizedBox(width: 5),
            Text(
              'Login Admin',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget updateDataButton() {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => InputScreen(),
            fullscreenDialog: true,
          ),
        );

        initialize();
      },
      child: Container(
        color: Colors.transparent,
        padding: EdgeInsets.all(2),
        child: Row(
          children: [
            Icon(
              Icons.edit_note_sharp,
              size: 12,
              color: Colors.white54,
            ),
            SizedBox(width: 3),
            Text(
              'Update Data',
              style: TextStyle(
                fontSize: 11,
                color: Colors.white54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget logoutButton() {
    return GestureDetector(
      onTap: () async {
        var status = await showDialog(
          context: context,
          builder: (context) {
            return LogoutDialog();
          },
        );

        if (status == 'success') {
          setState(() {});
        }
      },
      child: Container(
        color: Colors.transparent,
        padding: EdgeInsets.all(2),
        child: Row(
          children: [
            Icon(
              Icons.exit_to_app,
              size: 12,
              color: Colors.white54,
            ),
            SizedBox(width: 3),
            Text(
              'Logout',
              style: TextStyle(
                fontSize: 11,
                color: Colors.white54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget body() {
    return Container(
      width: MediaQuery.of(context).size.width,
      constraints: BoxConstraints(
        minWidth: 1440,
      ),
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: scatterWidget(),
              ),
              SizedBox(width: 18),
              Expanded(
                child: Column(
                  children: [
                    genderWidget(),
                    SizedBox(height: 18),
                    agesWidget(),
                    SizedBox(height: 18),
                    diseasesClassWidget(),
                  ],
                ),
              )
            ],
          ),
          SizedBox(height: 18),
          barChartWidget()
        ],
      ),
    );
  }

  Widget scatterWidget() {
    return Container(
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.blackLv2,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 12),
            child: Text(
              'Pengelompokan Data',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            constraints: BoxConstraints(
              maxHeight: 648,
            ),
            child: ScatterChart(
              ScatterChartData(
                scatterSpots: data(),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(
                    width: 1,
                    color: Colors.white24,
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                ),
                titlesData: FlTitlesData(
                  show: true,
                  leftTitles: AxisTitles(
                    axisNameWidget: Container(
                      child: Text(
                        'LAMA MENGIDAP (HARI)',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 35,
                      getTitlesWidget: (data, _) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          data.toPrecision(3).toString(),
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    axisNameWidget: Container(
                      child: Text(
                        'UMUR (TAHUN)',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (data, _) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          data.toPrecision(3).toString(),
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 35,
                      getTitlesWidget: (data, _) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          data.toPrecision(3).toString(),
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (data, _) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          data.toPrecision(3).toString(),
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                scatterTouchData: ScatterTouchData(
                  enabled: true,
                  touchTooltipData: ScatterTouchTooltipData(
                    tooltipBgColor: AppColors.blackLv3,
                    getTooltipItems: (data) => ScatterTooltipItem(
                      '${data.x.toString() + ', ' + data.y.toString()}',
                      textStyle: TextStyle(fontSize: 14, color: Colors.white),
                      bottomMargin: 0,
                    ),
                  ),
                ),
              ),
              swapAnimationDuration: const Duration(milliseconds: 600),
            ),
          ),
          SizedBox(height: 18),
          clusterInfo(),
        ],
      ),
    );
  }

  Widget clusterInfo() {
    return Row(
      children: [
        clusterName(),
        SizedBox(width: 12),
        clusterCount(),
        SizedBox(width: 12),
        attributMean(),
        SizedBox(width: 12),
        attributMinMax(),
      ],
    );
  }

  Widget clusterName() {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.blackLv3.withOpacity(0.30),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...List.generate(
              k + 1,
              (i) => Padding(
                padding: EdgeInsets.only(bottom: i < k ? 8.0 : 0),
                child: Row(
                  children: [
                    Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: pointColor(i),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    SizedBox(width: 6),
                    Text(
                      i == 0
                          ? 'Penyakit Akut'
                          : i == 1
                              ? 'Penyakit Kronis'
                              : 'Titik Tengah (Centroid)',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget clusterCount() {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.blackLv3.withOpacity(0.30),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...List.generate(
              k,
              (i) => Padding(
                padding: EdgeInsets.only(bottom: i < k ? 8.0 : 0),
                child: Row(
                  children: [
                    Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: pointColor(i),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    SizedBox(width: 6),
                    Text(
                      i == 0
                          ? '${dataPasien.where((e) => e.cluster == 0).length} Pasien (${(((dataPasien.where((e) => e.cluster == 0).length) / dataPasien.length) * 100).toPrecision(0)}%)'
                          : i == 1
                              ? '${dataPasien.where((e) => e.cluster == 1).length} Pasien (${(((dataPasien.where((e) => e.cluster == 1).length) / dataPasien.length) * 100).toPrecision(0)}%)'
                              : '',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Text(
              'Total Pasien :  ${dataPasien.length}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.84),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget attributMean() {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.blackLv3.withOpacity(0.30),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rata-Rata',
              style: TextStyle(
                color: Colors.white.withOpacity(0.84),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Umur                      :  ${(dataPasien.map((e) => e.umur).reduce((x, y) => x + y) / dataPasien.length).toPrecision(0)}',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Lama Mengidap  :  ${(dataPasien.map((e) => e.lamaMengidap).reduce((x, y) => x + y) / dataPasien.length).toPrecision(0)}',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget attributMinMax() {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.blackLv3.withOpacity(0.30),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Column(
                  children: [
                    Text(
                      '',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.84),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Min.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Max.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'Umur',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '${dataPasien.map((e) => e.umur).reduce((x, y) => x > y ? y : x)} Tahun',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.84),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '${dataPasien.map((e) => e.umur).reduce((x, y) => x > y ? x : y)} Tahun',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.84),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'Lama Mgdp.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '${dataPasien.map((e) => e.lamaMengidap).reduce((x, y) => x > y ? y : x)} Hari',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.84),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '${dataPasien.map((e) => e.lamaMengidap).reduce((x, y) => x > y ? x : y)} Hari',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.84),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget genderWidget() {
    return Container(
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.blackLv2,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const SizedBox(height: 4),
          Text(
            'Jenis Kelamin',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 22),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 170,
                height: 170,
                child: PieChart(
                  PieChartData(
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 8,
                    centerSpaceRadius: 35,
                    sections: showingSections(),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  indicator(
                      color: AppColors.brownLv2,
                      text: 'Laki-Laki (${dataPasien.map((e) => e.jenisKelamin).where((e) => e == 'L').length} Pasien)',
                      textColor: Colors.white70),
                  const SizedBox(width: 20),
                  indicator(
                      color: AppColors.brownLv3,
                      text: 'Perempuan (${dataPasien.map((e) => e.jenisKelamin).where((e) => e == 'P').length} Pasien)',
                      textColor: Colors.white70),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ],
      ),
    );
  }

  Widget indicator({
    required Color color,
    required String text,
    required Color textColor,
  }) {
    return Row(
      children: <Widget>[
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            color: color,
          ),
        ),
        SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        )
      ],
    );
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(2, (i) {
      switch (i) {
        case 0:
          return PieChartSectionData(
            color: AppColors.brownLv2,
            value: dataPasien.map((e) => e.jenisKelamin).where((e) => e == 'L').length.toDouble().toPrecision(0),
            title:
                '${((dataPasien.map((e) => e.jenisKelamin).where((e) => e == 'L').length / dataPasien.length) * 100).toPrecision(0)}%',
            radius: 48,
            titleStyle: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          );
        case 1:
          return PieChartSectionData(
            color: AppColors.brownLv3,
            value: dataPasien.map((e) => e.jenisKelamin).where((e) => e == 'P').length.toDouble().toPrecision(0),
            title:
                '${((dataPasien.map((e) => e.jenisKelamin).where((e) => e == 'P').length / dataPasien.length) * 100).toPrecision(0)}%',
            radius: 48,
            titleStyle: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          );

        default:
          throw Error();
      }
    });
  }

  Widget agesWidget() {
    return Container(
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.blackLv2,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const SizedBox(height: 4),
          Text(
            'Golongan Umur',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Container(
                width: 94,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Golongan',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.84),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Balita (0-5)',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Anak-Anak (5-11)',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Remaja (12-25)',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Dewasa (26-45)',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Lansia (46-65)',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Manula (>65)',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 6),
                  decoration: BoxDecoration(
                    color: AppColors.yellowLv1.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Akut',
                        style: TextStyle(
                          color: Color(0xFFFFD469),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '${dataPasien.where((e) => e.umur >= 0 && e.umur <= 5 && e.cluster == 0).length}',
                        style: TextStyle(
                          color: AppColors.yellowLv1,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '${dataPasien.where((e) => e.umur >= 6 && e.umur <= 11 && e.cluster == 0).length}',
                        style: TextStyle(
                          color: AppColors.yellowLv1,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '${dataPasien.where((e) => e.umur >= 12 && e.umur <= 25 && e.cluster == 0).length}',
                        style: TextStyle(
                          color: AppColors.yellowLv1,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '${dataPasien.where((e) => e.umur >= 26 && e.umur <= 45 && e.cluster == 0).length}',
                        style: TextStyle(
                          color: AppColors.yellowLv1,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '${dataPasien.where((e) => e.umur >= 46 && e.umur <= 65 && e.cluster == 0).length}',
                        style: TextStyle(
                          color: AppColors.yellowLv1,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '${dataPasien.where((e) => e.umur >= 65 && e.cluster == 0).length}',
                        style: TextStyle(
                          color: AppColors.yellowLv1,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 6),
                  decoration: BoxDecoration(
                    color: AppColors.redLv1.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Kronis',
                        style: TextStyle(
                          color: Color(0xFFFF7A76),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '${dataPasien.where((e) => e.umur >= 0 && e.umur <= 5 && e.cluster == 1).length}',
                        style: TextStyle(
                          color: AppColors.redLv1,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '${dataPasien.where((e) => e.umur >= 6 && e.umur <= 11 && e.cluster == 1).length}',
                        style: TextStyle(
                          color: AppColors.redLv1,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '${dataPasien.where((e) => e.umur >= 12 && e.umur <= 25 && e.cluster == 1).length}',
                        style: TextStyle(
                          color: AppColors.redLv1,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '${dataPasien.where((e) => e.umur >= 26 && e.umur <= 45 && e.cluster == 1).length}',
                        style: TextStyle(
                          color: AppColors.redLv1,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '${dataPasien.where((e) => e.umur >= 46 && e.umur <= 65 && e.cluster == 1).length}',
                        style: TextStyle(
                          color: AppColors.redLv1,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '${dataPasien.where((e) => e.umur >= 65 && e.cluster == 1).length}',
                        style: TextStyle(
                          color: AppColors.redLv1,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 6),
                  decoration: BoxDecoration(
                    color: AppColors.blackLv3.withOpacity(0.30),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Total',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.87),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '${dataPasien.where((e) => e.umur >= 0 && e.umur <= 5).length}',
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '${dataPasien.where((e) => e.umur >= 6 && e.umur <= 11).length}',
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '${dataPasien.where((e) => e.umur >= 12 && e.umur <= 25).length}',
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '${dataPasien.where((e) => e.umur >= 26 && e.umur <= 45).length}',
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '${dataPasien.where((e) => e.umur >= 46 && e.umur <= 65).length}',
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '${dataPasien.where((e) => e.umur > 65).length}',
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget diseasesClassWidget() {
    return Container(
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.blackLv2,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const SizedBox(height: 4),
          Text(
            'Golongan Penyakit',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 9,
                          height: 9,
                          decoration: BoxDecoration(
                            color: pointColor(0),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Penyakit Akut',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.87),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Range Umur Pengidap',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${dataPasien.where((e) => e.cluster == 0).map((e) => e.umur).reduce((x, y) => x < y ? x : y)} - ${dataPasien.where((e) => e.cluster == 0).map((e) => e.umur).reduce((x, y) => x > y ? x : y)} Tahun',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.87),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Range Lama Mengidap',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${dataPasien.where((e) => e.cluster == 0).map((e) => e.lamaMengidap).reduce((x, y) => x < y ? x : y)} - ${dataPasien.where((e) => e.cluster == 0).map((e) => e.lamaMengidap).reduce((x, y) => x > y ? x : y)} Hari',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.87),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.yellowLv1.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rata-Rata',
                            style: TextStyle(
                              color: Color(0xFFFFD469),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Umur                      :  ${(dataPasien.where((e) => e.cluster == 0).map((e) => e.umur).reduce((x, y) => x + y) / dataPasien.where((e) => e.cluster == 0).length).toPrecision(0)}',
                            style: TextStyle(
                              color: AppColors.yellowLv1,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Lama Mengidap  :  ${(dataPasien.where((e) => e.cluster == 0).map((e) => e.lamaMengidap).reduce((x, y) => x + y) / dataPasien.where((e) => e.cluster == 0).length).toPrecision(0)}',
                            style: TextStyle(
                              color: AppColors.yellowLv1,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 9,
                          height: 9,
                          decoration: BoxDecoration(
                            color: pointColor(1),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Penyakit Kronis',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.87),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Range Umur Pengidap',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${dataPasien.where((e) => e.cluster == 1).map((e) => e.umur).reduce((x, y) => x < y ? x : y)} - ${dataPasien.where((e) => e.cluster == 1).map((e) => e.umur).reduce((x, y) => x > y ? x : y)} Tahun',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.87),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Range Lama Mengidap',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${dataPasien.where((e) => e.cluster == 1).map((e) => e.lamaMengidap).reduce((x, y) => x < y ? x : y)} - ${dataPasien.where((e) => e.cluster == 1).map((e) => e.lamaMengidap).reduce((x, y) => x > y ? x : y)} Hari',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.87),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.redLv1.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rata-Rata',
                            style: TextStyle(
                              color: Color(0xFFFF7A76),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Umur                      :  ${(dataPasien.where((e) => e.cluster == 1).map((e) => e.umur).reduce((x, y) => x + y) / dataPasien.where((e) => e.cluster == 1).length).toPrecision(0)}',
                            style: TextStyle(
                              color: AppColors.redLv1,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Lama Mengidap  :  ${(dataPasien.where((e) => e.cluster == 1).map((e) => e.lamaMengidap).reduce((x, y) => x + y) / dataPasien.where((e) => e.cluster == 1).length).toPrecision(0)}',
                            style: TextStyle(
                              color: AppColors.redLv1,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  /// Returns the list of chart serie which need to render
  /// on the stacked column chart.
  List<StackedColumnSeries<ChartModel, String>> _getStackedColumnSeries() {
    return <StackedColumnSeries<ChartModel, String>>[
      StackedColumnSeries<ChartModel, String>(
        dataSource: caseByDiseases,
        xValueMapper: (ChartModel sales, _) => sales.x.namaPenyakit,
        yValueMapper: (ChartModel sales, _) => sales.c0,
        color: AppColors.yellowLv1,
        name: 'Penyakit Akut',
      ),
      StackedColumnSeries<ChartModel, String>(
        dataSource: caseByDiseases,
        xValueMapper: (ChartModel sales, _) => sales.x.namaPenyakit,
        yValueMapper: (ChartModel sales, _) => sales.c1,
        color: AppColors.redLv1,
        name: 'Penyakit Kronis',
      ),
    ];
  }

  Widget barChartWidget() {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxHeight: 500,
      ),
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.blackLv2,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const SizedBox(height: 4),
          Text(
            'Histogram Penyakit',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                'Penyakit Dengan Jumlah Pengidap Tertinggi',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Row(
                children: [
                  Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: pointColor(0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  SizedBox(width: 6),
                  Text(
                    higestCaseC0.length == 1
                        ? '${higestCaseC0.first.x.namaPenyakit} (${higestCaseC0.first.c0})'
                        : '${higestCaseC0.first.x.namaPenyakit} (${higestCaseC0.first.c0}) & ${higestCaseC0.length - 1} lainnya',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(width: 10),
              Row(
                children: [
                  Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: pointColor(1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  SizedBox(width: 6),
                  Text(
                    higestCaseC1.length == 1
                        ? '${higestCaseC1.first.x.namaPenyakit} (${higestCaseC1.first.c1})'
                        : '${higestCaseC1.first.x.namaPenyakit} (${higestCaseC1.first.c1}) & ${higestCaseC1.length - 1} lainnya',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 22),
          Expanded(
            child: SfCartesianChart(
              margin: EdgeInsets.zero,
              plotAreaBorderWidth: 0,
              primaryXAxis: CategoryAxis(
                axisLine: AxisLine(width: 0),
                majorGridLines: const MajorGridLines(width: 0),
                majorTickLines: const MajorTickLines(size: 0),
                labelRotation: 90,
                labelStyle: TextStyle(
                  fontSize: 9,
                  color: Colors.white,
                  fontFamily: 'Montserrat',
                ),
                interval: 1,
                labelIntersectAction: AxisLabelIntersectAction.multipleRows,
              ),
              primaryYAxis: NumericAxis(
                axisLine: AxisLine(width: 0),
                majorGridLines: MajorGridLines(
                  color: Colors.white24,
                  dashArray: [8, 4],
                ),
                majorTickLines: MajorTickLines(size: 0),
                title: AxisTitle(
                  text: 'JUMLAH PASIEN',
                  textStyle: TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontFamily: 'Montserrat',
                  ),
                ),
                labelFormat: '{value}',
                labelStyle: TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  fontFamily: 'Montserrat',
                ),
                maximum: higestCase,
              ),
              series: _getStackedColumnSeries(),
              tooltipBehavior: TooltipBehavior(enable: true),
            ),
          ),
        ],
      ),
    );
  }
}
