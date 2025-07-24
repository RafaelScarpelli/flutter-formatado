import 'package:projeto_ddm/projeto/banco/sqlite/conexao.dart';
import 'package:projeto_ddm/projeto/dto/observacao.dart';
import 'package:sqflite/sqflite.dart';

class DAOObservacao {
  final String _tableName = 'observacao';
  final String _id = 'id';
  final String _clienteId = 'cliente_id';
  final String _mensagem = 'mensagem';

  Future<int> salvar(Observacao observacao) async {
    final db = await Conexao.get();
    try {
      return await db.insert(
        _tableName,
        {
          _clienteId: observacao.clienteId,
          _mensagem: observacao.mensagem,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw Exception('Erro ao salvar observação: $e');
    }
  }

  Future<int> atualizar(Observacao observacao) async {
    final db = await Conexao.get();
    try {
      return await db.update(
        _tableName,
        {
          _clienteId: observacao.clienteId,
          _mensagem: observacao.mensagem,
        },
        where: '$_id = ?',
        whereArgs: [observacao.id],
      );
    } catch (e) {
      throw Exception('Erro ao atualizar observação: $e');
    }
  }

  Future<List<Observacao>> consultarTodos() async {
    final db = await Conexao.get();
    try {
      final List<Map<String, dynamic>> maps = await db.query(_tableName);
      return maps
          .map((map) => Observacao(
                id: map[_id],
                clienteId: map[_clienteId],
                mensagem: map[_mensagem],
              ))
          .toList();
    } catch (e) {
      throw Exception('Erro ao consultar observações: $e');
    }
  }

  Future<Observacao?> consultarPorId(int id) async {
    final db = await Conexao.get();
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: '$_id = ?',
        whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        return Observacao(
          id: maps.first[_id],
          clienteId: maps.first[_clienteId],
          mensagem: maps.first[_mensagem],
        );
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao consultar observação por ID: $e');
    }
  }

  Future<int> excluir(int id) async {
    final db = await Conexao.get();
    try {
      return await db.delete(
        _tableName,
        where: '$_id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Erro ao excluir observação: $e');
    }
  }

  Future<List<Observacao>> consultarPorClienteId(int clienteId) async {
    final db = await Conexao.get();
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: '$_clienteId = ?',
        whereArgs: [clienteId],
      );
      return maps
          .map((map) => Observacao(
                id: map[_id],
                clienteId: map[_clienteId],
                mensagem: map[_mensagem],
              ))
          .toList();
    } catch (e) {
      throw Exception('Erro ao consultar observações por cliente: $e');
    }
  }
}
