import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:todo_app/config/constatnt.dart';
import 'package:todo_app/controller/historycontroller.dart';

import '../config/assets.dart';
import '../config/colors.dart';
import '../config/global_widget.dart';
import '../config/helpers/db_helper.dart';
import '../model/todo_model.dart';

class HomeController extends GetxController {
  var todoData = <TODO>[].obs;
  var isLoading = true.obs;

  var task = ''.obs;
  var description = ''.obs;
  var search = ''.obs;
  var date = Rxn<DateTime>();
  var time = Rxn<TimeOfDay>();
  var showDate = ''.obs;
  var showTime = ''.obs;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  TextEditingController taskCon = TextEditingController();
  TextEditingController descriptionCon = TextEditingController();
  TextEditingController searchCon = TextEditingController();
  RxBool on = true.obs;
  void toggle() {
    on.value = on.value ? false : true;
  }

  Timer? _timer;
  @override
  void onInit() {
    super.onInit();
    fetchDataFromDb();
    // fetchTasks();
    // fetchDataFromDb();
    // _timer = Timer.periodic(Duration(seconds: 5), (timer) => fetchDataFromDb());

    initializeNotifications();
  }

  var isLongPressActive = false.obs;
  StreamController<List<TODO>> homeStreamController =
      StreamController.broadcast();

  Stream<List<TODO>> get tasksStream async* {
    while (true) {
      fetchDataFromDb();
      yield filteredTasks;
      await Future.delayed(Duration(seconds: 1)); // Refresh every second
    }
  }

  Future<List<TODO>?> fetchDataFromDb() async {
    isLoading.value = true;
    todoData.value = await DBHelper.dbHelper.fetchTask() ?? [];
    log("Fetched Data: ${todoData}");

    todoData.sort((a, b) {
      DateTime dateA = parseDate(a.date, a.time);
      DateTime dateB = parseDate(b.date, b.time);
      return dateB.compareTo(dateA);
    });

    todoData.value = todoData.where((todo) {
      List<String> dateParts = todo.date.split('/');
      DateTime taskDate = DateTime(
        int.parse(dateParts[2]), // Year
        int.parse(dateParts[1]), // Month
        int.parse(dateParts[0]), // Day
      );

      List<String> timeParts = todo.time.split(':');
      int taskHour = int.parse(timeParts[0]);
      int taskMinute = int.parse(timeParts[1]);
      DateTime taskDateTime = DateTime(
        taskDate.year,
        taskDate.month,
        taskDate.day,
        taskHour,
        taskMinute,
      );

      DateTime now = DateTime.now();
      DateTime currentDate = DateTime(now.year, now.month, now.day);

      return taskDate.isAfter(currentDate) ||
          (taskDate.isAtSameMomentAs(currentDate) && taskDateTime.isAfter(now));
    }).toList();

    log("Filtered Data: ${todoData}");
    // homeStreamController.add(todoData);
    isLoading.value = false;
    return null;
  }

  void resetStream() {
    isLongPressActive.value = false;
  }
  // void fetchTasks() async {
  //   final tasks = await fetchDataFromDb();
  //   taskStreamController.add(tasks);
  //   log('taskStreamController==>>${taskStreamController}');
  // }

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

  RxList<Map<String, dynamic>> selectedCheckBoxes =
      <Map<String, dynamic>>[].obs;

  DateTime parseDate(String date, String time) {
    List<String> dateParts = date.split('/');
    List<String> timeParts = time.split(':');

    return DateTime(
      int.parse(dateParts[2]), // Year
      int.parse(dateParts[1]), // Month
      int.parse(dateParts[0]), // Day
      int.parse(timeParts[0]), // Hour
      int.parse(timeParts[1]), // Minute
    );
  }

  var fromDate = Rx<DateTime?>(null);
  var toDate = Rx<DateTime?>(null);

  List<TODO> get filteredTasks {
    List<TODO> filtered = todoData.where((todo) {
      final taskDate = parseDate(todo.date, todo.time);

      // Remove time from the date for comparison
      final taskDateOnly =
          DateTime(taskDate.year, taskDate.month, taskDate.day);

      // Search filter
      final matchesSearch =
          todo.task.toLowerCase().contains(search.value.toLowerCase());

      // Apply date filters only if the dates are selected
      final matchesFromDate = fromDate.value == null ||
          taskDateOnly.isAtSameMomentAs(fromDate.value!.toLocal()) ||
          taskDateOnly.isAfter(fromDate.value!.toLocal());

      final matchesToDate = toDate.value == null ||
          taskDateOnly.isAtSameMomentAs(toDate.value!.toLocal()) ||
          taskDateOnly.isBefore(toDate.value!.toLocal().add(Duration(days: 1)));

      return matchesSearch && matchesFromDate && matchesToDate;
    }).toList();

    // Sort the filtered tasks by date
    filtered.sort((a, b) {
      final dateA = parseDate(a.date, a.time);
      final dateB = parseDate(b.date, b.time);
      return dateA.compareTo(dateB); // Ascending order
    });

    return filtered;
  }

  void toggleCheckbox(TODO todo) async {
    TODO updatedTodo = TODO(
      id: todo.id,
      task: todo.task,
      description: todo.description,
      time: todo.time,
      date: todo.date,
      checked: todo.checked == 0 ? 1 : 0,
    );

    // if (todo.checked == 0) {
    //   primaryToast(msg: 'Task completed successfully!');
    // }
    await DBHelper.dbHelper.updateTodo(todo: updatedTodo, u_id: todo.id!);
    final index = todoData.indexWhere((t) => t.id == todo.id);
    if (index != -1) {
      todoData[index] = updatedTodo;
      todoData.refresh(); // Notify UI of the change
    }
    if (updatedTodo.checked == 1) {
      primaryToast(msg: 'Task completed successfully!');
    }
    fetchDataFromDb();
  }

  //add Task
  String formatDate(DateTime date) {
    String day = date.day.toString().padLeft(2, '0');
    String month = date.month.toString().padLeft(2, '0');
    String year = date.year.toString();

    return "$day/$month/$year";
  }

  Future<void> addTask() async {
    if (task.isNotEmpty &&
        description.isNotEmpty &&
        date.value != null &&
        time.value != null) {
      TODO todo = TODO(
          date: '${date.value?.day}/${date.value?.month}/${date.value?.year}',
          task: task.value,
          time: '${time.value?.hour}:${time.value?.minute}',
          description: description.value,
          checked: 0);
      int? id = await DBHelper.dbHelper.insertTodo(todo: todo);

      scheduleNotification(
        // id: notificationId,
        id: id!, // Unique ID
        title: 'Schedule Reminder',
        body: todo.task,
        scheduledDateTime: DateTime(
          date.value!.year,
          date.value!.month,
          date.value!.day,
          time.value!.hour,
          time.value!.minute,
        ),
      );
      primaryToast(msg: 'Task add successfully');
      fetchDataFromDb();
      Get.back();
      resetTaskInputs();
    } else {
      primaryToast(msg: 'Please Enter All Data..');
    }
  }

  /// Initialize Local Notifications
  void initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print("Notification Clicked: ${response.payload}");
      },
    );
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDateTime,
  }) async {
    // Convert DateTime to TZDateTime
    final tz.TZDateTime tzScheduledDateTime = tz.TZDateTime.from(
      scheduledDateTime,
      tz.local,
    );

    // Ensure the scheduled time is in the future
    if (tzScheduledDateTime.isBefore(tz.TZDateTime.now(tz.local))) {
      print('Scheduled time must be in the future: $tzScheduledDateTime');
      // primaryToast(msg: 'Scheduled time must be in the future.');
      return;
    }

    const AndroidNotificationDetails android = AndroidNotificationDetails(
      'task_channel',
      'Task Notifications',
      channelDescription: 'This channel is for task reminders',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails details = NotificationDetails(
      android: android,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tzScheduledDateTime,
      details,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exact,
    );
  }

  Future<void> deleteTask(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);

    await DBHelper.dbHelper.deleteTask(d_id: id);
    // todoData.removeAt(index);
    // filteredTasks.removeAt(index);
    fetchDataFromDb();
  }

  HistoryController historyController = Get.put(HistoryController());

  int checked = 0;
  Future<void> updateTask(TODO todo, i) async {
    HomeController homeController = Get.find();
    taskCon.text = todo.task;
    descriptionCon.text = todo.description;
    checked = todo.checked;
    log('checked==>>${checked}');
    List<String> dateParts = todo.date.split('/');
    date.value = DateTime(
      int.parse(dateParts[2]), // Year
      int.parse(dateParts[1]), // Month
      int.parse(dateParts[0]), // Day
    );
    showDate.value =
        '${date.value?.day}/${date.value?.month}/${date.value?.year}';

    List<String> timeParts = todo.time.split(':');
    time.value = TimeOfDay(
      hour: int.parse(timeParts[0]), // Hour
      minute: int.parse(timeParts[1]), // Minute
    );
    showTime.value = '${timeParts[0]}:${timeParts[1].padLeft(2, '0')}';
    // showTime.value = todo.time;
    RxBool tempChecked = (todo.checked == 1).obs; // Use RxBool for reactivity

    Get.defaultDialog(
      backgroundColor: Colors.white,
      titleStyle: commonStyle(fontSize: 20),
      titlePadding: 20.onlyTop, contentPadding: EdgeInsets.zero,
      // barrierDismissible: false,
      title: "Update To-Do",
      content: PopScope(
        canPop: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Divider(
                color: Colors.grey,
              ),
              10.height,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    commonField(
                      controller: homeController.taskCon,
                      hintText: "Update Title..",
                      getVal: (p0) {
                        homeController.task.value = p0;
                      },
                    ),
                    5.height,
                    commonField(
                      controller: homeController.descriptionCon,
                      hintText: "Update description..",
                      maxLines: 7,
                      getVal: (p0) {
                        homeController.description.value = p0;
                      },
                    ),
                    7.height,
                    Row(
                      children: [
                        Expanded(
                          child: Obx(
                            () => commonDialogBtn(
                                onTap: () {
                                  homeController.pickDate();
                                },
                                img: AppSvg.calender,
                                label: homeController.showDate.value.isEmpty
                                    ? "Pick Date"
                                    : homeController.showDate.value,
                                color: homeController.showDate.value.isEmpty
                                    ? AppColors.grey
                                    : Colors.black),
                          ),
                        ),
                        10.width,
                        Expanded(
                          child: Obx(
                            () => commonDialogBtn(
                                onTap: () {
                                  homeController.pickTime(
                                      isForCompletion: true);
                                },
                                img: AppSvg.watch,
                                label: homeController.showTime.value.isEmpty
                                    ? "Pick Time"
                                    : convertToAmPmFormat(
                                        homeController.showTime.value),
                                color: homeController.showTime.value.isEmpty
                                    ? AppColors.grey
                                    : Colors.black),
                          ),
                        ),
                      ],
                    ),
                    10.height,
                  ],
                ),
              ),
              Obx(() => Row(
                    children: [
                      Radio<bool>(
                        value: true,
                        groupValue: tempChecked.value,
                        onChanged: (value) async {
                          tempChecked.value = true;
                          await flutterLocalNotificationsPlugin
                              .cancel(todo.id!);
                          final now = DateTime.now();
                          final pickedDateTime = DateTime(
                            date.value!.year,
                            date.value!.month,
                            date.value!.day,
                            time.value!.hour,
                            time.value!.minute,
                          );
                          await flutterLocalNotificationsPlugin
                              .cancel(todo.id!);
                          scheduleNotification(
                            id: todo.id!,
                            title: 'Schedule Reminder',
                            body: todo.task,
                            scheduledDateTime: pickedDateTime,
                          );

                          log('updatedTodo.checked==>>${tempChecked.value}');
                        },
                        activeColor: AppColors.primaryColor,
                      ),
                      Text(
                        'Complete',
                        style: TextStyle(fontSize: 10),
                      ),
                      Radio<bool>(
                        value: false,
                        groupValue: tempChecked.value,
                        onChanged: (value) async {
                          tempChecked.value = false;
                          log('updatedTodo.checked==>>${tempChecked.value}');
                        },
                        activeColor: AppColors.primaryColor,
                      ),
                      Text(
                        'Pending',
                        style: TextStyle(fontSize: 10),
                      ),
                    ],
                  )),
              Padding(
                padding: 10.onlyBottom,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    primaryBtn(
                      label: 'Cancel',
                      onPressed: () {
                        Get.back();
                        resetTaskInputs();
                      },
                    ),
                    // primaryBtn(
                    //   label: 'Delete',
                    //   onPressed: () {
                    //     deleteDialog(
                    //       label: "Are you sure you want to delete the task?",
                    //       deleteOnTap: () async {
                    //         deleteTask(
                    //           todo.id!,
                    //           i,
                    //         );
                    //         fetchDataFromDb();
                    //
                    //         Get.back();
                    //       },
                    //       cancelOnTap: () {
                    //         selectedTasks.clear();
                    //         Get.back();
                    //       },
                    //     );
                    //   },
                    // ),
                    primaryBtn(
                        onPressed: () async {
                          try {
                            if (taskCon.text.isEmpty ||
                                descriptionCon.text.isEmpty) {
                              primaryToast(msg: 'Please Enter All Fields..');
                            } else {
                              // Validate the date and time
                              final now = DateTime.now();
                              final pickedDateTime = DateTime(
                                date.value!.year,
                                date.value!.month,
                                date.value!.day,
                                time.value!.hour,
                                time.value!.minute,
                              );
                              log("updateCheck==>>${checked}");
                              String updatedTime;
                              if (tempChecked.value) {
                                updatedTime =
                                    '${now.hour}:${now.minute.toString().padLeft(2, '0')}';
                              } else {
                                updatedTime =
                                    '${time.value?.hour}:${time.value?.minute.toString().padLeft(2, '0')}';
                              }

                              TODO updatedTodo = TODO(
                                id: todo.id,
                                task: taskCon.text,
                                description: descriptionCon.text,
                                date:
                                    '${date.value?.day}/${date.value?.month}/${date.value?.year}',
                                time: updatedTime,
                                checked: tempChecked.value ? 1 : 0,
                              );

                              var res = await DBHelper.dbHelper.updateTodo(
                                todo: updatedTodo,
                                u_id: todo.id!,
                              );

                              await fetchDataFromDb();
                              historyController.fetchHistory();

                              if(tempChecked.value ==false){
                                await flutterLocalNotificationsPlugin
                                    .cancel(todo.id!);
                                scheduleNotification(
                                  id: todo.id!,
                                  title: 'Schedule Reminder',
                                  body: todo.task,
                                  scheduledDateTime: pickedDateTime,
                                );
                              }


                              primaryToast(msg: 'Task updated successfully');
                              Get.back();
                              resetTaskInputs();
                            }
                          } on Exception catch (e) {
                            log('error==>>${e}');
                          }
                        },
                        label: "Update"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      // confirm: Padding(
      //   padding: 10.onlyBottom,
      //   child: Row(
      //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      //     children: [
      //       primaryBtn(
      //         label: 'Cancel',
      //         onPressed: () {
      //           Get.back();
      //           resetTaskInputs();
      //         },
      //       ),
      //       // primaryBtn(
      //       //   label: 'Delete',
      //       //   onPressed: () {
      //       //     deleteDialog(
      //       //       label: "Are you sure you want to delete the task?",
      //       //       deleteOnTap: () async {
      //       //         deleteTask(
      //       //           todo.id!,
      //       //           i,
      //       //         );
      //       //         fetchDataFromDb();
      //       //
      //       //         Get.back();
      //       //       },
      //       //       cancelOnTap: () {
      //       //         selectedTasks.clear();
      //       //         Get.back();
      //       //       },
      //       //     );
      //       //   },
      //       // ),
      //       primaryBtn(
      //           onPressed: () async {
      //             try {
      //               if (taskCon.text.isEmpty || descriptionCon.text.isEmpty) {
      //                 primaryToast(msg: 'Please Enter All Fields..');
      //               } else {
      //                 // Validate the date and time
      //                 final now = DateTime.now();
      //                 final pickedDateTime = DateTime(
      //                   date.value!.year,
      //                   date.value!.month,
      //                   date.value!.day,
      //                   time.value!.hour,
      //                   time.value!.minute,
      //                 );
      //                 log("updateCheck==>>${checked}");
      //                 String updatedTime;
      //                 if (tempChecked.value) {
      //                   updatedTime =
      //                       '${now.hour}:${now.minute.toString().padLeft(2, '0')}';
      //                 } else {
      //                   updatedTime =
      //                       '${time.value?.hour}:${time.value?.minute.toString().padLeft(2, '0')}';
      //                 }
      //
      //                 TODO updatedTodo = TODO(
      //                   id: todo.id,
      //                   task: taskCon.text,
      //                   description: descriptionCon.text,
      //                   date:
      //                       '${date.value?.day}/${date.value?.month}/${date.value?.year}',
      //                   time: updatedTime,
      //                   checked: tempChecked.value ? 1 : 0,
      //                 );
      //
      //                 var res = await DBHelper.dbHelper.updateTodo(
      //                   todo: updatedTodo,
      //                   u_id: todo.id!,
      //                 );
      //
      //                 await fetchDataFromDb();
      //                 historyController.fetchHistory();
      //                 await flutterLocalNotificationsPlugin.cancel(todo.id!);
      //                 scheduleNotification(
      //                   id: todo.id!,
      //                   title: 'Schedule Reminder',
      //                   body: todo.task,
      //                   scheduledDateTime: pickedDateTime,
      //                 );
      //
      //                 primaryToast(msg: 'Task updated successfully');
      //                 Get.back();
      //                 resetTaskInputs();
      //               }
      //             } on Exception catch (e) {
      //               log('error==>>${e}');
      //             }
      //           },
      //           label: "Update"),
      //     ],
      //   ),
      // )
    );
  }

  void resetTaskInputs() {
    taskCon.clear();
    descriptionCon.clear();
    task.value = '';
    description.value = '';
    date.value = null;
    time.value = null;
    checked = 0;
    showDate.value = '';
    showTime.value = '';
  }

  Future<void> pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: Get.context!,
      // initialDate: date.value ?? DateTime.now(),
      initialDate: DateTime.now(),
      // firstDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2040),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData(
            primaryColor:
                AppColors.primaryColor, // Replace with your primary color
            colorScheme: ColorScheme.light(
              primary: AppColors
                  .primaryColor, // Header background color and active color
              onPrimary: Colors.white, // Text color on the header
              onSurface: Colors.black, // Default text color
            ),
            dialogBackgroundColor: Colors.white,
            datePickerTheme: DatePickerThemeData(
              headerBackgroundColor: AppColors.primaryColor,
              headerForegroundColor: Colors.white,
              rangePickerSurfaceTintColor: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null) {
      date.value = pickedDate;
      showDate.value =
          '${pickedDate.day}/${pickedDate.month}/${pickedDate.year}';
    }
  }

  Future<void> pickTime({bool isForCompletion = false}) async {
    final now = DateTime.now();

    if (date.value == null) {
      primaryToast(msg: 'Please select a date first.');
      return;
    }

    final isToday = date.value!.year == now.year &&
        date.value!.month == now.month &&
        date.value!.day == now.day;

    TimeOfDay? pickedTime = await showTimePicker(
      context: Get.context!,
      initialTime: time.value ?? TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData(
            primaryColor: AppColors.primaryColor,
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryColor.withOpacity(0.9),
              onPrimary: Colors.white, // Text color on the header
              onSurface: Colors.black, // Default text color
            ),
            timePickerTheme: TimePickerThemeData(
              dayPeriodTextColor: MaterialStateColor.resolveWith((states) =>
                  states.contains(MaterialState.selected)
                      ? Colors.white
                      : Colors.black), // Text color for AM/PM
              dayPeriodColor: MaterialStateColor.resolveWith((states) =>
                  states.contains(MaterialState.selected)
                      ? AppColors.primaryColor
                      : Colors.grey.shade200), // Background color for AM/PM
              dayPeriodShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8), // Optional shape
              ),
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      final pickedDateTime = DateTime(
        date.value!.year,
        date.value!.month,
        date.value!.day,
        pickedTime.hour,
        pickedTime.minute,
      );

      if (!isForCompletion && isToday && pickedDateTime.isBefore(now)) {
        primaryToast(msg: 'Please select a future time for today.');
      } else {
        time.value = pickedTime;
        showTime.value = formatTime(pickedTime);
      }

      // if (isToday && pickedDateTime.isBefore(now)) {
      //   primaryToast(msg: 'Please select a future time for today.');
      // } else {
      //   // Valid time picked
      //   time.value = pickedTime;
      //   showTime.value = formatTime(pickedTime);
      //   // showTime.value =
      //   //     '${pickedTime.hour}:${pickedTime.minute.toString().padLeft(2, '0')}';
      // }
    }
  }

  final RxBool isSelectionMode = false.obs;
  var selectedTasks = <TODO>[].obs;
  void toggleTaskSelection(TODO todo) {
    if (selectedTasks.contains(todo)) {
      selectedTasks.remove(todo);
    } else {
      selectedTasks.add(todo);
    }
  }

  String formatTime(TimeOfDay timeOfDay) {
    final now = DateTime.now();
    final dt = DateTime(
      now.year,
      now.month,
      now.day,
      timeOfDay.hour,
      timeOfDay.minute,
    );
    return DateFormat.jm().format(dt); // Returns time in AM/PM format
  }

  Future<void> fromDateMethod(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: fromDate.value ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData(
            primaryColor:
                AppColors.primaryColor, // Replace with your primary color
            colorScheme: ColorScheme.light(
              primary: AppColors
                  .primaryColor, // Header background color and active color
              onPrimary: Colors.white, // Text color on the header
              onSurface: Colors.black, // Default text color
            ),
            dialogBackgroundColor: Colors.white,
            datePickerTheme: DatePickerThemeData(
              headerBackgroundColor: AppColors.primaryColor,
              headerForegroundColor: Colors.white,
              rangePickerSurfaceTintColor: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null) {
      fromDate.value = pickedDate;
    }
  }

  Future<void> toDateMethod(BuildContext context) async {
    DateTime? firstDate =
        fromDate.value != null ? fromDate.value! : DateTime(2000);
    DateTime initialDate = toDate.value ?? fromDate.value ?? DateTime.now();
    if (fromDate.value != null && initialDate.isBefore(fromDate.value!)) {
      initialDate = fromDate.value!;
    }
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime(2100),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData(
            primaryColor:
                AppColors.primaryColor, // Replace with your primary color
            colorScheme: ColorScheme.light(
              primary: AppColors
                  .primaryColor, // Header background color and active color
              onPrimary: Colors.white, // Text color on the header
              onSurface: Colors.black, // Default text color
            ),
            dialogBackgroundColor: Colors.white,
            datePickerTheme: DatePickerThemeData(
              headerBackgroundColor: AppColors.primaryColor,
              headerForegroundColor: Colors.white,
              rangePickerSurfaceTintColor: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      toDate.value = pickedDate;
    }
  }

  @override
  void onClose() {
    homeStreamController.close();
    super.onClose();
  }
}
