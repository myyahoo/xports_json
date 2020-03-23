import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
/*
파일 엑세스 해결방법
1. Android Studio > File > Project Structure... 클릭!
2. 좌측 메뉴에서 Modules > *_android 클릭
3. 우측 패널에서 Dependencies를 클릭합니다
4. <No Project SDK> 클릭후 Android SDK 클릭!
5. Android Studio 재시작
 */
void main(){
  runApp(App());
}
class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home:MyPainter()
    );
  }
}

class MyPainter extends StatefulWidget {

  @override
  _MyPainterState createState() => _MyPainterState();
}

class _MyPainterState extends State<MyPainter> {
  GlobalKey<_Signature> signatureKey = GlobalKey();
  var image;
  String _platformVersion = 'Unknown';
  //Permission _permission = Permission.WriteExternalStorage;


  @override
  void initState() {
    super.initState();
    initPlatformState();
  }
  initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      //platformVersion = await SimplePermissions.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
    print(_platformVersion);
  }

  setRenderedImage(BuildContext context) async {
    ui.Image renderedImage = await signatureKey.currentState.rendered;
    setState(() {
      image = renderedImage;
    });
    showImage(context);

  }
  Future<Null> showImage(BuildContext context) async {
    var pngBytes = await image.toByteData(format: ui.ImageByteFormat.png);
    //if(!(await checkPermission())) await requestPermission();
    // Use plugin [path_provider] to export image to storage
    Directory directory = await getExternalStorageDirectory();
    //Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path;
    //print("========");
    print(path);
    await Directory(path).create(recursive: true);
    //저장
    var filename ='$path/test.png';
    File(filename)
        .writeAsBytesSync(pngBytes.buffer.asInt8List());

    //업로드
    //https://dev.to/carminezacc/advanced-flutter-networking-part-1-uploading-a-file-to-a-rest-api-from-flutter-using-a-multi-part-form-data-post-request-2ekm
    var request = http.MultipartRequest('POST', Uri.parse('http://18.221.219.78/ai/predict'));
    request.files.add(
        await http.MultipartFile.fromPath(
            'paint',
            filename
        )
    );
    var res = await request.send();
    final respStr = await res.stream.bytesToString();
    print(respStr);
    return showDialog<Null>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              '${respStr}',
              style: TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w300,
                  color: Theme.of(context).primaryColor,
                  letterSpacing: 1.1
              ),
            ),
            content: Image.memory(Uint8List.view(pngBytes.buffer)),
          );
        }
    );
  }
  String formattedDate() {
    DateTime dateTime = DateTime.now();
    String dateTimeString = 'Signature_' +
        dateTime.year.toString() +
        dateTime.month.toString() +
        dateTime.day.toString() +
        dateTime.hour.toString() +
        ':' + dateTime.minute.toString() +
        ':' + dateTime.second.toString() +
        ':' + dateTime.millisecond.toString() +
        ':' + dateTime.microsecond.toString();
    return dateTimeString;
  }
/*
  requestPermission() async {
    var result = await SimplePermissions.requestPermission(_permission);
    return result;
  }
  checkPermission() async {
    bool result = await SimplePermissions.checkPermission(_permission);
    return result;
  }

  getPermissionStatus() async {
    final result = await SimplePermissions.getPermissionStatus(_permission);
    print("permission status is " + result.toString());
  }

 */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Signature(key: signatureKey),
      persistentFooterButtons: <Widget>[
        FlatButton(
          child: Text('Clear'),
          onPressed: () {
            signatureKey.currentState.clearPoints();
          },
        ),
        FlatButton(
          child: Text('Save'),
          onPressed: () {
            // Future will resolve later
            // so setState @image here and access in #showImage
            // to avoid @null Checks
            setRenderedImage(context);
          },
        )
      ],
    );
  }
}


class Signature extends StatefulWidget {
  Signature({Key key}): super(key: key);

  @override
  _Signature createState() {
    return _Signature();
  }
}

/*
 GestureDetector 가 onPan 상태를 감지해서 offset _point 값을 업데이트 setstate 하면
 custompaint 는 poinst 상태를 받아서 그림을 그린다.
 */
class _Signature extends State<Signature> {
  List<Offset> _points = <Offset>[];

  Future<ui.Image> get rendered {

    ui.PictureRecorder recorder = ui.PictureRecorder();
    Canvas canvas = Canvas(recorder);
    SignaturePainter painter = SignaturePainter(points: _points);
    var size = context.size;
    painter.paint(canvas, size);
    /*
    return recorder.endRecording()
        .toImage(size.width.floor(), size.height.floor()); */
    return recorder.endRecording()
        .toImage(400, 400);
  }

  @override
  Widget build(BuildContext context) {
    print('build');
    return Scaffold(
        body: Container(
          height: 300,
          width: 400,
          child: GestureDetector(
            onPanUpdate: (DragUpdateDetails details) {
              setState(() {
                RenderBox object = context.findRenderObject();
                Offset _localPosition =
                object.globalToLocal(details.globalPosition);
                _points = List.from(_points)
                  ..add(_localPosition);
                //_points.add(_localPosition);
              });
            },
            onPanEnd: (DragEndDetails details) => _points.add(null),
            child: CustomPaint(
              size:Size(300,400),
              //size: Size.infinite,
              painter: new SignaturePainter(points: _points),

            ),
          ),
        )
    );
  }
  void clearPoints() {
    setState(() {
      _points.clear();
    });
  }
}

class SignaturePainter extends CustomPainter{
  List<Offset> points;
  SignaturePainter({this.points});

  @override
  void paint(Canvas canvas, Size size) {
    // .. => paint set cascade
    Paint paint = Paint()
      ..color = Colors.blue
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 10.0;
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i], points[i + 1], paint);
      }
    }
  }
  @override
  bool shouldRepaint(SignaturePainter oldDelegate) => oldDelegate.points != points;
}





