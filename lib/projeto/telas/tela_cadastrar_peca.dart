import 'package:flutter/material.dart';
import 'package:projeto_ddm/projeto/banco/sqlite/dao/dao_marca_veiculo.dart';
import 'package:projeto_ddm/projeto/banco/sqlite/dao/dao_peca.dart';
import 'package:projeto_ddm/projeto/dto/marca.dart';
import 'package:projeto_ddm/projeto/dto/peca.dart';
import 'package:projeto_ddm/projeto/telas/tela_lista_peca.dart';

class TelaCadastrarPeca extends StatefulWidget {
  final Peca? peca;
  const TelaCadastrarPeca({super.key, this.peca});

  @override
  State<TelaCadastrarPeca> createState() => _TelaCadastrarPecaState();
}

class _TelaCadastrarPecaState extends State<TelaCadastrarPeca> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _precoUnitarioController = TextEditingController();
  final _quantidadeController = TextEditingController();
  MarcaVeiculo? _marcaSelecionada;
  List<MarcaVeiculo> _marcas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.peca != null) {
      _nomeController.text = widget.peca!.nome;
      _precoUnitarioController.text = widget.peca!.precoUnitario.toString();
      _quantidadeController.text = widget.peca!.quantidade.toString();
    }
    _carregarMarcas();
  }

  Future<void> _carregarMarcas() async {
    final dao = DAOMarcaVeiculo();
    try {
      final marcas = await dao.consultarTodos();
      setState(() {
        _marcas = marcas;
        if (widget.peca != null) {
          _marcaSelecionada = _marcas.firstWhere(
            (m) => m.id == widget.peca!.marcaId,
            orElse: () => _marcas.first,
          );
        }
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar marcas: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _precoUnitarioController.dispose();
    _quantidadeController.dispose();
    super.dispose();
  }

  Future<void> _salvarOuAtualizarPeca() async {
    if (_formKey.currentState!.validate()) {
      try {
        final peca = Peca(
          id: widget.peca?.id,
          nome: _nomeController.text.trim(),
          marcaId: _marcaSelecionada!.id!,
          precoUnitario: double.parse(_precoUnitarioController.text),
          quantidade: int.parse(_quantidadeController.text),
        );

        final dao = DAOPeca();
        if (widget.peca == null) {
          await dao.salvar(peca);
        } else {
          await dao.atualizar(peca);
        }

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.peca == null
                ? 'Peça cadastrada com sucesso!'
                : 'Peça atualizada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => TelaListaPeca()),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Erro ao ${widget.peca == null ? 'cadastrar' : 'atualizar'} peça: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _marcas.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.peca == null ? 'Cadastrar Peça' : 'Editar Peça'),
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
          title: Text(widget.peca == null ? 'Cadastrar Peça' : 'Editar Peça'),
          backgroundColor: Colors.green[600],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nomeController,
                  decoration: const InputDecoration(labelText: 'Nome da Peça'),
                  validator: (value) =>
                      value!.trim().isEmpty ? 'Informe o nome da peça' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<MarcaVeiculo>(
                  value: _marcaSelecionada,
                  decoration: const InputDecoration(labelText: 'Marca'),
                  items: _marcas
                      .map((marca) => DropdownMenuItem(
                            value: marca,
                            child: Text(marca.nome),
                          ))
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _marcaSelecionada = value),
                  validator: (value) =>
                      value == null ? 'Selecione uma marca' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _precoUnitarioController,
                  decoration: const InputDecoration(labelText: 'Preço Unitário (R\$)'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.trim().isEmpty) return 'Informe o preço unitário';
                    final preco = double.tryParse(value);
                    if (preco == null || preco <= 0) return 'Preço inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _quantidadeController,
                  decoration: const InputDecoration(labelText: 'Quantidade'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.trim().isEmpty) return 'Informe a quantidade';
                    final quantidade = int.tryParse(value);
                    if (quantidade == null || quantidade <= 0) {
                      return 'Quantidade inválida';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _salvarOuAtualizarPeca,
                  child: Text(widget.peca == null ? 'Cadastrar' : 'Atualizar'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => TelaListaPeca()),
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