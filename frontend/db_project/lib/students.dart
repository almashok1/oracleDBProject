import 'dart:convert';
import 'dart:ui';

import 'package:db_project/connection.dart';
import 'package:db_project/styles.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Students extends StatefulWidget {
  @override
  _StudentsState createState() => _StudentsState();
}

class _StudentsState extends State<Students> {
  TextStyle _textStyle(color, size) =>
      TextStyle(fontSize: size, color: color, fontWeight: FontWeight.w500);
  @override
  Widget build(BuildContext context) {
    return Container(
        color: Theme.of(context).accentColor,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              FlatButton(
                  onPressed: () {
                    showBottomModalNR();
                  },
                  child: Container(
                    height: 150,
                    child: Center(
                        child: Text(
                      'Students who didn\'t regitered',
                      style: _textStyle(Colors.white, 24.0),
                    )),
                    decoration: decoration(Color(0xffff6363)),
                  )),
              FlatButton(
                  onPressed: () {
                    showBottomModalGPA('total');
                  },
                  child: Container(
                    height: 150,
                    child: Center(
                        child: Text(
                      'GPA Total',
                      style: _textStyle(Colors.white, 24.0),
                    )),
                    decoration: decoration(Color(0xffff6363)),
                  )),
              FlatButton(
                  onPressed: () {
                    showBottomModalGPA('term');
                  },
                  child: Container(
                    height: 150,
                    child: Center(
                        child: Text(
                      'GPA for Semester',
                      style: _textStyle(Colors.white, 24.0),
                    )),
                    decoration: decoration(Color(0xffff6363)),
                  )),
              FlatButton(
                  onPressed: () {
                    showBottomModalRetake('total');
                  },
                  child: Container(
                    height: 150,
                    child: Center(
                        child: Text(
                      'Spent Money for Retake Total',
                      textAlign: TextAlign.center,
                      style: _textStyle(Colors.white, 24.0),
                    )),
                    decoration: decoration(Color(0xffff6363)),
                  )),
              FlatButton(
                  onPressed: () {
                    showBottomModalRetake('term');
                  },
                  child: Container(
                    height: 150,
                    child: Center(
                        child: Text(
                      'Spent Money for Retake for Semester',
                      textAlign: TextAlign.center,
                      style: _textStyle(Colors.white, 24.0),
                    )),
                    decoration: decoration(Color(0xffff6363)),
                  )),
            ],
          ),
        ));
  }

  Future<http.Response> fetchGPA(
      int year, int term, String studId, String type) {
    if (type == 'total') return http.get(HOST + '/gpa/$studId');
    return http.get(HOST + '/gpa/$year/$term/$studId');
  }

  Future<http.Response> fetchRetakes(
      int year, int term, String studId, String type) {
    if (type == 'total') return http.get(HOST + '/students/retake/$studId');
    return http.get(HOST + '/students/retake/$year/$term');
  }

  Future<http.Response> fetchStudents(int year, int term) {
    return http.get(HOST + '/students/$year/$term');
  }

  Future<http.Response> fetchNRStud(int year, int term) {
    return http.get(HOST + '/students/NR/$year/$term');
  }

  void showBottomModalNR() async {
    double _term = 1;
    double _year = 2016;
    showModalBottomSheet(
        clipBehavior: Clip.hardEdge,
        shape: shapeBorder(50.0, false),
        context: context,
        builder: (insideContext) =>
            StatefulBuilder(builder: (context, setState) {
              return Container(
                color: Theme.of(context).primaryColor,
                padding: EdgeInsets.all(15.0),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          Text(
                            'TERM',
                            style: _textStyle(Color(0xffffbd69), 18.0),
                          ),
                          Slider.adaptive(
                            inactiveColor: Color(0xffffbd69),
                            activeColor: Color(0xffff6363),
                            label: _term.round().toString(),
                            value: _term,
                            min: 1,
                            max: 3,
                            divisions: 2,
                            onChanged: (value) {
                              setState(() {
                                _term = value;
                              });
                            },
                          )
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            'YEAR',
                            style: _textStyle(Color(0xffffbd69), 18.0),
                          ),
                          Slider.adaptive(
                            inactiveColor: Color(0xffffbd69),
                            activeColor: Color(0xffff6363),
                            label: _year.round().toString(),
                            value: _year,
                            min: 2016,
                            max: 2019,
                            divisions: 3,
                            onChanged: (value) {
                              setState(() {
                                _year = value;
                              });
                            },
                          )
                        ],
                      ),
                      FlatButton(
                        shape: shapeBorder(15.0),
                        onPressed: () async {
                          showDialog(
                              context: context,
                              builder: (context) =>
                                  Center(child: CircularProgressIndicator()));
                          _listNRStud(_year.round(), _term.round());
                        },
                        child: Container(
                            padding: EdgeInsets.all(17.0),
                            child: Text(
                              'NEXT',
                              style: _textStyle(Colors.white, 20.0),
                            )),
                      )
                    ],
                  ),
                ),
              );
            }));
  }

  void showBottomModalGPA(String type) async {
    double _term = 1;
    double _year = 2016;
    showModalBottomSheet(
        clipBehavior: Clip.hardEdge,
        shape: shapeBorder(50.0, false),
        context: context,
        builder: (insideContext) =>
            StatefulBuilder(builder: (context, setState) {
              return Container(
                color: Theme.of(context).primaryColor,
                padding: EdgeInsets.all(15.0),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          Text(
                            'TERM',
                            style: _textStyle(Color(0xffffbd69), 18.0),
                          ),
                          Slider.adaptive(
                            inactiveColor: Color(0xffffbd69),
                            activeColor: Color(0xffff6363),
                            label: _term.round().toString(),
                            value: _term,
                            min: 1,
                            max: 3,
                            divisions: 2,
                            onChanged: (value) {
                              setState(() {
                                _term = value;
                              });
                            },
                          )
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            'YEAR',
                            style: _textStyle(Color(0xffffbd69), 18.0),
                          ),
                          Slider.adaptive(
                            inactiveColor: Color(0xffffbd69),
                            activeColor: Color(0xffff6363),
                            label: _year.round().toString(),
                            value: _year,
                            min: 2016,
                            max: 2019,
                            divisions: 3,
                            onChanged: (value) {
                              setState(() {
                                _year = value;
                              });
                            },
                          )
                        ],
                      ),
                      FlatButton(
                        shape: shapeBorder(15.0),
                        onPressed: () async {
                          showDialog(
                              context: context,
                              builder: (context) =>
                                  Center(child: CircularProgressIndicator()));
                          var listStudents =
                              await _listStudents(_term.round(), _year.round());
                          Navigator.of(context).pop();
                          showDialog(
                              context: context,
                              builder: (context) => Center(
                                    child: Material(
                                        color: Theme.of(context).primaryColor,
                                        child: ListView.builder(
                                          itemCount: listStudents.length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return FlatButton(
                                              child: Text(
                                                  listStudents[index]
                                                      .toString(),
                                                  style: TextStyle(
                                                      fontSize: 18.0,
                                                      color: Colors.white)),
                                              onPressed: () async {
                                                Navigator.of(context).pop();
                                                showDialog(
                                                    context: context,
                                                    builder: (context) => Center(
                                                        child:
                                                            CircularProgressIndicator()));
                                                _gpaDialog(
                                                    _year.round(),
                                                    _term.round(),
                                                    listStudents[index],
                                                    type);
                                              },
                                            );
                                          },
                                        )),
                                  ));
                        },
                        child: Container(
                            padding: EdgeInsets.all(17.0),
                            child: Text(
                              'NEXT',
                              style: _textStyle(Colors.white, 20.0),
                            )),
                      )
                    ],
                  ),
                ),
              );
            }));
  }

  void showBottomModalRetake(String type) async {
    double _term = 1;
    double _year = 2016;
    showModalBottomSheet(
        clipBehavior: Clip.hardEdge,
        shape: shapeBorder(50.0, false),
        context: context,
        builder: (insideContext) =>
            StatefulBuilder(builder: (context, setState) {
              return Container(
                color: Theme.of(context).primaryColor,
                padding: EdgeInsets.all(15.0),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          Text(
                            'TERM',
                            style: _textStyle(Color(0xffffbd69), 18.0),
                          ),
                          Slider.adaptive(
                            inactiveColor: Color(0xffffbd69),
                            activeColor: Color(0xffff6363),
                            label: _term.round().toString(),
                            value: _term,
                            min: 1,
                            max: 3,
                            divisions: 2,
                            onChanged: (value) {
                              setState(() {
                                _term = value;
                              });
                            },
                          )
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            'YEAR',
                            style: _textStyle(Color(0xffffbd69), 18.0),
                          ),
                          Slider.adaptive(
                            inactiveColor: Color(0xffffbd69),
                            activeColor: Color(0xffff6363),
                            label: _year.round().toString(),
                            value: _year,
                            min: 2016,
                            max: 2019,
                            divisions: 3,
                            onChanged: (value) {
                              setState(() {
                                _year = value;
                              });
                            },
                          )
                        ],
                      ),
                      FlatButton(
                        shape: shapeBorder(15.0),
                        onPressed: () async {
                          showDialog(
                              context: context,
                              builder: (context) =>
                                  Center(child: CircularProgressIndicator()));
                          var listStudents =
                              await _listStudents(_term.round(), _year.round());
                          Navigator.of(context).pop();
                          showDialog(
                              context: context,
                              builder: (context) => Center(
                                    child: Material(
                                        color: Theme.of(context).primaryColor,
                                        child: ListView.builder(
                                          itemCount: listStudents.length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return FlatButton(
                                              child: Text(
                                                  listStudents[index]
                                                      .toString(),
                                                  style: TextStyle(
                                                      fontSize: 18.0,
                                                      color: Colors.white)),
                                              onPressed: () async {
                                                Navigator.of(context).pop();
                                                showDialog(
                                                    context: context,
                                                    builder: (context) => Center(
                                                        child:
                                                            CircularProgressIndicator()));
                                                _retakeDialog(
                                                    _year.round(),
                                                    _term.round(),
                                                    listStudents[index],
                                                    type);
                                              },
                                            );
                                          },
                                        )),
                                  ));
                        },
                        child: Container(
                            padding: EdgeInsets.all(17.0),
                            child: Text(
                              'NEXT',
                              style: _textStyle(Colors.white, 20.0),
                            )),
                      )
                    ],
                  ),
                ),
              );
            }));
  }

  Future<List<String>> _listStudents(term, year) async {
    final response = await fetchStudents(year, term);
    final jsonParsed = json.decode(response.body);
    if (jsonParsed.length == 0) {
      return null;
    }
    var list = new List<String>();
    for (var i in jsonParsed) {
      list.add(i["STUD_ID"]);
    }
    return list;
  }

  Future<void> _listNRStud(int year, int term) async {
    final response = await fetchNRStud(year.toInt(), term.toInt());

    final jsonParsed = json.decode(response.body);
    if (jsonParsed.length == 0) {
      Navigator.of(context).pop();
      showDialog(
          context: context,
          builder: (context) => Material(
              child: Center(
                  child: Container(
                      color: Theme.of(context).primaryColor,
                      child: Text("Nothing found",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 30.0,
                              fontWeight: FontWeight.w500))))));
      return;
    }
    Navigator.of(context).pop();
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: Text('Students Not Reg - $year, $term term'),
        ),
        body: Container(
          color: Theme.of(context).accentColor,
          child: ListView.builder(
            itemCount: jsonParsed.length,
            itemBuilder: (BuildContext context, int index) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Color(0xffffbd69)),
                        borderRadius: BorderRadius.circular(10.0)),
                    padding:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                    child: Text(
                      (index + 1).toString() +
                          ') ' +
                          jsonParsed[index]['STUD_ID'],
                      style: _textStyle(Colors.white, 18.0),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    ));
  }

  Future<void> _gpaDialog(
      int year, int term, String studId, String type) async {
    final response = await fetchGPA(year, term, studId, type);

    double gpa = json.decode(response.body)['res'] as double;

    Navigator.of(context).pop();
    showDialog(
      context: context,
      builder: (context) => Material(
        type: MaterialType.transparency,
        child: Container(
          height: 100,
          child: Center(
            child: Container(
              decoration: decoration(Color(0xffffbd30)),
              child: Center(
                  child: Text(
                'GPA - ${gpa.toStringAsPrecision(3)}',
                style: TextStyle(fontSize: 36.0, fontWeight: FontWeight.w500),
              )),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _retakeDialog(
      int year, int term, String studId, String type) async {
    final response = await fetchRetakes(year, term, studId, type);

    int money = json.decode(response.body)['res'];

    Navigator.of(context).pop();
    showDialog(
      context: context,
      builder: (context) => Material(
        type: MaterialType.transparency,
        child: Container(
          height: 100,
          child: Center(
            child: Container(
              decoration: decoration(Color(0xffffbd30)),
              child: Center(
                  child: Text(
                'Spent Money - $money KZT',
                style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.w500),
              )),
            ),
          ),
        ),
      ),
    );
  }
}
