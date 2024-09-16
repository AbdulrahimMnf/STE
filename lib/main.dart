import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_truck_elektronik/screen/expenses/expences.dart';
import 'package:smart_truck_elektronik/screen/login.dart';
import 'package:smart_truck_elektronik/screen/sales/sales.dart';
import 'package:smart_truck_elektronik/screen/tasks/tasks_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Truck Elektronik',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/': (context) => MyHomePage(title: 'Yönetim sistemi'),
        '/expenses': (context) => ExpensesPage(),
        '/login': (context) => LoginPage(),
        '/sales': (context) => SalesPage(),
        '/tasks': (context) => TasksPage(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 1;
  List<dynamic> products = [];
  bool isLoading = false;
  TextEditingController searchController = TextEditingController();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    void resetData() {
      setState(() {
        products = [];
      });
    }

    switch (index) {
      case 0:
        resetData();
        Navigator.pushNamed(context, '/tasks');
        break;
      case 1:
        resetData();

        Navigator.pushNamed(context, '/sales');
        break;
      case 2:
        resetData();
        Navigator.pushNamed(context, '/expenses');
        break;
    }
  }


  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token'); // Adjust this key to match your stored data

    // Navigate to the login page
    Navigator.popAndPushNamed(context, '/login');
  }


  Future<void> searchProducts(String query) async {
    setState(() {
      isLoading = true;
    });

    try {
      final url = Uri.parse('https://smart-truck-elektronik.com/api/products');

      // Prepare the request body
      final body = jsonEncode({'search': query});

      // Retrieve the stored token
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      if (token == null) {
        print('Token not found');
        return;
      }

      // Send the POST request
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Include the token in the headers
        },
        body: body,
      );

      if (response.statusCode >= 200) {
        final responseBody = json.decode(response.body);

        final List<dynamic> data = responseBody['data'];
        print(data);
        setState(() {
          products = data;
        });
      } else {
        print('Failed to fetch products: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error fetching products: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('lib/assets/img/logo-n.png'),
            // Search Section
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(labelText: 'Ürünü Ara'),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      searchProducts(searchController.text);
                    },
                  ),
                ],
              ),
            ),
            // Loading indicator
            if (isLoading) CircularProgressIndicator(),
            // Display list of products
            if (!isLoading && products.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    var product = products[index];
                    var productName =
                        product['name']['tr']; // Access the Turkish name
                    var productQty = product['qty'].toString(); //
                    var productQr = product['barcode'].toString(); //
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: ListTile(
                        title: Text(productName),
                        subtitle: Text('Barkod: ${productQr.toString()}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              productQty.toString(),
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

            if (!isLoading && products.isEmpty)
              const Text('ürün bilgisi için arama yapınız / Bulunamadı'),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_fix_high_rounded),
            label: 'TAMİR',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sell),
            label: 'SATIŞ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.money),
            label: 'ÖDEME',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _logout(context),
        child: const Icon(Icons.lock),
      ),
    );
  }
}
