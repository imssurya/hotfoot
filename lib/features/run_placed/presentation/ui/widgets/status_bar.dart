import 'package:flutter/material.dart';
import 'package:hotfoot/core/style/style.dart';

class StatusBar extends StatelessWidget {
  final String status;

  StatusBar({
    @required this.status,
  }) : assert(status != null);

  @override
  Widget build(BuildContext context) {
    Color containerColor;
    if (status == "Accepted") {
      containerColor = Colors.greenAccent;
    } else if (status == "Cancelled") {
      containerColor = Colors.red;
    } else if (status == "Delivered") {
      containerColor = Colors.lightBlueAccent;
    }else {
      containerColor = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.only(
        top: 2.0,
        bottom: 2.0,
      ),
      margin: const EdgeInsets.only(
        bottom: 10.0,
      ),
      width: MediaQuery.of(context).size.width,
      child: Align(
        alignment: Alignment.center,
        child: Text(
          "Status: $status",
          style: style.copyWith(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)
        ),
      ),
      decoration: BoxDecoration(
        color: containerColor,
        border: Border(
          top: BorderSide(width: 1.0, color: Colors.black),
          bottom: BorderSide(width: 1.0, color: Colors.black),
        ),
      ),
    );
  }
}
