import 'dart:async';
import 'package:flutter/material.dart';

import '../../ui_helper/ui_colors.dart';
import 'class_repository.dart';

class ClassNamePage extends StatefulWidget {
  const ClassNamePage({Key? key}) : super(key: key);

  @override
  State<ClassNamePage> createState() => _ClassNamePageState();
}

class _ClassNamePageState extends State<ClassNamePage> {
  final ClassRepository repo = ClassRepository.instance;
  final TextEditingController nameController = TextEditingController();

  List<ClassItem> items = [];

  @override
  void initState() {
    super.initState();
    _refreshList();
  }

  Future<void> _refreshList() async {
    final list = await repo.getAll();
    setState(() => items = list);
  }

  Future<void> saveFromInputs() async {
    final name = nameController.text.trim();
    if (name.isEmpty) return;

    await repo.createClass(name);
    nameController.clear();
    FocusScope.of(context).unfocus();
    _refreshList();
  }

  Future<void> _confirmDelete(ClassItem item) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.BLACK_7,
        title: const Text("Delete Confirmation",
            style: TextStyle(color: Colors.white)),
        content: Text("Are you sure you want to delete \"${item.name}\"?",
            style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            child: const Text("Cancel", style: TextStyle(color: Colors.white70)),
            onPressed: () => Navigator.pop(ctx, false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete"),
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );

    if (yes == true) {
      await repo.deleteClass(item.id);
      _refreshList();
    }
  }

  void _showEditDialog(ClassItem item) {
    final tcName = TextEditingController(text: item.name);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.BLACK_7,
        title: const Text('Edit Class', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: tcName,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Class Name',
            labelStyle: const TextStyle(color: Colors.white70),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.white),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        actions: [
          TextButton(
            child: const Text("Cancel", style: TextStyle(color: Colors.white70)),
            onPressed: () => Navigator.pop(ctx),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = tcName.text.trim();
              if (newName.isNotEmpty) {
                await repo.updateClass(item, newName);
                _refreshList();
              }
              Navigator.pop(ctx);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Widget _buildNameField() {
    return TextField(
      controller: nameController,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Class Name',
        hintStyle: const TextStyle(color: Colors.white54),
        labelText: 'Class Name',
        labelStyle: const TextStyle(color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: Colors.white38),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: Colors.white),
        ),
      ),
      onSubmitted: (_) => saveFromInputs(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.BLACK_9,
      appBar: AppBar(
        backgroundColor: AppColors.BLACK_9,
        centerTitle: true,
        title: const Text(
          'Class Name',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              'Add Class Name…..',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            const SizedBox(height: 12),
            _buildNameField(),
            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  onPressed: saveFromInputs,
                  child: const Text("Save",
                      style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(width: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () {
                    nameController.clear();
                  },
                  child: const Text("Cancel",
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),

            const SizedBox(height: 18),
            Expanded(child: _buildTable()),
          ],
        ),
      ),
    );
  }

  Widget _buildTable() {
    if (items.isEmpty) {
      return const Center(
        child: Text("No Classes Added",
            style: TextStyle(color: Colors.white70)),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.BLACK_7,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24, width: 0.5),
        ),
        child: DataTable(
          columnSpacing: 100,
          headingRowColor:
          MaterialStateProperty.all(Colors.grey[850]),
          dataRowColor:
          MaterialStateProperty.all(AppColors.BLACK_7.withOpacity(0.4)),
          dividerThickness: 0.4,
          columns: const [
            DataColumn(
              label: Text(
                'SL',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Class Name',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Last Updated',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Actions',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
          rows: items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final date = DateTime.fromMillisecondsSinceEpoch(item.updatedAt);
            final formattedDate =
                "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";

            return DataRow(
              cells: [
                DataCell(Text('${index + 1}',
                    style: const TextStyle(color: Colors.white70))),
                DataCell(Text(item.name,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w500))),
                DataCell(Text(formattedDate,
                    style: const TextStyle(color: Colors.white54))),
                DataCell(
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.greenAccent),
                        onPressed: () => _showEditDialog(item),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => _confirmDelete(item),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
