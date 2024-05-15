import 'package:flutter/material.dart';
import 'package:to_do_list/models/task.dart';
import 'package:to_do_list/widgets/task_item.dart';

class TaskList extends StatefulWidget {
  const TaskList({super.key, required this.task, required this.onRemoveTask});

  final List<Task> task;
  final void Function(Task task) onRemoveTask;

  @override
  State<TaskList> createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> { // класс формирующий ListView задач
  
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.task.length,
      itemBuilder: (ctx,index) => Dismissible(
        key: ValueKey(widget.task[index]),
        background: Container(
          color: Theme.of(context).colorScheme.error.withOpacity(0.75),
          padding: EdgeInsets.symmetric(horizontal: 20),
        ),
        child: TaskItem(task:widget.task[index]),
        onDismissed: (direction){
          widget.onRemoveTask(widget.task[index]);
        },
      )
      
    );
  }
}

