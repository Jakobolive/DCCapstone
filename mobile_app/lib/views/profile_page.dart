// import 'package:capstone_app/providers/user_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class ProfilePage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final userProvider = Provider.of<UserProvider>(context);
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: const Text("Profile"),
//         centerTitle: true,
//         backgroundColor: Colors.teal,
//         actions: [
//           // Profile Dropdown (Shows renter profiles first, otherwise landlord profiles)
//           if (userProvider.renterProfiles.isNotEmpty ||
//               userProvider.landlordProfiles.isNotEmpty)
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 10),
//               child: DropdownButton<Map<String, dynamic>>(
//                 value: userProvider.selectedProfile,
//                 hint: const Text("Select Profile"),
//                 dropdownColor: Colors.white,
//                 icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
//                 onChanged: (Map<String, dynamic>? newValue) {
//                   if (newValue != null) {
//                     final isRenter =
//                         userProvider.renterProfiles.contains(newValue);
//                     userProvider.setSelectedProfile(
//                         newValue, isRenter ? "Renter" : "Landlord");
//                   }
//                 },
//                 items: [
//                   ...userProvider.renterProfiles.map((profile) {
//                     return DropdownMenuItem<Map<String, dynamic>>(
//                       value: profile,
//                       child:
//                           Text(profile['preferred_name'] ?? "Renter Profile"),
//                     );
//                   }),
//                   ...userProvider.landlordProfiles.map((profile) {
//                     return DropdownMenuItem<Map<String, dynamic>>(
//                       value: profile,
//                       child:
//                           Text(profile['street_address'] ?? "Landlord Profile"),
//                     );
//                   }),
//                 ],
//               ),
//             ),

//           // Refresh Button
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: () async {
//               await userProvider.fetchProfiles();
//             },
//           ),

//           // Profile Creation Icon
//           IconButton(
//             icon: const Icon(Icons.person_add),
//             onPressed: () {
//               Navigator.pushNamed(context, '/build-profile');
//             },
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             children: [
//               // Profile Picture
//               CircleAvatar(
//                 radius: 60,
//                 backgroundImage: AssetImage(
//                     "assets/placeholder.jpg"), // Replace with dynamic image
//               ),
//               const SizedBox(height: 16),

//               // Name
//               const Text(
//                 "John Doe", // Replace with dynamic user name
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 8),

//               // Email
//               const Text(
//                 "johndoe@example.com", // Replace with dynamic user email
//                 style: TextStyle(
//                   fontSize: 16,
//                   color: Colors.grey,
//                 ),
//               ),
//               const SizedBox(height: 16),

//               // About Section
//               const Text(
//                 "About Me",
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               const Text(
//                 "I am a property manager specializing in residential units. Feel free to contact me for inquiries.", // Dynamic content
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: 16,
//                   color: Colors.black87,
//                 ),
//               ),
//               const SizedBox(height: 20),

//               // Contact Information
//               ListTile(
//                 leading: Icon(Icons.phone, color: Colors.teal),
//                 title: const Text("Phone"),
//                 subtitle: const Text("+1 123 456 7890"), // Dynamic content
//               ),
//               const Divider(),
//               ListTile(
//                 leading: Icon(Icons.location_on, color: Colors.teal),
//                 title: const Text("Location"),
//                 subtitle: const Text("Toronto, ON, Canada"), // Dynamic content
//               ),
//               const Divider(),

//               // Edit Profile Button
//               ElevatedButton.icon(
//                 onPressed: () {
//                   // Add navigation to edit profile page.
//                   Navigator.pushReplacementNamed(context, '/edit-profile');
//                 },
//                 icon: const Icon(Icons.edit),
//                 label: const Text("Edit Profile"),
//                 style: ElevatedButton.styleFrom(
//                   padding:
//                       const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   backgroundColor: Colors.teal,
//                 ),
//               ),
//               const SizedBox(height: 16),

//               // Logout Button
//               TextButton(
//                 onPressed: () {
//                   // Add logout logic
//                 },
//                 child: const Text(
//                   "Log Out",
//                   style: TextStyle(
//                     color: Colors.red,
//                     fontSize: 16,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:capstone_app/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final selectedProfile = userProvider.selectedProfile;
    final userType = userProvider.userType;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
        backgroundColor: Colors.teal,
        actions: [
          // Profile Dropdown
          if (userProvider.renterProfiles.isNotEmpty ||
              userProvider.landlordProfiles.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: DropdownButton<Map<String, dynamic>>(
                value: selectedProfile,
                hint: const Text("Select Profile"),
                dropdownColor: Colors.white,
                icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                onChanged: (Map<String, dynamic>? newValue) {
                  if (newValue != null) {
                    final isRenter =
                        userProvider.renterProfiles.contains(newValue);
                    userProvider.setSelectedProfile(
                        newValue, isRenter ? "Renter" : "Landlord");
                  }
                },
                items: [
                  ...userProvider.renterProfiles.map((profile) {
                    return DropdownMenuItem<Map<String, dynamic>>(
                      value: profile,
                      child:
                          Text(profile['preferred_name'] ?? "Renter Profile"),
                    );
                  }),
                  ...userProvider.landlordProfiles.map((profile) {
                    return DropdownMenuItem<Map<String, dynamic>>(
                      value: profile,
                      child:
                          Text(profile['street_address'] ?? "Landlord Profile"),
                    );
                  }),
                ],
              ),
            ),

          // Refresh Button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await userProvider.fetchProfiles();
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
      body: selectedProfile == null
          ? Center(
              child: Text(
                "No profile selected",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Profile Picture
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: AssetImage("assets/placeholder.jpg"),
                    ),
                    const SizedBox(height: 16),

                    // Name
                    Text(
                      selectedProfile['preferred_name'] ??
                          selectedProfile['street_address'] ??
                          "Unknown",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Email (if available)
                    if (selectedProfile.containsKey('email'))
                      Text(
                        selectedProfile['email'] ?? "No email provided",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    const SizedBox(height: 16),

                    // About Section
                    Text(
                      "About Me",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      userType == "Renter"
                          ? (selectedProfile['bio'] ?? "No bio available.")
                          : "This property is located at ${selectedProfile['street_address'] ?? "Unknown Address"}",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    const SizedBox(height: 20),

                    // Contact Information
                    if (selectedProfile.containsKey('phone'))
                      ListTile(
                        leading: Icon(Icons.phone, color: Colors.teal),
                        title: Text("Phone"),
                        subtitle:
                            Text(selectedProfile['phone'] ?? "Not provided"),
                      ),
                    const Divider(),

                    if (userType == "Landlord" &&
                        selectedProfile.containsKey('street_address'))
                      ListTile(
                        leading: Icon(Icons.location_on, color: Colors.teal),
                        title: Text("Property Location"),
                        subtitle: Text(selectedProfile['street_address'] ??
                            "Not provided"),
                      ),
                    const Divider(),

                    // Edit Profile Button
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushReplacementNamed(
                            context, '/edit-profile');
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text("Edit Profile"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        backgroundColor: Colors.teal,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Logout Button
                    TextButton(
                      onPressed: () {
                        userProvider.clearUser();
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: const Text(
                        "Log Out",
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
