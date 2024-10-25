import 'package:precious/src/static_images.dart';
import 'package:precious/utils/config.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

// page loader
const spinkit = SpinKitThreeBounce(
  color: Config.primaryColor,
);

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // load for 3 secs
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // show the loader
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: spinkit,
        ),
      );
    }
    // render the content
    return Scaffold(
      backgroundColor: Config.whiteColor,
      body: SingleChildScrollView(
        child: Container(
          color: Config.whiteColor,
          height: Config.screenHeight,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50.0),
                Image.asset(
                  preciousLogo,
                  scale: 0.05,
                  alignment: Alignment.center,
                  width: 210.0,
                ),
                const SizedBox(height: 1.0),
                //const WelcomeTitleFirst(),
                //const WelcomeTitleSecond(),
                //const SizedBox(height: 25.0),
                //const WelcomeSubTitle(),
                const SizedBox(height: 60.0),
                //const ManualSignInButton(),
                const SizedBox(height: 20.0),
                const EnglishButton(),
                const SizedBox(height: 20.0),
                const FrenchButton(),
                const SizedBox(height: 20.0),
                const KinyarwandaButton(),
                const SizedBox(height: 20.0),
                const SwahiliButton(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Welcome main title
class WelcomeTitleFirst extends StatelessWidget {
  const WelcomeTitleFirst({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Center(
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: DefaultTextStyle.of(context).style,
            children: const <TextSpan>[
              TextSpan(
                text: 'Find Your ',
                style: TextStyle(
                  fontSize: 20,
                  color: Config.darkColor,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Montserrat-SemiBold',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Welcome main title
class WelcomeTitleSecond extends StatelessWidget {
  const WelcomeTitleSecond({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Center(
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: DefaultTextStyle.of(context).style,
            children: const <TextSpan>[
              TextSpan(
                text: 'Incredible Soulmate',
                style: TextStyle(
                  fontSize: 20,
                  color: Config.darkColor,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Montserrat-SemiBold',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Welcome sub title
class WelcomeSubTitle extends StatelessWidget {
  const WelcomeSubTitle({super.key});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: Center(
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: DefaultTextStyle.of(context).style,
            children: const <TextSpan>[
              TextSpan(
                text:
                    'Favroite Meet, your companion for meaningful connection.',
                style: TextStyle(
                  fontSize: 13,
                  color: Color.fromARGB(255, 120, 120, 120),
                  fontWeight: FontWeight.w500,
                  fontFamily: 'OoohBaby',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// sign up button
class SignUp extends StatelessWidget {
  const SignUp({super.key});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: Center(
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: DefaultTextStyle.of(context).style,
            children: <TextSpan>[
              const TextSpan(
                text: "You don't have an account ? ",
                style: TextStyle(
                  fontSize: 13,
                  color: Color.fromARGB(255, 0, 0, 0),
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Montserrat',
                ),
              ),
              TextSpan(
                text: 'Sign up',
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //       builder: (context) => const RegisterScreen()),
                    // );
                  },
                style: const TextStyle(
                  fontSize: 13,
                  color: Config.primaryColor,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Montserrat',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Manual Sign In Button
// class ManualSignInButton extends StatelessWidget {
//   const ManualSignInButton({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return ElevatedButton(
//       onPressed: () {
//         // Navigator.push(
//         //   context,
//         //   MaterialPageRoute(builder: (context) => const LoginScreen()),
//         // );
//       },
//       style: ButtonStyle(
//         backgroundColor: WidgetStateProperty.all(Config.primaryColor),
//         fixedSize: WidgetStateProperty.all(
//             Size(Config.buttonNormalWidth, Config.buttonNormalHeight)),
//         elevation: WidgetStateProperty.all(0),
//       ),
//       child: const Text(
//         "Find Someone",
//         style: TextStyle(
//           fontSize: 13,
//           color: Color.fromARGB(255, 255, 255, 255),
//           fontFamily: 'Montserrat-SemiBold',
//         ),
//       ),
//     );
//   }
// }

// English Button
class EnglishButton extends StatelessWidget {
  const EnglishButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pushNamed(context, 'main');
      },
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(Config.greyColor),
        fixedSize: WidgetStateProperty.all(
            Size(Config.buttonNormalWidth, Config.buttonNormalHeight)),
        elevation: WidgetStateProperty.all(0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            engImg,
            height: 22,
          ),
          const SizedBox(width: 8),
          const SizedBox(
            width: 140,
            child: Text(
              "English Language",
              style: TextStyle(
                fontSize: 13,
                color: Config.darkColor,
                fontFamily: 'Montserrat-SemiBold',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// French Button
class FrenchButton extends StatelessWidget {
  const FrenchButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pushNamed(context, 'main');
      },
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(Config.greyColor),
        fixedSize: WidgetStateProperty.all(
            Size(Config.buttonNormalWidth, Config.buttonNormalHeight)),
        elevation: WidgetStateProperty.all(0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            frImg,
            height: 22,
          ),
          const SizedBox(width: 8),
          const SizedBox(
            width: 143,
            child: Text(
              "French Language",
              style: TextStyle(
                fontSize: 13,
                color: Config.darkColor,
                fontFamily: 'Montserrat-SemiBold',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Kinyarwanda Button
class KinyarwandaButton extends StatelessWidget {
  const KinyarwandaButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pushNamed(context, 'main');
      },
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(Config.greyColor),
        fixedSize: WidgetStateProperty.all(
            Size(Config.buttonNormalWidth, Config.buttonNormalHeight)),
        elevation: WidgetStateProperty.all(0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            rwImg,
            height: 24,
          ),
          const SizedBox(width: 8),
          const SizedBox(
            width: 140,
            child: Text(
              "Kinyarwanda Language",
              style: TextStyle(
                fontSize: 13,
                color: Config.darkColor,
                fontFamily: 'Montserrat-SemiBold',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Swahili Button
class SwahiliButton extends StatelessWidget {
  const SwahiliButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pushNamed(context, 'main');
      },
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(Config.greyColor),
        fixedSize: WidgetStateProperty.all(
            Size(Config.buttonNormalWidth, Config.buttonNormalHeight)),
        elevation: WidgetStateProperty.all(0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            swImg,
            height: 24,
          ),
          const SizedBox(width: 8),
          const SizedBox(
            width: 140,
            child: Text(
              "Swahili Language",
              style: TextStyle(
                fontSize: 13,
                color: Config.darkColor,
                fontFamily: 'Montserrat-SemiBold',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
