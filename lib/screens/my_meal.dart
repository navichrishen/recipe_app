import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:recipe_app/components/recipe_card.dart';
import 'package:recipe_app/screens/recipe_view.dart';

import '../components/circle_loader.dart';
import '../components/meal_card.dart';
import '../services/api.dart';
import '../utils/constant.dart';


class MyMeal extends StatefulWidget {

  const MyMeal({Key? key}) : super(key: key);

  @override
  _MyMealState createState() => _MyMealState();
}

class _MyMealState extends State<MyMeal> {
  List<dynamic> data = []; //ApiPass Body Data Holder
  String SelectedValueHolder = ""; //Dropdown Button Selected Value Holder

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  late Timer t;

  @override
  void initState() {
    super.initState();

    loadData();
  }

  var allFilterList = [];

  loadData() async{
    Timer.run(() {
      CircleLoader.showCustomDialog(context);
    });
    allFilterList = [];

    final value = await APIManager().getRequest(
        Constant.domain + "/api/Meals/GetByUserName/1");
    if (value != null && value['results'] != null) {

      CircleLoader.hideLoader(context);

      if (value['results'] != 0) {

        setState(() {
          allFilterList = value['results'];
        });
        return allFilterList;
      } else {
        return allFilterList;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: false,
        title: const Row(
          children: [
            SizedBox(
              width: 1,
            ),
            Text(
              "My Meal",
              style: TextStyle(
                fontFamily: "Roboto",
                letterSpacing: 1.0,
                fontSize: 18.0,
                color: Color(0xfffeb703),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: Color.fromARGB(255, 0, 23, 147),
      ),
      body:

      ListView.builder(
        itemCount: allFilterList.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: MealCard(title: allFilterList[index]["name"],desc: allFilterList[index]["mealType"],onClick: (){
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => const ViewRecipe(title: "Hello",)));
            },),
          );
        },
      )
    );
  }
}
