class Fornecedor {
  int? id;
  String nome;
  String cpf;
  String telefone;
  String email;
  DateTime dataCadastro;

  Fornecedor({
    this.id,
    required this.nome,
    required this.cpf,
    required this.telefone,
    required this.email,
    required this.dataCadastro,
  });
}
