import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:todo_app/config/constatnt.dart';
import 'package:todo_app/controller/home_controller.dart';
import 'package:todo_app/view/home.dart';

import '../config/assets.dart';
import '../config/colors.dart';
import '../config/global_widget.dart';
import '../controller/historycontroller.dart';
import '../model/todo_model.dart';

class HistoryScreen extends StatelessWidget {
  HistoryController controller = Get.put(HistoryController());
  HomeController homeController = Get.find();

  @override
  Widget build(BuildContext context) {
    controller.selectedTasks.clear();
    // controller.fetchHistory();
    return WillPopScope(
      onWillPop: () async {
        Get.to(() => Home());
        return false;
      },
      child: Scaffold(
        backgroundColor: AppColors.scaffoldColor,
        appBar: AppBar(
          toolbarHeight: 9.heightBox(),
          surfaceTintColor: AppColors.white,
          backgroundColor: AppColors.primaryColor.withOpacity(0.4),
          title: Text(
            "Previous Tasks",
            style: commonStyle(
              fontSize: 23,
              fontWeight: FontWeight.w400,
              color: AppColors.black,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            onPressed: () {
              Get.to(() => Home());
            },
            icon: Icon(Icons.arrow_back),
          ),
        ),
        body: StreamBuilder<List<TODO>>(
          stream: controller.tasksStream,
          builder: (context, AsyncSnapshot snapshot) {
            log('snapshot.data==>>${snapshot.data}');

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  "${snapshot.error}",
                  style: commonStyle(fontSize: 16, color: Colors.red),
                ),
              );
            } else if (snapshot.hasData) {
              return snapshot.data!.isEmpty
                  ? Center(
                      child: Image.asset(
                        Assets.emptyList,
                        height: 30.heightBox(),
                        width: 50.widthBox(),
                      ),
                    )
                  : Column(
                      children: [
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
                        16.height,
                        Expanded(
                          child: ListView.builder(
                            padding: EdgeInsets.only(
                                top: 0, left: 16, right: 16, bottom: 16),
                            itemCount: controller.historyTasks.length,
                            itemBuilder: (context, i) {
                              final todo = controller.historyTasks[i];
                              return Padding(
                                padding: 16.onlyBottom,
                                child: Obx(
                                  () => GestureDetector(
                                    onLongPress: () {
                                      // controller.isSelectionMode.value =
                                      //     true;
                                      controller.toggleTaskSelection(todo);
                                    },
                                    onTap: () {
                                      if (controller.selectedTasks.isNotEmpty) {
                                        controller.toggleTaskSelection(todo);
                                      } else {
                                        log('==>>');
                                      }
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: controller.selectedTasks
                                                .contains(todo)
                                            ? Colors.blue.shade50
                                            : AppColors.white,
                                        borderRadius: BorderRadius.circular(15),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                AppColors.grey.withOpacity(0.1),
                                            spreadRadius: -1,
                                            blurRadius: 3,
                                          ),
                                        ],
                                      ),
                                      child: ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        title: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  flex: 5,
                                                  child: Text(
                                                    "${todo.task}",
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: commonStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                ),
                                                Expanded(
                                                    flex: 1,
                                                    child: todo.checked == 0
                                                        ? GestureDetector(
                                                            child: Icon(
                                                              Icons.edit,
                                                              size: 2.5
                                                                  .heightBox(),
                                                              color: AppColors
                                                                  .black,
                                                            ),
                                                            onTap: () {
                                                              homeController
                                                                  .updateTask(
                                                                      todo, i);
                                                            },
                                                          )
                                                        : SizedBox(width: 1)),
                                                Expanded(
                                                  flex: 1,
                                                  child: GestureDetector(
                                                    child: Icon(
                                                      Icons.delete,
                                                      size: 2.5.heightBox(),
                                                      color: AppColors.black,
                                                    ),
                                                    onTap: () {
                                                      deleteDialog(
                                                        label:
                                                            "Are you sure you want to delete the task?",
                                                        deleteOnTap: () async {
                                                          homeController
                                                              .deleteTask(
                                                            todo.id!,

                                                          );
                                                          await controller
                                                              .fetchHistory();

                                                          Get.back();
                                                        },
                                                        cancelOnTap: () {
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
                                            Padding(
                                              padding: 10.onlyRight,
                                              child: Text(
                                                todo.description,
                                                style: commonStyle(
                                                    fontSize: 15,
                                                    color: Colors.black
                                                        .withOpacity(0.6),
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            ),
                                            5.height,
                                          ],
                                        ),
                                        leading: Padding(
                                          padding: 16.onlyLeft,
                                          child: Text(
                                            "${i + 1}",
                                            style: commonStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        // trailing: Padding(
                                        //   padding: 16.onlyRight,
                                        //   child: Column(
                                        //     mainAxisAlignment:
                                        //         MainAxisAlignment.start,
                                        //     children: [
                                        //       // todo.checked == 0
                                        //       //     ? GestureDetector(
                                        //       //         child: Icon(
                                        //       //           Icons.edit,
                                        //       //           size: 2.5.heightBox(),
                                        //       //           color: AppColors.black,
                                        //       //         ),
                                        //       //         onTap: () {
                                        //       //           homeController
                                        //       //               .updateTask(
                                        //       //             todo,
                                        //       //           );
                                        //       //         },
                                        //       //       )
                                        //       //     : SizedBox(width: 1),
                                        //       // 5.height,
                                        //       GestureDetector(
                                        //         child: Icon(
                                        //           Icons.delete,
                                        //           size: 2.5.heightBox(),
                                        //           color: AppColors.black,
                                        //         ),
                                        //         onTap: () {
                                        //           deleteDialog(
                                        //             label:
                                        //                 "Are you sure you want to delete the task?",
                                        //             deleteOnTap: () async {
                                        //               homeController.deleteTask(
                                        //                 todo.id!,
                                        //                 i,
                                        //               );
                                        //               await controller
                                        //                   .fetchHistory();
                                        //
                                        //               Get.back();
                                        //             },
                                        //             cancelOnTap: () {
                                        //               controller.selectedTasks
                                        //                   .clear();
                                        //               Get.back();
                                        //             },
                                        //           );
                                        //         },
                                        //       ),
                                        //       // : SizedBox(width: 1),
                                        //     ],
                                        //   ),
                                        // ),
                                        subtitle: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              flex: 5,
                                              child: commonDateTime(
                                                  label: "${todo.date}",
                                                  img: AppSvg.calender),
                                            ),
                                            10.width,
                                            Expanded(
                                              flex: 5,
                                              child: commonDateTime(
                                                  label:
                                                      "${controller.convertToAmPmFormat(todo.time)}",
                                                  img: AppSvg.watch),
                                            ),
                                            10.width,
                                            Expanded(
                                              child: todo.checked == 1
                                                  ? Padding(
                                                      padding: 10.onlyRight,
                                                      child: Icon(
                                                        Icons.check_circle,
                                                        size: 2.heightBox(),
                                                        color: Colors.green,
                                                      ),
                                                    )
                                                  : Padding(
                                                      padding: 10.onlyRight,
                                                      child: SvgPicture.asset(
                                                        AppSvg.pending,
                                                        height: 1.7.heightBox(),
                                                        color: Colors.red,
                                                      ),
                                                    ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
            } else {
              return Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryColor.withOpacity(0.5),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
