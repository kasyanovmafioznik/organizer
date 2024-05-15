import 'package:flutter/material.dart';
import 'package:to_do_list/models/task.dart';

class NewTask extends StatefulWidget {
  const NewTask(void Function(Task task) addTask,
      {Key? key, required this.onAddTask})
      : super(key: key);
  final void Function(Task task) onAddTask;

  @override
  State<NewTask> createState() => _NewTaskState();
}

class _NewTaskState extends State<NewTask> { // класс формирующий окно для добавления информации о новой задаче
  final _titleController = TextEditingController();
  final _describeController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  void _presentDatePicker() async { // метод для определения даты 
    final now = DateTime.now();
    final firstDate = DateTime.now();
    final pickerDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: firstDate,
      lastDate: DateTime(2101),
    );

    if (pickerDate != null) {
      final pickerTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      setState(() {
        _selectedDate = pickerDate;
        _selectedTime = pickerTime;
      });
    }
  }

  void _submitTaskData() { // метод для подтверждения сохранения задачи
    if (_titleController.text.trim().isEmpty ||
        _describeController.text.trim().isEmpty ||
        _selectedDate == null ||
        _selectedTime == null) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Вы забыли что-то заполнить'),
          content: const Text(
              'Пожалуйста, перепроверьте, не остались ли пустые строки'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
              },
              child: const Text('Окей'),
            )
          ],
        ),
      );
      return;
    }

    final selectedDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    widget.onAddTask(Task(
      title: _titleController.text,
      description: _describeController.text,
      date: selectedDateTime,
    ));
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _describeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardSpace = MediaQuery.of(context).viewInsets.bottom;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Новая задача'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Название'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _describeController,
                maxLength: 150,
                decoration: const InputDecoration(labelText: 'Описание'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedDate == null
                          ? 'Дата не выбрана'
                          : 'Дата: ${_selectedDate!.day}.${_selectedDate!.month}.${_selectedDate!.year}.${_selectedTime!.hour}:${_selectedTime!.minute}',
                    ),
                  ),
                  IconButton(
                    onPressed: _presentDatePicker,
                    icon: const Icon(Icons.calendar_today),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (!isSmallScreen) const Spacer(),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Отмена'),
                  ),
                  ElevatedButton(
                    onPressed: _submitTaskData,
                    child: const Text('Сохранить задачу'),
                  ),
                ],
              ),
              SizedBox(height: keyboardSpace),
            ],
          ),
        ),
      ),
    );
  }
}
