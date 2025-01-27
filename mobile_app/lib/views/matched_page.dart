import 'package:flutter/material.dart';

class MatchPopupPage extends StatelessWidget {
  final String matchName;
  final String matchProfileImage;

  MatchPopupPage({required this.matchName, required this.matchProfileImage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Match animation or icon
            Icon(
              Icons.favorite,
              color: Colors.pinkAccent,
              size: 80,
            ),
            const SizedBox(height: 20),

            // "It's a Match!" text
            Text(
              "It's a Match!",
              style: TextStyle(
                fontSize: 32,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            // Match name text
            Text(
              "You and $matchName like each other!",
              style: TextStyle(
                fontSize: 18,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 20),

            // Match profile picture
            CircleAvatar(
              radius: 70,
              backgroundImage: NetworkImage(matchProfileImage),
            ),
            const SizedBox(height: 30),

            // Message Button
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to the chat screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(contactName: matchName),
                  ),
                );
              },
              icon: Icon(Icons.message),
              label: Text("Message $matchName"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                textStyle: TextStyle(fontSize: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Dismiss button
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the popup
              },
              child: Text(
                "Maybe later",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Example Chat Screen (for navigation demonstration)
class ChatScreen extends StatelessWidget {
  final String contactName;

  ChatScreen({required this.contactName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(contactName),
      ),
      body: Center(
        child: Text("Chat with $contactName"),
      ),
    );
  }
}
