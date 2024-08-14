import 'dart:convert';

import 'package:appdriver/constants/constants.dart';
import 'package:appdriver/models/viaje_model.dart';
import 'package:appdriver/storage/history_storage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late DataStorage? dataStorage;
  String token = '';

  @override
  void initState() {
    super.initState();
    initSharedPreferences();
    DataStorage.loadToken('token').then((value) {
      setState(() {
        token = value;
        if (token.isNotEmpty) {
          fetchInfoMe(token).then((response) {
            if (response.statusCode == 200) {
              final jsonResponse = jsonDecode(response.body);
              String choferId = jsonResponse['id'].toString();
              print('User: $choferId');
              DataStorage.saveChoferId('choferId', choferId);
            } else {
              print('Error al obtener la información del usuario');
            }
          });
        }
      });
    });
  }

  Future<void> initSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      dataStorage = DataStorage(prefs);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.logout),
          tooltip: 'Cerrar sesión',
          onPressed: () {
            DataStorage.deleteToken('token').then((value) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            });
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(left: 15.0, top: 30.0),
              alignment: Alignment.centerLeft,
              child: const Text(
                'VIAJES',
                style: TextStyle(
                    fontSize: 18,
                    color: Color(0xfff2264b),
                    fontFamily: 'Gilroy-Bold'),
              ),
            ),
            getListViajes(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xfff2264b),
        onPressed: () {
          Navigator.pushNamed(context, '/mapa');
        },
        tooltip: 'Crear viaje',
        mini: true,
        child: const Icon(
          Icons.add_location_alt_outlined,
          color: Color.fromARGB(255, 255, 185, 185),
        ),
      ),
    );
  }

  Widget getListViajes() {
    return FutureBuilder<http.Response>(
      future: fetchListViajes(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final List<Viaje> viajes = viajeFromJson(snapshot.data!.body);
          return Expanded(
            child: ListView.builder(
              itemCount: viajes.length,
              itemBuilder: (context, index) {
                const status = ['Pendiente', 'En curso', 'Finalizado'];
                return Card(
                  margin: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  child: ListTile(
                    title: Text(viajes[index].name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Estado: ${status[viajes[index].status]}'),
                        Text(
                            'Salida: ${viajes[index].date.day}/${viajes[index].date.month}/${viajes[index].date.year}'),
                        Text('Hora: ${viajes[index].startTime}'),
                      ],
                    ),
                    trailing: viajes[index].status == 0
                        ? ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xfff2264b),
                            ),
                            onPressed: () {
                              // question if the user wants to start the trip
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('Iniciar viaje'),
                                    content: const Text(
                                        '¿Estás seguro de que deseas iniciar el viaje?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text(
                                          'Cancelar',
                                          style: TextStyle(
                                            color:
                                                Color.fromARGB(255, 255, 0, 43),
                                            fontFamily: 'Gilroy-Bold',
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          // Navigator.of(context).pop();
                                          // socket.emit('startTrip', viajes[index].id);
                                          fetchStartViaje(viajes[index].id).then((value) {
                                            if (value.statusCode == 200) {
                                              Navigator.pushNamed(
                                                context,
                                                '/viajedetail',
                                                arguments: viajes[index].id,
                                              );
                                            } else {
                                              print('Error al iniciar el viaje');
                                            }
                                          });
                                        },
                                        child: const Text(
                                          'Aceptar',
                                          style: TextStyle(
                                            color:
                                                Color.fromARGB(255, 255, 0, 43),
                                            fontFamily: 'Gilroy-Bold',
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: const Text(
                              'Iniciar',
                              style: TextStyle(
                                color: Color.fromARGB(255, 255, 224, 229),
                              ),
                            ),
                          )
                        : const SizedBox(),
                  ),
                );
              },
            ),
          );
        } else if (snapshot.hasError) {
          return const Text('Error al cargar los viajes');
        } else if (!snapshot.hasData) {
          return const Text('No hay viajes disponibles');
        }
        return const CircularProgressIndicator();
      },
    );
  }

  Future<http.Response> fetchInfoMe(tokenTxt) async {
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $tokenTxt'
    };
    return http.get(Uri.parse('${Constants.socketUrl}/api/auth/me'),
        headers: headers);
  }

  Future<http.Response> fetchListViajes() async {
    if (token.isEmpty) {
      print('Token is not available yet');
      return Future.error('Token is not available yet');
    }
    print('Token: $token');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    return http.get(Uri.parse('${Constants.socketUrl}/api/trips'),
        headers: headers);
  }

  Future<http.Response> fetchStartViaje(viajeId) async {
    if (token.isEmpty) {
      print('Token is not available yet');
      return Future.error('Token is not available yet');
    }
    print('Token: $token');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    return http.post(
        Uri.parse('${Constants.socketUrl}/api/trips/$viajeId/start'),
        headers: headers);
  }
}
