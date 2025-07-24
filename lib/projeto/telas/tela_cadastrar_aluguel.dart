import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:projeto_ddm/projeto/banco/sqlite/dao/dao_cliente.dart';
import 'package:projeto_ddm/projeto/banco/sqlite/dao/dao_veiculo.dart';
import 'package:projeto_ddm/projeto/banco/sqlite/dao/dao_aluguel.dart';
import 'package:projeto_ddm/projeto/dto/aluguel.dart';
import 'package:projeto_ddm/projeto/dto/cliente.dart';
import 'package:projeto_ddm/projeto/dto/veiculo.dart';
import 'package:projeto_ddm/projeto/telas/tela_lista_aluguel.dart';

class TelaCadastrarAluguel extends StatefulWidget {
  final Aluguel? aluguel;
  final Cliente? initialCliente;
  final Veiculo? initialVeiculo;

  const TelaCadastrarAluguel({
    super.key,
    this.aluguel,
    this.initialCliente,
    this.initialVeiculo,
  });

  @override
  State<TelaCadastrarAluguel> createState() => _TelaCadastrarAluguelState();
}

class _TelaCadastrarAluguelState extends State<TelaCadastrarAluguel> {
  final _formKey = GlobalKey<FormState>();
  final _dataInicioController = TextEditingController();
  final _dataFimController = TextEditingController();
  final _valorDiariaController = TextEditingController();
  final _valorTotalController = TextEditingController();
  Cliente? _clienteSelecionado;
  Veiculo? _veiculoSelecionado;
  String _status = 'ativo';
  List<Cliente> _clientes = [];
  List<Veiculo> _veiculos = [];
  bool _isLoading = true;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.aluguel != null;
    _initializeData();
  }

  Future<void> _initializeData() async {
    _clienteSelecionado = widget.initialCliente;
    _veiculoSelecionado = widget.initialVeiculo;
    if (widget.aluguel != null) {
      _dataInicioController.text = DateFormat('dd/MM/yyyy').format(widget.aluguel!.dataInicio);
      _dataFimController.text = DateFormat('dd/MM/yyyy').format(widget.aluguel!.dataFim);
      _valorDiariaController.text = widget.aluguel!.valorDiaria.toString();
      _valorTotalController.text = widget.aluguel!.valorTotal.toString();
      _status = widget.aluguel!.status;
      _veiculoSelecionado = widget.initialVeiculo;
    } else {
      _dataInicioController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
      _dataFimController.text = '';
      _valorDiariaController.text = '';
      _valorTotalController.text = '';
      _status = 'ativo';
    }

    await _carregarClientes();
    await _carregarVeiculos();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _carregarClientes() async {
    final dao = DAOCliente();
    try {
      final clientes = await dao.consultarTodos();
      setState(() {
        _clientes = clientes;
        if (_clienteSelecionado != null) {
          _clienteSelecionado = _clientes.firstWhere(
            (c) => c.id == _clienteSelecionado!.id,
            orElse: () => _clienteSelecionado!,
          );
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar clientes: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _carregarVeiculos() async {
    final dao = DAOVeiculo();
    try {
      final allVeiculos = await dao.consultarTodos();
      setState(() {
        if (_isEditing && _veiculoSelecionado != null) {
          _veiculos = [...allVeiculos.where((v) => v.status == 'disponível').toList(), _veiculoSelecionado!].toSet().toList();
        } else {
          _veiculos = allVeiculos.where((v) => v.status == 'disponível').toList();
        }
        print('Veículos carregados: ${_veiculos.map((v) => '${v.marcaId} ${v.modelo} (${v.placa}) - Status: ${v.status}').join(', ')}');
        print('Veículo selecionado: ${_veiculoSelecionado?.marcaId ?? 'Nenhum'}');
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar veículos: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  void dispose() {
    _dataInicioController.dispose();
    _dataFimController.dispose();
    _valorDiariaController.dispose();
    _valorTotalController.dispose();
    super.dispose();
  }

  Future<void> _salvarOuAtualizarAluguel() async {
    if (_formKey.currentState!.validate() && _clienteSelecionado != null && _veiculoSelecionado != null) {
      try {
        final aluguel = Aluguel(
          id: widget.aluguel?.id,
          clienteId: _clienteSelecionado!.id!,
          veiculoId: _veiculoSelecionado!.id!,
          dataInicio: DateFormat('dd/MM/yyyy').parse(_dataInicioController.text),
          dataFim: DateFormat('dd/MM/yyyy').parse(_dataFimController.text),
          valorDiaria: double.parse(_valorDiariaController.text),
          valorTotal: double.parse(_valorTotalController.text),
          status: _status,
        );

        final dao = DAOAluguel();
        final daoVeiculo = DAOVeiculo();

        if (widget.aluguel == null) {
          await dao.salvar(aluguel);
          await daoVeiculo.atualizarStatus(_veiculoSelecionado!.id!, 'alugado');
        } else {
          await dao.atualizar(aluguel);
          if (_status == 'finalizado' && widget.aluguel!.status != 'finalizado') {
            await daoVeiculo.atualizarStatus(_veiculoSelecionado!.id!, 'disponível');
          }
        }

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.aluguel == null
                ? 'Aluguel cadastrado com sucesso!'
                : 'Aluguel atualizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => TelaListaAluguel()),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao ${widget.aluguel == null ? 'cadastrar' : 'atualizar'} aluguel: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _selecionarDataInicio(BuildContext context) async {
    print('Tentando abrir seletor de data de início com context: $context');
    try {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2030),
      );
      print('Data de início selecionada: $picked');
      if (picked != null && mounted) {
        setState(() {
          _dataInicioController.text = DateFormat('dd/MM/yyyy').format(picked);
        });
      }
    } catch (e) {
      print('Erro ao selecionar data de início: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao selecionar data de início: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _selecionarDataFim(BuildContext context) async {
    print('Tentando abrir seletor de data de fim com context: $context');
    try {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2030),
      );
      print('Data de fim selecionada: $picked');
      if (picked != null && mounted) {
        setState(() {
          _dataFimController.text = DateFormat('dd/MM/yyyy').format(picked);
        });
      }
    } catch (e) {
      print('Erro ao selecionar data de fim: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao selecionar data de fim: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _clientes.isEmpty || (_veiculos.isEmpty && !_isEditing)) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.aluguel == null ? 'Cadastrar Aluguel' : 'Editar Aluguel'),
          backgroundColor: Colors.green[600],
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
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
          title: Text(widget.aluguel == null ? 'Cadastrar Aluguel' : 'Editar Aluguel'),
          backgroundColor: Colors.green[600],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<Cliente>(
                  value: _clienteSelecionado,
                  decoration: const InputDecoration(labelText: 'Cliente'),
                  items: _clientes
                      .map((cliente) => DropdownMenuItem(
                            value: cliente,
                            child: Text(cliente.nome),
                          ))
                      .toList(),
                  onChanged: (value) => setState(() => _clienteSelecionado = value),
                  validator: (value) => value == null ? 'Selecione um cliente' : null,
                ),
                const SizedBox(height: 16),
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
                  validator: (value) {
                    if (_isEditing && widget.aluguel != null && value == null) {
                      return null;
                    }
                    return value == null ? 'Selecione um veículo' : null;
                  },
                  onTap: () {
                    print('Dropdown de veículo clicado. Itens disponíveis: ${_veiculos.length}');
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _dataInicioController,
                  decoration: const InputDecoration(labelText: 'Data de Início (dd/mm/aaaa)'),
                  readOnly: true,
                  onTap: () => _selecionarDataInicio(context),
                  validator: (value) {
                    if (value!.trim().isEmpty) return 'Informe a data de início';
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
                  controller: _dataFimController,
                  decoration: const InputDecoration(labelText: 'Data de Fim (dd/mm/aaaa)'),
                  readOnly: true,
                  onTap: () => _selecionarDataFim(context),
                  validator: (value) {
                    if (value!.trim().isEmpty) return 'Informe a data de fim';
                    try {
                      DateFormat('dd/MM/yyyy').parse(value);
                      if (DateFormat('dd/MM/yyyy').parse(value).isBefore(DateFormat('dd/MM/yyyy').parse(_dataInicioController.text))) {
                        return 'Data de fim não pode ser anterior à data de início';
                      }
                      return null;
                    } catch (e) {
                      return 'Data inválida';
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _valorDiariaController,
                  decoration: const InputDecoration(labelText: 'Valor Diário (R\$)'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.trim().isEmpty) return 'Informe o valor diário';
                    final valor = double.tryParse(value);
                    if (valor == null || valor < 0) return 'Valor inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _valorTotalController,
                  decoration: const InputDecoration(labelText: 'Valor Total (R\$)'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.trim().isEmpty) return 'Informe o valor total';
                    final valor = double.tryParse(value);
                    if (valor == null || valor < 0) return 'Valor inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _status,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: const [
                    DropdownMenuItem(value: 'ativo', child: Text('Ativo')),
                    DropdownMenuItem(value: 'finalizado', child: Text('Finalizado')),
                  ],
                  onChanged: (value) => setState(() => _status = value!),
                  validator: (value) => value == null ? 'Selecione um status' : null,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _salvarOuAtualizarAluguel,
                  child: Text(widget.aluguel == null ? 'Cadastrar' : 'Atualizar'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => TelaListaAluguel()),
                  ),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[600]),
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