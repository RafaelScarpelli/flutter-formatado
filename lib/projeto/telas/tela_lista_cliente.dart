import 'package:flutter/material.dart';
import 'package:projeto_ddm/projeto/banco/sqlite/dao/dao_cliente.dart';
import 'package:projeto_ddm/projeto/banco/sqlite/dao/dao_observacao.dart';
import 'package:projeto_ddm/projeto/dto/cliente.dart';
import 'package:projeto_ddm/projeto/telas/tela_cadastrar_cliente.dart';

class TelaListaClientes extends StatefulWidget {
  const TelaListaClientes({super.key});

  @override
  State<TelaListaClientes> createState() => _TelaListaClientesState();
}

class _TelaListaClientesState extends State<TelaListaClientes> {
  late List<Cliente> _clientes;

  @override
  void initState() {
    super.initState();
    _clientes = [];
    _carregarClientes().then((clientes) {
      if (mounted) {
        setState(() {
          _clientes = clientes;
        });
      }
    });
  }

  Future<List<Cliente>> _carregarClientes() async {
    final dao = DAOCliente();
    try {
      return await dao.consultarTodos();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar clientes: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return [];
    }
  }

  Future<void> _excluirCliente(int clienteId) async {
    try {
      final dao = DAOCliente();
      await dao.excluir(clienteId);

      setState(() {
        _clientes.removeWhere((c) => c.id == clienteId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cliente excluído com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao excluir cliente: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _editarCliente(Cliente cliente) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TelaCadastrarCliente(cliente: cliente),
      ),
    );
  }

  void _mostrarObservacoes(int clienteId) async {
    try {
      final daoObservacao = DAOObservacao();
      final observacoes = await daoObservacao.consultarPorClienteId(clienteId);

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Observações do Cliente'),
            content: SizedBox(
              width: double.maxFinite,
              child: observacoes.isEmpty
                  ? const Text('Cliente não possui observações')
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: observacoes.length,
                      itemBuilder: (context, index) {
                        final observacao = observacoes[index];
                        return ListTile(
                          title: Text(
                            observacao.mensagem,
                            style: const TextStyle(color: Colors.white70),
                          ),
                        );
                      },
                    ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fechar'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar observações: $e'),
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
          title: const Text('Lista de Clientes'),
        ),
        body: ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: _clientes.length,
          itemBuilder: (context, index) {
            final cliente = _clientes[index];
            return Card(
              color: Colors.grey[850],
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: Text(
                  cliente.nome,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  'CPF: ${cliente.cpf}\nTelefone: ${cliente.telefone}',
                  style: const TextStyle(color: Colors.white70),
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'editar') {
                      _editarCliente(cliente);
                    } else if (value == 'excluir') {
                      _excluirCliente(cliente.id!);
                    } else if (value == 'observacoes') {
                      _mostrarObservacoes(cliente.id!);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'observacoes',
                      child: Text('Observações'),
                    ),
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
                builder: (context) => const TelaCadastrarCliente(),
              ),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
