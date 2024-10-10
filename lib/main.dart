import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:midtern_exam/firebase_options.dart';

import 'product_manager.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp( //khỏi tạo firebase
    options: DefaultFirebaseOptions.currentPlatform,
);
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quản lý sản phẩm',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      
      home: ProductManager(), // Gọi widget quản lý sản phẩm
      debugShowCheckedModeBanner: false,
    );
  }
}