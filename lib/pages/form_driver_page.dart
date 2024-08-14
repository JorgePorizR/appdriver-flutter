import 'dart:convert';

import 'package:appdriver/constants/constants.dart';
import 'package:appdriver/models/driver_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FormDriverPage extends StatefulWidget {
  const FormDriverPage({super.key});

  @override
  State<FormDriverPage> createState() => _FormDriverPageState();
}

class _FormDriverPageState extends State<FormDriverPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _vehicleBrandController = TextEditingController();
  final _vehicleModelController = TextEditingController();
  final _vehicleColorController = TextEditingController();
  final _vehiclePlateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 64.0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'Driver',
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'Gilroy-Bold',
            color: Color(0xfff2264b),
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: getForm(context),
      ),
    );
  }

  getForm(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(25.0, 20.0, 25.0, 0.0),
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          const Text(
            "Formulario de Driver",
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              fontFamily: 'Gilroy-Bold',
              color: Color(0xfff2264b),
            ),
          ),
          const SizedBox(height: 20.0),
          Form(
              key: _formKey,
              child: Column(
                children: [
                  SizedBox(
                    child: TextFormField(
                      controller: _fullNameController,
                      keyboardType: TextInputType.text,
                      cursorColor: const Color.fromARGB(255, 20, 126, 255),
                      cursorErrorColor: Colors.red,
                      decoration: InputDecoration(
                        hintText: 'Ingrese su nombre completo',
                        labelText: 'Nombre Completo',
                        //prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide: const BorderSide(
                              color: Color.fromARGB(255, 20, 126, 255)),
                        ),
                        labelStyle: const TextStyle(
                          color: Colors.black,
                          fontFamily: 'Gilroy-Medium',
                        ),
                        hintStyle: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12.0,
                        ),
                      ),
                      style: const TextStyle(
                        height: 1.0,
                        color: Colors.black,
                        fontFamily: 'Gilroy-Medium',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese un nombre';
                        }
                        if (value.length < 5) {
                          return 'El nombre no puede tener menos de 5 caracteres';
                        }
                        if (value.length > 50) {
                          return 'El nombre no puede tener mas de 50 caracteres';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 15.0),
                  SizedBox(
                    child: TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      cursorColor: const Color.fromARGB(255, 20, 126, 255),
                      cursorErrorColor: Colors.red,
                      decoration: InputDecoration(
                        hintText: 'Ingrese su correo electrónico',
                        labelText: 'Correo Electrónico',
                        //prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide: const BorderSide(
                              color: Color.fromARGB(255, 20, 126, 255)),
                        ),
                        labelStyle: const TextStyle(
                          color: Colors.black,
                          fontFamily: 'Gilroy-Medium',
                        ),
                        hintStyle: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12.0,
                        ),
                      ),
                      style: const TextStyle(
                        height: 1.0,
                        color: Colors.black,
                        fontFamily: 'Gilroy-Medium',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese un correo electrónico';
                        }
                        if (!value.contains('@')) {
                          return 'El correo electrónico no es válido';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 15.0),
                  SizedBox(
                    child: TextFormField(
                      controller: _passwordController,
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: true,
                      enableSuggestions: false,
                      autocorrect: false,
                      cursorColor: const Color.fromARGB(255, 20, 126, 255),
                      cursorErrorColor: Colors.red,
                      decoration: InputDecoration(
                        hintText: 'Ingrese su contraseña',
                        labelText: 'Contraseña',
                        //prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide: const BorderSide(
                              color: Color.fromARGB(255, 20, 126, 255)),
                        ),
                        labelStyle: const TextStyle(
                          color: Colors.black,
                          fontFamily: 'Gilroy-Medium',
                        ),
                        hintStyle: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12.0,
                        ),
                      ),
                      style: const TextStyle(
                        height: 1.0,
                        color: Colors.black,
                        fontFamily: 'Gilroy-Medium',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese una contraseña';
                        }
                        if (value.length < 8) {
                          return 'La contraseña no puede tener menos de 8 caracteres';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 15.0),
                  SizedBox(
                    child: TextFormField(
                      controller: _vehicleBrandController,
                      keyboardType: TextInputType.text,
                      cursorColor: const Color.fromARGB(255, 20, 126, 255),
                      cursorErrorColor: Colors.red,
                      decoration: InputDecoration(
                        hintText: 'Ingrese la marca de su vehículo',
                        labelText: 'Marca del Vehículo',
                        //prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide: const BorderSide(
                              color: Color.fromARGB(255, 20, 126, 255)),
                        ),
                        labelStyle: const TextStyle(
                          color: Colors.black,
                          fontFamily: 'Gilroy-Medium',
                        ),
                        hintStyle: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12.0,
                        ),
                      ),
                      style: const TextStyle(
                        height: 1.0,
                        color: Colors.black,
                        fontFamily: 'Gilroy-Medium',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese la marca de su vehículo';
                        }
                        if (value.length < 3) {
                          return 'La marca del vehículo no puede tener menos de 3 caracteres';
                        }
                        if (value.length > 50) {
                          return 'La marca del vehículo no puede tener mas de 50 caracteres';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 15.0),
                  SizedBox(
                    child: TextFormField(
                      controller: _vehicleModelController,
                      keyboardType: TextInputType.text,
                      cursorColor: const Color.fromARGB(255, 20, 126, 255),
                      cursorErrorColor: Colors.red,
                      decoration: InputDecoration(
                        hintText: 'Ingrese el modelo de su vehículo',
                        labelText: 'Modelo del Vehículo',
                        //prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide: const BorderSide(
                              color: Color.fromARGB(255, 20, 126, 255)),
                        ),
                        labelStyle: const TextStyle(
                          color: Colors.black,
                          fontFamily: 'Gilroy-Medium',
                        ),
                        hintStyle: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12.0,
                        ),
                      ),
                      style: const TextStyle(
                        height: 1.0,
                        color: Colors.black,
                        fontFamily: 'Gilroy-Medium',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese el modelo de su vehículo';
                        }
                        if (value.length < 3) {
                          return 'El modelo del vehículo no puede tener menos de 3 caracteres';
                        }
                        if (value.length > 50) {
                          return 'El modelo del vehículo no puede tener mas de 50 caracteres';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 15.0),
                  SizedBox(
                    child: TextFormField(
                      controller: _vehicleColorController,
                      keyboardType: TextInputType.text,
                      cursorColor: const Color.fromARGB(255, 20, 126, 255),
                      cursorErrorColor: Colors.red,
                      decoration: InputDecoration(
                        hintText: 'Ingrese el color de su vehículo',
                        labelText: 'Color del Vehículo',
                        //prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide: const BorderSide(
                              color: Color.fromARGB(255, 20, 126, 255)),
                        ),
                        labelStyle: const TextStyle(
                          color: Colors.black,
                          fontFamily: 'Gilroy-Medium',
                        ),
                        hintStyle: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12.0,
                        ),
                      ),
                      style: const TextStyle(
                        height: 1.0,
                        color: Colors.black,
                        fontFamily: 'Gilroy-Medium',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese el color de su vehículo';
                        }
                        if (value.length < 3) {
                          return 'El color del vehículo no puede tener menos de 3 caracteres';
                        }
                        if (value.length > 50) {
                          return 'El color del vehículo no puede tener mas de 50 caracteres';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 15.0),
                  SizedBox(
                    child: TextFormField(
                      controller: _vehiclePlateController,
                      keyboardType: TextInputType.text,
                      cursorColor: const Color.fromARGB(255, 20, 126, 255),
                      cursorErrorColor: Colors.red,
                      decoration: InputDecoration(
                        hintText: 'Ingrese la placa de su vehículo',
                        labelText: 'Placa del Vehículo',
                        //prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide: const BorderSide(
                              color: Color.fromARGB(255, 20, 126, 255)),
                        ),
                        labelStyle: const TextStyle(
                          color: Colors.black,
                          fontFamily: 'Gilroy-Medium',
                        ),
                        hintStyle: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12.0,
                        ),
                      ),
                      style: const TextStyle(
                        height: 1.0,
                        color: Colors.black,
                        fontFamily: 'Gilroy-Medium',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese la placa de su vehículo';
                        }
                        if (value.length < 6) {
                          return 'La placa del vehículo no puede tener menos de 6 caracteres';
                        }
                        if (value.length > 10) {
                          return 'La placa del vehículo no puede tener mas de 10 caracteres';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 15.0),
                  getButton(),
                  const SizedBox(height: 25.0),
                ],
              ))
        ],
      ),
    );
  }

  getButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xfff2264b),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        minimumSize: const Size(double.infinity, 56.0),
      ),
      onPressed: () async {
        if (!_formKey.currentState!.validate()) {
          return;
        }
        Driver driver = Driver(
          fullname: _fullNameController.text,
          email: _emailController.text,
          password: _passwordController.text,
          vehicleBrand: _vehicleBrandController.text,
          vehicleModel: _vehicleModelController.text,
          vehicleColor: _vehicleColorController.text,
          vehiclePlate: _vehiclePlateController.text,
        );
        //print("Driver: $driver");
        await fetchRegisterDriver(driver).then((response) {
          if (response.statusCode == 201) {
            print("Response: ${response.body}");
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/login',
              (route) => false,
            );
          } else {
            print("Error: ${response.body}");
          }
        });
      },
      child: const Text(
        "Guardar",
        style: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
          fontFamily: 'Gilroy-Bold',
          color: Colors.white,
        ),
      ),
    );
  }

  Future<http.Response> fetchRegisterDriver(Driver driver) {
    final headers = {'Content-Type': 'application/json'};
    return http.post(
        Uri.parse('${Constants.socketUrl}/api/auth/registerdriver'),
        body: jsonEncode(driver.toJson()),
        headers: headers);
  }
}
