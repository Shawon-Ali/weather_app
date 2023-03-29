import 'dart:convert';
import 'package:jiffy/jiffy.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
//Location permission
//(geoLocator ar ReadMe ar modde code copy kore @override ar upore boshia "import"korse)
  determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    position = await Geolocator.getCurrentPosition();
    getWeatherData();
    print(
        "my latitude is ${position!.latitude} longitute is ${position!.longitude}");
  }
//(geoLocator ReadMe theke nawa code ses ekhane)

  Position? position;
  Map<String, dynamic>? weatherMap;
  Map<String, dynamic>? forecastMap;

  getWeatherData() async {
    var weather = await http.get(Uri.parse(
        "https://api.openweathermap.org/data/2.5/weather?lat=${position!.latitude}&lon=${position!.longitude}&appid=ac17b1a9db6117470edaea1fd1b41aae&units=metric"));
    print("www.Weather ${weather.body}");

    var forecast = await http.get(Uri.parse(
        "https://api.openweathermap.org/data/2.5/forecast?lat=${position!.latitude}&lon=${position!.longitude}&appid=ac17b1a9db6117470edaea1fd1b41aae&units=metric"));

    var weatherData = jsonDecode(weather.body);
    var forecastData = jsonDecode(forecast.body);

    setState(() {
      weatherMap = Map<String, dynamic>.from(weatherData);
      forecastMap = Map<String, dynamic>.from(forecastData);
    });
  }

  @override
  void initState() {
    determinePosition();
    super.initState();
  }

  Widget build(BuildContext context) {
    return SafeArea(
      child: weatherMap != null
          ? Scaffold(
              body: Container(
                padding: EdgeInsets.all(25),
                decoration:
                 BoxDecoration(
                  
                    image: DecorationImage(
                        image: NetworkImage(
                            "https://images.unsplash.com/photo-1504608524841-42fe6f032b4b?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxzZWFyY2h8Nnx8d2VhdGhlciUyMGFwcHxlbnwwfHwwfHw%3D&w=1000&q=80"),
                        fit: BoxFit.cover)),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      style: BorderStyle.solid,
                      width:2 ,
                      color: Colors.black
                    ),
                    color: Colors.black.withOpacity(0.2),
                  ),
                  padding: EdgeInsets.all(25),
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("📍 ${weatherMap!["name"]}",style: TextStyle(fontSize: 18,color: Colors.white)),
                                Text(
                                  "${Jiffy("${DateTime.now()}").format("MMM do yyyy")}, ${Jiffy("${DateTime.now()}").format("hh : mm")}",style: TextStyle(color: Colors.white)),
                          ]),
                            
                          ],
                        ),
                      ),
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white.withOpacity(0.5),
                        child: Image.network(
                            "https://openweathermap.org/img/wn/${weatherMap!["weather"][0]["icon"]}@2x.png"),
                      ),
                      Text("${weatherMap!["main"]["temp"]}° ",style: TextStyle(color: Colors.white)),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          children: [
                            Text(
                                "Feels Like ${weatherMap!["main"]["feels_like"]}",style: TextStyle(color: Colors.white)),
                            Text(
                                " ${weatherMap!["weather"][0]["description"]}",style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                      Text(
                          "Humidity ${weatherMap!["main"]["humidity"]},Pressure ${weatherMap!["main"]["pressure"]},",style: TextStyle(color: Colors.white)),
                     
                      Row(
                        children: [
                          Center(
                            child: Container(
                               height: 40,
                              
                                                      
                                width: 130,
                                margin: EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: Colors.white.withOpacity(0.2)
                          
                                ),
                              child:
                              Center(child: Text("Sunrise ${Jiffy("${DateTime.fromMillisecondsSinceEpoch(weatherMap!["sys"]["sunrise"] * 1000)}").format("hh mm a")}",style: TextStyle(color: Colors.white))) ,
                            ),
                          ),
                          Center(
                            child: Container(
                              height: 40,                     
                                width: 130,
                                margin: EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: Colors.white.withOpacity(0.2)
                          
                                ),
                                                          child:
                              Center(child: Text("Sunset ${Jiffy("${DateTime.fromMillisecondsSinceEpoch(weatherMap!["sys"]["sunset"] * 1000)}").format("hh mm a")}",style: TextStyle(color: Colors.white))) ,
                              
                              
                            ),
                          ),
                        ],
                      ),
                     
                     
                      SizedBox(
                        height: 300,
                        child: ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemCount: forecastMap!.length,
                          itemBuilder: (context, index) {
                            return Container(
                              width: 150,
                              margin: EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.white.withOpacity(0.2)

                              ),
                              child: Column(
                                children: [
                                  SizedBox(height: 20,),
                                  Text(
                                      "${Jiffy("${forecastMap!["list"][index]["dt_txt"]}").format("EEE h mm")}",style: TextStyle(color: Colors.white)),
                                  Image.network(
                                      "https://openweathermap.org/img/wn/${forecastMap!["list"][index]["weather"][0]["icon"]}@2x.png"),
                                  Text(
                                      "${forecastMap!["list"][index]["main"]["temp_min"]}/${forecastMap!["list"][index]["main"]["temp_max"]}",style: TextStyle(color: Colors.white)),
                                  Text(
                                      "${forecastMap!["list"][index]["weather"][0]["description"]}",style: TextStyle(color: Colors.white)),
                                ],
                              ),
                            );
                          },
                        ),
                      ),

                     
                    ],
                  ),
                ),
              ),
            )

            //1st a asha circular progress bar
          : Center(child: CircularProgressIndicator()),
    );
  }
}
