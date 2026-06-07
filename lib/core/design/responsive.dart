import 'package:flutter/material.dart';

enum WidthClass { compact, medium, expanded }

WidthClass widthClassOf(BuildContext context) {
  final w = MediaQuery.of(context).size.width;
  final h = MediaQuery.of(context).size.height;
  final isLandscape = w > h;
  final shortestSide = w < h ? w : h;
  final isPhoneLandscape = isLandscape && shortestSide < 600;
  WidthClass cls;
  if (w < 600) {
    cls = WidthClass.compact;
  } else if (w < 840) {
    cls = WidthClass.medium;
  } else {
    cls = WidthClass.expanded;
  }
  if (isPhoneLandscape && cls != WidthClass.expanded) {
    return WidthClass.expanded;
  }
  return cls;
}

double responsiveHPadding(BuildContext context) {
  return switch (widthClassOf(context)) {
    WidthClass.expanded => 48,
    WidthClass.medium => 24,
    WidthClass.compact => 12,
  };
}

double statsHPadding(BuildContext context) {
  return switch (widthClassOf(context)) {
    WidthClass.expanded => 40,
    WidthClass.medium => 24,
    WidthClass.compact => 16,
  };
}

bool isWideScreen(BuildContext context) =>
    widthClassOf(context) != WidthClass.compact;

double? contentMaxWidth(BuildContext context) {
  return widthClassOf(context) == WidthClass.expanded ? 1080.0 : null;
}

int overviewColumns(BuildContext context) {
  return switch (widthClassOf(context)) {
    WidthClass.expanded => 6,
    WidthClass.medium => 4,
    WidthClass.compact => 2,
  };
}

double chartHeight(BuildContext context) {
  return widthClassOf(context) == WidthClass.compact ? 140.0 : 200.0;
}

bool useTwoColumns(BuildContext context) =>
    widthClassOf(context) == WidthClass.expanded;

double typeScale(BuildContext context) {
  return switch (widthClassOf(context)) {
    WidthClass.expanded => 1.1,
    WidthClass.medium => 1.05,
    WidthClass.compact => 1.0,
  };
}
