import 'package:flutter/material.dart';
import 'package:projeto_ddm/projeto/banco/sqlite/dao/dao_revisao.dart';
import 'package:projeto_ddm/projeto/dto/revisao.dart';
import 'package:projeto_ddm/projeto/telas/tela_lista_revisao.dart';

class TelaCadastrarRevisao extends StatefulWidget {
  final Revisao? revisao;

  const TelaCadastrarRevisao({
    super.key,
    this.revisao,
  });

  @override
  State<TelaCadastrarRevisao> createState() => _TelaCadastrarRevisaoState();
}

class _TelaCadastrarRevisaoState extends State<TelaCadastrarRevisao> {
  final _formKey = GlobalKey<FormState>();
  final _tipoController = TextEditingController();
  final _oficinaController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    if (widget.revisao != null) {
      _tipoController.text = widget.revisao!.tipo;
      _oficinaController.text = widget.revisao!.oficina;
    } else {
      _tipoController.text = '';
      _oficinaController.text = '';
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _tipoController.dispose();
    _oficinaController.dispose();
    super.dispose();
  }

  Future<void> _salvarOuAtualizarRevisao() async {
    if (_formKey.currentState!.validate()) {
      try {
        final revisao = Revisao(
          id: widget.revisao?.id,
          tipo: _tipoController.text,
          oficina: _oficinaController.text,
        );

        final dao = DAORevisao();

        if (widget.revisao == null) {
          await dao.salvar(revisao);
        } else {
          await dao.atualizar(revisao);
        }

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.revisao == null
                ? 'Revisão cadastrada com sucesso!'
                : 'Revisão atualizada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => TelaListaRevisao()),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao ${widget.revisao == null ? 'cadastrar' : 'atualizar'} revisão: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.revisao == null ? 'Cadastrar Revisão' : 'Editar Revisão'),
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
          title: Text(widget.revisao == null ? 'Cadastrar Revisão' : 'Editar Revisão'),
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
                  controller: _tipoController,
                  decoration: const InputDecoration(labelText: 'Tipo de Revisão'),
                  validator: (value) {
                    if (value!.trim().isEmpty) return 'Informe o tipo de revisão';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _oficinaController,
                  decoration: const InputDecoration(labelText: 'Oficina'),
                  validator: (value) {
                    if (value!.trim().isEmpty) return 'Informe a oficina';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _salvarOuAtualizarRevisao,
                  child: Text(widget.revisao == null ? 'Cadastrar' : 'Atualizar'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => TelaListaRevisao()),
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