import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_truck_elektronik/model/task.dart'; // Your Task model

class CreateTaskPage extends StatefulWidget {
  final Function(Task) onTaskCreated;

  CreateTaskPage({required this.onTaskCreated});

  @override
  _CreateTaskPageState createState() => _CreateTaskPageState();
}

class _CreateTaskPageState extends State<CreateTaskPage> {
  final _formKey = GlobalKey<FormState>();
  String? _name;
  String? _telNumber;
  String? _product;
  double? _cost;
  int? _qty;
  String? _reason;
  File? _image;

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Fotoğraf Çek'),
                onTap: () async {
                  final ImagePicker _picker = ImagePicker();
                  final XFile? image = await _picker.pickImage(source: ImageSource.camera);

                  if (image != null) {
                    setState(() {
                      _image = File(image.path);
                    });
                  }
                  Navigator.of(context).pop(); // Close the bottom sheet
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Galeriden Seç'),
                onTap: () async {
                  final ImagePicker _picker = ImagePicker();
                  final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

                  if (image != null) {
                    setState(() {
                      _image = File(image.path);
                    });
                  }
                  Navigator.of(context).pop(); // Close the bottom sheet
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      Task newTask = Task(
        id: 0, // You can assign this later or handle it automatically.
        name: _name!,
        telNumber: _telNumber!,
        product: _product!,
        cost: _cost!,
        qty: _qty!,
        reason: _reason!,
        image: _image != null ? _image!.path : '', // Wrapping in a list
      );

      widget.onTaskCreated(newTask);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Müşteri Adı'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen müşteri adını giriniz';
                  }
                  return null;
                },
                onSaved: (value) {
                  _name = value;
                },
              ),
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Müşteri Telefon Numarası'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen müşteri telefon numarası giriniz';
                  }
                  return null;
                },
                onSaved: (value) {
                  _telNumber = value;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Ürün Adı'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen ürün bilgisi giriniz';
                  }
                  return null;
                },
                onSaved: (value) {
                  _product = value;
                },
              ),
              
              TextFormField(
                decoration: InputDecoration(labelText: 'Adet'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || int.tryParse(value) == null) {
                    return 'Lütfen adet giriniz';
                  }
                  return null;
                },
                onSaved: (value) {
                  _qty = int.tryParse(value!);
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Adet Ücret Bedeli'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || double.tryParse(value) == null) {
                    return 'Lütfen ücret bedeli giriniz';
                  }
                  return null;
                },
                onSaved: (value) {
                  _cost = double.tryParse(value!);
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Şikayet sebebi'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen Şikayet sebebi giriniz';
                  }
                  return null;
                },
                onSaved: (value) {
                  _reason = value;
                },
              ),
              SizedBox(height: 20),
              Text('Fotoğraf Ekle'),
              SizedBox(height: 10),
              _image == null
                  ? Text('Herhangi bir fotoğraf seçilmedi.' , style: TextStyle(color: Colors.red),)
                  : Image.file(_image!, height: 150),
              TextButton(
                onPressed: _pickImage,
                child: Text('Fotoğraf Ekle'),
              ),
              SizedBox(height: 20,),
              Divider(),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Görevi Oluştur'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
