import 'package:flutter/material.dart';
import 'package:smarterp/core/responsive/breakpoints.dart';

class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, DeviceType deviceType) builder;
  final Widget? mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? largeDesktop;

  const ResponsiveBuilder({
    super.key,
    required this.builder,
    this.mobile,
    this.tablet,
    this.desktop,
    this.largeDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final deviceType = _getDeviceType(constraints.maxWidth);

        if (mobile != null && deviceType == DeviceType.mobile) {
          return mobile!;
        }
        if (tablet != null && deviceType == DeviceType.tablet) {
          return tablet!;
        }
        if (desktop != null && deviceType == DeviceType.desktop) {
          return desktop!;
        }
        if (largeDesktop != null && deviceType == DeviceType.largeDesktop) {
          return largeDesktop!;
        }

        return builder(context, deviceType);
      },
    );
  }

  DeviceType _getDeviceType(double width) {
    if (width >= Breakpoints.largeDesktop) {
      return DeviceType.largeDesktop;
    } else if (width >= Breakpoints.desktop) {
      return DeviceType.desktop;
    } else if (width >= Breakpoints.tablet) {
      return DeviceType.tablet;
    } else {
      return DeviceType.mobile;
    }
  }
}
