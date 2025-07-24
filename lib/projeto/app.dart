import 'package:flutter/material.dart';
import 'package:projeto_ddm/projeto/rotas.dart';
import 'package:projeto_ddm/projeto/telas/tela_cadastrar_agendamento_revisao.dart';
import 'package:projeto_ddm/projeto/telas/tela_cadastrar_aluguel.dart';
import 'package:projeto_ddm/projeto/telas/tela_cadastrar_cliente.dart';
import 'package:projeto_ddm/projeto/telas/tela_cadastrar_fornecedor.dart';
import 'package:projeto_ddm/projeto/telas/tela_cadastrar_marca.dart';
import 'package:projeto_ddm/projeto/telas/tela_cadastrar_observacao.dart';
import 'package:projeto_ddm/projeto/telas/tela_cadastrar_peca.dart';
import 'package:projeto_ddm/projeto/telas/tela_cadastrar_revisao.dart';
import 'package:projeto_ddm/projeto/telas/tela_cadastrar_veiculo.dart';
import 'package:projeto_ddm/projeto/telas/tela_cadastrar_venda.dart';
import 'package:projeto_ddm/projeto/telas/tela_dashboard.dart';
import 'package:projeto_ddm/projeto/telas/tela_lista_agendamento_revisao.dart';
import 'package:projeto_ddm/projeto/telas/tela_lista_aluguel.dart';
import 'package:projeto_ddm/projeto/telas/tela_lista_cliente.dart';
import 'package:projeto_ddm/projeto/telas/tela_lista_fornecedor.dart';
import 'package:projeto_ddm/projeto/telas/tela_lista_marca.dart';
import 'package:projeto_ddm/projeto/telas/tela_lista_observacao.dart';
import 'package:projeto_ddm/projeto/telas/tela_lista_peca.dart';
import 'package:projeto_ddm/projeto/telas/tela_lista_revisao.dart';
import 'package:projeto_ddm/projeto/telas/tela_lista_veiculos.dart';
import 'package:projeto_ddm/projeto/telas/tela_lista_venda.dart';
import 'package:projeto_ddm/projeto/telas/tela_menu.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gerenciador de Veículos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.grey[850],
        scaffoldBackgroundColor: Colors.grey[900],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[850],
          foregroundColor: Colors.white,
          elevation: 4,
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.grey[300]),
          titleLarge: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[600],
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: Colors.green[600]),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[800],
          labelStyle: TextStyle(color: Colors.grey[300]),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.orange[600]!, width: 1.5),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.green[600]!, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red[400]!, width: 1.5),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red[400]!, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        cardTheme: CardTheme(
          color: Colors.grey[800],
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      initialRoute: Rotas.dashboard,
      routes: {
        Rotas.dashboard: (context) => DashboardPage(),
        Rotas.menu: (context) => TelaMenuPrincipal(),
        Rotas.listar_veiculos: (context) => TelaListaVeiculos(),
        Rotas.cadastrar_veiculo: (context) => TelaCadastrarVeiculo(),
        Rotas.listar_clientes: (context) => TelaListaClientes(),
        Rotas.cadastrar_cliente: (context) => TelaCadastrarCliente(),
        Rotas.listar_vendas: (context) => TelaListaVenda(),
        Rotas.cadastrar_venda: (context) => TelaCadastrarVenda(),
        Rotas.listar_aluguel: (context) => TelaListaAluguel(),
        Rotas.cadastrar_aluguel: (context) => TelaCadastrarAluguel(),
        Rotas.listar_observacao: (context) => TelaListaObservacao(),
        Rotas.cadastrar_observacao: (context) => TelaCadastrarObservacao(),
        Rotas.listar_revisao: (context) => TelaListaRevisao(),
        Rotas.cadastrar_revisao: (context) => TelaCadastrarRevisao(),
        Rotas.listar_marca_veiculo: (context) => TelaListaMarcaVeiculo(),
        Rotas.cadastrar_marca_veiculo: (context) => TelaCadastrarMarcaVeiculo(),
        Rotas.listar_fornecedor: (context) => TelaListaFornecedor(),
        Rotas.cadastrar_fornecedor: (context) => TelaCadastrarFornecedor(),
        Rotas.listar_peca: (context) => TelaListaPeca(),
        Rotas.cadastrar_peca: (context) => TelaCadastrarPeca(),
        Rotas.listar_agendamento_revisao: (context) =>
            TelaListaAgendamentoRevisao(),
        Rotas.cadastrar_agendamento_revisao: (context) =>
            TelaCadastrarAgendamentoRevisao(),
      },
    );
  }
}
