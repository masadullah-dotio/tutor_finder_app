import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter/material.dart';

class PaymentService {
  // Production Vercel URL
  final String _baseUrl = 'https://tutor-finder-api.vercel.app/api'; 

  Future<void> initPaymentSheet({
    required double amount,
    required String currency,
  }) async {
    try {
      // 1. Call Django Server to get client secret
      final url = Uri.parse('$_baseUrl/create-payment-intent/');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'amount': amount,
          'currency': currency,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to create payment intent: ${response.body}');
      }

      final jsonResponse = jsonDecode(response.body);
      final clientSecret = jsonResponse['clientSecret'];

      // 2. Initialize Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Tutor Finder',
          style: ThemeMode.system,
        ),
      );
    } catch (e) {
      throw Exception('Error initializing payment sheet: $e');
    }
  }

  Future<void> presentPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet();
    } catch (e) {
      throw Exception('Error presenting payment sheet: $e');
    }
  }
}
