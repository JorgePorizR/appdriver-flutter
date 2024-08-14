// To parse this JSON data, do
//
//     final viaje = viajeFromJson(jsonString);

import 'dart:convert';

ViajeDetail viajeDetailFromJson(String str) => ViajeDetail.fromJson(json.decode(str));

String viajeDetailToJson(ViajeDetail data) => json.encode(data.toJson());

class ViajeDetail {
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
    List<Stop> stops;

    ViajeDetail({
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
        required this.stops,
    });

    factory ViajeDetail.fromJson(Map<String, dynamic> json) => ViajeDetail(
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
        stops: List<Stop>.from(json["stops"].map((x) => Stop.fromJson(x))),
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
        "stops": List<dynamic>.from(stops.map((x) => x.toJson())),
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

class Stop {
    int id;
    String lat;
    String lng;
    String time;
    int visited;
    int tripId;
    int passengerQty;
    DateTime createdAt;
    DateTime updatedAt;

    Stop({
        required this.id,
        required this.lat,
        required this.lng,
        required this.time,
        required this.visited,
        required this.tripId,
        required this.passengerQty,
        required this.createdAt,
        required this.updatedAt,
    });

    factory Stop.fromJson(Map<String, dynamic> json) => Stop(
        id: json["id"],
        lat: json["lat"],
        lng: json["lng"],
        time: json["time"],
        visited: json["visited"],
        tripId: json["tripId"],
        passengerQty: json["passengerQty"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "lat": lat,
        "lng": lng,
        "time": time,
        "visited": visited,
        "tripId": tripId,
        "passengerQty": passengerQty,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
    };
}
