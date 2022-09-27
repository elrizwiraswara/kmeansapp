import 'package:flutter/material.dart';
import 'package:kmeansapp/result_screen.dart';
import 'package:kmeansapp/theme/theme.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Analisa Data Penyakit Pasien Puskesmas Bukit Kayu Kapur',
      debugShowCheckedModeBanner: false,
      theme: appTheme(context),
      home: ResultScreen(),
    );
  }
}
