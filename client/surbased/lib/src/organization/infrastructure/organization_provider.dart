import 'package:flutter/material.dart';
import 'package:surbased/src/organization/domain/organization_model.dart';
import 'package:surbased/src/organization/infrastructure/organization_service.dart';

class OrganizationProvider with ChangeNotifier {
  final _organizationService = OrganizationService();
  String? _error;
  bool _isLoading = false;
  Organization? _organization;

  bool get isLoading => _isLoading;
  String? get error => _error;
  Organization? get organization => _organization;

  Future<void> getOrganizationById(String id, String token) async {
    _error = null;
    _isLoading = true;
    notifyListeners();

    try {
      final getOrganizationResponse =
          await _organizationService.getOrganizationById(id, token);

      if (getOrganizationResponse['success']) {
        _organization = Organization.fromJson(getOrganizationResponse['data']);
        _error = null;
        _isLoading = false;
        notifyListeners();
      } else {
        _error = getOrganizationResponse['data'];
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}
