import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

/// This represents a video player widget popup that utilizes the Chewie player
class VideoPlayerPopup extends StatefulWidget {
  final String videoLink;
  final UniqueKey newKey;

  VideoPlayerPopup(this.videoLink, this.newKey) : super(key: newKey);
  @override
  _VideoPlayerPopupState createState() => _VideoPlayerPopupState();
}

/// This is the private State class for the VideoPlayerPopup
class _VideoPlayerPopupState extends State<VideoPlayerPopup> {
  late VideoPlayerController _vpCtrl;
  late ChewieController _chewCtrl;
  late Chewie _chew;

  @override
  Widget build(BuildContext context) {
    // Establish link to URL, and then initialize.
    _vpCtrl = VideoPlayerController.network(widget.videoLink);
    return FutureBuilder<void>(
        future: _vpCtrl.initialize(),
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          _chewCtrl = ChewieController(
            videoPlayerController: _vpCtrl,
            autoPlay: false,
            looping: false,
          );
          _chew = Chewie(controller: _chewCtrl);
          return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(80)),
              elevation: 50,
              backgroundColor: Colors.transparent,
              child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: SizedBox(
                    width: _vpCtrl.value.size.width,
                    height: _vpCtrl.value.size.height * 0.5,
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(15), child: _chew),
                  )));
        });
  }

  @override
  void dispose() {
    _chewCtrl.dispose();
    _vpCtrl.dispose();
    super.dispose();
  }
}
