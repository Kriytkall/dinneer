import 'package:flutter/material.dart';

class TelaPerfil extends StatefulWidget {
  final Map<String, dynamic> dadosUsuario;

  const TelaPerfil({super.key, required this.dadosUsuario});

  @override
  State<TelaPerfil> createState() => _TelaPerfilState();
}

class _TelaPerfilState extends State<TelaPerfil> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final nome = widget.dadosUsuario['nm_usuario'] ?? 'Usuário';
    final email = widget.dadosUsuario['vl_email'] ?? '@usuario';
    final fotoUrl = widget.dadosUsuario['vl_foto']; // URL do Firebase

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280.0,
            backgroundColor: Colors.white,
            elevation: 0,
            pinned: true,
            stretch: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(color: Colors.grey[200]),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.black.withOpacity(0.4), Colors.transparent],
                        begin: Alignment.topCenter,
                        end: Alignment.center,
                      ),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 30),
                        CircleAvatar(
                          radius: 54,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey,
                            // Se tem URL, carrega da rede. Se não, mostra ícone.
                            backgroundImage: (fotoUrl != null && fotoUrl.toString().isNotEmpty)
                                ? NetworkImage(fotoUrl)
                                : null,
                            child: (fotoUrl == null || fotoUrl.toString().isEmpty)
                                ? const Icon(Icons.person, size: 50, color: Colors.white) 
                                : null,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          nome,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        Text(email, style: const TextStyle(color: Colors.white70)),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildStatItem(Icons.restaurant_menu, '0', 'Jantas'),
                            Container(height: 30, width: 1, color: Colors.white30, margin: const EdgeInsets.symmetric(horizontal: 20)),
                            _buildStatItem(Icons.star, '5.0', 'Estrelas'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPersistentHeader(
            delegate: _SliverAppBarDelegate(
              TabBar(
                controller: _tabController,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.black,
                indicatorWeight: 2,
                tabs: const [Tab(text: 'Imagens'), Tab(text: 'Avaliações')],
              ),
            ),
            pinned: true,
          ),
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                const Center(child: Text("Galeria vazia")),
                _buildAvaliacoesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Row(children: [Icon(icon, color: Colors.white70, size: 20), const SizedBox(width: 8), Text("$value $label", style: const TextStyle(color: Colors.white70))]);
  }

  Widget _buildAvaliacoesTab() {
    return ListView(padding: const EdgeInsets.all(20), children: [_buildRatingCard('Comida', 5), _buildRatingCard('Hospitalidade', 5)]);
  }

  Widget _buildRatingCard(String category, int rating) {
    return Card(
      elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey[200]!)), margin: const EdgeInsets.only(bottom: 12),
      child: Padding(padding: const EdgeInsets.all(16.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(category, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), const SizedBox(height: 8), Row(children: List.generate(5, (index) => Icon(index < rating ? Icons.star_rounded : Icons.star_border_rounded, color: Colors.amber, size: 22)))]))
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);
  final TabBar _tabBar;
  @override double get minExtent => _tabBar.preferredSize.height;
  @override double get maxExtent => _tabBar.preferredSize.height;
  @override Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => Container(color: Colors.white, child: _tabBar);
  @override bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}