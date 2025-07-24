import 'package:flutter/material.dart';
import 'package:projeto_ddm/projeto/banco/sqlite/dao/dao_cliente.dart';
import 'package:projeto_ddm/projeto/banco/sqlite/dao/dao_observacao.dart';
import 'package:projeto_ddm/projeto/dto/cliente.dart';
import 'package:projeto_ddm/projeto/dto/observacao.dart';
import 'package:projeto_ddm/projeto/telas/tela_lista_observacao.dart';

class TelaCadastrarObservacao extends StatefulWidget {
  final Observacao? observacao;
  final Cliente? initialCliente;

  const TelaCadastrarObservacao({
    super.key,
    this.observacao,
    this.initialCliente,
  });

  @override
  State<TelaCadastrarObservacao> createState() =>
      _TelaCadastrarObservacaoState();
}

class _TelaCadastrarObservacaoState extends State<TelaCadastrarObservacao> {
  final _formKey = GlobalKey<FormState>();
  final _mensagemController = TextEditingController();
  Cliente? _clienteSelecionado;
  List<Cliente> _clientes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    _clienteSelecionado = widget.initialCliente;
    if (widget.observacao != null) {
      _mensagemController.text = widget.observacao!.mensagem;
    } else {
      _mensagemController.text = '';
    }

    await _carregarClientes();
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
          SnackBar(
              content: Text('Erro ao carregar clientes: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  void dispose() {
    _mensagemController.dispose();
    super.dispose();
  }

  Future<void> _salvarOuAtualizarObservacao() async {
    if (_formKey.currentState!.validate() && _clienteSelecionado != null) {
      try {
        final observacao = Observacao(
          id: widget.observacao?.id,
          clienteId: _clienteSelecionado!.id!,
          mensagem: _mensagemController.text,
        );

        final dao = DAOObservacao();

        if (widget.observacao == null) {
          await dao.salvar(observacao);
        } else {
          await dao.atualizar(observacao);
        }

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.observacao == null
                ? 'Observação cadastrada com sucesso!'
                : 'Observação atualizada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => TelaListaObservacao()),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Erro ao ${widget.observacao == null ? 'cadastrar' : 'atualizar'} observação: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _clientes.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.observacao == null
              ? 'Cadastrar Observação'
              : 'Editar Observação'),
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
          title: Text(widget.observacao == null
              ? 'Cadastrar Observação'
              : 'Editar Observação'),
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
                  controller: _mensagemController,
                  decoration: const InputDecoration(labelText: 'Mensagem'),
                  maxLines: 3,
                  validator: (value) {
                    if (value!.trim().isEmpty) return 'Informe a mensagem';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _salvarOuAtualizarObservacao,
                  child: Text(
                      widget.observacao == null ? 'Cadastrar' : 'Atualizar'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => TelaListaObservacao()),
                  ),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[600]),
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
