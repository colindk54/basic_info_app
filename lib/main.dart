import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_device_imei/flutter_device_imei.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inspection machine',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        appBarTheme: AppBarTheme(
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      ),
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<ConnectivityResult>? connectivityResults;
  List<AppPermission>? permissions;
  AndroidDeviceInfo? deviceInfo;
  String? imei;

  @override
  void initState() {
    super.initState();
    _getImei();
    _getConnectivity();
    _getPermissions();
    _getDeviceInfo();
  }

  Future<void> _getImei() async {
    imei = await FlutterDeviceImei.instance.getIMEI();
    setState(() {

    });
  }

  Future<void> _getDeviceInfo() async {
    DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    deviceInfo = await deviceInfoPlugin.androidInfo;
    setState(() {});
  }

  Future<void> _getConnectivity() async {
    connectivityResults = await (Connectivity().checkConnectivity());

    setState(() {});
  }

  Future<void> _getPermissions() async {
    permissions = [];
    for (Permission perm in Permission.values) {
      try {
        PermissionStatus status = await perm.status;
        permissions!.add(AppPermission(perm.toString(), status));
      } on Error catch (e) {
        print('Error : $e');
      } on Exception catch (e) {
        print('Exception : $e');
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    List<Object?> missing = [connectivityResults];
    Size size = MediaQuery.sizeOf(context);
    Orientation orientation = MediaQuery.orientationOf(context);
    List<Widget> children = [];
    if(deviceInfo != null) {
      children.add(Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Android ${deviceInfo!.version.release}'),
          Text('Fabricant : ${deviceInfo!.manufacturer}'),
        ],
      ));
    }
    children.addAll([
      Text('Résolution : ${size.width.toInt()} x ${size.height.toInt()}'),
      Text('Orientation : ${orientation.name}'),
    ]);
    if(imei != null) children.add(Text('IMEI : $imei'));
    if (connectivityResults != null) {
      children.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Connexions : '),
            ...(connectivityResults!.map(
              (ConnectivityResult res) => Text(res.name),
            )),
          ],
        ),
      );
    }

    if (permissions != null) {
      children.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Permissions :'),
            ...permissions!
                .map((AppPermission perm) => Text(perm.toString()))
                ,
          ],
        ),
      );
    }

    if (missing.contains(null)) {
      children.add(CircularProgressIndicator());
    }
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 25,
              mainAxisAlignment: MainAxisAlignment.center,
              children: children,
            ),
          ),
        ),
      ),
    );
  }
}

class AppPermission {
  final String label;
  final PermissionStatus status;

  AppPermission(this.label, this.status);

  @override
  String toString() {
    return '$label : $status';
  }
}