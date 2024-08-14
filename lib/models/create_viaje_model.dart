// To parse this JSON data, do
//
//     final createViaje = createViajeFromJson(jsonString);

import 'dart:convert';

CreateViaje createViajeFromJson(String str) => CreateViaje.fromJson(json.decode(str));

String createViajeToJson(CreateViaje data) => json.encode(data.toJson());

class CreateViaje {
    String name;
    String latOrigin;
    String lngOrigin;
    String latDestination;
    String lngDestination;
    String date;
    String price;
    int seats;
    List<Stop> stops;
    String startTime;

    CreateViaje({
        required this.name,
        required this.latOrigin,
        required this.lngOrigin,
        required this.latDestination,
        required this.lngDestination,
        required this.date,
        required this.price,
        required this.seats,
        required this.stops,
        required this.startTime,
    });

    factory CreateViaje.fromJson(Map<String, dynamic> json) => CreateViaje(
        name: json["name"],
        latOrigin: json["latOrigin"],
        lngOrigin: json["lngOrigin"],
        latDestination: json["latDestination"],
        lngDestination: json["lngDestination"],
        date: json["date"],
        price: json["price"],
        seats: json["seats"],
        stops: List<Stop>.from(json["stops"].map((x) => Stop.fromJson(x))),
        startTime: json["startTime"],
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "latOrigin": latOrigin,
        "lngOrigin": lngOrigin,
        "latDestination": latDestination,
        "lngDestination": lngDestination,
        "date": date,
        "price": price,
        "seats": seats,
        "stops": List<dynamic>.from(stops.map((x) => x.toJson())),
        "startTime": startTime,
    };
}

class Stop {
    String lat;
    String lng;
    String time;

    Stop({
        required this.lat,
        required this.lng,
        required this.time,
    });

    factory Stop.fromJson(Map<String, dynamic> json) => Stop(
        lat: json["lat"],
        lng: json["lng"],
        time: json["time"],
    );

    Map<String, dynamic> toJson() => {
        "lat": lat,
        "lng": lng,
        "time": time,
    };
}
