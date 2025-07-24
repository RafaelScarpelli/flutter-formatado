class Aluguel {
  int? id;
  int clienteId;
  int veiculoId;
  DateTime dataInicio;
  DateTime dataFim;
  double valorDiaria;
  double valorTotal;
  String status;

  Aluguel({
    this.id,
    required this.clienteId,
    required this.veiculoId,
    required this.dataInicio,
    required this.dataFim,
    required this.valorDiaria,
    required this.valorTotal,
    required this.status,
  });
}
