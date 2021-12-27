import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_drag_scale/core/drag_scale_widget.dart';
import 'package:roobo_logger/roobo_logger.dart';
import 'package:roobo_rich_content/config_ui_value.dart';
import 'package:roobo_rich_content/media_listener.dart';
import 'package:roobo_rich_content/rich_content_bean.dart';
import 'package:roobo_rich_content/roobo_page_audio_item_widget.dart';
import 'package:roobo_rich_content/roobo_video_widget.dart';
import 'package:roobo_video/custom_video_player/tool_overscorll_behavior.dart';
import 'package:simple_html_css/simple_html_css.dart';

class RichContentWidget extends StatefulWidget {
  final String detailJson;

  const RichContentWidget({
    Key key,
    this.detailJson,
  }) : super(key: key);

  @override
  _RichContentWidgetState createState() => _RichContentWidgetState();
}

class _RichContentWidgetState extends State<RichContentWidget> {
  MediaController _preMediaController;
  List<RichContent> detail;

  @override
  void initState() {
    try {
      detail = [];
      json.decode(widget.detailJson).forEach((v) {
        detail.add(RichContent.fromJson(v));
      });
    } catch (e) {
      Logger.i(e.toString());
      throw Exception('无法解析数据，请检查数据格式！ ${e.toString()}');
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return detail.isEmpty || detail == null
        ? Container()
        : ScrollConfiguration(
            behavior: OverScrollBehavior(),
            child: CustomScrollView(
              slivers: detail.map((items) {
                switch (items.contentType) {
                  case RichContentType.video:
                    return SliverToBoxAdapter(
                      child: Container(
                        margin: EdgeInsets.only(top: UIValueConfig.space15),
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(UIValueConfig.radius12)),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            PageVideoWidget(
                              url: items.content.url,
                              title: items.content.name,
                              startPlay: (MediaController controller) {
                                if (_preMediaController == null) {
                                  _preMediaController = controller;
                                } else {
                                  if (_preMediaController != controller) {
                                    _preMediaController.stopMediaPlay();
                                    Future.delayed(Duration(milliseconds: 50), () {
                                      _preMediaController = controller;
                                    });
                                  }
                                }
                              },
                            ),
                            Image.asset('res/img/video_player_large_pause.png'),
                          ],
                        ),
                      ),
                    );
                  case RichContentType.text:
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.only(top: UIValueConfig.space15),
                        child: HTML.toRichText(context, items.content.text),
                      ),
                    );
                  case RichContentType.image:
                    return SliverToBoxAdapter(
                      child: InkWell(
                        child: Container(
                          margin: EdgeInsets.only(top: UIValueConfig.space15),
                          clipBehavior: Clip.hardEdge,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(UIValueConfig.radius12)),
                          ),
                          child: CachedNetworkImage(imageUrl: items.content.url, fit: BoxFit.fill),
                        ),
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                            return DragScaleContainer(
                                doubleTapStillScale: true,
                                child: InkWell(
                                  child: Container(
                                    color: Color.fromRGBO(34, 34, 34, 0.9),
                                    child: CachedNetworkImage(
                                      imageUrl: items.content.url,
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                ));
                          }));
                        },
                      ),
                    );
                  case RichContentType.audio:
                    return SliverToBoxAdapter(
                      child: PageDetailAudioItemWidget(
                        name: items.content.name,
                        duration: items.content.duration,
                        url: items.content.url,
                        startPlay: (MediaController mediaController) {
                          if (_preMediaController == null) {
                            _preMediaController = mediaController;
                          } else {
                            _preMediaController.stopMediaPlay();
                            Future.delayed(Duration(milliseconds: 50), () {
                              _preMediaController = mediaController;
                            });
                          }
                        },
                      ),
                    );
                }
              }).toList(),
            ),
          );
  }

  @override
  void dispose() {
    if (_preMediaController != null) {
      _preMediaController.stopMediaPlay();
    }
    super.dispose();
  }
}
