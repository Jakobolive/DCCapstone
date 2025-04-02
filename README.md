# URent
## Tinder-like Matching Application for Renters and Landlords

This is a Flutter application that provides a Tinder-style matching platform for renters and landlords. Users can create profiles, swipe to find potential matches, and message those they match with.

## 📱 Application Overview
The app allows users to sign up or log in, create profiles based on their role (renter or landlord), and connect with suitable matches through a swipe-based interface. If a match occurs, users can start messaging each other through a built-in chat feature.

### 🔗 APK Download
You can download the application via the following link: https://github.com/Jakobolive/DCCapstone/releases/download/FirstReleaseTag/app-debug.apk

---

## 🚀 Features
- **User Authentication:**
  - Users can sign up or log in using the Supabase backend.
- **Profile Creation & Editing:**
  - Users can create profiles based on their role:
    - **Renters:** Enter personal information and upload a profile image.
    - **Landlords:** Enter property information, upload property images, and specify rental details.
  - Profiles can be edited at any time.
- **Matching Algorithm:**
  - Matches are found by querying the Supabase database for compatible profiles.
  - Users can swipe to 'like' or 'dislike' potential matches.
  - Mutual likes result in a match.
- **Messaging System:**
  - Matches appear within the messaging page.
  - Users can send messages between matched profiles.

---

## 🛠️ Tech Stack
- **Frontend:** Flutter  
- **Backend:** Supabase (database management, and messaging)  
- **Database:** PostgreSQL (via Supabase)  
- **Deployment:** APK for Android devices  

---

## 📂 Project Structure
lib/
├── main.dart
├── providers/
│   └── user_provider.dart
└── views/
    ├── built_profile_page.dart
    ├── edit_profile_page.dart
    ├── home_page.dart
    ├── login_page.dart
    ├── messaging_page.dart
    ├── profile_page.dart
    └── sign_up_page.dart

---

## 📢 How to Use
1. Download the APK using the provided link above.  
2. Install the application on your Android device.  
3. Sign up or log in.  
4. Create a profile (Renter or Landlord).  
5. Browse profiles by swiping left (dislike) or right (like).  
6. If a match is made, start chatting via the messaging page.  

---

## 📌 Future Improvements
- Add filtering options for more precise matching.  
- Enhance the chat feature to support multimedia messages.  
- Implement push notifications for messages and matches.  
 
