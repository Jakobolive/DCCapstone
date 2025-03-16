import 'package:capstone_app/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MessengerApp());
}

class MessengerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Messenger App',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: ChatListScreen(),
    );
  }
}

// Chat List Screen
class ChatListScreen extends StatelessWidget {
  final List<Map<String, String>> contacts = [
    {"name": "Alice Johnson", "lastMessage": "Hey, how's it going?"},
    {"name": "Bob Smith", "lastMessage": "Can you send me the files?"},
    {"name": "Charlie Brown", "lastMessage": "Let's meet up tomorrow."},
    {"name": "Diana Prince", "lastMessage": "Thanks for the update!"},
    {"name": "Ethan Hunt", "lastMessage": "Mission completed!"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Chats"),
          centerTitle: true,
          backgroundColor: Colors.teal),
      body: ListView.builder(
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          final contact = contacts[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.teal,
              child: Text(
                contact['name']![0], // Display the first letter of the name
                style: TextStyle(color: Colors.white),
              ),
            ),
            title: Text(contact['name']!),
            subtitle: Text(contact['lastMessage']!),
            onTap: () {
              // Navigate to the chat screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ChatScreen(contactName: contact['name']!),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// Chat Screen
class ChatScreen extends StatelessWidget {
  final String contactName;

  ChatScreen({required this.contactName});

  final List<Map<String, String>> messages = [
    {"from": "me", "message": "Hey! How are you?"},
    {"from": "contact", "message": "I'm good, how about you?"},
    {"from": "me", "message": "Doing great, just working on a project."},
    {"from": "contact", "message": "Nice! Let me know if you need help."},
  ];

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Messaging Page"),
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
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isMe = message['from'] == 'me';
                return Align(
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.teal : Colors.grey[300],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      message['message']!,
                      style: TextStyle(
                        color: isMe ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Message Input
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: () {
                    // Add send message functionality here
                  },
                  child: const Icon(Icons.send),
                  mini: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
