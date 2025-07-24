import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:projeto_ddm/projeto/banco/sqlite/dao/dao_veiculo.dart';
import 'package:projeto_ddm/projeto/banco/sqlite/dao/dao_revisao.dart';
import 'package:projeto_ddm/projeto/banco/sqlite/dao/dao_agendamento_revisao.dart';
import 'package:projeto_ddm/projeto/dto/veiculo.dart';
import 'package:projeto_ddm/projeto/dto/revisao.dart';
import 'package:projeto_ddm/projeto/dto/agendamento_revisao.dart';
import 'package:projeto_ddm/projeto/telas/tela_lista_agendamento_revisao.dart';

class TelaCadastrarAgendamentoRevisao extends StatefulWidget {
  final AgendamentoRevisao? agendamento;
  const TelaCadastrarAgendamentoRevisao({super.key, this.agendamento});

  @override
  State<TelaCadastrarAgendamentoRevisao> createState() => _TelaCadastrarAgendamentoRevisaoState();
}

class _TelaCadastrarAgendamentoRevisaoState extends State<TelaCadastrarAgendamentoRevisao> {
  final _formKey = GlobalKey<FormState>();
  final _dataController = TextEditingController();
  final _descricaoController = TextEditingController();
  Veiculo? _veiculoSelecionado;
  Revisao? _revisaoSelecionada;
  List<Veiculo> _veiculos = [];
  List<Revisao> _revisoes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.agendamento != null) {
      _dataController.text = DateFormat('dd/MM/yyyy').format(widget.agendamento!.data);
      _descricaoController.text = widget.agendamento!.descricao;
    } else {
      _dataController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
    }
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    try {
      final daoVeiculo = DAOVeiculo();
      final daoRevisao = DAORevisao();
      final veiculos = await daoVeiculo.consultarTodos();
      final revisoes = await daoRevisao.consultarTodos();
      setState(() {
        _veiculos = veiculos;
        _revisoes = revisoes;
        if (widget.agendamento != null) {
          _veiculoSelecionado = _veiculos.firstWhere(
            (v) => v.id == widget.agendamento!.carroId,
            orElse: () => _veiculos.first,
          );
          _revisaoSelecionada = _revisoes.firstWhere(
            (r) => r.id == widget.agendamento!.revisaoId,
            orElse: () => _revisoes.first,
          );
        }
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar dados: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _dataController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _salvarOuAtualizarAgendamento() async {
    if (_formKey.currentState!.validate()) {
      try {
        final agendamento = AgendamentoRevisao(
          id: widget.agendamento?.id,
          carroId: _veiculoSelecionado!.id!,
          revisaoId: _revisaoSelecionada!.id!,
          data: DateFormat('dd/MM/yyyy').parse(_dataController.text),
          descricao: _descricaoController.text.trim(),
        );

        final dao = DAOAgendamentoRevisao();
        if (widget.agendamento == null) {
          await dao.salvar(agendamento);
        } else {
          await dao.atualizar(agendamento);
        }

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.agendamento == null
                ? 'Agendamento cadastrado com sucesso!'
                : 'Agendamento atualizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => TelaListaAgendamentoRevisao()),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Erro ao ${widget.agendamento == null ? 'cadastrar' : 'atualizar'} agendamento: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _selecionarData(BuildContext context) async {
    try {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2025, 12, 31),
      );
      if (picked != null && mounted) {
        setState(() {
          _dataController.text = DateFormat('dd/MM/yyyy').format(picked);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao selecionar data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _veiculos.isEmpty || _revisoes.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.agendamento == null ? 'Cadastrar Agendamento' : 'Editar Agendamento'),
          backgroundColor: Colors.green[600],
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Theme(
      data: ThemeData.dark().copyWith(
        primaryColor: Colors.green[600],
        colorScheme: ColorScheme.dark(
          primary: Colors.green[600]!,
          secondary: Colors.orange[600]!,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey[900],
          labelStyle: const TextStyle(color: Colors.white70),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange[600],
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.agendamento == null ? 'Cadastrar Agendamento' : 'Editar Agendamento'),
          backgroundColor: Colors.green[600],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<Veiculo>(
                  value: _veiculoSelecionado,
                  decoration: const InputDecoration(labelText: 'Veículo'),
                  items: _veiculos
                      .map((veiculo) => DropdownMenuItem(
                            value: veiculo,
                            child: FutureBuilder<String>(
                              future: DAOVeiculo().getMarcaNome(veiculo.marcaId),
                              builder: (context, snapshot) {
                                return Text(
                                  '${snapshot.data ?? 'Carregando...'} ${veiculo.modelo} (${veiculo.placa})',
                                );
                              },
                            ),
                          ))
                      .toList(),
                  onChanged: (value) => setState(() => _veiculoSelecionado = value),
                  validator: (value) => value == null ? 'Selecione um veículo' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<Revisao>(
                  value: _revisaoSelecionada,
                  decoration: const InputDecoration(labelText: 'Revisão'),
                  items: _revisoes
                      .map((revisao) => DropdownMenuItem(
                            value: revisao,
                            child: Text('${revisao.tipo} (${revisao.oficina})'),
                          ))
                      .toList(),
                  onChanged: (value) => setState(() => _revisaoSelecionada = value),
                  validator: (value) => value == null ? 'Selecione uma revisão' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _dataController,
                  decoration: const InputDecoration(labelText: 'Data (dd/mm/aaaa)'),
                  readOnly: true,
                  onTap: () => _selecionarData(context),
                  validator: (value) {
                    if (value!.trim().isEmpty) return 'Informe a data';
                    try {
                      DateFormat('dd/MM/yyyy').parse(value);
                      return null;
                    } catch (e) {
                      return 'Data inválida';
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descricaoController,
                  decoration: const InputDecoration(labelText: 'Descrição'),
                  validator: (value) =>
                      value!.trim().isEmpty ? 'Informe a descrição' : null,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _salvarOuAtualizarAgendamento,
                  child: Text(widget.agendamento == null ? 'Cadastrar' : 'Atualizar'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => TelaListaAgendamentoRevisao()),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[600],
                  ),
                  child: const Text('Cancelar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}