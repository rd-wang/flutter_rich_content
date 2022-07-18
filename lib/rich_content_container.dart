import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:roobo_rich_content/config_ui_value.dart';
import 'package:roobo_rich_content/rich_content_bean.dart';
import 'package:roobo_rich_content/roobo_page_audio_item_widget.dart';
import 'package:roobo_video/custom_video_player/tool_overscorll_behavior.dart';
import 'package:roobo_video/video_widget/media_listener.dart';
import 'package:roobo_video/video_widget/roobo_video_widget.dart';
import 'package:simple_html_css/simple_html_css.dart';

import 'net_state/net_state.dart';

class RichContentWidget extends StatefulWidget {
  final String? detailJson;

  const RichContentWidget({
    Key? key,
    this.detailJson,
  }) : super(key: key);

  @override
  _RichContentWidgetState createState() => _RichContentWidgetState();
}

class _RichContentWidgetState extends State<RichContentWidget> {
  MediaController? _preMediaController;
  List<RichContent>? detail;

  @override
  void initState() {
    try {
      detail = [];
      json.decode(widget.detailJson!).forEach((v) {
        detail!.add(RichContent.fromJson(v));
      });
    } catch (e) {
      print(e.toString());
      throw Exception('无法解析数据，请检查数据格式！ ${e.toString()}');
    }
    NetState.init(_updateConnectionState);
    super.initState();
  }

  static _updateConnectionState(ConnectivityResult result) async {
    NetConnectResult _connectResult;
    switch (result) {
      case ConnectivityResult.wifi:
        _connectResult = NetConnectResult.wifi;
        break;
      case ConnectivityResult.mobile:
        _connectResult = NetConnectResult.mobile;
        break;
      case ConnectivityResult.none:
        _connectResult = NetConnectResult.none;
        break;
      default:
        _connectResult = NetConnectResult.unknown;
        break;
    }
    NetState.getInstance!.netResult = _connectResult;
  }

  @override
  Widget build(BuildContext context) {
    return detail!.isEmpty || detail == null
        ? Container()
        : ScrollConfiguration(
            behavior: OverScrollBehavior(),
            child: CustomScrollView(
              slivers: getItem(),
            ),
          );
  }

  List<SliverToBoxAdapter> getItem() {
    return detail!.map((items) {
      switch (items.contentType) {
        case RichContentType.video:
          return SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.only(top: UIValueConfig.space8, bottom: UIValueConfig.space8),
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(UIValueConfig.radius12)),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  RooboVideoWidget(
                    url: items.content!.url,
                    title: items.content!.name,
                    isNoNet: () {
                      return NetState.getInstance!.netResult == NetConnectResult.none;
                    },
                    startPlay: (MediaController? controller) {
                      if (_preMediaController == null) {
                        _preMediaController = controller;
                      } else {
                        if (_preMediaController != controller) {
                          _preMediaController!.stopMediaPlay();
                          Future.delayed(Duration(milliseconds: 50), () {
                            _preMediaController = controller;
                          });
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        case RichContentType.text:
          return SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(top: UIValueConfig.space8, bottom: UIValueConfig.space8),
              child: HTML.toRichText(context, items.content!.text!),
            ),
          );
        case RichContentType.image:
          return SliverToBoxAdapter(
            child: InkWell(
              child: Container(
                margin: EdgeInsets.only(top: UIValueConfig.space8, bottom: UIValueConfig.space8),
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(UIValueConfig.radius12)),
                ),
                child: CachedNetworkImage(imageUrl: items.content!.url!, fit: BoxFit.fill),
              ),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                  return Material(
                    child: InkWell(
                      child: Container(
                        color: Color.fromRGBO(34, 34, 34, 0.9),
                        child: ExtendedImage.network(
                          items.content!.url!,
                          fit: BoxFit.fill,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                  );
                  // return Material(
                  //   child: DragScaleContainer(
                  //       doubleTapStillScale: true,
                  //       child: InkWell(
                  //         child: Container(
                  //           color: Color.fromRGBO(34, 34, 34, 0.9),
                  //           child: CachedNetworkImage(
                  //             imageUrl: items.content.url,
                  //           ),
                  //         ),
                  //         onTap: () {
                  //           Navigator.pop(context);
                  //         },
                  //       )),
                  // );
                }));
              },
            ),
          );
        case RichContentType.audio:
          return SliverToBoxAdapter(
            child: PageDetailAudioItemWidget(
              name: items.content!.name,
              duration: items.content!.duration!.toInt(),
              url: items.content!.url,
              startPlay: (MediaController? mediaController) {
                if (_preMediaController == null) {
                  _preMediaController = mediaController;
                } else {
                  _preMediaController!.stopMediaPlay();
                  Future.delayed(Duration(milliseconds: 50), () {
                    _preMediaController = mediaController;
                  });
                }
              },
            ),
          );
        default:
          return SliverToBoxAdapter(
            child: Container(),
          );
      }
    }).toList();
  }

  @override
  void dispose() {
    if (_preMediaController != null) {
      _preMediaController!.stopMediaPlay();
    }
    super.dispose();
  }
}
