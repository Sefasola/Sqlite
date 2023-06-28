
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqlite_kullanimi_youtube/utils/database_helper.dart';

import '../models/note.dart';


class NoteDetail extends StatefulWidget {
    late String appBartitle;
    final Note note;


    NoteDetail(this.note,this.appBartitle);

  @override
  State<StatefulWidget> createState() {
    return NoteDetailState(this.note ,this.appBartitle);
  }
}

class NoteDetailState extends State<NoteDetail> {
  static var _priorities = ["Hight", "Low"];

  DatabaseHelper helper = DatabaseHelper();
  String appBartitle;
  Note note;
  NoteDetailState(this.note,this.appBartitle);

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();


  @override
  Widget build(BuildContext context) {

    titleController.text = note.title;
    descriptionController.text = note.description;
    return WillPopScope(
      onWillPop: () async{
        MoveToLastScreen();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(appBartitle),
          leading: IconButton(icon: Icon(Icons.arrow_back),
          onPressed: (){
            MoveToLastScreen();
          },
          ),
        ),

        body: Padding(
          padding: const EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
          child: ListView(
            children: [
              ListTile(
                title: DropdownButton(
                  items: _priorities.map((String droDownStringItem) {
                    return DropdownMenuItem<String> (
                      value: droDownStringItem,
                      child: Text(droDownStringItem),
                    );
                  }).toList(),

                  value: getPriorityAsString(note.priority),
                  onChanged: (valueSelectedByUser){
                    setState(() {
                      debugPrint('User selected $valueSelectedByUser');
                      updatePriorityAsInt(valueSelectedByUser!);
                    });
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
                child: TextField(
                  controller: titleController,
                  onChanged: (value){
                    debugPrint("something changed in title text field");
                    updateTitle();
                  },
                  decoration: InputDecoration(
                    labelText: "Title",
                   border: OutlineInputBorder(
                     borderRadius: BorderRadius.circular(5.0),
                   )
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
                child: TextField(
                  controller: descriptionController,
                  onChanged: (value){
                    debugPrint("something changed in description text field");
                    updateDescription();
                  },
                  decoration: InputDecoration(
                      labelText: "Description",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0)
                      )
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
                child: Row(
                  children: [
                    Expanded(child: ElevatedButton(
                     child: Text(
                       "Save",
                       textScaleFactor: 1.5,
                     ),
                      onPressed: () {
                       setState(() {
                         debugPrint("Save button Clicked");
                         _save();
                       });
                      },
                    )
                    ),

                    Container(width: 5.0),

                    Expanded(child: ElevatedButton(
                      child: Text(
                        "Delete",
                        textScaleFactor: 1.5,
                      ),
                      onPressed: () {
                        setState(() {
                          debugPrint("Delete button Clicked");
                          _delete();
                        });
                      },
                    )
                    )


                  ],

                ),
              ),

            ],

          ),
        ),

      ),
    );
  }

  void MoveToLastScreen(){
    Navigator.pop(context, true);
  }

  //convert the string priority in the form of integer before saving it to database
  void updatePriorityAsInt(String value){
    switch(value) {
      case 'High':
        note.priority = 1;
        break;
      case 'Low':
        note.priority = 2;
        break;
    }
  }
  //convert int priority to string priority and display it to user dropdown

  String getPriorityAsString(int value) {
    late String priority;
    switch (value) {
      case 1:
        priority = _priorities[0]; // high
        break;
      case 2:
        priority = _priorities[2]; // low
        break;
      default:
        priority = ''; // handle other cases if needed
    }
    return priority;
  }

  //update the title of note object
void updateTitle(){
    note.title= titleController.text;
}
//update the description of Note object
void updateDescription(){
 note.description = descriptionController.text;
}

//save data to database
  void _save() async {
    MoveToLastScreen();

    note.date = DateFormat.yMMMd().format(DateTime.now());

    int? result = 0; // Initialize the 'result' variable

    if (note.id != null) { // Case 1: Update operation
      result = (await helper.updateNote(note))!;
    } else { // Case 2: Insert operation
      result = await helper.insertNote(note);
    }

    if (result != 0) {
      _showAlterDialog('Status', 'Note saved successfully');
    } else {
      _showAlterDialog('Status', 'Problem saving note');
    }
  }

  void _delete() async {
    MoveToLastScreen();
    //case1 if user is trying to delete the New note he has come to
    //the detail page by pressing the FAB of notelist page
    if(note.id == null){
      _showAlterDialog('Status', 'No note was deleted');
      return ;
    }

    //case2 user is trying to delete old note that already has a valid ID
    int result = await helper.deleteNote(note.id);
    if(result != 0){
      _showAlterDialog('Status', 'note deleted succesfuly');
    }else{
      _showAlterDialog('Status', 'Error ocured while deleting node');
    }

  }


  void _showAlterDialog(String title, String message){

    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(context: context, builder: (_) => alertDialog);
 }

}

