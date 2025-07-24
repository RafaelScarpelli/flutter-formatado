import 'package:projeto_ddm/projeto/banco/sqlite/conexao.dart';
import 'package:projeto_ddm/projeto/dto/revisao.dart';
import 'package:sqflite/sqflite.dart';

class DAORevisao {
  final String _tableName = 'revisao';
  final String _id = 'id';
  final String _tipo = 'tipo';
  final String _oficina = 'oficina';

  Future<int> salvar(Revisao revisao) async {
    final db = await Conexao.get();
    try {
      return await db.insert(
        _tableName,
        {
          _tipo: revisao.tipo,
          _oficina: revisao.oficina,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw Exception('Erro ao salvar revisão: $e');
    }
  }

  Future<int> atualizar(Revisao revisao) async {
    final db = await Conexao.get();
    try {
      return await db.update(
        _tableName,
        {
          _tipo: revisao.tipo,
          _oficina: revisao.oficina,
        },
        where: '$_id = ?',
        whereArgs: [revisao.id],
      );
    } catch (e) {
      throw Exception('Erro ao atualizar revisão: $e');
    }
  }

  Future<List<Revisao>> consultarTodos() async {
    final db = await Conexao.get();
    try {
      final List<Map<String, dynamic>> maps = await db.query(_tableName);
      return maps.map((map) => Revisao(
            id: map[_id],
            tipo: map[_tipo],
            oficina: map[_oficina],
          )).toList();
    } catch (e) {
      throw Exception('Erro ao consultar revisões: $e');
    }
  }

  Future<Revisao?> consultarPorId(int id) async {
    final db = await Conexao.get();
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: '$_id = ?',
        whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        return Revisao(
          id: maps.first[_id],
          tipo: maps.first[_tipo],
          oficina: maps.first[_oficina],
        );
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao consultar revisão por ID: $e');
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
      throw Exception('Erro ao excluir revisão: $e');
    }
  }
}