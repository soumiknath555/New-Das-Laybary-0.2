import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'drawer/Drawer_page/drawer_page.dart';

void main() {
  // 🔥 Desktop এ SQLite চালানোর জন্য অবশ্যই দরকার
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  runApp( MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DrawerPage(),
    );
  }
}


