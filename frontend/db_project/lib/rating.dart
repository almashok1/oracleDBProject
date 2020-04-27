import 'dart:convert';
import 'dart:ui';

import 'package:db_project/connection.dart';
import 'package:db_project/styles.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Rating extends StatefulWidget {
  @override
  _RatingState createState() => _RatingState();
}

class _RatingState extends State<Rating> {
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
                  showBottomModalPC(true);
                },
                child: Container(
                  height: 150,
                  child: Center(
                      child: Text(
                    'Rating Courses',
                    style: _textStyle(Colors.white, 24.0),
                  )),
                  decoration: decoration(Color(0xffff6363)),
                )),

            FlatButton(
                onPressed: () {
                  showBottomModalPC(false);
                },
                child: Container(
                  height: 150,
                  child: Center(
                      child: Text(
                    'Rating Teachers',
                    style: _textStyle(Colors.white, 24.0),
                  )),
                  decoration: decoration(Color(0xffff6363)),
                )),
          ],
        ));
  }

  Future<http.Response> fetchRatingCourses(int year, int term) {
    return http.get(HOST + '/rating/courses/$year/$term');
  }

  Future<http.Response> fetchRatingTeachers(int year, int term) {
    return http.get(HOST + '/rating/teachers/$year/$term');
  }

  void showBottomModalPC(bool isCourses) async {
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
                          Navigator.of(context).pop();
                          showDialog(
                              context: context,
                              builder: (context) =>
                                  Center(child: CircularProgressIndicator()));
                          isCourses ? await _listCourses(_year.round(), _term.round()) : 
                                      await _listTeachers(_year.round(), _term.round());
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

  Future<void> _listCourses(int year, int term) async {
    final response = await fetchRatingCourses(year.toInt(), term.toInt());

    final jsonParsed = json.decode(response.body);
    if (jsonParsed.length == 0) {
      return;
    }

    Navigator.of(context).pop();
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: Text('Rating Courses - $year year, $term term'),
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
                          jsonParsed[index]['DERS_KOD'],
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

  Future<void> _listTeachers(int year, int term) async {
    final response = await fetchRatingTeachers(year.toInt(), term.toInt());

    final jsonParsed = json.decode(response.body);
    if (jsonParsed.length == 0) {
      return;
    }

    Navigator.of(context).pop();
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: Text('Rating Teachers - $year year, $term term'),
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