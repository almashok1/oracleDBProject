import 'dart:convert';
import 'dart:ui';

import 'package:db_project/connection.dart';
import 'package:db_project/styles.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Teachers extends StatefulWidget {
  @override
  _TeachersState createState() => _TeachersState();
}

class _TeachersState extends State<Teachers> {
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
                  showBottomModalT();
                },
                child: Container(
                  height: 150,
                  child: Center(
                      child: Text(
                    'Popular Teachers',
                    style: _textStyle(Colors.white, 24.0),
                  )),
                  decoration: decoration(Color(0xffff6363)),
                )),
            FlatButton(
                onPressed: () {
                  showBottomModalT2();
                },
                child: Container(
                  height: 150,
                  child: Center(
                      child: Text(
                    'Teachers Loading..',
                    style: _textStyle(Colors.white, 24.0),
                  )),
                  decoration: decoration(Color(0xffff6363)),
                )),
            FlatButton(
                onPressed: () {
                  showBottomModalT3();
                },
                child: Container(
                  height: 150,
                  child: Center(
                      child: Text(
                    'Most Clever Flow',
                    style: _textStyle(Colors.white, 24.0),
                  )),
                  decoration: decoration(Color(0xffff6363)),
                )),
          ],
        ));
  }

  Future<http.Response> fetchPopularTeachers(
      int year, int term, String type, String dersKod) {
    return http.get(HOST + '/popular-teachers/$type/$year/$term/$dersKod');
  }

  Future<http.Response> fetchDersKod(int year, int term, String type) {
    return http.get(HOST + '/courses/$year/$term/$type');
  }

  Future<http.Response> fetchDersKodAll(int year, int term) {
    return http.get(HOST + '/courses/$year/$term');
  }

  Future<http.Response> fetchTeachers(int year, int term) {
    return http.get(HOST + '/teachers/$year/$term');
  }

  Future<http.Response> fetchTeachersDers(int year, int term, String ders) {
    return http.get(HOST + '/teachers/$ders/$year/$term');
  }

  Future<http.Response> fetchTeachersLoading(int year, int term, int empId) {
    return http.get(HOST + '/teachers/loading/$year/$term/$empId');
  }

  Future<http.Response> fetchMostCleverFlow(
      int year, int term, String ders, int empId) {
    return http.get(HOST + '/teachers/clever-flow/$ders/$year/$term/$empId');
  }

  void showBottomModalT() async {
    double _term = 1;
    double _year = 2016;
    String _type = 'lection';
    List<String> listCourses = [];
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
                      Container(
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            FlatButton(
                                onPressed: () {
                                  setState(() {
                                    _type = "lection";
                                  });
                                },
                                child: Text("Lecture",
                                    style: TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.w500,
                                        color: _type == 'lection'
                                            ? Color(0xffffbd69)
                                            : Colors.white))),
                            FlatButton(
                                onPressed: () {
                                  setState(() {
                                    _type = "practice";
                                  });
                                },
                                child: Text("Practice",
                                    style: TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.w500,
                                        color: _type == 'practice'
                                            ? Color(0xffffbd69)
                                            : Colors.white)))
                          ],
                        ),
                      ),
                      FlatButton(
                        shape: shapeBorder(15.0),
                        onPressed: () async {
                          showDialog(
                              context: context,
                              builder: (context) =>
                                  Center(child: CircularProgressIndicator()));
                          listCourses = await _listCourses(
                              _term.round(), _year.round(), _type);
                          Navigator.of(context).pop();
                          
                          setState(() {});
                          showDialog(
                              context: context,
                              builder: (context) => Center(
                                    child: Material(
                                        color: Theme.of(context).primaryColor,
                                        child: ListView(
                                          children: listCourses
                                              .map((e) => FlatButton(
                                                    child: Text(e,
                                                        style: TextStyle(
                                                            fontSize: 18.0,
                                                            color:
                                                                Colors.white)),
                                                    onPressed: () async {
                                                      Navigator.of(context)
                                                          .pop();
                                                      showDialog(
                                                          context: context,
                                                          builder: (context) =>
                                                              Center(
                                                                  child:
                                                                      CircularProgressIndicator()));
                                                      await _listTeachers(
                                                          _year.round(),
                                                          _term.round(),
                                                          _type,
                                                          e);
                                                    },
                                                  ))
                                              .toList(),
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

  void showBottomModalT2() async {
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
                          var listTeachers = await _listTeachersLoading(
                              _term.round(), _year.round());
                          Navigator.of(context).pop();
                          setState(() {});
                          showDialog(
                              context: context,
                              builder: (context) => Center(
                                    child: Material(
                                        color: Theme.of(context).primaryColor,
                                        child: ListView.builder(
                                          itemCount: listTeachers.length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return FlatButton(
                                              child: Text(
                                                  listTeachers[index]
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
                                                await _listTeachersLoadingFinal(
                                                    _year.round(),
                                                    _term.round(),
                                                    listTeachers[index]);
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

  void showBottomModalT3() async {
    double _term = 1;
    double _year = 2016;
    showModalBottomSheet(
        clipBehavior: Clip.hardEdge,
        shape: shapeBorder(50.0, false),
        context: context,
        builder:
            (insideContext) => StatefulBuilder(builder: (context, setState) {
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
                              var listCourses = await _listCoursesAll(
                                  _term.round(), _year.round());
                          Navigator.of(context).pop();
                              Navigator.of(context).pop();

                              setState(() {});
                              showDialog(
                                  context: context,
                                  builder: (insideContext) => Center(
                                        child: Material(
                                            color:
                                                Theme.of(context).primaryColor,
                                            child: ListView.builder(
                                              itemCount: listCourses.length,
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int index) {
                                                return FlatButton(
                                                  child: Text(
                                                      listCourses[index],
                                                      style: TextStyle(
                                                          fontSize: 18.0,
                                                          color: Colors.white)),
                                                  onPressed: () async {
                                                    var listTeachers =
                                                        await _listTeachersDers(
                                                            _term.round(),
                                                            _year.round(),
                                                            listCourses[index]);
                                                    var ders =
                                                        listCourses[index];
                                                    Navigator.of(context).pop();

                                                    showDialog(
                                                        context: context,
                                                        builder:
                                                            (context) => Center(
                                                                  child: Material(
                                                                      color: Theme.of(context).primaryColor,
                                                                      child: ListView.builder(
                                                                        itemCount:
                                                                            listTeachers.length,
                                                                        itemBuilder:
                                                                            (BuildContext context,
                                                                                int i) {
                                                                          return FlatButton(
                                                                            child:
                                                                                Text(listTeachers[i].toString(), style: TextStyle(fontSize: 18.0, color: Colors.white)),
                                                                            onPressed:
                                                                                () async {
                                                                              showMostFlow(_term.round(), _year.round(), ders, listTeachers[i]);
                                                                            },
                                                                          );
                                                                        },
                                                                      )),
                                                                ));
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

  void showMostFlow(term, year, ders, empId) async {
    final response = await fetchMostCleverFlow(year, term, ders, empId);
    
    String section = json.decode(response.body)['res'];
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
                          '$empId\' [$ders] most clever flow section is $section',
                          style: _textStyle(Colors.white, 25.0)),
                    ),
                  ),
                ),
              ),
            ));
  }

  Future<List<String>> _listCoursesAll(term, year) async {
    final response = await fetchDersKodAll(year, term);
    final jsonParsed = json.decode(response.body);
    if (jsonParsed.length == 0) {
      return null;
    }
    List<String> list = new List<String>();
    for (var i in jsonParsed) {
      list.add(i["DERS_KOD"].toString());
    }
    return list;
  }

  Future<List<int>> _listTeachersDers(int term, int year, String ders) async {
    final response = await fetchTeachersDers(year, term, ders);
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

  Future<List<String>> _listCourses(term, year, type) async {
    final response = await fetchDersKod(year, term, type);
    final jsonParsed = json.decode(response.body);
    if (jsonParsed.length == 0) {
      return null;
    }
    List<String> list = new List<String>();
    for (var i in jsonParsed) {
      list.add(i["DERS_KOD"].toString());
    }
    return list;
  }

  Future<List<int>> _listTeachersLoading(term, year) async {
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

  Future<void> _listTeachersLoadingFinal(int year, int term, int empId) async {
    final response = await fetchTeachersLoading(year, term, empId);
    int hours = json.decode(response.body)['res'];
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
                      child: Text('$hours hours',
                          style: _textStyle(Colors.white, 25.0)),
                    ),
                  ),
                ),
              ),
            ));
  }

  Future<void> _listTeachers(
      int year, int term, String type, String dersKod) async {
    dersKod = dersKod.split('+').join(' ');
    final response =
        await fetchPopularTeachers(year.toInt(), term.toInt(), type, dersKod);

    final jsonParsed = json.decode(response.body);
    if (jsonParsed.length == 0) {
      return;
    }
    Navigator.of(context).pop();
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: Text('Popular - $year year, $term term'),
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
                          jsonParsed[index]['EMP_ID'].toString(),
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
}
