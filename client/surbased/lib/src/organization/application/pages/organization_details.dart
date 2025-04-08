import 'package:flutter/material.dart';
import 'package:surbased/src/organization/application/widgets/organization_section.dart';

class OrganizationDetails extends StatelessWidget {
  const OrganizationDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: OrganizationSection(),
    );
  }
}
