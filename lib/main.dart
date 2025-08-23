import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'loginsignup.dart';
import 'resource.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'l10n/app_localizations.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:string_similarity/string_similarity.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

void main() async {
  String fcmtoken = "";
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  WidgetsFlutterBinding.ensureInitialized();
  // await initNotifications();
  // 🧠 Request notification permission for Android 13+
  if (Platform.isAndroid) {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  Future<void> saveFcmToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      print("FCM Token: $token");
      print(
        ". .................................................................................",
      );

      // Send this token to your Django backend
      //await sendTokenToBackend(token);
    }
  }

  saveFcmToken();
  try {
    final tokenResponse = await http.post(
      Uri.parse('http://13.203.219.206:8000/postsportsnotificationtoken/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        // 'username': Provider.of<resource>(context, listen: false).PresentWorkingUser,
        'username': '', // TODO: Set username after context is available
        'device_token': fcmtoken,
      }),
    );

    if (tokenResponse.statusCode == 201) {
      print("✅ FCM token successfully sent to Django.");
    } else {
      print("❌ Failed to send FCM token: ${tokenResponse.statusCode}");
    }
  } catch (e) {
    print("Error sending FCM token: $e");
  }

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => resource())],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(newLocale);
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: _locale,
      supportedLocales: [
        Locale('en'), // English
        Locale('hi'), // Hindi
        Locale('te'), // Telugu
      ],
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: AboutUsPage2(),
    );
  }
}

class HealthTechApp extends StatelessWidget {
  const HealthTechApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HealthLock',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.teal, useMaterial3: true),
      home: const AboutUsPage2(),
    );
  }
}

class CropsViewScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text("Crops")),
    body: Center(child: Text("Crops View")),
  );
}

class EquipmentViewScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text("Equipment")),
    body: Center(child: Text("Equipment View")),
  );
}

class ProduceFAQScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text("Produce FAQ")),
    body: Center(child: Text("Produce Info")),
  );
}

class AboutUsPage2 extends StatefulWidget {
  const AboutUsPage2({super.key}); // ✅ Keep const here

  @override
  State<AboutUsPage2> createState() => _AboutUsPage2State();
}

class _AboutUsPage2State extends State<AboutUsPage2> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();
  bool isListening = false;
  late String ttsLang;

  final Map<String, Map<String, String>> faqDataset = {
    "en": {
      "Hi": "Hello! How can I help you today?",
      "Good morning": "Good morning! Hope you have a better health",
      "Who are you":
          "I am your voice assistant, here to help with your queries.",
      "Your name": "I'm HealthBot, your smart health Tracking guide.",
      "What is organic farming":
          "Organic farming avoids synthetic chemicals and uses natural methods for growing crops.",
      "How to grow tomatoes":
          "Tomatoes grow best in well-drained soil with full sun exposure and regular watering.",
      "What is drip irrigation":
          "Drip irrigation delivers water directly to plant roots, reducing water usage and improving efficiency.",
      "What is precision agriculture":
          "Precision agriculture uses technology to optimize field-level management regarding crop farming.",
      "What is vermicomposting":
          "Vermicomposting is the process of using earthworms to convert organic waste into nutrient-rich compost.",
      "How to protect crops from pests":
          "Use integrated pest management methods like neem oil, crop rotation, and natural predators.",
      "How to test soil fertility":
          "Use a soil testing kit or send a sample to a local agriculture lab.",
      "What crops grow in summer":
          "Crops like maize, sorghum, and millets are well-suited for summer.",
      "What's the weather today":
          "I'm not connected to the internet right now, but usually you can check a weather app.",

      "What is organic farming?":
          "Organic farming is a method of farming that avoids synthetic chemicals and emphasizes natural processes.",
      "How to improve soil fertility?":
          "Add organic matter like compost, practice crop rotation, and use cover crops.",
      "What is crop rotation?":
          "Crop rotation is the practice of growing different types of crops in the same area in sequential seasons.",
      "What are common pests in rice farming?":
          "Stem borers, leaf folders, and brown plant hoppers are common pests in rice farming.",
      "How to conserve water in farming?":
          "Use drip irrigation, rainwater harvesting, and soil mulching.",
      "What is greenhouse farming?":
          "Greenhouse farming involves growing crops under controlled environmental conditions.",
      "What is the best time to sow wheat?":
          "In India, wheat is best sown in November during the Rabi season.",
      "How to prevent plant diseases?":
          "Use resistant varieties, proper spacing, and organic fungicides.",
      "What are biofertilizers?":
          "Biofertilizers are natural fertilizers that contain living microorganisms.",
      "How to store harvested grains safely?":
          "Keep grains dry, use airtight containers, and monitor for pests.",
      "What is hydroponics?":
          "Hydroponics is a method of growing plants in nutrient-rich water without soil.",
      "How to start a poultry farm?":
          "Choose a suitable location, good breed, provide clean water and balanced feed.",
      "What is integrated farming system?":
          "It combines crop production with livestock, fisheries, and poultry to optimize resources.",
      "How can I start beekeeping?":
          "Get bee boxes, place them near flowers, and follow local guidelines.",
      "How to check soil pH?":
          "Use a soil pH meter or testing kit available at agri stores.",
      "What’s your name?": "I’m AgriBot, your voice assistant for farming.",
      "Who made you?": "I was developed to help farmers with their queries.",
      "How can you help me?":
          "I can answer farming questions, provide tips, and more.",
      "Tell me a joke":
          "Why did the scarecrow win an award? Because he was outstanding in his field!",
      "What is AI?":
          "AI stands for Artificial Intelligence, simulating human intelligence in machines.",
      "What is climate change?":
          "Climate change refers to long-term changes in temperature and weather patterns.",
      "What is sustainable farming?":
          "Sustainable farming uses practices that maintain soil health, conserve resources, and ensure long-term productivity.",
      "How to grow rice?":
          "Rice needs flooded fields, fertile soil, and warm temperatures; transplant seedlings for best results.",
      "What is mulching?":
          "Mulching involves covering soil with organic or synthetic materials to retain moisture and suppress weeds.",
      "How to identify nutrient deficiencies in plants?":
          "Look for symptoms like yellow leaves (nitrogen deficiency) or stunted growth (phosphorus deficiency).",
      "What is companion planting?":
          "Companion planting involves growing different crops together to enhance growth or deter pests.",
      "How to start a small vegetable garden?":
          "Choose a sunny spot, prepare fertile soil, and plant seasonal vegetables with regular care.",
      "What is soil erosion?":
          "Soil erosion is the loss of topsoil due to wind, water, or human activity, reducing fertility.",
      "How to use natural fertilizers?":
          "Apply compost, manure, or green manure to enrich soil with nutrients naturally.",
      "What crops grow in winter?":
          "Winter crops include wheat, mustard, and peas, thriving in cooler temperatures.",
      "How to manage weeds?":
          "Use mulching, hand weeding, or organic herbicides to control weeds effectively.",
      "What is aquaponics?":
          "Aquaponics combines fish farming with hydroponics, using fish waste to nourish plants.",
      "How to improve crop yield?":
          "Use quality seeds, maintain soil health, and adopt precision farming techniques.",
      "What is a cover crop?":
          "Cover crops like clover or rye are grown to protect soil and improve its fertility.",
      "How to start organic farming?":
          "Avoid synthetic chemicals, use organic fertilizers, and certify your farm with local authorities.",
      "What is crop diversification?":
          "Crop diversification involves growing a variety of crops to reduce risk and improve soil health.",
      "How to deal with fungal diseases in plants?":
          "Use organic fungicides, ensure proper air circulation, and remove affected plant parts.",
      "What is the role of pollinators in farming?":
          "Pollinators like bees transfer pollen, aiding crop reproduction and increasing yields.",
      "How to store seeds properly?":
          "Store seeds in a cool, dry place in airtight containers to maintain viability.",
      "What is agroforestry?":
          "Agroforestry integrates trees with crops or livestock to enhance productivity and biodiversity.",
      "Can you tell me about drip irrigation benefits?":
          "Drip irrigation saves water, reduces weeds, and delivers nutrients directly to plant roots.",
      "Hello": "Hi there! Ready to assist you with your queries.",
      "Who are you?": "I'm AgriBot, your farming-friendly voice assistant.",
      "What is your name?":
          "My name's AgriBot, here to help with farming tips.",
      "How are you?": "Doing great, thanks! How about you?",
      "What can you do?":
          "I can answer farming questions, share tips, and chat with you.",
      "Good evening": "Good evening! Hope your day went well.",
      "How's the day going?": "My day's full of learning! How's yours?",
      "What is a voice assistant?":
          "A voice assistant is a digital helper that responds to voice commands.",
      "Who created you?":
          "I was built by a team to support farmers and answer queries.",
      "Tell me something interesting":
          "Did you know earthworms improve soil health naturally?",
      "What's the time?":
          "I can't check the time right now, but your clock can help!",
      "Can you tell a joke?":
          "Why did the cow become a speaker? It had a lot to moo about!",
      "What is farming?":
          "Farming is growing crops or raising animals for food and resources.",
      "Thank you": "You're welcome! Always here for you.",
      "How do you work?":
          "I listen to your questions and provide answers using my knowledge base.",
      "Good night": "Good night! Dream of healthy crops and happy farms.",
      "What is technology?":
          "Technology is the use of tools and systems to solve problems or improve life.",
      "Can you sing?": "I can't sing, but I can tell you about crop cycles!",
      "Goodbye": "See you later! Happy farming!",
      "Hi there": "Hello! I'm here to assist with your questions.",
      "Good afternoon": "Good afternoon! Hope your day is going well.",
      "What's your purpose?":
          "I'm AgriBot, designed to help farmers with advice and answers.",
      "Who is AgriBot?": "That's me! Your friendly farming voice assistant.",
      "Are you okay?": "I'm running smoothly, ready to help you out!",
      "What do you know about?":
          "I know about farming, weather tips, and general knowledge.",
      "How's it going?": "All good here! How's your farm doing?",
      "What is a chatbot?":
          "A chatbot is a program that chats with users, like me helping farmers!",
      "Who designed you?":
          "A team of innovators built me to support agriculture.",
      "Tell me something new":
          "Did you know crop diversity can boost soil health?",
      "What's the date today?":
          "It's July 8, 2025. Perfect day for farming plans!",
      "Can you tell a funny story?":
          "Once, a potato tried to join a vegetable choir but kept rolling off the stage!",
      "What is agriculture?":
          "Agriculture is the practice of cultivating crops and raising livestock.",
      "You're welcome": "Thanks for the kind words! I'm here for you.",
      "How do I use you?":
          "Just ASK me questions, and I'll respond with helpful answers.",
      "Have a great day": "Thanks! Wishing you a fruitful day on the farm.",
      "What is innovation?":
          "Innovation is creating new ideas or methods, like smart farming tools.",
      "Can you tell a fun fact?":
          "Bees can pollinate up to 5,000 flowers in a single day!",
      "What’s your favorite thing to do?":
          "I love helping farmers grow better crops!",
      "See you later": "Catch you later! Keep those fields thriving.",
      "Hey there": "Hi! I'm ready to help you with your questions.",
      "Good day": "Good day to you! Hope your farm is thriving.",
      "What are you?":
          "I'm AgriBot, a voice assistant for farmers and curious minds.",
      "Your identity?": "I'm AgriBot, your go-to for farming advice and chats.",
      "Feeling good?": "I'm buzzing like a busy bee! How about you?",
      "What’s your role?":
          "I answer questions, share farming tips, and keep you company.",
      "Nice to meet you": "Great to meet you too! Ready for some farming talk?",
      "What is an AI assistant?":
          "An AI assistant is a smart program that helps with tasks via voice or text.",
      "Who built you?":
          "A team passionate about agriculture created me to assist you.",
      "Share a cool fact":
          "Did you know healthy soil can store more carbon than the air?",
      "What’s today’s date?":
          "It’s July 8, 2025, at 9:48 PM IST. Time to plan your crops!",
      "Tell a silly joke":
          "Why did the carrot blush? It overheard the peas talking about their stew!",
      "What’s cultivation?":
          "Cultivation is preparing land and growing crops for food or resources.",
      "Appreciate it": "My pleasure! Always here to lend a hand.",
      "How can I interact with you?":
          "Just ask me anything, and I’ll reply with helpful info.",
      "Take care": "Thanks! Wishing you bountiful harvests ahead.",
      "What is automation?":
          "Automation uses technology to perform tasks, like irrigation systems in farming.",
      "Got any trivia?": "A single sunflower can produce up to 2,000 seeds!",
      "What do you like?":
          "I enjoy helping you nurture your crops and learn new tricks!",
      "Till next time": "Bye for now! Keep those fields green and growing.",
      "Hey": "Hello! I'm here to assist with your questions.",
      "What is your purpose?":
          "I'm AgriBot, designed to help farmers with advice and answers.",
      "What do you know?":
          "I know about farming, weather tips, and general knowledge.",
      "How's everything going?": "All good here! How's your farm doing?",
      "What’s the date today?":
          "It's July 8, 2025. Perfect day for farming plans!",
      "exit": "have a Good day and keep your fields thriving!",
      "Exit": "have a Good day and keep your fields thriving!",
      "bye": "have a Good day and keep your fields thriving!",
      "Bye": "have a Good day and keep your fields thriving!",
      "Close": "have a Good day and keep your fields thriving!",
    },
    "hi": {
      "नमस्ते": "नमस्ते! मैं आपकी मदद कैसे कर सकता हूँ?",
      "हेलो": "हाय! मैं आपके सवालों के लिए तैयार हूँ।",
      "आप क्या हैं?":
          "मैं एग्रीबॉट हूँ, किसानों और जिज्ञासुओं के लिए एक वॉयस असिस्टेंट।",
      "आपकी पहचान?": "मैं एग्रीबॉट, कृषि सलाह और बातचीत के लिए आपका साथी।",
      "अच्छा महसूस कर रहे हैं?":
          "मैं मधुमक्खी की तरह चहक रहा हूँ! आप कैसे हैं?",
      "आपकी भूमिका क्या है?":
          "मैं सवालों के जवाब देता हूँ, खेती के सुझाव देता हूँ और साथ देता हूँ।",
      "आपसे मिलकर अच्छा लगा":
          "आपसे मिलकर भी खुशी हुई! खेती की बातें करने को तैयार?",
      "एआई असिस्टेंट क्या है?":
          "एआई असिस्टेंट एक स्मार्ट प्रोग्राम है जो आवाज या टेक्स्ट से मदद करता है।",
      "एक शानदार तथ्य बताएं":
          "क्या आप जानते हैं कि स्वस्थ मिट्टी हवा से ज्यादा कार्बन स्टोर कर सकती है?",
      "मज़ेदार चुटकुला सुनाएं":
          "मूली क्यों शरमाई? उसने मटर की स्टू की बात सुनी!",
      "शुक्रिया": "मेरा सौभाग्य! हमेशा मदद के लिए हूँ।",
      "आपके साथ कैसे बात करूँ?":
          "मुझसे कुछ भी पूछें, मैं उपयोगी जानकारी दूँगा।",
      "ध्यान रखें": "शुक्रिया! आपके लिए ढेर सारी फसल की कामना।",
      "ऑटोमेशन क्या है?":
          "ऑटोमेशन तकनीक से कार्य करने की प्रक्रिया है, जैसे खेती में सिंचाई सिस्टम।",
      "कोई ट्रिविया बताएं?": "एक सूरजमुखी 2,000 तक बीज पैदा कर सकता है!",
      "फिर मिलेंगे": "अब के लिए अलविदा! अपने खेतों को हरा-भरा रखें।",
      "हाय": "नमस्ते! मैं आपके सवालों की मदद के लिए हूँ।",
      "शुभ दोपहर": "शुभ दोपहर! आपका दिन अच्छा चल रहा है, आशा है।",
      "आपका उद्देश्य क्या है?":
          "मैं एग्रीबॉट हूँ, किसानों की सलाह और जवाबों के लिए बनाया गया।",
      "एग्रीबॉट कौन है?": "वह मैं हूँ! आपका कृषि सहायक।",
      "क्या आप ठीक हैं?": "मैं पूरी तरह ठीक हूँ, आपकी मदद के लिए तैयार!",
      "आपको क्या पता है?": "मुझे खेती, मौसम सुझाव और सामान्य ज्ञान पता है।",
      "सब कैसा चल रहा है?": "यहाँ सब ठीक है! आपका खेत कैसा है?",
      "चैटबॉट क्या है?":
          "चैटबॉट एक प्रोग्राम है जो उपयोगकर्ताओं से बात करता है, जैसे मैं किसानों से।",
      "आपको किसने डिज़ाइन किया?":
          "मुझे कृषि सहायता के लिए नवप्रवर्तकों की एक टीम ने बनाया।",
      "कुछ नया बताएं":
          "क्या आप जानते हैं कि फसल विविधता मिट्टी को बेहतर बनाती है?",
      "आज की तारीख क्या है?":
          "आज 8 जुलाई 2025 है। खेती की योजना के लिए बढ़िया दिन!",
      "मज़ेदार कहानी सुनाएं":
          "एक बार एक आलू ने सब्जी गायन मंडली में शामिल होने की कोशिश की, लेकिन मंच से लुढ़क गया!",
      "कृषि क्या है?": "कृषि फसल उगाने और पशु पालने की प्रक्रिया है।",
      "आपका स्वागत है": "धन्यवाद! मैं आपके लिए हूँ।",
      "आपको कैसे उपयोग करें?": "बस मुझसे सवाल पूछें, मैं उपयोगी जवाब दूंगा।",
      "शुभ दिन": "धन्यवाद! आपके खेत के लिए शुभकामनाएँ।",
      "नवाचार क्या है?":
          "नवाचार नए विचारों या विधियों का निर्माण है, जैसे स्मार्ट खेती के उपकरण।",
      "मज़ेदार तथ्य बताएं":
          "मधुमक्खियाँ एक दिन में 5,000 फूलों का परागण कर सकती हैं!",
      "आपको क्या पसंद है?":
          "मुझे किसानों को बेहतर फसल उगाने में मदद करना पसंद है!",
      "फिर मिलते हैं": "बाद में मिलेंगे! अपने खेतों को हरा-भरा रखें।",
      "हाय वहाँ": "नमस्ते! मैं आपके सवालों की मदद के लिए यहाँ हूँ।",
      "सुप्रभात": "सुप्रभात! आशा है आपका दिन शुभ और उत्पादक हो।",
      "तुम कौन हो":
          "मैं आपका कृषि सहायक हूँ, जो आपके सवालों के जवाब देने में सक्षम है।",
      "आपका नाम क्या है":
          "मेरा नाम एग्रीबॉट है। मैं आपकी कृषि जानकारी में मदद करता हूँ।",
      "जैविक खेती क्या है":
          "जैविक खेती रासायनिक उर्वरकों के बिना प्राकृतिक तरीकों से की जाती है।",
      "टमाटर कैसे उगाएं":
          "टमाटर को अच्छी जल निकासी वाली मिट्टी और भरपूर धूप की आवश्यकता होती है।",
      "ड्रिप सिंचाई क्या है":
          "ड्रिप सिंचाई में पौधों की जड़ों में सीधे पानी दिया जाता है, जिससे पानी की बचत होती है।",
      "सटीक खेती क्या है":
          "सटीक खेती तकनीक का उपयोग करके फसलों का प्रबंधन और उत्पादन बढ़ाने की विधि है।",
      "वर्मी कम्पोस्टिंग क्या है":
          "यह एक प्रक्रिया है जिसमें केंचुओं का उपयोग करके कचरे को खाद में बदला जाता है।",
      "कीटों से फसलों की रक्षा कैसे करें":
          "नीम तेल, फसल चक्र और प्राकृतिक दुश्मनों का उपयोग करें।",
      "मिट्टी की उर्वरता कैसे जांचें":
          "मिट्टी परीक्षण किट का उपयोग करें या नजदीकी प्रयोगशाला में भेजें।",
      "गर्मियों में कौन सी फसलें उगती हैं":
          "गर्मी में मक्का, बाजरा और ज्वार जैसी फसलें अच्छी होती हैं।",
      "एक मज़ेदार चुटकुला सुनाओ":
          "टमाटर क्यों लाल हो गया? क्योंकि उसने सलाद को बदलते हुए देख लिया!",
      "आज मौसम कैसा है": "मैं ऑफलाइन हूँ, कृपया मौसम ऐप से जानकारी लें।",
      "धन्यवाद": "आपका स्वागत है! खुशहाल खेती करें!",
      "अलविदा": "ख्याल रखना! फिर मिलते हैं।",
      "जैविक खेती क्या है?":
          "जैविक खेती एक ऐसी विधि है जिसमें रासायनिक उर्वरकों का प्रयोग नहीं किया जाता।",
      "मिट्टी की उर्वरता कैसे बढ़ाएं?":
          "कम्पोस्ट डालें, फसल चक्र अपनाएं और हरी खाद का उपयोग करें।",
      "फसल चक्र क्या है?":
          "फसल चक्र एक ही खेत में अलग-अलग मौसम में अलग फसलें उगाने की प्रक्रिया है।",
      "धान की फसल में आम कीट कौन से हैं?":
          "तना छेदक, पत्ती मोड़ने वाले कीट और ब्राउन प्लांट होपर आम हैं।",
      "कृषि में पानी कैसे बचाएं?":
          "ड्रिप सिंचाई, वर्षा जल संचयन और मल्चिंग अपनाएं।",
      "ग्रीनहाउस कृषि क्या है?":
          "नियंत्रित वातावरण में फसलों को उगाना ग्रीनहाउस कृषि कहलाता है।",
      "गेहूं की बुवाई का सबसे अच्छा समय क्या है?":
          "भारत में नवंबर का महीना रबी सीजन के लिए उपयुक्त है।",
      "पौधों के रोगों से कैसे बचाएं?":
          "रोग प्रतिरोधी किस्में, उचित दूरी और जैविक दवाओं का उपयोग करें।",
      "जैव उर्वरक क्या हैं?":
          "ऐसे उर्वरक जिनमें जीवाणु होते हैं और मिट्टी की उर्वरता बढ़ाते हैं।",
      "अनाज को कैसे सुरक्षित रखें?":
          "अनाज को सूखा रखें, एयरटाइट कंटेनर में रखें और कीटों की निगरानी करें।",
      "हाइड्रोपोनिक्स क्या है?":
          "मिट्टी के बिना पोषक जल में पौधों को उगाने की तकनीक।",
      "पोल्ट्री फार्म कैसे शुरू करें?":
          "स्थान चुनें, नस्ल तय करें, साफ पानी और संतुलित आहार दें।",
      "एकीकृत कृषि प्रणाली क्या है?":
          "फसल, पशुपालन, मछली पालन आदि को मिलाकर की गई खेती।",
      "मधुमक्खी पालन कैसे शुरू करें?":
          "मधुमक्खी बक्से खरीदें और फूलों के पास रखें।",
      "मिट्टी का पीएच कैसे जांचें?": "पीएच मीटर या किट का प्रयोग करें।",
      "आपका नाम क्या है?": "मैं एग्रीबॉट हूँ, आपका कृषि सहायक।",
      "आप कैसे हैं?": "मैं ठीक हूँ और आपकी मदद के लिए तैयार हूँ।",
      "आपको किसने बनाया?": "मुझे किसानों की सहायता के लिए बनाया गया है।",
      "आप मेरी कैसे मदद कर सकते हैं?":
          "मैं आपके कृषि सवालों का उत्तर दे सकता हूँ।",
      "एक मज़ेदार चुटकुला सुनाएं":
          "क्यों टमाटर शर्मिंदा हो गया? क्योंकि उसने सलाद को कपड़े बदलते देख लिया!",
      "AI क्या है?":
          "AI का मतलब आर्टिफिशियल इंटेलिजेंस है, जिसमें मशीनें इंसानों की तरह सोचती हैं।",
      "जलवायु परिवर्तन क्या है?":
          "लंबे समय में तापमान और मौसम के पैटर्न में बदलाव।",
      "टिकाऊ खेती क्या है?":
          "टिकाऊ खेती ऐसी प्रथाओं का उपयोग करती है जो मिट्टी को स्वस्थ रखती हैं और संसाधनों का संरक्षण करती हैं।",
      "धान कैसे उगाएं?":
          "धान को बाढ़ वाले खेतों, उपजाऊ मिट्टी और गर्म तापमान की आवश्यकता होती है; रोपाई करें।",
      "मल्चिंग क्या है?":
          "मल्चिंग में मिट्टी को जैविक या कृत्रिम सामग्री से ढकना होता है ताकि नमी बनी रहे।",
      "पौधों में पोषक तत्वों की कमी कैसे पहचानें?":
          "पीले पत्ते (नाइट्रोजन की कमी) या छोटा विकास (फास्फोरस की कमी) जैसे लक्षण देखें।",
      "सह-रोपण क्या है?":
          "सह-रोपण में विभिन्न फसलों को एक साथ उगाया जाता है ताकि कीटों से बचाव हो।",
      "छोटा सब्जी बाग कैसे शुरू करें?":
          "धूप वाली जगह चुनें, उपजाऊ मिट्टी तैयार करें और मौसमी सब्जियां लगाएं।",
      "मृदा अपरदन क्या है?":
          "मृदा अपरदन हवा, पानी या मानवीय गतिविधियों से ऊपरी मिट्टी का नुकसान है।",
      "प्राकृतिक उर्वरकों का उपयोग कैसे करें?":
          "खाद, गोबर या हरी खाद डालकर मिट्टी को पोषक तत्व दें।",
      "सर्दियों में कौन सी फसलें उगती हैं?":
          "सर्दियों में गेहूं, सरसों और मटर अच्छी तरह उगती हैं।",
      "खरपतवारों का प्रबंधन कैसे करें?":
          "मल्चिंग, हाथ से निराई या जैविक जड़ी-बूटी नाशक का उपयोग करें।",
      "एक्वापोनिक्स क्या है?":
          "एक्वापोनिक्स मछली पालन और हाइड्रोपोनिक्स का संयोजन है, जिसमें मछली का कचरा पौधों को पोषक देता है।",
      "फसल की पैदावार कैसे बढ़ाएं?":
          "गुणवत्तापूर्ण बीज, मिट्टी स्वास्थ्य और सटीक खेती तकनीकों का उपयोग करें।",
      "कवर क्रॉप क्या है?":
          "कवर क्रॉप जैसे तिपतिया घास मिट्टी की रक्षा और उर्वरता बढ़ाने के लिए उगाए जाते हैं।",
      "जैविक खेती कैसे शुरू करें?":
          "रासायनिक पदार्थों से बचें, जैविक उर्वरक का उपयोग करें और प्रमाणन लें।",
      "फसल विविधीकरण क्या है?":
          "फसल विविधीकरण में जोखिम कम करने के लिए विभिन्न फसलों को उगाना शामिल है।",
      "पौधों में फंगल रोगों से कैसे निपटें?":
          "जैविक कवकनाशी, हवा का संचार और प्रभावित हिस्सों को हटाएं।",
      "परागणकों की भूमिका क्या है?":
          "मधुमक्खियां परागण करके फसलों की पैदावार बढ़ाती हैं।",
      "बीज कैसे संग्रह करें?":
          "बीजों को ठंडी, सूखी जगह पर हवाबंद डिब्बों में रखें।",
      "एग्रोफोरेस्ट्री क्या है?":
          "एग्रोफोरेस्ट्री में पेड़ों को फसलों या पशुओं के साथ जोड़ा जाता है।",
      "ड्रिप सिंचाई के लाभ क्या हैं?":
          "यह पानी बचाता है, खरपतवार कम करता है और जड़ों तक पोषक तत्व पहुंचाता है।",
      "आप कौन हैं?": "मैं एग्रीबॉट हूँ, आपका कृषि सहायक।",
      "आप क्या कर सकते हैं?":
          "मैं कृषि सवालों के जवाब दे सकता हूँ और बातचीत कर सकता हूँ।",
      "शुभ संध्या": "शुभ संध्या! आपका दिन कैसा रहा?",
      "दिन कैसा चल रहा है?": "मेरा दिन सीखने से भरा है! आपका कैसा है?",
      "वॉयस असिस्टेंट क्या है?":
          "वॉयस असिस्टेंट एक डिजिटल सहायक है जो आवाज के आदेशों का जवाब देता है।",
      "कुछ रोचक बताएं":
          "क्या आप जानते हैं कि केंचुए मिट्टी को प्राकृतिक रूप से बेहतर बनाते हैं?",
      "समय क्या है?": "मैं अभी समय नहीं देख सकता, आपकी घड़ी मदद कर सकती है!",
      "चुटकुला सुनाएं": "गाय ने भाषण क्यों दिया? क्योंकि उसे बहुत कुछ कहना था!",
      "खेती क्या है?": "खेती फसल उगाने या पशु पालने की प्रक्रिया है।",
      "आप कैसे काम करते हैं?":
          "मैं आपके सवाल सुनता हूँ और अपने ज्ञान से जवाब देता हूँ।",
      "शुभ रात्रि": "शुभ रात्रि! स्वस्थ फसलों के सपने देखें।",
      "तकनीक क्या है?": "तकनीक समस्याओं को हल करने के लिए उपकरणों का उपयोग है।",
      "क्या आप गा सकते हैं?": "मैं गा नहीं सकता, लेकिन फसल चक्र बता सकता हूँ!",
    },
    "te": {
      "హలో": "హాయ్! నేను ఎలా సహాయం చేయగలను?",
      "హాయ్": "హాయ్! నీ ప్రశ్నలకు సహాయం చేయడానికి సిద్ధంగా ఉన్నాను。",
      "మధ్యాహ్న శుభాకాంక్షలు":
          "మధ్యాహ్న శుభాకాంక్షలు! నీ రోజు బాగా సాగుతోందని ఆశిస్తున్నాను。",
      "నీ ఉద్దేశ్యం ఏమిటి?":
          "నేను అగ్రిబాట్, రైతులకు సలహాలు ఇవ్వడానికి రూపొందాను。",
      "అగ్రిబాట్ ఎవరు?": "అది నేనే! నీ వ్యవసాయ సహాయకుడు.",
      "నీవు బాగున్నావా?": "నేను బాగానే ఉన్నాను, నీకు సహాయం చేయడానికి సిద్ధం!",
      "సుభ రోజు": "సుభ రోజు! నీ పొలం సమృద్ధిగా ఉందని ఆశిస్తున్నాను。",
      "నీవు ఏమిటి?":
          "నేను అగ్రిబాట్, రైతులు మరియు జిజ్ఞాసువుల కోసం వాయిస్ అసిస్టెంట్.",
      "నీ గుర్తింపు?":
          "నేను అగ్రిబాట్, వ్యవసాయ సలహాలు మరియు సంభాషణల కోసం నీ సహచరుడు.",
      "బాగున్నావా?": "నేను తేనెటీగలా ఝుంగా! నీవు ఎలా ఉన్నావు?",
      "నీ పాత్ర ఏమిటి?":
          "ప్రశ్నలకు సమాధానమిస్తాను, వ్యవసాయ సలహాలు ఇస్తాను, నీకు తోడుగా ఉంటాను。",
      "నిన్ను కలవడం సంతోషం": "నిన్ను కలవడం నాకూ ఆనందం! వ్యవసాయ చర్చకు సిద్ధమా?",
      "ఏఐ అసిస్టెంట్ అంటే ఏమిటి?":
          "ఏఐ అసిస్టెంట్ అనేది వాయిస్ లేదా టెక్స్ట్ ద్వారా సహాయపడే స్మార్ట్ ప్రోగ్రామ్.",
      "నిన్ను ఎవరు నిర్మించారు?":
          "వ్యవసాయం పట్ల మక్కువ ఉన్న బృందం నీ కోసం నన్ను తయారు చేసింది。",
      "ఒక కూల్ ఫ్యాక్ట్ చెప్పు":
          "ఆరోగ్యమైన నేల గాలి కంటే ఎక్కువ కార్బన్ నిల్వ చేయగలదని తెలుసా?",
      "ఈ రోజు తేదీ ఏమిటి?":
          "ఇది జూలై 8, 2025, రాత్రి 9:48 IST. పంటల ప్రణాళిక సమయం!",
      "చిన్న జోక్ చెప్పు":
          "క్యారెట్ ఎందుకు సిగ్గుపడింది? బఠానీలు వాటి స్టూ గురించి మాట్లాడడం వినింది!",
      "సాగు అంటే ఏమిటి?":
          "సాగు అనేది భూమిని సిద్ధం చేసి, ఆహారం లేదా వనరుల కోసం పంటలు పెంచడం.",
      "కృతజ్ఞతలు": "నా ఆనందం! ఎప్పుడూ సహాయం చేస్తాను。",
      "నిన్ను ఎలా సంభాషించాలి?":
          "ఏదైనా అడుగు, నేను ఉపయోగకరమైన సమాచారం ఇస్తాను。",
      "జాగ్రత్త": "ధన్యవాదాలు! నీకు సమృద్ధిగా దిగుబడి కావాలని కోరుకుంటున్నాను。",
      "ఆటోమేషన్ అంటే ఏమిటి?":
          "ఆటోమేషన్ అనేది టెక్నాలజీతో పనులు చేయడం, వ్యవసాయంలో నీటిపారుదల వ్యవస్థల వంటివి。",
      "ట్రివియా చెప్పు":
          "ఒక్క సూర్యకాంతి 2,000 విత్తనాల వరకు ఉత్పత్తి చేయగలదు!",
      "నీకు ఏమి ఇష్టం?":
          "నీ పంటలను పెంచడంలో మరియు కొత్త విద్యలు నేర్పడంలో సహాయపడటం నాకు ఇష్టం!",
      "మళ్లీ కలుద్దాం": "ఇప్పటికి వీడ్కోలు! నీ పొలాలను హరితంగా పెంచు.",
      "నీకు ఏమి తెలుసు?":
          "వ్యవసాయం, వాతావరణ సలహాలు, సాధారణ జ్ఞానం నాకు తెలుసు。",
      "రోజు ఎలా సాగుతోంది?": "ఇక్కడ అంతా బాగుంది! నీ పొలం ఎలా ఉంది?",
      "చాట్‌బాట్ అంటే ఏమిటి?":
          "చాట్‌బాట్ అనేది యూజర్లతో మాట్లాడే ప్రోగ్రామ్, నేను రైతులతో మాట్లాడతాను!",
      "నిన్ను ఎవరు రూపొందించారు?":
          "వ్యవసాయ సహాయం కోసం ఆవిష్కర్తల బృందం నన్ను తయారు చేసింది。",
      "కొత్త విషయం చెప్పు":
          "పంట వైవిధ్యం నేల ఆరోగ్యాన్ని మెరుగుపరుస్తుందని తెలుసా?",
      "హాస్య కథ చెప్పు":
          "ఒక బంగాళదుంప కూరగాయల గాయన బృందంలో చేరాలనుకుంది, కానీ వేదికపై నుండి దొర్లింది!",
      "వ్యవసాయం అంటే ఏమిటి?":
          "వ్యవసాయం అంటే పంటలు పెంచడం మరియు పశువులను పెంచడం.",
      "మీకు స్వాగతం": "ధన్యవాదాలు! నేను నీ కోసం ఇక్కడ ఉన్నాను。",
      "నిన్ను ఎలా ఉపయోగించాలి?":
          "నాకు ప్రశ్నలు అడుగు, నేను సహాయకరమైన సమాధానాలు ఇస్తాను。",
      "మంచి రోజు కావాలి":
          "ధన్యవాదాలు! నీ పొలంలో ఫలవంతమైన రోజు కావాలని కోరుకుంటున్నాను。",
      "ఆవిష్కరణ అంటే ఏమిటి?":
          "ఆవిష్కరణ అంటే కొత్త ఆలోచనలు లేదా పద్ధతుల సృష్టి, స్మార్ట్ ఫార్మింగ్ టూల్స్ వంటివి。",
      "ఫన్ ఫ్యాక్ట్ చెప్పు":
          "తేనెటీగలు ఒక్క రోజులో 5,000 పూలను పరాగసంపర్కం చేయగలవు!",
      "నీకు ఇష్టమైన పని ఏమిటి?":
          "రైతులకు మంచి పంటలు పెంచడంలో సహాయం చేయడం నాకు ఇష్టం!",
      "శుభోదయం": "శుభోదయం! మీ రోజంతా సంతోషంగా సాగాలని ఆశిస్తున్నాను.",
      "మీరు ఎవరు": "నేను మీ వ్యవసాయ సహాయకుడు, మీ ప్రశ్నలకు సమాధానాలు ఇస్తాను.",
      "మీ పేరు ఏమిటి": "నా పేరు అగ్రిబాట్. నేను మీకు వ్యవసాయ సలహా అందిస్తాను.",
      "ఆర్గానిక్ ఫార్మింగ్ అంటే ఏమిటి":
          "ఆర్గానిక్ వ్యవసాయంలో రసాయనాల్ని కాకుండా సహజ పదార్థాలను వాడతారు.",
      "టమోటాలు ఎలా పెంచాలి":
          "టమోటాలు మంచి నీటి పారుదల గల మట్టిలో మరియు ఎక్కువ సూర్యకాంతితో బాగా పెరుగుతాయి.",
      "డ్రిప్ ఇరిగేషన్ అంటే ఏమిటి":
          "డ్రిప్ ఇరిగేషన్ అనేది మొక్కల రూట్స్‌కి నేరుగా నీటిని అందించే విధానం.",
      "ప్రిసిషన్ అగ్రికల్చర్ అంటే ఏమిటి":
          "టెక్నాలజీ సహాయంతో సాగు ప్రక్రియను మెరుగుపరచే వ్యవసాయ విధానమే ప్రిసిషన్ అగ్రికల్చర్.",
      "వెర్మీ కంపోస్టింగ్ అంటే ఏమిటి":
          "కెంచుల ద్వారా వృథా పదార్థాలను ప్రాకృతికమైన ఖాతుగా మార్చే ప్రక్రియ వెర్మీ కంపోస్టింగ్.",
      "పురుగుల నుండి పంటలను ఎలా రక్షించాలి":
          "నేమ్ ఆయిల్, పంటల మార్పిడి, మరియు సహజ శత్రువులను వాడండి.",
      "నేల ఉరితత్వాన్ని ఎలా పరీక్షించాలి":
          "సోయిల్ టెస్ట్ కిట్ వాడండి లేదా దగ్గర్లోని ల్యాబ్‌కి నమూనా పంపండి.",
      "ఎండాకాలంలో ఏ పంటలు బాగుంటాయి":
          "జొన్న, పెద్దసిరి మరియు మక్కా పంటలు బాగుంటాయి.",
      "ఒక జోక్ చెప్పు":
          "టమోటా ఎక్కడకి వెళ్లింది? సలాడ్ డ్రెస్ చూస్తూ అచ్చెత్తింది!",
      "ఈరోజు వాతావరణం ఎలా ఉంది":
          "నేను ఆఫ్‌లైన్‌లో ఉన్నాను, దయచేసి వాతావరణ యాప్‌ను తనిఖీ చేయండి.",
      "ధన్యవాదాలు": "మీకు స్వాగతం! సుఖంగా వ్యవసాయం చేయండి!",
      "వీడ్కోలు": "శుభంగా ఉండండి! మళ్ళీ కలుద్దాం.",
      "ఆర్గానిక్ వ్యవసాయం అంటే ఏమిటి?":
          "రసాయనాల్ని లేకుండా సహజ పద్ధతులతో పంటలు పండించే వ్యవసాయ విధానమే ఆర్గానిక్ వ్యవసాయం.",
      "నేల ఉరితత్వం ఎలా పెంచాలి?":
          "కంపోస్ట్ వాడండి, పంటల మార్పిడి చేయండి, హరిత ఎరువులు వాడండి.",
      "పంటల మార్పిడి అంటే ఏమిటి?":
          "ఒకే మైదానంలో ప్రతిసారి వేర్వేరు పంటలు వేయడం.",
      "బియ్యం పంటలో సాధారణ పురుగులు":
          "స్టెమ్ బోరర్లు, లీఫ్ ఫోల్డర్లు, బ్రౌన్ ప్లాంట్ హాపర్స్.",
      "వ్యవసాయంలో నీరు ఎలా సేవ్ చేయాలి?":
          "డ్రిప్ ఇరిగేషన్, వర్ష జల నిర్వహణ, మల్చింగ్ ఉపయోగించండి.",
      "గ్రీన్హౌస్ వ్యవసాయం అంటే?": "పర్యావరణ నియంత్రణతో పంటలు పెంచే విధానం.",
      "గోధుమలు ఎప్పుడు వేయాలి?": "భారతదేశంలో సాధారణంగా నవంబరులో వేయాలి.",
      "వృక్ష రోగాల నివారణ ఎలా చేయాలి?":
          "ప్రతిఘటన గల విత్తనాలు, సరైన అంతరాలు మరియు సేంద్రియ మందులు వాడండి.",
      "జైవ ఉరవేసకాలు అంటే?":
          "జీవ శక్తితో ఉన్న ఉరవేసకాలు, ఇవి నేల ఉరితత్వాన్ని పెంచుతాయి.",
      "ధాన్యం ఎలా నిల్వ ఉంచాలి?":
          "బాగా ఎండబెట్టిన ధాన్యాన్ని గాలి చొరబడని డబ్బాలలో పెట్టాలి.",
      "హైడ్రోపోనిక్స్ అంటే?":
          "మట్టితో కాకుండా నీటిలో పోషకాలు కలిపి పంటలు పెంచే విధానం.",
      "పౌల్ట్రీ ఫార్మ్ ఎలా ప్రారంభించాలి?":
          "చక్కని ప్రదేశాన్ని ఎంచుకోండి, మంచి జాతిని తీసుకోండి.",
      "ఇంటిగ్రేటెడ్ ఫార్మింగ్ అంటే?": "పంటలు, జంతువులు, చేపలు కలిపిన వ్యవసాయం.",
      "తేనెటీగల పెంపకం ఎలా మొదలుపెట్టాలి?":
          "తేనెటీగ పెట్టెలు కొనండి మరియు పుష్పాల సమీపంలో పెట్టండి.",
      "నేల పీహెచ్ ఎలా చెక్ చేయాలి?": "పిహెచ్ టెస్ట్ కిట్ ఉపయోగించండి.",
      "నీ పేరు ఏమిటి?": "నా పేరు అగ్రిబాట్. నేను వ్యవసాయ సహాయం కోసం ఉన్నాను.",
      "నువ్వు ఎలా ఉన్నావు?": "నేను బాగున్నాను, మీ సేవలో సిద్ధంగా ఉన్నాను!",
      "నీని ఎవరు తయారు చేశారు?":
          "నన్ను రైతులను సహాయపడే ఉద్దేశ్యంతో అభివృద్ధి చేశారు.",
      "నువ్వు ఎలా సహాయం చేస్తావు?":
          "నేను వ్యవసాయం గురించి ప్రశ్నలకు సమాధానాలు ఇస్తాను.",
      "నాకు జోక్ చెప్పు": "ఏంట్రా టమోటా అచ్చెత్తింది? సలాడ్ డ్రెస్ చూసింది!",
      "AI అంటే ఏమిటి?":
          "AI అంటే ఆర్టిఫిషియల్ ఇంటెలిజెన్స్, అంటే యంత్రాలు మానవుల్లా ఆలోచించడం.",
      "కాలానుకూల మార్పు అంటే ఏమిటి?":
          "పలుకుబడి గల కాలానుకూల ఉష్ణోగ్రతలు మరియు వాతావరణ మార్పులు.",
      "సస్టైనబుల్ ఫార్మింగ్ అంటే ఏమిటి?":
          "సస్టైనబుల్ ఫార్మింగ్ నేల ఆరోగ్యాన్ని కాపాడే మరియు సుదీర్ఘ ఉత్పాదకతను నిర్ధారించే పద్ధతులను ఉపయోగిస్తుంది।",
      "వరి ఎలా పెంచాలి?":
          "వరికి నీరు నిలిచే పొలం, ఫలవంతమైన నేల, వెచ్చని వాతావరణం అవసరం; నాట్లు వేయండి।",
      "మల్చింగ్ అంటే ఏమిటి?":
          "మల్చింగ్ అనేది నేలను సేంద్రియ లేదా కృత్రిమ పదార్థాలతో కప్పడం, తేమను నిలుపుకోవడానికి।",
      "మొక్కలలో పోషక లోపాలను ఎలా గుర్తించాలి?":
          "పసుపు ఆకులు (నైట్రోజన్ లోపం) లేదా చిన్న పెరుగుదల (ఫాస్ఫరస్ లోపం) చూడండి।",
      "కంపానియన్ ప్లాంటింగ్ అంటే ఏమిటి?":
          "వివిధ పంటలను ఒకేసారి పెంచడం ద్వారా పెరుగుదలను మెరుగుచేయడం లేదా పురుగులను నివారించడం.",
      "చిన్న కూరగాయల తోట ఎలా మొదలుపెట్టాలి?":
          "ఎండ ఉన్న ప్రదేశాన్ని ఎంచుకోండి, ఫలవంతమైన నేలను సిద్ధం చేసి, సీజనల్ కూరగాయలు నాటండి।",
      "నేల కోత అంటే ఏమిటి?":
          "నేల కోత అనేది గాలి, నీరు లేదా మానవ కార్యకలాపాల వల్ల ఎగువ నేల కోల్పోవడం.",
      "సహజ ఎరువులను ఎలా ఉపయోగించాలి?":
          "కంపోస్ట్, గొల్లపిడ లేదా హరిత ఎరువులను నేలకు జోడించండి।",
      "శీతాకాలంలో ఏ పంటలు పెరుగుతాయి?":
          "గోధుమ, ఆవాలు, బఠానీలు చల్లని వాతావరణంలో బాగా పెరుగుతాయి।",
      "కలుపు మొక్కలను ఎలా నిర్వహించాలి?":
          "మల్చింగ్, చేతితో కలుపు తీయడం లేదా సేంద్రియ హెర్బిసైడ్లు వాడండి।",
      "ఆక్వాపోనిక్స్ అంటే ఏమిటి?":
          "చేపల పెంపకంతో హైడ్రోపోనిక్స్ కలిపి, చేపల వ్యర్థాలతో మొక్కలకు పోషణ ఇవ్వడం.",
      "పంట దిగుబడిని ఎలా మెరుగుపరచాలి?":
          "గుణమైన విత్తనాలు, నేల ఆరోగ్యం, స్టీక ఫార్మింగ్ టెక్నిక్‌లు వాడండి।",
      "కవర్ క్రాప్ అంటే ఏమిటి?":
          "క్లోవర్ లేదా రై వంటి కవర్ క్రాప్‌లు నేల రక్షణ మరియు ఉరితత్వం కోసం పెంచబడతాయి।",
      "ఆర్గానిక్ ఫార్మింగ్ ఎలా మొదలుపెట్టాలి?":
          "రసాయనాలను నివారించండి, సేంద్రియ ఎరువులు వాడండి మరియు అధికారుల సర్టిఫికేషన్ తీసుకోండి।",
      "పంట వైవిధ్యం అంటే ఏమిటి?":
          "వివిధ రకాల పంటలను పెంచడం ద్వారా రిస్క్ తగ్గించడం మరియు నేల ఆరోగ్యం మెరుగుపరచడం.",
      "మొక్కలలో ఫంగల్ రోగాలను ఎలా నివారించాలి?":
          "సేంద్రియ కవకనాశినులు, గాలి ఆడేలా చూసుకోండి, ప్రభావిత భాగాలను తొలగించండి।",
      "పరాగసంపర్క జీవుల పాత్ర ఏమిటి?":
          "తేనెటీగలు పరాగసంపర్కం చేస్తాయి, ఫసల దిగుబడిని పెంచుతాయి।",
      "విత్తనాలను ఎలా నిల్వ చేయాలి?":
          "విత్తనాలను చల్లని, పొడి ప్రదేశంలో గాలి చొరబడని డబ్బాలలో నిల్వ చేయండి।",
      "ఆగ్రోఫారెస్ట్రీ అంటే ఏమిటి?":
          "చెట్లను పంటలు లేదా పశువులతో కలిపి ఉత్పాదకతను పెంచే విధానం.",
      "డ్రిప్ ఇరిగేషన్ యొక్క ప్రయోజనాలు ఏమిటి?":
          "ఇది నీటిని ఆదా చేస్తుంది, కలుపు మొక్కలను తగ్గిస్తుంది మరియు రూట్స్‌కు పోషకాలను అందిస్తుంది।",
      "మీరు ఎవరు?": "నేను అగ్రిబాట్, మీ వ్యవసాయ సహాయకుడు.",
      "మీ పేరు ఏమిటి?": "నా పేరు అగ్రిబాట్, వ్యవసాయ సలహాల కోసం ఉన్నాను。",
      "నీవు ఎలా ఉన్నావు?": "నేను బాగున్నాను, ధన్యవాదాలు! నీవు ఎలా ఉన్నావు?",
      "నీవు ఏం చేయగలవు?":
          "నేను వ్యవసాయ ప్రశ్నలకు సమాధానమిస్తాను, సలహాలు ఇస్తాను.",
      "సాయంత్రం శుభం": "సాయంత్రం శుభం! మీ రోజు బాగా గడిచిందని ఆశిస్తున్నాను.",
      "వాయిస్ అసిస్టంట్ అంటే ఏమిటి?":
          "వాయిస్ అసిస్టంట్ అనేది గొంతు ఆదేశాలకు స్పందించే డిజిటల్ సహాయకుడు.",
      "నిన్ను ఎవరు సృష్టించారు?":
          "రైతులకు సహాయపడేందుకు నన్ను ఒక బృందం తయారు చేసింది。",
      "ఆసక్తికరమైన విషయం చెప్పు":
          "కెంచుకలు నేల ఆరోగ్యాన్ని సహజంగా మెరుగుపరుస్తాయని తెలుసా?",
      "సమయం ఎంత?": "నేను ఇప్పుడు సమయం చూడలేను, నీ గడియారం సహాయపడగలదు!",
      "జోక్ చెప్పు": "ఆవు స్పీకర్ ఎందుకైంది? చాలా మూగుడు విషయాలు ఉన్నాయ్ కదా!",
      "నీవు ఎలా పనిచేస్తావు?":
          "నీ ప్రశ్నలను విని, నా జ్ఞానంతో సమాధానాలు ఇస్తాను.",
      "शुभ रात्रि": "शुभ रात्री! स्वस्थ फसलों के सपनों का आनंद लें।",
      "తెల్నాగం": "సుభ రాత్రి! ఆర్వాగ్యమైన పంటల స్వప్నాలు చూడు.",
      "టెక్నాలజీ అంటే ఏమిటి?":
          "టెక్నాలజీ అంటే సమస్యలను పరిష్కరించే సాధనాలు మరియు వ్యవస్థల ఉపయోగం.",
      "నీవు పాడగలవా?": "నేను పాడలేను, కానీ పంట చక్రాల గురించి చెప్పగలను!",
    },
  };

  String selectedLang = 'en';
  String selectedLocale = 'en-US';

  Future<String?> fetchUserProfileImageUrl(String username) async {
    const baseUrl = 'https://djangotestcase.s3.ap-south-1.amazonaws.com/';
    final extensions = ['jpg', 'jpeg', 'png'];

    for (String ext in extensions) {
      final url = '$baseUrl${username}profile.$ext';
      try {
        final response = await http.head(Uri.parse(url));
        if (response.statusCode == 200) {
          return url;
        }
      } catch (_) {
        // continue trying other extensions
      }
    }
    return null;
  }

  Future<void> showSiriAssistant(BuildContext context) async {
    String userInput = ""; // Declare and initialize before use
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              'assets/siri.json',
              width: 200,
              height: 200,
              repeat: true,
            ),
            const SizedBox(height: 10),
            Text(
              "Listening..... $userInput",
              style: const TextStyle(color: Colors.white, fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
    while (true) {
      userInput = await _listen() ?? "";

      // Wait a bit after speaking
      await Future.delayed(Duration(seconds: 1));

      if (userInput.trim().isEmpty) return;

      final reply = await _getResponseFromDataset(userInput);

      if (userInput.contains("Farmer Page") ||
          userInput.contains("farmer page")) {
        Navigator.of(context).pop(); // Close the dialog
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(builder: (context) => FarmerDashboard()),
        // );
        return;
      }

      if (userInput == "Open Dashboard" || userInput == "open dashboard") {
        Navigator.of(context).pop(); // Close the dialog
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(builder: (context) => BuyerDashboardPage()),
        // );
        return;
      }

      if (userInput.contains("Open") && userInput.contains("Dashboard") ||
          userInput.contains("open") && userInput.contains("dashboard")) {
        Navigator.of(context).pop(); // Close the dialog
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(builder: (context) => BuyerDashboardPage()),
        // );
        return;
      }

      if (userInput.contains("Dashboard") || userInput.contains("dashboard")) {
        Navigator.of(context).pop(); // Close the dialog
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(builder: (context) => BuyerDashboardPage()),
        // );
        return;
      }

      if (userInput.contains("Policies") ||
          userInput.contains("policies") ||
          userInput.contains("Policy") ||
          userInput.contains("policy")) {
        Navigator.of(context).pop(); // Close the dialog
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(builder: (context) => FarmPolicyApp()),
        // );
        return;
      }

      if (userInput.contains("Weather") || userInput.contains("weather")) {
        Navigator.of(context).pop(); // Close the dialog
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(builder: (context) => WeatherMarketPage()),
        // );
        return;
      }

      if (userInput.contains("Login Page") ||
          userInput.contains("login page")) {
        Navigator.of(context).pop(); // Close the dialog
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
        return;
      }

      if (userInput.contains("change language") ||
          userInput.contains("Change Language")) {
        MyApp.setLocale(context, const Locale('hi'));
        Navigator.of(context).pop(); // Close the dialog

        return;
      }

      // Speak response
      String ttsLang = selectedLocale;

      await _tts.setLanguage(ttsLang);
      await _tts.speak(reply);

      if ([
        "exit",
        "quit",
        "bye",
        "goodbye",
        "stop",
        "close",
        "cancel",
        "Exit",
        "Quit",
        "Bye",
        "Goodbye",
        "Stop",
        "Close",
        "Cancel",
      ].contains(userInput)) {
        Navigator.of(context).pop(); // Close the dialog
        return;
      }

      await Future.delayed(Duration(milliseconds: 4000));
    }
  }

  Future<String?> _listen() async {
    if (isListening) {
      await _speech.stop();
      setState(() => isListening = false);
      return null;
    }

    bool available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          setState(() => isListening = false);
        }
      },
      onError: (error) {
        print('Speech error: $error');
        setState(() => isListening = false);
      },
    );

    if (!available) return null;

    setState(() => isListening = true);

    final completer = Completer<String?>();
    print(selectedLocale);

    _speech.listen(
      localeId: selectedLocale,

      listenMode: stt.ListenMode.dictation,
      listenFor: Duration(seconds: 10),
      pauseFor: Duration(seconds: 3),
      onResult: (result) {
        if (result.finalResult) {
          setState(() => isListening = false);
          _speech.stop();
          completer.complete(result.recognizedWords);
        }
      },
    );

    return completer.future;
  }

  Future<String> _getResponseFromDataset(String userInput) async {
    String langCode = selectedLang.substring(0, 2);

    // Allow only en, hi, te
    if (!['en', 'hi', 'te'].contains(langCode)) {
      langCode = 'en';
    }
    print("Selected Language Code: $langCode");

    Map<String, String> faqs = faqDataset[langCode] ?? faqDataset['en']!;

    String? bestMatch;
    double maxScore = 0.0;

    faqs.forEach((question, answer) {
      double score = userInput.toLowerCase().similarityTo(question);
      if (score > maxScore) {
        maxScore = score;
        bestMatch = question;
      }
    });

    return maxScore > 0.4
        ? faqs[bestMatch]!
        : "Sorry, I couldn't understand. Please ask a Health-related question.";
  }

  @override
  Widget build(BuildContext context) {
    fetchUserProfileImageUrl(
      Provider.of<resource>(context, listen: false).PresentWorkingUser,
    );
    final local = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final subTextColor = isDark ? Colors.white70 : Colors.black54;

    final carouselItems = [
      {"image": "assets/appointment.jpg", "title": local.carouselTitle1},
      {"image": "assets/qrcode.jpg", "title": local.carouselTitle2},
      {"image": "assets/privacy.jpg", "title": local.carouselTitle3},
      {"image": "assets/logs.jpg", "title": "Logs Supported"},
    ];

    final categories = [
      {
        "icon": Icons.folder_shared,
        "title": local.categoryCropsTitle,
        "desc": local.categoryCropsDesc,
        "screen": PlaceholderScreen(title: local.categoryCropsTitle),
      },
      {
        "icon": Icons.health_and_safety,
        "title": local.categoryEquipmentTitle,
        "desc": local.categoryEquipmentDesc,
        "screen": PlaceholderScreen(title: local.categoryEquipmentTitle),
      },
      {
        "icon": Icons.medication,
        "title": local.categoryProduceTitle,
        "desc": " ",
        "screen": PlaceholderScreen(title: local.categoryProduceTitle),
      },
    ];

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(local.appTitle),
        backgroundColor: const Color.fromRGBO(68, 138, 255, 1),
        actions: [
          Padding(
            padding: const EdgeInsets.only(
              right: 16.0,
            ), // Add more right padding
            child: DropdownButton<Locale>(
              underline: const SizedBox(),
              icon: const Icon(Icons.language, color: Colors.white),
              onChanged: (locale) {
                if (locale != null) MyApp.setLocale(context, locale);
              },
              items: const [
                DropdownMenuItem(value: Locale('en'), child: Text('EN')),
                DropdownMenuItem(value: Locale('hi'), child: Text('HI')),
                DropdownMenuItem(value: Locale('te'), child: Text('TE')),
              ],
            ),
          ),
        ],
      ),
      drawer: Drawer(
        width: MediaQuery.of(context).size.width * 0.69,
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(
                Provider.of<resource>(
                  context,
                  listen: false,
                ).PresentWorkingUser,
              ),
              accountEmail: Text(
                Provider.of<resource>(
                  context,
                  listen: false,
                ).PresentWorkingUser2,
              ),
              currentAccountPicture: FutureBuilder<String?>(
                future: fetchUserProfileImageUrl(
                  Provider.of<resource>(
                    context,
                    listen: false,
                  ).PresentWorkingUser,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircleAvatar(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasData && snapshot.data != null) {
                    return CircleAvatar(
                      backgroundImage: NetworkImage(snapshot.data!),
                    );
                  } else {
                    return const CircleAvatar(
                      backgroundImage: AssetImage(
                        'assets/imgicon1.png',
                      ), // fallback
                    );
                  }
                },
              ),
              decoration: const BoxDecoration(color: Colors.blue),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: Text(local.drawerProfile),
              onTap: () async {
                // Step 2: Fetch all device tokens
                final tokenResponse = await http.get(
                  Uri.parse(
                    "http://13.203.219.206:8000/getsportsnotificationtoken/",
                  ),
                );

                if (tokenResponse.statusCode == 200) {
                  final data = jsonDecode(tokenResponse.body);
                  final List<dynamic> tokens = data['tokens'];

                  await http.post(
                    Uri.parse(
                      "http://13.203.219.206:8000/sendnotificationtoall/",
                    ),
                    headers: {"Content-Type": "application/json"},
                    body: jsonEncode({
                      "title": "Doctor Appointmnet",
                      "body": "Your Appointment Will be in 21st 4pm",
                    }),
                  );

                  print("🔔 Notifications sent to ${tokens.length} devices.");
                } else {
                  print("⚠ Failed to fetch tokens: ${tokenResponse.body}");
                }
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.help),
              title: Text(local.drawerHelp),
              onTap: () {
                Navigator.pop(context);
                showSiriAssistant(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.contact_emergency),
              title: Text(local.drawerQuery),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: Text(local.drawerSettings),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Search
          TextField(
            decoration: InputDecoration(
              hintText: local.searchHint,
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Carousel
          CarouselSlider.builder(
            itemCount: carouselItems.length,
            itemBuilder: (context, index, realIdx) {
              final item = carouselItems[index];
              return Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(item['image']!, fit: BoxFit.cover),
                  Center(
                    child: Container(
                      color: Colors.black38,
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        item['title']!,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              );
            },
            options: CarouselOptions(height: 200, autoPlay: true),
          ),
          const SizedBox(height: 20),

          // Info Section
          Center(
            child: Text(
              local.contractFarmingTitle,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              local.contractFarmingDescription,
              style: TextStyle(color: subTextColor),
            ),
          ),

          const SizedBox(height: 20),
          // Categories
          Center(
            child: Text(
              local.exploreCategories,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: categories
                  .map((cat) => _buildCategoryBox(cat, context))
                  .toList(),
            ),
          ),

          const SizedBox(height: 20),
          // Testimonials
          Center(
            child: Text(
              local.whatUsersSay,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
          _testimonial(
            local.testimonial1,
            local.testimonial1Author,
            textColor,
            subTextColor,
          ),
          _testimonial(
            local.testimonial2,
            local.testimonial2Author,
            textColor,
            subTextColor,
          ),
          _testimonial(
            local.testimonial3,
            local.testimonial3Author,
            textColor,
            subTextColor,
          ),

          const SizedBox(height: 20),
          // Footer
          Container(
            color: Colors.lightBlue,
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                Text(
                  local.footerCopyright,
                  style: TextStyle(color: subTextColor),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.facebook, size: 28, color: Colors.white),
                    SizedBox(width: 12),
                    Icon(Icons.alternate_email, size: 28, color: Colors.white),
                    SizedBox(width: 12),
                    Icon(Icons.camera_alt, size: 28, color: Colors.white),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: SizedBox(
        width: 130, // Increase width
        height: 50, // Increase height
        child: FloatingActionButton.extended(
          backgroundColor: Colors.orange,
          onPressed: () async {
            // showSiriAssistant(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
          },
          icon: const Icon(Icons.arrow_circle_right),
          label: const Text("Proceed", style: TextStyle(fontSize: 16)),
        ),
      ),
    );
  }

  Future<void> saveFcmToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      print("FCM Token: $token");
      print(
        ". .................................................................................",
      );

      // Send this token to your Django backend
      //await sendTokenToBackend(token);
    }
  }

  Widget _buildCategoryBox(Map<String, dynamic> cat, BuildContext context) {
    return InkWell(
      onTap: () {
        // saveFcmToken();
        //  showSiriAssistant;

        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => cat['screen']),
        );
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.80,
        height: 150,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF8e44ad), Color(0xFF3498db)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(cat['icon'], size: 40, color: Colors.white),
            const SizedBox(height: 10),
            Text(
              cat['title'],
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 5),
            Text(
              cat['desc'],
              style: const TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _testimonial(
    String text,
    String author,
    Color textColor,
    Color subTextColor,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            '"$text"',
            style: TextStyle(fontStyle: FontStyle.italic, color: textColor),
          ),
          const SizedBox(height: 8),
          Text(
            author,
            style: TextStyle(fontWeight: FontWeight.bold, color: subTextColor),
          ),
        ],
      ),
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text("This is $title screen")),
    );
  }
}

class Appointment {
  Appointment({
    required this.patientName,
    required this.concern,
    required this.doctor,
    required this.dateTime,
    this.completed = false,
  });

  final String patientName;
  final String concern;
  final String doctor;
  final DateTime dateTime;
  bool completed;

  Map<String, dynamic> toMap() => {
    'patientName': patientName,
    'concern': concern,
    'doctor': doctor,
    'dateTime': dateTime.toIso8601String(),
    'completed': completed,
  };

  static Appointment fromMap(Map<String, dynamic> m) => Appointment(
    patientName: m['patientName'] as String,
    concern: m['concern'] as String,
    doctor: m['doctor'] as String,
    dateTime: DateTime.parse(m['dateTime'] as String),
    completed: m['completed'] as bool? ?? false,
  );
}

class RecordItem {
  RecordItem({
    required this.date,
    required this.summary,
    required this.details,
  });
  final DateTime date;
  final String summary;
  final String details;
}

class Thread {
  Thread(this.name, this.avatar, this.messages);

  final String name;
  final IconData avatar; // keep IconData
  final List<Message> messages;

  Map<String, dynamic> toMap() => {
    'name': name,
    'avatar': avatar.codePoint,
    'messages': messages.map((m) => m.toMap()).toList(),
  };

  static Thread fromMap(Map<String, dynamic> m) => Thread(
    m['name'] as String,
    IconData(m['avatar'] as int, fontFamily: 'MaterialIcons'),
    (m['messages'] as List<dynamic>)
        .map((e) => Message.fromMap(e as Map<String, dynamic>))
        .toList(),
  );
}

class Message {
  Message(this.text, this.isMe, this.time);
  final String text;
  final bool isMe;
  final DateTime time;

  Map<String, dynamic> toMap() => {
    'text': text,
    'isMe': isMe,
    'time': time.toIso8601String(),
  };
  static Message fromMap(Map<String, dynamic> m) => Message(
    m['text'] as String,
    m['isMe'] as bool,
    DateTime.parse(m['time'] as String),
  );
}

class Store {
  static const _kAppointments = 'pt_appointments';
  static const _kThreads = 'pt_threads';

  static Future<List<Appointment>> loadAppointments() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getStringList(_kAppointments) ?? [];
    return raw
        .map((s) => Appointment.fromMap(jsonDecode(s) as Map<String, dynamic>))
        .toList();
  }

  static Future<void> saveAppointments(List<Appointment> items) async {
    final p = await SharedPreferences.getInstance();
    await p.setStringList(
      _kAppointments,
      items.map((a) => jsonEncode(a.toMap())).toList(),
    );
  }

  static Future<List<Thread>> loadThreads() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getStringList(_kThreads);
    if (raw == null) return _seedThreads(); // first run
    return raw
        .map((s) => Thread.fromMap(jsonDecode(s) as Map<String, dynamic>))
        .toList();
  }

  static Future<void> saveThreads(List<Thread> t) async {
    final p = await SharedPreferences.getInstance();
    await p.setStringList(
      _kThreads,
      t.map((e) => jsonEncode(e.toMap())).toList(),
    );
  }

  static Future<List<Thread>> _seedThreads() async {
    final demo = [
      Thread('Dr. Sarah Johnson', Icons.favorite, [
        Message(
          'Hello, how are symptoms today?',
          false,
          DateTime.now().subtract(const Duration(hours: 2)),
        ),
        Message(
          'Feeling better, mild headache remains.',
          true,
          DateTime.now().subtract(const Duration(hours: 2, minutes: 5)),
        ),
      ]),
      Thread('Reception', Icons.support_agent, [
        Message(
          'Your reports are ready for pickup.',
          false,
          DateTime.now().subtract(const Duration(days: 1)),
        ),
        Message(
          'Great, thanks!',
          true,
          DateTime.now().subtract(const Duration(days: 1, minutes: 4)),
        ),
      ]),
    ];
    await saveThreads(demo);
    return demo;
  }
}

class PatientShell extends StatefulWidget {
  const PatientShell({super.key});

  @override
  State<PatientShell> createState() => _PatientShellState();
}

class _PatientShellState extends State<PatientShell> {
  int index = 0;

  final _homeKey = GlobalKey<HomePageState>();
  final _apptKey = GlobalKey<AppointmentsPageState>();

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomePage(key: _homeKey),
      const RecordsPage(),
      const QRPage(),
      AppointmentsPage(key: _apptKey),
      //  ProfilePage(Provider.of<resource>(context, listen: false).PresentWorkingUser),
      ProfilePage(
        username: Provider.of<resource>(
          context,
          listen: false,
        ).PresentWorkingUser,
      ),
    ];

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        transitionBuilder: (child, anim) => SlideTransition(
          position: Tween(
            begin: const Offset(0.06, 0),
            end: Offset.zero,
          ).animate(anim),
          child: FadeTransition(opacity: anim, child: child),
        ),
        child: pages[index],
      ),
      bottomNavigationBar: NavigationBar(
        height: 74,
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_open_outlined),
            selectedIcon: Icon(Icons.folder),
            label: 'Records',
          ),
          NavigationDestination(
            icon: Icon(Icons.qr_code, size: 34), // bigger center QR
            selectedIcon: Icon(Icons.qr_code, size: 34),
            label: 'QR',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Appointments',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final _hospitals = const [
    ('City Medical Center', '2.1 km'),
    ('Metro General Hospital', '3.5 km'),
    ('Sunrise Clinic', '1.2 km'),
  ];

  final _doctors = const [
    ('Dr. Sarah Johnson', 'Cardiology', '10 yrs'),
    ('Dr. Alan White', 'Dermatology', '8 yrs'),
    ('Dr. Priya Nair', 'Neurology', '12 yrs'),
    ('Dr. Omar Khan', 'Orthopedics', '9 yrs'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Hospitals & Doctors'),
        actions: [
          IconButton(
            tooltip: 'Messages',
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ThreadsPage()),
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionTitle(context, 'Nearby Hospitals'),
          ..._hospitals.indexed.map((e) {
            final i = e.$1, h = e.$2;
            return _cardSlideIn(
              i,
              ListTile(
                leading: const Icon(
                  Icons.local_hospital,
                  color: Colors.redAccent,
                ),
                title: Text(h.$1),
                subtitle: Text('${h.$2} away'),
                trailing: FilledButton.tonal(
                  onPressed: () {},
                  child: const Text('View'),
                ),
              ),
            );
          }),
          const SizedBox(height: 12),
          _sectionTitle(context, 'Available Doctors'),
          Wrap(
            runSpacing: 12,
            children: _doctors.indexed.map((e) {
              final i = e.$1, d = e.$2;
              return _cardSlideIn(
                i,
                ListTile(
                  leading: const CircleAvatar(
                    backgroundImage: AssetImage('assets/doctor.jpg'),
                  ),
                  title: Text(d.$1),
                  subtitle: Text('${d.$2} • ${d.$3}'),
                  trailing: FilledButton(
                    onPressed: () {},
                    child: const Text('Book'),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String t) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(t, style: Theme.of(context).textTheme.titleLarge),
  );

  Widget _cardSlideIn(int i, Widget child) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: 1),
    duration: Duration(milliseconds: 220 + (i * 70)),
    builder: (_, v, c) => Transform.translate(
      offset: Offset(0, 18 * (1 - v)),
      child: Opacity(opacity: v, child: c),
    ),
    child: Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: child,
    ),
  );
}

class RecordsPage extends StatelessWidget {
  const RecordsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final records = <RecordItem>[
      RecordItem(
        date: DateTime.now().subtract(const Duration(days: 3)),
        summary: 'Flu Diagnosis',
        details: 'Symptoms: fever, cough. Rx: Paracetamol 500mg, rest, fluids.',
      ),
      RecordItem(
        date: DateTime.now().subtract(const Duration(days: 50)),
        summary: 'Annual Blood Test',
        details: 'All readings normal. Vitamin D borderline low.',
      ),
      RecordItem(
        date: DateTime.now().subtract(const Duration(days: 120)),
        summary: 'Allergy Check',
        details: 'Dust allergy mild. Antihistamine PRN.',
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Health Records')),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: records.length,
        itemBuilder: (_, i) {
          final r = records[i];
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: Duration(milliseconds: 240 + 60 * i),
            builder: (_, v, c) => Transform.translate(
              offset: Offset(0, 16 * (1 - v)),
              child: Opacity(opacity: v, child: c),
            ),
            child: Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ExpansionTile(
                leading: const Icon(Icons.folder),
                title: Text(
                  r.summary,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(DateFormat.yMMMd().format(r.date)),
                childrenPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                children: [Text(r.details)],
              ),
            ),
          );
        },
      ),
    );
  }
}

class QRPage extends StatefulWidget {
  const QRPage({super.key});

  @override
  State<QRPage> createState() => _QRPageState();
}

class _QRPageState extends State<QRPage> {
  late String _qrData;
  late DateTime _expiry;

  final Map<String, dynamic> _patientData = {
    "name": "John Doe",
    "age": 35,
    "gender": "Male",
    "bloodGroup": "O+",
    "conditions": ["Diabetes", "Hypertension"],
    "allergies": ["Dust", "Penicillin"],
    "medications": ["Metformin", "Lisinopril"],
    "lastVisit": "2025-08-01",
    "doctor": "Dr. Smith",
    "hospital": "City Heart Center",
    "insurance": "MC-12345",
    "emergencyContact": "+1 555-9876",
    "address": "12 River Ave, Metro City",
  };

  @override
  void initState() {
    super.initState();
    _generate();
  }

  void _generate() {
    final now = DateTime.now();
    _expiry = now.add(const Duration(minutes: 5));

    // Encode patient data + expiry in QR payload
    final payload = {
      "type": "PatientAccess",
      "expiry": _expiry.toIso8601String(),
      "data": _patientData,
    };

    _qrData = jsonEncode(payload);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final expired = DateTime.now().isAfter(_expiry);

    return Scaffold(
      appBar: AppBar(title: const Text('Generate QR')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              duration: const Duration(milliseconds: 250),
              scale: expired ? 0.95 : 1,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x12000000),
                      blurRadius: 14,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: expired
                    ? const Icon(Icons.hourglass_disabled_outlined, size: 160)
                    : QrImageView(data: _qrData, size: 220),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              expired
                  ? 'QR expired • Tap to generate a new code'
                  : 'Valid until: ${DateFormat.Hm().format(_expiry)}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _generate,
              icon: const Icon(Icons.refresh),
              label: const Text('Generate New QR'),
            ),
          ],
        ),
      ),
    );
  }
}

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({super.key});

  @override
  State<AppointmentsPage> createState() => AppointmentsPageState();
}

class AppointmentsPageState extends State<AppointmentsPage> {
  List<Appointment> _items = [];
  bool _loading = true;

  final _nameCtrl = TextEditingController(text: 'John Doe');
  final _concernCtrl = TextEditingController();
  String _doctor = 'Dr. Sarah Johnson';
  DateTime _date = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _time = const TimeOfDay(hour: 10, minute: 0);

  final _doctors = const [
    'Dr. Sarah Johnson (Cardiology)',
    'Dr. Alan White (Dermatology)',
    'Dr. Priya Nair (Neurology)',
    'Dr. Omar Khan (Orthopedics)',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final saved = await Store.loadAppointments();
    setState(() {
      _items = saved;
      _loading = false;
    });
  }

  Future<void> _save() async => Store.saveAppointments(_items);

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: _date,
    );
    if (d != null) setState(() => _date = d);
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(context: context, initialTime: _time);
    if (t != null) setState(() => _time = t);
  }

  void _book() {
    if (_concernCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your concern.')),
      );
      return;
    }
    final dt = DateTime(
      _date.year,
      _date.month,
      _date.day,
      _time.hour,
      _time.minute,
    );
    final appt = Appointment(
      patientName: _nameCtrl.text.trim(),
      concern: _concernCtrl.text.trim(),
      doctor: _doctor,
      dateTime: dt,
    );
    setState(() {
      _items.add(appt);
    });
    _save();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Appointment booked!')));
  }

  @override
  Widget build(BuildContext context) {
    final up =
        _items
            .where((a) => a.dateTime.isAfter(DateTime.now()) && !a.completed)
            .toList()
          ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    final past =
        _items
            .where((a) => a.dateTime.isBefore(DateTime.now()) || a.completed)
            .toList()
          ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointments'),
        actions: [
          IconButton(
            tooltip: 'Messages',
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ThreadsPage()),
              );
              setState(() {}); // in case messages persisted
            },
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _formCard(context),
                const SizedBox(height: 14),
                if (up.isNotEmpty)
                  Text(
                    'Upcoming',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ...up.map(_apptTile),
                const SizedBox(height: 8),
                if (past.isNotEmpty)
                  Text(
                    'Past / Completed',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ...past.map(_apptTile),
                const SizedBox(height: 12),
              ],
            ),
    );
  }

  Widget _formCard(BuildContext context) => Card(
    elevation: 0,
    color: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Book New', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(
              labelText: 'Your Name',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _concernCtrl,
            decoration: const InputDecoration(
              labelText: 'Concern / Disease',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: _doctor,
            decoration: const InputDecoration(
              labelText: 'Doctor',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            items: _doctors
                .map(
                  (d) => DropdownMenuItem(
                    value: d.split(' (').first,
                    child: Text(d),
                  ),
                )
                .toList(),
            onChanged: (v) => setState(() => _doctor = v ?? _doctor),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.event),
                  label: Text(DateFormat.yMMMd().format(_date)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickTime,
                  icon: const Icon(Icons.schedule),
                  label: Text(_time.format(context)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: _book,
              icon: const Icon(Icons.add),
              label: const Text('Book Appointment'),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _apptTile(Appointment a) {
    final dtStr = DateFormat('yyyy-MM-dd  HH:mm').format(a.dateTime);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 260),
      builder: (_, v, c) => Transform.translate(
        offset: Offset(0, 14 * (1 - v)),
        child: Opacity(opacity: v, child: c),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x11000000),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: ListTile(
          leading: const CircleAvatar(child: Icon(Icons.person)),
          title: Text(
            a.doctor,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text('${a.concern}  •  $dtStr'),
          trailing: Wrap(
            spacing: 6,
            children: [
              if (!a.completed)
                IconButton(
                  tooltip: 'Mark done',
                  onPressed: () {
                    setState(() => a.completed = true);
                    _save();
                  },
                  icon: const Icon(Icons.check_circle, color: Colors.green),
                ),
              IconButton(
                tooltip: 'Delete',
                onPressed: () {
                  setState(() => _items.remove(a));
                  _save();
                },
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ThreadsPage extends StatefulWidget {
  const ThreadsPage({super.key});
  @override
  State<ThreadsPage> createState() => _ThreadsPageState();
}

class _ThreadsPageState extends State<ThreadsPage> {
  List<Thread> _threads = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final t = await Store.loadThreads();
    setState(() {
      _threads = t;
      _loading = false;
    });
  }

  Future<void> _persist() async => Store.saveThreads(_threads);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              itemCount: _threads.length,
              separatorBuilder: (_, __) => const SizedBox(height: 6),
              itemBuilder: (_, i) {
                final t = _threads[i];
                final last = t.messages.isNotEmpty
                    ? t.messages.last.text
                    : 'No messages yet';
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: Duration(milliseconds: 240 + (i * 60)),
                  builder: (_, v, c) => Transform.translate(
                    offset: Offset(0, 16 * (1 - v)),
                    child: Opacity(opacity: v, child: c),
                  ),
                  child: Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    child: ListTile(
                      leading: CircleAvatar(child: Icon(t.avatar)),
                      title: Text(
                        t.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        last,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatPage(thread: t),
                          ),
                        );
                        await _persist();
                        setState(() {});
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final newT = await _createThreadDialog(context);
          if (newT != null) {
            setState(() => _threads.insert(0, newT));
            await _persist();
          }
        },
        label: const Text('New'),
        icon: const Icon(Icons.add_comment),
      ),
    );
  }

  Future<Thread?> _createThreadDialog(BuildContext context) async {
    final name = TextEditingController();
    return showDialog<Thread>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Start conversation'),
        content: TextField(
          controller: name,
          decoration: const InputDecoration(
            labelText: 'Doctor/Contact name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(
              context,
              Thread(
                name.text.trim().isEmpty ? 'New Chat' : name.text.trim(),
                Icons.person,
                [],
              ),
            ),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.thread});
  final Thread thread;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ctrl = TextEditingController();

  void _send() async {
    final text = ctrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      widget.thread.messages.add(Message(text, true, DateTime.now()));
      ctrl.clear();
    });
    // simple simulated reply
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() {
      widget.thread.messages.add(Message('Noted 👍', false, DateTime.now()));
    });
  }

  @override
  Widget build(BuildContext context) {
    final msgs = widget.thread.messages;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(child: Icon(widget.thread.avatar)),
            const SizedBox(width: 8),
            Text(widget.thread.name),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: msgs.length,
              itemBuilder: (_, i) {
                final m = msgs[i];
                return Align(
                  alignment: m.isMe
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 200),
                      builder: (_, v, c) => Transform.scale(
                        scale: .92 + .08 * v,
                        child: Opacity(opacity: v, child: c),
                      ),
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 300),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: m.isMe
                              ? Theme.of(context).colorScheme.primary
                              : const Color(0xFFF1F3F6),
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: Radius.circular(m.isMe ? 16 : 4),
                            bottomRight: Radius.circular(m.isMe ? 4 : 16),
                          ),
                        ),
                        child: Text(
                          m.text,
                          style: TextStyle(
                            color: m.isMe ? Colors.white : Colors.black87,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Row(
              children: [
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: ctrl,
                    decoration: const InputDecoration(
                      hintText: 'Type a message…',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(14)),
                      ),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _send,
                  icon: const Icon(Icons.send),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  final String username; // 👈 Pass the logged-in username

  const ProfilePage({super.key, required this.username});

  // Your function to fetch profile image URL from S3
  Future<String?> fetchUserProfileImageUrl(String username) async {
    const baseUrl = 'https://djangotestcase.s3.ap-south-1.amazonaws.com/';
    final extensions = ['jpg', 'jpeg', 'png'];

    for (String ext in extensions) {
      final url = '$baseUrl${username}profile.$ext';
      try {
        final response = await http.head(Uri.parse(url));
        if (response.statusCode == 200) {
          return url;
        }
      } catch (_) {
        // continue trying other extensions
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    stat(String label, String value, IconData icon) => Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x11000000),
              blurRadius: 10,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: Colors.black54)),
          ],
        ),
      ),
    );

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _cover(context, username)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      stat('Age', '32', Icons.cake),
                      const SizedBox(width: 12),
                      stat('Allergies', 'Dust', Icons.coronavirus),
                      const SizedBox(width: 12),
                      stat('Insurance', 'MC-12345', Icons.local_hospital),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _card(
                    context,
                    'About Me',
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _kv('Name', 'John Doe'),
                        _kv('Gender', 'Male'),
                        _kv('Conditions', 'Hypertension'),
                        _kv('Primary Hospital', 'City Medical Center'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _card(
                    context,
                    'Contacts',
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _kv('Email', 'john.doe@example.com'),
                        _kv('Phone', '+1 555-0123'),
                        _kv('Address', '12 River Ave, Metro City'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Profile header with avatar + name
  Widget _cover(BuildContext context, String username) => Container(
    padding: const EdgeInsets.fromLTRB(16, 42, 16, 20),
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0xFF2D5D8A), Color(0xFF3E7FB2)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    child: Row(
      children: [
        FutureBuilder<String?>(
          future: fetchUserProfileImageUrl(username),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircleAvatar(
                radius: 38,
                child: CircularProgressIndicator(color: Colors.white),
              );
            } else if (snapshot.hasData && snapshot.data != null) {
              return CircleAvatar(
                radius: 38,
                backgroundImage: NetworkImage(snapshot.data!),
              );
            } else {
              return const CircleAvatar(
                radius: 38,
                backgroundImage: AssetImage('assets/patient.jpg'),
              );
            }
          },
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                Provider.of<resource>(
                  context,
                  listen: false,
                ).PresentWorkingUser,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                Provider.of<resource>(
                  context,
                  listen: false,
                ).PresentWorkingUser2,
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  /// Reusable card with animation
  Widget _card(BuildContext context, String title, Widget child) =>
      TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 300),
        builder: (_, v, c) => Transform.translate(
          offset: Offset(0, 16 * (1 - v)),
          child: Opacity(opacity: v, child: c),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x11000000),
                blurRadius: 10,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              child,
            ],
          ),
        ),
      );

  /// Key-value text pair
  static Widget _kv(String key, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Text(
          "$key: ",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
      ],
    ),
  );
}

class _kv extends StatelessWidget {
  _kv(this.k, this.v);
  final String k, v;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(k, style: const TextStyle(color: Colors.black54)),
          ),
          Expanded(
            child: Text(v, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
