// lib/features/representatives/data/datasources/representatives_remote_datasource.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/representative_model.dart';

abstract class RepresentativesRemoteDataSource {
  Future<List<RepresentativeModel>> getRepresentativesByLocation(double latitude, double longitude);
  Future<RepresentativeModel> getRepresentativeById(String id);
}

class RepresentativesRemoteDataSourceImpl implements RepresentativesRemoteDataSource {
  final http.Client client;
  final String baseUrl;

  RepresentativesRemoteDataSourceImpl({
    required this.client,
    required this.baseUrl,
  });

  @override
  Future<List<RepresentativeModel>> getRepresentativesByLocation(
    double latitude,
    double longitude,
  ) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/representatives?lat=$latitude&lng=$longitude'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => RepresentativeModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load representatives');
      }
    } catch (e) {
      throw Exception('Failed to connect to server');
    }
  }

  @override
  Future<RepresentativeModel> getRepresentativeById(String id) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/representatives/$id'),
      );

      if (response.statusCode == 200) {
        return RepresentativeModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load representative details');
      }
    } catch (e) {
      throw Exception('Failed to connect to server');
    }
  }
}