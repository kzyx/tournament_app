/// This file contains classes and/or functions relating to the video player
/// that we use in this app to play highlight footage from selected games.
import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

/// This represents a video player widget popup that utilizes the Chewie player.
/// Important point: The use of uniqueKey means that we only ever have one
/// instance of this class.
class VideoPlayerPopup extends StatefulWidget {
  final String videoURL;
  final UniqueKey uniqueKey;

  const VideoPlayerPopup(this.videoURL, this.uniqueKey)
      : super(key: uniqueKey);
  @override
  _VideoPlayerPopupState createState() => _VideoPlayerPopupState();
}

/// This is the private State class for the VideoPlayerPopup.
class _VideoPlayerPopupState extends State<VideoPlayerPopup> {
  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;
  late Chewie _chewie;

  @override
  Widget build(BuildContext context) {
    // Establish link to URL, and then initialize.
    _videoPlayerController = VideoPlayerController.network(widget.videoURL);
    return FutureBuilder<void>(
        future: _videoPlayerController.initialize(),
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          _chewieController = ChewieController(
            videoPlayerController: _videoPlayerController,
            autoPlay: false,
            looping: false,
          );
          _chewie = Chewie(controller: _chewieController);
          return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(80)),
              elevation: 50,
              backgroundColor: Colors.transparent,
              child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: SizedBox(
                    width: _videoPlayerController.value.size.width,
                    height: _videoPlayerController.value.size.height * 0.5,
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: _chewie),
                  )));
        });
  }

  @override
  void dispose() {
    _chewieController.dispose();
    _videoPlayerController.dispose();
    super.dispose();
  }
}
