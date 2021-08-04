import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:just_audio/just_audio.dart';

class GwaPlayerState with ChangeNotifier {
  AudioPlayer audioPlayer;
  ConcatenatingAudioSource playlist;
  IndexedAudioSource currentIndexedAudioSource;
  List<IndexedAudioSource> effectiveSequence;
  ValueNotifier<Duration> audioProgressNotifier;
  ValueNotifier<bool> playerActiveNotifier;

  GwaPlayerState() {
    audioPlayer = AudioPlayer();
    playlist = ConcatenatingAudioSource(children: []);
    audioProgressNotifier = ValueNotifier<Duration>(Duration.zero);
    playerActiveNotifier = ValueNotifier(false);
  }

  bool get isPlaying => audioPlayer.playing;

  Stream<SequenceState> get sequenceStateStream =>
      audioPlayer.sequenceStateStream;

  String get currentAudioSourceTitle {
    if (currentIndexedAudioSource == null) return null;
    return (currentIndexedAudioSource.tag as AudioData).title;
  }

  String get currentAudioSourceFileTitle {
    if (currentIndexedAudioSource == null) return null;
    return (currentIndexedAudioSource.tag as AudioData).fileTitle;
  }

  String get currentAudioSourceAuthor {
    if (currentIndexedAudioSource == null) return null;
    return (currentIndexedAudioSource.tag as AudioData).author;
  }

  String get currentAudioSourceAuthorFlairText {
    if (currentIndexedAudioSource == null) return null;
    return (currentIndexedAudioSource.tag as AudioData).authorFlairText;
  }

  String get currentAudioSourceCoverUrl {
    if (currentIndexedAudioSource == null) return null;
    return (currentIndexedAudioSource.tag as AudioData).coverUrl;
  }

  String get currentAudioSourceSubmissionFullname {
    if (currentIndexedAudioSource == null) return '';
    return (currentIndexedAudioSource.tag as AudioData).submissionFullname;
  }

  init() async {
    await audioPlayer.setAudioSource(playlist);
    audioPlayer.sequenceStateStream.listen((SequenceState sequenceState) {
      currentIndexedAudioSource = sequenceState.currentSource;
      effectiveSequence = sequenceState.effectiveSequence;
      notifyListeners();
    });
    audioPlayer.positionStream.listen((Duration duration) {
      audioProgressNotifier.value = duration;
    });
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  seekToNext() async => audioPlayer.seekToNext();

  Future<void> clearPlaylist() => playlist.clear();

  Future<Duration> addAudioToPlaylist(String url, AudioData audioData) async {
    final audioSource = AudioSource.uri(Uri.parse(url), tag: audioData);
    await playlist.add(audioSource);
    playerActiveNotifier.value = true;
    notifyListeners();
    return audioSource.duration;
  }

  insertAudioToPlaylist(String url, AudioData audioData) async {
    final int currentIndex = audioPlayer.currentIndex;
    if (currentIndex + 1 == playlist.length || audioPlayer.nextIndex == null) {
      addAudioToPlaylist(url, audioData);
    } else {
      final audioSource = AudioSource.uri(Uri.parse(url), tag: audioData);
      await playlist.insert(audioPlayer.currentIndex + 1, audioSource);
    }
  }

  Future<void> play() {
    final play = audioPlayer.play();
    notifyListeners();
    return play;
  }

  Future<void> pause() {
    final pause = audioPlayer.pause();
    notifyListeners();
    return pause;
  }

  skipSeconds(int seconds) {
    return audioPlayer.seek(Duration(
        seconds: min(max(audioPlayer.position.inSeconds + seconds, 0),
            currentIndexedAudioSource.duration.inSeconds)));
  }

  dismissPlayer() {
    playerActiveNotifier.value = false;
    notifyListeners();
  }
}

class AudioData {
  final String title;
  final String fileTitle;
  final String author;
  final String authorFlairText;
  final String coverUrl;
  final String submissionFullname;

  const AudioData(this.title, this.fileTitle, this.author, this.authorFlairText,
      this.coverUrl, this.submissionFullname);
}
