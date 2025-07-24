class AgendamentoRevisao {
  int? id;
  int carroId;
  int revisaoId;
  DateTime data;
  String descricao;

  AgendamentoRevisao({
    this.id,
    required this.carroId,
    required this.revisaoId,
    required this.data,
    required this.descricao,
  });
}
