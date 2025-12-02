import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

// Imports das telas de navegação
import 'package:dinneer/screens/tela_criar_jantar.dart';
import 'package:dinneer/screens/tela_meus_jantares.dart';
import 'package:dinneer/screens/tela_criar_local.dart';

// Imports dos serviços
import 'package:dinneer/service/sessao/SessionService.dart';
import 'package:dinneer/service/local/LocalService.dart';
import 'package:dinneer/service/usuario/UsuarioService.dart';

class TelaPerfil extends StatefulWidget {
  final Map<String, dynamic> dadosUsuario;

  const TelaPerfil({super.key, required this.dadosUsuario});

  @override
  State<TelaPerfil> createState() => _TelaPerfilState();
}

class _TelaPerfilState extends State<TelaPerfil> with TickerProviderStateMixin {
  late TabController _tabController;
  
  // Dados do Usuário
  String? idUsuario;
  String? fotoUrlAtual;
  String nomeUsuario = "Usuário";
  String emailUsuario = "@usuario";

  // Estado da Tela
  List<dynamic> meusLocais = [];
  bool carregandoLocais = true;
  bool _enviandoFoto = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    _inicializarDadosUsuario();
  }

  void _inicializarDadosUsuario() {
    // 1. Carrega dados básicos que vieram do Login
    setState(() {
      nomeUsuario = widget.dadosUsuario['nm_usuario'] ?? 'Usuário';
      emailUsuario = widget.dadosUsuario['vl_email'] ?? '@usuario';
      
      final rawFoto = widget.dadosUsuario['vl_foto'];
      if (rawFoto != null && rawFoto.toString().isNotEmpty && rawFoto.toString() != 'null') {
        fotoUrlAtual = rawFoto.toString();
      }
    });

    // 2. Define o ID do usuário (prioridade para o que veio via parâmetro)
    if (widget.dadosUsuario['id_usuario'] != null) {
      idUsuario = widget.dadosUsuario['id_usuario'].toString();
      debugPrint("TelaPerfil: ID carregado via parâmetros: $idUsuario");
      _carregarMeusLocais(); 
    } else {
      // Fallback: Tenta pegar da sessão se não veio nos parâmetros
      _carregarIdUsuarioSessao();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // --- LÓGICA DE CARREGAMENTO DE DADOS ---

  Future<void> _carregarIdUsuarioSessao() async {
    try {
      final id = await SessionService.pegarUsuarioId();
      if (!mounted) return;
      
      setState(() => idUsuario = id);
      if (id != null) {
        _carregarMeusLocais();
      } else {
        setState(() => carregandoLocais = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => carregandoLocais = false);
    }
  }

  Future<void> _carregarMeusLocais() async {
    if (idUsuario == null) return;

    if (!mounted) return;
    setState(() => carregandoLocais = true);

    try {
      debugPrint("TelaPerfil: Buscando locais para ID $idUsuario...");
      final resposta = await LocalService.getMeusLocais(idUsuario!);
      
      if (!mounted) return;

      setState(() {
        meusLocais = resposta['dados'] ?? [];
        carregandoLocais = false;
      });
    } catch (e) {
      debugPrint("TelaPerfil: Erro ao carregar locais: $e");
      if (!mounted) return;
      setState(() => carregandoLocais = false);
    }
  }

  // --- LÓGICA DE FOTO DE PERFIL ---

  Future<void> _alterarFotoPerfil() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? imagem = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, // Otimização
        maxWidth: 1080,
      );

      if (imagem != null) {
        setState(() => _enviandoFoto = true);
        await _uploadEAtualizarFoto(File(imagem.path));
      }
    } catch (e) {
      debugPrint("Erro ao escolher imagem: $e");
      setState(() => _enviandoFoto = false);
    }
  }

  Future<void> _uploadEAtualizarFoto(File imagem) async {
    try {
      debugPrint("--- INICIANDO UPLOAD DE PERFIL ---");

      // 1. Upload para Firebase Storage (COM METADADOS)
      String nomeArquivo = "perfil_${DateTime.now().millisecondsSinceEpoch}.jpg";
      Reference ref = FirebaseStorage.instance.ref().child('perfis/$nomeArquivo');
      
      // CRUCIAL: Adicionar metadados para evitar erro no Android
      final metadata = SettableMetadata(contentType: "image/jpeg");
      
      UploadTask task = ref.putFile(imagem, metadata);
      
      // Timeout de segurança
      await task.whenComplete(() {}).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception("Tempo limite excedido no upload.");
        },
      );

      String novaUrl = await ref.getDownloadURL();
      debugPrint("Upload concluído. Nova URL: $novaUrl");

      // 2. Atualizar no Banco de Dados (PHP)
      if (idUsuario != null) {
         await UsuarioService.atualizarFotoPerfil(idUsuario!, novaUrl);
      }

      // 3. Atualizar UI
      if (mounted) {
        setState(() {
          fotoUrlAtual = novaUrl;
          _enviandoFoto = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Foto de perfil atualizada com sucesso!"), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      debugPrint("Erro ao atualizar foto: $e");
      if (mounted) {
        setState(() => _enviandoFoto = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erro ao enviar a foto. Tente novamente."), backgroundColor: Colors.red),
        );
      }
    }
  }

  // --- LÓGICA DE LOCAIS ---

  void _confirmarDeleteLocal(int idLocal) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Excluir local"),
          content: const Text("Tem certeza que deseja excluir este local? Todos os jantares vinculados a ele também serão excluídos."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await LocalService.deleteLocal(idLocal.toString());
                  if (!mounted) return;
                  await _carregarMeusLocais(); // Recarrega a lista
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Local excluído.")));
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erro ao excluir."), backgroundColor: Colors.red));
                }
              },
              child: const Text("Excluir", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (idUsuario == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      
      // Botão Flutuante para criar NOVO LOCAL
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TelaCriarLocal(idUsuario: int.parse(idUsuario!)),
            ),
          ).then((_) {
            if (!mounted) return;
            _carregarMeusLocais();
          });
        },
        label: const Text("Adicionar local", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        icon: const Icon(Icons.add_location_alt, color: Colors.white),
        backgroundColor: Colors.black,
      ),

      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          
          // Barra de Abas (Imagens / Avaliações / Locais)
          SliverPersistentHeader(
            delegate: _SliverAppBarDelegate(
              TabBar(
                controller: _tabController,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.black,
                indicatorWeight: 3,
                tabs: const [
                  Tab(text: "Imagens"),
                  Tab(text: "Avaliações"),
                  Tab(text: "Meus Locais"),
                ],
              ),
            ),
            pinned: true,
          ),

          // Conteúdo das Abas
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                const Center(child: Text("Galeria vazia")), // Aba 1
                _buildAvaliacoesTab(),                      // Aba 2
                _buildMeusLocaisTab(),                      // Aba 3
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS AUXILIARES ---

  SliverAppBar _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 280,
      backgroundColor: Colors.white,
      pinned: true,
      stretch: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Fundo Cinza (Placeholder para Capa)
            Container(color: Colors.grey[200]),
            
            // Degradê para o texto ficar legível
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                  begin: Alignment.topCenter,
                  end: Alignment.center,
                ),
              ),
            ),
            
            // Conteúdo Central (Foto e Nome)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),
                  
                  // Foto com Botão de Edição
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 58, // Borda externa branca
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 54,
                          backgroundColor: Colors.grey.shade300,
                          backgroundImage: (fotoUrlAtual != null && fotoUrlAtual!.isNotEmpty)
                              ? NetworkImage(fotoUrlAtual!)
                              : null,
                          child: _enviandoFoto 
                            ? const CircularProgressIndicator(color: Colors.black)
                            : (fotoUrlAtual == null || fotoUrlAtual!.isEmpty
                                ? const Icon(Icons.person, size: 60, color: Colors.white)
                                : null),
                        ),
                      ),
                      
                      // Botãozinho da Câmera
                      GestureDetector(
                        onTap: _enviandoFoto ? null : _alterarFotoPerfil,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Text(
                    nomeUsuario,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [Shadow(offset: Offset(0, 1), blurRadius: 3.0, color: Colors.black45)],
                    ),
                  ),
                  
                  Text(
                    emailUsuario,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMeusLocaisTab() {
    if (carregandoLocais) {
      return const Center(child: CircularProgressIndicator(color: Colors.black));
    }

    if (meusLocais.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off_outlined, size: 60, color: Colors.grey),
            SizedBox(height: 16),
            Text("Você ainda não cadastrou nenhum local.", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 20, bottom: 80, left: 20, right: 20), // Espaço pro FAB
      itemCount: meusLocais.length,
      itemBuilder: (context, index) {
        final local = meusLocais[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cabeçalho do Card (Icone e Endereço)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.location_on_rounded, color: Colors.black87),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "CEP: ${local['nu_cep']}",
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Número: ${local['nu_casa']}",
                            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                          ),
                          if (local['dc_complemento'] != null && local['dc_complemento'].toString().isNotEmpty)
                             Text(
                               "${local['dc_complemento']}",
                               style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                             ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const Divider(height: 32),

                // Botões de Ação
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Botão 1: Novo Jantar (Vinculado a este local)
                    TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TelaCriarJantar(idUsuario: idUsuario!),
                            // Aqui futuramente você passará também idLocal: local['id_local']
                          ),
                        );
                      },
                      icon: const Icon(Icons.restaurant_menu, size: 18),
                      label: const Text("Novo Jantar"),
                      style: TextButton.styleFrom(foregroundColor: Colors.orange.shade800),
                    ),

                    // Botão 2: Ver Jantares deste local
                    // Implementação futura ou usar TelaMeusJantares
                    
                    // Botão 3: Excluir
                    IconButton(
                      onPressed: () => _confirmarDeleteLocal(local['id_local']),
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      tooltip: "Excluir Local",
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

  Widget _buildAvaliacoesTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildRatingCard('Comida', 5),
        _buildRatingCard('Hospitalidade', 5),
        _buildRatingCard('Pontualidade', 4),
      ],
    );
  }

  Widget _buildRatingCard(String category, int rating) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(category, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Row(
            children: List.generate(
              5,
              (index) => Icon(
                index < rating ? Icons.star_rounded : Icons.star_border_rounded,
                color: Colors.amber,
                size: 24,
              ),
            ),
          )
        ],
      ),
    );
  }
}

// Delegate para o SliverPersistentHeader (Mantém as abas fixas)
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);
  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}