import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class MoodIntensityGauge extends StatefulWidget {
  final Function(int) onIntensitySelected;

  const MoodIntensityGauge({Key? key, required this.onIntensitySelected}) : super(key: key);

  @override
  _MoodIntensityGaugeState createState() => _MoodIntensityGaugeState();
}

class _MoodIntensityGaugeState extends State<MoodIntensityGauge> {
  double _selectedLevel = 1; // Default at level 1

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SfRadialGauge(
          axes: <RadialAxis>[
            RadialAxis(
              minimum: 1,
              maximum: 5,
              interval: 1,
              showLabels: true,
              showTicks: true,
              axisLineStyle: const AxisLineStyle(thickness: 8),
              labelOffset: 15, // Adjust label distance
              tickOffset: 5,
              ranges: [
                GaugeRange(startValue: 1, endValue: 5, color: Colors.transparent),
              ],
              pointers: <GaugePointer>[
                // Dragging Pointer
                MarkerPointer(
                  value: _selectedLevel,
                  markerType: MarkerType.circle,
                  color: Colors.black,
                  enableDragging: true, // Enables dragging
                  onValueChanged: (value) {
                    setState(() {
                      _selectedLevel = value.round().toDouble(); // Round to whole number
                      widget.onIntensitySelected(_selectedLevel.toInt()); // Send selected value back
                    });
                  },
                ),
              ],
              annotations: <GaugeAnnotation>[
                for (int i = 1; i <= 5; i++)
                  GaugeAnnotation(
                    widget: Text(
                      "$i",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    angle: 180 - ((i - 1) * 45), // Adjust position
                    positionFactor: 1.2,
                  ),
              ],
            ),
          ],
        ),
        Text(
          "Selected Level: $_selectedLevel",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
