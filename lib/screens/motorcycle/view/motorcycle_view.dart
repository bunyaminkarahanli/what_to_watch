import 'package:flutter/material.dart';

class MotorcycleView extends StatefulWidget {
  const MotorcycleView({super.key});

  @override
  State<MotorcycleView> createState() => _KickViewState();
}

class _KickViewState extends State<MotorcycleView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kick")),
      body: const Center(child: Text("Kick View")),
    );
  }
}
