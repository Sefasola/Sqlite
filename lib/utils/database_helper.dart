import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite_kullanimi_youtube/models/note.dart';


class DatabaseHelper{
   static DatabaseHelper? _databaseHelper ;
   static Database? _database ;

   String  noteTable = 'note_table';
   String colId = 'id';
   String colTitle = 'title';
   String colDescription = 'priority';
   String colPriority = 'priority';
   String colDate = 'date';

   DatabaseHelper._creteInstance();

  factory DatabaseHelper() {
    if(_databaseHelper == null){
      _databaseHelper = DatabaseHelper._creteInstance();
    }
    return _databaseHelper!;
  }

  Future<Database?> get database async{
    if(_database == null) {
      _database = await initiaDatabase();
    }
    return _database;
  }

 Future<Database> initiaDatabase() async {
    //get the directory path for both android and İOS to store database
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'notes.db';

    //open create the databse at a given path
    var notesDatabase = await openDatabase(path, version: 1, onCreate: _createDb);
    return notesDatabase;
  }

  void _createDb(Database db, int newVersion) async{
    await db.execute('CREATE TABLE $noteTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, '
        '$colDescription TEXT, $colPriority INTEGER, $colDate TEXT)');
  }

  //Fetch operation get all note objects from database
    Future<List<Map<String, Object?>>?> getNoteMapList() async {
    Database? db = await this.database;

    var result = await db?.rawQuery("SELECT * FROM $noteTable order by $colPriority ASC");
    return result;
    }

    //Insert operation: Insert a note object to database
    Future<int?> insertNote(Note note) async{
    Database? db = await this.database;
    var result = await db?.insert(noteTable, note.toMap());
    return result;
    }

    //update operation update a note object and save it to database
   Future<int?>  updateNote(Note note) async {
    var db = await this.database;
    var result = await db?.update(noteTable, note.toMap(), where: '$colId = ?', whereArgs: [note.id]);
    return result;
   }
    //get number of Note objwcts in database
   Future<int?> getCount() async {
    Database? db = await this.database;
    List<Map<String, dynamic>>  x = await db!.rawQuery('SELECT COUNT (*) from $noteTable');
    int? result = Sqflite.firstIntValue(x);
    return result;
   }
   //delete operation delete a object from database
   Future<int>  deleteNote(int id) async{
    var db = await this.database;
    int result = await db!.rawDelete('DELETE FROM $noteTable WHERE $colId = $noteTable.id');
    return result;

   }

   //get the map list [list<Map>] and convert it to 'NoteList' [List<Note>]

    Future<List<Note>> getNoteList() async{

    var noteMapList = await getNoteMapList(); //get map list from database
      int count = noteMapList!.length;     //count the number of map entries in db table

      List<Note> noteList = <Note>[];
      //for loop create a note list from a map list

      for(int i=0; i<count; i++){
        noteList.add(Note.fromMapObject(noteMapList[i]));
      }

      return noteList;
    }


}




