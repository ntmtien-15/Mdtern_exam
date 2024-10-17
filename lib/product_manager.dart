import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class ProductManager extends StatefulWidget {
  @override
  _ProductManagerState createState() => _ProductManagerState();
}

class _ProductManagerState extends State<ProductManager> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  File? imageFile;
  String? imageUrl;

  final ImagePicker _picker = ImagePicker();

//Chon hinh anh tu thu vien
  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
    }
  }
// Tai anh len FS
  Future<void> uploadImage() async {
    if (imageFile != null) {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageRef =
          FirebaseStorage.instance.ref().child('products/$fileName');
      UploadTask uploadTask = storageRef.putFile(imageFile!);
      TaskSnapshot snapshot = await uploadTask;
      imageUrl = await snapshot.ref.getDownloadURL();
    }
  }

// Them san pham
  void addProduct() async {
    // kiem tra trong va thong bao
    if (nameController.text.isEmpty || categoryController.text.isEmpty || priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng điền đầy đủ thông tin.')),
      );
      return;
    }
    try {
      await uploadImage(); // tai anh len và lay URL
      await FirebaseFirestore.instance.collection('products').add({ //them sp vao FS
        'name': nameController.text,
        'category': categoryController.text,
        'price': double.parse(priceController.text),
        'imageUrl': imageUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Thêm sản phẩm thành công!')),
      );
      // cap nhạt lai UI
      nameController.clear();
      categoryController.clear();
      priceController.clear();
      setState(() {
        imageFile = null;
    });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Có lỗi xảy ra khi thêm sản phẩm.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( // Tieu de
        title: Text('Dữ liệu sản phẩm'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Tên sản phẩm'),
            ),
            TextField(
              controller: categoryController,
              decoration: InputDecoration(labelText: 'Loại sản phẩm'),
            ),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Giá sản phẩm'), 
            ),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: pickImage,
                  icon: Icon(Icons.folder_open),
                  label: Text(imageFile != null
                      ? imageFile!.path.split('/').last
                      : 'Chọn hình ảnh'),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: addProduct,
              child: Text('THÊM SẢN PHẨM'),
            ),
            Expanded(
              child: StreamBuilder( //lang nghe luong trong FS và update UI khi dl thay doi
                stream: FirebaseFirestore.instance.collection('products').snapshots(),
                builder: (context, AsyncSnapshot snapshot) { //duoc goi khi co dl moi
                  if (!snapshot.hasData) { //kiem tra luong có cung cap dl k ?
                    return Center(child: CircularProgressIndicator());
                  }
                  var products = snapshot.data.docs; //lấy lại ds
                  return ListView.builder( //hien thi ds sp
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      var product = products[index];
                      return Card(
                        child: ListTile(
                          leading: product['imageUrl'] != null
                              ? Image.network(product['imageUrl'])
                              : Container(width: 50, height: 50),
                          title: Text('Tên sp: ${product['name']}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Giá sp: ${product['price']}'),
                              Text('Loại sp: ${product['category']}'),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  FirebaseFirestore.instance
                                      .collection('products')
                                      .doc(product.id)
                                      .delete();
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
