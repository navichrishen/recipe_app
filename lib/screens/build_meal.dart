import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:recipe_app/services/api.dart';
import 'package:recipe_app/utils/constant.dart';
import '../components/circle_loader.dart';
import '../components/dropdown_widget.dart';
import 'package:intl/intl.dart';

import '../data/recipe_data.dart';
import '../utils/toast.dart';

class BuildMeal extends StatefulWidget {
  const BuildMeal({Key? key}) : super(key: key);

  @override
  _BuildMealState createState() => _BuildMealState();
}

class _BuildMealState extends State<BuildMeal> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController recipeNameCon =
      TextEditingController(); //Text of TextField
  final TextEditingController _textEditingController1 =
      TextEditingController(); //Text of TextField
  List<dynamic> data = []; //ApiPass Body Data Holder
  String title = "Good Morning!";
  int touchedIndex = -1;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  var selectedName;
  var _isDisable = false;
  var selectedId;
  var mealType = "Breakfast";

  // var isWebView = false;

  var recipeList = [];

  static const yellow = Color(0xfffeb703);
  static const blue = Color.fromARGB(255, 0, 23, 147);
  List<RecipeData> allFilterList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchSuggestions();
    _dateController.text = DateTime.now().toString().split(" ")[0];
  }

  void _ShowDatePicker(textEditingController) {
    showDatePicker(
        //Color.fromARGB(255, 246, 197, 0)
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1990),
        lastDate: DateTime(2050),
        builder: (context, child) => (Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: blue,
                  onPrimary: Color.fromARGB(255, 255, 255, 255),
                  onSurface: blue,
                ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    foregroundColor: blue, // button text color
                  ),
                ),
              ),
              child: child!,
            ))).then((value) {
      setState(() {
        textEditingController.text = DateFormat('yyyy-MM-dd').format(value!);
      });
    });
  }

  fetchSuggestions() async {
    Timer.run(() {
      CircleLoader.showCustomDialog(context);
    });
    allFilterList = [];
    final value = await APIManager()
        .getRequest(Constant.domain + "/api/v1/Recipe/GetByUserName/1");
    if (value != null && value['results'] != null) {
      CircleLoader.hideLoader(context);
      if (value['results'] != 0) {
        for (var item in value['results']) {
          allFilterList.add(RecipeData(
              id: item['id'] as String, name: item['name'] as String));
        }
        setState(() {
          allFilterList = allFilterList;
        });
      } else {}
    }
  }

  saveMeal() async {
    setState(() {
      _isDisable = true;
    });
    var data = {
      "mealType": mealType == "Breakfast"
          ? 0
          : mealType == "Lunch"
              ? 1
              : 2,
      "mealDate": _dateController.text,
      "description": "none",
      "recipies": recipeList,
      "userId": "1"
    };

    APIManager().postRequest(Constant.domain + "/api/Meals", data).then((res) {
      setState(() {
        _isDisable = false;
      });
      if (res["isSucess"]) {
        MyToast.showSuccess("Meal Added");
      } else {
        MyToast.showError("Failed to add meal");
      }
    });
  }


  List<RecipeData> getSuggestions(String query) {
    List<RecipeData> matches = [];
    matches.addAll(allFilterList);
    matches.retainWhere((s) => s.name.toLowerCase().contains(query.toLowerCase()));
    return matches;
  }

  @override
  Widget build(BuildContext context) {
    //TextEditingController _textEditingController = TextEditingController(); //Text of TextField
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
              "Build Meal",
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
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  //First Selection
                  //Spacer

                  //Spacer
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            style: const TextStyle(
                              fontSize: 14.0,
                              color: blue,
                              fontFamily: "Roboto",
                              fontWeight: FontWeight.bold,
                            ),
                            controller: _dateController,
                            decoration: InputDecoration(
                              suffixIcon: IconButton(
                                onPressed: _dateController.clear,
                                icon: const Icon(
                                  Icons.clear,
                                  color: blue,
                                ),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 2, color: Color(0xFF006de4)),
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(6),
                                    bottomLeft: Radius.circular(6)),
                              ),
                              border: const OutlineInputBorder(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(6),
                                    bottomLeft: Radius.circular(6)),
                                borderSide: BorderSide(color: blue, width: 2.0),
                              ),
                              hintText: 'Select the Date',
                              //enabled: false,
                            ),
                            readOnly: true,
                          ),
                        ),
                        Container(
                          height: 55,
                          decoration: const BoxDecoration(
                              color: blue,
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(6),
                                  bottomRight: Radius.circular(6))),
                          child: IconButton(
                              icon: const Icon(
                                Icons.calendar_month_rounded,
                                size: 30,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                _ShowDatePicker(_dateController);
                              }),
                        )
                      ],
                    ),
                  ),

                  Text(
                    'Meal Type',
                    style: TextStyle(fontSize: 16),
                  ),

                  Padding(
                      padding: const EdgeInsets.all(8),
                      child: DropdownWidget(
                        onChanged: (val) {
                          setState(() {
                            mealType = val;
                          });
                        },
                        title: "Select Meal Type",
                        items: const ["Breakfast", "Lunch", "Dinner"],
                        selectedValue: mealType,
                      )),
                  Text(
                    'Search Recipe',
                    style: TextStyle(fontSize: 16),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(0),
                    child: TypeAheadField<RecipeData>(
                      suggestionsCallback: (value) {
                        return getSuggestions(value);
                      },
                      builder: (context, controller, focusNode) {
                        return TextField(
                            controller: controller,
                            focusNode: focusNode,
                            autofocus: true,
                            decoration: const InputDecoration(
                                border: OutlineInputBorder()));
                      },
                      itemBuilder: (context, foodData) {
                        return ListTile(
                          title: Text(foodData.name),
                        );
                      },
                      onSelected: (recipe) {
                        print("recipe");
                        print(recipe);

                        recipeList.add({"id": recipe.id});
                        selectedName = recipe.name + " \n";
                        selectedId = recipe.id;
                        recipeNameCon.text += selectedName;
                      },
                    ),
                  ),

                  const Text(
                    'Selected Recipes',
                    style: TextStyle(fontSize: 16),
                  ),

                  TextField(
                    enabled: false,
                    controller: recipeNameCon,
                    maxLines: null, // Set maxLines to null for multiline input
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width / 100 * 100,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [blue, Color.fromARGB(255, 4, 34, 193)],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        recipeNameCon.text = "";
                        recipeList.clear();
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent, elevation: 0),
                      child: const Text(
                        'Clear All',
                        style: TextStyle(
                          fontFamily: "Roboto",
                          fontSize: 18.0,
                          color: Colors.white,
                          letterSpacing: 1.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),

                  //Submit Button
                  Container(
                    width: MediaQuery.of(context).size.width / 100 * 100,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [blue, Color.fromARGB(255, 4, 34, 193)],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: ElevatedButton(
                      onPressed: _isDisable? null : () {
                        if (recipeList.length == 0) {
                          MyToast.showError("Please add a recipe");
                        } else {

                          saveMeal();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent, elevation: 0),
                      child: const Text(
                        'Analyze Meal',
                        style: TextStyle(
                          fontFamily: "Roboto",
                          fontSize: 18.0,
                          color: Colors.white,
                          letterSpacing: 1.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
