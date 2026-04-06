import 'package:flutter/material.dart';
import 'package:dinneer/service/refeicao/Cardapio.dart';

class JantarAppBar extends StatelessWidget {
  final Cardapio refeicao;

  const JantarAppBar({super.key, required this.refeicao});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 280.0,
      backgroundColor: Colors.white,
      elevation: 0,
      pinned: true,
      stretch: true,
      flexibleSpace: FlexibleSpaceBar(
        background: ClipPath(
          clipper: AppBarClipper(),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              image: (refeicao.urlFoto != null && refeicao.urlFoto!.isNotEmpty)
                  ? DecorationImage(image: NetworkImage(refeicao.urlFoto!), fit: BoxFit.cover)
                  : null,
            ),
            child: (refeicao.urlFoto == null || refeicao.urlFoto!.isEmpty)
                ? const Icon(Icons.restaurant, size: 100, color: Colors.white)
                : null,
          ),
        ),
      ),
      leading: CircleAvatar(
        backgroundColor: Colors.white.withValues(alpha: 0.8),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }
}

class AppBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    const curveHeight = 40.0;
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height - curveHeight);
    path.quadraticBezierTo(size.width / 2, size.height, 0, size.height - curveHeight);
    path.close();
    return path;
  }
  
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
