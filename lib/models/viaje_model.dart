// To parse this JSON data, do
//
//     final viaje = viajeFromJson(jsonString);

import 'dart:convert';

List<Viaje> viajeFromJson(String str) => List<Viaje>.from(json.decode(str).map((x) => Viaje.fromJson(x)));

String viajeToJson(List<Viaje> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Viaje {
    int id;
    String name;
    String latOrigin;
    String lngOrigin;
    String latDestination;
    String lngDestination;
    DateTime date;
    String startTime;
    int driverId;
    int price;
    int status;
    int totalSeats;
    int usedSeats;
    DateTime createdAt;
    DateTime updatedAt;
    Driver driver;
    List<Driver> passengers;

    Viaje({
        required this.id,
        required this.name,
        required this.latOrigin,
        required this.lngOrigin,
        required this.latDestination,
        required this.lngDestination,
        required this.date,
        required this.startTime,
        required this.driverId,
        required this.price,
        required this.status,
        required this.totalSeats,
        required this.usedSeats,
        required this.createdAt,
        required this.updatedAt,
        required this.driver,
        required this.passengers,
    });

    factory Viaje.fromJson(Map<String, dynamic> json) => Viaje(
        id: json["id"],
        name: json["name"],
        latOrigin: json["latOrigin"],
        lngOrigin: json["lngOrigin"],
        latDestination: json["latDestination"],
        lngDestination: json["lngDestination"],
        date: DateTime.parse(json["date"]),
        startTime: json["startTime"],
        driverId: json["driverId"],
        price: json["price"],
        status: json["status"],
        totalSeats: json["totalSeats"],
        usedSeats: json["usedSeats"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
        driver: Driver.fromJson(json["driver"]),
        passengers: List<Driver>.from(json["passengers"].map((x) => Driver.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "latOrigin": latOrigin,
        "lngOrigin": lngOrigin,
        "latDestination": latDestination,
        "lngDestination": lngDestination,
        "date": date.toIso8601String(),
        "startTime": startTime,
        "driverId": driverId,
        "price": price,
        "status": status,
        "totalSeats": totalSeats,
        "usedSeats": usedSeats,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
        "driver": driver.toJson(),
        "passengers": List<dynamic>.from(passengers.map((x) => x.toJson())),
    };
}

class Driver {
    int id;
    String fullname;
    String email;
    int type;
    DateTime createdAt;
    DateTime updatedAt;
    TripPassenger? tripPassenger;

    Driver({
        required this.id,
        required this.fullname,
        required this.email,
        required this.type,
        required this.createdAt,
        required this.updatedAt,
        this.tripPassenger,
    });

    factory Driver.fromJson(Map<String, dynamic> json) => Driver(
        id: json["id"],
        fullname: json["fullname"],
        email: json["email"],
        type: json["type"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
        tripPassenger: json["trip_passenger"] == null ? null : TripPassenger.fromJson(json["trip_passenger"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "fullname": fullname,
        "email": email,
        "type": type,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
        "trip_passenger": tripPassenger?.toJson(),
    };
}

class TripPassenger {
    int tripId;
    int passengerId;
    int stopId;
    DateTime createdAt;
    DateTime updatedAt;

    TripPassenger({
        required this.tripId,
        required this.passengerId,
        required this.stopId,
        required this.createdAt,
        required this.updatedAt,
    });

    factory TripPassenger.fromJson(Map<String, dynamic> json) => TripPassenger(
        tripId: json["tripId"],
        passengerId: json["passengerId"],
        stopId: json["stopId"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
    );

    Map<String, dynamic> toJson() => {
        "tripId": tripId,
        "passengerId": passengerId,
        "stopId": stopId,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
    };
}
