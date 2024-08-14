import 'dart:convert';

import 'package:appdriver/constants/constants.dart';
import 'package:appdriver/models/login_model.dart';
import 'package:appdriver/storage/history_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late DataStorage? dataStorage;
  @override
  void initState() {
    initSharedPreferences();
    super.initState();
    DataStorage.loadToken('token').then((value) {
      print('Token Login: $value');
      if (value.isNotEmpty) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/',
          (route) => false,
        );
      }
    });
  }

  Future<void> initSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      dataStorage = DataStorage(prefs);
    });
  }

  @override
  void didChangeDependencies(){
    super.didChangeDependencies();
    initSharedPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 64.0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'CARPOOLING',
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'Gilroy-Bold',
            color: Color(0xfff2264b),
          ),
        ),
        centerTitle: true,
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
            "Login Driver",
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
                        if (value.length < 3) {
                          return 'La contraseña no puede tener menos de 3 caracteres';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 15.0),
                  getButton(),
                  const SizedBox(height: 15.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '¿No tienes cuenta? ',
                        style: TextStyle(
                          fontFamily: 'Gilroy-Medium',
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/formdriver');
                        },
                        child: const Text(
                          'Crear cuenta',
                          style: TextStyle(
                            color: Color(0xfff2264b),
                            fontFamily: 'Gilroy-Medium',
                          ),
                        ),
                      ),
                    ],
                  ),
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
        Login driver = Login(
          email: _emailController.text,
          password: _passwordController.text,
        );
        //print("Driver: ${driver.email}, ${driver.password}");
        await fetchLoginDriver(driver).then((response) {
          if (response.statusCode == 200) {
            //print("Response: ${response.body}");
            Map<String, dynamic> jsonResponse = jsonDecode(response.body);
            String accessToken = jsonResponse['access_token'];
            //print("Access Token: $accessToken");
            DataStorage.saveToken('token', accessToken);
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/',
              (route) => false,
            );
          } else {
            print("Error: ${response.body}");
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(const JsonDecoder().convert(response.body)['message']),
                ));
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

  Future<http.Response> fetchLoginDriver(Login driver) {
    //final body = jsonEncode({'email': driver.email, 'password': driver.password});
    final headers = {'Content-Type': 'application/json'};
    //print("Body: $body");
    //print("otro Body: ${jsonEncode(driver.toJson())}");
    return http.post(Uri.parse('${Constants.socketUrl}/api/auth/logindriver'), body: jsonEncode(driver.toJson()), headers: headers);
  }
}
