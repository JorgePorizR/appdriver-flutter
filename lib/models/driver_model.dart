// To parse this JSON data, do
//
//     final driver = driverFromJson(jsonString);

import 'dart:convert';

Driver driverFromJson(String str) => Driver.fromJson(json.decode(str));

String driverToJson(Driver data) => json.encode(data.toJson());

class Driver {
    int? id;
    String fullname;
    String email;
    String password;
    String vehicleBrand;
    String vehicleModel;
    String vehicleColor;
    String vehiclePlate;

    Driver({
        this.id,
        required this.fullname,
        required this.email,
        required this.password,
        required this.vehicleBrand,
        required this.vehicleModel,
        required this.vehicleColor,
        required this.vehiclePlate,
    });

    factory Driver.fromJson(Map<String, dynamic> json) => Driver(
        id: json["id"],
        fullname: json["fullname"],
        email: json["email"],
        password: json["password"],
        vehicleBrand: json["vehicle_brand"],
        vehicleModel: json["vehicle_model"],
        vehicleColor: json["vehicle_color"],
        vehiclePlate: json["vehicle_plate"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "fullname": fullname,
        "email": email,
        "password": password,
        "vehicle_brand": vehicleBrand,
        "vehicle_model": vehicleModel,
        "vehicle_color": vehicleColor,
        "vehicle_plate": vehiclePlate,
    };
}
