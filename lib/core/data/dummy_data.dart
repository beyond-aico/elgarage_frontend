import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Place {
  final String id;
  final String name;
  final String address;
  final String phone;
  final double rating;
  final IconData typeIcon;
  final String imageUrl; // سنستخدم ألوان أو صور افتراضية للآن

  Place({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.rating,
    required this.typeIcon,
    this.imageUrl = '',
  });
}

class DummyData {
  // 1. الكاوتش
  static List<Place> tires = [
    Place(id: 't1', name: "بريدجستون فيت & فيكس", address: "مدينة نصر - الحي السابع", phone: "19123", rating: 4.8, typeIcon: FontAwesomeIcons.circleNotch),
    Place(id: 't2', name: "ميشلان - النيل", address: "المعادي - شارع 9", phone: "0100200300", rating: 4.7, typeIcon: FontAwesomeIcons.circleNotch),
  ];

  // 2. البطاريات
  static List<Place> batteries = [
    Place(id: 'b1', name: "النسر للبطاريات", address: "وسط البلد - رمسيس", phone: "0122334455", rating: 4.5, typeIcon: FontAwesomeIcons.carBattery),
    Place(id: 'b2', name: "كلورايد إيجيبت", address: "الدقي - المساحة", phone: "19888", rating: 4.6, typeIcon: FontAwesomeIcons.carBattery),
  ];

  // 3. مراكز صيانة شاملة
  static List<Place> centers = [
    Place(id: 'c1', name: "المركز الألماني المعتمد", address: "جسر السويس - الحرفيين", phone: "0111222333", rating: 4.9, typeIcon: FontAwesomeIcons.screwdriverWrench),
    Place(id: 'c2', name: "أوتو فيكس (Auto Fix)", address: "الشيخ زايد - بيفرلي هيلز", phone: "0155556666", rating: 4.8, typeIcon: FontAwesomeIcons.screwdriverWrench),
  ];

  // 4. زيوت وصيانات بسيطة
  static List<Place> oils = [
    Place(id: 'o1', name: "شل أوتو كير", address: "محطة بنزين شل - الهرم", phone: "16666", rating: 4.7, typeIcon: FontAwesomeIcons.oilCan),
    Place(id: 'o2', name: "موبيل 1 سنتر", address: "التجمع الخامس - التسعين", phone: "15555", rating: 4.8, typeIcon: FontAwesomeIcons.oilCan),
  ];

  // 5. غسيل سيارات (القسم الجديد)
  static List<Place> washing = [
    Place(id: 'w1', name: "بابلز كار كير", address: "مدينتي - الكرافت زون", phone: "0109998887", rating: 4.9, typeIcon: FontAwesomeIcons.soap),
    Place(id: 'w2', name: "سبا كار (Spa Car)", address: "مصر الجديدة - الميرغني", phone: "0122222222", rating: 4.5, typeIcon: FontAwesomeIcons.soap),
  ];

  // بيانات الونش
  static Map<String, String> winchData = {
    "القاهرة - مدينة نصر": "ونش الإنقاذ السريع: 01012345678",
    "القاهرة - التجمع": "ونش محور المشير: 01112345678",
    "الجيزة - الهرم": "ونش الهرم والمريوطية: 01212345678",
    "الطريق الدائري": "طوارئ الدائري: 01512345678",
  };
}