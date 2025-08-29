import 'package:flutter/cupertino.dart';
import 'package:hasan2/utils/size_config.dart';
import 'package:hasan2/utils/widgets/text_widget.dart';
import 'package:iconsax/iconsax.dart';

import 'back_button.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool isBackButtonVisible;
  final Function()? onTap;
  final IconData? iconData;

  const CustomAppBar({super.key, this.title, this.isBackButtonVisible = false, this.onTap, this.iconData});

  @override
  Size get preferredSize => Size(100.w, 13.h);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(left: 4.w, right: 4.w, top: 2.w, bottom: 2.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            title != null ? CustomText(text: title!, fontSize: 7.5, fontWeight: FontWeight.bold) : SizedBox.shrink(),
            onTap != null
                ? GestureDetector(
                    onTap: onTap!,
                    child: Icon(iconData, size: iconData == Iconsax.add ? 8.w : 6.w),
                  )
                : isBackButtonVisible
                ? BackButtonCustom()
                : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
