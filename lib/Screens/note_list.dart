import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sqlite_kullanimi_youtube/Screens/note_detail.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqlite_kullanimi_youtube/utils/database_helper.dart';

import '../models/note.dart';

class NoteList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return NoteListState();
  }
}

class NoteListState extends State<NoteList> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Note> noteList = [];
  int count = 0;

  @override
  Widget build(BuildContext context) {
    if (noteList.isEmpty) {
      updateListView();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("Notes"),
      ),
      body: getNoteListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          debugPrint("Fab clicked");
          navigateToDetail(Note(0, '', '', '', 1), "Add note");
        },
        tooltip: "Add Note",
        child: Icon(Icons.add),
      ),
    );
  }

  ListView getNoteListView() {
    TextTheme titleStyle = Theme.of(context).textTheme;

    return ListView.builder(
      itemCount: count,
      itemBuilder: (BuildContext context, int index) {
        return Card(
          color: Colors.white,
          elevation: 2.0,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: getPriorityColor(noteList[index].priority),
              child: getPriorityIcon(noteList[index].priority),
            ),
            title: Text(
              noteList[index].title,
              style: TextStyle(fontSize: 10),
            ),
            subtitle: Text(noteList[index].date),
            trailing: GestureDetector(
              child: Icon(
                Icons.delete,
                color: Colors.grey,
              ),
              onTap: () {
                _delete(context, noteList[index]);
              },
            ),
            onTap: () {
              debugPrint("ListTile Tapped");
              navigateToDetail(this.noteList[index],"Edit note");
            },
          ),
        );
      },
    );
  }

  Color getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.red;
      case 3:
        return Colors.yellow;
      default:
        return Colors.yellow;
    }
  }

  Icon getPriorityIcon(int priority) {
    switch (priority) {
      case 1:
        return Icon(Icons.play_arrow);
      case 2:
        return Icon(Icons.keyboard_arrow_right);
      default:
        return Icon(Icons.keyboard_arrow_right);
    }
  }

  Future<void> _delete(BuildContext context, Note note) async {
    int result = await databaseHelper.deleteNote(note.id);
    if (result != 0) {
      _showSnackBar(context, "Note deleted successfully");
      updateListView();
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  void navigateToDetail(Note note,String title) async {
  bool result = await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return NoteDetail(note ,title);
    }));

    if(result == true){
      updateListView();
    }
  }

  void updateListView() async {
    final Database database = await databaseHelper.initiaDatabase();
    List<Note> noteList = await databaseHelper.getNoteList();
    setState(() {
      this.noteList = noteList;
      this.count = noteList.length;
    });
  }
}
