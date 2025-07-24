import 'package:projeto_ddm/projeto/banco/sqlite/conexao.dart';
import 'package:projeto_ddm/projeto/dto/veiculo.dart';
import 'package:sqflite/sqflite.dart';

class DAOVeiculo {
  final String _sqlSalvar = '''
    INSERT OR REPLACE INTO veiculo (id, marca_id, modelo, ano, cor, quilometragem, tipo, valor_venda, valor_aluguel_dia, status, data_cadastro, placa)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
  ''';

  final String _sqlConsultarTodos = '''
    SELECT v.*, m.nome AS marca_nome 
    FROM veiculo v 
    JOIN marca_veiculo m ON v.marca_id = m.id
  ''';

  final String _sqlConsultarPorId = '''
    SELECT v.*, m.nome AS marca_nome 
    FROM veiculo v 
    JOIN marca_veiculo m ON v.marca_id = m.id 
    WHERE v.id = ?
  ''';

  final String _sqlExcluir = '''
    DELETE FROM veiculo WHERE id = ?
  ''';

  final String _sqlAtualizar = '''
    UPDATE veiculo SET
      marca_id = ?, modelo = ?, ano = ?, cor = ?, quilometragem = ?,
      tipo = ?, valor_venda = ?, valor_aluguel_dia = ?, status = ?,
      data_cadastro = ?, placa = ?
    WHERE id = ?
  ''';

  Future<Veiculo> _fromMap(Map<String, dynamic> map) async {
    return Veiculo(
      id: map['id'],
      marcaId: map['marca_id'] as int,
      modelo: map['modelo'] as String,
      ano: map['ano'] as int,
      cor: map['cor'] as String,
      quilometragem: (map['quilometragem'] as num).toDouble(),
      tipo: map['tipo'] as String,
      valorVenda: (map['valor_venda'] as num).toDouble(),
      valorAluguelDia: (map['valor_aluguel_dia'] as num).toDouble(),
      status: map['status'] as String,
      dataCadastro: DateTime.parse(map['data_cadastro'] as String),
      placa: map['placa'] as String,
    );
  }

  Map<String, dynamic> _toMap(Veiculo veiculo) {
    return {
      'id': veiculo.id,
      'marca_id': veiculo.marcaId,
      'modelo': veiculo.modelo,
      'ano': veiculo.ano,
      'cor': veiculo.cor,
      'quilometragem': veiculo.quilometragem,
      'tipo': veiculo.tipo,
      'valor_venda': veiculo.valorVenda,
      'valor_aluguel_dia': veiculo.valorAluguelDia,
      'status': veiculo.status,
      'data_cadastro': veiculo.dataCadastro.toIso8601String(),
      'placa': veiculo.placa,
    };
  }

  Future<void> salvar(Veiculo veiculo) async {
    final db = await Conexao.get();
    try {
      await db.rawInsert(_sqlSalvar, [
        veiculo.id,
        veiculo.marcaId,
        veiculo.modelo,
        veiculo.ano,
        veiculo.cor,
        veiculo.quilometragem,
        veiculo.tipo,
        veiculo.valorVenda,
        veiculo.valorAluguelDia,
        veiculo.status,
        veiculo.dataCadastro.toIso8601String(),
        veiculo.placa,
      ]);
    } catch (e) {
      throw Exception('Erro ao salvar veículo: $e');
    }
  }

  Future<void> atualizar(Veiculo veiculo) async {
    final db = await Conexao.get();
    try {
      await db.rawUpdate(_sqlAtualizar, [
        veiculo.marcaId,
        veiculo.modelo,
        veiculo.ano,
        veiculo.cor,
        veiculo.quilometragem,
        veiculo.tipo,
        veiculo.valorVenda,
        veiculo.valorAluguelDia,
        veiculo.status,
        veiculo.dataCadastro.toIso8601String(),
        veiculo.placa,
        veiculo.id,
      ]);
    } catch (e) {
      throw Exception('Erro ao atualizar veículo: $e');
    }
  }

  Future<List<Veiculo>> consultarTodos() async {
    final db = await Conexao.get();
    try {
      final List<Map<String, dynamic>> maps =
          await db.rawQuery(_sqlConsultarTodos);
      return Future.wait(maps.map((map) => _fromMap(map)));
    } catch (e) {
      throw Exception('Erro ao consultar veículos: $e');
    }
  }

  Future<Veiculo?> consultarPorId(int id) async {
    final db = await Conexao.get();
    try {
      final List<Map<String, dynamic>> maps =
          await db.rawQuery(_sqlConsultarPorId, [id]);
      if (maps.isNotEmpty) {
        return await _fromMap(maps.first);
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao consultar veículo por ID: $e');
    }
  }

  Future<String> getMarcaNome(int marcaId) async {
    final db = await Conexao.get();
    try {
      final List<Map<String, dynamic>> maps = await db.rawQuery(
        'SELECT nome FROM marca_veiculo WHERE id = ?',
        [marcaId],
      );
      return maps.isNotEmpty ? maps.first['nome'] as String : 'Desconhecida';
    } catch (e) {
      throw Exception('Erro ao consultar nome da marca: $e');
    }
  }

  Future<void> excluir(int id) async {
    final db = await Conexao.get();
    try {
      await db.rawDelete(_sqlExcluir, [id]);
    } catch (e) {
      throw Exception('Erro ao excluir veículo: $e');
    }
  }

  Future<void> atualizarStatus(int veiculoId, String novoStatus) async {
    final db = await Conexao.get();
    try {
      await db.rawUpdate(
        '''
      UPDATE veiculo SET status = ? WHERE id = ?
      ''',
        [novoStatus, veiculoId],
      );
    } catch (e) {
      throw Exception('Erro ao atualizar status do veículo: $e');
    }
  }
}