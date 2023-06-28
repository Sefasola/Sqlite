class Note {
  int _id;
  String _title;
  String _description;
  String _date;
  int _priority;

  Note( this._id, this._title, this._description, this._date, this._priority);

  Note.withId(this._id, this._title, this._description, this._date, this._priority);

  int get priority => _priority;

  String get date => _date;

  String get description => _description;

  String get title => _title;

  int get id => _id;


  set priority(int value) {
    if(value >= 1 && value <= 2 ){
      _priority = value;
    }

  }

  set date(String value) {
    _date = value;
  }

  set description(String value) {
    if(value.length <= 255 ){
      _description = value;
    }

  }

  set title(String value) {
    if(value.length <= 255 ){
      _title = value;
    }
  }

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    if(id != null){
      map['id'] = _id;
    }
    map['title'] = _title;
    map['description'] = _description;
    map['priority'] = _priority;
    map['date'] = _date;

    return map;
  }

  Note.fromMapObject(Map<String, dynamic> map):
        _id = map['id'],
        _title = map['title'],
        _description = map['description'],
        _priority = map['priority'],
        _date = map['date'];
}
