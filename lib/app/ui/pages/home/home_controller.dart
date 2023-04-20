import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:crimity_map/app/helpers/image_to_bytes.dart';
import 'package:flutter/widgets.dart' show ChangeNotifier, ImageConfiguration, Offset;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../utils/map_style.dart';
import 'package:geolocator/geolocator.dart';

class HomeController extends ChangeNotifier{
  final Map<MarkerId, Marker> _markers = {};
  Set<Marker> get markers => _markers.values.toSet();

  final _markersController = StreamController<String>.broadcast();
  Stream<String> get onMarkerTap => _markersController.stream;

  Position? _initialPosition;
  CameraPosition get initialCameraPosition => CameraPosition(
      target: LatLng(
        _initialPosition!.latitude,
        _initialPosition!.longitude,
      ),
    zoom: 15,
  );

  final _ladronIcon = Completer<BitmapDescriptor>();

  bool _loading = true;
  bool get loading => _loading;

  late bool _gpsEnabled;
  bool get gpsEnabled => _gpsEnabled;

  StreamSubscription? _gpsSubscription, _positionSubscription;

  HomeController() {
    _init();
  }

  Future<void>_init() async{
    final value = await imageToBytes(
        'https://cdn-icons-png.flaticon.com/512/2323/2323072.png',
        width: 130,
        fromNetwork: true
    );
    final bitmap = BitmapDescriptor.fromBytes(value);
    _ladronIcon.complete(bitmap);
    _gpsEnabled = await Geolocator.isLocationServiceEnabled();
    _loading = false;
    _gpsSubscription = Geolocator.getServiceStatusStream().listen(
          (status) async {
            _gpsEnabled = status == ServiceStatus.enabled;
            if(_gpsEnabled){
              await _initLocationUpdates();
            }
          },
    );
    await _initLocationUpdates();
  }

  Future<void> _initLocationUpdates() async {
    bool initialized = false;
    await _positionSubscription?.cancel();
    _positionSubscription = Geolocator.getPositionStream().listen(
        (position) {
          print("👮 $position");
          if(!initialized) {
            print("👮 init $position");
            _setInitialPosition(position);
            initialized = true;
            notifyListeners();
          }
        },
        onError: (e) {
          print("☠️onError ${e.runtimeType}");
          if(e is LocationServiceDisabledException) {
            _gpsEnabled = false;
            notifyListeners();
          }
        }
    );
  }

  void _setInitialPosition(Position position) {
    if(_gpsEnabled && _initialPosition == null){
      //_initialPosition = await Geolocator.getLastKnownPosition();
      _initialPosition = position;
    }
  }

  void onMapCreated(GoogleMapController controller){
    controller.setMapStyle(mapStyle);
  }

  Future<void> turnOnGPS() => Geolocator.openLocationSettings();

  void onTap(LatLng position) async {
    final id = _markers.length.toString();
    final markerId = MarkerId(id);

    final icon = await _ladronIcon.future;

    final marker = Marker(
      markerId: markerId,
      position: position,
      draggable: true,
      icon: icon,
      // anchor: const Offset(0.5,1),
      onTap: (){
        _markersController.sink.add(id);
      },
      onDragEnd: (newPosition) {
        print("new position $newPosition");
      }
    );
    _markers[markerId] = marker;
    notifyListeners();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _gpsSubscription?.cancel();
    _markersController.close();
    super.dispose();
  }
}