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
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  String? idUsuario;

  List<dynamic> meusLocais = [];
  bool carregandoLocais = true;

  bool temLocais = false; // <<< CONTROLE PRINCIPAL

  @override
  void initState() {
    super.initState();
    _carregarIdUsuario();
  }

  Future<void> _carregarIdUsuario() async {
    final id = await SessionService.pegarUsuarioId();
    setState(() => idUsuario = id);

    await _carregarMeusLocais();
  }

  Future<void> _carregarMeusLocais() async {
    if (idUsuario == null) return;

    try {
      final resposta = await LocalService.getMeusLocais(idUsuario!);

      int registros = resposta['registros'] ?? 0;

      setState(() {
        temLocais = registros > 0;

        meusLocais = resposta['dados'] ?? [];
        carregandoLocais = false;

        _tabController = TabController(
          length: temLocais ? 3 : 2,  
          vsync: this,
        );
      });
    } catch (e) {
      setState(() => carregandoLocais = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final nome = widget.dadosUsuario['nm_usuario'] ?? 'Usuário';
    final email = widget.dadosUsuario['vl_email'] ?? '@usuario';
    final fotoUrl = widget.dadosUsuario['vl_foto'];

    if (idUsuario == null || _tabController == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,

      // FAB — SOMENTE SE NÃO TIVER LOCAIS
      floatingActionButton: !temLocais
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        TelaCriarLocal(idUsuario: int.parse(idUsuario!)),
                  ),
                ).then((_) => _carregarMeusLocais());
              },
              label: const Text("Quero virar anfitrião"),
              icon: const Icon(Icons.home),
            )
          : null,

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
                            backgroundImage: (fotoUrl != null && fotoUrl != "")
                                ? NetworkImage(fotoUrl)
                                : null,
                            child: (fotoUrl == null || fotoUrl == "")
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
                        Text(email,
                            style: const TextStyle(color: Colors.white70)),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),

          // TABS
          SliverPersistentHeader(
            delegate: _SliverAppBarDelegate(
              TabBar(
                controller: _tabController,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.black,
                tabs: temLocais
                    ? const [
                        Tab(text: "Imagens"),
                        Tab(text: "Avaliações"),
                        Tab(text: "Meus Locais"),
                      ]
                    : const [
                        Tab(text: "Imagens"),
                        Tab(text: "Avaliações"),
                      ],
              ),
            ),
            pinned: true,
          ),

          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: temLocais
                  ? [
                      const Center(child: Text("Galeria vazia")),
                      _buildAvaliacoesTab(),
                      _buildMeusLocaisTab(),
                    ]
                  : [
                      const Center(child: Text("Galeria vazia")),
                      _buildAvaliacoesTab(),
                    ],
            ),
          ),
        ],
      ),
    );
  }

Widget _buildMeusLocaisTab() {
  if (carregandoLocais) {
    return const Center(child: CircularProgressIndicator());
  }

  return Column(
    children: [
      const SizedBox(height: 10),

      Expanded(
        child: meusLocais.isEmpty
            ? const Center(
                child: Text("Você ainda não possui locais cadastrados."),
              )
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
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

                          // -------------------------------
                          //      ROW 1 — CEP
                          // -------------------------------
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

                          // -------------------------------
                          //      ROW 2 — CASA
                          // -------------------------------
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

                          // -------------------------------
                          //      ROW 3 — AÇÕES
                          // -------------------------------
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              
                              // BOTÃO MEUS JANTARES
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

                              // BOTÃO NOVO JANTAR
                              ElevatedButton.icon(
                                onPressed: () async {
                                  final bool? criou = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => TelaCriarJantar(
                                        idUsuario: idUsuario!,
                                        // idLocal: local['id_local'],
                                      ),
                                    ),
                                  );

                                  if (criou == true) {
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

                              // BOTÃO DELETAR
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
              ),
      ),
    ],
  );
}


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

                await LocalService.deleteLocal(idLocal.toString());
                _carregarMeusLocais();
              },
              child: const Text("Excluir", style: TextStyle(color: Colors.red)),
            ),
          ],
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
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(category,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
