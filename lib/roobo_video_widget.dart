import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:roobo_rich_content/media_listener.dart';
import 'package:roobo_video/custom_video_player/custom_video_control.dart';
import 'package:roobo_video/custom_video_player/custom_video_player.dart';
import 'package:roobo_video/custom_video_player/widget_process_load.dart';
import 'package:video_player/video_player.dart';
import 'package:roobo_net/net_state/net_state.dart';

import 'config_ui_value.dart';

class PageVideoWidget extends StatefulWidget {
  final String url;
  final String title;
  final MediaStartPlay startPlay;
  const PageVideoWidget({Key key, this.url, this.title, this.startPlay}) : super(key: key);

  @override
  _PageVideoWidgetState createState() => _PageVideoWidgetState();
}

class _PageVideoWidgetState extends State<PageVideoWidget> {
  VideoPlayerController _videoPlayerController;
  CustomVideoController _customVideoController;
  final int _normal = 0;
  final int _noNet = 1;
  final int _error = 2;
  int _playStatus = 0;
  double progress = 0;
  bool isPlay = false;
  MediaController mediaController;


  @override
  void initState() {
    super.initState();
    mediaController = MediaController();
    mediaController.addListener(MediaWidgetListener(
      videoStopPlay: () {
        _videoPlayerController.pause();
      }
    ));
    Future.delayed(Duration(milliseconds: 800)).then((value) {
      initializePlayer();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      height: UIValueConfig.space190,
      child: _customVideoController != null && _customVideoController.videoPlayerController.value.isInitialized
          ?  videoWidget(): getOtherWidget(),
    );
  }

  videoWidget() {
    return Stack(
      children: [
        CustomVideoPlayer(
          controller: _customVideoController,
          title: widget.title,
        ),
        Positioned.fill(child: Visibility(child: IconButton(icon:Image.asset("res/img/icon_page_video_paly.png"),onPressed: () {
          _videoPlayerController.play();
        },),visible: !isPlay,)),
      ],
    );
  }

  initializePlayer() async {
    _videoPlayerController = VideoPlayerController.network(widget.url);
    await _videoPlayerController.initialize();

    _videoPlayerController?.addListener(() {
      double current = _videoPlayerController.value.position.inMilliseconds * 100 / _videoPlayerController.value.duration.inMilliseconds;
      if (current > progress) {
        progress = current;
      }

      if (_videoPlayerController.value.hasError) {
        if (NetState.getInstance.netResult == NetConnectResult.none) {
          setState(() {
            _playStatus = _noNet;
          });
        } else {
          setState(() {
            _playStatus = _error;
          });
        }
      }

      if (!_videoPlayerController.value.isPlaying) {
          setState(() {
            isPlay = false;
            _customVideoController.showVideoControllers(false);
          });
      } else if (_videoPlayerController.value.isPlaying) {
        setState(() {
          isPlay = true;
          _customVideoController.showVideoControllers(true);
          if (widget.startPlay != null) {
            widget.startPlay(mediaController);
          }
          // _customVideoController.showControls = true;
        });
      }
    });
    _customVideoController = CustomVideoController(
        videoPlayerController: _videoPlayerController,
        autoPlay: false,
        looping: false,
        customControls: VideoControlWidget(),
        showControls: false,
        errorBuilder: (context, string) {
          return getNoNetWidget();
        },
        deviceOrientationsOnEnterFullScreen: [DeviceOrientation.landscapeRight, DeviceOrientation.landscapeLeft],
    );
    setState(() {});
  }

  getNoNetWidget() {
    return GestureDetector(
      onTap: () async {
        if (NetState.getInstance.netResult == NetConnectResult.none) {
          setState(() {
            _playStatus = _noNet;
          });
          return;
        }
        setState(() {
          _playStatus = _normal;
        });
        if (_customVideoController.isFullScreen) {
          await Navigator.of(context, rootNavigator: true).pop();
        }
        initializePlayer();
      },
      child: Container(
        color: Colors.black,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('res/img/video_refresh.png'),
            SizedBox(
              height: UIValueConfig.space15,
              width: double.infinity,
            ),
            Text('网络未连接，点击重新加载',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  getOtherWidget() {
    if (_playStatus == _noNet) {
      return getNoNetWidget();
    } else if (_playStatus == _error) {
      return GestureDetector(
        onTap: () {
          setState(() {
            _playStatus = _normal;
          });
          initializePlayer();
        },
        child: Center(
          child: Container(
            color: Colors.black,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('res/img/video_refresh.png'),
                SizedBox(
                  height: 15,
                  width: double.infinity,
                ),
                Text('网络未连接，点击重新加载',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return Center(
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ProgressLoadWidget(type: ProgressLoadType.Circle),
              Text(
                '加载中',
                style: TextStyle(color: Colors.white),
              )
            ],
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _videoPlayerController?.removeListener(() {});
    _videoPlayerController?.dispose();
    _customVideoController?.dispose();
    super.dispose();
  }
}
