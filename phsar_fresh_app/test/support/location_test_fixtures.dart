import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Inspect GoogleMap options without creating an Android/iOS platform view.
Widget buildTestGoogleMap(GoogleMap map) =>
    const ColoredBox(color: Color(0xFFF0F4EE), child: SizedBox.expand());
