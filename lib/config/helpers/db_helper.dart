import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../model/todo_model.dart';

class DBHelper {
  DBHelper._();

  static final DBHelper dbHelper = DBHelper._();

  static Database? database;

  //TODO:table componennts
  String table_name = 'todo';
  String id = 'id';
  String task = 'task';
  String description = 'description';
  String time = 'time';
  String date = 'date';
  String deleted = 'deleted';
  String checked = 'checked';

  initDB() async {
    String path = await getDatabasesPath();
    String db_path = join(path, 'demo.db');

    database = await openDatabase(
      db_path,
      version: 1,
      onCreate: (db, version) {
        String query =
            "CREATE TABLE IF NOT EXISTS $table_name($id INTEGER PRIMARY KEY AUTOINCREMENT,$task TEXT,$description TEXT,$time TEXT,$date TEXT,$checked INTEGER DEFAULT 0);";
        db.execute(query);
      },
    );
  }

  Future<int?> insertTodo({required TODO todo}) async {
    await initDB();
    String query =
        "INSERT INTO $table_name($task,$description,$date,$time,$checked) VALUES(?,?,?,?,?);";
    List args = [
      todo.task,
      todo.description,
      todo.date,
      todo.time,
      todo.checked
    ];
    int? res = await database?.rawInsert(query, args);
    return res;
  }

  Future<List<TODO>?> fetchTask() async {
    await initDB();
    // String query = "SELECT * FROM $table_name WHERE $deleted = 0;";
    String query = "SELECT * FROM $table_name;";
    var list = await database?.rawQuery(query);
    List<TODO>? todo = list?.map((e) => TODO.fromDB(data: e)).toList();
    return todo;
  }

  Future<int?> deleteTask({required int d_id}) async {
    await initDB();
    // Instead of deleting, mark the task as deleted
    String query = "DELETE FROM $table_name WHERE $id = ?;";
    // String query = "UPDATE $table_name SET $deleted = 1 WHERE $id = ?;";
    List args = [d_id];
    return await database?.rawUpdate(query, args);
  }

  Future<int?> updateTodo({required TODO todo, required int u_id}) async {
    await initDB();
    String query =
        "UPDATE $table_name SET $task=?,$description=?,$time=?,$date=?,$checked=? WHERE $id=?;";
    List args = [
      todo.task,
      todo.description,
      todo.time,
      todo.date,
      todo.checked,
      u_id
    ];
    int? res = await database?.rawUpdate(query, args);
    return res;
  }

  Future<String> getDatabasePath() async {
    String path = await getDatabasesPath();
    return join(path, 'demo.db');
  }
}
