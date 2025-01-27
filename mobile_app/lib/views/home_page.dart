import 'package:flutter/material.dart';
import 'package:card_swiper/card_swiper.dart';

void main() {
  runApp(SwipeExampleApp());
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
    return Scaffold(
      appBar: AppBar(title: Text("Swipe Rentals")),
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
                        BorderRadius.vertical(top: Radius.circular(20)),
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
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        listings[index]['price']!,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
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
        layout: SwiperLayout.DEFAULT, // Corrected layout
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
