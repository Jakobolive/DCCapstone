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

// Chat List Screen.
class ChatListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Contact Page"),
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
                      : null, // Ensures the value exists in the list.
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
      body: FutureBuilder<List<Map<String, String>>>(
        future: userProvider.fetchContacts(), // Fetch contacts dynamically.
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No contacts available.'));
          }
          final contacts = snapshot.data!;
          return ListView.builder(
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              final contact = contacts[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.teal,
                  backgroundImage: contact['picture'] != null &&
                          contact['picture']!.isNotEmpty
                      ? NetworkImage(contact['picture']!) // Use the image URL.
                      : null, // If no image is available, fall back to initials.
                  child:
                      contact['picture'] == null || contact['picture']!.isEmpty
                          ? Text(
                              contact['name']![
                                  0], // Display the first letter of the name.
                              style: TextStyle(color: Colors.white),
                            )
                          : null, // No text if there's an image.
                ),
                title: Text(contact['name']!),
                subtitle: Text(contact['lastMessage']!),
                onTap: () {
                  int? matchedProfileId =
                      int.tryParse(contact['matchedProfileId'] ?? '') ?? 0;
                  if (matchedProfileId == 0) {
                    // Handle missing or incorrect ID.
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Invalid matched profile ID.")),
                    );
                    return;
                  }
                  // Navigate to ChatScreen with correct profile ID.
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        matchedProfileId: matchedProfileId,
                        contactName: contact['name']!,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

// Chat Screen.
class ChatScreen extends StatefulWidget {
  final int matchedProfileId;
  final String contactName;
  ChatScreen({required this.matchedProfileId, required this.contactName});
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController messageController = TextEditingController();
  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider
        .fetchMessages(widget.matchedProfileId); // Fetch full chat history.
  }

  // Common UI.
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final messages = userProvider.getMessages(widget.matchedProfileId);
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${widget.contactName}'),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          // Messages List.
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
                    margin: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.blue : Colors.grey[300],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      message['message']!,
                      style:
                          TextStyle(color: isMe ? Colors.white : Colors.black),
                    ),
                  ),
                );
              },
            ),
          ),
          // Message Input.
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(hintText: 'Type a message...'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    final text = messageController.text.trim();
                    if (text.isNotEmpty) {
                      userProvider.sendMessage(widget.matchedProfileId, text);
                      messageController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
