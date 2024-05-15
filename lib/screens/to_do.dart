import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:to_do_list/models/task.dart';
import 'package:to_do_list/widgets/new_task.dart';
import 'package:to_do_list/widgets/task_list.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timezone/timezone.dart' as trz;


class ToDoScreen extends StatefulWidget {
  const ToDoScreen({super.key});

  @override
  State<ToDoScreen> createState() => _ToDoScreenState();
}

class _ToDoScreenState extends State<ToDoScreen> { // класс формирующий окно задач
  final List<Task> _registeredTask = [];
  bool _showCompletedTasks = false;
  final user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
   late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
 @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _fetchTasks();
  }

Future<void> _initializeNotifications() async {// метод для инициализации уведомлений
  _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  final InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);
  await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
}


void _scheduleNotification(Task task) async { // метод для формирования push уведомления
  final deviceTimeZone = trz.local;

  final scheduledDate = trz.TZDateTime.from(task.date.subtract(Duration(days: 1)), deviceTimeZone);


  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'to_do_list_channel',
    'ToDo List Channel',
    importance: Importance.max,
    priority: Priority.high,
    ticker: 'ticker',
  );
  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);


  await _flutterLocalNotificationsPlugin.zonedSchedule(
    0,
    'Пора выполнить задачу!',
    task.title,
    scheduledDate,
    platformChannelSpecifics,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
    matchDateTimeComponents: DateTimeComponents.time,
  );
}

  Future<void> _fetchTasks() async { // метод для считывания задач из базы данных
    try {
      final snapshot = await _firestore.collection('tasks').doc(user!.uid).get();
      if (snapshot.exists) {
        final List<Task> tasks = List<Task>.from(snapshot.data()!['tasks'].map((task) => Task.fromJson(task)));
        setState(() {
          _registeredTask.addAll(tasks);
        });
      }
    } catch (e) {
      print('Ошибка считывания записи: $e');
    }
  }

  void _saveTasks() async { // метод для сохранения задач в базе данных
    try {
      await _firestore.collection('tasks').doc(user!.uid).set({'tasks':_registeredTask.map((task) => task.toJson()).toList()});
    } catch (e) {
      print('Ошибка записи задач: $e');
    }
  }

  void _openAddTaskOverplay() { // метод для открытия окна для добавления новой задачи
    showModalBottomSheet(
        useSafeArea: true,
        isScrollControlled: true,
        context: context,
        builder: (ctx) => NewTask((task) {}, onAddTask: _addTask));
  }

  void _addTask(Task task) { // метод отвечающий за добавление новой задачи в список
    setState(() {
      _registeredTask.add(task);
    });
     _saveTasks();
     print(task.date);
     _scheduleNotification(task); 
  }

 void _removeTask(Task task) async { // метод удаляющий задачу из списка и из базы данных
  final TaskEndex = _registeredTask.indexOf(task);
  setState(() {
    _registeredTask.remove(task);
  });

  await _firestore.collection('tasks').doc(user!.uid).update({
    'tasks': FieldValue.arrayRemove([task.toJson()])
  });

  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: const Text('Задача удалена'),
      duration: const Duration(seconds: 3),
      action: SnackBarAction(
        label: 'Отмена',
        onPressed: () {
          setState(() {
            _registeredTask.insert(TaskEndex, task);
          });
          _firestore.collection('tasks').doc(user!.uid).update({
            'tasks': FieldValue.arrayUnion([task.toJson()])
          });
        },
      ),
    ),
  );
}


  Future<void> signOut() async { // метод для выхода из аккаунта
    final navigator = Navigator.of(context);

    await FirebaseAuth.instance.signOut();

    navigator.pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
  }

   void _sortTasksByDate() {// метод для сортировки задач по дате
    setState(() {
      _registeredTask.sort((a, b) => a.date.compareTo(b.date));
    });
  }

  void _sortTasksByTitle() { // метод для сортировки задач в алфавитном порядке по названию
    setState(() {
       _registeredTask.sort((a, b) => a.title.compareTo(b.title));
    });
  }

    void _toggleCompletedTasks() { // метод для сортировки задач по выполненным
    setState(() {
      _showCompletedTasks = !_showCompletedTasks;
    });
  }

  @override
  Widget build(BuildContext context) {
     List<Task> tasksToDisplay = _showCompletedTasks
        ? _registeredTask.where((task) => task.isCompleted).toList()
        : _registeredTask;
    Widget maincontent = const Center(
      child: Text('Пока нету никаких задач!'),
    );
    if (tasksToDisplay.isNotEmpty) {
      maincontent = TaskList(task: tasksToDisplay, onRemoveTask: _removeTask);
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("Органайзер ваших задач", style: TextStyle(color: Colors.white),),
        actions: [IconButton(onPressed: _openAddTaskOverplay, icon: const Icon(Icons.add, color: Colors.white,))],
        leading: PopupMenuButton(
          icon: Icon(Icons.account_circle_rounded),
          iconSize: 30,
          color: Colors.white,
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem(
                    child: ListTile(
                      title: Text('Выйти'),
                      onTap: signOut,
                    ),
                  ),
                ];
              },
        ),
        backgroundColor: Colors.indigo,
      ),
      body: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
            onPressed: _toggleCompletedTasks,
            icon: const Icon(Icons.check),
            tooltip: 'Показать выполненные задачи',
           ),
              IconButton(
                onPressed: _sortTasksByDate,
                icon: const Icon(Icons.calendar_today),
                tooltip: 'Сортировать по дате',
              ),
              IconButton(
                onPressed: _sortTasksByTitle,
                icon: const Icon(Icons.sort_by_alpha),
                tooltip: 'Сортировать по заголовку',
              ),
            ],
        ),
        Expanded(child: maincontent),
      ],),
    );
  }
}
