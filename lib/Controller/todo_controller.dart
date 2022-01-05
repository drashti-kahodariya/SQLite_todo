import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqlite_todo/Helpers/constant.dart';
import 'package:sqlite_todo/Model/todoModel.dart';

class TodoController extends GetxController {
  var todoList = <TodoModel>[].obs;

  Future<void> createDatabase() async {
    String path = join(await getDatabasesPath(), databaseName);
    await openDatabase(path, version: version,
        onCreate: (Database db, int version) async {
      printInfo(info: "db:" + db.toString());
      await db.execute("CREATE TABLE $tblName ("
          "$columnId TEXT PRIMARY KEY,"
          "$columnTitle TEXT NOT NULL,"
          "$columnDescription TEXT NOT NULL,"
          "$columnDate TEXT NOT NULL"
          ")");
    });
    getTodo();
  }

  void addData(
      {required String description,
      required String date,
      required String title}) {
    var todo = TodoModel(
        id: (todoList.length + 1).toString(),
        title: title,
        description: description,
        date: date);
    insertData(todo);
  }

  Future<void> insertData(TodoModel todo) async {
    String path = join(await getDatabasesPath(), databaseName);
    final db = await openDatabase(path);

    await db.insert(tblName, todo.toJson());
    print(todo.toJson());
    getTodo();
  }

  Future<void> getTodo() async {
    todoList.clear();
    String path = join(await getDatabasesPath(), databaseName);
    final db = await openDatabase(path, version: version);

    final List<Map<String, dynamic>> maps = await db.query(tblName);
    todoList.addAll(maps.map((e) => TodoModel.fromJson(e)).toList());
  }

  delete({String? id}) async {
    String path = join(await getDatabasesPath(), databaseName);
    final db = await openDatabase(path, version: version);
    getTodo();
    return await db.delete(tblName, where: '$columnId = ?', whereArgs: [id]);
  }

  updateTodo(TodoModel todo) async {
    print(todo.id);
    String path = join(await getDatabasesPath(), databaseName);
    final db = await openDatabase(path);
    await db.update(
      tblName,
      todo.toJson(),
      where: 'id = ?',
      whereArgs: [todo.id],
    );
    getTodo();
    return todo;
  }
}
