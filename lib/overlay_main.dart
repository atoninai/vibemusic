import 'package:flutter/material.dart';
import 'overlay/dynamic_island_overlay.dart';

/// Overlay entry point — invoked by flutter_overlay_window
@pragma("vm:entry-point")
void overlayMain() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DynamicIslandOverlay(),
    ),
  );
}
