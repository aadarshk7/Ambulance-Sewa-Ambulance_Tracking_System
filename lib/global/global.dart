import 'package:firebase_auth/firebase_auth.dart';

import '../models/usermodel.dart';

final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    User? currentUser;
 UserModel? userModelCurrentInfo;
 String userDropOffAddress = '';
