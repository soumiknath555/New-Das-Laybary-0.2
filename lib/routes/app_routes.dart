import 'package:flutter/cupertino.dart';
import 'package:new_das_laybary_2/page/publication_page/publication_page.dart';
import 'package:new_das_laybary_2/page/settings/settings_page.dart';

import '../drawer/Drawer_page/drawer_page.dart';
import '../page/add_page/add_page.dart';
import '../page/dashboard/dashboard_page.dart';

class AppRoutes {
  static const DASHBOARD_PAGE = "/home";
  static const ADD_PAGE = "/addpage";
  static const SETTING_PAGE = "/setting";
  static const PUBLICATION_PAGE ="/publication_page";

  static const DRAWER_PAGE ="/drawer_page";


  static Map<String , Widget Function(BuildContext) > routes = {
    DASHBOARD_PAGE :(context) => DashboardPage(),
    ADD_PAGE : (context) => AddPage(),
    SETTING_PAGE :(context) => SettingsPage(),
    PUBLICATION_PAGE : (context) => Publication_Page(),

    DRAWER_PAGE : (context) => DrawerPage(),
  };
}