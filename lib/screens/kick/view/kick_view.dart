import 'package:flutter/material.dart';

class KickView extends StatefulWidget {
  const KickView({super.key});

  @override
  State<KickView> createState() => _KickViewState();
}

class _KickViewState extends State<KickView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kick")),
      body: const Center(child: Text("Kick View")),
    );
  }
}
