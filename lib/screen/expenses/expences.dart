import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:smart_truck_elektronik/model/expense.dart';
import 'package:smart_truck_elektronik/screen/expenses/create_expense_page.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ExpensesPage extends StatefulWidget {
  @override
  _ExpensesPageState createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> {
  List<Expense> expenses = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchExpenses();
  }

  double get totalAmount {
    return expenses.fold(0.0, (sum, item) => sum + item.amount);
  }

  Future<void> _fetchExpenses() async {
    isLoading = true;

    final url = Uri.parse('https://smart-truck-elektronik.com/api/expenses');

    try {
      print('titklendi');
      // Retrieve the stored token
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      print('Token : ' + token.toString());
      // Ensure the token is not null
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token', // Pass the token in the headers
        },
      );

      if (response.statusCode >= 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData['success']) {
          setState(() {
            expenses = (responseData['data'] as List)
                .map((item) => Expense(
                      id: item['id'],
                      description: item['description'],
                      amount: double.parse(item['amount']),
                    ))
                .toList();
          });
          if (expenses.length < 1) {
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
          print('Error: ${responseData['message']}');
        }
      } else {
        print('Failed to load expenses: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching expenses: $error');
    }
    isLoading = false;
  }

  void _addExpense(String description, double amount) async {
    final url =
        Uri.parse('https://smart-truck-elektronik.com/api/expenses/store');

    final expenseData = {
      'description': description,
      'amount': amount,
    };

    // Retrieve the stored token
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Pass the token in the headers
      },
      body: jsonEncode(expenseData),
    );

    if (response.statusCode >= 200) {
      setState(() {
        expenses.add(Expense(
          id: expenses.length + 1,
          description: description,
          amount: amount,
        ));
      });
    } else {
      print('Failed to add expense: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  void _deleteExpense(int id) async {
  
    final url = Uri.parse(
        'https://smart-truck-elektronik.com/api/expenses/delete/' +
            id.toString());

    // Retrieve the stored token
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Pass the token in the headers
      },
    );

    if (response.statusCode >= 200) {
      setState(() {
        expenses.removeWhere((expense) => expense.id == id);
      });
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Başarız Eylem"),
            content: Text("Lütfen daha sonra tekar deneyiniz."),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ödemeler'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Total: ${totalAmount.toStringAsFixed(2)}TL',
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
              itemCount: expenses.length,
              itemBuilder: (context, index) {
                final expense = expenses[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text(expense.description),
                    subtitle:
                        Text('Tutar: ${expense.amount.toStringAsFixed(2)}TL'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          color: Colors.red,
                          icon: Icon(Icons.delete),
                          onPressed: () => _deleteExpense(expense.id),
                        ),
                      ],
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
              builder: (context) => CreateExpensePage(
                onExpenseCreated: (description, amount) {
                  _addExpense(description, amount);
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
