// lib/widgets/campo_de_texto.dart

import 'package:flutter/material.dart';

class CampoDeTextoCustomizado extends StatelessWidget {
  // Adicionamos o controller como um parâmetro obrigatório.
  final TextEditingController controller;
  final String dica;
  final bool textoObscuro;

  const CampoDeTextoCustomizado({
    super.key,
    required this.controller, // Incluímos o controller no construtor.
    required this.dica,
    this.textoObscuro = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller, // Ligamos o controller ao TextField.
      obscureText: textoObscuro,
      decoration: InputDecoration(
        hintText: dica,
        hintStyle: TextStyle(color: Colors.grey[400]),
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding:
            const EdgeInsets.symmetric(vertical: 18.0, horizontal: 20.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.grey[400]!),
        ),
      ),
    );
  }
}