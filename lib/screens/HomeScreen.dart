import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:weather/weather.dart';
import 'package:weather_icons/weather_icons.dart';
import 'package:weatherapp/consts.dart';
import 'temperature.dart'; 
import 'package:shared_preferences/shared_preferences.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  List<String> favoriteCities = [];
  WeatherFactory wf = WeatherFactory(OPENWEATHER_API_KEY); //API KEYS CALL

  Map<String, Weather?> cityWeatherMap = {}; // Store weather data 
  bool isLoading = true; // show loading state

  @override

    void initState() {
    super.initState();
    _loadFavoriteCities(); //For loading Favourite City
  }

  Future<void> _fetchWeatherForAllCities() async {
    try {
      for (String city in favoriteCities) {
        if (!cityWeatherMap.containsKey(city)) {
          try {
            Weather? weather = await wf.currentWeatherByCityName(city);
            setState(() {
              cityWeatherMap[city] = weather;
            });
          } catch (e) {
          }
        }
      }
    } catch (e) {
    } finally {
      setState(() {
        isLoading = false; 
      });
    }
  }

  
   void _loadFavoriteCities() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      favoriteCities = prefs.getKeys().where((key) => prefs.getBool(key) ?? false).toList();
    });
     _fetchWeatherForAllCities();
  }

    Color _getListViewColor(String cityName) {
    Weather? weather = cityWeatherMap[cityName];
    if (weather == null || weather.temperature == null) {
      return Colors.grey[300]!; // Default color if no weather data is available
    }

    double? temp = weather.temperature?.celsius;
    if (temp == null) return Colors.grey[300]!;

    // Set color based on temperature range
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
  Widget _buildWeatherInfo(String city) {
  Weather? weather = cityWeatherMap[city];

  if (weather == null || weather.temperature == null) {
    return Text('No data available');
  }

  double? temp = weather.temperature?.celsius;
  String? description = weather.weatherDescription ?? 'Unknown weather';
  
  return Row(
    children: [
      BoxedIcon(WeatherIcons.thermometer),
      Text(
        'Temperature: ${temp?.toStringAsFixed(1)}°C', 
        style: GoogleFonts.prompt(fontSize: 16,color: Colors.black)
      ),
      SizedBox(width: 10),
      BoxedIcon(WeatherIcons.cloud),
      Text(
        description, 
        style: GoogleFonts.prompt(fontSize: 16,color: Colors.black)
      ),
    ],
  );
}


   Future<void> _navigateToTempScreen(String city) async {
    // Navigate to temperature screen and wait for result
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => tempscreen(cityName: city),
      ),
    );

    // When returning, reload the favorite cities list
     if (result == 'reload') {
    _loadFavoriteCities();
  }
  else{
    _loadFavoriteCities();
  }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Your Weather Place", style:  
        GoogleFonts.prompt(fontSize: 24,
        color: Colors.white,
        fontWeight: FontWeight.bold
        ),
    
        ),
        backgroundColor: Colors.indigo[900],
        actions: [
          IconButton(
          onPressed: () async {
            final result = await showSearch( 
              context: context,
              delegate: CustomSearchDelegate(wf), // Seacrh Delegate 
            );


            if (result == 'reload') { // when return to HomeScreen Reload favourite city list
              _loadFavoriteCities();
            }
},
            icon: const Icon(Icons.search,color: Colors.white,),
          ),
          const SizedBox(
            width: 30,
          )
        ],
      ),
      body: 
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            
            child: Text("Your Places :",   //Favourite City List 
                style: GoogleFonts.prompt(
                  color: const Color.fromARGB(242, 255, 255, 255),
                  fontSize: 20,
               
                 
                ),
              
            ),
          ),
          Expanded(
            child: _buildFavoriteCitiesList(), //Call function to create favourite List
          ),
        ],
      ),
      backgroundColor: const Color.fromARGB(255, 7, 1, 24),
    );
  }

  // Build the favorite cities list
  Widget _buildFavoriteCitiesList() {
    if (favoriteCities.isEmpty) {  //No favourite List
      return  Center(
        child: Text(
          'Go get your Favourite City for fast Check from here!',
          style: GoogleFonts.prompt(fontSize: 16,
          color: Colors.white
          ),
        ),
      );
    }

return Expanded(
  child: ListView.builder(
    itemCount: favoriteCities.length, // Loop for city list
    itemBuilder: (context, index) {
      String city = favoriteCities[index];
       Color listColor = _getListViewColor(city);
      return Column(
        children: [
          Container(
            color: listColor, // Set background color
            child: ListTile(
              title: Text(
                city,
                style: GoogleFonts.prompt(
                  fontSize: 18,
                  color: Colors.black,
                  fontWeight: FontWeight.w500
                ),
                
              ),
                subtitle: cityWeatherMap[city] != null ? _buildWeatherInfo(city) : Text('Loading...'),
              trailing: IconButton( // Icon for remove from list
                icon: const Icon(Icons.cancel_outlined, color: Colors.white),
                onPressed: () {
                  _removeFromFavorites(city); // Remove city from favorites
                },
              ),
              onTap: () {
                _navigateToTempScreen(city); // Navigate to temp screen
              },
            ),
          ),
          const SizedBox(height: 8), //seperator
        ],
      );
    
    },
  ),
);
  }


  // Remove city from favorite list and SharedPreferences
  void _removeFromFavorites(String city) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(city);
     setState(() {
      favoriteCities.remove(city); // Update the UI immediat
  });
}
}


class CustomSearchDelegate extends SearchDelegate {
  final WeatherFactory weatherFactory;

  CustomSearchDelegate(this.weatherFactory);
  

  @override
  List<Widget>? buildActions(BuildContext context) { //clear search typing
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = ''; 
        },
      ),
      const SizedBox(width: 20,)
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) { //when click return reload the HomeScreen
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        
        close(context, 'reload');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) { // Already do it in buildSuggestion

    return Container(); 
  }

  @override
  Widget buildSuggestions(BuildContext context) {

    return FutureBuilder<List<String>>(
      future: _fetchSuggestions(query),  //fetch city name from search
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Search Some City Name eg. Bangkok , Sydney , London etc.')); //tips
        }

        List<String> suggestions = snapshot.data!;
        return ListView.builder(
          itemCount: suggestions.length,
          itemBuilder: (context, index) {
            String suggestion = suggestions[index];
            return ListTile(
              title: Text(suggestion),  //if seacrh correct 
              onTap: () {
              
                Navigator.push(  //to Reroute to tempscreen and sent city name variable
                  context,
                  MaterialPageRoute(
                    builder: (context) => tempscreen(cityName: suggestion),
                    
                  ),
                );
                
              },
            );
          },
        );
      },
    );
  }

  Future<List<String>> _fetchSuggestions(String query) async {
    if (query.isEmpty) return [];
    try {
      Weather? weather = await weatherFactory.currentWeatherByCityName(query);
      
      return [weather.areaName ?? 'Unknown City'];
        } catch (e) {
      return [];
    }
  }
}
