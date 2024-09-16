// screens/sales_page.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_truck_elektronik/model/sale.dart';
import 'package:smart_truck_elektronik/screen/sales/create_sale_page.dart';

class SalesPage extends StatefulWidget {
  @override
  _SalesPageState createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  List<Sale> sales = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchSales();
  }

  double get totalSalesAmount {
    return sales.fold(0.0, (sum, sale) => sum + sale.total);
  }

  Future<void> _fetchSales() async {
        isLoading = true;

    final url = Uri.parse('https://smart-truck-elektronik.com/api/sales');
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode >= 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['success']) {
          setState(() {
            sales = (responseData['data'] as List)
                .map((item) => Sale(
                      id: item['id'],
                      customerName: item['customer_name'],
                      productName: item['product_name'],
                      phone: item['phone'],
                      qty: item['qty'],
                      amount: double.parse(item['amount']),
                      total: double.parse(item['total']),
                    ))
                .toList();
          });
        } else {
          print('Error: ${responseData['message']}');
        }
      } else {
        print('Failed to load sales: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching sales: $error');
    }
      isLoading = false;

  }

  void _addSale(String customerName, String productName, String phone, int qty,
      double amount) async {
    final url = Uri.parse('https://smart-truck-elektronik.com/api/sales/store');

    final saleData = {
      'customer_name': customerName,
      'product_name': productName,
      'phone': phone,
      'qty': qty,
      'amount': amount,
      'total': qty * amount,
    };

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(saleData),
    );

    if (response.statusCode >= 200) {
      setState(() {
        sales.add(Sale(
          id: sales.length + 1,
          customerName: customerName,
          productName: productName,
          phone: phone,
          qty: qty,
          amount: amount,
          total: qty * amount,
        ));
      });

  if (sales.length < 1) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("VERI MERKEZI"),
                  content: Text("SUNULANACAK VERI BULUNAMADI."),
                  actions: <Widget>[
                    TextButton(
                      child: Text("OK"),
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                      },
                    ),
                  ],
                );
              },
            );
          }


    } else {
      
      print('Failed to add sale: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  void _deleteSale(int id) async {
    final url = Uri.parse(
        'https://smart-truck-elektronik.com/api/sales/delete/' + id.toString());

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        sales.removeWhere((sale) => sale.id == id);
      });
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Başarısız Eylem"),
            content: Text("Lütfen daha sonra tekrar deneyiniz."),
            actions: <Widget>[
              TextButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Satışları'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Tutarı: ${totalSalesAmount.toStringAsFixed(2)}TL',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue),
            ),
          ),
          Divider(),


 // Loading indicator
          if (isLoading)
            Padding(
              padding: EdgeInsets.all(12.0),
              child: CircularProgressIndicator(),
            ),

          Expanded(
            child: ListView.builder(
              itemCount: sales.length,
              itemBuilder: (context, index) {
                final sale = sales[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text('${sale.productName}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            'Adet: ${sale.qty} x ${sale.amount.toStringAsFixed(2)} = ${sale.total.toStringAsFixed(2)}TL'),
                        Divider(),
                        Text('Muşteri: ${sale.customerName}'),
                        Divider(),
                        Text('Tel: ${sale.phone}'),
                      ],
                    ),
                    trailing: IconButton(
                      color: Colors.red,
                      icon: Icon(Icons.delete),
                      onPressed: () => _deleteSale(sale.id),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CreateSalePage(
                onSaleCreated: (customerName, productName, phone, qty, amount) {
                  _addSale(customerName, productName, phone, qty, amount);
                },
              ),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
