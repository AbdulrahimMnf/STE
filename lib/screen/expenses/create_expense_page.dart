
import 'package:flutter/material.dart';

class CreateExpensePage extends StatefulWidget {
  final Function(String, double) onExpenseCreated;

  CreateExpensePage({required this.onExpenseCreated});

  @override
  _CreateExpensePageState createState() => _CreateExpensePageState();
}

class _CreateExpensePageState extends State<CreateExpensePage> {
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _submitExpense() {
    if (_formKey.currentState!.validate()) {
      final enteredDescription = _descriptionController.text;
      final enteredAmount = double.parse(_amountController.text);

      widget.onExpenseCreated(enteredDescription, enteredAmount);
      Navigator.of(context).pop(); // Close the page after saving
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ödeme Oluşturma Sayfası'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Açıklama'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen bir açıklama giriniz';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Tutar'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen bir tutar giriniz !';
                  }
                  if (double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'Lütfen geçerli bir tutar giriniz !';
                  }
                  return null;
                },
              ),
            const  SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitExpense,
                child: const Text('Ödeme Kaydet'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
