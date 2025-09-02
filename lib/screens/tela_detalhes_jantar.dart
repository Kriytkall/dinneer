import 'package:flutter/material.dart';

class TelaDetalhesJantar extends StatelessWidget {
  const TelaDetalhesJantar({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[300],
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: const Text(
            'AGENDAMENTO',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280.0,
            backgroundColor: Colors.white,
            elevation: 0,
            pinned: true,
            stretch: true,
            flexibleSpace: FlexibleSpaceBar(
              background: ClipPath(
                clipper: AppBarClipper(),
                child: Container(
                  color: Colors.grey[200],
                  child:
                      const Icon(Icons.image, size: 100, color: Colors.white),
                ),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black54),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitulo(),
                  const SizedBox(height: 8),
                  const Text(
                    'R\$ 50,00',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoUsuario(),
                  const SizedBox(height: 16),
                  const Text(
                    'Venha conhecer o jantar italiano do Thalis. Uma delícia única com ingrediente secreto passado de geração em geração. Venha se deliciar com essa obra...',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildDetalhesAdicionais(),
                  const SizedBox(height: 24),
                  _buildMapa(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitulo() {
    return const Text(
      'Jantar Italiano Gourmet',
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildInfoUsuario() {
    return Row(
      children: [
        const CircleAvatar(
          radius: 24,
          backgroundColor: Colors.grey,
        ),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nome de usuário',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber, size: 16),
                Icon(Icons.star, color: Colors.amber, size: 16),
                Icon(Icons.star, color: Colors.amber, size: 16),
                Icon(Icons.star, color: Colors.amber, size: 16),
                Icon(Icons.star_half, color: Colors.amber, size: 16),
              ],
            ),
          ],
        ),
        const Spacer(),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.chat_bubble_outline, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildDetalhesAdicionais() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildInfoRow(Icons.calendar_today, '12/09 às 19h'),
        _buildInfoRow(Icons.people_alt_outlined, '0/4 vagas'),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[700]),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(color: Colors.grey[800], fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildMapa() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Text(
          'Mapa Placeholder',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

// Classe que define o formato customizado para a AppBar
class AppBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    const curveHeight = 40.0;

    // Desenha o caminho com a curva e sem cantos arredondados no topo
    path.moveTo(0, 0); // Canto superior esquerdo
    path.lineTo(size.width, 0); // Linha reta para o canto superior direito
    path.lineTo(size.width, size.height - curveHeight); // Linha para baixo
    path.quadraticBezierTo(
      size.width / 2, // Ponto de controle X (centro)
      size.height, // Ponto de controle Y (o ponto mais baixo da curva)
      0, // Ponto final X (borda esquerda)
      size.height - curveHeight, // Ponto final Y (acima da base)
    );
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

