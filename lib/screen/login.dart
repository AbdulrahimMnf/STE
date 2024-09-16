import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

// class _LoginPageState extends State<LoginPage> {
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   bool _isLoading = false;
//   bool _isPasswordVisible = false;

//   @override
//   void initState() {
//     _isLoading = true;
//     super.initState();
//     // Check if the user is already logged in
//     _checkLoginStatus();
//     _isLoading = false;
//   }

//   Future<void> _checkLoginStatus() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();

//     // Check if the token is stored
//     final String? token = prefs.getString('auth_token');

//     if (token != null && token.isNotEmpty) {
//       // User is already logged in, navigate to the home page
//       Navigator.pushReplacementNamed(context, '/');
//     }
//   }

//   Future<void> _login() async {
//     setState(() {
//       _isLoading = true;
//     });

//     final String apiUrl = "https://smart-truck-elektronik.com/api/login";

//     final response = await http.post(
//       Uri.parse(apiUrl),
//       headers: {"Content-Type": "application/json"},
//       body: jsonEncode({
//         "email": _emailController.text,
//         "password": _passwordController.text,
//       }),
//     );

//     setState(() {
//       _isLoading = false;
//     });

//     if (response.statusCode == 200) {
//       final Map<String, dynamic> responseData = jsonDecode(response.body);
//       // Extract the token from the parsed JSON
//       final String token = responseData['token'];

//       // Store the token
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       await prefs.setString('auth_token', token);
//       // Navigate to the home page on successful login
//       Navigator.pushReplacementNamed(context, '/');
//     } else {
//       // Handle error, e.g., show error message
//       print("Login failed: ${response.body}");

//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: Text("Başarız Eylem"),
//             content: Text("Lütfen bilgileri kontrol edip tekar deneyiniz."),
//             actions: <Widget>[
//               TextButton(
//                 child: Text("OK"),
//                 onPressed: () {
//                   Navigator.of(context).pop(); // Close the dialog
//                 },
//               ),
//             ],
//           );
//         },
//       );

//       // ------------------
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       resizeToAvoidBottomInset: true,
//       backgroundColor: Colors.blue[50],
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 20.0),
//         child: Center(
//           child: SingleChildScrollView(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Image.asset('lib/assets/img/logo-n-1.png'),
//                 SizedBox(height: 8),
//                 Text(
//                   "Giriş Sayfası",
//                   style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
//                 ),
//                 Text(
//                   "Bilgileriniz Giriniz",
//                   style: TextStyle(fontSize: 16, color: Colors.grey),
//                 ),
//                 SizedBox(height: 40),
//                 TextField(
//                   controller: _emailController,
//                   decoration: InputDecoration(
//                     prefixIcon: Icon(Icons.person),
//                     labelText: "E-mail",
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10.0),
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 20),
//                 TextField(
//                   controller: _passwordController,
//                   obscureText: !_isPasswordVisible,
//                   decoration: InputDecoration(
//                     prefixIcon: Icon(Icons.lock),
//                     suffixIcon: IconButton(
//                       icon: Icon(
//                         _isPasswordVisible
//                             ? Icons.visibility
//                             : Icons.visibility_off,
//                       ),
//                       onPressed: () {
//                         setState(() {
//                           _isPasswordVisible = !_isPasswordVisible;
//                         });
//                       },
//                     ),
//                     labelText: "Password",
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10.0),
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 40),
//                 _isLoading
//                     ? CircularProgressIndicator()
//                     : SizedBox(
//                         width: double.infinity,
//                         height: 50,
//                         child: ElevatedButton(
//                           onPressed: _login,
//                           style: ElevatedButton.styleFrom(
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(10.0),
//                             ),
//                           ),
//                           child: Text("Giriş Yap"),
//                         ),
//                       ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }




class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('auth_token');

    if (token != null && token.isNotEmpty) {
      Navigator.pushReplacementNamed(context, '/');
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showErrorDialog("Error", "Email yada password boş olmamalı.");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final String apiUrl = "https://smart-truck-elektronik.com/api/login";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": _emailController.text,
          "password": _passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final String token = responseData['token'];

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);

        Navigator.pushReplacementNamed(context, '/');
      } else {
        _showErrorDialog("Login Failed", "Lütfen kimlik bilgilerinizi kontrol edin ve tekrar deneyin.");
      }
    } catch (e) {
      _showErrorDialog("Error", "Bir hata oluştu. Lütfen daha sonra tekrar deneyin.");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.blue[50],
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('lib/assets/img/logo-n-1.png'),
                SizedBox(height: 8),
                Text(
                  "Giriş Sayfası",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Bilgileriniz Giriniz",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                SizedBox(height: 40),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.person),
                    labelText: "E-mail",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    labelText: "Password",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                SizedBox(height: 40),
                _isLoading
                    ? CircularProgressIndicator()
                    : SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          child: Text("Giriş Yap"),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
