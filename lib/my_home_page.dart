import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tmc/data.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Timer timer;
  Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};
  final _mapController = Completer();
  final _textController = TextEditingController();
  final _focusNode = FocusNode();
  bool? _showTram = true;
  bool? _showBus = true;
  String _searchValue = "";
  bool _snackbarShown = true;

  @override
  void initState() {
    startTimer();
    super.initState();
  }

  void getData() async {
    final vehicles = await DataRepo().getData();
    Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
    final tram = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(0.000001, 0.00001)), 'tram.png');
    final bus = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(0.000001, 0.00001)), 'bus.png');
    for (var vehicle in vehicles) {
      final markerId = vehicle.id.toString();
      if (((vehicle.id >= 1000 && _showBus!) || (vehicle.id < 1000 && _showTram!)) &&
          (vehicle.nr == _searchValue || _searchValue == "")) {
        final vehicleName = vehicle.id >= 1000 ? "Autobus" : "Tramwaj";
        markers[MarkerId(markerId)] = Marker(
            markerId: MarkerId(markerId),
            position: LatLng(vehicle.latitude, vehicle.longitude),
            icon: vehicle.id >= 1000 ? bus : tram,
            onTap: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    vehicleName + " linii nr " + vehicle.nr.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 17,
                    ),
                  ),
                  backgroundColor: Colors.black12.withOpacity(0.85),
                ),
              );
            });
      }
    }
    setState(() {
      _markers = markers;
    });
    if (_markers.isEmpty && !_snackbarShown) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Nie znaleziono pojazdów',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 17,
            ),
          ),
          backgroundColor: Colors.black12.withOpacity(0.85),
        ),
      );
    }
    _snackbarShown = true;
  }

  void startTimer() {
    getData();
    timer = Timer.periodic(const Duration(seconds: 5), (Timer t) async {
      getData();
    });
  }

  Widget checkboxRow({
    required String title,
    required void Function(bool?)? onChanged,
    required IconData icon,
    required bool? value,
  }) =>
      Row(
        children: [
          Checkbox(
            value: value,
            checkColor: Colors.black,
            activeColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(2.0),
            ),
            side: MaterialStateBorderSide.resolveWith(
              (states) => const BorderSide(width: 1.0, color: Colors.white),
            ),
            onChanged: onChanged,
          ),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 18,
            ),
          ),
          const SizedBox(width: 3),
          Icon(icon, color: Colors.white, size: 26),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          GoogleMap(
            myLocationEnabled: true,
            initialCameraPosition: const CameraPosition(
              target: LatLng(52.43, 16.93),
              zoom: 12.00,
            ),
            onMapCreated: (GoogleMapController controller) {
              _mapController.complete(controller);
            },
            markers: _markers.values.toSet(),
          ),
          Container(
              height: 180,
              width: MediaQuery.of(context).size.width,
              color: Colors.black12.withOpacity(0.85),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 50, 16, 10),
                    child: TextField(
                      controller: _textController,
                      focusNode: _focusNode,
                      cursorColor: Colors.white,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                      decoration: InputDecoration(
                        hintText: "Wprowadź numer pojazdu",
                        hintStyle:
                            const TextStyle(color: Colors.white, fontWeight: FontWeight.w400),
                        focusedBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(16.0)),
                          borderSide: BorderSide(
                            color: Colors.white60,
                            width: 2.0,
                          ),
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(16.0)),
                          borderSide: BorderSide(color: Colors.white60),
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.send, color: Colors.white),
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                            _snackbarShown = false;
                            setState(() {
                              _searchValue = _textController.text;
                            });
                            getData();
                          },
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        checkboxRow(
                          title: "autobus",
                          onChanged: (value) {
                            setState(() {
                              _showBus = value;
                            });
                            getData();
                          },
                          icon: Icons.directions_bus,
                          value: _showBus,
                        ),
                        checkboxRow(
                          title: "tramwaj",
                          onChanged: (value) {
                            setState(() {
                              _showTram = value;
                            });
                            getData();
                          },
                          icon: Icons.tram,
                          value: _showTram,
                        ),
                      ],
                    ),
                  )
                ],
              )),
        ],
      ),
    );
  }
}
