import 'package:flutter/material.dart';

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
        title: const Text('Chats'),
      ),
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
    return Scaffold(
      appBar: AppBar(
        title: Text(contactName),
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
