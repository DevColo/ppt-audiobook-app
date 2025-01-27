import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:precious/providers/collections_provider.dart';
import 'package:precious/utils/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  // Helper function to map collection titles to image assets
  String _getImageForTitle(String title) {
    switch (title.toLowerCase()) {
      case 'kinyarwanda':
        return 'assets/images/kinyarwanda.png';
      case 'english':
        return 'assets/images/english.png';
      case 'french':
        return 'assets/images/french.png';
      case 'kiswahili':
        return 'assets/images/kiswahili.png';
      case 'lingala':
        return 'assets/images/lingala.png';
      default:
        return 'assets/images/default.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    final collectionsProvider = Provider.of<CollectionsProvider>(context);

    // page loader
    const spinkit = SpinKitSpinningLines(
      color: Config.primaryColor,
    );

    // Show loader if data is still being fetched or screen is loading
    if (_isLoading || collectionsProvider.collections.isEmpty) {
      return const Scaffold(
        body: Center(
          child: spinkit,
        ),
      );
    }

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
                  'assets/images/logo.png',
                  width: 130.0,
                ),
                const SizedBox(height: 20.0),
                ...collectionsProvider.collections.map((collection) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: ElevatedButton(
                      onPressed: () async {
                        // Send the selected language to backend
                        await collectionsProvider
                            .selectLanguage(collection['title']);

                        // Save the selected language to SharedPreferences
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        await prefs.setString(
                            'selectedLanguage', collection['title']);

                        // Navigate to the main screen
                        Navigator.pushNamed(context, 'main');
                      },
                      style: ButtonStyle(
                        backgroundColor:
                            WidgetStateProperty.all(Config.greyColor),
                        fixedSize: WidgetStateProperty.all(
                          Size(Config.buttonNormalWidth,
                              Config.buttonNormalHeight),
                        ),
                        elevation: WidgetStateProperty.all(0),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            _getImageForTitle(collection['title']),
                            height: 24,
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 140,
                            child: Text(
                              collection['title'],
                              style: const TextStyle(
                                fontSize: 13,
                                color: Config.darkColor,
                                fontFamily: 'Montserrat-SemiBold',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
