import 'package:flutter/material.dart';
import 'package:http/http.dart';

class ScheduleTab extends StatefulWidget {
  final json;
  final id;

  ScheduleTab(this.json, this.id);

  @override
  _ScheduleTabState createState() => _ScheduleTabState();
}

class _ScheduleTabState extends State<ScheduleTab> {
  var res = {
      'MONDAY': <CardSchedule>[],
      'TUESDAY': <CardSchedule>[],
      'WEDNESDAY': <CardSchedule>[],
      'THURSDAY': <CardSchedule>[],
      'FRIDAY': <CardSchedule>[],
      'SATURDAY': <CardSchedule>[]
  };
  @override
  void initState() {
    super.initState();
    res['MONDAY'] = new List<CardSchedule>();
    res['TUESDAY'] = new List<CardSchedule>();
    res['WEDNESDAY'] = new List<CardSchedule>();
    res['THURSDAY'] = new List<CardSchedule>();
    res['FRIDAY'] = new List<CardSchedule>();
    res['SATURDAY'] = new List<CardSchedule>();
    for (var i in widget.json) {
      final String weekday = i['WEEKDAY'].toString().toUpperCase().trim();
      
       
      res[weekday].add(CardSchedule(
          i['DERS_KOD'], i['START_TIME'], i['SECTION'], i['TYPE']));
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primaryColor: Color(0xff202040), 
      accentColor: Color(0xff543864)),
        home: DefaultTabController(
            length: 6,
            child: Scaffold(
              appBar: AppBar(
                title: Text('${widget.id}'),
                bottom: TabBar(
                    isScrollable: true,
                    tabs: weeks.map((e) => Text(e)).toList()),
              ),
              body: Container(
                padding: EdgeInsets.all(20.0),
                color: Theme.of(context).accentColor,
                child: TabBarView(children: [
                  buildList(res['MONDAY']),
                  buildList(res['TUESDAY']),
                  buildList(res['WEDNESDAY']),
                  buildList(res['THURSDAY']),
                  buildList(res['FRIDAY']),
                  buildList(res['SATURDAY']),
                ]),
              ),
            )));
  }

  List<String> get weeks {
    return ['MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY'];
  }

  TextStyle getStyle(size) => TextStyle(
    fontSize: size,
    fontWeight: FontWeight.w400,
    color: Colors.white
  );

  Widget buildList(List<CardSchedule> l) {
    return ListView(
      children: l
          .map((e) => Card(
            elevation: 3.0,
            color: Theme.of(context).primaryColor,
                  child: Container(
                    padding: EdgeInsets.all(5.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(e.dersKod, style: getStyle(20.0),),
                  Container(
                      child: Column(
                    children: [
                      Text(e.section.toString() + "-" + e.type.toString(), style: getStyle(18.0),),
                      Text(e.startTime.toString(), style: getStyle(18.0))
                    ],
                  ))
                ],
              ))))
          .toList(),
    );
  }
}

class CardSchedule {
  final dersKod;
  final startTime;
  final section;
  final type;

  CardSchedule(this.dersKod, this.startTime, this.section, this.type);
}
