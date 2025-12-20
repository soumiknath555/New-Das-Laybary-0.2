import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

import 'package:super_drag_and_drop/super_drag_and_drop.dart';
import 'package:file_picker/file_picker.dart';


import '../../ui_helper/sn_button.dart';
import '../../ui_helper/dropdowon_button.dart';
import '../../ui_helper/text_field.dart';
import '../../ui_helper/ui_colors.dart';

import '../../models/publication_model.dart';
import '../../models/class_model.dart';
import '../../models/books_type_model.dart';
import '../../models/shop_model.dart';

import '../books_type/books_type_db.dart';
import '../class_name/class_repository.dart';
import '../publication_page/publication_db.dart';
import '../shope_name/shop_name_db.dart';
import 'add_page_db.dart';


class UploadedFile {
  final Uint8List? bytes;
  final File? file;
  final String name;
  final String mime;

  UploadedFile({this.bytes, this.file, required this.name, required this.mime});
  bool get isVideo => mime.toLowerCase().startsWith('video');
}

class MouseDragScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
  };
}

class DbImage {
  final int id;
  final Uint8List bytes;

  DbImage({required this.id, required this.bytes});
}



class AddPage extends StatefulWidget {

  final Map<String, dynamic>? book;

  const AddPage({super.key, this.book});





  @override
  State<AddPage> createState() => _AddPageState();
}

Uint8List? _editImageBytes; // 👈 DB image
String bookLanguage = "Text";


class _AddPageState extends State<AddPage> {
  // ------------------------ CONTROLLERS ------------------------
  final nameCtrl = TextEditingController();
  final authorCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final mrpCtrl = TextEditingController();
  final discountCtrl = TextEditingController();
  final purchaseCtrl = TextEditingController();
  final quantityCtrl = TextEditingController();

  // ------------------------ DROPZONE ------------------------
  List<UploadedFile> _uploadedFiles = [];


  late final PageController _pageController;
  Timer? _autoSlideTimer;
  int _currentImageIndex = 0;




  // ------------------------ DATABASE LISTS ------------------------
  List<PublicationModel> brandList = [];
  List<BooksTypeModel> bookTypeList = [];
  List<ClassModel> classList = [];
  List<ShopModel> shopList = [];

  // ------------------------ SELECTED ------------------------
  PublicationModel? selectedPublication;
  BooksTypeModel? selectedBookType;
  ClassModel? selectedClass;
  List<ShopModel> selectedShopModels = [];
  String priceType = "Discount";  // default selected
  String bookLanguage = "Text"; // default


  // image list (mobile + web + desktop)
  List<dynamic> _pickedImages = [];   // File only
  List<DbImage> _dbImages = [];       // DB images
  List<int> _deletedImageIds = [];    // 🔥 only IDs



  //// helper ..............................................

  double _toDouble(String v) => double.tryParse(v) ?? 0;

  double get purchasePrice {
    final mrp = _toDouble(mrpCtrl.text);
    final dis = _toDouble(purchaseCtrl.text);

    if (priceType == "Discount") {
      return mrp - (mrp * dis / 100);
    } else {
      return mrp - dis;
    }
  }

  double get sellPrice {
    final mrp = _toDouble(mrpCtrl.text);
    final dis = _toDouble(discountCtrl.text);

    if (priceType == "Discount") {
      return mrp - (mrp * dis / 100);
    } else {
      return mrp - dis;
    }
  }


  double get profit => sellPrice - purchasePrice;

  // -------------  price formatting -------------------


  Map<String, dynamic> get calculatedData {
    return {
      "purchasePrice": _roundedInt(purchasePrice),
      "sellPrice": _roundedInt(sellPrice),
      "profit": _roundedInt(profit),
    };
  }

  int _roundedInt(double value) {
    return value >= value.floor() + 0.5
        ? value.ceil()
        : value.floor();
  }



//// .........................................................................

  @override
  void initState() {
    super.initState();

    if (widget.book != null) {
      final b = widget.book!;

      nameCtrl.text = b['title'] ?? '';
      authorCtrl.text = b['author'] ?? '';

      // 🔥 VERY IMPORTANT (Text / Sohika)
      bookLanguage = b['book_language'] ?? 'Text';
    }


    /// PAGE CONTROLLER (for preview slider)
    _pageController = PageController();

    /// LOAD DROPDOWN DATA
    _loadDropdownData();

    /// EDIT MODE
    if (widget.book != null) {
      final b = widget.book!;

      /// TEXT FIELDS
      nameCtrl.text = b['title'] ?? '';
      authorCtrl.text = b['author'] ?? '';
      bookLanguage = b['book_language'] ?? "Text";
      descCtrl.text = b['description'] ?? '';

      mrpCtrl.text = b['mrp']?.toString() ?? '';
      discountCtrl.text = b['sell_discount']?.toString() ?? '';
      purchaseCtrl.text = b['purchase_discount']?.toString() ?? '';
      quantityCtrl.text = b['quantity']?.toString() ?? '';

      /// PRICE TYPE
      priceType = b['price_type'] ?? "Discount";

      /// OLD SINGLE IMAGE (fallback)
      if (b['front_image'] != null) {
        _editImageBytes = Uint8List.fromList(b['front_image']);
      }

      /// LOAD MULTIPLE IMAGES (ASYNC – SAFE)
      Future.microtask(() async {
        final id = b['id'];

        final res =
        await BooksAddDB.instance.getImagesWithIdByBookId(id);

        setState(() {
          _dbImages = res
              .map((e) => DbImage(
            id: e['id'] as int,
            bytes: e['image'] as Uint8List,
          ))
              .toList();
        });



      });
    }
  }



  void _refreshPreview() {
    setState(() {});
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }


  void _clearAllFields() {
    // 🟢 TEXT FIELDS
    nameCtrl.clear();
    authorCtrl.clear();
    descCtrl.clear();
    mrpCtrl.clear();
    discountCtrl.clear();
    purchaseCtrl.clear();
    quantityCtrl.clear();

    // 🟢 DROPDOWN + MULTISELECT + IMAGE
    setState(() {
      selectedPublication = null;
      selectedBookType = null;
      selectedClass = null;
      selectedShopModels.clear();

      _pickedImages.clear();   // 🔥 IMAGE CLEAR
      _currentImageIndex = 0;

      priceType = "Discount"; // তোমার default
    });
  }





  // ------------------------ LOAD DROPDOWN DATA ------------------------
  Future<void> _loadDropdownData() async {
    // Publication
    final pubs = await PublicationDB.instance.getAllPublications();
    brandList = pubs.map((e) => PublicationModel(id: e['id'], name: e['name'])).toList();

    /// ------- Books Type -------
    final types = await BooksTypeDB.instance.getAll();
    bookTypeList = types
        .map((e) => BooksTypeModel(
      id: e['id'],
      pubId: e['pub_id'],                 // ✔ FIXED
      pubName: e['pub_name'],
      typeName: e['type_name'],
      purchase: (e['purchase'] as num).toDouble(),
      sell: (e['sell'] as num).toDouble(),
    ))
        .toList();

    /// ------- Class -------
    final classes = await ClassRepository.instance.getAll();
    classList = classes
        .map((e) => ClassModel(
      id: int.tryParse(e.id.toString()) ?? 0,  // ✔ FIX for String ID
      name: e.name,
    ))
        .toList();


    // Shop
    final shops = await ShopNameDB.instance.getAll();
    shopList = shops.map((e) => ShopModel(id: e['id'], name: e['name'], location: e['location'])).toList();

    if (widget.book != null) {
      final b = widget.book!;

      selectedPublication = brandList.firstWhere(
            (p) => p.id == b['publication_id'],
      );

      selectedBookType = bookTypeList.firstWhere(
            (t) => t.id == b['book_type_id'],
      );

      selectedClass = classList.firstWhere(
            (c) => c.id == b['class_id'],
      );

      if (b['shop_list'] != null) {
        final names =
        b['shop_list'].toString().split(',').map((e) => e.trim());
        selectedShopModels =
            shopList.where((s) => names.contains(s.name)).toList();
      }
    }


    setState(() {});
  }


  //  -------------------------- AUTO SLIDER -----------------------
  void _startAutoSlide() {
    _autoSlideTimer?.cancel();

    _autoSlideTimer = Timer.periodic(
      const Duration(seconds: 2),
          (timer) {
        if (_pickedImages.length <= 1) return;

        int nextPage = _currentImageIndex + 1;
        if (nextPage >= _pickedImages.length) {
          nextPage = 0;
        }

        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      },
    );
  }



  Future<void> _pickVideoMobile() async {
    final picker = ImagePicker();
    final picked = await picker.pickVideo(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _uploadedFiles.add(UploadedFile(
          file: File(picked.path),
          name: picked.path.split('/').last,
          mime: 'video/*',
        ));
      });
    }
  }


  Future<void> _handleDropNew(PerformDropEvent event) async {
    for (final item in event.session.items) {
      final reader = item.dataReader;
      if (reader == null) continue;

      if (reader.canProvide(Formats.fileUri)) {
        reader.getValue(Formats.fileUri, (Uri? uri) {
          if (uri == null) return;
          final file = File(uri.toFilePath());
          if (_isImage(file)) {
            setState(() => _pickedImages.add(file));
          }
        });
      }
    }
  }



  Future<void> _pickImagesNew() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.image,
    );

    if (result == null) return;

    setState(() {
      _pickedImages.addAll(
        result.paths.whereType<String>().map((p) => File(p)),
      );
    });
  }

  Future<void> loadBookTypes() async {
    final types = await BooksTypeDB.instance.getAll();
    setState(() {
      bookTypeList = types.map((e) => BooksTypeModel.fromMap(e)).toList();
    });
  }





  // ------------------------ SAVE TO SQLITE ------------------------
  Future<void> _saveToLocalDB() async {
    final calc = calculatedData;

    // ===============================
    // 1️⃣ Build book DB map (TEXT / SOHIKA INCLUDED)
    // ===============================
    final dbMap = BooksAddDB.instance.buildDBMap(
      title: nameCtrl.text.trim(),
      author: authorCtrl.text.trim(),
      description: descCtrl.text.trim(),

      publicationId: selectedPublication?.id,
      publicationName: selectedPublication?.name,

      bookTypeId: selectedBookType?.id,
      bookTypeName: selectedBookType?.typeName,

      classId: selectedClass?.id,
      className: selectedClass?.name,

      mrp: int.tryParse(mrpCtrl.text) ?? 0,
      sellDiscount: int.tryParse(discountCtrl.text) ?? 0,
      purchaseDiscount: int.tryParse(purchaseCtrl.text) ?? 0,

      priceType: priceType,
      purchasePrice: calc["purchasePrice"],
      sellPrice: calc["sellPrice"],
      profit: calc["profit"],

      quantity: int.tryParse(quantityCtrl.text) ?? 0,
      shopList: selectedShopModels.map((e) => e.name).join(", "),

      // 🔥 VERY IMPORTANT (Text / Sohika)
      bookLanguage: bookLanguage,
    );

    int bookId;

    // ===============================
    // 2️⃣ EDIT vs NEW MODE
    // ===============================
    if (widget.book != null) {
      // ---------- ✏️ EDIT MODE ----------
      bookId = widget.book!['id'];

      // 🔥 UPDATE MAIN BOOK DATA
      await BooksAddDB.instance.updateBook(bookId, dbMap);

      // 🔥 DELETE REMOVED DB IMAGES (BY ID)
      for (final id in _deletedImageIds) {
        await BooksAddDB.instance.deleteBookImageById(id);
      }

    } else {
      // ---------- 🆕 NEW BOOK ----------
      bookId = await BooksAddDB.instance.addBook(dbMap);
    }

    // ===============================
    // 3️⃣ INSERT NEWLY PICKED IMAGES ONLY
    // ===============================
    for (final img in _pickedImages) {
      if (img is File) {
        final bytes = await img.readAsBytes();

        await BooksAddDB.instance.insertBookImage(
          bookId: bookId,
          imageBytes: bytes,
        );
      }
    }

    // ===============================
    // 4️⃣ SUCCESS FEEDBACK & BACK
    // ===============================
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Book saved successfully")),
      );

      Navigator.pop(context, true); // refresh previous page
    }
  }



  Widget _dbImageBox(DbImage img) {
    return commonCoverBox(
      imageProvider: MemoryImage(img.bytes),
      icon: Icons.delete,
      iconColor: Colors.redAccent,
      onDelete: () {
        setState(() {
          _deletedImageIds.add(img.id);
          _dbImages.remove(img);
        });
      },
    );
  }



  Widget _commonImageBox({
    required Widget image,
    VoidCallback? onDelete,
    IconData icon = Icons.close,
    Color iconColor = Colors.white,
  }) {
    return SizedBox(
      height: 300,
      width: 200,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: image,
          ),

          if (onDelete != null)
            Positioned(
              top: 6,
              right: 6,
              child: GestureDetector(
                onTap: onDelete,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Icon(icon, color: iconColor, size: 18),
                ),
              ),
            ),
        ],
      ),
    );
  }




  // ------------------------ UI ------------------------
  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.BLACK_9,
        title: const Text('Add Book', style: TextStyle(color: Colors.white)),
      ),
      backgroundColor: AppColors.BLACK_9,
      body: Container(
        padding: const EdgeInsets.all(12),
        child: isWide
            ? Row(
          children: [
            Expanded(flex: 3, child: SingleChildScrollView(child: _buildForm())),
            const SizedBox(width: 12),
            SizedBox(width: 350, child: _buildPreviewCard()),
          ],
        )
            : SingleChildScrollView(
          child: Column(
            children: [
              _buildForm(),
              const SizedBox(height: 20),
              _buildPreviewCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildImageUploader(250),
        const SizedBox(height: 10),
        _bookInfoCard(),
        const SizedBox(height: 10),
        _dropdownCard(),
        const SizedBox(height: 10),
        _priceCard(),
        const SizedBox(height: 10),
        _shopCard(),
        const SizedBox(height: 20),
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SnButton(
                text: "Save",
                buttonColor: AppColors.GREEN_9,
                textColor: AppColors.WHITE_9,
                onPressed: _saveToLocalDB, // ✅ ঠিক
              ),

              const SizedBox(width: 30),

              SnButton(
                text: "Cancel",
                buttonColor: AppColors.RED_9,
                textColor: AppColors.WHITE_9,
                onPressed: _clearAllFields,
              ),

            ],
          ),
        ),
      ],
    );
  }




  Widget _bookInfoCard() => Card(
    color: AppColors.BLACK_7,
    child: Padding(
      padding: const EdgeInsets.all(8),
      child: Column(children: [
        snTextField(hint: "Book Name", label: "Book Name", controller: nameCtrl ,onChanged: (_) => setState(() {}),),
        const SizedBox(height: 10),
        snTextField(hint: "Author", label: "Author", controller: authorCtrl , onChanged: (_) => setState(() {}),),
        const SizedBox(height: 10),
        snTextField(hint: "Description", label: "Description", controller: descCtrl, maxLines: 3 , onChanged: (_) => setState(() {}),),
      ]),
    ),
  );

  Widget _dropdownCard() => Card(
    color: AppColors.BLACK_7,
    child: Padding(
      padding: const EdgeInsets.all(8),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [

          // ------------------ Publication Dropdown ------------------
          Container(
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(6),
            ),
            child: DropdownButton<PublicationModel>(
              dropdownColor: Colors.black87,
              value: selectedPublication,
              hint: const Text("Select Publication",
                  style: TextStyle(color: Colors.white)),
              iconEnabledColor: Colors.white,
              style: const TextStyle(color: Colors.white),
              isExpanded: true,
              items: brandList.map((pub) {
                return DropdownMenuItem(
                  value: pub,
                  child: Text(pub.name,
                      style: const TextStyle(color: Colors.white)),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  selectedPublication = val;

                  final relatedTypes = bookTypeList
                      .where((b) => b.pubName == val?.name)
                      .toList();

                  if (relatedTypes.isNotEmpty) {
                    selectedBookType = relatedTypes.first;
                  }
                });
              },
            ),
          ),

          // ------------------ Book Type Dropdown ------------------
          Container(
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(6),
            ),
            child: DropdownButton<BooksTypeModel>(
              dropdownColor: Colors.black87,
              value: selectedBookType,
              hint: const Text("Select Book Type",
                  style: TextStyle(color: Colors.white)),
              iconEnabledColor: Colors.white,
              style: const TextStyle(color: Colors.white),
              isExpanded: true,
              items: bookTypeList
                  .where((b) => b.pubName == selectedPublication?.name)
                  .map((type) => DropdownMenuItem(
                value: type,
                child: Text(type.typeName, // <-- change here
                    style: const TextStyle(color: Colors.white)),
              ))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  selectedBookType = val;

                  if (val != null) {
                    // Format purchase
                    purchaseCtrl.text = val.purchase % 1 == 0
                        ? val.purchase.toInt().toString()
                        : val.purchase.toString();

                    // Format sell
                    discountCtrl.text = val.sell % 1 == 0
                        ? val.sell.toInt().toString()
                        : val.sell.toString();
                  } else {
                    purchaseCtrl.text = '';
                    discountCtrl.text = '';
                  }
                });
              },

            ),

          ),

          // ------------------ Book Language Dropdown ------------------
          Container(
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(6),
            ),
            child: DropdownButton<String>(
              dropdownColor: Colors.black87,
              value: bookLanguage,
              iconEnabledColor: Colors.white,
              style: const TextStyle(color: Colors.white),
              isExpanded: true,
              items: const [
                DropdownMenuItem(
                  value: "Text",
                  child: Text(
                    "Text",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                DropdownMenuItem(
                  value: "Sohika",
                  child: Text(
                    "Sohika",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                DropdownMenuItem(
                  value: "Chatro bondhu",
                  child: Text(
                    "Chatro bondhu",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                DropdownMenuItem(
                  value: "Khata",
                  child: Text(
                    "Khata",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                DropdownMenuItem(
                  value: "Pen",
                  child: Text(
                    "Pen",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                DropdownMenuItem(
                  value: "Penchil",
                  child: Text(
                    "Penchil",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                DropdownMenuItem(
                  value: "Helping Tools",
                  child: Text(
                    "Helping Tools",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
              onChanged: (val) {
                setState(() {
                  bookLanguage = val!;
                });
              },
            ),
          ),



          // ------------------ Class Dropdown ------------------
          Container(
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(6),
            ),
            child: DropdownButton<ClassModel>(
              dropdownColor: Colors.black87,   // ⬅️ dark dropdown window
              value: selectedClass,
              hint: const Text(
                "Select Class",
                style: TextStyle(color: Colors.white),
              ),
              iconEnabledColor: Colors.white,
              style: const TextStyle(color: Colors.white),
              isExpanded: true,
              items: classList
                  .map((cls) => DropdownMenuItem(
                value: cls,
                child: Text(cls.name,
                    style: const TextStyle(color: Colors.white)),
              ))
                  .toList(),
              onChanged: (val) {
                setState(() => selectedClass = val);
              },
            ),
          ),

          // ------------------ STATIC dropdown: Discount / Flat ------------------
          Container(
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(6),
            ),
            child: DropdownButton<String>(
              dropdownColor: Colors.black87,
              value: priceType,
              hint: const Text("Select Price Type",
                  style: TextStyle(color: Colors.white)),
              iconEnabledColor: Colors.white,
              style: const TextStyle(color: Colors.white),
              isExpanded: true,
              items: ["Discount", "Flat"].map((txt) {
                return DropdownMenuItem(
                  value: txt,
                  child: Text(txt,
                      style: const TextStyle(color: Colors.white)),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  priceType = val!;
                });
              },
            ),
          ),

        ],
      ),
    ),
  );


  Widget _priceCard() => Card(
    color: AppColors.BLACK_7,
    child: Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          snTextField(hint: "MRP", label: "MRP", controller: mrpCtrl,onChanged: (_) => setState(() {}),),
          const SizedBox(height: 10),
          snTextField(hint: "Sell Discount", label: "Sell Discount", controller: discountCtrl,onChanged: (_) => setState(() {}),),
          const SizedBox(height: 10),
          snTextField(hint: "Purchase Discount", label: "Purchase Discount", controller: purchaseCtrl,onChanged: (_) => setState(() {}),),
          const SizedBox(height: 10),
          snTextField(hint: "Quantity", label: "Quantity", controller: quantityCtrl,onChanged: (_) => setState(() {}),),
        ],
      ),
    ),
  );

  Widget _shopCard() => Card(
    color: AppColors.BLACK_7,
    child: Padding(
      padding: const EdgeInsets.all(8),
      child: Theme(
        // 🔥 This makes dropdown arrow WHITE
        data: Theme.of(context).copyWith(
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        child: MultiSelectDialogField<ShopModel>(
          items: shopList.map((s) => MultiSelectItem(s, s.name)).toList(),
          initialValue: selectedShopModels,

          // Dialog title
          title: const Text(
            "Select Shop",
            style: TextStyle(color: AppColors.BLACK_9),
          ),

          searchable: true,

          itemsTextStyle: const TextStyle(color: AppColors.BLACK_9),
          selectedItemsTextStyle:
          const TextStyle(color: Colors.green),

          // 👇 BUTTON TEXT (HINT)
          buttonText: const Text(
            "Select Shop",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),

          // 👇 BUTTON UI
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white, width: 1),
          ),

          selectedColor: Colors.green,

          onConfirm: (values) =>
              setState(() => selectedShopModels = values),

          chipDisplay: MultiSelectChipDisplay(
            chipColor: AppColors.GREEN_9,
            textStyle: const TextStyle(color: Colors.white),
            onTap: (val) =>
                setState(() => selectedShopModels.remove(val)),
          ),
        ),
      ),
    ),
  );




  // ------------------------ IMAGE UPLOADER ------------------------
  Widget _buildImageUploader(double size) {
    const double boxWidth = 200;
    const double boxHeight = 300;

    return Card(
      color: AppColors.BLACK_7,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ..._dbImages.map((img) => _dbImageBox(img)), // 🔥 DB images
            ..._pickedImages.asMap().entries.map(
                  (e) => _imageBox(e.key, e.value),           // 🔥 New images
            ),
            _dropPickBox(boxWidth, boxHeight),
          ],
        ),

      ),
    );
  }

  Widget _imageBox(int index, File img) {
    return commonCoverBox(
      imageProvider: FileImage(img),
      onDelete: () {
        setState(() {
          _pickedImages.removeAt(index);
        });
      },
    );
  }


  Widget commonCoverBox({
    required ImageProvider imageProvider,
    VoidCallback? onDelete,
    IconData icon = Icons.close,
    Color iconColor = Colors.white,
  }) {
    return SizedBox(
      width: 200,
      height: 300,
      child: Stack(
        children: [
          Container(
            width: 200,
            height: 300,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: imageProvider,
                fit: BoxFit.cover, // 🔥 FINAL FIX
              ),
            ),
          ),

          if (onDelete != null)
            Positioned(
              top: 6,
              right: 6,
              child: GestureDetector(
                onTap: onDelete,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Icon(icon, color: iconColor, size: 18),
                ),
              ),
            ),
        ],
      ),
    );
  }





  Widget _dropPickBox(double w, double h) {
    return DropRegion(
      formats: Formats.standardFormats,
      onDropOver: (_) => DropOperation.copy,
      onPerformDrop: _handleDropNew,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: _pickImagesNew,
          child: Container(
            height: h,
            width: w,
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white38),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cloud_upload, color: Colors.white, size: 40),
                SizedBox(height: 8),
                Text(
                  'Drag & Drop\nor Click to Pick',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  // ------------------------ PREVIEW CARD ------------------------
  Widget _buildPreviewCard() {
    final calc = calculatedData;

    // 🔹 Merge picked images + db images for slider
    final allImages = [
      ..._pickedImages,
      ..._dbImages.map((e) => e.bytes),
    ];

    return SizedBox(
      height: 700, // fixed height
      child: Card(
        color: AppColors.BLACK_7,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---------------- IMAGE SLIDER ----------------
                SizedBox(
                  height: 200,
                  child: allImages.isEmpty
                      ? Container(
                    color: Colors.grey[800],
                    child: const Center(
                      child: Text(
                        "No Media",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  )
                      : ScrollConfiguration(
                    behavior: MouseDragScrollBehavior(),
                    child: NotificationListener<UserScrollNotification>(
                      onNotification: (notification) {
                        if (notification.direction != ScrollDirection.idle) {
                          _autoSlideTimer?.cancel(); // pause auto-slide
                        } else {
                          _startAutoSlide(); // resume auto-slide
                        }
                        return false;
                      },
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: allImages.length,
                        onPageChanged: (index) {
                          setState(() => _currentImageIndex = index);
                        },
                        itemBuilder: (context, index) {
                          final img = allImages[index];
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: img is File
                                ? Image.file(
                              img,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 200,
                            )
                                : Image.memory(
                              img is Uint8List ? img : Uint8List(0),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 200,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // ---------------- DOT INDICATOR ----------------
                if (allImages.length > 1)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      allImages.length,
                          (i) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: _currentImageIndex == i ? 10 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: _currentImageIndex == i
                              ? Colors.white
                              : Colors.white38,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 12),

                // ---------------- PREVIEW DETAILS ----------------
                _previewRow("📖 Book :", nameCtrl.text),
                _previewRow("✍️ Author :", authorCtrl.text),
                _previewRow(
                    "🏷 Brand (Publication) :", selectedPublication?.name ?? '-'),
                _previewRow(
                    "📚 Book Type :", selectedBookType?.typeName ?? '-'),
                _previewRow("🈶 Book Medium :", bookLanguage),
                _previewRow("📚 Class :", selectedClass?.name ?? '-'),

                const Divider(color: Colors.white38),

                _previewRow("💰 MRP :", mrpCtrl.text),
                _previewRow("💸 Sell Discount :", discountCtrl.text),
                _previewRow("🧾 Purchase Discount :", purchaseCtrl.text),

                _previewRow(
                  "🛒 Purchase Price :",
                  calc["purchasePrice"].toString(),
                  valueColor: Colors.orangeAccent,
                ),

                _previewRow(
                  priceType == "Discount"
                      ? "💸 Sell Price (%)"
                      : "💸 Sell Price (Flat)",
                  calc["sellPrice"].toString(),
                  valueColor: Colors.greenAccent,
                ),

                _previewRow(
                  "📈 Profit :",
                  calc["profit"].toString(),
                  valueColor: calc["profit"] >= 0
                      ? Colors.lightGreen
                      : Colors.redAccent,
                ),

                _previewRow("📦 Quantity :", quantityCtrl.text),

                const Divider(color: Colors.white38),

                _previewRow(
                  "🏪 Shops : ",
                  selectedShopModels.isEmpty
                      ? '-'
                      : selectedShopModels.map((e) => e.name).join(', '),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }





  Widget _previewRow(
      String title,
      String value, {
        Color titleColor = Colors.white70,
        Color valueColor = Colors.white,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(color: titleColor)),
          Flexible(
            child: Text(
              value.isEmpty ? "-" : value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: valueColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }



}

bool _isImage(File file) {
  final p = file.path.toLowerCase();
  return p.endsWith('.png') ||
      p.endsWith('.jpg') ||
      p.endsWith('.jpeg') ||
      p.endsWith('.webp');
}