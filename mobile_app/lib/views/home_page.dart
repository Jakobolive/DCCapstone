import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:card_swiper/card_swiper.dart';
import '../providers/user_provider.dart'; // Import your provider

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => UserProvider(),
      child: SwipeExampleApp(),
    ),
  );
}

class SwipeExampleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Swipe Example',
      home: SwipePage(),
    );
  }
}

class SwipePage extends StatelessWidget {
  final List<Map<String, String>> listings = [
    {
      "image":
          "https://images.unsplash.com/photo-1570129477492-45c003edd2be?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=400",
      "title": "Modern Apartment",
      "price": "\$1,200/month"
    },
    {
      "image":
          "https://images.unsplash.com/photo-1560185127-6c4f2bafec15?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=400",
      "title": "Cozy Studio",
      "price": "\$800/month"
    },
  ];

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Swipe Rentals"),
        centerTitle: true,
        backgroundColor: Colors.teal,
        actions: [
          // Profile Dropdown
          if (userProvider.profiles.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: DropdownButton<String>(
                value: userProvider.selectedProfile,
                hint: const Text("Select Profile"),
                dropdownColor: Colors.white,
                icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    userProvider.setSelectedProfile(newValue);
                  }
                },
                items: userProvider.profiles.map((profile) {
                  return DropdownMenuItem<String>(
                    value:
                        profile['street_address'] ?? profile['preferred_name'],
                    child: Text(
                        profile['street_address'] ?? profile['preferred_name']),
                  );
                }).toList(),
              ),
            ),

          // Refresh Button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await userProvider
                  .fetchProfiles(); // Call method to refresh profiles
            },
          ),
          // Profile Creation Icon
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () {
              Navigator.pushNamed(context, '/build-profile');
            },
          ),
        ],
      ),
      body: Swiper(
        itemBuilder: (BuildContext context, int index) {
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(20)),
                    child: Image.network(
                      listings[index]['image']!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        listings[index]['title']!,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        listings[index]['price']!,
                        style:
                            const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        itemCount: listings.length,
        itemWidth: MediaQuery.of(context).size.width * 0.85,
        itemHeight: MediaQuery.of(context).size.height * 0.6,
        layout: SwiperLayout.DEFAULT,
        onIndexChanged: (index) {
          print('Swiped to card at index: $index');
        },
        onTap: (index) {
          print('Tapped on card at index: $index');
        },
      ),
    );
  }
}
