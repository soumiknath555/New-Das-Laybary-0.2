import 'package:flutter/material.dart';
import 'package:new_das_laybary_2/page/add_page/add_books_page.dart';
import 'package:new_das_laybary_2/page/belling_page/belling_main_page/belling_page.dart';
import 'package:new_das_laybary_2/page/publication_page/publication_page.dart';
import 'package:new_das_laybary_2/page/settings/settings_page.dart';
import 'package:new_das_laybary_2/page/shope_name/shop_name_page.dart';

import '../../page/Purchase/purchase_page.dart';
import '../../page/add_page/add_page.dart';
import '../../page/books_type/books_type.dart';
import '../../page/class_name/class_name_page.dart';
import '../../page/dashboard/dashboard_page.dart';
import '../../page/school_name/school_name_page.dart';
import '../../ui_helper/text_style.dart';
import '../../ui_helper/ui_colors.dart';

class DrawerPage extends StatefulWidget {
  const DrawerPage({super.key});

  @override
  State<DrawerPage> createState() => _DrawerPageState();
}

class _DrawerPageState extends State<DrawerPage> {
  int selectedIndex = 1 ;

  List<Widget> drawerPage = [
    DashboardPage(),
    BillingPage(),
    AddBooksPage(),
    Publication_Page(),
    BooksType(),
    ClassNamePage(),
    SchoolNamePage(),
    ShopNamePage(),
    PurchasePage(),
    SettingsPage(),
  ] ;


  void onItemTapped(int Index) {
    setState(() {
      selectedIndex = Index ;
    });
    Navigator.pop(context);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("New Das Laybary",
          style: snTextStyle20Bold(color: Colors.white),),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),

      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              child: Text("New Das Laybary", style: snTextStyle20Bold(color: AppColors.WHITE_9),),
              decoration: BoxDecoration(color: AppColors.BLACK_9),
            ),
            ListTile(
              title: Text("Dashboard Page"),
              onTap: ()=> onItemTapped(0),
            ),
            ListTile(
              title: Text("Billing Page"),
              onTap: ()=> onItemTapped(1),
            ),
            ListTile(
              title: Text("Add Page"),
              onTap: ()=> onItemTapped(2),
            ),

            ListTile(title: Text("Publication"),
              onTap: () => onItemTapped(3),
            ),

            ListTile(title: Text("Books Type"),
              onTap: () => onItemTapped(4),
            ),

            ListTile(
              title: Text("Add Class"),
              onTap: ()=> onItemTapped(5),
            ),
            ListTile(
              title: Text("Add School Name"),
              onTap: ()=> onItemTapped(6),
            ),
            ListTile(
              title: Text("Add Shop Name"),
              onTap: ()=> onItemTapped(7),
            ),
            ListTile(
              title: Text("Purchase Page"),
              onTap: ()=> onItemTapped(8),
            ),

            ListTile(
              title: Text("Setting Page"),
              onTap: ()=> onItemTapped(9),
            ),

          ],
        ),
      ),

      body: drawerPage[selectedIndex],
    );
  }
}