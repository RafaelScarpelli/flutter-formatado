import 'package:flutter/material.dart';
import 'package:projeto_ddm/projeto/banco/sqlite/dao/dao_marca_veiculo.dart';
import 'package:projeto_ddm/projeto/dto/marca.dart';
import 'package:projeto_ddm/projeto/telas/tela_lista_marca.dart';

class TelaCadastrarMarcaVeiculo extends StatefulWidget {
  final MarcaVeiculo? marca;
  const TelaCadastrarMarcaVeiculo({super.key, this.marca});

  @override
  State<TelaCadastrarMarcaVeiculo> createState() => _TelaCadastrarMarcaVeiculoState();
}

class _TelaCadastrarMarcaVeiculoState extends State<TelaCadastrarMarcaVeiculo> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _siteOficialController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.marca != null) {
      _nomeController.text = widget.marca!.nome;
      _siteOficialController.text = widget.marca!.site_oficial;
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _siteOficialController.dispose();
    super.dispose();
  }

  Future<void> _salvarOuAtualizarMarca() async {
    if (_formKey.currentState!.validate()) {
      try {
        final marca = MarcaVeiculo(
          id: widget.marca?.id,
          nome: _nomeController.text.trim(),
          site_oficial: _siteOficialController.text.trim(),
        );

        final dao = DAOMarcaVeiculo();
        if (widget.marca == null) {
          await dao.salvar(marca);
        } else {
          await dao.atualizar(marca);
        }

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.marca == null
                ? 'Marca cadastrada com sucesso!'
                : 'Marca atualizada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => TelaListaMarcaVeiculo()),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Erro ao ${widget.marca == null ? 'cadastrar' : 'atualizar'} marca: $e'),
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
              widget.marca == null ? 'Cadastrar Marca' : 'Editar Marca'),
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
                  decoration: const InputDecoration(labelText: 'Nome da Marca'),
                  validator: (value) =>
                      value!.trim().isEmpty ? 'Informe o nome da marca' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _siteOficialController,
                  decoration: const InputDecoration(labelText: 'Site Oficial'),
                  keyboardType: TextInputType.url,
                  validator: (value) {
                    if (value!.trim().isEmpty) return 'Informe o site oficial';
                    final urlValida = RegExp(
                            r'^(https?:\/\/)?([\w-]+\.)+[\w-]{2,4}(\/.*)?$')
                        .hasMatch(value);
                    if (!urlValida) return 'URL inválida (ex.: https://www.exemplo.com)';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _salvarOuAtualizarMarca,
                  child:
                      Text(widget.marca == null ? 'Cadastrar' : 'Atualizar'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TelaListaMarcaVeiculo(),
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