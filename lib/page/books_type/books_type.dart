import 'package:flutter/material.dart';
import '../../ui_helper/ui_colors.dart';
import '../publication_page/publication_db.dart';
import 'books_type_db.dart';
import '../books_type/books_type_db.dart';


class BooksType extends StatefulWidget {
  const BooksType({super.key});

  @override
  State<BooksType> createState() => _BooksTypeState();
}

class _BooksTypeState extends State<BooksType> {
  String? selectedPublication;
  int? selectedPubId;

  final TextEditingController typeNameCtrl = TextEditingController();
  final TextEditingController purchaseCtrl = TextEditingController();
  final TextEditingController sellCtrl = TextEditingController();

  List<Map<String, dynamic>> pubList = [];
  List<Map<String, dynamic>> savedList = [];

  @override
  void initState() {
    super.initState();
    loadPublications();
    loadSavedBooksType();
  }

  Future<void> loadPublications() async {
    pubList = await PublicationDB.instance.getAllPublications();
    setState(() {});
  }

  Future<void> loadSavedBooksType() async {
    savedList = await BooksTypeDB.instance.getAll();
    setState(() {});
  }

  void showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: color,
        content: Text(msg, style: TextStyle(color: AppColors.WHITE_9)),
      ),
    );
  }

  void openDialog({Map<String, dynamic>? oldItem}) {
    FocusNode typeNameFocus = FocusNode();
    FocusNode purchaseFocus = FocusNode();
    FocusNode sellFocus = FocusNode();

    if (oldItem != null) {
      selectedPublication = oldItem['pub_name'];
      selectedPubId = oldItem['pub_id'];
      typeNameCtrl.text = oldItem['type_name'];
      purchaseCtrl.text = ((oldItem['purchase'] ?? 0) % 1 == 0)
          ? (oldItem['purchase'] ?? 0).toInt().toString()
          : (oldItem['purchase'] ?? 0).toString();
      sellCtrl.text = ((oldItem['sell'] ?? 0) % 1 == 0)
          ? (oldItem['sell'] ?? 0).toInt().toString()
          : (oldItem['sell'] ?? 0).toString();
    } else {
      selectedPublication = null;
      selectedPubId = null;
      typeNameCtrl.clear();
      purchaseCtrl.clear();
      sellCtrl.clear();
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: AppColors.BLACK_7,
              title: Text(
                oldItem == null ? "Add Books Type" : "Edit Books Type",
                style: TextStyle(color: AppColors.WHITE_9),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// Publication Dropdown
                  DropdownButton<String>(
                    value: selectedPublication,
                    hint: Text("Select Publication",
                        style: TextStyle(color: AppColors.WHITE_9)),
                    dropdownColor: AppColors.BLACK_7,
                    isExpanded: true,
                    items: pubList.map((pub) {
                      return DropdownMenuItem<String>(
                        value: pub['name'],
                        child: Text(pub['name'],
                            style: TextStyle(color: AppColors.WHITE_9)),
                        onTap: () => selectedPubId = pub['id'],
                      );
                    }).toList(),
                    onChanged: (v) {
                      setStateDialog(() => selectedPublication = v);
                    },
                  ),

                  const SizedBox(height: 10),

                  /// Book Type Name
                  TextField(
                    controller: typeNameCtrl,
                    focusNode: typeNameFocus,
                    style: TextStyle(color: AppColors.WHITE_9),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.BLACK_7,
                      labelText: "Books Type Name",
                      labelStyle: TextStyle(color: AppColors.WHITE_9),
                      border: OutlineInputBorder(),
                    ),
                    onEditingComplete: () {
                      FocusScope.of(context).requestFocus(purchaseFocus);
                    },
                  ),

                  const SizedBox(height: 10),

                  /// Purchase
                  TextField(
                    controller: purchaseCtrl,
                    focusNode: purchaseFocus,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: AppColors.WHITE_9),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.BLACK_7,
                      labelText: "Purchase Discount",
                      labelStyle: TextStyle(color: AppColors.WHITE_9),
                      border: OutlineInputBorder(),
                    ),
                    onEditingComplete: () {
                      FocusScope.of(context).requestFocus(sellFocus);
                    },
                  ),

                  const SizedBox(height: 10),

                  /// Sell
                  TextField(
                    controller: sellCtrl,
                    focusNode: sellFocus,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: AppColors.WHITE_9),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.BLACK_7,
                      labelText: "Sell Discount",
                      labelStyle: TextStyle(color: AppColors.WHITE_9),
                      border: OutlineInputBorder(),
                    ),
                    onEditingComplete: () {
                      saveOrUpdate(oldItem); // final save
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel", style: TextStyle(color: AppColors.WHITE_9)),
                ),
                TextButton(
                  onPressed: () => saveOrUpdate(oldItem),
                  child: Text("Save", style: TextStyle(color: AppColors.GREEN_9)),
                ),
              ],
            );
          },
        );
      },
    );
  }


  Future<void> saveOrUpdate(Map<String, dynamic>? oldItem) async {
    if (selectedPublication == null || typeNameCtrl.text.isEmpty) {
      showSnack("⚠ Fill all fields", AppColors.RED_9);
      return;
    }

    final purchase = double.tryParse(purchaseCtrl.text) ?? 0;
    final sell = double.tryParse(sellCtrl.text) ?? 0;

    if (oldItem == null) {
      await BooksTypeDB.instance.addData(
        selectedPubId!,
        selectedPublication!,
        typeNameCtrl.text,
        purchase,
        sell,
      );
      showSnack("✔ Saved Successfully", AppColors.GREEN_9);
    } else {
      await BooksTypeDB.instance.update(
        oldItem['id'],
        selectedPubId!,
        selectedPublication!,
        typeNameCtrl.text,
        purchase,
        sell,
      );
      showSnack("✔ Updated Successfully", AppColors.GREEN_9);
    }

    Navigator.pop(context);
    loadSavedBooksType();
  }

  void confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.BLACK_7,
        title: Text("Delete?", style: TextStyle(color: AppColors.WHITE_9)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("No", style: TextStyle(color: AppColors.WHITE_9)),
          ),
          TextButton(
            onPressed: () async {
              await BooksTypeDB.instance.delete(id);
              Navigator.pop(context);
              loadSavedBooksType();
              showSnack("✔ Deleted Successfully", AppColors.RED_9); // ✅ add snackbar
            },
            child: Text("Yes", style: TextStyle(color: AppColors.RED_9)),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.BLACK_9,
      appBar: AppBar(
        backgroundColor: AppColors.BLACK_9,
        title: Text("Books Type",
            style: TextStyle(color: AppColors.WHITE_9)),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.GREEN_9,
        onPressed: () => openDialog(),
        child: Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: savedList.length,
        itemBuilder: (_, i) {
          final item = savedList[i];
          return Card(
            color: AppColors.BLACK_7,
            child: ListTile(
              title: Text(item['type_name'] ?? "",
                  style: TextStyle(color: AppColors.WHITE_9)),
              subtitle: Text(
                  "${item['pub_name'] ?? ''} | P:${(item['purchase'] ?? 0).toStringAsFixed(0)} | S:${(item['sell'] ?? 0).toStringAsFixed(0)}",
                  style: TextStyle(color: Colors.white70),
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
