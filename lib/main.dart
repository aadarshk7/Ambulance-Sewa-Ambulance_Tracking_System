import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import flutter_dotenv
import 'package:firebase_core/firebase_core.dart';
import 'package:ambulancesewa/infoHandler/app_info.dart';
import 'package:ambulancesewa/screens/choicepage.dart';
import 'package:ambulancesewa/adminpage/admin_page.dart';
import 'package:ambulancesewa/adminpage/adminuserpage.dart';
import 'package:ambulancesewa/userpage/messagedriver.dart';
import 'package:ambulancesewa/userpage/messagerequest.dart';
import 'package:ambulancesewa/userpage/user_page.dart';
import 'package:ambulancesewa/userpage/user_search_places.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'adminpage/admin_driverinsert.dart';
import 'adminpage/admindriverdetails.dart';
import 'adminpage/adminoptionpage.dart';
import 'driverpage/LoginDriver.dart';
import 'driverpage/driver_page.dart';
import 'login_signup/phoneopt.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(); // Load environment variables

  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: dotenv.env['AIzaSyCqj-IOPAmA8EBYdZmfeHziysnWElv_71U']!,
      appId: dotenv.env['1:449261236794:web:449261236794']!,
      messagingSenderId: dotenv.env['449261236794']!,
      projectId: dotenv.env['ambulancesewa-b1f26']!,
    ),
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppInfo(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: ChoicePage(),
        routes: {
          '/choicepage': (_) => ChoicePage(),
          '/admin_page': (_) => AdminPage(),
          '/phoneotp': (_) => PhoneOTP(),
          '/user_page': (_) => UserPage(),
          '/driver_page': (_) => DriverPage(),
          '/adminuserpage': (_) => GetUser(),
          '/adminoptionpage': (_) => AdminDriver(),
          '/admindriverdetails': (_) => AdminDriverDetails(),
          '/admin_driverinsert': (_) => DriverInsertPage(),
          '/LoginDriver': (_) => LoginDriver(),
          '/messagedriver': (_) => MessageDriver(),
          '/messagerequest': (_) => MessageRequest(),
        },
      ),
    );
  }
}
//}
