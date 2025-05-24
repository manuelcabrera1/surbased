import 'package:flutter/material.dart';
import 'package:surbased/src/organization/domain/organization_model.dart';
import 'package:surbased/src/organization/infrastructure/organization_service.dart';
import 'package:surbased/src/user/domain/user_model.dart';

import '../../../survey/domain/survey_model.dart';

class OrganizationProvider with ChangeNotifier {
  final _organizationService = OrganizationService();
  String? _error;
  bool _isLoading = false;
  Organization? _organization;
  Organization? _selectedOrganization;
  List<Organization> _organizations = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  Organization? get organization => _organization;
  List<Organization> get organizations => _organizations;
  Organization? get selectedOrganization => _selectedOrganization;

  set selectedOrganization(Organization? organization) {
    _selectedOrganization = organization;
    notifyListeners();
  }

  set organization(Organization? organization) {
    _organization = organization;
    notifyListeners();
  }

  void clearState() {
    _organization = null;
    _selectedOrganization = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createOrganization(String name, String token) async {
    _error = null;
    _isLoading = true;
    notifyListeners();

    try {
      final createOrganizationResponse = await _organizationService.createOrganization(name, token);

      if (createOrganizationResponse['success']) {
        _organizations.add(Organization.fromJson(createOrganizationResponse['data']));
        _error = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = createOrganizationResponse['data'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> getOrganizations(String token) async {
    _error = null;
    _isLoading = true;
    notifyListeners();

    try {
      final getOrganizationsResponse = await _organizationService.getOrganizations(token);

      if (getOrganizationsResponse['success']) {
        _organizations = (getOrganizationsResponse['data']['organizations'] as List<dynamic>)
        .map((organization) => Organization.fromJson(organization))
        .toList();

        _error = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {  
        _error = getOrganizationsResponse['data'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch(e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }

  }

  String getOrganizationName(String id) {
    if (_organizations.isEmpty && _organization == null) {
      return '';
    }
    if (_organizations.isNotEmpty) {
      return _organizations.firstWhere((organization) => organization.id == id, orElse: () => Organization(id: '', name: '')).name;
    }
    return _organization!.name;
  }

  Future<Organization?> getOrganizationById(String id, String token) async {
    _error = null;
    _isLoading = true;
    notifyListeners();

    try {
      final getOrganizationResponse =
          await _organizationService.getOrganizationById(id, token);

      if (getOrganizationResponse['success']) {
        final organization = Organization.fromJson(getOrganizationResponse['data']);
        _error = null;
        _isLoading = false;
        notifyListeners();
        return organization;
      } else {
        _error = getOrganizationResponse['data'];
        _isLoading = false;
        notifyListeners();
        return null;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<void> getCurrentOrganization(String id, String token) async {
    _error = null;
    _isLoading = true;
    notifyListeners();

    try {
      final organization = await getOrganizationById(id, token);

      if (organization != null) {
        _organization = organization;
        _error = null;
        _isLoading = false;
        notifyListeners();
      } else {
        _error = 'Error getting organization';
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getUsersInOrganization(String token,
      {String? sortBy, String? order, String? organizationId, bool? isCurrentOrganization = true}) async {
    _error = null;
    _isLoading = true;
    notifyListeners();
    try {
      late Map<String, dynamic> getUsersResponse;

      getUsersResponse = await _organizationService
          .getUsersInCurrentOrganization(token, organizationId ?? _organization!.id,
              sortBy: sortBy, order: order);

      if (getUsersResponse['success']) {
        final users =
            (getUsersResponse['data']['users'] as List<dynamic>)
                .map((user) => User.fromJson(user))
                .toList();
        if (isCurrentOrganization!) {
            _organization!.users = users;
        } else {
          _selectedOrganization!.users = users;
        }

        _isLoading = false;
        _error = null;
        notifyListeners();
      } else {
        _isLoading = false;
        _error = getUsersResponse['data'];
        notifyListeners();
      }
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> getSurveysInOrganization(String token, {String? category, String? organizationId, bool? isCurrentOrganization = true}) async {
    _error = null;
    _isLoading = true;
    notifyListeners();
    try {
      final getSurveysResponse = await _organizationService
          .getSurveysInOrganization(organizationId ?? _organization!.id, token, category: category);

      if (getSurveysResponse['success']) {
        final surveys =
            (getSurveysResponse['data']['surveys'] as List<dynamic>)
                .map((survey) => Survey.fromJson(survey))
                .toList();

        isCurrentOrganization!
        ?_organization!.surveys = surveys
        : _selectedOrganization!.surveys = surveys;

        _isLoading = false;
        _error = null;
        notifyListeners();
      } else {
        _isLoading = false;
        _error = getSurveysResponse['data'];
        notifyListeners();
      }
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> updateOrganization(String id, String name, String token) async {
    _error = null;
    _isLoading = true;
    notifyListeners();

    try {

      final updateOrganizationResponse = await _organizationService.updateOrganization(id, name, token);

      if (updateOrganizationResponse['success']) {
        _error = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = updateOrganizationResponse['data'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }

  }

  Future<bool> deleteOrganization(String id, String token) async {
    _error = null;
    _isLoading = true;
    notifyListeners();
    try {

      final deleteOrganizationResponse = await _organizationService.deleteOrganization(id, token);
      print(deleteOrganizationResponse);

      if (deleteOrganizationResponse['success']) {
        _error = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = deleteOrganizationResponse['data'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }

  }
}
