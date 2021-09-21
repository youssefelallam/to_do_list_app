import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class update_task extends StatefulWidget {
  final String title, body, date_time;
  final id;
  const update_task(
      {Key? key,
      required this.title,
      required this.body,
      required this.id,
      required this.date_time})
      : super(key: key);

  @override
  _update_taskState createState() => _update_taskState();
}

class _update_taskState extends State<update_task> {
  TextEditingController _titleControler = TextEditingController();
  TextEditingController _bodyControler = TextEditingController();
  late String mytitle, mybody, mydatetime;
  late DateTime parseDt;

  Future<http.Response> update(String mytitle, mybody, mydatetime, var id) {
    return http.put(
      Uri.parse('API URL/$id'),
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

  @override
  void initState() {
    super.initState();
    _titleControler.text = widget.title;
    _bodyControler.text = widget.body;
    parseDt = DateTime.parse(widget.date_time);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xffC92F2F),
        centerTitle: true,
        title: Text('Update'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(13.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 30,
              ),
              Text(
                'Update Task',
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
                  mytitle = value;
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
                  mybody = value;
                },
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                height: 90,
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.dateAndTime,
                  minimumYear: 2020,
                  maximumYear: 2030,
                  use24hFormat: true,
                  initialDateTime: parseDt,
                  onDateTimeChanged: (DateTime newDateTime) {
                    setState(() {
                      mydatetime = newDateTime.toString();
                    });
                  },
                ),
              ),
              SizedBox(
                height: 20,
              ),
              //
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 5,
                  ),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Color(0xffC53232)),
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
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Color(0xffC53232)),
                      foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.white),
                    ),
                    onPressed: () {
                      setState(() {
                        update(_titleControler.text, _bodyControler.text,
                            mydatetime, widget.id);
                        _titleControler.clear();
                        _bodyControler.clear();
                        Navigator.of(context).pop();
                      });
                    },
                    child: Text('Update'),
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
    );
  }
}
