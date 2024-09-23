import 'package:minhas_anotacoes/models/anotacao.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AnotacaoHelper {
  static const String nomeTabela = 'anotacao';
  static final AnotacaoHelper _anotacaoHelper = AnotacaoHelper._internal();
  Database? _db;

  factory AnotacaoHelper() {
    return _anotacaoHelper;
  }

  AnotacaoHelper._internal();

  get db async {
    if (_db != null) {
      return _db;
    } else {
      _db = await inicializadorDB();
      return _db;
    }
  }

  _onCreate(Database db, int version) async {
    String sql =
        'CREATE TABLE anotacao (id INTEGER PRIMARY KEY AUTOINCREMENT, titulo VARCHAR, descricao TEXT, data DATETIME)';
    await db.execute(sql);
  }

  inicializadorDB() async {
    final caminhoBancoDeDados = await getDatabasesPath();
    final localBancoDeDados =
        join(caminhoBancoDeDados, 'banco_minhas_anotacoes.db');

    var db =
        await openDatabase(localBancoDeDados, version: 1, onCreate: _onCreate);
    return db;
  }

  Future<int> salvarAnotacao(Anotacao anotacao) async {
    var bancoDeDados = await db;

    int resultado = await bancoDeDados.insert(nomeTabela, anotacao.toMap());

    return resultado;
  }

  recuperarAnotacoes() async {
    var bancoDeDados = await db;
    String sql = 'SELECT * FROM $nomeTabela ORDER BY data DESC';
    List anotacoes = await bancoDeDados.rawQuery(sql);
    return anotacoes;
  }

  Future<int> atualizarAnotacao(Anotacao anotacao) async {
    var bancoDeDados = await db;
    return await bancoDeDados.update(
      nomeTabela,
      anotacao.toMap(),
      where: 'id = ?',
      whereArgs: [anotacao.id],
    );
  }

  Future<int> excluirAnotacao(int id) async {
    var bancoDeDados = await db;
    return await bancoDeDados.delete(
      nomeTabela,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
