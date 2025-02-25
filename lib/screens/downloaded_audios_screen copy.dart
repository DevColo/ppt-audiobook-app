import 'dart:io';

import 'package:flutter/material.dart';
import 'package:precious/providers/audio_books_provider.dart';
import 'package:precious/screens/audio_player_screen.dart';
import 'package:precious/utils/config.dart';
import 'package:precious/utils/localization_service.dart';
import 'package:provider/provider.dart';

class DownloadedAudiosScreen extends StatelessWidget {
  const DownloadedAudiosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final downloadedFiles =
        Provider.of<AudioBooksProvider>(context).downloadedFiles;

    return Scaffold(
      backgroundColor: Config.greyColor,
      appBar: AppBar(
        backgroundColor: Config.whiteColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Config.darkColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          LocalizationService().translate('downloads'),
          style: const TextStyle(
            fontSize: 14,
            fontFamily: 'Montserrat-SemiBold',
            color: Config.darkColor,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 1.0,
          horizontal: 10.0,
        ),
        child: Column(
          children: [
            const SizedBox(height: 2.0),
            // New Releases Section - Vertically scrollable inside the remaining screen space
            Expanded(
              child: ListView.builder(
                itemCount: downloadedFiles.length,
                itemBuilder: (context, index) {
                  final filePath = downloadedFiles[index];
                  final fileName = filePath.split('/').last;
                  return audioCard(context, fileName, filePath);
                },
              ),
            ),
          ],
        ),
      ),
      // body: ListView.builder(
      //   itemCount: downloadedFiles.length,
      //   itemBuilder: (context, index) {
      //     final filePath = downloadedFiles[index];
      //     final fileName = filePath.split('/').last;

      //     return audioCard(context, fileName, filePath);
      //   },
      // ),
    );
  }

  Widget audioCard(BuildContext context, String fileName, String filePath) {
    // return Padding(
    //   padding: const EdgeInsets.symmetric(vertical: 6.0),
    //   child: GestureDetector(
    //     onTap: () {
    //       Navigator.push(
    //         context,
    //         MaterialPageRoute(
    //           builder: (context) => AudioPlayerScreen(filePath: filePath),
    //         ),
    //       );
    //     },
    //     child: Container(
    //       decoration: BoxDecoration(
    //         color: Colors.white,
    //         borderRadius: BorderRadius.circular(10),
    //       ),
    //       padding: const EdgeInsets.only(right: 8.0),
    //       child: Row(
    //         children: [
    //           Column(
    //             crossAxisAlignment: CrossAxisAlignment.start,
    //             children: [
    //               SizedBox(
    //                 width: 170.0,
    //                 child: Text(
    //                   fileName,
    //                   style: const TextStyle(
    //                     color: Color.fromARGB(255, 0, 0, 0),
    //                     fontFamily: 'Montserrat-SemiBold',
    //                     fontSize: 11,
    //                   ),
    //                 ),
    //               ),
    //             ],
    //           ),
    //           const Spacer(),
    //           const Icon(
    //             Icons.arrow_forward_ios,
    //             color: Config.primaryColor,
    //             size: 18.0,
    //           ),
    //         ],
    //       ),
    //     ),
    //   ),
    // );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AudioPlayerScreen(filePath: filePath),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.only(right: 8.0),
          child: Row(
            children: [
              Container(
                height: 40,
                width: 10,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10.0),
                    bottomLeft: Radius.circular(10.0),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 170.0,
                    child: Text(
                      fileName,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0),
                        fontFamily: 'Montserrat-SemiBold',
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(
                  Icons.delete,
                  color: Colors.red,
                  size: 15.0,
                ),
                onPressed: () {
                  // Delete the file
                  final file = File(filePath);
                  if (file.existsSync()) {
                    file.deleteSync();
                    Provider.of<AudioBooksProvider>(context, listen: false)
                        .removeDownloadedFile(filePath);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('$fileName deleted successfully!')),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
