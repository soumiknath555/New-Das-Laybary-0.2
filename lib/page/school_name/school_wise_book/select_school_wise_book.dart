import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:new_das_laybary_2/page/school_name/school_wise_book/select_school_wise_book_db.dart';
import '../../../ui_helper/ui_colors.dart';
import '../../add_page/add_page_db.dart';

class SelectSchoolWiseBook extends StatefulWidget {
  final Map<String, dynamic> school;

  /// ✏️ edit mode
  final String? editSaveClass;

  const SelectSchoolWiseBook({
    super.key,
    required this.school,
    this.editSaveClass,
  });


  @override
  State<SelectSchoolWiseBook> createState() => _SelectSchoolWiseBookState();
}



class _SelectSchoolWiseBookState extends State<SelectSchoolWiseBook> {
  bool loading = true;

  String selectedClass = "All Class";
  String selectedPublication = "All Publication";
  String selectedMedium = "All Medium";

  List<Map<String, dynamic>> books = [];
  List<String> classList = [];
  List<String> publicationList = [];
  List<String> mediumList = [];

  /// ✅ Selected books
  final Set<int> selectedBooks = {};

  /// 🔹 SAVE CLASS (dropdown)
  String? selectedSaveClass;


  @override
  void initState() {
    super.initState();
    _loadBooks();

    /// 🔥 edit mode detect
    if (widget.editSaveClass != null) {
      selectedSaveClass = widget.editSaveClass;
      _loadSavedBooksForEdit();
    }
  }

  Future<void> _loadSavedBooksForEdit() async {
    final db = await SchoolBookDB.instance.database;

    final rows = await db.query(
      "school_books",
      where: "school_id = ? AND save_class = ?",
      whereArgs: [widget.school['id'], widget.editSaveClass],
    );

    setState(() {
      selectedBooks.clear();
      for (final r in rows) {
        selectedBooks.add(r['book_id'] as int);
      }
    });
  }


  Future<void> _loadBooks() async {
    final data = await BooksAddDB.instance.getAllBooks();
    setState(() {
      books = data;
      classList =
          data.map((e) => (e['class_name'] ?? '').toString()).toSet().toList();
      publicationList = data
          .map((e) => (e['publication_name'] ?? '').toString())
          .toSet()
          .toList();
      mediumList = data
          .map((e) => (e['book_language'] ?? '').toString())
          .toSet()
          .toList();

      loading = false;
    });
  }


  /// ================= FILTER =================
  List<Map<String, dynamic>> get filteredBooks {
    final filtered = books.where((b) {
      final classOk =
          selectedClass == "All Class" || b['class_name'] == selectedClass;
      final pubOk = selectedPublication == "All Publication" ||
          b['publication_name'] == selectedPublication;
      final mediumOk =
          selectedMedium == "All Medium" || b['book_language'] == selectedMedium;
      return classOk && pubOk && mediumOk;
    }).toList();

    /// ✅ selected books first
    filtered.sort((a, b) {
      final aSel = selectedBooks.contains(a['id']);
      final bSel = selectedBooks.contains(b['id']);
      if (aSel == bSel) return 0;
      return aSel ? -1 : 1;
    });

    return filtered;
  }

  void toggleSelect(int id) {
    setState(() {
      if (selectedBooks.contains(id)) {
        selectedBooks.remove(id);
      } else {
        selectedBooks.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.BLACK_9,
      appBar: AppBar(
        backgroundColor: AppColors.BLACK_9,
        title: const Text("Select School Wise Book",
            style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Row(
        children: [
          /// ================= LEFT =================
          Expanded(
            flex: 3,
            child: Column(
              children: [
                /// DROPDOWNS
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      _dropdown(
                          selectedClass, "All Class", classList,
                              (v) => setState(() => selectedClass = v)),
                      const SizedBox(width: 12),
                      _dropdown(selectedPublication, "All Publication",
                          publicationList,
                              (v) => setState(() => selectedPublication = v)),
                      const SizedBox(width: 12),
                      _dropdown(selectedMedium, "All Medium", mediumList,
                              (v) => setState(() => selectedMedium = v)),
                    ],
                  ),
                ),

                /// GRIDVIEW
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.70,
                    ),
                    itemCount: filteredBooks.length,
                    itemBuilder: (_, i) {
                      final book = filteredBooks[i];
                      final bool selected =
                      selectedBooks.contains(book['id']);

                      return GestureDetector(
                        onTap: () => toggleSelect(book['id']),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.BLACK_7,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: selected ? Colors.greenAccent : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              /// IMAGE
                              FutureBuilder<Uint8List?>(
                                future: BooksAddDB.instance.getFirstImageByBookId(book['id']),
                                builder: (_, snap) {
                                  if (!snap.hasData || snap.data == null) {
                                    return Container(
                                      height: 140,
                                      decoration: BoxDecoration(
                                        color: AppColors.BLACK_6,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.book,
                                          color: Colors.white54, size: 50),
                                    );
                                  }
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.memory(
                                      snap.data!,
                                      height: 300,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  );
                                },
                              ),

                              const SizedBox(height: 6),

                              Text(
                                book['title'] ?? '',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: Colors.white, fontWeight: FontWeight.bold),
                              ),

                              Text(
                                "Author: ${book['author'] ?? '-'}",
                                style: const TextStyle(color: Colors.white70, fontSize: 12),
                              ),

                              Text(
                                "Pub: ${book['publication_name'] ?? '-'}",
                                style: const TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      );

                    },
                  ),
                ),
              ],
            ),
          ),

          /// ================= RIGHT PREVIEW =================
          Expanded(
            flex: 1,
            child: Container(
              color: AppColors.BLACK_8,
              padding: const EdgeInsets.all(12),
              child: selectedBooks.isEmpty
                  ? const Center(
                child: Text(
                  "No book selected",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              )
                  : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// TITLE
                  const Text(
                    "Selected Books",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20, // 🔥 bigger
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(color: Colors.white24),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      const Text(
                        "Save For Class:",
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(width: 12),

                      DropdownButton<String>(
                        value: selectedSaveClass,
                        dropdownColor: AppColors.BLACK_7,
                        hint: const Text(
                          "Select Class",
                          style: TextStyle(color: Colors.white70),
                        ),
                        items: classList.map((c) {
                          return DropdownMenuItem(
                            value: c,
                            child: Text(
                              c,
                              style: const TextStyle(color: Colors.white),
                            ),
                          );
                        }).toList(),
                        onChanged: (v) {
                          setState(() => selectedSaveClass = v);
                        },
                      ),
                    ],
                  ),

                  const Divider(color: Colors.white24),


                  /// LIST
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: books
                            .where((b) => selectedBooks.contains(b['id']))
                            .map((b) => Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.BLACK_7,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: Colors.white12),
                          ),
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              /// BOOK NAME + MEDIUM
                              Text(
                                "${b['title']} (${b['book_language']})",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16, // 🔥 bigger
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              const SizedBox(height: 4),

                              /// AUTHOR
                              Text(
                                "✍️ ${b['author'] ?? '-'}",
                                style: const TextStyle(
                                  color: Colors.amber,
                                  fontSize: 13,
                                ),
                              ),

                              const SizedBox(height: 2),

                              /// PUBLICATION
                              Text(
                                "🏢 (${b['publication_name']})",
                                style: const TextStyle(
                                  color: Colors.lightBlueAccent,
                                  fontSize: 16,
                                ),
                              ),

                              const SizedBox(height: 2),

                              /// CLASS
                              Text(
                                "🎓 Class: ${b['class_name']}",
                                style: const TextStyle(
                                  color: Colors.orangeAccent,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ))
                            .toList(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// SAVE BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.save, color: Colors.black),
                      label: const Text(
                        "SAVE SELECTED BOOKS",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent,
                      ),
                        onPressed: () async {
                          if (selectedSaveClass == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Please select class"),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          final db = await SchoolBookDB.instance.database;

                          /// 🔥 EDIT MODE: clear old data
                          if (widget.editSaveClass != null) {
                            await db.delete(
                              "school_books",
                              where: "school_id = ? AND save_class = ?",
                              whereArgs: [widget.school['id'], selectedSaveClass],
                            );
                          }

                          /// 🔥 insert updated books
                          for (final b
                          in books.where((b) => selectedBooks.contains(b['id']))) {
                            await db.insert("school_books", {
                              "school_id": widget.school['id'],
                              "school_name": widget.school['name'],
                              "book_id": b['id'],
                              "title": b['title'],
                              "author": b['author'],
                              "publication": b['publication_name'],
                              "medium": b['book_language'],
                              "book_class": b['class_name'],
                              "save_class": selectedSaveClass,
                            });
                          }

                          Navigator.pop(context); // 🔥 back to table
                        }


                    ),
                  )
                ],
              ),
            ),
          )

        ],
      ),
    );
  }

  Widget _dropdown(String value, String all, List<String> list,
      Function(String) onChanged) {
    return DropdownButton<String>(
      value: value,
      dropdownColor: AppColors.BLACK_7,
      items: [all, ...list].map((e) {
        return DropdownMenuItem(
          value: e,
          child: Text(e, style: const TextStyle(color: Colors.white)),
        );
      }).toList(),
      onChanged: (v) => onChanged(v!),
    );
  }
}


