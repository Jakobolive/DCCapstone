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
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Page"),
        centerTitle: true,
        backgroundColor: Colors.teal,
        actions: [
          if ((userProvider.renterProfiles?.isNotEmpty ?? false) ||
              (userProvider.landlordProfiles?.isNotEmpty ?? false))
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: DropdownButton<Map<String, dynamic>>(
                  value: (userProvider.selectedProfile != null &&
                          (userProvider.renterProfiles?.contains(
                                      userProvider.selectedProfile!) ==
                                  true ||
                              userProvider.landlordProfiles?.contains(
                                      userProvider.selectedProfile!) ==
                                  true))
                      ? userProvider.selectedProfile
                      : null, // Ensures the value exists in the list
                  hint: const Text("Select Profile"),
                  dropdownColor: Colors.white,
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                  onChanged: (Map<String, dynamic>? newValue) {
                    if (newValue != null) {
                      final profileType = newValue['userType'];
                      userProvider.setSelectedProfile(newValue,
                          profileType == 'Renter' ? "Renter" : "Landlord");
                      userProvider.fetchProfiles();
                    }
                  },
                  items: [
                    if (userProvider.renterProfiles != null)
                      ...userProvider.renterProfiles!.map((profile) {
                        return DropdownMenuItem<Map<String, dynamic>>(
                          value: profile,
                          child: Text(
                              profile['preferred_name'] ?? "Renter Profile"),
                        );
                      }),
                    if (userProvider.landlordProfiles != null)
                      ...userProvider.landlordProfiles!.map((profile) {
                        return DropdownMenuItem<Map<String, dynamic>>(
                          value: profile,
                          child: Text(
                              profile['street_address'] ?? "Landlord Profile"),
                        );
                      }),
                  ],
                )),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await userProvider.fetchProfiles();
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () {
              Navigator.pushNamed(context, '/build-profile');
            },
          ),
        ],
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final isRenter = userProvider.selectedProfile != null &&
              userProvider.userType! == 'Renter';

          print('isRenter: $isRenter');

          // Determine which data to show based on the user type
          final profilesToShow = userProvider.profiles;

          return profilesToShow?.isEmpty ?? true
              ? const Center(child: CircularProgressIndicator())
              : Swiper(
                  itemBuilder: (BuildContext context, int index) {
                    // Determine whether to show profile or listing data
                    final data =
                        profilesToShow![index]; // Renters see Landlord profiles
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(20)),
                              child: Image.network(
                                data['photo_url'] ?? '',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(child: Icon(Icons.error));
                                },
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (isRenter) ...[
                                  // Assuming it is a renter profile, display listings.
                                  Text(
                                    data['street_address'] ?? "No title",
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    data['asking_price']?.toString() ??
                                        "No price",
                                    style: const TextStyle(
                                        fontSize: 16, color: Colors.grey),
                                  ),
                                  Text(
                                    data['listing_bio'] ?? "No Bio Available",
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ]
                                // For Renters, show preference-specific information
                                else if (!isRenter) ...[
                                  Text(
                                    data['preferred_name'] ??
                                        "No preferred name",
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  Text(
                                    data['profile_bio'] ?? "No Bio Available",
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  itemCount: profilesToShow.length ?? 0,
                  // ? profilesToShow?.length ?? 0
                  // : listingsToShow?.length ?? 0,
                  itemWidth: MediaQuery.of(context).size.width * 0.85,
                  itemHeight: MediaQuery.of(context).size.height * 0.6,
                  layout: SwiperLayout.DEFAULT,
                  onIndexChanged: (index) {
                    print('Swiped to card at index: $index');
                  },
                  onTap: (index) {
                    print('Tapped on card at index: $index');
                  },
                );
        },
      ),
    );
  }
}
