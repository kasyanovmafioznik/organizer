import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:to_do_list/models/task.dart';

class TaskItem extends StatefulWidget {
  const TaskItem({Key? key, required this.task}) : super(key: key);

  final Task task;

  @override
  State<TaskItem> createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem> {
  // класс формирующий внешний вид задачи
  Color? _cardColor = Colors.indigo[300];
  final user = FirebaseAuth.instance.currentUser;

  void _showFullText(BuildContext context, String text) {
    // метод для чтения описания, если описание вышло очень длинным
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Полное описание'),
          content: Text(text),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Закрыть'),
            ),
          ],
        );
      },
    );
  }

  void _editTask() {// метод для редактирования задачи
    String tempTitle = widget.task.title;
    String tempDescription = widget.task.description;
    DateTime tempDate = widget.task.date;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Редактировать задачу'),
          contentPadding: const EdgeInsets.all(24),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: widget.task.title,
                  onChanged: (value) {
                    setState(() {
                      widget.task.title = value;
                    });
                  },
                  decoration:
                      const InputDecoration(labelText: 'Название задачи'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: widget.task.description,
                  onChanged: (value) {
                    setState(() {
                      widget.task.description = value;
                    });
                  },
                  decoration:
                      const InputDecoration(labelText: 'Описание задачи'),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Дата и время: ${widget.task.date.toString()}',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        showDatePicker(
                          context: context,
                          initialDate: widget.task.date,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        ).then((selectedDate) {
                          if (selectedDate != null) {
                            showTimePicker(
                              context: context,
                              initialTime:
                                  TimeOfDay.fromDateTime(widget.task.date),
                            ).then((selectedTime) {
                              if (selectedTime != null) {
                                setState(() {
                                  widget.task.date = DateTime(
                                    selectedDate.year,
                                    selectedDate.month,
                                    selectedDate.day,
                                    selectedTime.hour,
                                    selectedTime.minute,
                                  );
                                });
                              }
                            });
                          }
                        });
                      },
                      icon: Icon(Icons.calendar_today),
                    ),
                  ],
                )
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  widget.task.title = tempTitle;
                  widget.task.description = tempDescription;
                  widget.task.date = tempDate;
                });

                Navigator.pop(context);
              },
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: (){
                Navigator.pop(context);
              },
              child: const Text('Сохранить'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: _cardColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.task.title,
                    style: Theme.of(context).textTheme.headline4,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: _editTask,
                      icon: const Icon(Icons.edit_document),
                    ),
                    Checkbox(
                      value: widget.task.isCompleted,
                      onChanged: (newbool) {
                        setState(() {
                          widget.task.isCompleted = newbool!;
                          _cardColor = widget.task.isCompleted
                              ? Colors.green[300]
                              : Colors.indigo[300];
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      _showFullText(context, widget.task.description);
                    },
                    child: Text(
                      widget.task.description,
                      style: const TextStyle(fontSize: 15),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  widget.task.formattedDate,
                  style: const TextStyle(fontSize: 15),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
