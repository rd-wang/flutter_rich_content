import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:roobo_rich_content/seek_bar.dart';
import 'package:roobo_video/video_widget/media_listener.dart';

import 'config_ui_value.dart';

class PageDetailAudioItemWidget extends StatefulWidget {
  final String? name;
  final String? url;
  final int duration;
  final MediaStartPlay? startPlay;

  const PageDetailAudioItemWidget({Key? key, this.name, this.url, this.duration = 0, this.startPlay}) : super(key: key);

  @override
  _PageDetailAudioItemWidgetState createState() => _PageDetailAudioItemWidgetState();
}

class _PageDetailAudioItemWidgetState extends State<PageDetailAudioItemWidget> {
  double progress = 0.0;

  AudioPlayer audioPlayer = AudioPlayer();
  MediaController? mediaController;

  bool isPlay = false;

  int maxDuration = 0;
  int processDuration = 0;
  bool canPlay = true;
  bool isCompleted = false;

  @override
  void initState() {
    super.initState();
    mediaController = MediaController();
    audioPlayer.setSourceUrl(widget.url!);
    audioPlayer.onPlayerStateChanged.listen((PlayerState s) {
      switch (s) {
        case PlayerState.stopped:
          isPlay = false;
          isCompleted = false;
          break;
        case PlayerState.playing:
          isPlay = true;
          isCompleted = false;
          break;
        case PlayerState.paused:
          isPlay = false;
          isCompleted = false;
          break;
        case PlayerState.completed:
          isPlay = false;
          isCompleted = true;
          progress = 0.0;
          break;
      }
      if (mounted) {
        setState(() {});
      }
    });
    audioPlayer.onDurationChanged.listen((Duration d) {
      if (mounted) {
        setState(() {
          maxDuration = d.inSeconds;
        });
      }
    });
    audioPlayer.onPositionChanged.listen((Duration p) {
      if (mounted) {
        setState(() {
          if (p.inSeconds != null && p.inSeconds != 0 && maxDuration != 0 && maxDuration != null) {
            progress = p.inSeconds / maxDuration;
          }
        });
      }
    });

    mediaController!.addListener(
      MediaWidgetListener(
        videoEnablePlay: (bool enablePlay) {
          setState(() {
            canPlay = enablePlay;
          });
        },
        videoStopPlay: () {
          if (isPlay) {
            audioPlayer.pause();
          }
          return Future.value(true);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.1,
      margin: EdgeInsets.only(top: UIValueConfig.space8, bottom: UIValueConfig.space8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(UIValueConfig.radius10)),
      child: Padding(
        padding: const EdgeInsets.all(UIValueConfig.space15),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.name ?? "",
                    style: TextStyle(fontSize: UIValueConfig.font16, fontWeight: FontWeight.w700),
                    maxLines: 1,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: UIValueConfig.space15, bottom: UIValueConfig.space8),
                    child: Container(
                      height: UIValueConfig.space20,
                      width: double.maxFinite,
                      child: SeekBar(
                        secondValue: 1,
                        progressWidth: UIValueConfig.space4,
                        value: progress,
                        thumbRadius: UIValueConfig.radius10,
                        barColor: Colors.white,
                        secondProgressColor: Color(0x0A000000),
                        progressColor: Color(0xFF0DCC8B),
                        thumbColor: Color(0xFF0DCC8B),
                        onProgressChanged: (double s) {
                          setState(() {
                            progress = s;
                          });
                        },
                        onStopTrackingTouch: () {
                          audioPlayer.seek(Duration(seconds: (progress * widget.duration).truncate()));
                        },
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        progress <= 0 ? "00:00:00" : getDuration((progress * widget.duration).toInt()),
                        style: TextStyle(fontSize: UIValueConfig.font12, color: Color(0xFF747778)),
                      ),
                      Text(
                        getDuration(widget.duration),
                        style: TextStyle(fontSize: UIValueConfig.font12, color: Color(0xFF747778)),
                      ),
                    ],
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: UIValueConfig.space20, right: UIValueConfig.space5),
              child: IconButton(
                icon: Image.asset(
                  isPlay ? "res/img/icon_page_audio_stop.png" : "res/img/icon_page_audio_play.png",
                  height: UIValueConfig.space36,
                  width: UIValueConfig.space36,
                ),
                onPressed: () {
                  if (isPlay) {
                    audioPlayer.pause();
                  } else {
                    // 播放回调
                    if (widget.startPlay != null) {
                      widget.startPlay!(mediaController);
                    }

                    if (isCompleted) {
                      audioPlayer.play(UrlSource(widget.url!));
                    } else {
                      audioPlayer.resume();
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  getDuration(int duration) {
    int hour = (duration / 3600).truncate();
    int m = ((duration % 3600) / 60).truncate();
    int s = duration % 3600 % 60;
    return (hour < 10 ? '0$hour' : hour.toString()) + ":" + (m < 10 ? '0$m' : m.toString()) + ":" + (s < 10 ? '0$s' : s.toString());
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }
}
