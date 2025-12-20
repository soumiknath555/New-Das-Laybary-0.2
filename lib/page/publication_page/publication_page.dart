import 'package:flutter/material.dart';
import 'package:new_das_laybary_2/page/publication_page/publication_db.dart';

class Publication_Page extends StatefulWidget {
  const Publication_Page({super.key});

  @override
  State<Publication_Page> createState() => _PublicationPageState();
}

class _PublicationPageState extends State<Publication_Page> {
  final TextEditingController pubController = TextEditingController();

  List<Map<String, dynamic>> publicationList = [];

  @override
  void initState() {
    super.initState();
    loadPublications();
  }

  Future<void> loadPublications() async {
    final data = await PublicationDB.instance.getAllPublications();
    setState(() {
      publicationList = data;
    });
  }

  // 🔥 Snackbar Function
  void showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontSize: 16)),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.black87,
      ),
    );
  }

  Future<void> savePublication() async {
    final name = pubController.text.trim();
    if (name.isEmpty) return;

    await PublicationDB.instance.addPublication(name);

    pubController.clear();
    FocusScope.of(context).unfocus();

    await loadPublications();

    showSnack("✔ Publication Saved!");
  }

  void editPublication(int id, String oldName) {
    pubController.text = oldName;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black87,
          title: const Text("Edit Publication", style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: pubController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: "Publication Name",
              labelStyle: TextStyle(color: Colors.white70),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white54)),
              focusedBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel", style: TextStyle(color: Colors.redAccent))),
            TextButton(
                onPressed: () async {
                  final newName = pubController.text.trim();
                  if (newName.isNotEmpty) {
                    await PublicationDB.instance.updatePublication(id, newName);
                    pubController.clear();
                    Navigator.pop(context);
                    loadPublications();
                    showSnack("✔ Publication Updated!");
                  }
                },
                child: const Text("Update", style: TextStyle(color: Colors.greenAccent))),
          ],
        );
      },
    );
  }

  // 🔥 DELETE Confirmation Dialog
  Future<void> confirmDelete(int id) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black87,
        title: const Text("Confirm Delete", style: TextStyle(color: Colors.white)),
        content: const Text(
          "Are you sure you want to delete this publication?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            child: const Text("Cancel", style: TextStyle(color: Colors.greenAccent)),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text("Delete", style: TextStyle(color: Colors.redAccent)),
            onPressed: () async {
              Navigator.pop(context);
              await deletePublication(id);
            },
          ),
        ],
      ),
    );
  }

  Future<void> deletePublication(int id) async {
    await PublicationDB.instance.deletePublication(id);
    loadPublications();
    showSnack("🗑 Publication Deleted!");
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Publication", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text("Add Publication Name.....",
                    style: TextStyle(fontSize: 20, color: Colors.white)),
                const SizedBox(height: 20),

                TextField(
                  controller: pubController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: "Publication Name",
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white54)),
                    focusedBorder:
                    OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                  ),
                  onSubmitted: (value) => savePublication(),
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: savePublication,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      child: const Text("Save"),
                    ),
                    const SizedBox(width: 40),
                    ElevatedButton(
                      onPressed: () => pubController.clear(),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text("Cancel"),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: Container(
              padding: const EdgeInsets.all(10),
              child: isWide ? buildWebTable() : buildMobileList(),
            ),
          )
        ],
      ),
    );
  }

  // 🔹 Mobile List
  Widget buildMobileList() {
    return ListView.builder(
      itemCount: publicationList.length,
      itemBuilder: (context, index) {
        final row = publicationList[index];
        return Card(
          color: Colors.grey[900],
          child: ListTile(
            leading: Text("${index + 1}.", style: const TextStyle(color: Colors.white)),
            title: Text(row["name"], style: const TextStyle(color: Colors.white)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                    icon: const Icon(Icons.edit, color: Colors.greenAccent),
                    onPressed: () => editPublication(row["id"], row["name"])),
                IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () => confirmDelete(row["id"])),
              ],
            ),
          ),
        );
      },
    );
  }

  // 🔹 Desktop Table
  Widget buildWebTable() {
    return SingleChildScrollView(
      child: DataTable(
        headingRowColor: MaterialStateProperty.all(Colors.grey[900]),
        columns: const [
          DataColumn(label: Text("SL", style: TextStyle(color: Colors.white))),
          DataColumn(label: Text("Publication Name", style: TextStyle(color: Colors.white))),
          DataColumn(label: Text("Actions", style: TextStyle(color: Colors.white))),
        ],
        rows: publicationList.asMap().entries.map((entry) {
          final index = entry.key;
          final row = entry.value;

          return DataRow(cells: [
            DataCell(Text("${index + 1}", style: const TextStyle(color: Colors.white))),
            DataCell(Text(row["name"], style: const TextStyle(color: Colors.white))),
            DataCell(Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.greenAccent),
                  onPressed: () => editPublication(row["id"], row["name"]),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () => confirmDelete(row["id"]),
                ),
              ],
            )),
          ]);
        }).toList(),
      ),
    );
  }
}
