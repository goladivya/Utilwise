import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:utilwise/Pages/main_pages/no_internet_page.dart';

import '../../provider/data_provider.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();

    whereToGo();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
        stream: connectivityStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!) {
              return buildScaffold();
            } else {
              return NoInternetPage();
            }
          } else {
            return buildScaffold();
          }
        });
  }

  buildScaffold() {
    return Scaffold(
        body: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade50, Color(0xFF56D0A0)],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
      ),
      child: Center(
          child: Container(
        margin: EdgeInsets.only(left: 25, right: 25),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            color: Colors.green.shade50,
            border: Border.all(color: Color(0xFF56D0A0), width: 2)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.home_filled,
              size: 45,
              color: Color(0xFF56D0A0),
            ),
            Text(
              "Utilwise",
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Color(0xFF56D0A0),
              ),
            ),
          ],
        ),
      )),
    ));
  }

  void whereToGo() async {
    var sharedPref = await SharedPreferences.getInstance();
    var userPhone = sharedPref.getString("userPhone") ?? "";
    // print("userPhone: $userPhone");
    Timer(Duration(seconds: 2), () async {
      if (userPhone != "") {
        DataProvider dataProvider =
            Provider.of<DataProvider>(context, listen: false);
        await dataProvider.getAllDetails(userPhone);
        // try{
        // } on TimeoutException catch (e) {
        //   Navigator.pushReplacementNamed(context, '/noInternet');
        // } on Error catch (e) {
        //   print(e);
        // }
        // await dataProvider.getAllDetails(userPhone);
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  Stream<bool> get connectivityStream =>
      Connectivity().onConnectivityChanged.map((List<ConnectivityResult> result) {
        return result != ConnectivityResult.none;
      });
}
