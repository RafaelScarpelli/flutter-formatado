import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:projeto_ddm/projeto/banco/sqlite/dao/dao_fornecedor.dart';
import 'package:projeto_ddm/projeto/dto/fornecedor.dart';
import 'package:projeto_ddm/projeto/telas/tela_lista_fornecedor.dart';

class TelaCadastrarFornecedor extends StatefulWidget {
  final Fornecedor? fornecedor;
  const TelaCadastrarFornecedor({super.key, this.fornecedor});

  @override
  State<TelaCadastrarFornecedor> createState() => _TelaCadastrarFornecedorState();
}

class _TelaCadastrarFornecedorState extends State<TelaCadastrarFornecedor> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _cpfController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _emailController = TextEditingController();

  final _cpfFormatter = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {'#': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.eager,
  );

  final _telefoneFormatter = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {'#': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.eager,
  );

  @override
  void initState() {
    super.initState();
    if (widget.fornecedor != null) {
      _nomeController.text = widget.fornecedor!.nome;
      _cpfController.text = widget.fornecedor!.cpf;
      _telefoneController.text = widget.fornecedor!.telefone;
      _emailController.text = widget.fornecedor!.email;
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _cpfController.dispose();
    _telefoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _salvarOuAtualizarFornecedor() async {
    if (_formKey.currentState!.validate()) {
      try {
        final fornecedor = Fornecedor(
          id: widget.fornecedor?.id,
          nome: _nomeController.text.trim(),
          cpf: _cpfController.text,
          telefone: _telefoneController.text,
          email: _emailController.text.trim(),
          dataCadastro: widget.fornecedor?.dataCadastro ?? DateTime.now(),
        );

        final dao = DAOFornecedor();
        if (widget.fornecedor == null) {
          await dao.salvar(fornecedor);
        } else {
          await dao.atualizar(fornecedor);
        }

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.fornecedor == null
                ? 'Fornecedor cadastrado com sucesso!'
                : 'Fornecedor atualizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => TelaListaFornecedor()),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Erro ao ${widget.fornecedor == null ? 'cadastrar' : 'atualizar'} fornecedor: $e'),
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
          title: Text(
              widget.fornecedor == null ? 'Cadastrar Fornecedor' : 'Editar Fornecedor'),
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
                  decoration: const InputDecoration(labelText: 'Nome'),
                  validator: (value) =>
                      value!.trim().isEmpty ? 'Informe o nome' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _cpfController,
                  decoration: const InputDecoration(labelText: 'CPF'),
                  inputFormatters: [_cpfFormatter],
                  validator: (value) {
                    if (value!.trim().isEmpty) return 'Informe o CPF';
                    final cpfValido =
                        RegExp(r'^\d{3}\.\d{3}\.\d{3}-\d{2}$').hasMatch(value);
                    if (!cpfValido) return 'CPF inválido (ex.: 123.456.789-00)';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _telefoneController,
                  decoration: const InputDecoration(labelText: 'Telefone'),
                  inputFormatters: [_telefoneFormatter],
                  validator: (value) {
                    if (value!.trim().isEmpty) return 'Informe o telefone';
                    final telefoneValido =
                        RegExp(r'^\(\d{2}\) \d{5}-\d{4}$').hasMatch(value);
                    if (!telefoneValido) {
                      return 'Telefone inválido (ex.: (11) 91234-5678)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'E-mail'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value!.trim().isEmpty) return 'Informe o e-mail';
                    final emailValido = RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value);
                    if (!emailValido) return 'E-mail inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _salvarOuAtualizarFornecedor,
                  child:
                      Text(widget.fornecedor == null ? 'Cadastrar' : 'Atualizar'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TelaListaFornecedor(),
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