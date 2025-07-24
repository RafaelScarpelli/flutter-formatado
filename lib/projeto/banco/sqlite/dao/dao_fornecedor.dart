import 'package:projeto_ddm/projeto/banco/sqlite/conexao.dart';
import 'package:projeto_ddm/projeto/dto/fornecedor.dart';
import 'package:sqflite/sqflite.dart';

class DAOFornecedor {
  final String _sqlSalvar = '''
    INSERT OR REPLACE INTO fornecedor (id, nome, cpf, telefone, email, data_cadastro)
    VALUES (?, ?, ?, ?, ?, ?)
  ''';

  final String _sqlConsultarTodos = '''
    SELECT * FROM fornecedor
  ''';

  final String _sqlConsultarPorId = '''
    SELECT * FROM fornecedor WHERE id = ?
  ''';

  final String _sqlExcluir = '''
    DELETE FROM fornecedor WHERE id = ?
  ''';

  final String _sqlAtualizar = '''
    UPDATE fornecedor SET
      nome = ?, cpf = ?, telefone = ?, email = ?, data_cadastro = ?
    WHERE id = ?
  ''';

  Future<Fornecedor> _fromMap(Map<String, dynamic> map) async {
    return Fornecedor(
      id: map['id'],
      nome: map['nome'] as String,
      cpf: map['cpf'] as String,
      telefone: map['telefone'] as String,
      email: map['email'] as String,
      dataCadastro: DateTime.parse(map['data_cadastro'] as String),
    );
  }

  Map<String, dynamic> _toMap(Fornecedor fornecedor) {
    return {
      'id': fornecedor.id,
      'nome': fornecedor.nome,
      'cpf': fornecedor.cpf,
      'telefone': fornecedor.telefone,
      'email': fornecedor.email,
      'data_cadastro': fornecedor.dataCadastro.toIso8601String(),
    };
  }

  Future<void> salvar(Fornecedor fornecedor) async {
    final db = await Conexao.get();
    try {
      await db.rawInsert(_sqlSalvar, [
        fornecedor.id,
        fornecedor.nome,
        fornecedor.cpf,
        fornecedor.telefone,
        fornecedor.email,
        fornecedor.dataCadastro.toIso8601String(),
      ]);
    } catch (e) {
      throw Exception('Erro ao salvar fornecedor: $e');
    }
  }

  Future<void> atualizar(Fornecedor fornecedor) async {
    final db = await Conexao.get();
    try {
      await db.rawUpdate(_sqlAtualizar, [
        fornecedor.nome,
        fornecedor.cpf,
        fornecedor.telefone,
        fornecedor.email,
        fornecedor.dataCadastro.toIso8601String(),
        fornecedor.id,
      ]);
    } catch (e) {
      throw Exception('Erro ao atualizar fornecedor: $e');
    }
  }

  Future<List<Fornecedor>> consultarTodos() async {
    final db = await Conexao.get();
    try {
      final List<Map<String, dynamic>> maps = await db.rawQuery(_sqlConsultarTodos);
      return Future.wait(maps.map((map) => _fromMap(map)));
    } catch (e) {
      throw Exception('Erro ao consultar fornecedores: $e');
    }
  }

  Future<Fornecedor?> consultarPorId(int id) async {
    final db = await Conexao.get();
    try {
      final List<Map<String, dynamic>> maps = await db.rawQuery(_sqlConsultarPorId, [id]);
      if (maps.isNotEmpty) {
        return await _fromMap(maps.first);
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao consultar fornecedor por ID: $e');
    }
  }

  Future<void> excluir(int id) async {
    final db = await Conexao.get();
    try {
      await db.rawDelete(_sqlExcluir, [id]);
    } catch (e) {
      throw Exception('Erro ao excluir fornecedor: $e');
    }
  }
}