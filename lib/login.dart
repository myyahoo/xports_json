import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main(){
  runApp(LoginApp());
}

class LoginApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_)=>UserProvider(),
        )
        /*
        StreamProvider<FirebaseUser>.value(
          value:User()
        )*/

        // 스트림 프로바이더로 인증 정보를 읽어들임. 인증 상태가 변하면, 변한 값이 출력됨.
      ],
      child: MaterialApp(
        title: '인증 프로바이더',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: LoginPage(),
      ),
    );
  }
}


class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailCtrl = TextEditingController();
  TextEditingController passwordCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final UserProvider user = Provider.of(context);
    var loggedIn = user.getUser() != null;

    //print(user.getUser().name);
      return Scaffold(
        appBar: AppBar(
          title:Text('로그인페이지')
        ),
        body: Form(
          key:_formKey,
            child:Column(
          children: <Widget>[
            if(loggedIn)...[RaisedButton(child:Text('sign out'), onPressed: (){ signOut(user); } ),Text(user.getUser().name)],
            if(!loggedIn)...[
              TextFormField(
                controller: emailCtrl,
                decoration: InputDecoration(
                    icon: Icon(Icons.email), hintText: '이메일을 적어주세요.'),
                validator:(value){
                  if(value.isEmpty){
                    return '공백은 허용안됨';
                  }
                },
              ),
              TextFormField(
                controller: passwordCtrl,
                validator:(value){
                  if(value.isEmpty){
                    return '공백은 허용안됨';
                  }
                },
                decoration: InputDecoration(
                    icon: Icon(Icons.keyboard), hintText: '비밀번호를 적어주세요.'),
                obscureText: true,

              ),
              RaisedButton(
                  onPressed: (){
                if(_formKey.currentState.validate()){
                  Scaffold.of(_formKey.currentContext).showSnackBar(SnackBar(content: Text('처리중'),));
                }
                    //user.setUser(age:1,name:passwordCtrl.text);
                  },
                  child:Text('완료')
              )
            ],

          ],
        )
      )
      );
    }

  void signOut(UserProvider user){
    user.setUser(age:0,name:'');

  }
}

/*
class FirebaseUser extends ChangeNotifier{
  User user;
  void setUser({int age,String name}){
    user.age = age;
    user.name = name;
  }
}
*/
class UserProvider with ChangeNotifier{
  User user;
  User getUser(){
    return user;
  }
  void setUser({int age,String name}){
    if(name!='') {
      user = User(age: age, name: name);
    }else{
      user = null;
    }
    notifyListeners();
  }
}
class User{
  int age;
  String name;

  User({this.age,this.name});

}