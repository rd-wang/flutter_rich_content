# roobo_rich_content

roobo 富文本

## Getting Started



## 使用： 输入数据类型 数据类型必须匹配 ，否则无法渲染
```dart
RichContentWidget(
detailJson: widget.details.toJson(),
)
```

```json
[
  {
    "type": "text",
    "content": {
      "text": ""
    }
  },
  {
    "type": "video",
    "content": {
      "url": "",
      "duration": 0
    }
  },
  {
    "type": "audio",
    "content": {
      "url": "",
      "duration": 0,
      "name": ""
    }
  },
  {
    "type": "image",
    "content": {
      "url": ""
    }
  }
]
```