import 'package:flutter/material.dart';
import 'package:projeto_ddm/projeto/banco/sqlite/dao/dao_revisao.dart';
import 'package:projeto_ddm/projeto/dto/revisao.dart';
import 'package:projeto_ddm/projeto/telas/tela_cadastrar_revisao.dart';

class TelaListaRevisao extends StatefulWidget {
  const TelaListaRevisao({super.key});

  @override
  State<TelaListaRevisao> createState() => _TelaListaRevisaoState();
}

class _TelaListaRevisaoState extends State<TelaListaRevisao> {
  late List<Revisao> _revisoes;

  @override
  void initState() {
    super.initState();
    _revisoes = [];
    _carregarRevisoes().then((revisoes) {
      if (mounted) {
        setState(() {
          _revisoes = revisoes;
        });
      }
    });
  }

  Future<List<Revisao>> _carregarRevisoes() async {
    final dao = DAORevisao();
    try {
      return await dao.consultarTodos();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar revisões: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return [];
    }
  }

  Future<void> _excluirRevisao(int revisaoId) async {
    try {
      final dao = DAORevisao();
      await dao.excluir(revisaoId);

      setState(() {
        _revisoes.removeWhere((r) => r.id == revisaoId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Revisão excluída com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao excluir revisão: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _editarRevisao(Revisao revisao) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TelaCadastrarRevisao(revisao: revisao),
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
          title: const Text('Lista de Revisões'),
        ),
        body: ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: _revisoes.length,
          itemBuilder: (context, index) {
            final revisao = _revisoes[index];
            return Card(
              color: Colors.grey[850],
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: Text(
                  'Tipo: ${revisao.tipo}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  'Oficina: ${revisao.oficina}',
                  style: const TextStyle(color: Colors.white70),
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'editar') {
                      _editarRevisao(revisao);
                    } else if (value == 'excluir') {
                      _excluirRevisao(revisao.id!);
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
                builder: (context) => const TelaCadastrarRevisao(),
              ),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}