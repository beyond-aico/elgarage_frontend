library;

// تطبيع النصوص العربية
String _norm(String s) {
  var out = s.toLowerCase().trim();
  const alif = ['أ','إ','آ','ٱ'];
  for (final a in alif) { out = out.replaceAll(a, 'ا'); }
  out = out.replaceAll('ى', 'ي').replaceAll('ة', 'ه')
           .replaceAll('ؤ', 'و').replaceAll('ئ', 'ي').replaceAll('ـ', '');
  return out;
}

// هيكل نتيجة الكشف
class RouteMatch {
  final String? route;
  final String? reply; // الرد المقترح
  const RouteMatch({this.route, this.reply});
}

// خريطة التوجيه والردود الذكية
const Map<String, Map<String, dynamic>> _routeMap = {
  '/sos': {
    'keywords': ['نجدة','ونش','عطلان','الحقني','حادثة','اسعاف','شرطة','غرزت','sos','help','tow'],
    'reply': 'حالا يا هندسة، فتحتلك قسم الطوارئ حالاً عشان نطلب ونش, شوف ايه أقرب حاجة ليك.'
  },
  '/maintenance': {
    'keywords': ['صيانة','مركز','ورشة','ميكانيكي','عفشة','كهربائي','سمكري','فتيس','موتور','تصليح'],
    'reply': 'تمام يا باشا، ده قسم الإصلاحات فيه أفضل المراكز المتخصصة لعربيتك, شوف تقيماتهم و اختار اللي يريحك.'
  },
  '/tires': {
    'keywords': ['كاوتش','عجلة','نايمة','مخرومة','بنشر','لحام','بطارية','شحن','توصيلة','تغيير فردة'],
    'reply': 'تمام يا هندسة، فتحتلك قسم الكاوتش والبطاريات، شوف أقرب واحد ليك, و شوف بردو العروض اللي عندنا المتاحة.'
  },
  '/services': {
    'keywords': ['زيت','فلتر','مياه','تبريد','تيل','فرامل','صيانة دورية','بنزينة'],
    'reply': 'فتحتلك قسم الخدمات السريعة، عشان تظبط الزيت والفلاتر بسرعة شوف العروض الموجودة دلوقتي.'
  },
  '/care': {
    'keywords': ['غسيل','نظافة','تلميع','بوليش','مساحات','كار كير','زينة','كماليات','فاميه','فرش','سبويلر'],
    'reply': 'عشان عربيتك تنور، ده قسم العناية والكماليات يا هندسة قوللي بتفكر تغير ايه.'
  },
  '/garage': {
    'keywords': ['جراج','عربيتي','مواعيد','صياناتي'],
    'reply': 'ده جراجك يا هندسة، فيه كل تفاصيل ومواعيد صيانة عربيتك و انا معاك في اي سؤال او اقتراح.'
  },
  '/parts': { // قسم قطع الغيار الجديد
    'keywords': ['قطع غيار','قطعة','تيل','سير','بوجيهات','مساعدين','فانوس','اكصدام'],
    'reply': 'فتحتلك سوق قطع الغيار، هتلاقي كل اللي محتاجه أصلي ومضمون.'
  },
};

RouteMatch detectRouteIntent(String utterance) {
  final s = _norm(utterance);
  
  for (final entry in _routeMap.entries) {
    final route = entry.key;
    final data = entry.value;
    final keywords = data['keywords'] as List<String>;
    
    for (final kw in keywords) {
      if (s.contains(_norm(kw))) {
        return RouteMatch(route: route, reply: data['reply']);
      }
    }
  }
  return const RouteMatch(route: null, reply: null);
}