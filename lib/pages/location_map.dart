import 'dart:async';
import 'dart:convert';

import 'package:appdriver/models/create_viaje_model.dart';
import 'package:appdriver/storage/history_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:appdriver/constants/constants.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class LocationMap extends StatefulWidget {
  const LocationMap({super.key});

  @override
  State<LocationMap> createState() => _LocationMapState();
}

class _LocationMapState extends State<LocationMap> {
  late DataStorage? dataStorage;
  String token = '';

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  LatLng? _center;
  Position? _currentPosition;

  final _originLocationController = TextEditingController();
  bool _originLocationSelected = false;
  Marker? _originMarker;
  final _destinationLocationController = TextEditingController();
  bool _destinationLocationSelected = false;
  Marker? _destinationMarker;

  Map<PolylineId, Polyline> polylines = {};
  bool _isRouteSelected = false;

  final _nombreController = TextEditingController();
  final _asientosController = TextEditingController();
  final _precioController = TextEditingController();
  final _fechaSalidaController = TextEditingController();
  final _horaSalidaController = TextEditingController();
  bool _isInputsValidated = false;

  final _paradasController = TextEditingController();
  final _horaParadaController = TextEditingController();
  bool _isParadaSelected = false;
  Map<MarkerId, Marker> paradasMarkers = <MarkerId, Marker>{};
  List<Stop> paradas = [];


  @override
  void initState() {
    super.initState();
    _getUserLocation();
    initSharedPreferences();
    loadToken();
  }

  Future<void> initSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      dataStorage = DataStorage(prefs);
    });
  }

  Future<void> loadToken() async {
    final loadedToken = await DataStorage.loadToken('token');
    setState(() {
      token = loadedToken;
    });
  }

  _getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;
    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }
    // Request permission to get the user's location
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      return;
    }
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return;
      }
    }
    // Get the current location of the user
    _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    print(
        'Ubicación actual: ${_currentPosition!.latitude}, ${_currentPosition!.longitude}');
    setState(() {
      _center = LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //automaticallyImplyLeading: false,
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
      ),
      body: _center == null
          ? const Center(
              child: CircularProgressIndicator(
              backgroundColor: Color.fromARGB(255, 255, 223, 220),
              color: Color(0xfff2264b),
            ))
          : Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      getMap(),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 30.0),
                        child: Center(
                          child: Icon(
                            Icons.location_on,
                            size: 40.0,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                getIputsLocation(),
              ],
            ),
    );
  }

  getMap() {
    return GoogleMap(
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
      },
      mapType: MapType.normal,
      initialCameraPosition: CameraPosition(
        target: _center!,
        zoom: 15.0,
      ),
      markers: {
        if (_originMarker != null) _originMarker!,
        if (_destinationMarker != null) _destinationMarker!,
        if (paradasMarkers.isNotEmpty) ...paradasMarkers.values,
      },
      polylines: Set<Polyline>.of(polylines.values),
    );
  }

  getIputsLocation() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _isRouteSelected == false
            ? Container(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _originLocationController,
                        keyboardType: TextInputType.text,
                        cursorColor: const Color.fromARGB(255, 20, 126, 255),
                        cursorErrorColor: Colors.red,
                        enabled: false,
                        decoration: InputDecoration(
                          hintText: '',
                          labelText: 'Origen Location',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            borderSide: const BorderSide(
                                color: Color.fromARGB(255, 10, 10, 10)),
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
                            fontSize: 12.0),
                        validator: (value) {
                          return null;
                        },
                      ),
                    ),
                    Container(
                      width: 50.0,
                      height: 50.0,
                      margin: const EdgeInsets.only(left: 20.0),
                      child: IconButton(
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all<Color>(
                              const Color.fromARGB(255, 20, 126, 255)),
                        ),
                        tooltip: 'Selecionar Origen',
                        icon: const Icon(
                          Icons.add_location_alt,
                          color: Color.fromARGB(255, 197, 223, 255),
                        ),
                        onPressed: () async {
                          final GoogleMapController controller =
                              await _controller.future;
                          LatLngBounds bounds =
                              await controller.getVisibleRegion();
                          LatLng center = LatLng(
                            (bounds.northeast.latitude +
                                    bounds.southwest.latitude) /
                                2,
                            (bounds.northeast.longitude +
                                    bounds.southwest.longitude) /
                                2,
                          );
                          String address = await getAddressFromCoordinates(
                              center.latitude, center.longitude);
                          _originLocationController.text = address;
                          //print('Ubicación central del mapa: ${center.latitude}, ${center.longitude}');
                          setState(() {
                            _originLocationSelected = true;
                            _originMarker = Marker(
                              markerId: const MarkerId('origin_location'),
                              position: center,
                              infoWindow: const InfoWindow(
                                  title: 'Origen Location',
                                  snippet: 'Ubicación de partida'),
                            );
                          });
                          if (_originLocationSelected) {
                            getPolylinePoints().then((value) {
                              generatePolyLineFromPoints(value);
                            });
                          }
                          //print('Ubicación central del mapa: ${center.latitude}, ${center.longitude}');
                        },
                      ),
                    ),
                  ],
                ),
              )
            : Container(),
        _originLocationSelected == true && _isRouteSelected == false
            ? Container(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _destinationLocationController,
                        keyboardType: TextInputType.text,
                        cursorColor: const Color.fromARGB(255, 20, 126, 255),
                        cursorErrorColor: Colors.red,
                        enabled: false,
                        decoration: InputDecoration(
                          hintText: '',
                          labelText: 'Destination Location',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            borderSide: const BorderSide(
                                color: Color.fromARGB(255, 10, 10, 10)),
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
                            fontSize: 12.0),
                        validator: (value) {
                          return null;
                        },
                      ),
                    ),
                    Container(
                      width: 50.0,
                      height: 50.0,
                      margin: const EdgeInsets.only(left: 20.0),
                      child: IconButton(
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all<Color>(
                              const Color.fromARGB(255, 20, 126, 255)),
                        ),
                        tooltip: 'Selecionar Destino',
                        icon: const Icon(
                          Icons.add_location_alt,
                          color: Color.fromARGB(255, 197, 223, 255),
                        ),
                        onPressed: () async {
                          final GoogleMapController controller =
                              await _controller.future;
                          LatLngBounds bounds =
                              await controller.getVisibleRegion();
                          LatLng center = LatLng(
                            (bounds.northeast.latitude +
                                    bounds.southwest.latitude) /
                                2,
                            (bounds.northeast.longitude +
                                    bounds.southwest.longitude) /
                                2,
                          );
                          String address = await getAddressFromCoordinates(
                              center.latitude, center.longitude);
                          _destinationLocationController.text = address;
                          setState(() {
                            _destinationLocationSelected = true;
                            _destinationMarker = Marker(
                              markerId: const MarkerId('destination_location'),
                              position: center,
                              infoWindow: const InfoWindow(
                                  title: 'Destination Location',
                                  snippet: 'Ubicación de destino'),
                            );
                          });
                          getPolylinePoints().then((value) {
                            generatePolyLineFromPoints(value);
                          });
                          //print('Ubicación central del mapa: ${center.latitude}, ${center.longitude}');
                        },
                      ),
                    ),
                  ],
                ),
              )
            : Container(),
        _destinationLocationSelected == true && _isRouteSelected == false
            ? Container(
                padding: const EdgeInsets.all(10.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xfff2264b),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    minimumSize: const Size(double.infinity, 56.0),
                  ),
                  onPressed: () {
                    //print('Origen: ${_originLocationController.text}');
                    //print('Destino: ${_destinationLocationController.text}');
                    print('Origen: ${_originMarker!.position}');
                    print('Destino: ${_destinationMarker!.position}');
                    setState(() {
                      _isRouteSelected = true;
                    });
                    //Navigator.pushNamed(context, '/');
                  },
                  child: const Text(
                    'Siguiente',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Gilroy-Medium',
                      fontSize: 16.0,
                    ),
                  ),
                ),
              )
            : Container(),
        _isRouteSelected == true && _isInputsValidated == false
            ? getInputsIfRouteSelected()
            : Container(),
        _isInputsValidated == true ? getInputsParadas() : Container(),
      ],
    );
  }

  getInputsIfRouteSelected() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(5.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: TextFormField(
                  controller: _nombreController,
                  keyboardType: TextInputType.text,
                  cursorColor: const Color.fromARGB(255, 20, 126, 255),
                  cursorErrorColor: Colors.red,
                  decoration: InputDecoration(
                    hintText: 'Nombre del Viaje',
                    labelText: 'Nombre',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      borderSide: const BorderSide(
                          color: Color.fromARGB(255, 10, 10, 10)),
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
                      fontSize: 12.0),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(5.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: TextFormField(
                  controller: _asientosController,
                  keyboardType: TextInputType.number,
                  cursorColor: const Color.fromARGB(255, 20, 126, 255),
                  cursorErrorColor: Colors.red,
                  decoration: InputDecoration(
                    hintText: 'Número de asientos',
                    labelText: 'Asientos',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      borderSide: const BorderSide(
                          color: Color.fromARGB(255, 10, 10, 10)),
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
                      fontSize: 12.0),
                  onChanged: (value) => {
                    if (int.tryParse(value) == null)
                      {_asientosController.clear()}
                  },
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(5.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: TextFormField(
                  controller: _precioController,
                  keyboardType: TextInputType.number,
                  cursorColor: const Color.fromARGB(255, 20, 126, 255),
                  cursorErrorColor: Colors.red,
                  decoration: InputDecoration(
                    hintText: 'Precio por asiento',
                    labelText: 'Precio',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      borderSide: const BorderSide(
                          color: Color.fromARGB(255, 10, 10, 10)),
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
                      fontSize: 12.0),
                  onChanged: (value) => {
                    if (double.tryParse(value) == null)
                      {_precioController.clear()}
                  },
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(5.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: TextFormField(
                  controller: _fechaSalidaController,
                  keyboardType: TextInputType.datetime,
                  cursorColor: const Color.fromARGB(255, 20, 126, 255),
                  cursorErrorColor: Colors.red,
                  decoration: InputDecoration(
                    hintText: 'Fecha de salida',
                    labelText: 'Fecha',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      borderSide: const BorderSide(
                          color: Color.fromARGB(255, 10, 10, 10)),
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
                    fontSize: 12.0,
                  ),
                  readOnly: true,
                  onTap: () async {
                    // Abre el selector de fecha
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );

                    if (pickedDate != null) {
                      // Formatea la fecha seleccionada
                      String formattedDate =
                          DateFormat('yyyy-MM-dd').format(pickedDate);
                      setState(() {
                        // Actualiza el controlador del TextFormField
                        _fechaSalidaController.text = formattedDate;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(5.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: TextFormField(
                  controller: _horaSalidaController,
                  keyboardType: TextInputType.datetime,
                  cursorColor: const Color.fromARGB(255, 20, 126, 255),
                  cursorErrorColor: Colors.red,
                  decoration: InputDecoration(
                    hintText: 'Hora de salida',
                    labelText: 'Hora',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      borderSide: const BorderSide(
                          color: Color.fromARGB(255, 10, 10, 10)),
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
                    fontSize: 12.0,
                  ),
                  readOnly: true,
                  onTap: () async {
                    // Abre el selector de hora
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );

                    if (pickedTime != null) {
                      // Formatea la hora seleccionada
                      final now = DateTime.now();
                      final formattedTime = DateFormat('HH:mm').format(
                        DateTime(now.year, now.month, now.day, pickedTime.hour,
                            pickedTime.minute),
                      );
                      setState(() {
                        // Actualiza el controlador del TextFormField
                        _horaSalidaController.text = formattedTime;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(5.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xfff2264b),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              minimumSize: const Size(double.infinity, 56.0),
            ),
            onPressed: () {
              setState(() {
                _isRouteSelected = false;
                _nombreController.clear();
                _asientosController.clear();
                _precioController.clear();
                _fechaSalidaController.clear();
                _horaSalidaController.clear();
              });
            },
            child: const Text(
              'Volver',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Gilroy-Medium',
                fontSize: 16.0,
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(5.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xfff2264b),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              minimumSize: const Size(double.infinity, 56.0),
            ),
            onPressed: () {
              // print('Asientos: ${_asientosController.text}');
              // print('Precio: ${_precioController.text}');
              // print('Fecha de salida: ${_fechaSalidaController.text}');
              // print('Hora de salida: ${_horaSalidaController.text}');

              if (_nombreController.text.isEmpty ||
                  _asientosController.text.isEmpty ||
                  _precioController.text.isEmpty ||
                  _fechaSalidaController.text.isEmpty ||
                  _horaSalidaController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Todos los campos son obligatorios"),
                ));
                return;
              }
              setState(() {
                _isInputsValidated = true;
              });

              //Navigator.pushNamed(context, '/');
            },
            child: const Text(
              'Siguiente',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Gilroy-Medium',
                fontSize: 16.0,
              ),
            ),
          ),
        )
      ],
    );
  }

  getInputsParadas() {
    return Column(
      children: [
        _isParadaSelected == false
            ? Container(
                padding: const EdgeInsets.all(5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _horaParadaController,
                        keyboardType: TextInputType.datetime,
                        cursorColor: const Color.fromARGB(255, 20, 126, 255),
                        cursorErrorColor: Colors.red,
                        decoration: InputDecoration(
                          hintText: '',
                          labelText: 'Hora de la parada',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            borderSide: const BorderSide(
                                color: Color.fromARGB(255, 10, 10, 10)),
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
                          fontSize: 12.0,
                        ),
                        readOnly: true,
                        onTap: () async {
                          // Abre el selector de hora
                          TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );

                          if (pickedTime != null) {
                            // Formatea la hora seleccionada
                            final now = DateTime.now();
                            final formattedTime = DateFormat('HH:mm').format(
                              DateTime(now.year, now.month, now.day,
                                  pickedTime.hour, pickedTime.minute),
                            );
                            setState(() {
                              // Actualiza el controlador del TextFormField
                              _horaParadaController.text = formattedTime;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              )
            : Container(),
        _isParadaSelected == false
            ? Container(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _paradasController,
                        keyboardType: TextInputType.text,
                        cursorColor: const Color.fromARGB(255, 20, 126, 255),
                        cursorErrorColor: Colors.red,
                        enabled: false,
                        decoration: InputDecoration(
                          hintText: '',
                          labelText: 'Parada',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            borderSide: const BorderSide(
                                color: Color.fromARGB(255, 10, 10, 10)),
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
                            fontSize: 12.0),
                      ),
                    ),
                    Container(
                      width: 50.0,
                      height: 50.0,
                      margin: const EdgeInsets.only(left: 20.0),
                      child: IconButton(
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all<Color>(
                              const Color.fromARGB(255, 20, 126, 255)),
                        ),
                        tooltip: 'Seleccionar Parada',
                        icon: const Icon(
                          Icons.add_location_alt,
                          color: Color.fromARGB(255, 197, 223, 255),
                        ),
                        onPressed: () async {
                          final GoogleMapController controller =
                              await _controller.future;
                          LatLngBounds bounds =
                              await controller.getVisibleRegion();
                          LatLng center = LatLng(
                            (bounds.northeast.latitude +
                                    bounds.southwest.latitude) /
                                2,
                            (bounds.northeast.longitude +
                                    bounds.southwest.longitude) /
                                2,
                          );
                          String address = await getAddressFromCoordinates(
                              center.latitude, center.longitude);
                          _paradasController.text =
                              "Parada-${paradasMarkers.length + 1}: $address\n";
                          setState(() {
                            var marker = Marker(
                              markerId: MarkerId(
                                  'Parada-${paradasMarkers.length + 1}'),
                              position: center,
                              infoWindow: InfoWindow(
                                  title: 'Parada-${paradasMarkers.length + 1}',
                                  snippet:
                                      'Parada-${paradasMarkers.length + 1}'),
                            );
                            if (_horaParadaController.text.isEmpty) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text("Escoga un hora para la parada"),
                              ));
                              return;
                            }
                            paradasMarkers[marker.markerId] = marker;
                            paradas.add(Stop(
                                lat: center.latitude.toString(),
                                lng: center.longitude.toString(),
                                time: _horaParadaController.text));
                            _isParadaSelected = true;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              )
            : Container(),
        _isParadaSelected == true
            ? Container(
                padding: const EdgeInsets.all(5.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xfff2264b),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    minimumSize: const Size(double.infinity, 56.0),
                  ),
                  onPressed: () {
                    setState(() {
                      _isParadaSelected = false;
                      _paradasController.clear();
                      _horaParadaController.clear();
                    });
                  },
                  child: const Text(
                    'Agregar nueva parada',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Gilroy-Medium',
                      fontSize: 16.0,
                    ),
                  ),
                ),
              )
            : Container(),
        Container(
          padding: const EdgeInsets.all(5.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xfff2264b),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              minimumSize: const Size(double.infinity, 56.0),
            ),
            onPressed: () {
              setState(() {
                _isInputsValidated = false;
                _paradasController.clear();
                paradasMarkers = <MarkerId, Marker>{};
              });
            },
            child: const Text(
              'Volver',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Gilroy-Medium',
                fontSize: 16.0,
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(5.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xfff2264b),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              minimumSize: const Size(double.infinity, 56.0),
            ),
            onPressed: () async {
              if (paradasMarkers.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Debe seleccionar al menos 1 parada"),
                ));
                return;
              }
              if (_paradasController.text.isEmpty ||
                  _horaParadaController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Todos los campos son obligatorios"),
                ));
                return;
              }
              CreateViaje viaje = CreateViaje(
                name: _nombreController.text,
                latOrigin: _originMarker!.position.latitude.toString(),
                lngOrigin: _originMarker!.position.longitude.toString(),
                latDestination:
                    _destinationMarker!.position.latitude.toString(),
                lngDestination:
                    _destinationMarker!.position.longitude.toString(),
                date: _fechaSalidaController.text.toString(),
                price: _precioController.text,
                seats: int.parse(_asientosController.text),
                stops: paradas,
                startTime: _horaSalidaController.text,
              );
              //print('Viaje: ${jsonEncode(viaje.toJson())}');
              await fetchAddViaje(viaje).then((response) {
                if (response.statusCode == 201) {
                  print("Response: ${response.body}");
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/',
                    (route) => false,
                  );
                } else {
                  print("Error al crear viaje: ${response.body}");
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text("Error al crear viaje: ${const JsonDecoder().convert(response.body)['message']}"),
                ));
                }
              });
            },
            child: const Text(
              'Crear Viaje',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Gilroy-Medium',
                fontSize: 16.0,
              ),
            ),
          ),
        )
      ],
    );
  }

  Future<http.Response> fetchAddViaje(CreateViaje viaje) {
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    print('Viaje: ${jsonEncode(viaje.toJson())}');
    return http.post(Uri.parse('${Constants.socketUrl}/api/trips'),
        body: jsonEncode(viaje.toJson()), headers: headers);
  }

  Future<List<LatLng>> getPolylinePoints() async {
    try {
      List<LatLng> polylineCoordinates = [];
      PolylinePoints polylinePoints = PolylinePoints();
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey: Constants.apiKey,
        request: PolylineRequest(
          origin: PointLatLng(_originMarker!.position.latitude,
              _originMarker!.position.longitude),
          destination: PointLatLng(_destinationMarker!.position.latitude,
              _destinationMarker!.position.longitude),
          mode: TravelMode.driving,
        ),
      );
      if (result.points.isNotEmpty) {
        result.points.forEach((PointLatLng point) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        });
      } else {
        print("ERROR POLYLINES: ${result.errorMessage}");
      }
      return polylineCoordinates;
    } catch (e) {
      print('Error getting polyline points: $e');
      return [];
    }
  }

  void generatePolyLineFromPoints(List<LatLng> polylineCoordinates) {
    PolylineId id = const PolylineId('poly');
    Polyline polyline = Polyline(
      polylineId: id,
      color: const Color.fromARGB(255, 40, 122, 198),
      points: polylineCoordinates,
      width: 3,
    );
    setState(() {
      polylines[id] = polyline;
    });
  }

  Future<String> getAddressFromCoordinates(
      double latitude, double longitude) async {
    const apiKey = Constants.apiKey;
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse['status'] == 'OK') {
        final address = jsonResponse['results'][0]['formatted_address'];
        return address;
      } else {
        throw Exception(
            'Error obteniendo la dirección: ${jsonResponse['status']}');
      }
    } else {
      throw Exception('Error en la solicitud: ${response.statusCode}');
    }
  }
}
