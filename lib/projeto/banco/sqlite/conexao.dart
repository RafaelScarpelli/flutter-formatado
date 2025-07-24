import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:projeto_ddm/projeto/banco/sqlite/script.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class Conexao {
  static Database? _db;

  static Future<Database> get() async {
    if (_db != null) return _db!;

    try {
      if (kIsWeb) {
        databaseFactory = databaseFactoryFfiWeb;
      }

      final path = join(await getDatabasesPath(), 'banco.db');
      // await deleteDatabase(path);

      _db = await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          for (final sql in criarTabelas) {
            await db.execute(sql);
          }
          for (final insert in insertVeiculos) {
            await db.execute(insert);
          }
          for (final insert in insertClientes) {
            await db.execute(insert);
          }
          for (final insert in insertVendas) {
            await db.execute(insert);
          }
          for (final insert in insertVendaVeiculo) {
            await db.execute(insert);
          }
          for (final insert in insertObservacoes) {
            await db.execute(insert);
          }
          for (final insert in insertMarcasVeiculo) {
            await db.execute(insert);
          }
          for (final insert in insertFornecedores) {
            await db.execute(insert);
          }
          for (final insert in insertPecas) {
            await db.execute(insert);
          }
          for (final insert in insertVendaPeca) {
            await db.execute(insert);
          }
          for (final insert in insertRevisoes) {
            await db.execute(insert);
          }
          for (final insert in insertAgendamentosRevisao) {
            await db.execute(insert);
          }
        },
      );

      return _db!;
    } catch (e) {
      throw Exception('Erro ao abrir o banco de dados: $e');
    }
  }
}
