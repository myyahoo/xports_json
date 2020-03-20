import 'dart:async';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState(title:title);
}

class _MyHomePageState extends State<MyHomePage> {

  var title;
  StreamController<NewsArticle>  streamController;

  _MyHomePageState({Key key,this.title});
  List<NewsArticle> newsData;
  var aaa='';

  @override
  void initState() {
    print('init');
    // TODO: implement initState
    super.initState();
    this.getReq();
  }
  @override
  Widget build(BuildContext context) {
    print('build');
    //print(newsData);
    return Scaffold(
      appBar: AppBar(
        title:Text(title),
        actions: <Widget>[
          IconButton(
            icon:Icon(Icons.close),
            onPressed: (){
              Navigator.pop(context);
            }
          )
        ],
      ),
      body:ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: newsData==null?0:newsData.length,
          itemBuilder: (BuildContext _context,index){
            return  ListTile(

                title:Text('${newsData[index].title}'),
                onTap: (){
                  Navigator.push(_context, MaterialPageRoute(builder: (ctx)=>SecondPage(id: newsData[index].id)) );
                },
            );
          }
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: aaa,
        child:Icon(Icons.update)
      ),
    );
  }
  Future<void> getReq() async{
    try {
      print('getreq');
      //await Future.delayed(Duration(seconds: 5));
      var client = http.Client();
      final response = await client.get('http://www.xportsnews.com/?ac=test&tac=list');
      //var parsed = json.decode(utf8.decode(response.bodyBytes)).cast<Map<String, dynamic>>();
      var parsed = json.decode(utf8.decode(response.bodyBytes));
      //print(parsed);
      //print(list[10].title);
      setState(() {
        this.newsData = parsed.map<NewsArticle>((txt) => NewsArticle.fromJson(txt)).toList();
        aaa='async';
        print(this.newsData[0].title);
      });
    }catch(e){
      print(e);
    }
  }

/*
  Future<void> getReq() async{
    try {
      print('getreq');
      await Future.delayed(Duration(seconds: 5));
      var client = http.Client();
      final response = await client.get('http://www.xportsnews.com/?ac=test&tac=list');
      //var parsed = json.decode(utf8.decode(response.bodyBytes)).cast<Map<String, dynamic>>();
      var parsed = json.decode(utf8.decode(response.bodyBytes));
      //print(parsed);
     //print(list[10].title);
      setState(() {
        this.newsData = parsed.map<NewsArticle>((txt) => NewsArticle.fromJson(txt)).toList();
        aaa='async';
      });
    }catch(e){
      print(e);
    }
  }

   */
}
class NewsArticle{
  final String id;
  final String title;
  final String body;

  NewsArticle({this.id,this.title,this.body});

  factory NewsArticle.fromJson(Map<String,dynamic> json){
    return NewsArticle(id:json['id'],title:json['title']);

  }
}

class SecondPage extends StatefulWidget {
  String id;

  SecondPage({this.id});
  @override
  _SecondPageState createState() => _SecondPageState(id:this.id);
}

class _SecondPageState extends State<SecondPage> {
  String id;
  NewsArticle newsData;
  _SecondPageState({Key key,this.id});

  @override
  void initState() {
    print('secod init${id}');

    // TODO: implement initState
    super.initState();
    getView();
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title:Text(newsData==null?'':newsData.title),
        actions: <Widget>[
          IconButton(
            icon:Icon(Icons.navigate_next),
            onPressed: (){
              Navigator.push(context,MaterialPageRoute(builder: (ctx)=>ThirdPage()));
            },
          ),

        ],
      ),
      body:Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(newsData==null?'':newsData.body),
      ),
    );

  }
  Future getView() async{
    try {
      final response = await http.get(
          'http://www.xportsnews.com/?ac=test&tac=view&entry_id=${id}');
      setState(() {
        var parsed = json.decode(utf8.decode(response.bodyBytes)); // json string to list
        newsData = NewsArticle(id:parsed['id'],title:parsed['Title'],body:parsed['Body']);
        print(newsData.body);
      });

    }catch(Exception){
      print(Exception);
    }
  }
}

class ThirdPage extends StatelessWidget {
  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Last Page!"),
        backgroundColor: Theme.of(ctx).accentColor,
        elevation: 2.0,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.close),
            onPressed: (){
              Navigator.pop(ctx);
            },
          )
        ],
      ),
      body: Center(
        child: MaterialButton(
          onPressed: (){
            Navigator.popUntil(ctx, ModalRoute.withName(Navigator.defaultRouteName));
          },
          child: Text("Go Home!"),
        ),
      ),
    );
  }
}

