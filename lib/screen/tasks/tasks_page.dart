import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:smart_truck_elektronik/model/task.dart'; // Update to import Task model
import 'package:smart_truck_elektronik/screen/tasks/create_task_page.dart'; // Update to create_task_page
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class TasksPage extends StatefulWidget {
  @override
  _TasksPageState createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  List<Task> tasks = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    isLoading = true;
    final url = Uri.parse('https://smart-truck-elektronik.com/api/tasks');

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
            tasks = (responseData['data'] as List)
                .map((item) => Task.fromJson(item))
                .toList();
          });

          if (tasks.isEmpty) {
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
                        Navigator.of(context).pop();
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
        print('Failed to load tasks: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching tasks: $error');
    }
    isLoading = false;
  }

  void _addTask(Task task) async {
    final url = Uri.parse('https://smart-truck-elektronik.com/api/tasks/store');

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    var request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = 'Bearer $token';

    // Add text fields
    request.fields['name'] = task.name;
    request.fields['telNumber'] = task.telNumber;
    request.fields['product'] = task.product;
    request.fields['cost'] = task.cost.toString();
    request.fields['qty'] = task.qty.toString();
    request.fields['reason'] = task.reason;

    // Add image file if it's not null
    if (task.image.isNotEmpty) {
      var imageFile = http.MultipartFile.fromBytes(
        'image',
        await File(task.image).readAsBytes(),
        filename: task.image.split('/').last,
      );
      request.files.add(imageFile);
    }

    // Send the request
    var response = await request.send();

    if (response.statusCode >= 200) {
      // setState(() {
      //   tasks.add(Task(
      //     id: tasks.length + 1,
      //     name: task.name,
      //     telNumber: task.telNumber,
      //     product: task.product,
      //     cost: task.cost,
      //     qty: task.qty,
      //     reason: task.reason,
      //     image: 'assets/img/logo-light.svg',
      //   ));
      // });
      _fetchTasks();
    } else {
      print('Failed to add task: ${response.statusCode}');
      print('Response body: ${await response.stream.bytesToString()}');
    }
  }

  void _deleteTask(int id) async {
    final url =
        Uri.parse('https://smart-truck-elektronik.com/api/tasks/delete/$id');

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode >= 200) {
      setState(() {
        tasks.removeWhere((task) => task.id == id);
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
        title: Text('Tamirler'),
      ),
      body: Column(
        children: [

          // Loading indicator
          if (isLoading)
            Padding(
              padding: EdgeInsets.all(12.0),
              child: CircularProgressIndicator(),
            ),

          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return Column(
                  children: [
                    Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Image Section with OnClick to Show Modal
                          if (task.image.isNotEmpty)
                            InkWell(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Dialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(
                                          'https://smart-truck-elektronik.com/' +
                                              task.image,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(12)),
                                child: Image.network(
                                  'https://smart-truck-elektronik.com/' +
                                      task.image,
                                  height: 150,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Title Section
                                Text(
                                  'Müşteri ADI : ${task.name}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Divider(),
                                // Description Section
                                Text(
                                  'ÜRÜN : ${task.product}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Divider(),
                                Text(
                                  task.reason,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Divider(),
                                // ÜCRET (Cost) display
                                Container(
                                  padding: EdgeInsets.symmetric(vertical: 3.0),
                                  child: Text(
                                    'ÜCRET: ${NumberFormat('#,##0.00', 'en_US').format(task.cost)} TL',
                                    style: TextStyle(
                                      color: Colors.grey[800],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),

                                // ADET (Quantity) display
                                Container(
                                  padding: EdgeInsets.symmetric(vertical: 3.0),
                                  child: Text(
                                    'ADET: ${task.qty}',
                                    style: TextStyle(
                                      color: Colors.grey[800],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),

                                // TOPLAM (Total) display
                                Container(
                                  child: Text(
                                    'TOPLAM: ${NumberFormat('#,##0.00', 'en_US').format(task.qty * task.cost)} TL',
                                    style: TextStyle(
                                      color: Colors.green[700],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),

                                // Divider line
                                Divider(
                                  color: Colors.blueAccent.withOpacity(0.5),
                                  thickness: 2,
                                ),
                                // Button Section
                                ElevatedButton(
                                  onPressed: () => _deleteTask(task.id),
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    iconColor: Colors.red,
                                  ),
                                  child: Icon(Icons.delete),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      color: Colors.blueAccent.withOpacity(0.5),
                      indent: 20,
                      endIndent: 20,
                      thickness: 1,
                    ),
                  ],
                );
              },
            ),
          ),

// ---------------------------
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CreateTaskPage(
                onTaskCreated: (task) {
                  _addTask(task);
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
