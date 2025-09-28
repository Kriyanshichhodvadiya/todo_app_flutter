import 'dart:async';
import 'dart:developer';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../config/helpers/db_helper.dart';
import '../model/todo_model.dart';

class HistoryController extends GetxController {
  var historyTasks = <TODO>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    // fetchHistory();
    super.onInit();
  }

  StreamController<List<TODO>> historyStreamController =
      StreamController<List<TODO>>.broadcast();

  Stream<List<TODO>> get tasksStream async* {
    while (true) {
      fetchHistory();
      yield historyTasks;
      await Future.delayed(Duration(milliseconds: 800)); // Refresh every second
    }
  }

  Future<void> fetchHistory() async {
    isLoading.value = true;
    final tasks = await DBHelper.dbHelper.fetchTask();

    // Filter tasks that are from today or in the past
    historyTasks.value = (tasks?.where((todo) {
          List<String> dateParts = todo.date.split('/');
          DateTime taskDate = DateTime(
            int.parse(dateParts[2]), // Year
            int.parse(dateParts[1]), // Month
            int.parse(dateParts[0]), // Day
          );

          // Get the current date
          DateTime now = DateTime.now();
          DateTime currentDate = DateTime(now.year, now.month, now.day);

          if (taskDate.isBefore(currentDate) ||
              taskDate.isAtSameMomentAs(currentDate)) {
            if (taskDate.isAtSameMomentAs(currentDate)) {
              // Convert todo.time (hh:mm format) into a DateTime object
              List<String> timeParts = todo.time.split(':');
              DateTime taskTime = DateTime(now.year, now.month, now.day,
                  int.parse(timeParts[0]), int.parse(timeParts[1]));

              // Compare with current time, show task only if time is in the past
              DateTime currentTime = DateTime.now();
              return taskTime.isBefore(currentTime);
            }
            return true; // If the date is in the past, show it
          }
          return false; // Exclude future tasks
        }).toList() ??
        []);

    // Sort tasks in descending order by date and time
    historyTasks.sort((a, b) {
      DateTime taskADateTime = getTaskDateTime(a);
      DateTime taskBDateTime = getTaskDateTime(b);
      return taskBDateTime.compareTo(taskADateTime); // Descending order
    });

    log('historyTasks==>>${historyTasks}');
    isLoading.value = false;
  }

// Helper function to create DateTime from task date and time
  DateTime getTaskDateTime(TODO task) {
    List<String> dateParts = task.date.split('/');
    List<String> timeParts = task.time.split(':');
    DateTime taskDate = DateTime(
      int.parse(dateParts[2]), // Year
      int.parse(dateParts[1]), // Month
      int.parse(dateParts[0]), // Day
      int.parse(timeParts[0]), // Hour
      int.parse(timeParts[1]), // Minute
    );
    return taskDate;
  }

  // Future<void> fetchHistory() async {
  //   isLoading.value = true;
  //   final tasks = await DBHelper.dbHelper.fetchTask();
  //   historyTasks.value = tasks?.where((todo) {
  //         List<String> dateParts = todo.date.split('/');
  //         DateTime taskDate = DateTime(
  //           int.parse(dateParts[2]), // Year
  //           int.parse(dateParts[1]), // Month
  //           int.parse(dateParts[0]), // Day
  //         );
  //
  //         // Get the current date
  //         DateTime now = DateTime.now();
  //         DateTime currentDate = DateTime(now.year, now.month, now.day);
  //         if (taskDate.isBefore(currentDate) ||
  //             taskDate.isAtSameMomentAs(currentDate)) {
  //           if (taskDate.isAtSameMomentAs(currentDate)) {
  //             // Convert todo.time (hh:mm format) into a DateTime object
  //             List<String> timeParts = todo.time.split(':');
  //             DateTime taskTime = DateTime(now.year, now.month, now.day,
  //                 int.parse(timeParts[0]), int.parse(timeParts[1]));
  //
  //             // Compare with current time, show task only if time is in the past
  //             DateTime currentTime = DateTime.now();
  //             return taskTime.isBefore(currentTime);
  //           }
  //           return true; // If the date is in the past, show it
  //         }
  //         return false; // Exclude future tasks
  //       }).toList() ??
  //       [];
  //   // historyStreamController.add(historyTasks);
  //
  //   log('historyTasks==>>${historyTasks}');
  //   isLoading.value = false;
  // }

  // void deleteTaskFromHistory(int id) async {
  //   await DBHelper.dbHelper.deleteTaskFromHistory(d_id: id);
  //   fetchHistory();
  // }
  var selectedTasks = <TODO>[].obs;
  void toggleTaskSelection(TODO todo) {
    if (selectedTasks.contains(todo)) {
      selectedTasks.remove(todo);
    } else {
      selectedTasks.add(todo);
    }
  }

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  String convertToAmPmFormat(String time) {
    try {
      final timeParts = time.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      final dateTime = DateTime(0, 0, 0, hour, minute);
      final formattedTime = DateFormat.jm().format(dateTime);
      return formattedTime;
    } catch (e) {
      return time;
    }
  }

  @override
  void onClose() {
    historyStreamController.close();
    super.onClose();
  }
}
