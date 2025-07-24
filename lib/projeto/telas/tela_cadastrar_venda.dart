import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:projeto_ddm/projeto/banco/sqlite/dao/dao_cliente.dart';
import 'package:projeto_ddm/projeto/banco/sqlite/dao/dao_veiculo.dart';
import 'package:projeto_ddm/projeto/banco/sqlite/dao/dao_venda.dart';
import 'package:projeto_ddm/projeto/dto/cliente.dart';
import 'package:projeto_ddm/projeto/dto/venda.dart';
import 'package:projeto_ddm/projeto/dto/veiculo.dart';
import 'package:projeto_ddm/projeto/telas/tela_lista_venda.dart';

class TelaCadastrarVenda extends StatefulWidget {
  final Venda? venda;
  final Cliente? initialCliente;
  final List<Veiculo>? initialVeiculos;

  const TelaCadastrarVenda({
    super.key,
    this.venda,
    this.initialCliente,
    this.initialVeiculos,
  });

  @override
  State<TelaCadastrarVenda> createState() => _TelaCadastrarVendaState();
}

class _TelaCadastrarVendaState extends State<TelaCadastrarVenda> {
  final _formKey = GlobalKey<FormState>();
  final _valorController = TextEditingController();
  final _dataVendaController = TextEditingController();
  Cliente? _clienteSelecionado;
  List<Veiculo> _veiculosSelecionados = [];
  List<Cliente> _clientes = [];
  List<Veiculo> _veiculos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    _clienteSelecionado = widget.initialCliente;
    if (widget.initialVeiculos != null) {
      _veiculosSelecionados = List.from(widget.initialVeiculos!);
    }
    if (widget.venda != null) {
      _valorController.text = widget.venda!.valor.toString();
      _dataVendaController.text =
          DateFormat('dd/MM/yyyy').format(widget.venda!.dataVenda);
    } else {
      _valorController.text = '';
      _dataVendaController.text =
          DateFormat('dd/MM/yyyy').format(DateTime.now());
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
          final matchingClient = _clientes.firstWhere(
            (c) => c.id == _clienteSelecionado!.id,
            orElse: () => _clienteSelecionado!,
          );
          _clienteSelecionado = matchingClient;
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erro ao carregar clientes: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _carregarVeiculos() async {
    final dao = DAOVeiculo();
    try {
      final allVeiculos = await dao.consultarTodos();
      setState(() {
        _veiculos = allVeiculos.where((v) => v.status == 'disponível').toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erro ao carregar veículos: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  void dispose() {
    _valorController.dispose();
    _dataVendaController.dispose();
    super.dispose();
  }

  Future<void> _salvarOuAtualizarVenda() async {
    if (_formKey.currentState!.validate()) {
      try {
        final venda = Venda(
          id: widget.venda?.id,
          clienteId: _clienteSelecionado!.id!,
          veiculoIds: _veiculosSelecionados.map((v) => v.id!).toList(),
          dataVenda: DateFormat('dd/MM/yyyy').parse(_dataVendaController.text),
          valor: double.parse(_valorController.text),
        );

        final dao = DAOVenda();
        final daoVeiculo = DAOVeiculo();

        if (widget.venda == null) {
          await dao.salvar(venda);
        } else {
          await dao.atualizar(venda);
        }

        for (var veiculoId in _veiculosSelecionados.map((v) => v.id!)) {
          await daoVeiculo.atualizarStatus(veiculoId, 'vendido');
        }

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.venda == null
                ? 'Venda cadastrada com sucesso!'
                : 'Venda atualizada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => TelaListaVenda()),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Erro ao ${widget.venda == null ? 'cadastrar' : 'atualizar'} venda: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _selecionarData(BuildContext context) async {
    print('Tentando abrir o seletor de data com context: $context');
    try {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2025, 12, 31),
      );
      print('Data selecionada: $picked');
      if (picked != null && mounted) {
        setState(() {
          _dataVendaController.text = DateFormat('dd/MM/yyyy').format(picked);
        });
      }
    } catch (e) {
      print('Erro ao selecionar data: $e');
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
    if (_isLoading || _clientes.isEmpty || _veiculos.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title:
              Text(widget.venda == null ? 'Cadastrar Venda' : 'Editar Venda'),
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
          title:
              Text(widget.venda == null ? 'Cadastrar Venda' : 'Editar Venda'),
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
                  onChanged: (value) =>
                      setState(() => _clienteSelecionado = value),
                  validator: (value) =>
                      value == null ? 'Selecione um cliente' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _dataVendaController,
                  decoration: const InputDecoration(
                      labelText: 'Data da Venda (dd/mm/aaaa)'),
                  readOnly: true,
                  onTap: () => _selecionarData(context),
                  validator: (value) {
                    if (value!.trim().isEmpty) return 'Informe a data da venda';
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
                  controller: _valorController,
                  decoration: const InputDecoration(labelText: 'Valor (R\$)'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.trim().isEmpty) return 'Informe o valor';
                    final valor = double.tryParse(value);
                    if (valor == null || valor < 0) return 'Valor inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<Veiculo>(
                  decoration:
                      const InputDecoration(labelText: 'Selecionar Veículos'),
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
                  onChanged: (veiculo) {
                    if (veiculo != null &&
                        !_veiculosSelecionados.contains(veiculo)) {
                      setState(() {
                        _veiculosSelecionados.add(veiculo);
                      });
                    }
                  },
                  validator: (value) => _veiculosSelecionados.isEmpty
                      ? 'Selecione pelo menos um veículo'
                      : null,
                ),
                const SizedBox(height: 16),
                if (_veiculosSelecionados.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Veículos Selecionados:',
                          style: TextStyle(color: Colors.white70)),
                      ..._veiculosSelecionados
                          .asMap()
                          .entries
                          .map((entry) => ListTile(
                                title: FutureBuilder<String>(
                                  future: DAOVeiculo().getMarcaNome(entry.value.marcaId),
                                  builder: (context, snapshot) {
                                    return Text(
                                      '${snapshot.data ?? 'Carregando...'} ${entry.value.modelo} (${entry.value.placa})',
                                      style: const TextStyle(color: Colors.white),
                                    );
                                  },
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.remove_circle,
                                      color: Colors.red),
                                  onPressed: () {
                                    setState(() {
                                      _veiculosSelecionados.removeAt(entry.key);
                                    });
                                  },
                                ),
                              ))
                          .toList(),
                    ],
                  ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _salvarOuAtualizarVenda,
                  child: Text(widget.venda == null ? 'Cadastrar' : 'Atualizar'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TelaListaVenda(),
                    ),
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