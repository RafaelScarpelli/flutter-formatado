import 'package:projeto_ddm/projeto/banco/sqlite/conexao.dart';
import 'package:projeto_ddm/projeto/dto/venda.dart';
import 'package:sqflite/sqflite.dart';

class DAOVenda {
  final String _sqlSalvarVenda = '''
    INSERT OR REPLACE INTO venda (id, cliente_id, data_venda, valor)
    VALUES (?, ?, ?, ?)
  ''';

  final String _sqlSalvarVendaVeiculo = '''
    INSERT OR REPLACE INTO venda_veiculo (venda_id, veiculo_id)
    VALUES (?, ?)
  ''';

  final String _sqlConsultarTodos = '''
    SELECT * FROM venda
  ''';

  final String _sqlConsultarPorId = '''
    SELECT * FROM venda WHERE id = ?
  ''';

  final String _sqlConsultarVeiculosPorVenda = '''
    SELECT veiculo_id FROM venda_veiculo WHERE venda_id = ?
  ''';

  final String _sqlExcluirVenda = '''
    DELETE FROM venda WHERE id = ?
  ''';

  final String _sqlExcluirVendaVeiculos = '''
    DELETE FROM venda_veiculo WHERE venda_id = ?
  ''';

  final String _sqlAtualizar = '''
    UPDATE venda SET
      cliente_id = ?, data_venda = ?, valor = ?
    WHERE id = ?
  ''';

  Future<Venda> _fromMap(Map<String, dynamic> map, List<int> veiculoIds) async {
    return Venda(
      id: map['id'],
      clienteId: map['cliente_id'] as int,
      veiculoIds: veiculoIds,
      dataVenda: DateTime.parse(map['data_venda'] as String),
      valor: (map['valor'] as num).toDouble(),
    );
  }

  Map<String, dynamic> _toMap(Venda venda) {
    return {
      'id': venda.id,
      'cliente_id': venda.clienteId,
      'data_venda': venda.dataVenda.toIso8601String(),
      'valor': venda.valor,
    };
  }

  Future<void> salvar(Venda venda) async {
    final db = await Conexao.get();
    try {
      await db.transaction((txn) async {
        final vendaId = await txn.rawInsert(_sqlSalvarVenda, [
          venda.id,
          venda.clienteId,
          venda.dataVenda.toIso8601String(),
          venda.valor,
        ]);

        for (final veiculoId in venda.veiculoIds) {
          await txn.rawInsert(_sqlSalvarVendaVeiculo, [vendaId, veiculoId]);
        }
      });
    } catch (e) {
      throw Exception('Erro ao salvar venda: $e');
    }
  }

  Future<void> atualizar(Venda venda) async {
    final db = await Conexao.get();
    try {
      await db.transaction((txn) async {
        await txn.rawUpdate(_sqlAtualizar, [
          venda.clienteId,
          venda.dataVenda.toIso8601String(),
          venda.valor,
          venda.id,
        ]);

        await txn.rawDelete(_sqlExcluirVendaVeiculos, [venda.id]);
        for (final veiculoId in venda.veiculoIds) {
          await txn.rawInsert(_sqlSalvarVendaVeiculo, [venda.id, veiculoId]);
        }
      });
    } catch (e) {
      throw Exception('Erro ao atualizar venda: $e');
    }
  }

  Future<List<Venda>> consultarTodos() async {
    final db = await Conexao.get();
    try {
      final List<Map<String, dynamic>> maps =
          await db.rawQuery(_sqlConsultarTodos);
      final vendas = <Venda>[];
      for (final map in maps) {
        final veiculoIds = await _consultarVeiculoIds(map['id'] as int);
        vendas.add(await _fromMap(map, veiculoIds));
      }
      return vendas;
    } catch (e) {
      throw Exception('Erro ao consultar vendas: $e');
    }
  }

  Future<Venda?> consultarPorId(int id) async {
    final db = await Conexao.get();
    try {
      final List<Map<String, dynamic>> maps =
          await db.rawQuery(_sqlConsultarPorId, [id]);
      if (maps.isNotEmpty) {
        final veiculoIds = await _consultarVeiculoIds(id);
        return await _fromMap(maps.first, veiculoIds);
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao consultar venda por ID: $e');
    }
  }

  Future<List<int>> _consultarVeiculoIds(int vendaId) async {
    final db = await Conexao.get();
    final List<Map<String, dynamic>> maps =
        await db.rawQuery(_sqlConsultarVeiculosPorVenda, [vendaId]);
    return maps.map((map) => map['veiculo_id'] as int).toList();
  }

  Future<void> excluir(int id) async {
    final db = await Conexao.get();
    try {
      await db.transaction((txn) async {
        await txn.rawDelete(_sqlExcluirVendaVeiculos, [id]);
        await txn.rawDelete(_sqlExcluirVenda, [id]);
      });
    } catch (e) {
      throw Exception('Erro ao excluir venda: $e');
    }
  }
}