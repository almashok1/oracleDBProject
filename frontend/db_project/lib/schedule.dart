import 'dart:convert';
import 'dart:ui';

import 'package:db_project/connection.dart';
import 'package:db_project/schedule_tab.dart';
import 'package:db_project/styles.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Schedule extends StatefulWidget {
  @override
  _ScheduleState createState() => _ScheduleState();
}

class _ScheduleState extends State<Schedule> {
  TextStyle _textStyle(color, size) =>
      TextStyle(fontSize: size, color: color, fontWeight: FontWeight.w500);
  @override
  Widget build(BuildContext context) {
    return Container(
        color: Theme.of(context).accentColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            FlatButton(
                onPressed: () {
                  showBottomModalS(true);
                },
                child: Container(
                  height: 150,
                  child: Center(
                      child: Text(
                    'Student Schedule',
                    style: _textStyle(Colors.white, 24.0),
                  )),
                  decoration: decoration(Color(0xffff6363)),
                )),
            FlatButton(
                onPressed: () {
                  showBottomModalS(false);
                },
                child: Container(
                  height: 150,
                  child: Center(
                      child: Text(
                    'Teacher Schedule',
                    style: _textStyle(Colors.white, 24.0),
                  )),
                  decoration: decoration(Color(0xffff6363)),
                )),
          ],
        ));
  }

  Future<http.Response> fetchStudents(int year, int term) {
    return http.get(HOST + '/students/$year/$term');
  }
   Future<http.Response> fetchTeachers(int year, int term) {
    return http.get(HOST + '/teachers/$year/$term');
  }
  Future<http.Response> fetchScheduleEmp(int year, int term, int id) {
    return http.get(HOST + '/teachers/schedule/$year/$term/$id');
  }
  Future<http.Response> fetchScheduleStud(int year, int term, String id) {
    return http.get(HOST + '/students/schedule/$year/$term/$id');
  }


  void showBottomModalS(bool isStud) async {
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
                          var list;
                          if (isStud)
                            list =
                                await _listStudents(_term.round(), _year.round());
                          else 
                            list = await _listTeachers(_term.round(), _year.round());
                          Navigator.of(context).pop();
                          showDialog(
                              context: context,
                              builder: (context) => Center(
                                    child: Material(
                                        color: Theme.of(context).primaryColor,
                                        child: ListView.builder(
                                          itemCount: list.length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return FlatButton(
                                              child: Text(
                                                  list[index]
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
                                                _schedule(
                                                    _year.round(),
                                                    _term.round(),
                                                    list[index],);
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

  void _schedule(int year, int term, dynamic id) async {
    var response;
    if (id is String)
      response = await fetchScheduleStud(year, term, id);
    else if (id is int)
      response = await fetchScheduleEmp(year, term, id);
    
    final jsonParsed = json.decode(response.body);
    Navigator.of(context).pop();  
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ScheduleTab(jsonParsed, id)
    ));
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
  Future<List<int>> _listTeachers(term, year) async {
    final response = await fetchTeachers(year, term);
    final jsonParsed = json.decode(response.body);
    if (jsonParsed.length == 0) {
      return null;
    }
    var list = new List<int>();
    for (var i in jsonParsed) {
      list.add(i["EMP_ID"]);
    }
    return list;
  }
}