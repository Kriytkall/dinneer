import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';

class BarraNavegacaoCustomizada extends StatelessWidget {
  final int index;
  final Function(int) onTap;

  const BarraNavegacaoCustomizada({
    super.key,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      const Icon(Icons.home_outlined, size: 30),
      const Icon(Icons.chat_bubble_outline, size: 30),
      const Icon(Icons.add, size: 30),
      const Icon(Icons.restaurant_outlined, size: 30),
      const Icon(Icons.person_outline, size: 30),
    ];

    return CurvedNavigationBar(
      items: items,
      index: index,
      onTap: onTap,
      height: 60,
      backgroundColor: Colors.transparent,
      buttonBackgroundColor: Colors.white,
      color: Colors.white,
      animationCurve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 400),
    );
  }
}
