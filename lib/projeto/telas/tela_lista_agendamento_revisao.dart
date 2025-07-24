import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:projeto_ddm/projeto/banco/sqlite/dao/dao_veiculo.dart';
import 'package:projeto_ddm/projeto/banco/sqlite/dao/dao_revisao.dart';
import 'package:projeto_ddm/projeto/banco/sqlite/dao/dao_agendamento_revisao.dart';
import 'package:projeto_ddm/projeto/dto/agendamento_revisao.dart';
import 'package:projeto_ddm/projeto/telas/tela_cadastrar_agendamento_revisao.dart';

class TelaListaAgendamentoRevisao extends StatefulWidget {
  const TelaListaAgendamentoRevisao({super.key});

  @override
  State<TelaListaAgendamentoRevisao> createState() => _TelaListaAgendamentoRevisaoState();
}

class _TelaListaAgendamentoRevisaoState extends State<TelaListaAgendamentoRevisao> {
  late List<AgendamentoRevisao> _agendamentos;

  @override
  void initState() {
    super.initState();
    _agendamentos = [];
    _carregarAgendamentos().then((agendamentos) {
      if (mounted) {
        setState(() {
          _agendamentos = agendamentos;
        });
      }
    });
  }

  Future<List<AgendamentoRevisao>> _carregarAgendamentos() async {
    final dao = DAOAgendamentoRevisao();
    try {
      return await dao.consultarTodos();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar agendamentos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return [];
    }
  }

  Future<String> _getVeiculoNome(int carroId) async {
    final dao = DAOVeiculo();
    final veiculo = await dao.consultarPorId(carroId);
    if (veiculo != null) {
      final marcaNome = await dao.getMarcaNome(veiculo.marcaId);
      return '$marcaNome ${veiculo.modelo} (${veiculo.placa})';
    }
    return 'Desconhecido';
  }

  Future<String> _getRevisaoNome(int revisaoId) async {
    final dao = DAORevisao();
    final revisao = await dao.consultarPorId(revisaoId);
    return revisao != null ? '${revisao.tipo} (${revisao.oficina})' : 'Desconhecida';
  }

  Future<void> _excluirAgendamento(int agendamentoId) async {
    try {
      final dao = DAOAgendamentoRevisao();
      await dao.excluir(agendamentoId);
      setState(() {
        _agendamentos.removeWhere((a) => a.id == agendamentoId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Agendamento excluído com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao excluir agendamento: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _editarAgendamento(AgendamentoRevisao agendamento) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TelaCadastrarAgendamentoRevisao(agendamento: agendamento),
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
          title: const Text('Lista de Agendamentos de Revisão'),
        ),
        body: ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: _agendamentos.length,
          itemBuilder: (context, index) {
            final agendamento = _agendamentos[index];
            return Card(
              color: Colors.grey[850],
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: FutureBuilder<String>(
                  future: _getVeiculoNome(agendamento.carroId),
                  builder: (context, snapshot) {
                    return Text(
                      'Veículo: ${snapshot.data ?? 'Carregando...'}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
                subtitle: FutureBuilder<String>(
                  future: _getRevisaoNome(agendamento.revisaoId),
                  builder: (context, snapshot) {
                    return Text(
                      'Revisão: ${snapshot.data ?? 'Carregando...'}\nData: ${DateFormat('dd/MM/yyyy').format(agendamento.data)}\nDescrição: ${agendamento.descricao}',
                      style: const TextStyle(color: Colors.white70),
                    );
                  },
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'editar') {
                      _editarAgendamento(agendamento);
                    } else if (value == 'excluir') {
                      _excluirAgendamento(agendamento.id!);
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
                builder: (context) => const TelaCadastrarAgendamentoRevisao(),
              ),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}