import 'package:projeto_ddm/projeto/banco/sqlite/conexao.dart';
import 'package:projeto_ddm/projeto/dto/peca.dart';
import 'package:sqflite/sqflite.dart';

class DAOPeca {
  final String _sqlSalvar = '''
    INSERT OR REPLACE INTO peca (id, nome, marca_id, preco_unitario, quantidade)
    VALUES (?, ?, ?, ?, ?)
  ''';

  final String _sqlConsultarTodos = '''
    SELECT * FROM peca
  ''';

  final String _sqlConsultarPorId = '''
    SELECT * FROM peca WHERE id = ?
  ''';

  final String _sqlExcluir = '''
    DELETE FROM peca WHERE id = ?
  ''';

  final String _sqlAtualizar = '''
    UPDATE peca SET
      nome = ?, marca_id = ?, preco_unitario = ?, quantidade = ?
    WHERE id = ?
  ''';

  Future<Peca> _fromMap(Map<String, dynamic> map) async {
    return Peca(
      id: map['id'],
      nome: map['nome'] as String,
      marcaId: map['marca_id'] as int,
      precoUnitario: (map['preco_unitario'] as num).toDouble(),
      quantidade: map['quantidade'] as int,
    );
  }

  Map<String, dynamic> _toMap(Peca peca) {
    return {
      'id': peca.id,
      'nome': peca.nome,
      'marca_id': peca.marcaId,
      'preco_unitario': peca.precoUnitario,
      'quantidade': peca.quantidade,
    };
  }

  Future<void> salvar(Peca peca) async {
    final db = await Conexao.get();
    try {
      await db.rawInsert(_sqlSalvar, [
        peca.id,
        peca.nome,
        peca.marcaId,
        peca.precoUnitario,
        peca.quantidade,
      ]);
    } catch (e) {
      throw Exception('Erro ao salvar peça: $e');
    }
  }

  Future<void> atualizar(Peca peca) async {
    final db = await Conexao.get();
    try {
      await db.rawUpdate(_sqlAtualizar, [
        peca.nome,
        peca.marcaId,
        peca.precoUnitario,
        peca.quantidade,
        peca.id,
      ]);
    } catch (e) {
      throw Exception('Erro ao atualizar peça: $e');
    }
  }

  Future<List<Peca>> consultarTodos() async {
    final db = await Conexao.get();
    try {
      final List<Map<String, dynamic>> maps = await db.rawQuery(_sqlConsultarTodos);
      return Future.wait(maps.map((map) => _fromMap(map)));
    } catch (e) {
      throw Exception('Erro ao consultar peças: $e');
    }
  }

  Future<Peca?> consultarPorId(int id) async {
    final db = await Conexao.get();
    try {
      final List<Map<String, dynamic>> maps = await db.rawQuery(_sqlConsultarPorId, [id]);
      if (maps.isNotEmpty) {
        return await _fromMap(maps.first);
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao consultar peça por ID: $e');
    }
  }

  Future<void> excluir(int id) async {
    final db = await Conexao.get();
    try {
      await db.rawDelete(_sqlExcluir, [id]);
    } catch (e) {
      throw Exception('Erro ao excluir peça: $e');
    }
  }
}