import 'dart:async';
import 'dart:convert';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:to_do/screens/update_task.dart';
import 'package:date_count_down/date_count_down.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xffC92F2F),
        brightness: Brightness.dark,
        dialogBackgroundColor: Colors.transparent,
      ),
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Future get_data() async {
    var response = await http
        .get(Uri.parse('https://ramiyoussef.pythonanywhere.com/list/'));
    var jsonresponse = jsonDecode(response.body);
    return jsonresponse;
  }

  //
  Future<http.Response> delete(var id) async {
    final http.Response response = await http
        .delete(Uri.parse('https://ramiyoussef.pythonanywhere.com/list/$id'));
    return response;
  }

  Future<http.Response> create(String mytitle, mybody, mydatetime) {
    return http.post(
      Uri.parse('https://ramiyoussef.pythonanywhere.com/list/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'title': mytitle,
        'body': mybody,
        'date_en': mydatetime,
      }),
    );
  }

  final keyRefresh = GlobalKey<RefreshIndicatorState>();
  late String title, body, datetime;
  TextEditingController _titleControler = TextEditingController();
  TextEditingController _bodyControler = TextEditingController();
  late StreamSubscription sub;

  @override
  void initState() {
    super.initState();
    sub = Connectivity().onConnectivityChanged.listen((event) {
      if (event != ConnectivityResult.none) {
        setState(() {
          get_data();
        });
      }
    });
  }

  @override
  void dispose() {
    sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xffC92F2F),
        centerTitle: true,
        title: Text('To Do'),
        actions: [
          IconButton(
            onPressed: () {
              _showMyDialog();
            },
            icon: Icon(Icons.add_circle),
          )
        ],
      ),
      body: FutureBuilder(
        future: get_data(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return RefreshIndicator(
              key: keyRefresh,
              onRefresh: () async {
                setState(() {
                  get_data();
                });
              },
              child: ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (context, i) {
                  return Padding(
                    padding: const EdgeInsets.all(11.0),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Color(0xffC53232),
                          border:
                              Border.all(color: Color(0xffC53232), width: 2),
                          borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 5,
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => update_task(
                                              title: snapshot.data[i]['title'],
                                              body: snapshot.data[i]['body'],
                                              id: snapshot.data[i]['id'],
                                              date_time: snapshot.data[i]
                                                  ['date_en'],
                                            )));
                              });
                            },
                            child: Column(
                              children: [
                                Text(
                                  snapshot.data[i]['title'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25,
                                  ),
                                ),
                                Text(
                                  snapshot.data[i]['body'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                CountDownText(
                                  due: DateTime.parse(
                                      snapshot.data[i]['date_en']),
                                  finishedText: "Time Out",
                                  showLabel: true,
                                  longDateName: true,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                delete(snapshot.data[i]['id']);
                                get_data();
                              });
                            },
                            icon: Icon(Icons.delete),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  //
  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            height: MediaQuery.of(context).size.height * 0.65,
            width: MediaQuery.of(context).size.width * 0.8,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(25),
            ),
            child: Padding(
              padding: const EdgeInsets.all(9.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Add New Task',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TextField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Tilte',
                      ),
                      controller: _titleControler,
                      onChanged: (value) {
                        title = value;
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TextField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Body',
                      ),
                      controller: _bodyControler,
                      onChanged: (value) {
                        body = value;
                      },
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    //
                    Container(
                      height: 90,
                      child: CupertinoDatePicker(
                        mode: CupertinoDatePickerMode.dateAndTime,
                        minimumYear: 2020,
                        maximumYear: 2030,
                        use24hFormat: true,
                        onDateTimeChanged: (DateTime newDateTime) {
                          setState(() {
                            datetime = newDateTime.toString();
                          });
                        },
                      ),
                    ),
                    //
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 5,
                        ),
                        ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Color(0xffC53232)),
                            foregroundColor:
                                MaterialStateProperty.all<Color>(Colors.white),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('Cancel'),
                        ),
                        ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Color(0xffC53232)),
                            foregroundColor:
                                MaterialStateProperty.all<Color>(Colors.white),
                          ),
                          onPressed: () {
                            setState(() {
                              create(title, body, datetime);
                              _titleControler.clear();
                              _bodyControler.clear();
                              get_data();
                              Navigator.of(context).pop();
                            });
                          },
                          child: Text('  Add  '),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
