import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../theme/app_theme.dart';

extension IconExtension on Icon {
  Icon autoDirection() {
    if (AppTheme.textDirection == TextDirection.ltr) return this;
    if (icon == Icons.chevron_right) {
      return Icon(
        Icons.chevron_left,
        color: color,
        textDirection: textDirection,
        size: size,
        key: key,
        semanticLabel: semanticLabel,
      );
    } else if (icon == Icons.chevron_left) {
      return Icon(
        Icons.chevron_right,
        color: color,
        textDirection: textDirection,
        size: size,
        key: key,
        semanticLabel: semanticLabel,
      );
    } else if (icon == MdiIcons.chevronLeft) {
      return Icon(
        MdiIcons.chevronRight,
        color: color,
        textDirection: textDirection,
        size: size,
        key: key,
        semanticLabel: semanticLabel,
      );
    } else if (icon == MdiIcons.chevronRight) {
      return Icon(
        MdiIcons.chevronLeft,
        color: color,
        textDirection: textDirection,
        size: size,
        key: key,
        semanticLabel: semanticLabel,
      );
    }
    return this;
  }
}
