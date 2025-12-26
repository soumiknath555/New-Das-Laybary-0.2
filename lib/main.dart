import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'drawer/Drawer_page/drawer_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp( MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(
          scrollbarTheme: ScrollbarThemeData(
            thumbColor: MaterialStateProperty.all(Colors.greenAccent),
            trackColor: MaterialStateProperty.all(Colors.white12),
            trackVisibility: MaterialStateProperty.all(true),
            thickness: MaterialStateProperty.all(10),
            radius: const Radius.circular(8),
          ),
    ),
      home: DrawerPage(),
    );
  }
}


