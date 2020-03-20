import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

/*
Consumer 사용과 Provider.of 의 현재 동작은 같습니다.
그럼 Provider.of 와 Consumer 의 차이점은 무엇일까요?
Consumer 는 상태 변경이 일어날때 builder 에 지정된 위젯을 rebuild 하게 됩니다.
state 의 변경에 의해서 위젯의 rebuild 가 필요할 때 consumer 를 지정하여 사용해야 합니다.
state 와 관련없는 위젯까지 rebuild 할 필요가 없겠죠.
현재 코드에서 counter 가 변경될때 변경되어야 하는 위젯은 중앙에 위치한 Text 위젯 입니다.
따라서 Consumer 는 변경될 위젯 가장 깊숙한 곳 에서 사용하는 것이 좋습니다.
Provider.of 는 consumer 와 같이 해당 Provider 클래스에 접근 할 수 있지만 조금 다른 용도로 주로 사용 됩니다.
CounterProvider 클래스에는 state 를 변경하는 increment, decrement, reset 메소드가 있습니다.
해당 메소드를 실행 할 때 특정 위젯이나 상태가 필요하지 않습니다.
해당 위젯의 상태 변경도 없고, 단지 메소드만 실행하는 위젯 들 입니다.
이런 경우에는 해당 메소드를 실행시키는 위젯은 notify 를 받을 필요가 없습니다.
이런 경우 provider.of 의 옵션으로 listen 값을 false 로 주고 사용할 수 있습니다.
이 경우 해당 위젯들은 notify 를 받지 않습니다.

출처: https://alexband.tistory.com/56 [GoodBye World]
 */
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<GetNews>(
      create: (_)=>GetNews(),
      child: MaterialApp(
        title: 'DEMO',
        theme: ThemeData(
          // Define the default brightness and colors.
          brightness: Brightness.dark,
          primaryColor: Colors.lightBlue[800],
          accentColor: Colors.cyan[600],
          // Define the default font family.
          fontFamily: 'Georgia',
        ),
        home: MyHomePage(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  void initState() {
    print('init');
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final getnews = Provider.of<GetNews>(context);

    // provider 는 빌드시에 동작하기에 아래는 오류
    //if(getnews.newsData!=null){print(getnews.newsData[0].title);}
    //getnews.newsData.map<NewsArticle>((d){print(d);});
    print('build');
    //print(newsData);
    return Scaffold(
      appBar: AppBar(
        title:Text(widget.title),
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
          itemCount: getnews.newsData==null?0:getnews.newsData.length,
          itemBuilder: (BuildContext _context,index){
            //print(index);
            //if(getnews.newsData!=null){print(getnews._newsData[0].title);}
            return  Dismissible(
                key: Key('${index}'),
                onDismissed: (DismissDirection){

                },
                child:ListTile(
                  title:Text('${getnews.newsData[index].title}'),
                  onTap: (){
                    Navigator.push(_context, MaterialPageRoute(builder: (ctx)=>SecondPage(id: getnews.newsData[index].id)) );
                  },
                )
            );
          }
      ),
      floatingActionButton: FloatingActionButton(
          child:Icon(Icons.update)
      ),
    );
  }
}

class GetNews extends ChangeNotifier {
  List<NewsArticle> _newsData = [];

  // get으로 호출 안해도 됨. 실제 호출시 GetNews._newsData 로도 호출가능
  List<NewsArticle> get newsData => _newsData;

  //생성자
  factory GetNews() {
    return GetNews._();
  }
  // private 생성자
  GetNews._(){
    getData();
  }
  Future<void> getData() async {
    try {
      print('getreq');
      await Future.delayed(Duration(seconds: 5));
      var client = http.Client();
      final response = await client.get(
          'http://www.xportsnews.com/?ac=test&tac=list');
      var parsed = json.decode(utf8.decode(response.bodyBytes));
      _newsData =
          parsed.map<NewsArticle>((txt) => NewsArticle.fromJson(txt))
              .toList();
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }
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

