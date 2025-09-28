import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:todo_app/config/colors.dart';
import 'package:todo_app/config/constatnt.dart';
import 'package:todo_app/view/history.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/assets.dart';
import '../config/global_widget.dart';
import '../controller/home_controller.dart';
import '../model/todo_model.dart';

class Home extends StatelessWidget {
  HomeController controller = Get.put(HomeController());
  // HistoryController historyController = Get.put(HistoryController());
  @override
  Widget build(BuildContext context) {
    String shareApp = "https://play.google.com/store/games?device=windows";
    // controller.fetchDataFromDb();
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) {
          return;
        }
        confirmDialog();
      },
      child: Scaffold(
        backgroundColor: AppColors.scaffoldColor,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          toolbarHeight: 9.heightBox(), surfaceTintColor: AppColors.white,
          automaticallyImplyLeading: false,
          backgroundColor: AppColors.primaryColor.withOpacity(0.4),
          // shape: RoundedRectangleBorder(
          //     borderRadius: BorderRadius.vertical(bottom: Radius.circular(30))),
          title: Text(
            "To-Do App",
            style: commonStyle(
              fontSize: 23,
              fontWeight: FontWeight.w400,
              color: AppColors.black,
            ),
          ),
          centerTitle: true,
          actions: [
            PopupMenuButton(
                color: AppColors.white,
                itemBuilder: (context) {
                  return [
                    PopupMenuItem(
                        child: Text(
                          "Previous Tasks",
                          style: commonStyle(
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        onTap: () async {
                          Get.to(
                            () => HistoryScreen(),
                          );
                        }),
                    // PopupMenuItem(
                    //     child: Text(
                    //       "Take google drive backup",
                    //       style: commonStyle(
                    //         fontWeight: FontWeight.w400,
                    //       ),
                    //     ),
                    //     onTap: () async {
                    //       var dbPath =
                    //           await DBHelper.dbHelper.getDatabasePath();
                    //       log('dbPath==>>${dbPath}');
                    //       //==>> /data/user/0/com.example.todo_app/databases/demo.db
                    //       await bckp.CreateBackup().uploadToNormal(context);
                    //     }),
                    // PopupMenuItem(
                    //     child: Text(
                    //       "Sync now",
                    //       style: commonStyle(
                    //         fontWeight: FontWeight.w400,
                    //       ),
                    //     ),
                    //     onTap: () {
                    //       Get.to(() => RestoreDriveFileList());
                    //     }),
                    PopupMenuItem(
                        child: Text(
                          "Rate App",
                          style: commonStyle(
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        onTap: () async {
                          if (await canLaunch(shareApp)) {
                            await launch(shareApp);
                          } else {
                            throw 'Could not launch $shareApp';
                          }
                        }),
                    PopupMenuItem(
                        child: Text(
                          "Share App",
                          style: commonStyle(
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        onTap: () {
                          Share.share(shareApp);
                        }),
                  ];
                },
                child: Icon(
                  Icons.more_vert_outlined,
                  size: 28,
                  color: AppColors.black,
                )),
            10.width,
          ],
        ),
        floatingActionButton: FloatingActionButton
            // .extended
            (
          backgroundColor: AppColors.primaryColor,
          onPressed: () {
            controller.selectedTasks.clear();
            Get.defaultDialog(
              titleStyle: commonStyle(fontSize: 20),
              titlePadding: 20.onlyTop,
              backgroundColor: Colors.white,
              barrierDismissible: false,
              title: "Add To-Do",
              content: PopScope(
                canPop: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Divider(
                      color: Colors.grey,
                    ),
                    5.height,
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          commonField(
                              controller: controller.taskCon,
                              hintText: 'Add Title',
                              getVal: (val) {
                                controller.task.value = val;
                              }),
                          7.height,
                          commonField(
                              controller: controller.descriptionCon,
                              maxLines: 10,
                              hintText: 'Add Description..',
                              getVal: (val) {
                                controller.description.value = val;
                              }),
                          7.height,
                          Row(
                            children: [
                              Expanded(
                                child: Obx(
                                  () => commonDialogBtn(
                                      onTap: () {
                                        controller.pickDate();
                                      },
                                      img: AppSvg.calender,
                                      label: controller.showDate.value.isEmpty
                                          ? "Pick Date"
                                          : controller.showDate.value,
                                      color: controller.showDate.value.isEmpty
                                          ? AppColors.grey
                                          : Colors.black),
                                ),
                              ),
                              10.width,
                              Expanded(
                                child: Obx(
                                  () => commonDialogBtn(
                                      onTap: () {
                                        controller.pickTime();
                                      },
                                      img: AppSvg.watch,
                                      label: controller.showTime.value.isEmpty
                                          ? "Pick Time"
                                          : controller.showTime.value,
                                      color: controller.showTime.value.isEmpty
                                          ? AppColors.grey
                                          : Colors.black),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              confirm: Padding(
                padding: 7.onlyBottom,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    primaryBtn(
                      label: 'Cancel',
                      onPressed: () {
                        controller.taskCon.clear();
                        controller.task.isEmpty;
                        controller.date.value = null;
                        controller.showDate.value = '';
                        controller.time.value = null;
                        controller.showTime.value = '';
                        Get.back();
                      },
                    ),
                    primaryBtn(
                        onPressed: () {
                          controller.addTask();
                        },
                        label: "Add"),
                  ],
                ),
              ),
            );
          },
          child: Icon(
            Icons.add,
            color: Constant.white,
          ),
        ),
        body: StreamBuilder<List<TODO>>(
            stream: controller.tasksStream,
            // initialData: controller.todoData,
            builder: (context, AsyncSnapshot snapshot) {
              log('snapshot.data==>>${snapshot.data}');
              // controller.fetchDataFromDb();
              // controller.todoData;
              if (snapshot.hasError) {
                return Center(child: Text("${snapshot.error}"));
              } else if (snapshot.hasData) {
                return Builder(
                  builder: (BuildContext context) {
                    // var filteredTasks = controller.filteredTasks;
                    List<TODO> filteredTasks = snapshot.data!;

                    return controller.todoData.isEmpty
                        ? Center(
                            child: Image.asset(
                              Assets.emptyList,
                              height: 30.heightBox(),
                              width: 50.widthBox(),
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              16.height,
                              searchField(),
                              16.height,
                              Padding(
                                padding: EdgeInsets.only(
                                    right: controller.toDate.value != null ||
                                            controller.fromDate.value != null
                                        ? 0
                                        : 16),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Obx(
                                        () => commonFromDate(
                                          onTap: () async {
                                            controller.fromDateMethod(context);
                                          },
                                          isCheck:
                                              controller.fromDate.value != null,
                                          date: controller.fromDate.value !=
                                                  null
                                              ? "${controller.formatDate(controller.fromDate.value!)}"
                                              : " ",
                                          label:
                                              controller.fromDate.value != null
                                                  ? ''
                                                  : 'From',
                                          deleteOnTap: () {
                                            controller.fromDate.value = null;
                                          },
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: commonFromDate(
                                          deleteOnTap: () {
                                            // controller.toDate.value = null;
                                            controller.toDate.value = null;
                                          },
                                          onTap: () async {
                                            controller.toDateMethod(context);
                                          },
                                          isCheck:
                                              controller.toDate.value != null,
                                          date: controller.toDate.value != null
                                              ? "${controller.formatDate(controller.toDate.value!)}"
                                              : " ",
                                          label: controller.toDate.value != null
                                              ? ''
                                              : 'To'),
                                    ),
                                    Visibility(
                                      visible:
                                          controller.toDate.value != null ||
                                              controller.fromDate.value != null,
                                      child: IconButton(
                                        onPressed: () {
                                          controller.toDate.value = null;
                                          controller.fromDate.value = null;
                                        },
                                        icon: Icon(
                                          Icons.close,
                                          color: AppColors.grey,
                                          size: 2.5.heightBox(),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              16.height,
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: 10.onlyRight,
                                    child: Icon(
                                      Icons.check_circle,
                                      size: 2.heightBox(),
                                      color: Colors.green,
                                    ),
                                  ),
                                  Text(
                                    'Complete',
                                    style: commonStyle(
                                        fontWeight: FontWeight.w400,
                                        color: AppColors.grey),
                                  ),
                                  16.width,
                                  Padding(
                                    padding: 10.onlyRight,
                                    child: SvgPicture.asset(
                                      AppSvg.pending,
                                      height: 1.7.heightBox(),
                                      color: Colors.red,
                                    ),
                                  ),
                                  Text(
                                    'Pending',
                                    style: commonStyle(
                                        fontWeight: FontWeight.w400,
                                        color: AppColors.grey),
                                  ),
                                ],
                              ),
                              10.height,
                              controller.filteredTasks.isEmpty
                                  ? Expanded(
                                      child: Center(
                                        child: Image.asset(
                                          Assets.emptyList,
                                          height: 30.heightBox(),
                                          width: 50.widthBox(),
                                        ),
                                      ),
                                    )
                                  : Expanded(
                                      child: ListView.builder(
                                        padding: EdgeInsets.only(
                                            top: 5,
                                            left: 16,
                                            right: 16,
                                            bottom: 70),
                                        itemCount: filteredTasks.length,
                                        itemBuilder: (context, i) {
                                          // var todo = filteredTasks[i];
                                          var todo = filteredTasks[i];

                                          return Padding(
                                            padding: 16.onlyBottom,
                                            child: Obx(
                                              () => Container(
                                                decoration: BoxDecoration(
                                                  color: controller
                                                          .selectedTasks
                                                          .contains(todo)
                                                      ? Colors.blue.shade50
                                                      : AppColors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: AppColors.grey
                                                          .withOpacity(0.1),
                                                      spreadRadius: -1,
                                                      blurRadius: 3,
                                                    ),
                                                  ],
                                                ),
                                                child: ListTile(
                                                  contentPadding:
                                                      EdgeInsets.zero,
                                                  title: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                            flex: 5,
                                                            child: Text(
                                                              "${todo.task}",
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: commonStyle(
                                                                  fontSize: 18,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500),
                                                            ),
                                                          ),
                                                          Expanded(
                                                            flex: 1,
                                                            child:
                                                                GestureDetector(
                                                              child: Icon(
                                                                Icons.edit,
                                                                size: 2.3
                                                                    .heightBox(),
                                                                color: AppColors
                                                                    .black,
                                                              ),
                                                              onTap: () {
                                                                // Get.back();
                                                                controller
                                                                    .updateTask(
                                                                        todo,
                                                                        i);
                                                              },
                                                            ),
                                                          ),
                                                          Expanded(
                                                            flex: 1,
                                                            child:
                                                                GestureDetector(
                                                              child: Icon(
                                                                Icons.delete,
                                                                size: 2.5
                                                                    .heightBox(),
                                                                color: AppColors
                                                                    .black,
                                                              ),
                                                              onTap: () {
                                                                deleteDialog(
                                                                  label:
                                                                      "Are you sure you want to delete the task?",
                                                                  deleteOnTap:
                                                                      () async {
                                                                    controller
                                                                        .deleteTask(
                                                                      todo.id!,
                                                                    );
                                                                    await controller
                                                                        .fetchDataFromDb();

                                                                    Get.back();
                                                                  },
                                                                  cancelOnTap:
                                                                      () {
                                                                    controller
                                                                        .selectedTasks
                                                                        .clear();
                                                                    Get.back();
                                                                  },
                                                                );
                                                              },
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Text(
                                                        todo.description,
                                                        // overflow: TextOverflow.ellipsis,
                                                        style: commonStyle(
                                                            fontSize: 15,
                                                            color: AppColors
                                                                .black
                                                                .withOpacity(
                                                                    0.6),
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                      ),
                                                      5.height,
                                                    ],
                                                  ),
                                                  leading: Padding(
                                                    padding: 16.onlyLeft,
                                                    child: Text("${i + 1}",
                                                        style: commonStyle(
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight.w500
                                                            // fontWeight:
                                                            //     FontWeight.w200,
                                                            // color: AppColors.grey,
                                                            )),
                                                  ),

                                                  subtitle: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    // mainAxisAlignment: MainAxisAlignment.start,
                                                    children: [
                                                      Expanded(
                                                        flex: 5,
                                                        child: commonDateTime(
                                                            label:
                                                                "${todo.date}",
                                                            img: AppSvg
                                                                .calender),
                                                      ),
                                                      10.width,
                                                      Expanded(
                                                        flex: 5,
                                                        child: commonDateTime(
                                                            label:
                                                                "${controller.convertToAmPmFormat(todo.time)}",
                                                            img: AppSvg.watch),
                                                      ),
                                                      Expanded(
                                                        child: todo.checked == 1
                                                            ? Padding(
                                                                padding: 10
                                                                    .onlyRight,
                                                                child: Icon(
                                                                  Icons
                                                                      .check_circle,
                                                                  size: 2
                                                                      .heightBox(),
                                                                  color: Colors
                                                                      .green,
                                                                ),
                                                              )
                                                            : Padding(
                                                                padding: 10
                                                                    .onlyRight,
                                                                child:
                                                                    SvgPicture
                                                                        .asset(
                                                                  AppSvg
                                                                      .pending,
                                                                  height: 1.7
                                                                      .heightBox(),
                                                                  color: Colors
                                                                      .red,
                                                                ),
                                                              ),
                                                      ),
                                                    ],
                                                  ),
                                                  // trailing: Padding(
                                                  //   padding: 16.onlyRight,
                                                  //   child: Column(
                                                  //     // clipBehavior: Clip.none,
                                                  //     mainAxisAlignment:
                                                  //         MainAxisAlignment
                                                  //             .start,
                                                  //     children: [
                                                  //       GestureDetector(
                                                  //         child: Icon(
                                                  //           Icons.edit,
                                                  //           size:
                                                  //               2.heightBox(),
                                                  //           color: AppColors
                                                  //               .black,
                                                  //         ),
                                                  //         onTap: () {
                                                  //           Get.back();
                                                  //           controller
                                                  //               .updateTask(
                                                  //                   todo);
                                                  //         },
                                                  //       ),
                                                  //       5.height,
                                                  //       GestureDetector(
                                                  //         child: Icon(
                                                  //           Icons.delete,
                                                  //           size:
                                                  //               2.heightBox(),
                                                  //           color: AppColors
                                                  //               .black,
                                                  //         ),
                                                  //         onTap: () {
                                                  //           deleteDialog(
                                                  //             label:
                                                  //                 "Are you sure you want to delete the task?",
                                                  //             deleteOnTap:
                                                  //                 () async {
                                                  //               controller
                                                  //                   .deleteTask(
                                                  //                 todo.id!,
                                                  //                 i,
                                                  //               );
                                                  //               await controller
                                                  //                   .fetchDataFromDb();
                                                  //
                                                  //               Get.back();
                                                  //             },
                                                  //             cancelOnTap:
                                                  //                 () {
                                                  //               controller
                                                  //                   .selectedTasks
                                                  //                   .clear();
                                                  //               Get.back();
                                                  //             },
                                                  //           );
                                                  //         },
                                                  //       ),
                                                  //     ],
                                                  //   ),
                                                  // ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                            ],
                          );
                  },
                );
              }
              return Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryColor.withOpacity(0.5),
                ),
              );
            }),
      ),
    );
  }
}
