import 'package:flutter/material.dart';
import 'package:projeto_ddm/projeto/banco/sqlite/dao/dao_marca_veiculo.dart';
import 'package:projeto_ddm/projeto/banco/sqlite/dao/dao_peca.dart';
import 'package:projeto_ddm/projeto/dto/peca.dart';
import 'package:projeto_ddm/projeto/telas/tela_cadastrar_peca.dart';

class TelaListaPeca extends StatefulWidget {
  const TelaListaPeca({super.key});

  @override
  State<TelaListaPeca> createState() => _TelaListaPecaState();
}

class _TelaListaPecaState extends State<TelaListaPeca> {
  late List<Peca> _pecas;

  @override
  void initState() {
    super.initState();
    _pecas = [];
    _carregarPecas().then((pecas) {
      if (mounted) {
        setState(() {
          _pecas = pecas;
        });
      }
    });
  }

  Future<List<Peca>> _carregarPecas() async {
    final dao = DAOPeca();
    try {
      return await dao.consultarTodos();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar peças: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return [];
    }
  }

  Future<String> _getMarcaNome(int marcaId) async {
    final dao = DAOMarcaVeiculo();
    final marca = await dao.consultarPorId(marcaId);
    return marca?.nome ?? 'Desconhecida';
  }

  Future<void> _excluirPeca(int pecaId) async {
    try {
      final dao = DAOPeca();
      await dao.excluir(pecaId);
      setState(() {
        _pecas.removeWhere((p) => p.id == pecaId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Peça excluída com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao excluir peça: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _editarPeca(Peca peca) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TelaCadastrarPeca(peca: peca),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        primaryColor: Colors.green[600],
        colorScheme: ColorScheme.dark(
          primary: Colors.green[600]!,
          secondary: Colors.orange[600]!,
        ),
        scaffoldBackgroundColor: Colors.grey[900],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.green[600],
          foregroundColor: Colors.white,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Lista de Peças'),
        ),
        body: ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: _pecas.length,
          itemBuilder: (context, index) {
            final peca = _pecas[index];
            return Card(
              color: Colors.grey[850],
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: Text(
                  peca.nome,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: FutureBuilder<String>(
                  future: _getMarcaNome(peca.marcaId),
                  builder: (context, snapshot) {
                    return Text(
                      'Marca: ${snapshot.data ?? 'Carregando...'}\nPreço: R\$ ${peca.precoUnitario.toStringAsFixed(2)}\nQuantidade: ${peca.quantidade}',
                      style: const TextStyle(color: Colors.white70),
                    );
                  },
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'editar') {
                      _editarPeca(peca);
                    } else if (value == 'excluir') {
                      _excluirPeca(peca.id!);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'editar',
                      child: Text('Editar'),
                    ),
                    const PopupMenuItem(
                      value: 'excluir',
                      child: Text('Excluir', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.orange[600],
          foregroundColor: Colors.white,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TelaCadastrarPeca(),
              ),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}