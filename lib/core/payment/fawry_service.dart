import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

class FawryService {
  // ---------------------------------------------------------
  // 🛑 مكان المفاتيح (هنغيرهم لما يوصلك الإيميل)
  // ---------------------------------------------------------
  static const String merchantCode = "1tSa6uxz2nTQKQ=="; 
  static const String secureKey = "2465456456456456456"; 
  static const String baseUrl = "https://atfawry.fawrystaging.com"; 

  static String _generateSignature({
    required String merchantCode,
    required String merchantRefNum,
    required String customerProfileId,
    required String itemId,
    required String quantity,
    required String price,
    required String secureKey,
    required String returnUrl,
  }) {
    String rawString = 
        "$merchantCode$merchantRefNum$customerProfileId$returnUrl$itemId$quantity$price$secureKey";

    var bytes = utf8.encode(rawString);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  static Future<void> initiatePayment({
    required BuildContext context,
    required double amount,
    required String userId,
    required String userMobile,
    required String userEmail,
  }) async {
    try {
      String merchantRefNum = DateTime.now().millisecondsSinceEpoch.toString(); 
      String returnUrl = "https://automentor.com/callback"; 
      
      String signature = _generateSignature(
        merchantCode: merchantCode,
        merchantRefNum: merchantRefNum,
        customerProfileId: userId,
        itemId: "ITEM_1",
        quantity: "1",
        price: amount.toStringAsFixed(2),
        secureKey: secureKey,
        returnUrl: returnUrl,
      );

      Map<String, dynamic> body = {
        "merchantCode": merchantCode,
        "merchantRefNum": merchantRefNum,
        "customerProfileId": userId,
        "customerMobile": userMobile,
        "customerEmail": userEmail,
        "language": "ar-eg",
        "chargeItems": [
          {
            "itemId": "ITEM_1",
            "description": "Auto Mentor Service",
            "price": amount.toStringAsFixed(2),
            "quantity": "1"
          }
        ],
        "returnUrl": returnUrl,
        "authCaptureMode": false,
        "signature": signature,
        "paymentMethod": "PayAtFawry,CreditCard,Wallet" 
      };

      print("⏳ Sending request to Fawry...");
      final response = await http.post(
        Uri.parse("$baseUrl/ECommerceWeb/Fawry/payments/charge"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      print("📡 Status Code: ${response.statusCode}");
      print("📡 Body: ${response.body}");

      if (response.statusCode == 200) {
         String urlToLaunch = response.body;
         
         // التعديل هنا: استخدام المتغير لطباعته وحل التحذير
         if(response.body.trim().startsWith("{")) {
            final jsonResponse = jsonDecode(response.body);
            print("✅ Fawry JSON Response: $jsonResponse"); // تم استخدام المتغير هنا
         }

         if (urlToLaunch.startsWith("http")) {
            final Uri url = Uri.parse(urlToLaunch);
            await launchUrl(url, mode: LaunchMode.externalApplication);
         } else {
             // لو الرد مش رابط مباشر، غالباً هيكون JSON فيه رسالة خطأ أو تفاصيل
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("الرد: ${response.body}")));
         }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("خطأ من فوري: ${response.body}")));
      }
    } catch (e) {
      print("❌ Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("حدث خطأ في التطبيق: $e")));
    }
  }
}