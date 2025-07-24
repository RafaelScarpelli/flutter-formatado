import 'package:flutter/material.dart';
import 'package:projeto_ddm/projeto/rotas.dart';

class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dashboard')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Visão Geral',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.directions_car,
                        color: Colors.green[600], size: 40),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Veículos Cadastrados',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        Text(
                          '25 veículos',
                          style: TextStyle(
                              color: Colors.orange[600], fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.attach_money,
                        color: Colors.green[600], size: 40),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Vendas Realizadas',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        Text(
                          '10 vendas',
                          style: TextStyle(
                              color: Colors.orange[600], fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today,
                        color: Colors.green[600], size: 40),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Aluguéis Ativos',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        Text(
                          '5 aluguéis',
                          style: TextStyle(
                              color: Colors.orange[600], fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.person, color: Colors.green[600], size: 40),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Clientes Cadastrados',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        Text(
                          '30 clientes',
                          style: TextStyle(
                              color: Colors.orange[600], fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, Rotas.menu),
              child: Text('Acessar Menu Principal'),
            ),
          ],
        ),
      ),
    );
  }
}
