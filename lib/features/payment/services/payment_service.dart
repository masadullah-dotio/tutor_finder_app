import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tutor_finder_app/features/payment/data/models/payment_model.dart';

class PaymentService {
  final String _baseUrl = dotenv.env['API_BASE_URL'] ?? 'https://tutor-finder-api.vercel.app/api'; 
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createPaymentRecord(PaymentModel payment) async {
    try {
      await _firestore.collection('payments').doc(payment.id).set(payment.toMap());
    } catch (e) {
      throw Exception('Failed to save payment record: $e');
    }
  } 

  /// For web: Creates a Stripe Checkout session and returns the URL
  Future<String> createCheckoutSession({
    required double amount,
    required String currency,
    required String successUrl,
    required String cancelUrl,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/create-checkout-session/');
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': amount,
          'currency': currency,
          'success_url': successUrl,
          'cancel_url': cancelUrl,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to create checkout session: ${response.body}');
      }

      final jsonResponse = jsonDecode(response.body);
      return jsonResponse['url'] as String;
    } catch (e) {
      throw Exception('Error creating checkout session: $e');
    }
  }

  /// Opens Stripe Checkout in browser for web payments
  /// Returns the checkout URL (for web, we navigate in-page instead of external browser)
  Future<String> launchStripeCheckout({
    required double amount,
    required String currency,
    required String bookingId,
  }) async {
    // For web, use current URL as base
    final currentUrl = kIsWeb ? Uri.base.origin + '/' : 'https://tutorfinder.app/';
    final successUrl = '${currentUrl}payment-success?booking_id=$bookingId&session_id={CHECKOUT_SESSION_ID}';
    final cancelUrl = '${currentUrl}payment-cancelled?booking_id=$bookingId';
    
    final checkoutUrl = await createCheckoutSession(
      amount: amount,
      currency: currency,
      successUrl: successUrl,
      cancelUrl: cancelUrl,
    );
    
    // For web, redirect in the same window
    if (kIsWeb) {
      final uri = Uri.parse(checkoutUrl);
      await launchUrl(uri, webOnlyWindowName: '_self');
    } else {
      final uri = Uri.parse(checkoutUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Could not launch Stripe Checkout');
      }
    }
    
    return checkoutUrl;
  }

  Future<String> initPaymentSheet({
    required double amount,
    required String currency,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/create-payment-intent/');
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
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

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Tutor Finder',
          style: ThemeMode.system,
        ),
      );

      return clientSecret;
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

