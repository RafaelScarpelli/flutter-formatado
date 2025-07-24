import 'package:projeto_ddm/projeto/banco/sqlite/conexao.dart';
import 'package:projeto_ddm/projeto/dto/aluguel.dart';
import 'package:sqflite/sqflite.dart';

class DAOAluguel {
  final String _tableName = 'aluguel';
  final String _id = 'id';
  final String _clienteId = 'cliente_id';
  final String _veiculoId = 'veiculo_id';
  final String _dataInicio = 'data_inicio';
  final String _dataFim = 'data_fim';
  final String _valorDiaria = 'valor_diaria';
  final String _valorTotal = 'valor_total';
  final String _status = 'status';

  Future<int> salvar(Aluguel aluguel) async {
    final db = await Conexao.get();
    try {
      return await db.insert(
        _tableName,
        {
          _clienteId: aluguel.clienteId,
          _veiculoId: aluguel.veiculoId,
          _dataInicio: aluguel.dataInicio.toIso8601String(),
          _dataFim: aluguel.dataFim.toIso8601String(),
          _valorDiaria: aluguel.valorDiaria,
          _valorTotal: aluguel.valorTotal,
          _status: aluguel.status,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw Exception('Erro ao salvar aluguel: $e');
    }
  }

  Future<int> atualizar(Aluguel aluguel) async {
    final db = await Conexao.get();
    try {
      return await db.update(
        _tableName,
        {
          _clienteId: aluguel.clienteId,
          _veiculoId: aluguel.veiculoId,
          _dataInicio: aluguel.dataInicio.toIso8601String(),
          _dataFim: aluguel.dataFim.toIso8601String(),
          _valorDiaria: aluguel.valorDiaria,
          _valorTotal: aluguel.valorTotal,
          _status: aluguel.status,
        },
        where: '$_id = ?',
        whereArgs: [aluguel.id],
      );
    } catch (e) {
      throw Exception('Erro ao atualizar aluguel: $e');
    }
  }

  Future<List<Aluguel>> consultarTodos() async {
    final db = await Conexao.get();
    try {
      final List<Map<String, dynamic>> maps = await db.query(_tableName);
      return maps.map((map) => Aluguel(
            id: map[_id],
            clienteId: map[_clienteId],
            veiculoId: map[_veiculoId],
            dataInicio: DateTime.parse(map[_dataInicio]),
            dataFim: DateTime.parse(map[_dataFim]),
            valorDiaria: map[_valorDiaria],
            valorTotal: map[_valorTotal],
            status: map[_status],
          )).toList();
    } catch (e) {
      throw Exception('Erro ao consultar aluguéis: $e');
    }
  }

  Future<Aluguel?> consultarPorId(int id) async {
    final db = await Conexao.get();
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: '$_id = ?',
        whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        return Aluguel(
          id: maps.first[_id],
          clienteId: maps.first[_clienteId],
          veiculoId: maps.first[_veiculoId],
          dataInicio: DateTime.parse(maps.first[_dataInicio]),
          dataFim: DateTime.parse(maps.first[_dataFim]),
          valorDiaria: maps.first[_valorDiaria],
          valorTotal: maps.first[_valorTotal],
          status: maps.first[_status],
        );
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao consultar aluguel por ID: $e');
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
      throw Exception('Erro ao excluir aluguel: $e');
    }
  }
}