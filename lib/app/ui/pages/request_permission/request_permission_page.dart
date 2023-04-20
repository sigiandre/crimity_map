import 'dart:async';

import 'package:crimity_map/app/ui/pages/request_permission/request_permission_controller.dart';
import 'package:crimity_map/app/ui/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class RequestPermissionPage extends StatefulWidget {
  const RequestPermissionPage({Key? key}) : super(key: key);

  @override
  State<RequestPermissionPage> createState() => _RequestPermissionPageState();
}

class _RequestPermissionPageState extends State<RequestPermissionPage> with WidgetsBindingObserver{
  final _controller = RequestPermissionController(Permission.locationWhenInUse);
  late StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    _subscription = _controller.onStatusChanged.listen(
          (status) {
            switch(status){
              case PermissionStatus.granted:
                _goToHome();
                break;
              case PermissionStatus.permanentlyDenied:
                showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text("Info"),
                      content: const Text("Acceso al dispositivo"),
                      actions: [
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              openAppSettings();
                            },
                            child: const Text("Ir a Configuración"),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text("Cancel"),
                        ),
                      ],
                    ),
                );
                break;
            }
          },
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async{
    if(state == AppLifecycleState.resumed){
      final status = await _controller.check();
      if(status == PermissionStatus.granted){
        _goToHome();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    _subscription.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _goToHome(){
    Navigator.pushReplacementNamed(context, Routes.HOME);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          alignment: Alignment.center,
          child: ElevatedButton(
            child: const Text("Allow"),
            onPressed: (){
              _controller.request();
            },
          ),
        ),
      ),
    );
  }
}
