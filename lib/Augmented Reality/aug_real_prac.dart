import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:flutter/services.dart';
import 'package:vector_math/vector_math_64.dart' as vector64;

class AugRealPrac extends StatefulWidget {
  const AugRealPrac({super.key});

  @override
  State<AugRealPrac> createState() => _AugRealPrac();
}

class _AugRealPrac extends State<AugRealPrac> {
  ArCoreController? augmentedRealityCoreController;

  void augmentedRealityViewCreated(ArCoreController coreController) {
    augmentedRealityCoreController = coreController;
    displayShapes(augmentedRealityCoreController!);
  }

  Future<void> displayShapes(ArCoreController coreController) async {
    try {
      final ByteData displayShapesTextureBytes =
          await rootBundle.load("assets/triangle.png");

      final materials = ArCoreMaterial(
        color: const Color.fromARGB(255, 20, 20, 203),
        textureBytes: displayShapesTextureBytes.buffer.asUint8List(),
      );

      final shapeSphere = ArCoreSphere(
        materials: [materials],
        radius: 0.1,
      );

      final node = ArCoreNode(
        shape: shapeSphere,
        position: vector64.Vector3(0, 0, -1),
      );

      augmentedRealityCoreController!.addArCoreNode(node);
    } catch (e) {
      print('Error loading texture or adding shape: $e');
    }
  }

  @override
  void dispose() {
    augmentedRealityCoreController?.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    augmentedRealityCoreController?.dispose();
    return true; 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AR Example"),
        centerTitle: true,
      ),
      body: WillPopScope(
        onWillPop: _onWillPop, // Handle back button press
        child: ArCoreView(
          onArCoreViewCreated: augmentedRealityViewCreated,
        ),
      ),
    );
  }
}
