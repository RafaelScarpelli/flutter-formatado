class Venda {
  int? id;
  int clienteId;
  List<int> veiculoIds;
  DateTime dataVenda;
  double valor;

  Venda({
    this.id,
    required this.clienteId,
    required this.veiculoIds,
    required this.dataVenda,
    required this.valor,
  });
}