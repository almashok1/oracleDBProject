import 'dart:convert';
import 'dart:ui';

import 'package:db_project/connection.dart';
import 'package:db_project/styles.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Courses extends StatefulWidget {
  @override
  _CoursesState createState() => _CoursesState();
}

class _CoursesState extends State<Courses> {
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
                  showBottomModalPC();
                },
                child: Container(
                  height: 150,
                  child: Center(
                      child: Text(
                    'Popular Courses',
                    style: _textStyle(Colors.white, 24.0),
                  )),
                  decoration: decoration(Color(0xffff6363)),
                )),
            FlatButton(
                onPressed: () async {
                  showDialog(
                      context: context,
                      builder: (context) =>
                          Center(child: CircularProgressIndicator()));
                  await retakeProfits();
                },
                child: Container(
                  height: 150,
                  child: Center(
                      child: Text(
                    'All Retakes Profit',
                    style: _textStyle(Colors.white, 24.0),
                  )),
                  decoration: decoration(Color(0xffff6363)),
                )),
          ],
        ));
  }

  Future<http.Response> fetchPopularCourses(int year, int term) {
    return http.get(HOST + '/popular-courses/$year/$term');
  }

  Future<http.Response> fetchAllRetakesProfit() =>
      http.get(HOST + '/all-retakes-profit/');

  Future<void> retakeProfits() async {
    final response = await fetchAllRetakesProfit();
    int credits = json.decode(response.body)['res'];
    Navigator.of(context).pop();
    showDialog(
        context: context,
        builder: (context) => Material(
              type: MaterialType.transparency,
              child: Container(
                height: 200,
                child: Center(
                  child: Container(
                    decoration: decoration(Color(0xffffbd30)),
                    child: Center(
                      child: Text(
                          '$credits CREDITS X 25 000 = \n${credits * 25000} KZT',
                          style: _textStyle(Colors.white, 25.0)),
                    ),
                  ),
                ),
              ),
            ));
  }

  void showBottomModalPC() async {
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
                          await _listCourses(_year.round(), _term.round());
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
    final response = await fetchPopularCourses(year.toInt(), term.toInt());

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
}
