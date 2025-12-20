import 'package:flutter/material.dart';
import '../../ui_helper/ui_colors.dart';
import 'shop_name_db.dart';

class ShopNamePage extends StatefulWidget {
  const ShopNamePage({super.key});

  @override
  State<ShopNamePage> createState() => _ShopNamePageState();
}

class _ShopNamePageState extends State<ShopNamePage> {
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController locationCtrl = TextEditingController();

  List<Map<String, dynamic>> savedList = [];

  @override
  void initState() {
    super.initState();
    loadShopNames();
  }

  Future<void> loadShopNames() async {
    savedList = await ShopNameDB.instance.getAll();
    setState(() {});
  }

  // ------------------------ Snackbar --------------------------
  void showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: color,
        content: Text(msg, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  // ------------------------ Dialog -----------------------------
  void openDialog({Map<String, dynamic>? oldItem}) {
    if (oldItem != null) {
      nameCtrl.text = oldItem['name'];
      locationCtrl.text = oldItem['location'];
    } else {
      nameCtrl.clear();
      locationCtrl.clear();
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.BLACK_7,
          title: Text(
            oldItem == null ? "Add Shop" : "Edit Shop",
            style: const TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.black,
                  labelText: "Shop Name",
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) => saveOrUpdate(oldItem),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: locationCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.black,
                  labelText: "Location",
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) => saveOrUpdate(oldItem),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () => saveOrUpdate(oldItem),
              child: Text(
                "Save",
                style: TextStyle(color: AppColors.GREEN_9),
              ),
            ),
          ],
        );
      },
    );
  }

  // ------------------------ Save / Update -----------------------
  Future<void> saveOrUpdate(Map<String, dynamic>? oldItem) async {
    final name = nameCtrl.text.trim();
    final location = locationCtrl.text.trim();

    if (name.isEmpty || location.isEmpty) {
      showSnack("⚠ All fields are required!", AppColors.RED_9);
      return;
    }

    if (oldItem == null) {
      // ADD
      await ShopNameDB.instance.addData(name, location);
      showSnack("✔ Shop Added Successfully", AppColors.GREEN_9);
    } else {
      // UPDATE
      await ShopNameDB.instance.update(oldItem['id'], name, location);
      showSnack("✔ Shop Updated Successfully", AppColors.GREEN_9);
    }

    Navigator.pop(context);
    loadShopNames();
  }

  // ------------------------ Delete Confirm ---------------------
  void confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: AppColors.BLACK_7,
          title: const Text("Delete?", style: TextStyle(color: Colors.white)),
          content: const Text("Are you sure?", style: TextStyle(color: Colors.white)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("No", style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () async {
                await ShopNameDB.instance.delete(id);
                Navigator.pop(context);
                loadShopNames();
                showSnack("Deleted!", AppColors.RED_9);
              },
              child: Text("Yes", style: TextStyle(color: AppColors.RED_9)),
            ),
          ],
        );
      },
    );
  }

  // ------------------------ UI -----------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.BLACK_9,
      appBar: AppBar(
        backgroundColor: AppColors.BLACK_9,
        centerTitle: true,
        title: const Text(
          "Shop Name",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.GREEN_9,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => openDialog(),
      ),

      body: ListView.builder(
        itemCount: savedList.length,
        itemBuilder: (_, i) {
          final item = savedList[i];
          return Card(
            color: AppColors.BLACK_7,
            child: ListTile(
              title: Text(
                item['name'],
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                item['location'],
                style: const TextStyle(color: Colors.white70),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: AppColors.GREEN_9),
                    onPressed: () => openDialog(oldItem: item),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: AppColors.RED_9),
                    onPressed: () => confirmDelete(item['id']),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
