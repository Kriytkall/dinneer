import 'package:flutter/material.dart';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';

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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 15,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: BottomNavyBar(
        selectedIndex: index,
        onItemSelected: onTap,
        backgroundColor: Colors.white,
        itemCornerRadius: 12,
        curve: Curves.easeIn,
        items: <BottomNavyBarItem>[
          BottomNavyBarItem(
            icon: const Icon(Icons.home_rounded),
            title: const Text('Home'),
            activeColor: Colors.black,
            inactiveColor: Colors.grey[600],
            textAlign: TextAlign.center,
          ),
          BottomNavyBarItem(
            icon: const Icon(Icons.chat_bubble_rounded),
            title: const Text('Chat'),
            activeColor: Colors.black,
            inactiveColor: Colors.grey[600],
            textAlign: TextAlign.center,
          ),
          BottomNavyBarItem(
            icon: const Icon(Icons.restaurant_rounded),
            title: const Text('Pedidos'),
            activeColor: Colors.black,
            inactiveColor: Colors.grey[600],
            textAlign: TextAlign.center,
          ),
          BottomNavyBarItem(
            icon: const Icon(Icons.person_rounded),
            title: const Text('Perfil'),
            activeColor: Colors.black,
            inactiveColor: Colors.grey[600],
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

