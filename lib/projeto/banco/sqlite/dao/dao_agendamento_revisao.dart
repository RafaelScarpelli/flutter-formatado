import 'package:projeto_ddm/projeto/banco/sqlite/conexao.dart';
import 'package:projeto_ddm/projeto/dto/agendamento_revisao.dart';
import 'package:sqflite/sqflite.dart';

class DAOAgendamentoRevisao {
  final String _sqlSalvar = '''
    INSERT OR REPLACE INTO agendamento_revisao (id, carro_id, revisao_id, data, descricao)
    VALUES (?, ?, ?, ?, ?)
  ''';

  final String _sqlConsultarTodos = '''
    SELECT * FROM agendamento_revisao
  ''';

  final String _sqlConsultarPorId = '''
    SELECT * FROM agendamento_revisao WHERE id = ?
  ''';

  final String _sqlExcluir = '''
    DELETE FROM agendamento_revisao WHERE id = ?
  ''';

  final String _sqlAtualizar = '''
    UPDATE agendamento_revisao SET
      carro_id = ?, revisao_id = ?, data = ?, descricao = ?
    WHERE id = ?
  ''';

  Future<AgendamentoRevisao> _fromMap(Map<String, dynamic> map) async {
    return AgendamentoRevisao(
      id: map['id'],
      carroId: map['carro_id'] as int,
      revisaoId: map['revisao_id'] as int,
      data: DateTime.parse(map['data'] as String),
      descricao: map['descricao'] as String,
    );
  }

  Map<String, dynamic> _toMap(AgendamentoRevisao agendamento) {
    return {
      'id': agendamento.id,
      'carro_id': agendamento.carroId,
      'revisao_id': agendamento.revisaoId,
      'data': agendamento.data.toIso8601String(),
      'descricao': agendamento.descricao,
    };
  }

  Future<void> salvar(AgendamentoRevisao agendamento) async {
    final db = await Conexao.get();
    try {
      await db.rawInsert(_sqlSalvar, [
        agendamento.id,
        agendamento.carroId,
        agendamento.revisaoId,
        agendamento.data.toIso8601String(),
        agendamento.descricao,
      ]);
    } catch (e) {
      throw Exception('Erro ao salvar agendamento de revisão: $e');
    }
  }

  Future<void> atualizar(AgendamentoRevisao agendamento) async {
    final db = await Conexao.get();
    try {
      await db.rawUpdate(_sqlAtualizar, [
        agendamento.carroId,
        agendamento.revisaoId,
        agendamento.data.toIso8601String(),
        agendamento.descricao,
        agendamento.id,
      ]);
    } catch (e) {
      throw Exception('Erro ao atualizar agendamento de revisão: $e');
    }
  }

  Future<List<AgendamentoRevisao>> consultarTodos() async {
    final db = await Conexao.get();
    try {
      final List<Map<String, dynamic>> maps = await db.rawQuery(_sqlConsultarTodos);
      return Future.wait(maps.map((map) => _fromMap(map)));
    } catch (e) {
      throw Exception('Erro ao consultar agendamentos de revisão: $e');
    }
  }

  Future<AgendamentoRevisao?> consultarPorId(int id) async {
    final db = await Conexao.get();
    try {
      final List<Map<String, dynamic>> maps = await db.rawQuery(_sqlConsultarPorId, [id]);
      if (maps.isNotEmpty) {
        return await _fromMap(maps.first);
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao consultar agendamento de revisão por ID: $e');
    }
  }

  Future<void> excluir(int id) async {
    final db = await Conexao.get();
    try {
      await db.rawDelete(_sqlExcluir, [id]);
    } catch (e) {
      throw Exception('Erro ao excluir agendamento de revisão: $e');
    }
  }
}