import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ui.FragmentProgram? _fragmentProgram;
  ui.Image? _texture;
  ui.Image? _lut;
  double _lut_value = 1.0;

  ui.Shader? _getShader() {
    final shader = _fragmentProgram?.fragmentShader();

    if (shader == null) {
      return null;
    }

    final texture = _texture;

    if (texture == null) {
      return null;
    }

    final lut = _lut;

    if (lut == null) {
      return null;
    }

    shader.setFloat(0, 960.0);
    shader.setFloat(1, 540.0);
    shader.setFloat(2, _lut_value);

    shader.setImageSampler(0, texture);
    shader.setImageSampler(1, lut);

    return shader;
  }

  @override
  void initState() {
    rootBundle.load('images/texture.jpg').then(
          (byteData) => ui.decodeImageFromList(
            byteData.buffer.asUint8List(),
            (texture) => setState(
              () {
                _texture = texture;
              },
            ),
          ),
        );
    rootBundle.load('images/lut.png').then(
          (byteData) => ui.decodeImageFromList(
            byteData.buffer.asUint8List(),
            (lut) => setState(
              () {
                _lut = lut;
              },
            ),
          ),
        );
    ui.FragmentProgram.fromAsset('shader/shader.frag').then(
      (fragmentProgram) => setState(
        () {
          _fragmentProgram = fragmentProgram;
        },
      ),
    );
    super.initState();
  }

  @override
  void dispose() {
    _texture?.dispose();
    _lut?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shader = _getShader();
    final body = shader != null ? CustomPaint(painter: ShaderPainter(shader: shader)) : const SizedBox.expand();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: [
            FittedBox(
              child: SizedBox(
                width: 960.0,
                height: 540.0,
                child: body,
              ),
            ),
            Slider(
              value: _lut_value,
              onChanged: (value) {
                setState(
                  () {
                    _lut_value = value;
                  },
                );
              },
            )
          ],
        ),
      ),
    );
  }
}

class ShaderPainter extends CustomPainter {
  ShaderPainter({required this.shader});

  final ui.Shader shader;

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    final paint = Paint();
    paint.color = Colors.red;
    canvas.drawRect(Offset.zero & size, paint);
    paint.shader = shader;
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
