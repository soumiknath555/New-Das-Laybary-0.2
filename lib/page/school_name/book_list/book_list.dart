import 'package:flutter/material.dart';
import 'package:new_das_laybary_2/ui_helper/ui_colors.dart';
import '../school_wise_book/select_school_wise_book.dart';
import '../school_wise_book/select_school_wise_book_db.dart';

class BookList extends StatefulWidget {
  final Map<String, dynamic> school;
  const BookList({super.key, required this.school});

  @override
  State<BookList> createState() => _BookListState();
}

class _BookListState extends State<BookList> {
  List<String> saveClasses = [];
  String? selectedClass;
  List<Map<String, dynamic>> classBooks = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadClasses();
  }

  /// 🔹 load LEFT SIDE class list
  Future<void> loadClasses() async {
    final data =
    await SchoolBookDB.instance.getSaveClasses(widget.school['id']);

    setState(() {
      saveClasses = data;
      loading = false;
    });
  }

  /// 🔹 load RIGHT SIDE books
  Future<void> loadBooks(String saveClass) async {
    final books = await SchoolBookDB.instance.getBooksByClass(
      widget.school['id'],
      saveClass,
    );

    setState(() {
      selectedClass = saveClass;
      classBooks = books;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.school['name'],
          style: const TextStyle(color: Colors.white),
        ),
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Row(
        children: [

          /// ================= LEFT : CLASS LIST =================
          Expanded(
            flex: 1,
            child: Container(
              color: AppColors.BLACK_7,
              child: ListView.builder(
                itemCount: saveClasses.length,
                itemBuilder: (_, i) {
                  final c = saveClasses[i];
                  final selected = c == selectedClass;

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.BLACK_9,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: selected ? Colors.greenAccent : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: ListTile(
                      title: Text(
                        c,
                        style: TextStyle(
                          color: selected ? Colors.greenAccent : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      /// ✏️ EDIT BUTTON
                      trailing: IconButton(
                        icon: const Icon(Icons.edit, color: Colors.amber),
                        tooltip: "Edit books for this class",
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SelectSchoolWiseBook(
                                school: widget.school,

                                /// 🔥 edit mode data
                                editSaveClass: c,
                              ),
                            ),
                          );

                          /// 🔄 back আসার পরে reload
                          loadBooks(c);
                          loadClasses();
                        },
                      ),

                      onTap: () => loadBooks(c),
                    ),
                  );
                },
              ),
            ),
          ),



          /// ================= RIGHT : BOOK TABLE =================
          Expanded(
            flex: 3,
            child: selectedClass == null
                ? const Center(
              child: Text(
                "Select a class",
                style: TextStyle(color: Colors.white),
              ),
            )
                : LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: DataTable(
                          columnSpacing: 70,
                          headingRowHeight: 48,
                          dataRowMinHeight: 48,
                          dataRowMaxHeight: 48,

                          /// 🔥 HEADER COLOR
                          headingRowColor:
                          MaterialStateProperty.all(AppColors.BLACK_8),

                          /// 🔥 ROW COLOR (hover + normal)
                          dataRowColor: MaterialStateProperty.resolveWith<Color?>(
                                (states) {
                              if (states.contains(MaterialState.hovered)) {
                                return Colors.green.withOpacity(0.15);
                              }
                              return AppColors.BLACK_9;
                            },
                          ),

                          headingTextStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),

                          /// default data text
                          dataTextStyle: const TextStyle(color: Colors.white),

                          columns: const [
                            DataColumn(label: Text("📘 Title")),
                            DataColumn(label: Text("✍️ Author")),
                            DataColumn(label: Text("🏢 Publication")),
                            DataColumn(label: Text("🎓 Class")),
                          ],

                          rows: classBooks.asMap().entries.map((entry) {
                            final index = entry.key;
                            final b = entry.value;

                            return DataRow(
                              /// 🔥 alternate row shading
                              color: MaterialStateProperty.all(
                                index.isEven
                                    ? AppColors.BLACK_9
                                    : AppColors.BLACK_8,
                              ),
                              cells: [
                                /// TITLE – green accent
                                DataCell(
                                  Text(
                                    b['title'] ?? '',
                                    style: const TextStyle(
                                      color: Colors.greenAccent,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),

                                /// AUTHOR – amber
                                DataCell(
                                  Text(
                                    b['author'] ?? '',
                                    style: const TextStyle(
                                      color: Colors.amber,
                                    ),
                                  ),
                                ),

                                /// PUBLICATION – blue
                                DataCell(
                                  Text(
                                    b['publication'] ?? '',
                                    style: const TextStyle(
                                      color: Colors.lightBlueAccent,
                                    ),
                                  ),
                                ),

                                /// CLASS – orange
                                DataCell(
                                  Text(
                                    b['book_class'] ?? '',
                                    style: const TextStyle(
                                      color: Colors.orangeAccent,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),


          ),


        ],
      ),

      /// ➕ ADD BOOKS BUTTON
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: const Icon(Icons.menu_book, color: Colors.white),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  SelectSchoolWiseBook(school: widget.school),
            ),
          );

          /// 🔁 refresh after save
          loadClasses();
        },
      ),
    );
  }
}
