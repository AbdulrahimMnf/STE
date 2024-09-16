// screens/create_sale_page.dart

import 'package:flutter/material.dart';

class CreateSalePage extends StatefulWidget {
  final Function(String, String, String, int, double) onSaleCreated;

  CreateSalePage({required this.onSaleCreated});

  @override
  _CreateSalePageState createState() => _CreateSalePageState();
}

class _CreateSalePageState extends State<CreateSalePage> {
  final _formKey = GlobalKey<FormState>();
  String customerName = '';
  String productName = '';
  String phone = '';
  int qty = 0;
  double amount = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Satış Oluşturma Sayfası'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Muşteri Adı'),
                onSaved: (value) => customerName = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Ürün Adı'),
                onSaved: (value) => productName = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Telefon Numarası'),
                onSaved: (value) => phone = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Adet'),
                keyboardType: TextInputType.number,
                onSaved: (value) => qty = int.parse(value!),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Adet Fiyat'),
                keyboardType: TextInputType.number,
                onSaved: (value) => amount = double.parse(value!),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    widget.onSaleCreated(customerName, productName, phone, qty, amount);
                    Navigator.of(context).pop();
                  }
                },
                child: Text('Satışı Oluştur'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
