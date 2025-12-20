import 'package:flutter/material.dart';
import '../../ui_helper/ui_colors.dart';
import 'book_list/book_list.dart';
import 'school_name_db.dart';

class SchoolNamePage extends StatefulWidget {
  const SchoolNamePage({super.key});

  @override
  State<SchoolNamePage> createState() => _SchoolNamePageState();
}

class _SchoolNamePageState extends State<SchoolNamePage> {
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController shortCtrl = TextEditingController();

  List<Map<String, dynamic>> savedList = [];

  @override
  void initState() {
    super.initState();
    loadSchools();
  }

  Future<void> loadSchools() async {
    savedList = await SchoolNameDB.instance.getAll();
    setState(() {});
  }

  // ---------------- Snackbar ----------------
  void showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: color,
        content: Text(msg, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  // ---------------- Dialog ------------------
  void openDialog({Map<String, dynamic>? oldItem}) {
    if (oldItem != null) {
      nameCtrl.text = oldItem['name'];
      shortCtrl.text = oldItem['short_form'];
    } else {
      nameCtrl.clear();
      shortCtrl.clear();
    }

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: AppColors.BLACK_7,
          title: Text(
            oldItem == null ? "Add School" : "Edit School",
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
                  labelText: "School Name",
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) => saveOrUpdate(oldItem),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: shortCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.black,
                  labelText: "School Short Form",
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
              child: Text("Save", style: TextStyle(color: AppColors.GREEN_9)),
            ),
          ],
        );
      },
    );
  }

  // ---------------- Save / Update ----------------
  Future<void> saveOrUpdate(Map<String, dynamic>? oldItem) async {
    final name = nameCtrl.text.trim();
    final shortForm = shortCtrl.text.trim();

    if (name.isEmpty || shortForm.isEmpty) {
      showSnack("⚠ All fields are required!", AppColors.RED_9);
      return;
    }

    if (oldItem == null) {
      await SchoolNameDB.instance.addData(name, shortForm);
      showSnack("✔ School Added Successfully", AppColors.GREEN_9);
    } else {
      await SchoolNameDB.instance.update(
        oldItem['id'],
        name,
        shortForm,
      );
      showSnack("✔ School Updated Successfully", AppColors.GREEN_9);
    }

    Navigator.pop(context);
    loadSchools();
  }

  // ---------------- Delete ----------------
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
                await SchoolNameDB.instance.delete(id);
                Navigator.pop(context);
                loadSchools();
                showSnack("Deleted!", AppColors.RED_9);
              },
              child: Text("Yes", style: TextStyle(color: AppColors.RED_9)),
            ),
          ],
        );
      },
    );
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.BLACK_9,
      appBar: AppBar(
        backgroundColor: AppColors.BLACK_9,
        centerTitle: true,
        title: const Text(
          "School Name",
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

              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BookList(school: item),
                  ),
                );
              },

              title: Row(
                children: [
                  Text(
                    item['name'],
                    style: const TextStyle(color: Colors.white),
                  ),
                  SizedBox(width: 10),
                  Text(
                    "(${item['short_form']})",
                    style: const TextStyle(color: Colors.green),
                  ),

                ],
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
