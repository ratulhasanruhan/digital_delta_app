import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'route_planner_section.dart';

/// Full-screen M4 routing (opened from dashboard or Drone tab).
class FullRoutePlannerPage extends StatelessWidget {
  const FullRoutePlannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Routes & hazards',
          style: GoogleFonts.dmSans(fontWeight: FontWeight.w700),
        ),
      ),
      body: const SingleChildScrollView(
        child: RoutePlannerSection(),
      ),
    );
  }
}
