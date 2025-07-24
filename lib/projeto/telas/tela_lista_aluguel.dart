import 'package:flutter/material.dart';
import 'package:projeto_ddm/projeto/banco/sqlite/dao/dao_aluguel.dart';
import 'package:projeto_ddm/projeto/banco/sqlite/dao/dao_cliente.dart';
import 'package:projeto_ddm/projeto/banco/sqlite/dao/dao_veiculo.dart';
import 'package:projeto_ddm/projeto/dto/aluguel.dart';
import 'package:projeto_ddm/projeto/dto/cliente.dart';
import 'package:projeto_ddm/projeto/dto/veiculo.dart';
import 'package:projeto_ddm/projeto/telas/tela_cadastrar_aluguel.dart';
import 'package:intl/intl.dart';

class TelaListaAluguel extends StatefulWidget {
  const TelaListaAluguel({super.key});

  @override
  State<TelaListaAluguel> createState() => _TelaListaAluguelState();
}

class _TelaListaAluguelState extends State<TelaListaAluguel> {
  late List<Aluguel> _alugueis;

  @override
  void initState() {
    super.initState();
    _alugueis = [];
    _carregarAlugueis().then((alugueis) {
      if (mounted) {
        setState(() {
          _alugueis = alugueis;
        });
      }
    });
  }

  Future<List<Aluguel>> _carregarAlugueis() async {
    final dao = DAOAluguel();
    try {
      return await dao.consultarTodos();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar aluguéis: $e'),
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

  Future<String> _getVeiculoNome(int veiculoId) async {
    final dao = DAOVeiculo();
    final veiculo = await dao.consultarPorId(veiculoId);
    if (veiculo != null) {
      final marcaNome = await dao.getMarcaNome(veiculo.marcaId);
      return '$marcaNome ${veiculo.modelo} (${veiculo.placa})';
    }
    return 'Desconhecido';
  }

  Future<void> _excluirAluguel(int aluguelId) async {
    try {
      final dao = DAOAluguel();
      final daoVeiculo = DAOVeiculo();

      final aluguel = await dao.consultarPorId(aluguelId);
      if (aluguel != null) {
        if (aluguel.status == 'ativo') {
          await daoVeiculo.atualizarStatus(aluguel.veiculoId, 'disponível');
        }
        await dao.excluir(aluguelId);

        setState(() {
          _alugueis.removeWhere((a) => a.id == aluguelId);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aluguel excluído com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao excluir aluguel: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _editarAluguel(Aluguel aluguel) async {
    try {
      final daoCliente = DAOCliente();
      final cliente = await daoCliente.consultarPorId(aluguel.clienteId);
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

      final daoVeiculo = DAOVeiculo();
      final veiculo = await daoVeiculo.consultarPorId(aluguel.veiculoId);
      if (veiculo == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Veículo não encontrado.'),
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
            builder: (context) => TelaCadastrarAluguel(
              aluguel: aluguel,
              initialCliente: cliente,
              initialVeiculo: veiculo,
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
          title: const Text('Lista de Aluguéis'),
        ),
        body: ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: _alugueis.length,
          itemBuilder: (context, index) {
            final aluguel = _alugueis[index];
            return Card(
              color: Colors.grey[850],
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: FutureBuilder<String>(
                  future: _getClienteNome(aluguel.clienteId),
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
                subtitle: FutureBuilder<String>(
                  future: _getVeiculoNome(aluguel.veiculoId),
                  builder: (context, snapshot) {
                    return Text(
                      'Veículo: ${snapshot.data ?? 'Carregando...'}\nPeríodo: ${DateFormat('dd/MM/yyyy').format(aluguel.dataInicio)} - ${DateFormat('dd/MM/yyyy').format(aluguel.dataFim)}\nStatus: ${aluguel.status}',
                      style: const TextStyle(color: Colors.white70),
                    );
                  },
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'R\$ ${aluguel.valorTotal.toStringAsFixed(2)}',
                      style: TextStyle(color: Colors.orange[600]),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'editar') {
                          _editarAluguel(aluguel);
                        } else if (value == 'excluir') {
                          _excluirAluguel(aluguel.id!);
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
                builder: (context) => const TelaCadastrarAluguel(),
              ),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}