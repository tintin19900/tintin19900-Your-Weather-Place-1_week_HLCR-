import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:weather/weather.dart';
import 'package:weatherapp/consts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_icons/weather_icons.dart';

class tempscreen extends StatefulWidget {
  final String cityName;

  const tempscreen({Key? key, required this.cityName}) : super(key: key);

  @override
  State<tempscreen> createState() => _tempscreenState();
}

class _tempscreenState extends State<tempscreen> {
  final WeatherFactory _wf = WeatherFactory(OPENWEATHER_API_KEY);

  Weather? _weather;

  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
    _loadFavoriteStatus();
  }

  void _fetchWeather() async {
    try {
      Weather? weather = await _wf.currentWeatherByCityName(widget.cityName);
      setState(() {
        _weather = weather;
      });
    } catch (e) {
      print('Error fetching weather: $e');
    }
  }



  void _loadFavoriteStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isFavorite = prefs.getBool(widget.cityName) ?? false;
    });
  }

  
  void _toggleFavorite() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isFavorite = !isFavorite;  // Toggle favorite state 
      if (isFavorite) {
        prefs.setBool(widget.cityName, true);  // Save as favorite
      } else {
        prefs.remove(widget.cityName);  // Remove from favorites
      }
    });
  }


  Color _getBackgroundColor() {
    if (_weather == null || _weather?.temperature == null) {
      return Colors.grey[300]!;  // Default Null
    }

    double? temp = _weather?.temperature?.celsius;
    if (temp == null) return Colors.grey[300]!;

   
    if (temp <= 16.00) {
      return Colors.blue[300]!; // Cold temperature
    } else if (temp > 16 && temp <= 25) {
      return Colors.green[300]!; // warm temperature
    } else if (temp > 25 && temp <= 35) {
      return Colors.orange[300]!; // Hot temperature
    } else {
      return Colors.red[400]!; // Very Hot temperature
    }
  }

    Color _getAppbarColor() {
    if (_weather == null || _weather?.temperature == null) {
      return Colors.grey[300]!; // Default color for Null
    }

    double? temp = _weather?.temperature?.celsius;
    if (temp == null) return Colors.grey[300]!;


    if (temp <= 16.00) {
      return Colors.lightBlue[100]!; // Cold temperature
    } else if (temp > 16 && temp <= 25) {
      return Colors.lightGreen[100]!; // Warm temperature
    } else if (temp > 25 && temp <= 35) {
      return const Color.fromARGB(255, 249, 209, 149); // Hot temperature
    } else {
      return const Color.fromARGB(255, 231, 160, 160); // Very Hot temperature
    }
  }
   Widget _getIcon(){
    if (_weather == null || _weather?.temperature == null) {
      return BoxedIcon(WeatherIcons.hot);// Default color for Null
    }
    double? temp = _weather?.temperature?.celsius;
    if (temp == null) return BoxedIcon(WeatherIcons.hot);

       if (temp <= 16.00) {
      return BoxedIcon(WeatherIcons.snowflake_cold,color: const Color.fromARGB(255, 162, 226, 255),size: 40,); // Cold temperature
    } else if (temp > 16 && temp <= 25) {
      return BoxedIcon(WeatherIcons.cloudy_windy, color: const Color.fromARGB(255, 170, 255, 117), size: 40,); // Warm temperature
    } else if (temp > 25 && temp <= 35) {
      return BoxedIcon(WeatherIcons.day_sunny,color: const Color.fromARGB(255, 255, 190, 149),size: 40,); // Hot temperature
    } else {
      return BoxedIcon(WeatherIcons.hot,color: const Color.fromARGB(255, 194, 15, 2),size: 40,); // Very Hot temperature
    }

   }
   Color getBoxColor(){
     if (_weather == null || _weather?.temperature == null) {
      return Colors.grey;// Default color for Null
    }
    double? temp = _weather?.temperature?.celsius;
    if (temp == null) return Colors.grey;

      if (temp <= 16.00) {
      return  const Color.fromARGB(255, 118, 255, 244); // Cold temperature
    } else if (temp > 16 && temp <= 25) {
      return  const Color.fromARGB(255, 200, 255, 161); // Warm temperature
    } else if (temp > 25 && temp <= 35) {
      return const Color.fromARGB(255, 251, 178, 119); // Hot temperature
    } else {
      return const Color.fromARGB(255, 245, 143, 136); // Very Hot temperature
    }
   }
   List <Color>_getColor(){
         if (_weather == null || _weather?.temperature == null) {
      return [Colors.grey];// Default color for Null
    }
    double? temp = _weather?.temperature?.celsius;
    if (temp == null) return [Colors.grey];

      if (temp <= 16.00) {
      return       [ const Color.fromARGB(255, 124, 138, 200),
                    const Color.fromARGB(255, 136, 158, 255),
                    const Color.fromARGB(255, 117, 142, 255),
                    const Color.fromARGB(255, 73, 107, 255) ];// Cold temperature
    } else if (temp > 16 && temp <= 25) {
      return    [ const Color.fromARGB(255, 117, 175, 111),
                    const Color.fromARGB(255, 96, 183, 72),
                    const Color.fromARGB(255, 48, 164, 42),
                    const Color.fromARGB(255, 0, 149, 8), ]; // Warm temperature
    } else if (temp > 25 && temp <= 35) {
      return   [ const Color.fromARGB(255, 169, 142, 118),
                    const Color.fromARGB(255, 199, 168, 98),
                    const Color.fromARGB(255, 186, 141, 50),
                    const Color.fromARGB(255, 194, 120, 0), ]; // Hot temperature
    } else {
      return   [ const Color.fromARGB(255, 214, 132, 132),
                    const Color.fromARGB(255, 255, 129, 129),
                    const Color.fromARGB(255, 255, 86, 86),
                    const Color.fromARGB(255, 255, 49, 49), ]; // Very Hot temperature
    }

   }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${_weather?.areaName} Weather", // "City name" Weather
          style: GoogleFonts.prompt(fontSize: 18),
        ),
        backgroundColor: _getAppbarColor(), //Color depend on temperature
         actions: [
          Text("Favorite Button",style: GoogleFonts.prompt(fontSize: 12),), //For tester to see iconbutton
          const SizedBox(width: 5,),
          Icon(Icons.arrow_forward_sharp,color: Colors.black,size: 20,),
          IconButton(
            icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border), // Check if Favorite or not
            onPressed: _toggleFavorite,       //toggle Favorite State
          ),
          const SizedBox(width: 27,) 
        ], // 
      ),
      body: _buildUI(), //call function to show
      backgroundColor: _getBackgroundColor(),  //depend on temp
    );
  }

  Widget _buildUI() {
    if (_weather == null) {  //when bug!
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,   
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _locationHeader(),  //call City name and Country name
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.05, // if greater than 1 it will out of BOUND!!
          ),
          _dateTimeInfo(),  //call d/m/y and week day name
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.005,
          ),
          _weatherIcon(), // API call icon and depend on weatherDescription
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          _currentTemp(), //API call temperature
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          _extraInfo(), //Return Container Box with extra information from API call and Icon for decoration
        ],
      ),
    );
  }

  Widget _locationHeader() {
    return Column(
      children: [
        Text(
          _weather?.areaName ?? " ", //To string
          style: GoogleFonts.prompt(fontWeight: FontWeight.bold, fontSize: 26),
        ),
        const SizedBox(height: 5),
        Text(
          "${_weather?.country}", // Country ตัวย่อ 
          style: GoogleFonts.prompt(fontSize: 13),
        )
      ],
    );
  }

  Widget _dateTimeInfo() {
    if (_weather?.date == null) {
      return Container();
    }
    DateTime now = _weather!.date!; //call time from API
    return Column(
      children: [
        Text(
          "${DateFormat("dd/MM/y EEEE").format(now)}", // Time format
          style: GoogleFonts.prompt(fontSize: 15),
        ),
        const SizedBox(
          height: 10,
        ),
      ],
    );
  }

  Widget _weatherIcon() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.2,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                  "https://openweathermap.org/img/wn/${_weather?.weatherIcon}@4x.png"),
            ),
          ),
        ),
        Text(
          "${_weather?.weatherDescription}", // weatherDescription call
          style: GoogleFonts.prompt(
            fontSize: 21,
          ),
        )
      ],
    );
  }

  Widget _currentTemp() {
    return Text(
      "${_weather?.temperature?.celsius?.toStringAsFixed(1)}°C", //API call temperature in Celsius and fix it 1 digit point
      style: GoogleFonts.prompt(fontSize: 40),
    );
  }

  Widget _extraInfo() {
   
    return Container(  //Box contain info
      width: 375,
      height: 150,
      decoration: BoxDecoration(
        color: Colors.red,
     
        borderRadius:  BorderRadius.circular(24),
        boxShadow: [
                BoxShadow(
                  color: getBoxColor(),
                  offset: const Offset(0, 20),
                  blurRadius: 30,
                  spreadRadius: -5,
                ),
              ],
            gradient: LinearGradient(                           // FOR DECORATION 
                  begin: Alignment.topLeft,
                  end: Alignment.bottomCenter,
                  colors : _getColor(),
                  stops: const [
                    0.1,
                    0.5,
                    0.7,
                    1.0
                  ],
        ),
      
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
           
            Text("Humidity: ${_weather?.humidity}%",style:  GoogleFonts.prompt(fontSize: 15,color : Colors.white)), //Humid and Windspeed 
          const SizedBox(width: 10,),
          Text("Wind Speed: ${_weather?.windSpeed?.toStringAsFixed(1)}km/hr",style: GoogleFonts.prompt(fontSize: 15 ,color : Colors.white),)

          ],),
          const SizedBox(height: 10,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Pressure: ${_weather?.pressure}hPa",style:  GoogleFonts.prompt(fontSize: 15,color: Colors.white),), //Pressure and Feels temp
              const SizedBox(width: 10,),
              Text("Temp Feels like: ${_weather?.tempFeelsLike?.celsius?.toStringAsFixed(1)}°C",style:  GoogleFonts.prompt(fontSize: 15,color: Colors.white),)
            ],
          ),
          const SizedBox(height: 10,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [_getIcon()], // Call icon depend on temperature
            
            )
        ],
        
      ),
  
    );
  
  

  }
}
