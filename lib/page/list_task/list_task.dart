import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:task/model/task.dart';
import 'package:task/page/list_task/item_task_screen.dart';
import 'package:task/page/screen/alert.dart';
import 'package:task/page/screen/load.dart';
import 'package:task/service/http/task.dart';

class ListPage extends StatefulWidget {
  @override
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  final Map<int, Task> tasks = Map();
  final TaskService _webClient = TaskService();
  bool _isLoad = true;

  @override
  void initState() {
    super.initState();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      setState(() => _isLoad = true);
      processDatas();
    });
    processDatas();
  }

  processDatas() {
    this._webClient.findAll().then(
          (tasksResponse) => setState(
            () {
              this._isLoad = false;
              tasksResponse.forEach((task) {
                tasks[task.id] = task;
              });
            },
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoad) {
      return LoadScreen();
    } else {
      return Container(
        child: Stack(
          children: <Widget>[
            Container(
              color: Colors.transparent,
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.9,
              child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, position) {
                  int key = tasks.keys.elementAt(position);
                  return ItemScreen(
                    tasks[key],
                    this.onRemove,
                  );
                },
              ),
            ),
          ],
        ),
      );
    }
  }

  Future<bool> onRemove(int id, String just) async {
    bool ok = await this._webClient.cancelTask(tasks[id], just);
    if (ok) {
      setState(() {
        this.tasks.remove(id);
      });
    } else {
      showCustomDialog(
        context,
        "Erro ao deletar!",
        "Verifique sua conexão ou contate ao administrador.",
        Colors.red,
        () => print("Confirmado"),
      );
    }
    return ok;
  }
}
