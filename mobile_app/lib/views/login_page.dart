import 'package:capstone_app/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bcrypt/bcrypt.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  // Login functionality.
  Future<void> _login(BuildContext context) async {
    final supabase = Supabase.instance.client;
    // Basic input validation to ensure we're not dealing with empty strings.
    if (emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Email Is Required")),
      );
      return;
    }
    if (passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Password Is Required")),
      );
      return;
    }
    try {
      // Fetch the user record by email.
      final response = await supabase
          .from('users_table')
          .select('password, user_id')
          .eq('email_address', emailController.text.toLowerCase().trim())
          .single(); // Ensures we only get one user.
      if (response != null) {
        final storedHashedPassword = response['password'];
        // Compare input password with stored hash.
        final isPasswordCorrect = BCrypt.checkpw(
            passwordController.text.trim(), storedHashedPassword);
        if (isPasswordCorrect) {
          final int userId = response['user_id'];
          // Store the user session. (e.g., in a provider)
          print("Login successful! User ID: $userId");
          Provider.of<UserProvider>(context, listen: false).setUserId(userId);
          // Redirect user.
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Incorrect email or password")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("User not found")),
        );
      }
    } catch (e) {
      // If there was an error during the query or login.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  // Common UI.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white,
        appBar: AppBar(
            title: const Text("Sign In"),
            centerTitle: true,
            backgroundColor: Colors.teal),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(
                  child: Text(
                    "Login",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 40),
                // Email Input Field.
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    prefixIcon: const Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 16),
                // Password Input Field.
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    prefixIcon: const Icon(Icons.lock),
                  ),
                ),
                const SizedBox(height: 20),
                // Login Button.
                ElevatedButton(
                  onPressed: () =>
                      _login(context), // Calls the _login function.
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("Login", style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(height: 16),
                // Forgot Password / Sign Up Links.
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        // Implement forgot password functionality here.
                        Navigator.pushNamed(context, '/signup');
                      },
                      child: const Text("Forgot Password?"),
                    ),
                    const Text("|"),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/signup');
                      },
                      child: const Text("Sign Up"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ));
  }
}
