import 'package:daily_manage_user_app/providers/user_provider.dart';
import 'package:daily_manage_user_app/screens/admin_screens/nav_screens/leaves_management/admin_leaves_report_screen.dart';
import 'package:daily_manage_user_app/screens/admin_screens/nav_screens/leaves_management/widgets/admin_leaves_widget.dart';
import 'package:daily_manage_user_app/screens/admin_screens/nav_screens/users_management/admin_users_management_screen.dart';
import 'package:daily_manage_user_app/screens/admin_screens/nav_screens/works_management/admin_work_hours_report_screen.dart';
import 'package:daily_manage_user_app/screens/common_screens/splash_screens.dart';
import 'package:daily_manage_user_app/screens/common_screens/widgets/splash_next_screen_widget.dart';
import 'package:daily_manage_user_app/screens/common_screens/widgets/splash_widget.dart';
import 'package:daily_manage_user_app/screens/admin_screens/nav_screens/users_management/widgets/screens/admin_create_new_user_screen.dart';
import 'package:daily_manage_user_app/screens/user_screens/user_main_screen.dart';
import 'package:daily_manage_user_app/screens/responsive.dart';
import 'package:daily_manage_user_app/screens/temp.dart';
import 'package:daily_manage_user_app/services/sockets/leave_socket.dart';
import 'package:daily_manage_user_app/services/sockets/work_socket.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';

import 'models/leave.dart';
import 'models/work.dart';
void main() async{
  // WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  // FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Chặn xoay ngang màn hình
  WidgetsFlutterBinding.ensureInitialized();
  WorkSocket.initSocketConnection();
  LeaveSocket.initSocketConnection();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('vi_VN', null); // Khởi tạo ngôn ngữ Việt Nam


// Khởi tạo Hive trong main
  await Hive.initFlutter();
  await Hive.openBox('appSettingsBoxLeave'); // Mở box cho cài đặt
  await Hive.openBox('appSettingsBoxWork'); // Mở box cho cài đặt


  Hive.registerAdapter(LeaveAdapter()); // <- auto-gen từ `build_runner`
  await Hive.openBox<Leave>('leaveCacheBox'); // tên tuỳ bạn

  Hive.registerAdapter(WorkAdapter());
  await Hive.openBox<Work>('workCacheBox'); // 👈 tên box


  runApp(ProviderScope(child: const MyApp()));

}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  Future<void> _checkTokenAndUser(WidgetRef ref) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('auth_token');
    String? userJson = preferences.getString('user');
    if(token != null &&  userJson != null){
      ref.read(userProvider.notifier).setUser(userJson);
    }else{
      ref.read(userProvider.notifier).signOut();
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,



      // ✅ Thêm các dòng sau:
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        MonthYearPickerLocalizations.delegate, // ✅ cần thiết!
      ],
      supportedLocales: const [
        Locale('en'), // hoặc thêm Locale('vi') nếu bạn dùng tiếng Việt
        Locale('vi'),
      ],




      title: 'Flutter Demo',

      // theme: ThemeData(
      //   // tested with just a hot reload.
      //   colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      //   // fontFamily: 'roboto',
      //   // fontFamily: 'opz',
      // ),
      theme:
      // ThemeData(
      //   textTheme: GoogleFonts.jostTextTheme(),
      // ),
      // ThemeData(
      //   textTheme: GoogleFonts.robotoTextTheme(),
      // ),
      // ThemeData(
      //   textTheme: GoogleFonts.interTextTheme(),
      // ),
      ThemeData(
        textTheme: GoogleFonts.beVietnamProTextTheme(),
      ),

      routes: {
        '/leaves': (context) => AdminLeavesReportScreen(),
        '/works': (context) => AdminWorkHoursReportScreen(),
        '/users': (context) => AdminUsersManagementScreen(),
        // Thêm các route khác nếu cần
      },
      home: SplashScreens(),
      // home: SplashWidget(),
      // home: SplashNextScreenWidget(screenWidget: LoginScreen()),
      // home: FutureBuilder(future: _checkTokenAndUser(ref), builder: (context, snapshot) {
      //   if(snapshot.connectionState == ConnectionState.waiting){
      //     return Center(child: CircularProgressIndicator(),);
      //   }
      //   final user = ref.watch(userProvider);
      //   // return user!= null ? LeaveScreenTemp() :LeaveScreenTemp();
      //   return user!= null ? MainScreen() :LoginScreen();
      //   // return user!= null ? SplashScreens() :LoginScreen();
      //   // return user!= null ? AdminRegisterScreen() :AdminRegisterScreen();
      //   // return user!= null ? NavigatorBottomBar() :NavigatorBottomBar();
      //   // return user!= null ? Responsive() :Responsive();
      //   // return user!= null ? LeaveTypeDropdown() :LeaveTypeDropdown();
      // },),
    );
  }
}
