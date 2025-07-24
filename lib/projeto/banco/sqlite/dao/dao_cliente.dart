import 'package:projeto_ddm/projeto/banco/sqlite/conexao.dart';
import 'package:projeto_ddm/projeto/dto/cliente.dart';
import 'package:sqflite/sqflite.dart';

class DAOCliente {
  final String _sqlSalvar = '''
    INSERT OR REPLACE INTO cliente (id, nome, cpf, telefone, email, data_cadastro)
    VALUES (?, ?, ?, ?, ?, ?)
  ''';

  final String _sqlConsultarTodos = '''
    SELECT * FROM cliente
  ''';

  final String _sqlConsultarPorId = '''
    SELECT * FROM cliente WHERE id = ?
  ''';

  final String _sqlExcluir = '''
    DELETE FROM cliente WHERE id = ?
  ''';

  final String _sqlAtualizar = '''
    UPDATE cliente SET
      nome = ?, cpf = ?, telefone = ?, email = ?, data_cadastro = ?
    WHERE id = ?
  ''';

  Future<Cliente> _fromMap(Map<String, dynamic> map) async {
    return Cliente(
      id: map['id'],
      nome: map['nome'] as String,
      cpf: map['cpf'] as String,
      telefone: map['telefone'] as String,
      email: map['email'] as String,
      dataCadastro: DateTime.parse(map['data_cadastro'] as String),
    );
  }

  Map<String, dynamic> _toMap(Cliente cliente) {
    return {
      'id': cliente.id,
      'nome': cliente.nome,
      'cpf': cliente.cpf,
      'telefone': cliente.telefone,
      'email': cliente.email,
      'data_cadastro': cliente.dataCadastro.toIso8601String(),
    };
  }

  Future<void> salvar(Cliente cliente) async {
    final db = await Conexao.get();
    try {
      await db.rawInsert(_sqlSalvar, [
        cliente.id,
        cliente.nome,
        cliente.cpf,
        cliente.telefone,
        cliente.email,
        cliente.dataCadastro.toIso8601String(),
      ]);
    } catch (e) {
      throw Exception('Erro ao salvar cliente: $e');
    }
  }

  Future<void> atualizar(Cliente cliente) async {
    final db = await Conexao.get();
    try {
      await db.rawUpdate(_sqlAtualizar, [
        cliente.nome,
        cliente.cpf,
        cliente.telefone,
        cliente.email,
        cliente.dataCadastro.toIso8601String(),
        cliente.id,
      ]);
    } catch (e) {
      throw Exception('Erro ao atualizar cliente: $e');
    }
  }

  Future<List<Cliente>> consultarTodos() async {
    final db = await Conexao.get();
    try {
      final List<Map<String, dynamic>> maps = await db.rawQuery(_sqlConsultarTodos);
      return Future.wait(maps.map((map) => _fromMap(map)));
    } catch (e) {
      throw Exception('Erro ao consultar clientes: $e');
    }
  }

  Future<Cliente?> consultarPorId(int id) async {
    final db = await Conexao.get();
    try {
      final List<Map<String, dynamic>> maps = await db.rawQuery(_sqlConsultarPorId, [id]);
      if (maps.isNotEmpty) {
        return await _fromMap(maps.first);
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao consultar cliente por ID: $e');
    }
  }

  Future<void> excluir(int id) async {
    final db = await Conexao.get();
    try {
      await db.rawDelete(_sqlExcluir, [id]);
    } catch (e) {
      throw Exception('Erro ao excluir cliente: $e');
    }
  }
}