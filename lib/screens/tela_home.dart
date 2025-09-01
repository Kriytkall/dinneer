import 'package:flutter/material.dart';

class TelaHome extends StatefulWidget {
  const TelaHome({super.key});

  @override
  State<TelaHome> createState() => _TelaHomeState();
}

class _TelaHomeState extends State<TelaHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tela Home'),
      ),
      body: const Center(
        child: Text('Bem-vindo à Tela Home!'),
      ),
    );
  }
}
