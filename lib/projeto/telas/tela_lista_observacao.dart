import 'package:flutter/material.dart';
import 'package:projeto_ddm/projeto/banco/sqlite/dao/dao_cliente.dart';
import 'package:projeto_ddm/projeto/banco/sqlite/dao/dao_observacao.dart';
import 'package:projeto_ddm/projeto/dto/observacao.dart';
import 'package:projeto_ddm/projeto/dto/cliente.dart';
import 'package:projeto_ddm/projeto/telas/tela_cadastrar_observacao.dart';

class TelaListaObservacao extends StatefulWidget {
  const TelaListaObservacao({super.key});

  @override
  State<TelaListaObservacao> createState() => _TelaListaObservacaoState();
}

class _TelaListaObservacaoState extends State<TelaListaObservacao> {
  late List<Observacao> _observacoes;

  @override
  void initState() {
    super.initState();
    _observacoes = [];
    _carregarObservacoes().then((observacoes) {
      if (mounted) {
        setState(() {
          _observacoes = observacoes;
        });
      }
    });
  }

  Future<List<Observacao>> _carregarObservacoes() async {
    final dao = DAOObservacao();
    try {
      return await dao.consultarTodos();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar observações: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return [];
    }
  }

  Future<String> _getClienteNome(int clienteId) async {
    final dao = DAOCliente();
    final cliente = await dao.consultarPorId(clienteId);
    return cliente?.nome ?? 'Desconhecido';
  }

  Future<void> _excluirObservacao(int observacaoId) async {
    try {
      final dao = DAOObservacao();
      await dao.excluir(observacaoId);

      setState(() {
        _observacoes.removeWhere((o) => o.id == observacaoId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Observação excluída com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao excluir observação: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _editarObservacao(Observacao observacao) async {
    try {
      final daoCliente = DAOCliente();
      final cliente = await daoCliente.consultarPorId(observacao.clienteId);
      if (cliente == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cliente não encontrado.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TelaCadastrarObservacao(
              observacao: observacao,
              initialCliente: cliente,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar dados para edição: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
          title: const Text('Lista de Observações'),
        ),
        body: ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: _observacoes.length,
          itemBuilder: (context, index) {
            final observacao = _observacoes[index];
            return Card(
              color: Colors.grey[850],
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: FutureBuilder<String>(
                  future: _getClienteNome(observacao.clienteId),
                  builder: (context, snapshot) {
                    return Text(
                      'Cliente: ${snapshot.data ?? 'Carregando...'}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
                subtitle: Text(
                  'Mensagem: ${observacao.mensagem}',
                  style: const TextStyle(color: Colors.white70),
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'editar') {
                      _editarObservacao(observacao);
                    } else if (value == 'excluir') {
                      _excluirObservacao(observacao.id!);
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
                builder: (context) => const TelaCadastrarObservacao(),
              ),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
