import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utilwise/components/expense.dart';

import '../../provider/data_provider.dart';
import '../../screens/add_screens/edit_expense.dart';

class EditExpensePage extends StatefulWidget {
  final Expense expense;

  EditExpensePage({Key? key, required this.expense}) : super(key: key);

  @override
  State<EditExpensePage> createState() => _EditFromObjectPageData();
}

class _EditFromObjectPageData extends State<EditExpensePage> {
  @override
  Widget build(BuildContext context) {
    final providerCommunity = Provider.of<DataProvider>(context, listen: false);
    return DefaultTabController(
      length: 1,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF56D0A0),
          elevation: 1,
          title: Row(
            children: <Widget>[
              Image.asset(
                '${providerCommunity.extractCommunityImagePathByName(widget.expense.creatorTuple)}',
                width: 40,
                height: 40,
              ),
              SizedBox(width: 10),
              Text((widget.expense.creatorTuple).split(":")[0]),
            ],
          ),
          bottom: PreferredSize(
              preferredSize: Size.fromHeight(90.0),
              child: Container(
                margin: EdgeInsets.only(left: 90),
                child: Column(children: [
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: 13.0,
                        ),
                        child: Text(
                          '↳ ',
                          style: TextStyle(
                            fontSize: 30.0,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 10.0, top: 3),
                        child: Image.asset(
                          '${providerCommunity.extractObjectImagePathByName(widget.expense.objectName)}',
                          width: 40,
                          height: 40,
                        ),
                      ),
                      Text(
                        ' ${widget.expense.objectName}',
                        style: TextStyle(
                          fontSize: 20.0,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Row(children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 10.0, top: 3, left: 75),
                      child: Icon(Icons.currency_rupee_outlined,
                          color: Colors.white),
                    ),
                  ])
                ]),
              )),
        ),
        body: TabBarView(
          children: [
            EditExpenseScreen(
                isFromCommunityPage: false,
                isFromObjectPage: true,
                expense: widget.expense),
          ],
        ),
      ),
    );
  }
}
