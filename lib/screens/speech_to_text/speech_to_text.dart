import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_speech/speech_client_authenticator.dart';
import 'package:google_speech/google_speech.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';
import 'dart:io' as io;
import 'dart:async';

import 'package:record_with_play/providers/record_audio_provider.dart';

class SpeechToTxt extends StatefulWidget {
  const SpeechToTxt({super.key});
  static const String nameRoute = "SpeechToTxt";

  @override
  State<SpeechToTxt> createState() => _SpeechToTxtState();
}

class _SpeechToTxtState extends State<SpeechToTxt> {
  bool isTranscribing = false;
  String content = "";
/*
  void transcribe(List<int> audio) async {
    setState(() {
      isTranscribing = true;
    });
    final serviceAccount = ServiceAccount.fromString(
        "${await rootBundle.loadString("assets/angelic-gift-398808-44e3eddc0b16.json")}");
    final speechToText = SpeechToText.viaServiceAccount(serviceAccount);
    final config = RecognitionConfig(
      audioChannelCount: 2,
      encoding: AudioEncoding.LINEAR16,
      model: RecognitionModel.basic,
      enableAutomaticPunctuation: true,
      sampleRateHertz: 4410,
      languageCode: 'en-US',
    );
    await speechToText.recognize(config, audio).then((value) {
      setState(() {
        content = value.results
            .map((e) => e.alternatives.first.transcript)
            .join('\n');
      });
    }).whenComplete(() {
      setState(() {
        isTranscribing = false;
      });
    });
  }
  void getAoudio() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path.toString());
      print(file.path);
    } else {
    }
  }*/

  @override
  Widget build(BuildContext context) {
    final _recordProvider = Provider.of<RecordAudioProvider>(context);
    void transcribe() async {
      try {
        setState(() {
          isTranscribing = true;
        });
        final serviceAccount = ServiceAccount.fromString(
            "${await rootBundle.loadString("assets/angelic-gift-398808-44e3eddc0b16.json")}");
        final speechToText = SpeechToText.viaServiceAccount(serviceAccount);
        final config = RecognitionConfig(
            encoding: AudioEncoding.LINEAR16, languageCode: 'en-US');
        await speechToText
            .recognize(config, _recordProvider.getAudioContent())
            .then((value) {
          setState(() {
            content = value.results
                .map((e) => e.alternatives.first.transcript)
                .join('\n');
          });
        }).whenComplete(() {
          setState(() {
            isTranscribing = false;
          });
        });
      } catch (e) {
        print("Error Speeth to text : $e");
      }
    }

    return SingleChildScrollView(
      child: Container(
        height: 350,
        width: 350,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(50),
                bottomRight: Radius.circular(50))),
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 70),
            Container(
              height: 200,
              width: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.all(5),
              child: content == ""
                  ? Text(
                      "Your text will appear here",
                      style: TextStyle(color: Colors.grey),
                    )
                  : Text(content, style: TextStyle(fontSize: 20)),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              child: isTranscribing
                  ? Expanded(
                      child: LoadingIndicator(
                      indicatorType: Indicator.ballPulse,
                      colors: [Colors.red, Colors.green, Colors.blue],
                    ))
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          elevation: 10,
                          backgroundColor: Colors.amber,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15))),
                      onPressed: isTranscribing ? () {} : transcribe,
                      child: isTranscribing
                          ? CircularProgressIndicator()
                          : Text(
                              "Transcribe",
                              style: TextStyle(fontSize: 20),
                            )),
            )
          ],
        )),
      ),
    );
  }
}
