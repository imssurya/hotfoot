import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotfoot/features/navigation_screen/presentation/bloc/navigation_screen_bloc.dart';
import 'package:hotfoot/features/order_placed/presentation/ui/widgets/open_close_chat_button.dart';
import 'package:hotfoot/features/order_placed/presentation/ui/widgets/cancel_delivery_button.dart';
import 'package:hotfoot/features/order_placed/presentation/ui/widgets/accept_delivery_button.dart';

class RunPlacedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final navScreenBloc = BlocProvider.of<NavigationScreenBloc>(context);
    final currRun = navScreenBloc.state.runModel;
    final json1 = json.encode(currRun.toJson());
    print('FROM NAV BLOC');
    print(json1);

    return Scaffold(
      appBar: AppBar(title: Text('Run Status')),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            LinearProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            Container(
              height: MediaQuery.of(context).size.height / 1.5,
              child: Center(
                  child: Text("Live map being updated here",
                      style: TextStyle(fontSize: 24.0))),
              color: Colors.lightGreenAccent,
            ),
            SizedBox(height: 20),
            Row(
              // Should use this here so formatting stays similar across
              // all screen sizes
              // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(width: 40),
                Text("Status", style: TextStyle(fontSize: 24.0)),
                SizedBox(width: 110),
                OpenCloseChatButton(),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CancelDeliveryButton(),
                AcceptDeliveryButton(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
