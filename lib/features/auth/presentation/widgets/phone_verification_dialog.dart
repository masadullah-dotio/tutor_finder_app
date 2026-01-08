import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tutor_finder_app/core/services/auth_service.dart';

class PhoneVerificationDialog extends StatefulWidget {
  final String? initialPhoneNumber;

  const PhoneVerificationDialog({super.key, this.initialPhoneNumber});

  @override
  State<PhoneVerificationDialog> createState() => _PhoneVerificationDialogState();
}

class _PhoneVerificationDialogState extends State<PhoneVerificationDialog> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final AuthService _authService = AuthService();

  String? _verificationId;
  bool _codeSent = false;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.initialPhoneNumber != null) {
      _phoneController.text = widget.initialPhoneNumber!;
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _sendCode() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final phone = _phoneController.text.trim();
      if (phone.isEmpty) throw 'Please enter a phone number';

      await _authService.startPhoneVerification(
        phoneNumber: phone,
        onCodeSent: (verificationId, resendToken) {
           if (mounted) {
             setState(() {
               _verificationId = verificationId;
               _codeSent = true;
               _isLoading = false;
             });
           }
        },
        onVerificationFailed: (e) {
          if (mounted) {
            setState(() {
              _error = e.message;
              _isLoading = false;
            });
          }
        },
        onAutoRetrievalTimeout: (verificationId) {
          if (mounted) {
             setState(() {
               _verificationId = verificationId;
             });
          }
        },
      );
    } catch (e) {
       if (mounted) {
         setState(() {
           _error = e.toString();
           _isLoading = false;
         });
       }
    }
  }

  void _verifyCode() async {
     setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      if (_verificationId == null) throw 'Verification ID missing';
      if (_otpController.text.isEmpty) throw 'Please enter the code';

      await _authService.verifyOTP(
        verificationId: _verificationId!,
        smsCode: _otpController.text.trim(),
      );
      
      if (mounted) {
        Navigator.of(context).pop(true); // Return true on success
      }
    } catch (e) {
      if (mounted) {
         setState(() {
           _error = e.toString();
           _isLoading = false;
         });
       }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        _codeSent ? 'Enter SMS Code' : 'Verify Phone Number',
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_error != null)
               Container(
                 padding: const EdgeInsets.all(12),
                 margin: const EdgeInsets.only(bottom: 16),
                 decoration: BoxDecoration(
                   color: Colors.red.withOpacity(0.1),
                   borderRadius: BorderRadius.circular(8),
                   border: Border.all(color: Colors.red.withOpacity(0.3)),
                 ),
                 child: Row(
                   children: [
                     const Icon(Icons.error_outline, size: 20, color: Colors.red),
                     const SizedBox(width: 8),
                     Expanded(
                       child: Text(
                         _error!, 
                         style: const TextStyle(color: Colors.red, fontSize: 13),
                       ),
                     ),
                   ],
                 ),
               ),
            
            Text(
              _codeSent 
                  ? 'We have sent a 6-digit code to ${_phoneController.text}' 
                  : 'Enter your mobile number to receive a verification code.',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            if (!_codeSent)
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  hintText: '+1 234 567 8900',
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              )
            else 
               TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                autofocus: true,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '000000',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton(
                onPressed: _isLoading 
                  ? null 
                  : (_codeSent ? _verifyCode : _sendCode),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: _isLoading 
                   ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                   : Text(_codeSent ? 'Verify' : 'Send Code'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
