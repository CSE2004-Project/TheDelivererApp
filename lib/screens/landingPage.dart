import 'dart:convert';
import 'package:TheDeliverer/animations/BounceIn.dart';
import 'package:TheDeliverer/main.dart';
import 'package:TheDeliverer/providers/reg.dart';
import 'package:TheDeliverer/providers/restaurants.dart';
import 'package:TheDeliverer/providers/userDetails.dart';
import 'package:TheDeliverer/screens/orderPage.dart';
import 'package:TheDeliverer/screens/restaurantCard.dart';
import 'package:TheDeliverer/screens/selectAddress.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  void initState() {
    super.initState();
    visitScreen();
  }

  List restaurants = [];
  Map extractedUserData = {};
  bool isLoading = false;
  List<dynamic> items = [];
  Future<void> visitScreen() async {
    setState(() {
      isLoading = true;
    });
    await Provider.of<User>(context, listen: false)
        .fetchDetails(Provider.of<Reg>(context, listen: false).token);
    final prefs = await SharedPreferences.getInstance();
    extractedUserData = await json.decode(
        prefs.getString('currentAddress') ?? json.encode({'addressId': ''}));
    if (extractedUserData["addressId"] != '') {
      await Provider.of<Restaurant>(context, listen: false).fetchRestaurants(
          extractedUserData["addressId"],
          Provider.of<Reg>(context, listen: false).token);
      restaurants =
          Provider.of<Restaurant>(context, listen: false).restaurantDetails;
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return isLoading
        ? Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: size.height * 16.5 / 100,
                    ),
                    Container(
                      padding: EdgeInsets.only(left: size.width * 4 / 100),
                      child: Text(
                        "Our favourite Restaurants!",
                        style: GoogleFonts.montserrat(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Theme.of(context).backgroundColor,
                        ),
                      ),
                    ),
                    extractedUserData["addressId"] == ''
                        ? Container(
                            height: size.height * 20 / 100,
                            width: double.maxFinite,
                            margin: EdgeInsets.symmetric(
                              horizontal: size.width * 4 / 100,
                              vertical: size.height * 2 / 100,
                            ),
                            child: DottedBorder(
                              dashPattern: [20, 25],
                              strokeWidth: 2,
                              borderType: BorderType.RRect,
                              radius: Radius.circular(30),
                              color: Theme.of(context).accentColor,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Color(0xffffdbc7),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                width: double.maxFinite,
                                child: Center(
                                  child: Text(
                                    'Please choose an address',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context).accentColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Container(
                            height: size.height * 72 / 100,
                            width: double.maxFinite,
                            child: ListView.builder(
                              shrinkWrap: false,
                              scrollDirection: Axis.vertical,
                              itemCount: restaurants.length,
                              itemBuilder: (context, index) {
                                return FlatButton(
                                  onPressed: () async {
                                    Navigator.push(
                                      context,
                                      BounceIn(
                                        widget: OrderPage(
                                          restaurantId: restaurants[index]
                                              ['restaurantId'],
                                          name: restaurants[index]
                                              ['restaurantName'],
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(
                                      bottom: size.height * 2 / 100,
                                    ),
                                    width: double.infinity,
                                    child: RestaurantCard(
                                      name: restaurants[index]
                                          ['restaurantName'],
                                      addressLine1: restaurants[index]
                                          ['addressLine1'],
                                      addressLine2: restaurants[index]
                                          ['addressLine2'],
                                      id: restaurants[index]['restaurantId'],
                                      state: restaurants[index]['state'],
                                      city: restaurants[index]['city'],
                                      pinCode: restaurants[index]['pinCode']
                                          .toString(),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                  ],
                ),
              ),
              Container(
                color: Colors.white,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: size.height * 5.5 / 100,
                    ),
                    Container(
                      padding: EdgeInsets.only(left: size.width * 4 / 100),
                      child: Text(
                        "Now Delivering to",
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).backgroundColor,
                        ),
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        FlatButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              BounceIn(
                                widget: SelectAddressScreen(),
                              ),
                            );
                          },
                          child: Container(
                            child: Text(
                              extractedUserData["addressId"] == ''
                                  ? 'Select an Address'
                                  : extractedUserData["city"].toString() +
                                      ', ' +
                                      extractedUserData["state"].toString(),
                              style: GoogleFonts.montserrat(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Theme.of(context).accentColor,
                              ),
                            ),
                          ),
                        ),
                        Spacer(),
                        Container(
                          padding: EdgeInsets.only(right: size.width * 4 / 100),
                          child: IconButton(
                            icon: Icon(
                              FontAwesomeIcons.signOutAlt,
                              size: 20,
                              color: Theme.of(context).accentColor,
                            ),
                            onPressed: () async {
                              await Provider.of<Reg>(context, listen: false)
                                  .logout();
                              RestartWidget.restartApp(context);
                            },
                          ),
                        ),
                      ],
                    ),
                    Container(
                      height: 0.3,
                      width: double.infinity,
                      color: Theme.of(context).backgroundColor,
                      margin: EdgeInsets.symmetric(
                          horizontal: size.width * 4 / 100),
                    ),
                  ],
                ),
              ),
            ],
          );
  }
}
