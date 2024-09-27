import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:weather/weather.dart';
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

  @override

    void initState() {
    super.initState();
    _loadFavoriteCities(); //For loading Favourite City
  }


  
   void _loadFavoriteCities() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      favoriteCities = prefs.getKeys().where((key) => prefs.getBool(key) ?? false).toList();
    });
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
        title: Text("Weather Application", style:  
        GoogleFonts.prompt(fontSize: 30,
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
            
            child: Text("Fast Favorite Tap List",   //Favourite City List 
                style: GoogleFonts.prompt(
                  color: const Color.fromARGB(242, 255, 255, 255),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic
                ),
              
            ),
          ),
          Expanded(
            child: _buildFavoriteCitiesList(), //Call function to create favourite List
          ),
        ],
      ),
      backgroundColor: Colors.lightBlue,
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
      
      return Column(
        children: [
          Container(
            color: Colors.lightBlue[100], // Set background color
            child: ListTile(
              title: Text(
                city,
                style: GoogleFonts.prompt(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              trailing: IconButton( // Icon for remove from list
                icon: const Icon(Icons.cancel_outlined, color: Colors.red),
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
