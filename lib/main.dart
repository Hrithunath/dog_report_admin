import 'package:admin_dog_rport/drawer.dart';
import 'package:admin_dog_rport/firebase_options.dart';
import 'package:admin_dog_rport/report_details.dart';
import 'package:admin_dog_rport/report_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Make sure to import provider

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AdminService(),
      child: MaterialApp(debugShowCheckedModeBanner: false, home: SideBar()),
    );
  }
}
