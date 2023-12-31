import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:record_with_play/services/permission_management.dart';
import 'package:record_with_play/services/storage_management.dart';
import 'package:record_with_play/services/toast_services.dart';
import 'dart:io' as io;

class RecordAudioProvider extends ChangeNotifier {
  final Record _record = Record();
  bool _isRecording = false;
  String _afterRecordingFilePath = '';

  bool get isRecording => _isRecording;
  String get recordedFilePath => _afterRecordingFilePath;

  clearOldData() {
    _afterRecordingFilePath = '';
    notifyListeners();
  }

  recordVoice() async {
    final _isPermitted = (await PermissionManagement.recordingPermission()) &&
        (await PermissionManagement.storagePermission());

    if (!_isPermitted) return;

    if (!(await _record.hasPermission())) return;

    final _voiceDirPath = await StorageManagement.getAudioDir;
    final _voiceFilePath = StorageManagement.createRecordAudioPath(
        dirPath: _voiceDirPath, fileName: 'audio_message');

    await _record.start(path: _voiceFilePath);
    _isRecording = true;
    notifyListeners();

    showToast('Recording Started');
  }

  stopRecording() async {
    String? _audioFilePath;

    if (await _record.isRecording()) {
      _audioFilePath = await _record.stop();
      showToast('Recording Stopped');
    }

    print('Audio file path: $_audioFilePath');

    _isRecording = false;
    _afterRecordingFilePath = _audioFilePath ?? '';
    print(_afterRecordingFilePath);
    notifyListeners();
  }

  List<int> getAudioContent() {
    return io.File(_afterRecordingFilePath).readAsBytesSync().toList();
  }
}
