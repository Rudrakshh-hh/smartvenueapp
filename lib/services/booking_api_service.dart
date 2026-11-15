import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/venue.dart';

/// Thrown when a booking cannot be saved. [message] is safe to show to the user.
class BookingException implements Exception {
  BookingException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Talks to the campusvenue-api  POST /api/bookings  endpoint.
class BookingApiService {
  BookingApiService._();

  /// Address of your Node API.
  ///  - Real Android phone : your PC's IPv4 address, e.g. 'http://192.168.1.5:3000'
  ///                         (phone and PC on the same Wi-Fi; run `ipconfig` to find it)
  ///  - Android emulator   : 'http://10.0.2.2:3000'
  ///  - Chrome / Windows   : 'http://localhost:3000'
  /// If your login code already has a base URL, reuse the same value here.
  static String baseUrl = 'http://192.168.29.7:3000'; // <-- CHANGE THIS

  /// Set this right after your login succeeds:
  ///     BookingApiService.authToken = tokenFromLoginResponse;
  /// and set it back to null on logout.
  static String? authToken;

  /// App venue (Venue.imdfRoomId)  ->  venue_id in the `venues` table.
  /// Add a line here whenever you add a bookable venue to the app.
  static const Map<String, int> venueIdByRoomId = {
    'cr101': 1,
    'cr107': 2,
    'cr113': 3,
    'cr114': 4,
    'cr115': 5,
    'cr116': 6,
    'cr117': 7,
    'cr123': 8,
    'lt106': 9,
    'lt124': 10,
    'lab102': 11,
    'room109': 12,
    'room121': 13,
  };

  static String _two(int n) => n.toString().padLeft(2, '0');

  /// Saves a booking. Returns normally on success, throws [BookingException]
  /// (with a readable message) on any problem, including "slot already taken".
  static Future<void> createBooking({
    required Venue venue,
    required DateTime date,
    required TimeOfDay start,
    required TimeOfDay end,
    required String purpose,
  }) async {
    final venueId = venueIdByRoomId[venue.imdfRoomId];
    if (venueId == null) {
      throw BookingException('${venue.name} is not linked to the database yet.');
    }
    final token = authToken;
    if (token == null || token.isEmpty) {
      throw BookingException('Please log in again to book a venue.');
    }

    final body = jsonEncode({
      'venueId': venueId,
      'purpose': purpose,
      'date': '${date.year}-${_two(date.month)}-${_two(date.day)}',
      'startTime': '${_two(start.hour)}:${_two(start.minute)}',
      'endTime': '${_two(end.hour)}:${_two(end.minute)}',
    });

    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/bookings'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: body,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 201 || response.statusCode == 200) return;

      // The API always answers errors as { "message": "..." }.
      String message = 'Could not save the booking (error ${response.statusCode}).';
      try {
        final data = jsonDecode(response.body);
        if (data is Map && data['message'] is String) {
          message = data['message'] as String;
        }
      } catch (_) {}
      throw BookingException(message);
    } on BookingException {
      rethrow;
    } on TimeoutException {
      throw BookingException('The server is not responding. Please try again.');
    } catch (_) {
      throw BookingException(
        'Could not reach the server. Check that the API is running and the address is correct.',
      );
    }
  }
}
