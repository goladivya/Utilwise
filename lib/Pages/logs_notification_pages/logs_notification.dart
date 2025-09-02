import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/data_provider.dart';

class LogsNotification extends StatefulWidget {
  const LogsNotification(
      {Key? key, required this.creatorTuple, required this.notification})
      : super(key: key);
  final String creatorTuple;
  final List<String> notification;

  @override
  State<LogsNotification> createState() => _LogsNotification();
}

class _LogsNotification extends State<LogsNotification> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final providerCommunity = Provider.of<DataProvider>(context, listen: true);
    List<String> notifications = widget.notification.reversed.toList();

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF56D0A0),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Image.asset(
                    '${providerCommunity.extractCommunityImagePathByName(widget.creatorTuple)}',
                    width: 40,
                    height: 40,
                  ),
                  SizedBox(width: 10.0),
                  Flexible(
                    child: Text(
                      (widget.creatorTuple.split(':')[0]),
                      style: TextStyle(fontSize: 20.0),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(' Logs', style: TextStyle(fontSize: 20.0))
                ],
              ),
              // SizedBox(height: 10.0),
              // Text("Notifications",
              //   style: TextStyle(fontSize: 20.0),
              // ),
            ],
          ), // title: Text('Notification: ${widget.communityName}'),
        ),
        body: Container(
          child: ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    title: Text(notifications[index]
                        .substring(0, notifications[index].lastIndexOf('^'))),
                    subtitle: Text(notifications[index].substring(
                        notifications[index].lastIndexOf('^') + 1,
                        notifications[index].length)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0.0),
                      side: BorderSide(color: Color(0xFF56D0A0), width: 1.0),
                    ),
                  ),
                );
              }),
        ));
  }
}
