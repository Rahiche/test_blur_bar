import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: CustomTabBarDemo(),
    );
  }
}

const borderRadius = 25.0;

class CustomTabBarDemo extends StatefulWidget {
  const CustomTabBarDemo({super.key});

  @override
  _CustomTabBarDemoState createState() => _CustomTabBarDemoState();
}

class _CustomTabBarDemoState extends State<CustomTabBarDemo> {
  GlobalKey tabBarKey = GlobalKey();

  late LinkedScrollControllerGroup _controllers;
  late ScrollController first;
  late ScrollController second;

  TabItemType selectedItem = TabItemType.Glass;

  // Operation in the following order
  // 1. Clip
  // 2. Apply effect
  bool clipFirst = false;

  @override
  void initState() {
    super.initState();
    _controllers = LinkedScrollControllerGroup();
    first = _controllers.addAndGet();
    second = _controllers.addAndGet();
  }

  @override
  void dispose() {
    first.dispose();
    second.dispose();
    super.dispose();
  }

  final List<Widget> _tabsContent = [
    Image.network(
      "https://i.imgur.com/oa0tp0w.png",
      fit: BoxFit.cover,
    ),
    Image.network(
      "https://i.imgur.com/hcpFVzx.png",
      fit: BoxFit.cover,
    ),
    Image.network(
      "https://i.imgur.com/yd8DU4o.png",
      fit: BoxFit.cover,
    ),
    Image.network(
      "https://i.imgur.com/awC6ruq.png",
      fit: BoxFit.cover,
    ),
  ];

  Map<String, dynamic> _getTabBarSizeAndPosition() {
    // Access the RenderBox
    RenderBox? renderBox =
        tabBarKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      return {};
    }
    // Get the size
    Size size = renderBox.size;
    // Get the position
    Offset position = renderBox.localToGlobal(Offset.zero);

    // Use size and position as needed
    print("TabBar Size: $size, Position: $position");
    return {
      "size": size,
      "position": position,
    };
  }

  @override
  Widget build(BuildContext context) {
    var copiedChild = ClipPath(
      clipper: MyCustomClipper(data: _getTabBarSizeAndPosition()),
      child: SingleChildScrollView(
        controller: second,
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: _tabsContent),
      ),
    );

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              controller: first,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: _tabsContent),
            ),
          ),
          if (clipFirst)
            Positioned.fill(
              child: IgnorePointer(child: _addShader(copiedChild)),
            )
          else
            Positioned.fill(
              child: IgnorePointer(
                child: ClipPath(
                  clipper: MyCustomClipper(data: _getTabBarSizeAndPosition()),
                  child: _addShader(
                    SingleChildScrollView(
                      controller: second,
                      physics: const NeverScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [..._tabsContent],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          Positioned(
            key: tabBarKey,
            bottom: 10,
            left: 10,
            right: 10,
            height: 90,
            child: _tabBar(),
          ),
        ],
      ),
    );
  }

  Widget _addShader(Widget copiedChild) {
    return ShaderBuilder(
      (context, shader, child) {
        return AnimatedSampler(
          (image, size, canvas) {
            shader.setFloat(0, size.width);
            shader.setFloat(1, size.height);
            shader.setImageSampler(0, image);

            canvas.drawRect(
              Rect.fromLTWH(0, 0, size.width, size.height),
              Paint()..shader = shader,
            );
          },
          child: copiedChild,
        );
      },
      assetKey: selectedItem.shader,
    );
  }

  Widget _tabBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 90,
        width: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: Colors.white,
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: TabItemType.values.map((e) {
            return TabItem(
              tabItemType: e,
              onChange: (TabItemType value) {
                selectedItem = value;
                setState(() {});
              },
              title: e.name,
              icon: e.icon,
              isSelected: selectedItem == e,
            );
          }).toList(),
        ),
      ),
    );
  }
}

enum TabItemType {
  Glass,
  Gaussian,
  Mean,
  Surface,
}

extension TabItemExtension on TabItemType {
  IconData get icon {
    switch (this) {
      case TabItemType.Glass:
        return Icons.home;
      case TabItemType.Gaussian:
        return Icons.home_repair_service;
      case TabItemType.Mean:
        return Icons.military_tech_rounded;
      case TabItemType.Surface:
        return Icons.place_sharp;
    }
  }

  String get shader {
    switch (this) {
      case TabItemType.Glass:
        return 'shaders/glass.frag';
      case TabItemType.Gaussian:
        return 'shaders/blur.frag';
      case TabItemType.Mean:
        return 'shaders/mean.frag';
      case TabItemType.Surface:
        return 'shaders/surface.frag';
    }
  }
}

class TabItem extends StatelessWidget {
  const TabItem({
    super.key,
    required this.tabItemType,
    required this.onChange,
    required this.title,
    required this.icon,
    required this.isSelected,
  });

  final TabItemType tabItemType;
  final ValueChanged<TabItemType> onChange;
  final String title;
  final IconData icon;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: InkWell(
        onTap: () {
          onChange(tabItemType);
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.white54,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MyCustomClipper extends CustomClipper<Path> {
  MyCustomClipper({super.reclip, required this.data});
  final Map<String, dynamic> data;

  @override
  Path getClip(Size size) {
    const double padding = 9.0;
    // Define constants for common values
    if (data["position"] == null) {
      return Path();
    }
    final position = data["position"] as Offset;
    final double height = position.dy + padding;
    final double sideMargin = position.dx + padding;

    ui.Path path = Path();
    // Define your path here with rounded corners.

    // Top left corner
    path.moveTo(sideMargin, height + borderRadius);
    path.quadraticBezierTo(
      sideMargin,
      height,
      sideMargin + borderRadius,
      height,
    );

    // Top right corner
    path.lineTo(
      size.width - sideMargin - borderRadius,
      height,
    );
    path.quadraticBezierTo(
      size.width - sideMargin,
      height,
      size.width - sideMargin,
      height + borderRadius,
    );

    // Bottom right corner
    path.lineTo(
      size.width - sideMargin,
      size.height - sideMargin - borderRadius,
    );
    path.quadraticBezierTo(
      size.width - sideMargin,
      size.height - sideMargin,
      size.width - sideMargin - borderRadius,
      size.height - sideMargin,
    );

    // Bottom left corner
    path.lineTo(sideMargin + borderRadius, size.height - sideMargin);
    path.quadraticBezierTo(
      sideMargin,
      size.height - sideMargin,
      sideMargin,
      size.height - sideMargin - borderRadius,
    );

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}
