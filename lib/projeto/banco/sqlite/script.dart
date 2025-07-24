final _veiculo = '''
CREATE TABLE veiculo (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    marca_id INTEGER NOT NULL,
    modelo TEXT NOT NULL,
    ano INTEGER NOT NULL,
    cor TEXT NOT NULL,
    quilometragem REAL NOT NULL,
    tipo TEXT NOT NULL,
    valor_venda REAL NOT NULL,
    valor_aluguel_dia REAL NOT NULL,
    status TEXT NOT NULL,
    data_cadastro TEXT NOT NULL,
    placa TEXT NOT NULL,
    FOREIGN KEY (marca_id) REFERENCES marca_veiculo(id)
);
''';

final _cliente = '''
CREATE TABLE cliente ( 
  id INTEGER PRIMARY KEY AUTOINCREMENT, 
  nome TEXT NOT NULL, 
  cpf TEXT NOT NULL, 
  telefone TEXT NOT NULL, 
  email TEXT NOT NULL, 
  data_cadastro TEXT NOT NULL 
); 
''';

final _venda = '''
CREATE TABLE venda (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    cliente_id INTEGER NOT NULL,
    data_venda TEXT NOT NULL,
    valor REAL NOT NULL,
    FOREIGN KEY (cliente_id) REFERENCES cliente(id)
);
''';

final _venda_veiculo = '''
CREATE TABLE venda_veiculo (
    venda_id INTEGER NOT NULL,
    veiculo_id INTEGER NOT NULL,
    PRIMARY KEY (venda_id, veiculo_id),
    FOREIGN KEY (venda_id) REFERENCES venda(id),
    FOREIGN KEY (veiculo_id) REFERENCES veiculo(id)
);
''';

final _aluguel = '''
CREATE TABLE aluguel (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    cliente_id INTEGER NOT NULL,
    veiculo_id INTEGER NOT NULL,
    data_inicio TEXT NOT NULL,
    data_fim TEXT NOT NULL,
    valor_diaria REAL NOT NULL,
    valor_total REAL NOT NULL,
    status TEXT NOT NULL,
    FOREIGN KEY (cliente_id) REFERENCES cliente(id),
    FOREIGN KEY (veiculo_id) REFERENCES veiculo(id)
);
''';

final _observacao = '''
CREATE TABLE observacao (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    cliente_id INTEGER NOT NULL,
    mensagem TEXT NOT NULL,
    FOREIGN KEY (cliente_id) REFERENCES cliente(id)
);
''';

final _revisao = '''
CREATE TABLE revisao (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    tipo TEXT NOT NULL,
    oficina TEXT NOT NULL
);
''';

final _marca_veiculo = ''' 
CREATE TABLE marca_veiculo ( 
    id INTEGER PRIMARY KEY AUTOINCREMENT, 
    nome TEXT NOT NULL, 
    site_oficial TEXT NOT NULL 
); 
''';

final _fornecedor = ''' 
CREATE TABLE fornecedor ( 
    id INTEGER PRIMARY KEY AUTOINCREMENT, 
    nome TEXT NOT NULL, 
    cpf TEXT NOT NULL, 
    telefone TEXT NOT NULL, 
    email TEXT NOT NULL, 
    data_cadastro TEXT NOT NULL 
); 
''';

final _peca = ''' 
CREATE TABLE peca ( 
    id INTEGER PRIMARY KEY AUTOINCREMENT, 
    nome TEXT NOT NULL, 
    marca_id INTEGER NOT NULL, 
    preco_unitario REAL NOT NULL, 
    quantidade INTEGER NOT NULL, 
    FOREIGN KEY (marca_id) REFERENCES marca_veiculo(id) 
); 
''';

final _venda_peca = ''' 
CREATE TABLE venda_peca ( 
    venda_id INTEGER NOT NULL, 
    peca_id INTEGER NOT NULL, 
    PRIMARY KEY (venda_id, peca_id), 
    FOREIGN KEY (venda_id) REFERENCES venda(id), 
    FOREIGN KEY (peca_id) REFERENCES peca(id) 
); 
''';

final _agendamento_revisao = ''' 
CREATE TABLE agendamento_revisao ( 
    id INTEGER PRIMARY KEY AUTOINCREMENT, 
    carro_id INTEGER NOT NULL, 
    revisao_id INTEGER NOT NULL, 
    data TEXT NOT NULL, 
    descricao TEXT NOT NULL, 
    FOREIGN KEY (carro_id) REFERENCES veiculo(id), 
    FOREIGN KEY (revisao_id) REFERENCES revisao(id) 
); 
''';

final criarTabelas = [
  _veiculo,
  _cliente,
  _venda,
  _venda_veiculo,
  _aluguel,
  _observacao,
  _revisao,
  _marca_veiculo,
  _fornecedor,
  _peca,
  _venda_peca,
  _agendamento_revisao,
];

final insertVeiculos = [
  '''
  INSERT INTO veiculo (marca_id, modelo, ano, cor, quilometragem, tipo, valor_venda, valor_aluguel_dia, status, data_cadastro, placa)
  VALUES (1, 'Corolla', 2020, 'Prata', 35000.0, 'Venda', 90000.0, 0.0, 'vendido', '2025-01-10T00:00:00.000', 'ABC-1234')
  ''',
  '''
  INSERT INTO veiculo (marca_id, modelo, ano, cor, quilometragem, tipo, valor_venda, valor_aluguel_dia, status, data_cadastro, placa)
  VALUES (2, 'Civic', 2019, 'Preto', 45000.0, 'Aluguel', 0.0, 200.0, 'disponível', '2025-02-15T00:00:00.000', 'DEF-5678')
  ''',
  '''
  INSERT INTO veiculo (marca_id, modelo, ano, cor, quilometragem, tipo, valor_venda, valor_aluguel_dia, status, data_cadastro, placa)
  VALUES (3, 'Focus', 2018, 'Azul', 60000.0, 'Ambos', 75000.0, 150.0, 'disponível', '2025-03-20T00:00:00.000', 'GHI-9012')
  ''',
];

final insertClientes = [
  ''' INSERT INTO cliente (nome, cpf, telefone, email, data_cadastro) VALUES ('João Silva', '123.456.789-00', '(11) 91234-5678', 'joao.silva@email.com', '2025-01-15T00:00:00.000') ''',
  ''' INSERT INTO cliente (nome, cpf, telefone, email, data_cadastro) VALUES ('Maria Oliveira', '987.654.321-00', '(21) 98765-4321', 'maria.oliveira@email.com', '2025-02-20T00:00:00.000') ''',
];

final insertVendas = [
  '''
  INSERT INTO venda (cliente_id, data_venda, valor)
  VALUES (1, '2025-04-10T00:00:00.000', 90000.0)
  ''',
];

final insertVendaVeiculo = [
  '''
  INSERT INTO venda_veiculo (venda_id, veiculo_id)
  VALUES (1, 1)
  ''',
];

final insertObservacoes = [
  '''
  INSERT INTO observacao (cliente_id, mensagem)
  VALUES (1, 'Pagamento atrasado')
  ''',
];

final insertMarcasVeiculo = [
  ''' INSERT INTO marca_veiculo (nome, site_oficial) VALUES ('Toyota', 'https://www.toyota.com') ''',
  ''' INSERT INTO marca_veiculo (nome, site_oficial) VALUES ('Honda', 'https://www.honda.com') ''',
  ''' INSERT INTO marca_veiculo (nome, site_oficial) VALUES ('Ford', 'https://www.ford.com') ''',
];

final insertFornecedores = [
  ''' INSERT INTO fornecedor (nome, cpf, telefone, email, data_cadastro) VALUES ('Auto Peças Silva', '111.222.333-44', '(11) 99876-5432', 'auto.pecas@email.com', '2025-03-10T00:00:00.000') ''',
  ''' INSERT INTO fornecedor (nome, cpf, telefone, email, data_cadastro) VALUES ('Distribuidora Santos', '555.666.777-88', '(21) 91234-5678', 'dist.santos@email.com', '2025-04-15T00:00:00.000') ''',
];

final insertPecas = [
  ''' INSERT INTO peca (nome, marca_id, preco_unitario, quantidade) VALUES ('Filtro de Óleo', 1, 50.0, 10) ''',
  ''' INSERT INTO peca (nome, marca_id, preco_unitario, quantidade) VALUES ('Pastilha de Freio', 2, 120.0, 5) ''',
];

final insertVendaPeca = [
  ''' INSERT INTO venda_peca (venda_id, peca_id) VALUES (1, 1) ''',
];

final insertRevisoes = [
  ''' INSERT INTO revisao (tipo, oficina) VALUES ('Motor', 'Oficina Central') ''',
  ''' INSERT INTO revisao (tipo, oficina) VALUES ('Funilaria', 'Oficina Norte') ''',
];

final insertAgendamentosRevisao = [
  ''' INSERT INTO agendamento_revisao (carro_id, revisao_id, data, descricao) VALUES (2, 1, '2025-05-10T00:00:00.000', 'Revisão programada para o Honda Civic') ''',
];
