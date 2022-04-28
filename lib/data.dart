import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tmc/vehicle.dart';

class DataRepo {
  Future<List<Vehicle>> getData() async {
    final url = Uri.parse('https://0fbc-46-205-211-138.eu.ngrok.io/fetchData');
    final response = await http.get(url);
    final result = json.decode(response.body);
    List vehiclesTemp = result["vehicles"];
    List<Vehicle> vehicles = [];
    for (var vehicle in vehiclesTemp) {
      vehicles.add(Vehicle(
        id: int.parse(vehicle["id"]),
        nr: vehicle["label"].substring(0, vehicle["label"].indexOf("/")),
        latitude: vehicle["latitude"],
        longitude: vehicle["longitude"],
      ));
    }
    return vehicles;
  }
}
