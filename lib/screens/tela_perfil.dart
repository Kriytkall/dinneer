import 'package:dinneer/screens/tela_criar_jantar.dart';
import 'package:dinneer/screens/tela_meus_jantares.dart';
import 'package:dinneer/service/sessao/SessionService.dart';
import 'package:flutter/material.dart';
import 'tela_criar_local.dart';
import 'package:dinneer/service/local/LocalService.dart';

class TelaPerfil extends StatefulWidget {
  final Map<String, dynamic> dadosUsuario;

  const TelaPerfil({super.key, required this.dadosUsuario});

  @override
  State<TelaPerfil> createState() => _TelaPerfilState();
}

class _TelaPerfilState extends State<TelaPerfil>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String? idUsuario;

  List<dynamic> meusLocais = [];
  bool carregandoLocais = true;

  @override
  void initState() {
    super.initState();

    // TabController fixo — sempre 3 abas
    _tabController = TabController(length: 3, vsync: this);

    _carregarIdUsuario();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Carrega o id do usuário da sessão
  Future<void> _carregarIdUsuario() async {
    try {
      final id = await SessionService.pegarUsuarioId();

      if (!mounted) return;
      setState(() => idUsuario = id);

      await _carregarMeusLocais();
    } catch (e) {
      if (!mounted) return;
      setState(() => carregandoLocais = false);
    }
  }

  // Carrega os locais do usuário SEM recriar TabController
  Future<void> _carregarMeusLocais() async {
    if (idUsuario == null) return;

    if (!mounted) return;
    setState(() => carregandoLocais = true);

    try {
      final resposta = await LocalService.getMeusLocais(idUsuario!);

      if (!mounted) return;

      setState(() {
        meusLocais = resposta['dados'] ?? [];
        carregandoLocais = false;
      });

    } catch (e) {
      if (!mounted) return;
      setState(() => carregandoLocais = false);
    }
  }

  // Confirmação e execução da exclusão do local
  void _confirmarDeleteLocal(int idLocal) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Excluir local"),
          content: const Text("Tem certeza que deseja excluir este local?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);

                try {
                  await LocalService.deleteLocal(idLocal.toString());

                  if (!mounted) return;
                  await _carregarMeusLocais();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Local excluído com sucesso.")),
                  );

                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Erro ao excluir local.")),
                  );
                }
              },
              child: const Text("Excluir", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final nome = widget.dadosUsuario['nm_usuario'] ?? 'Usuário';
    final email = widget.dadosUsuario['vl_email'] ?? '@usuario';
    final fotoUrl = widget.dadosUsuario['vl_foto'];

    if (idUsuario == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  TelaCriarLocal(idUsuario: int.parse(idUsuario!)),
            ),
          ).then((_) {
            if (!mounted) return;
            _carregarMeusLocais();
          });
        },
        label: const Text("Adicionar local"),
        icon: const Icon(Icons.home),
      ),

      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            backgroundColor: Colors.white,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(color: Colors.grey[200]),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.4),
                          Colors.transparent
                        ],
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
                            backgroundImage:
                                fotoUrl != null && fotoUrl != ""
                                    ? NetworkImage(fotoUrl)
                                    : null,
                            child: fotoUrl == null || fotoUrl == ""
                                ? const Icon(Icons.person,
                                    size: 50, color: Colors.white)
                                : null,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          nome,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          email,
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),

          // TABS — sempre 3
          SliverPersistentHeader(
            delegate: _SliverAppBarDelegate(
              TabBar(
                controller: _tabController,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.black,
                tabs: const [
                  Tab(text: "Imagens"),
                  Tab(text: "Avaliações"),
                  Tab(text: "Meus Locais"),
                ],
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
                _buildMeusLocaisTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // TAB — MEUS LOCAIS
  Widget _buildMeusLocaisTab() {
    if (carregandoLocais) {
      return const Center(child: CircularProgressIndicator());
    }

    if (meusLocais.isEmpty) {
      return const Center(
        child: Text("Você ainda não possui locais cadastrados."),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: meusLocais.length,
      itemBuilder: (context, index) {
        final local = meusLocais[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.red),
                    const SizedBox(width: 8),
                    Text(
                      "CEP: ${local['nu_cep']}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    const Icon(Icons.home),
                    const SizedBox(width: 8),
                    Text(
                      "Casa: ${local['nu_casa']}",
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TelaMeusJantares(
                              idLocal: local['id_local'],
                              idUsuario: int.parse(idUsuario!),
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.list_alt),
                      label: const Text("Meus jantares"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                      ),
                    ),

                    ElevatedButton.icon(
                      onPressed: () async {
                        final bool? criou = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TelaCriarJantar(
                              idUsuario: idUsuario!,
                            ),
                          ),
                        );

                        if (criou == true) {
                          if (!mounted) return;
                          _carregarMeusLocais();
                        }
                      },
                      icon: const Icon(Icons.restaurant_menu),
                      label: const Text("Novo jantar"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                    ),

                    ElevatedButton.icon(
                      onPressed: () {
                        _confirmarDeleteLocal(local['id_local']);
                      },
                      icon: const Icon(Icons.delete),
                      label: const Text("Excluir"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // TAB — AVALIAÇÕES
  Widget _buildAvaliacoesTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildRatingCard('Comida', 5),
        _buildRatingCard('Hospitalidade', 5),
      ],
    );
  }

  Widget _buildRatingCard(String category, int rating) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(category,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: List.generate(
                  5,
                  (index) => Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                  ),
                ),
              )
            ]),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);
  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
          BuildContext context, double shrinkOffset, bool overlapsContent) =>
      Container(color: Colors.white, child: _tabBar);

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}
