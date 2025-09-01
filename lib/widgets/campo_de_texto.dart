import 'package:flutter/material.dart';

class CampoDeTextoCustomizado extends StatelessWidget {
  final String dica;
  final bool textoObscuro;

  const CampoDeTextoCustomizado({
    super.key,
    required this.dica,
    this.textoObscuro = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
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
