import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:projeto_ddm/projeto/banco/sqlite/dao/dao_cliente.dart';
import 'package:projeto_ddm/projeto/dto/cliente.dart';
import 'package:projeto_ddm/projeto/telas/tela_lista_cliente.dart';

class TelaCadastrarCliente extends StatefulWidget {
  final Cliente? cliente;
  const TelaCadastrarCliente({super.key, this.cliente});

  @override
  State<TelaCadastrarCliente> createState() => _TelaCadastrarClienteState();
}

class _TelaCadastrarClienteState extends State<TelaCadastrarCliente> {
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
    if (widget.cliente != null) {
      _nomeController.text = widget.cliente!.nome;
      _cpfController.text = widget.cliente!.cpf;
      _telefoneController.text = widget.cliente!.telefone;
      _emailController.text = widget.cliente!.email;
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

  Future<void> _salvarOuAtualizarCliente() async {
    if (_formKey.currentState!.validate()) {
      try {
        final cliente = Cliente(
          id: widget.cliente?.id,
          nome: _nomeController.text.trim(),
          cpf: _cpfController.text,
          telefone: _telefoneController.text,
          email: _emailController.text.trim(),
          dataCadastro: widget.cliente?.dataCadastro ?? DateTime.now(),
        );

        final dao = DAOCliente();
        if (widget.cliente == null) {
          await dao.salvar(cliente);
        } else {
          await dao.atualizar(cliente);
        }

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.cliente == null
                ? 'Cliente cadastrado com sucesso!'
                : 'Cliente atualizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => TelaListaClientes()),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Erro ao ${widget.cliente == null ? 'cadastrar' : 'atualizar'} cliente: $e'),
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
              widget.cliente == null ? 'Cadastrar Cliente' : 'Editar Cliente'),
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
                  onPressed: _salvarOuAtualizarCliente,
                  child:
                      Text(widget.cliente == null ? 'Cadastrar' : 'Atualizar'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TelaListaClientes(),
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