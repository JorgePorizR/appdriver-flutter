import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:appdriver/constants/constants.dart';
import 'package:appdriver/models/viajedetail_model.dart';
import 'package:appdriver/storage/history_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ViajeDetailPage extends StatefulWidget {
  final int? viajeId;
  const ViajeDetailPage({super.key, required this.viajeId});

  @override
  State<ViajeDetailPage> createState() => _ViajeDetailPageState();
}

class _ViajeDetailPageState extends State<ViajeDetailPage> {
  late IO.Socket socket;
  late int viajeId;
  late DataStorage? dataStorage;
  String token = '';
  String choferId = '';
  ViajeDetail? viajeDetail;

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  Marker? _originMarker;
  Marker? _destinationMarker;

  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  Map<MarkerId, Marker> paradasMarkers = <MarkerId, Marker>{};
  List<Stop> paradas = [];
  List<Stop> paradasVisited = [];

  Marker? _currentLocationMarker;

  BitmapDescriptor _originLocationIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor _destinationLocationIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor _currentLocationIcon = BitmapDescriptor.defaultMarker;

  Timer? timer;
  Timer? timerCurrentLocation;
  int currentIndex = 0;
  late Stop stopActual;
  bool _isStop = false;
  bool _isFinish = false;

  @override
  void initState() {
    super.initState();
    viajeId = widget.viajeId as int;
    initSharedPreferences();
    manageSocket();
    setCustomMarkerIcon();
    loadToken().then((_) {
      loadViajeDetail();
    });
  }

  void startPrintCurrentLocation() {
    socket.emit('identificarChofer', {'id': int.parse(choferId)});
    timerCurrentLocation =
        Timer.periodic(const Duration(seconds: 30), (Timer t) {
      //print("choferId $choferId");
      //print('Current Location: ${_currentLocationMarker!.position}');
      socket.emit('actualizarChofer', {
        'driverId': int.parse(choferId),
        'lat': _currentLocationMarker!.position.latitude.toString(),
        'lng': _currentLocationMarker!.position.longitude.toString(),
      });
    });
  }

  Future<void> initSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      dataStorage = DataStorage(prefs);
    });
  }

  Future<void> manageSocket() async {
    try {
      socket = IO.io(Constants.socketUrl, <String, dynamic>{
        'autoConnect': true,
        'transports': ['websocket'],
      });
      socket.connect();
      socket.onConnect((data) {
        print('socket connected: ${socket.id}');
      });
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> loadToken() async {
    final loadedToken = await DataStorage.loadToken('token');
    final loadedChoferId = await DataStorage.loadChoferId('choferId');
    setState(() {
      token = loadedToken;
      choferId = loadedChoferId;
    });
  }

  void setCustomMarkerIcon() {
    BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(30, 40)),
      'markerIcon.png',
    ).then((value) {
      _originLocationIcon = value;
    });
    BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(30, 40)),
      'markerIcon.png',
    ).then((value) {
      _destinationLocationIcon = value;
    });
    BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(50, 50)),
      'carIcon.png',
    ).then((value) {
      _currentLocationIcon = value;
    });
  }

  Future<void> loadViajeDetail() async {
    try {
      final response = await fetchViajeDetail(viajeId);
      if (response.statusCode == 200) {
        //print('Response: ${response.body}');
        viajeDetail = viajeDetailFromJson(response.body);
        final originLatLng = LatLng(
          double.parse(viajeDetail!.latOrigin),
          double.parse(viajeDetail!.lngOrigin),
        );
        final destinationLatLng = LatLng(
          double.parse(viajeDetail!.latDestination),
          double.parse(viajeDetail!.lngDestination),
        );
        paradas = viajeDetail!.stops;
        paradas.asMap().forEach((index, stop) {
          final paradaLatLng = LatLng(
            double.parse(stop.lat),
            double.parse(stop.lng),
          );
          final markerId = MarkerId(stop.id.toString());
          final marker = Marker(
            markerId: markerId,
            position: paradaLatLng,
            infoWindow: InfoWindow(
              title: 'Parada ${index + 1}',
              snippet: 'Parada ${index + 1}\n${stop.passengerQty} pasajeros',
            ),
          );
          paradasMarkers[markerId] = marker;
        });
        _currentLocationMarker = Marker(
          markerId: const MarkerId('currentLocation'),
          icon: _currentLocationIcon,
          position: originLatLng,
          infoWindow: const InfoWindow(
            title: 'Current Location',
            snippet: 'Ubicación actual',
          ),
        );
        _originMarker = Marker(
          markerId: const MarkerId('origin'),
          icon: _originLocationIcon,
          position: originLatLng,
          infoWindow: const InfoWindow(
              title: 'Origen Location', snippet: 'Ubicación de partida'),
        );
        _destinationMarker = Marker(
          markerId: const MarkerId('destination'),
          icon: _destinationLocationIcon,
          position: destinationLatLng,
          infoWindow: const InfoWindow(
              title: 'Destino Location', snippet: 'Ubicación de destino'),
        );
        getPolylinePoints().then((value) {
          generatePolyLineFromPoints(value);
          startPrintingCoordinates();
          startPrintCurrentLocation();
        });
        setState(() {});
      } else {
        print('Failed to load viaje detail');
      }
    } catch (e) {
      print('Error loading viaje detail: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
        /*leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/',
              (route) => false,
            );
          },
        ),*/
      ),
      body: _currentLocationMarker == null
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
                    ],
                  ),
                ),
                if (_isStop) getButtonRestart(),
                if (_isFinish) getButtonFinishViaje(),
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
        target: LatLng(_originMarker!.position.latitude,
            _originMarker!.position.longitude),
        zoom: 15.0,
      ),
      markers: {
        if (_originMarker != null) _originMarker!,
        if (_currentLocationMarker != null) _currentLocationMarker!,
        if (_destinationMarker != null) _destinationMarker!,
        if (paradasMarkers.isNotEmpty) ...paradasMarkers.values,
      },
      polylines: Set<Polyline>.of(polylines.values),
    );
  }

  Widget getButtonRestart() {
    return FutureBuilder<String>(
      future: getAddressFromCoordinates(double.parse(stopActual.lat), double.parse(stopActual.lng)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          final stopDirection = snapshot.data!;
          return Column(
            children: [
              Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 10.0),
                  child: Text(
                    'Parada: $stopDirection',
                    style: const TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Gilroy-Bold',
                      color: Color(0xfff2264b),
                    ),
                  )),
              Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 10.0),
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
                        _isStop = false;
                        socket.emit('dejandoPuntoRecogida', {
                          'tripId': viajeId,
                          'driverId': int.parse(choferId),
                          'stopId': stopActual.id,
                        });
                      });
                      startPrintingCoordinates();
                    },
                    child: const Text(
                      "Continuar Viaje",
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Gilroy-Bold',
                        color: Colors.white,
                      ),
                    ),
                  )),
            ],
          );
        }
      },
    );
  }

  getButtonFinishViaje() {
    return Padding(
        padding: const EdgeInsets.all(8.0),
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
              socket.emit('finalizarViaje', {'tripId': viajeId});
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/',
                (route) => false,
              );
            });
          },
          child: const Text(
            "Finalizar Viaje",
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              fontFamily: 'Gilroy-Bold',
              color: Colors.white,
            ),
          ),
        ));
  }

  Future<List<LatLng>> getPolylinePoints() async {
    try {
      //List<LatLng> polylineCoordinates = [];
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

  Future<http.Response> fetchViajeDetail(int viajeId) {
    if (token.isEmpty) {
      print('Token is not available yet');
      return Future.error('Token is not available yet');
    }
    print('Token: $token');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    return http.get(Uri.parse('${Constants.socketUrl}/api/trips/$viajeId'),
        headers: headers);
  }

  void startPrintingCoordinates() {
    if (!_isStop) {
      const double proximityRadius = 100;
      timer = Timer.periodic(const Duration(seconds: 5), (Timer t) {
        if (currentIndex < polylineCoordinates.length) {
          LatLng coordinate = polylineCoordinates[currentIndex];
          //print('Lat: ${coordinate.latitude}, Lng: ${coordinate.longitude}');

          // Verifica si la coordenada está cerca de alguna parada no visitada
          for (var stop in paradas) {
            LatLng stopCoordinate =
                LatLng(double.parse(stop.lat), double.parse(stop.lng));
            double distance = _calculateDistance(coordinate, stopCoordinate);

            if (distance <= proximityRadius && !paradasVisited.contains(stop)) {
              //print('La coordenada está dentro de los 100 metros de la parada con id: ${stop.id}.');
              paradasVisited.add(stop);
              setState(() {
                _isStop = true;
                timer?.cancel();
                socket.emit('enPuntoRecogida', {
                  'tripId': viajeId,
                  'driverId': int.parse(choferId),
                  'stopId': stop.id,
                });
                stopActual = stop;
              });
              break;
            }
          }

          setState(() {
            _currentLocationMarker = _currentLocationMarker!.copyWith(
              positionParam: coordinate,
            );
          });
          currentIndex += 1;
          verifyFinishViaje();
        } else {
          timer?.cancel();
        }
      });
    }
  }

  void verifyFinishViaje() {
    if (currentIndex >= polylineCoordinates.length) {
      setState(() {
        _isFinish = true;
        timer?.cancel();
      });
    }
  }

  double _calculateDistance(LatLng start, LatLng end) {
    const double earthRadius = 6371000; // Radio de la Tierra en metros

    double dLat = _degreesToRadians(end.latitude - start.latitude);
    double dLng = _degreesToRadians(end.longitude - start.longitude);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(start.latitude)) *
            cos(_degreesToRadians(end.latitude)) *
            sin(dLng / 2) *
            sin(dLng / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
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

  @override
  void dispose() {
    socket.disconnect();
    timer?.cancel();
    timerCurrentLocation?.cancel();
    super.dispose();
  }
}
