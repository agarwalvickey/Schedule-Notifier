import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:flutter/rendering.dart';
import 'package:remind/task_manager.dart';
import 'package:remind/task.dart';
import 'database.dart';
import 'package:intl/intl.dart';
import 'package:weekday_selector/weekday_selector.dart';
List<String> getday=["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"];
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Injection.initInjection();
  runApp(const MyApp());
}

task_manager TaskManager = new task_manager();

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: home(),
    );
  }
}

class home extends StatefulWidget {
  const home({Key key}) : super(key: key);

  @override
  State<home> createState() => _homeState();
}

class _homeState extends State<home> {
  callBack() {
    setState(() {
      _tasks=getElements();
    });
  }
  callBack2(int id,int d,int hour, int minute,String title,String details){

    notificationScheduled(id,d,hour,minute,title,details);
  }
  FlutterLocalNotificationsPlugin flutterNotificationPlugin;

  Future<List<Map<dynamic, dynamic>>> _tasks;
  @override
  void initState() {
    // SchedulerBinding.instance.addPostFrameCallback((_) => setState(() {}));
    _tasks = getElements();
    var initializationSettingsAndroid = new AndroidInitializationSettings('launch_background');

    var initializationSettingsIOS = new IOSInitializationSettings();

    var initializationSettings = new InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    flutterNotificationPlugin = FlutterLocalNotificationsPlugin();

    flutterNotificationPlugin.initialize(initializationSettings,onSelectNotification: onSelectNotification);


    super.initState();
  }
  Future onSelectNotification(String payload) async{
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(
              "Your Scheduled Event"
          ),
          content: Text(
              "$payload"
          ),
        )
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reminder'),
      ),
      body: Container(
          child: FutureBuilder<List<Map<dynamic, dynamic>>>(
              future: _tasks,
              builder: (BuildContext context,
                  AsyncSnapshot<List<Map<dynamic, dynamic>>> snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: Text(
                      "You don't have any event scheduled yet, Please add an event"
                    ),
                  );
                } else {


                  return ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: Icon(Icons.add_alert),
                        title: Text(snapshot.data[index]['title'],textScaleFactor: 1.5,),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              // snapshot.data[index]['reminder_time'][0]
                                  getday[int.parse(snapshot.data[index]['reminder_time'].substring(0,1))-1]+"\n"+snapshot.data[index]['reminder_time'].substring(1)
                            ),
                            // Text(s)

                            // Icon(Icons.edit,color: Colors.grey,),
                            IconButton(onPressed: () async {
                              deleteItem(snapshot.data[index]['id']);
                              await flutterNotificationPlugin.cancel(snapshot.data[index]['id']);
                              callBack();
                            }, icon: const Icon(Icons.delete,color: Colors.red,)),

                          ],
                        ),
                        subtitle: Text(snapshot.data[index]['detail']),
                        selected: true,
                        onTap: () {
                        },
                      )
                        ;
                    },
                  );
                }
              })),
      floatingActionButton: FloatingActionButton.extended(
        isExtended: true,
        backgroundColor: Colors.blue,
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return form(callBack,callBack2);

              });
        },
        label: Icon(Icons.add),
      ),
    );
  }
  Future<void> notificationScheduled(int id,int d,int hour,int minute,String title,String detail) async {
    // int hour = 13;
    var ogValue = hour;
    // int minute = 46;

    var time = Time(hour,minute,0);
    var day=Day(d);
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'repeatDailyAtTime channel id',
      'repeatDailyAtTime channel name',
      channelDescription: 'repeatDailyAtTime description',
      importance: Importance.max,
      // sound: 'slow_spring_board',
      ledColor: Color(0xFF3EB16F),
      ledOffMs: 1000,
      ledOnMs: 1000,
      enableLights: true,
    );
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);

    await flutterNotificationPlugin.showWeeklyAtDayAndTime(id,title,
      detail,day,time, platformChannelSpecifics,payload: title+" : " +detail);

    print('Set at '+time.minute.toString()+" +"+time.hour.toString());

  }
}

class form extends StatefulWidget {
  form(this.callback,this.callback2);
  Function callback;
  Function callback2;
  // const form({Key? key}) : super(key: key);
  @override
  State<form> createState() => _formState();
}

class _formState extends State<form> {
  TextEditingController title = TextEditingController();
  TextEditingController details = TextEditingController();
  TextEditingController createdate = TextEditingController();
  TextEditingController reminderdate = TextEditingController();
  var departureDate;
  final values = List.filled(7, false);
  // values[1]=true;
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              decoration: new InputDecoration.collapsed(
                  hintText: 'Title'
              ),
              controller: title,
            ),
            TextField(
              decoration: new InputDecoration.collapsed(
                  hintText: 'Detail'
              ),
              controller: details,
            ),
            Container(
              child: DateTimePicker(
              validator: (value) => (value == null || value.isEmpty)
                  ? 'Required Field'
                  : null,
              type: DateTimePickerType.time,
              initialTime: TimeOfDay.now() ,

              // firstDate: DateTime(1900),
              // lastDate: DateTime(2100),
              // initialDate: DateTime.now(),
              // dateLabelText: 'Reminder Date',
              timeLabelText: 'Reminder Time',
              onChanged: (value) {
                // departureDate = DateTime.parse(value);
                departureDate= value;

                // departureDate=value.timeZoneOffset.inHours.toString();
              },
            ),),
            Container(
                child: WeekdaySelector(
                  onChanged: (int day) {
                    setState(() {

                      final index = day % 7;
                      values[index] = !values[index];
                    });
                  },
                  values: values,
                )
            ),
            Container(
              child: ElevatedButton(
                onPressed: () async {
                  DateTime now = DateTime.now();
                  String formattedDate = DateFormat('EEE d MMM \n kk:mm').format(now);
                  // String reminderDate = DateFormat('kk:mm').format(departureDate);
                  String reminderDate=departureDate;
                  int x=7;
                  for(int i=0;i<values.length;i++){
                    if(values[i]){
                      x=i;
                      break;
                    }
                  }
                  // List<String> temp=reminderDate.split("\n");
                  // reminderDate=temp[1];
                  String val=(x+1).toString()+reminderDate;
                  int id=await inserttasks(details.text, title.text, val,
                     formattedDate );
                  String temp2=reminderDate;
                  List<String> temp3=temp2.split(":");
                  int hour=int.parse(temp3[0]);
                  int minute=int.parse(temp3[1]);
                  print(hour);
                  print(minute);
                  widget.callback2(id,x+1,hour,minute,title.text,details.text);
                  widget.callback();
                  Navigator.pop(context);
                },
                child: Text('Create'),
              ),
            )
          ],
        ),
      ),
    );
  }
}


// class task extends StatefulWidget {
//   const task({Key? key}) : super(key: key);
//
//   @override
//   State<task> createState() => _taskState();
// }
//
// class _taskState extends State<task> {
//   @override
//   Widget build(BuildContext context) {
//     return Container(child: Text('task'),);
//   }
// }
// Container(
// // height: 100,
// padding: EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 0.0),
// child: Card(
// elevation: 5,
// shape: RoundedRectangleBorder(
// borderRadius: BorderRadius.circular(10),
// side: BorderSide(color: Colors.lightBlue, width: 2),
// ),
// child: Row(
// children: [
// Container(
// height: 50,
// // constraints: BoxConstraints.expand(),
// padding: EdgeInsets.all(10),
// decoration: const BoxDecoration(
// color: Colors.blue,
// borderRadius: BorderRadius.all(Radius.circular(10))
// ),
// child: Text(
// snapshot.data[index]['title'][0].toUpperCase(),
// style: TextStyle(color: Colors.white),
// ),
// ),
// Column(
// children: [
// Container(
// padding: EdgeInsets.all(5),
// child: Text(
// snapshot.data[index]['title'],
// )
// ),
// Container(
// padding: EdgeInsets.all(5),
// child: Text(
// snapshot.data[index]['detail'],
// )
// )
// ],
// )
// ],
//
// )
// ),
// );

