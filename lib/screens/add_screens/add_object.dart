import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/data_provider.dart';

class ObjectScreen extends StatefulWidget {
  const ObjectScreen(
      {Key? key, required this.isFromCommunityPage, required this.creatorTuple})
      : super(key: key);
  final bool isFromCommunityPage;
  final String creatorTuple;

  @override
  State<ObjectScreen> createState() => ObjectData();
}

class ObjectData extends State<ObjectScreen> {
  final _formKey = GlobalKey<FormState>();
  String communityDropDown = '';

  @override
  void initState() {
    super.initState();
  }

  TextEditingController objectName = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final providerCommunity = Provider.of<DataProvider>(context, listen: true);

    if (providerCommunity.communities.isEmpty) {
      return Container(
          margin: EdgeInsets.symmetric(horizontal: 30, vertical: 150),
          child: Text(
            "Hey there! Swipe left to add your first community! Then come back here to add an object!",
            style: TextStyle(fontSize: 30),
          ));
    }

    if (widget.isFromCommunityPage) {
      communityDropDown = widget.creatorTuple;
    } else {
      communityDropDown =
          providerCommunity.communities[providerCommunity.communitiesIndex];
    }

    return Form(
        key: _formKey,
        child: Container(
            padding: const EdgeInsets.all(16.0),
            // child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'Add Object',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),

                  if (!widget.isFromCommunityPage)
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      itemHeight: null,
                      decoration: const InputDecoration(
                        icon: Icon(Icons.home_work),
                        hintText: 'Community',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                      ),
                      value: communityDropDown,
                      items: providerCommunity.communities
                          .map<DropdownMenuItem<String>>((String chosenValue) {
                        return DropdownMenuItem<String>(
                          value: chosenValue,
                          child: Text(
                            (chosenValue).split(":")[0] +
                                " - " +
                                providerCommunity
                                    .communityMembersMap[chosenValue]!
                                    .firstWhere(
                                        (member) =>
                                            member.phone ==
                                            (chosenValue).split(":")[1],
                                        orElse: () => providerCommunity
                                            .communityMembersMap[chosenValue]!
                                            .firstWhere((member) =>
                                                member.isCreator == true))
                                    .name,
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          communityDropDown = newValue!;
                          providerCommunity.communityListen(communityDropDown);
                        });
                      },
                    ),

                  SizedBox(
                    height: 10,
                  ),

              DropdownButtonFormField<String>(
              decoration: const InputDecoration(
              border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
              icon: Icon(Icons.grid_view),
              hintText: 'Select the Object',
            ),
            value: objectName.text.isEmpty ? null : objectName.text,
            items: ['Vehicle', 'Education', 'House','Food','Health','Travel','Shopping','Entertainment','Gifts','Other'].map((String value) {
            return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
            );
  }).toList(),
  onChanged: (String? newValue) {
    if (newValue != null) {
      objectName.text = newValue;
    }
  },
),

                  SizedBox(
                    height: 10,
                  ),

                  //
                  // TextFormField(
                  //   keyboardType: TextInputType.multiline,
                  //   maxLines: null,
                  //   decoration: const InputDecoration(
                  //     icon: Icon(Icons.edit),
                  //     hintText: 'Remark',
                  //   ),
                  // ),
                  Container(
                      margin: const EdgeInsets.only(top: 20.0),
                      child: FloatingActionButton(
                        backgroundColor: Color(0xFF56D0A0),
                        heroTag: "BTN-21",
                        // added checks for empty fields
                        onPressed: () async {
                          if (objectName.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Please enter the object name!'),
                                    duration: Duration(seconds: 3)));
                            return;
                          }

                          // CHANGED HERE

                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Adding Object'),
                                  duration: Duration(seconds: 8)));

                          bool res = await providerCommunity.addObject(
                              communityDropDown, objectName.text);

                          ScaffoldMessenger.of(context).removeCurrentSnackBar();

                          if (!res) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Error in Adding Object'),
                                    duration: Duration(seconds: 1)));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Object Added'),
                                    duration: Duration(seconds: 1)));
                          }

                          Navigator.pop(context);
                        },
                        child: const Icon(Icons.check),
                      )),
                ],
              ),
              // )
            )));
  }
}
