import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class LocalImage extends StatefulWidget {
  const LocalImage({
    required this.img,
    this.height,
    this.type = 'png',
    this.borderRadius = 0,
    this.width,
    this.color,
    this.alignment = FractionalOffset.center,
    this.fit = BoxFit.fitHeight,
    this.isFileImage = false,

    super.key,
  });

  final String img;
  final String type;
  final double? height;
  final double? width;
  final Color? color;
  final double borderRadius;
  final AlignmentGeometry alignment;
  final BoxFit fit;
  final bool isFileImage;

  @override
  State<LocalImage> createState() => _CustomImageAssetsState();
}

class _CustomImageAssetsState extends State<LocalImage> {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: widget.isFileImage != true
          ? widget.type == "svg"
                ? SvgPicture.asset(
                    "assets/images/svg/${widget.img}.svg",
                    height: widget.height,
                    width: widget.width,
                    fit: widget.fit,
                    colorFilter: widget.color != null ? ColorFilter.mode(widget.color!, BlendMode.srcIn) : null,
                    semanticsLabel: '',
                  )
                : Image.asset(
                    "assets/images/${widget.type}/${widget.img}.${widget.type}",
                    fit: widget.fit,
                    height: widget.height,
                    alignment: widget.alignment,
                    width: widget.width,
                  )
          : Image.file(File(widget.img), fit: widget.fit, height: widget.height, alignment: widget.alignment, width: widget.width),
    );
  }
}
