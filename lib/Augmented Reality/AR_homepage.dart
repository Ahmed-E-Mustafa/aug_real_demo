import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import 'package:url_launcher/url_launcher.dart';
class ARdemo extends StatefulWidget {
  @override
  _ARdemo createState() => _ARdemo();
}

class _ARdemo extends State<ARdemo> {
  late ArCoreController arCoreController;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Hello World'),
                actions: [
                  PopupMenuButton<String>(
            onSelected: (value) async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/');
              
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
          ),
            ],
        ),
        body: ArCoreView(
          onArCoreViewCreated: _onArCoreViewCreated,
        ),
        
      ),
    );
  }

  void _onArCoreViewCreated(ArCoreController controller) {
    arCoreController = controller;

    _addSphere(arCoreController);
    _addCylindre(arCoreController);
    _addCube(arCoreController);

    _addGLBModel(arCoreController);
  }

  void _addGLBModel(ArCoreController controller) {
    final node = ArCoreReferenceNode(
      name: 'triangle',
      objectUrl: 'assets/triangle.glb',
      position: vector.Vector3(0.0, 0.0, -2.0), // Adjust position as needed
      rotation: vector.Vector4(0.0, 0.0, 0.0, 1.0), // Adjust rotation as needed
    );
    controller.addArCoreNode(node);
  }

  void _addSphere(ArCoreController controller) {
    final material = ArCoreMaterial(
        color: const Color.fromARGB(120, 66, 134, 244));
    final sphere = ArCoreSphere(
      materials: [material],
      radius: 0.1,
    );
    final node = ArCoreNode(
      shape: sphere,
      position: vector.Vector3(0, 0, -1.5),
    );
    controller.addArCoreNode(node);
  }

  void _addCylindre(ArCoreController controller) {
    final material = ArCoreMaterial(
      color: Colors.red,
      reflectance: 1.0,
    );
    final cylindre = ArCoreCylinder(
      materials: [material],
      radius: 0.5,
      height: 0.3,
    );
    final node = ArCoreNode(
      shape: cylindre,
      position: vector.Vector3(0.0, -0.5, -2.0),
    );
    controller.addArCoreNode(node);
  }

  void _addCube(ArCoreController controller) {
    final material = ArCoreMaterial(
      color:const Color.fromARGB(120, 66, 134, 244),
      metallic: 1.0,
    );
    final cube = ArCoreCube(
      materials: [material],
      size: vector.Vector3(0.5, 0.5, 0.5),
    );
    final node = ArCoreNode(
      shape: cube,
      position: vector.Vector3(-0.5, 0.5, -3.5),
    );
    controller.addArCoreNode(node);
  }

  @override
  void dispose() {
    arCoreController.dispose();
    super.dispose();
  }
}
