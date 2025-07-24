import 'package:flutter/material.dart';
import 'package:projeto_ddm/projeto/banco/sqlite/dao/dao_veiculo.dart';
import 'package:projeto_ddm/projeto/dto/veiculo.dart';
import 'package:projeto_ddm/projeto/telas/tela_cadastrar_veiculo.dart';

class TelaListaVeiculos extends StatefulWidget {
  const TelaListaVeiculos({super.key});

  @override
  State<TelaListaVeiculos> createState() => _TelaListaVeiculosState();
}

class _TelaListaVeiculosState extends State<TelaListaVeiculos> {
  Future<List<Veiculo>> _carregarVeiculos() async {
    final dao = DAOVeiculo();
    try {
      return await dao.consultarTodos();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar veículos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return [];
    }
  }

  Future<void> _excluirVeiculo(int id, String placa) async {
    bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Deseja excluir o veículo com placa $placa?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      try {
        final dao = DAOVeiculo();
        await dao.excluir(id);
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veículo excluído com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao excluir veículo: $e'),
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
          title: const Text('Lista de Veículos'),
        ),
        body: FutureBuilder<List<Veiculo>>(
          future: _carregarVeiculos(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text('Erro ao carregar veículos'));
            }
            final veiculos = snapshot.data ?? [];
            if (veiculos.isEmpty) {
              return const Center(child: Text('Nenhum veículo cadastrado'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: veiculos.length,
              itemBuilder: (context, index) {
                final veiculo = veiculos[index];
                return Card(
                  color: Colors.grey[850],
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: FutureBuilder<String>(
                      future: DAOVeiculo().getMarcaNome(veiculo.marcaId),
                      builder: (context, snapshot) {
                        return Text(
                          '${snapshot.data ?? 'Carregando...'} ${veiculo.modelo}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                    subtitle: Text(
                      'Placa: ${veiculo.placa} | Status: ${veiculo.status}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'R\$ ${veiculo.tipo == 'Venda' ? veiculo.valorVenda.toStringAsFixed(2) : veiculo.valorAluguelDia.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Colors.orange[600],
                          ),
                        ),
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'editar') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      TelaCadastrarVeiculo(veiculo: veiculo),
                                ),
                              );
                            } else if (value == 'excluir') {
                              _excluirVeiculo(veiculo.id!, veiculo.placa);
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
                builder: (context) => const TelaCadastrarVeiculo(),
              ),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}