import 'package:projeto_ddm/projeto/banco/sqlite/conexao.dart';
import 'package:projeto_ddm/projeto/dto/marca.dart';
import 'package:sqflite/sqflite.dart';

class DAOMarcaVeiculo {
  final String _sqlSalvar = '''
    INSERT OR REPLACE INTO marca_veiculo (id, nome, site_oficial)
    VALUES (?, ?, ?)
  ''';

  final String _sqlConsultarTodos = '''
    SELECT * FROM marca_veiculo
  ''';

  final String _sqlConsultarPorId = '''
    SELECT * FROM marca_veiculo WHERE id = ?
  ''';

  final String _sqlExcluir = '''
    DELETE FROM marca_veiculo WHERE id = ?
  ''';

  final String _sqlAtualizar = '''
    UPDATE marca_veiculo SET
      nome = ?, site_oficial = ?
    WHERE id = ?
  ''';

  Future<MarcaVeiculo> _fromMap(Map<String, dynamic> map) async {
    return MarcaVeiculo(
      id: map['id'],
      nome: map['nome'] as String,
      site_oficial: map['site_oficial'] as String,
    );
  }

  Map<String, dynamic> _toMap(MarcaVeiculo marca) {
    return {
      'id': marca.id,
      'nome': marca.nome,
      'site_oficial': marca.site_oficial,
    };
  }

  Future<void> salvar(MarcaVeiculo marca) async {
    final db = await Conexao.get();
    try {
      await db.rawInsert(_sqlSalvar, [
        marca.id,
        marca.nome,
        marca.site_oficial,
      ]);
    } catch (e) {
      throw Exception('Erro ao salvar marca de veículo: $e');
    }
  }

  Future<void> atualizar(MarcaVeiculo marca) async {
    final db = await Conexao.get();
    try {
      await db.rawUpdate(_sqlAtualizar, [
        marca.nome,
        marca.site_oficial,
        marca.id,
      ]);
    } catch (e) {
      throw Exception('Erro ao atualizar marca de veículo: $e');
    }
  }

  Future<List<MarcaVeiculo>> consultarTodos() async {
    final db = await Conexao.get();
    try {
      final List<Map<String, dynamic>> maps = await db.rawQuery(_sqlConsultarTodos);
      return Future.wait(maps.map((map) => _fromMap(map)));
    } catch (e) {
      throw Exception('Erro ao consultar marcas de veículos: $e');
    }
  }

  Future<MarcaVeiculo?> consultarPorId(int id) async {
    final db = await Conexao.get();
    try {
      final List<Map<String, dynamic>> maps = await db.rawQuery(_sqlConsultarPorId, [id]);
      if (maps.isNotEmpty) {
        return await _fromMap(maps.first);
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao consultar marca de veículo por ID: $e');
    }
  }

  Future<void> excluir(int id) async {
    final db = await Conexao.get();
    try {
      await db.rawDelete(_sqlExcluir, [id]);
    } catch (e) {
      throw Exception('Erro ao excluir marca de veículo: $e');
    }
  }
}