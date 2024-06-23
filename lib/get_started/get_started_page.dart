import 'package:flutter/material.dart';
import 'package:flutter_moneymanager/Profile/data_user.dart';
import 'package:flutter_moneymanager/auth_page.dart';
import 'package:flutter_moneymanager/get_started/page1.dart';
import 'package:flutter_moneymanager/get_started/page2.dart';
import 'package:flutter_moneymanager/get_started/page3.dart';
import 'package:flutter_moneymanager/login.dart';
import 'package:flutter_moneymanager/main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class GetStartedPage extends StatefulWidget {
  const GetStartedPage({super.key});

  @override
  State<GetStartedPage> createState() => _GetStartedPageState();
}

class _GetStartedPageState extends State<GetStartedPage> {
  final _controller = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 540,
              child: PageView(
                scrollDirection: Axis.horizontal,
                controller: _controller,
                children: const [
                  Page1(),
                  Page2(),
                  Page3(),
                ],
              ),
            ),
            Container(
              child: SmoothPageIndicator(
                controller: _controller,
                count: 3,
                effect: ScaleEffect(
                  //try: //SwapEffect //JumpingDotEffect
                  activeDotColor: Colors.deepPurple,
                  dotColor: Colors.deepPurple.shade100,
                  scale: 1.8,
                  dotHeight: 10,
                  dotWidth: 10,
                  spacing: 20,
                  // verticalOffset: 10,  //used in JumpingDotEffect
                  // jumpScale: 3, //used in JumpingDotEffect
                ),
              ),
            ),
            SizedBox(
              height: 16,
            ),
            Padding(
              padding: const EdgeInsets.all(36.0),
              child: MaterialButton(
                onPressed: () {
                  if (_controller.page != 2) {
                    _controller.nextPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  } else {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) =>AuthPage()),
                    );
                  }
                },
                color: Colors.deepPurple[400],
                height: 70,
                minWidth: double.infinity,
                child: Text(
                  "Get Started",
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: Colors.white),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
              ),
            )
          ]),
    );
  }
}
