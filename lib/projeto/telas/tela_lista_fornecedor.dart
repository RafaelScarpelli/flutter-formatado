import 'package:flutter/material.dart';
import 'package:projeto_ddm/projeto/banco/sqlite/dao/dao_fornecedor.dart';
import 'package:projeto_ddm/projeto/dto/fornecedor.dart';
import 'package:projeto_ddm/projeto/telas/tela_cadastrar_fornecedor.dart';

class TelaListaFornecedor extends StatefulWidget {
  const TelaListaFornecedor({super.key});

  @override
  State<TelaListaFornecedor> createState() => _TelaListaFornecedorState();
}

class _TelaListaFornecedorState extends State<TelaListaFornecedor> {
  late List<Fornecedor> _fornecedores;

  @override
  void initState() {
    super.initState();
    _fornecedores = [];
    _carregarFornecedores().then((fornecedores) {
      if (mounted) {
        setState(() {
          _fornecedores = fornecedores;
        });
      }
    });
  }

  Future<List<Fornecedor>> _carregarFornecedores() async {
    final dao = DAOFornecedor();
    try {
      return await dao.consultarTodos();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar fornecedores: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return [];
    }
  }

  Future<void> _excluirFornecedor(int fornecedorId) async {
    try {
      final dao = DAOFornecedor();
      await dao.excluir(fornecedorId);

      setState(() {
        _fornecedores.removeWhere((f) => f.id == fornecedorId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fornecedor excluído com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao excluir fornecedor: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _editarFornecedor(Fornecedor fornecedor) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TelaCadastrarFornecedor(fornecedor: fornecedor),
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
          title: const Text('Lista de Fornecedores'),
        ),
        body: ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: _fornecedores.length,
          itemBuilder: (context, index) {
            final fornecedor = _fornecedores[index];
            return Card(
              color: Colors.grey[850],
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: Text(
                  fornecedor.nome,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  'CPF: ${fornecedor.cpf}\nTelefone: ${fornecedor.telefone}',
                  style: const TextStyle(color: Colors.white70),
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'editar') {
                      _editarFornecedor(fornecedor);
                    } else if (value == 'excluir') {
                      _excluirFornecedor(fornecedor.id!);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'editar',
                      child: Text('Editar'),
                    ),
                    const PopupMenuItem(
                      value: 'excluir',
                      child:
                          Text('Excluir', style: TextStyle(color: Colors.red)),
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
                builder: (context) => const TelaCadastrarFornecedor(),
              ),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}