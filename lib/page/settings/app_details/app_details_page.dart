import 'package:flutter/material.dart';
import '../../../ui_helper/ui_colors.dart';
import 'app_details_db.dart';

class AppDetailsPage extends StatefulWidget {
  const AppDetailsPage({super.key});

  @override
  State<AppDetailsPage> createState() => _AppDetailsPageState();
}

class _AppDetailsPageState extends State<AppDetailsPage> {
  final shopCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final whatsappCtrl = TextEditingController();
  final noticeCtrl = TextEditingController();
  final msg1Ctrl = TextEditingController();
  final msg2Ctrl = TextEditingController();
  final msg3Ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await AppDetailsDB.instance.getDetails();
    if (data == null) return;

    shopCtrl.text = data['shop_name'] ?? '';
    addressCtrl.text = data['address'] ?? '';
    phoneCtrl.text = data['phone'] ?? '';
    whatsappCtrl.text = data['whatsapp'] ?? '';
    noticeCtrl.text = data['notice'] ?? '';
    msg1Ctrl.text = data['msg1'] ?? '';
    msg2Ctrl.text = data['msg2'] ?? '';
    msg3Ctrl.text = data['msg3'] ?? '';
  }


  Future<void> _save() async {
    await AppDetailsDB.instance.saveDetails({
      'shop_name': shopCtrl.text,
      'address': addressCtrl.text,
      'phone': phoneCtrl.text,
      'whatsapp': whatsappCtrl.text,
      'notice': noticeCtrl.text,
      'msg1': msg1Ctrl.text,
      'msg2': msg2Ctrl.text,
      'msg3': msg3Ctrl.text,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Saved Successfully"),
        backgroundColor: AppColors.GREEN_9,
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.pop(context, true); // ✅ back & return true
  }



  Widget _field(String label, TextEditingController c,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: AppColors.BLACK_6,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: AppColors.GREEN_9),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.BLACK_8,
      appBar: AppBar(
        backgroundColor: AppColors.BLACK_9,
        title: const Text("App Details", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _field("Shop Name", shopCtrl),
            _field("Address", addressCtrl, maxLines: 2),
            _field("Phone Number", phoneCtrl),
            _field("WhatsApp Number", whatsappCtrl),
            _field("Notice", noticeCtrl, maxLines: 2),
            _field("Message Line 1", msg1Ctrl),
            _field("Message Line 2", msg2Ctrl),
            _field("Message Line 3", msg3Ctrl),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _save,
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}
