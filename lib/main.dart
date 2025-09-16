import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/tela_login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await initializeDateFormatting('pt_BR', null);
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dinneer',
      theme: ThemeData(
        primarySwatch: Colors.grey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const TelaLogin(),
      debugShowCheckedModeBanner: false,
    );
  }
}

