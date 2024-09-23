// ignore_for_file: unused_local_variable, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:minhas_anotacoes/helpers/anotacao_helper.dart';
import 'package:minhas_anotacoes/models/anotacao.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  final _db = AnotacaoHelper();
  List<Anotacao> _anotacoes = [];

  _exibirTelaCadastro({Anotacao? anotacao}) {
    String textoSalvarAtualizar = '';

    if (anotacao == null) {
      _tituloController.text = '';
      _descricaoController.text = '';
      textoSalvarAtualizar = 'Salvar';
    } else {
      _tituloController.text = anotacao.titulo.toString();
      _descricaoController.text = anotacao.descricao.toString();
      textoSalvarAtualizar = 'Atualizar';
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('$textoSalvarAtualizar anotação'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _tituloController,
                autofocus: true,
                decoration: const InputDecoration(
                    label: Text('Título'), hintText: 'Digite um título'),
              ),
              TextField(
                onSubmitted: (value) {
                  Future.delayed(
                    Duration.zero,
                    () {
                      _salvarAtualizarAnotacao(anotacaoSelecionada: anotacao);
                      Navigator.pop(context);
                    },
                  );
                },
                controller: _descricaoController,
                decoration: const InputDecoration(
                    label: Text('Descrição'), hintText: 'Digite uma descrição'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('cancelar'),
            ),
            TextButton(
              onPressed: () {
                _salvarAtualizarAnotacao(anotacaoSelecionada: anotacao);
                Navigator.pop(context);
              },
              child: Text(textoSalvarAtualizar),
            ),
          ],
        );
      },
    );
  }

  _recuperarAnotacoes() async {
    List anotacoesRecuperadas = await _db.recuperarAnotacoes();

    List<Anotacao>? listaTemporaria = [];
    for (var item in anotacoesRecuperadas) {
      Anotacao anotacao = Anotacao.fromMap(item);
      listaTemporaria.add(anotacao);
    }

    setState(() {
      _anotacoes = listaTemporaria!;
    });
    listaTemporaria = null;

    //print('lista ${anotacoesRecuperadas.toString()}');
  }

  _salvarAtualizarAnotacao({Anotacao? anotacaoSelecionada}) async {
    String titulo = _tituloController.text;
    String descricao = _descricaoController.text;

    if (anotacaoSelecionada == null) {
      Anotacao anotacao =
          Anotacao(titulo, descricao, DateTime.now().toString());
      _db.salvarAnotacao(anotacao);
    } else {
      anotacaoSelecionada.titulo = titulo;
      anotacaoSelecionada.descricao = descricao;
      anotacaoSelecionada.data = DateTime.now().toString();
      int resultado = await _db.atualizarAnotacao(anotacaoSelecionada);
    }

    _tituloController.clear();
    _descricaoController.clear();

    _recuperarAnotacoes();
  }

  _excluirAnotacao(int id) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remover anotação'),
          content: const Text('Tem certeza que deseja remover essa anotação?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                _db.excluirAnotacao(id);
                Navigator.pop(context);

                var snackbar = const SnackBar(
                  duration: Duration(seconds: 2),
                  content: Text('Tarefa removida com sucesso!'),
                );
                ScaffoldMessenger.of(context).showSnackBar(snackbar);
              },
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    _recuperarAnotacoes();
  }

  _formatarData(String data) {
    initializeDateFormatting('pt_BR');

    var formater = DateFormat('dd/MM/yyyy - H:m');

    DateTime dataConvertida = DateTime.parse(data);
    String dataFormatada = formater.format(dataConvertida);

    return dataFormatada;
  }

  @override
  void initState() {
    super.initState();
    _recuperarAnotacoes();
  }

  @override
  Widget build(BuildContext context) {
    _recuperarAnotacoes();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anotações'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _anotacoes.length,
              itemBuilder: (context, index) {
                final anotacao = _anotacoes[index];
                return Card(
                  child: ListTile(
                    title: Text(anotacao.titulo.toString()),
                    subtitle: Text(
                        '${_formatarData(anotacao.data.toString())} - ${anotacao.descricao.toString()}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () {
                            _exibirTelaCadastro(anotacao: anotacao);
                          },
                          child: const Icon(
                            Icons.edit,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(width: 20),
                        GestureDetector(
                          onTap: () {
                            _excluirAnotacao(anotacao.id!);
                          },
                          child: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        onPressed: _exibirTelaCadastro,
        child: const Icon(Icons.add),
      ),
    );
  }
}
