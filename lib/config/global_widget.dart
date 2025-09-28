import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:todo_app/config/constatnt.dart';
import 'package:todo_app/controller/home_controller.dart';

import 'colors.dart';

OutlineInputBorder myBorder({Color color = Colors.black}) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: color),
    );

Widget commonDialogBtn(
    {required void Function() onTap,
    required String label,
    required String img,
    required Color color}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      height: 5.5.heightBox(),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black.withOpacity(0.7), width: 0.7),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: SvgPicture.asset(
              img,
              height: 3.heightBox(),
              width: 2.widthBox(),
              fit: BoxFit.contain,
            ),
          ),
          Expanded(
              flex: 5,
              child: Text(
                label,
                style: commonStyle(
                    fontSize: 13, color: color, fontWeight: FontWeight.w500
                    //     time == null ? AppColors.grey : Colors.black,
                    ),
              ))
        ],
      ),
    ),
  );
}

Widget primaryBtn({
  required void Function()? onPressed,
  required label,
}) {
  return ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primaryColor,
      minimumSize: const Size(90, 40),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    child: Text(
      label,
      style: commonStyle(color: Colors.white),
    ),
  );
}

TextStyle commonStyle({
  double fontSize = 14,
  Color color = Colors.black,
  FontWeight fontWeight = FontWeight.w600,
  FontStyle fontStyle = FontStyle.normal,
  String fontFamily = 'Roboto',
  double letterSpacing = 0,
}) {
  return TextStyle(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    fontStyle: fontStyle,
    fontFamily: fontFamily,
    letterSpacing: letterSpacing,
  );
}

Future<bool?> primaryToast({required msg}) {
  return Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0);
}

Widget commonField(
    {required controller,
    void Function(String)? getVal,
    required hintText,
    int? maxLines = 1}) {
  return Container(
    height: maxLines != 1 ? 10.heightBox() : 5.5.heightBox(),
    decoration: BoxDecoration(color: Colors.white),
    child: TextFormField(
      cursorColor: Colors.black,
      maxLines: maxLines,
      controller: controller,
      onChanged: getVal,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.only(top: 13, left: 13),
        hintText: hintText,
        border: myBorder(),
        enabled: true,
        focusedBorder: myBorder(),
      ),
    ),
  );
}

void confirmDialog() {
  Get.defaultDialog(
    backgroundColor: Colors.white,
    titleStyle: commonStyle(
        fontSize: 25, color: Colors.black, fontWeight: FontWeight.w600),
    titlePadding: 20.onlyTop,
    barrierDismissible: false,
    title: "Confirm Exit!",
    content: Text(
      "Are you sure you want to exit?",
      textAlign: TextAlign.center,
      style: commonStyle(
          fontSize: 15, color: AppColors.grey, fontWeight: FontWeight.w500),
    ),
    confirm: Padding(
      padding: 10.onlyBottom,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          primaryBtn(
            onPressed: () {
              Get.back();
            },
            label: 'No',
          ),
          primaryBtn(
            onPressed: () {
              SystemNavigator.pop();
            },
            label: 'Yes',
          ),
        ],
      ),
    ),
  );
}

Widget commonDateTime({required img, required label}) {
  return Row(
    children: [
      SvgPicture.asset(
        img,
        height: 2.heightBox(),
        width: 3.widthBox(),
        fit: BoxFit.contain,
      ),
      10.width,
      Text(
        label,
        style: commonStyle(
          fontWeight: FontWeight.w200,
          color: AppColors.grey,
        ),
      ),
    ],
  );
}

Widget commonFromDate({
  required void Function()? onTap,
  required void Function()? deleteOnTap,
  required label,
  required date,
  required isCheck,
}) {
  return Padding(
    padding: const EdgeInsets.only(left: 15),
    child: Row(
      children: [
        Expanded(
          flex: 7,
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              height: 6.heightBox(),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: AppColors.primaryColor.withOpacity(0.1),
              ),
              child: Padding(
                padding: 5.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Visibility(
                      visible: !isCheck,
                      child: Expanded(
                          flex: 3,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(
                              label,
                              style: commonStyle(),
                            ),
                          )),
                    ),
                    Expanded(
                      flex: 6,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Row(
                          children: [
                            Text(
                              date,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: commonStyle(
                                  fontSize: 15, color: Colors.black),
                            ),
                            Spacer(),
                            Icon(
                              Icons.calendar_month_outlined,
                              color: AppColors.grey,
                              size: 3.heightBox(),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget searchField() {
  HomeController controller = Get.find();
  return Padding(
    padding: 16.horizontal,
    child: Container(
      height: 6.heightBox(),
      decoration: BoxDecoration(color: Colors.transparent),
      child: TextFormField(
        controller: controller.searchCon,
        onChanged: (val) {
          controller.search.value = val;
        },
        autofocus: false,
        cursorColor: Colors.black,
        cursorHeight: 3.2.heightBox(),
        decoration: InputDecoration(
            fillColor: Colors.white,
            filled: true,
            contentPadding: EdgeInsets.only(top: 13, left: 13),
            hintText: 'search task here..',
            // border: myBorder(color: AppColors.grey),
            enabled: true,
            focusedBorder: myBorder(color: AppColors.grey.withOpacity(0.7)),
            enabledBorder: myBorder(color: AppColors.grey.withOpacity(0.2)),
            prefixIcon: Icon(
              Icons.search,
              color: AppColors.grey,
            )),
      ),
    ),
  );
}

void deleteDialog(
    {required label,
    required void Function()? deleteOnTap,
    required void Function()? cancelOnTap}) {
  Get.defaultDialog(
      backgroundColor: AppColors.white,
      titleStyle: commonStyle(fontSize: 20),
      titlePadding: 20.onlyTop,
      barrierDismissible: false,
      title: "Delete Task",
      content: PopScope(
        canPop: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Divider(
              color: Colors.grey,
            ),
            10.height,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: commonStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                    color: AppColors.grey),
              ),
            ),
          ],
        ),
      ),
      confirm: Padding(
        padding: 10.onlyBottom,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            primaryBtn(label: 'Cancel', onPressed: cancelOnTap),
            primaryBtn(
              onPressed: deleteOnTap,
              label: "Delete",
            ),
          ],
        ),
      ));
}
