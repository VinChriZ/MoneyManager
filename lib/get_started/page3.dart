import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class Page3 extends StatelessWidget {
  const Page3({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Padding(
          padding: EdgeInsets.only(left: 50.0, top: 40, right: 40),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              child: Container(
                child: Column(
                  children: [
                    Container(
                      child: SvgPicture.asset(
                        'lib/assets/Illustration3.svg',
                        fit: BoxFit.contain,
                      ),
                    ),
                    Container(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Planning ahead",
                              style: GoogleFonts.inter(
                                  fontSize: 30, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Text(
                              "Setup your budget for each",
                              style: GoogleFonts.inter(
                                  fontSize: 16,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500),
                            ),
                            Text(
                              "category so you in control",
                              style: GoogleFonts.inter(
                                  fontSize: 16,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
