import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../../config/app_colour.dart';
import '../../../config/app_size.dart';
import '../../../data/models/kitchen_item.dart';
import '../controller/kitchen_contr.dart';


class KitchenView extends StatelessWidget {
  const KitchenView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<KitchenController>();
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(ctrl: ctrl),
            Obx(() {
              final fridgeZone = ctrl.zoneById('fridge');
              final pantryZone = ctrl.zoneById('pantry');
              final spiceZone = ctrl.zoneById('spice');
              final counterZone = ctrl.zoneById('counter');
              final cabinetZone = ctrl.zoneById('cabinet');
              final basketZone = ctrl.zoneById('basket');
              return SizedBox(
                height: R.h(380),
                child: Stack(
                  children: [
                    _KitchenWall(), _WallTiles(), _Floor(), _Countertop(),
                    // FRIDGE
                    Positioned(
                      left: R.w(6),
                      top: R.h(8),
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          ctrl.openZone('fridge');
                        },
                        child: _FridgeWidget(zone: fridgeZone),
                      ),
                    ),
                    Positioned(
                      left: R.w(4),
                      top: R.h(234),
                      child: _ZonePill(
                        emoji: '❄️',
                        label: 'Fridge',
                        count: fridgeZone.itemCount,
                        expiring: fridgeZone.expiringCount,
                        onTap: () => ctrl.openZone('fridge'),
                      ),
                    ),
                    // SPICE CABINET
                    Positioned(
                      left: R.w(88),
                      top: R.h(8),
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          ctrl.openZone('spice');
                        },
                        child: _UpperCabinetLeft(zone: spiceZone),
                      ),
                    ),
                    // PANTRY SHELF
                    Positioned(
                      left: R.w(88),
                      top: R.h(116),
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          ctrl.openZone('pantry');
                        },
                        child: _OpenShelf(zone: pantryZone),
                      ),
                    ),
                    Positioned(
                      left: R.w(84),
                      top: R.h(200),
                      child: _ZonePill(
                        emoji: '🗄️',
                        label: 'Pantry',
                        count: pantryZone.itemCount,
                        expiring: pantryZone.expiringCount,
                        onTap: () => ctrl.openZone('pantry'),
                      ),
                    ),
                    // RIGHT CABINET
                    Positioned(
                      right: R.w(6),
                      top: R.h(8),
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          ctrl.openZone('cabinet');
                        },
                        child: _UpperCabinetRight(zone: cabinetZone),
                      ),
                    ),
                    Positioned(
                      right: R.w(4),
                      top: R.h(120),
                      child: _ZonePill(
                        emoji: '🚪',
                        label: 'Cabinet',
                        count: cabinetZone.itemCount,
                        expiring: cabinetZone.expiringCount,
                        onTap: () => ctrl.openZone('cabinet'),
                      ),
                    ),
                    // LOWER CABINET
                    Positioned(
                      left: R.w(88),
                      bottom: R.h(380 * 0.32).toDouble(),
                      child: const _LowerCabinet(),
                    ),
                    // COUNTERTOP
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: R.h(380 * 0.32).toDouble(),
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          ctrl.openZone('counter');
                        },
                        child: SizedBox(
                          height: R.h(380 * 0.08),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: R.w(12)),
                            child: Row(
                              children: counterZone.items
                                  .take(5)
                                  .map(
                                    (i) => Padding(
                                      padding: EdgeInsets.only(right: R.w(8)),
                                      child: Text(
                                        i.emoji,
                                        style: TextStyle(
                                          fontSize: R.sp(18),
                                          shadows: [
                                            Shadow(
                                              color: Colors.black.withOpacity(
                                                0.3,
                                              ),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: R.w(90),
                      bottom: (R.h(380 * 0.32) + R.h(380 * 0.08) + R.h(4))
                          .toDouble(),
                      child: _ZonePill(
                        emoji: '🍽️',
                        label: 'Counter',
                        count: counterZone.itemCount,
                        expiring: counterZone.expiringCount,
                        onTap: () => ctrl.openZone('counter'),
                      ),
                    ),
                    // BASKET
                    Positioned(
                      right: R.w(6),
                      bottom: R.h(380 * 0.32).toDouble(),
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          ctrl.openZone('basket');
                        },
                        child: _BasketWidget(zone: basketZone),
                      ),
                    ),
                    Positioned(
                      right: R.w(4),
                      bottom: (R.h(380 * 0.32) + R.h(380 * 0.08) + R.h(4))
                          .toDouble(),
                      child: _ZonePill(
                        emoji: '🧺',
                        label: 'Basket',
                        count: basketZone.itemCount,
                        expiring: basketZone.expiringCount,
                        onTap: () => ctrl.openZone('basket'),
                      ),
                    ),
                  ],
                ),
              );
            }),
            Expanded(
              child: Obx(
                () => ctrl.isLoading.value
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 2,
                        ),
                      )
                    : _ZoneSummaryList(ctrl: ctrl),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final KitchenController ctrl;
  const _TopBar({required this.ctrl});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(R.w(20), R.h(14), R.w(20), R.h(10)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'My Kitchen',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                Obx(
                  () => Text(
                    '${ctrl.totalItems} items · ${ctrl.expiringCount} expiring',
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Get.toNamed('/scan'),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: R.w(14),
                vertical: R.h(8),
              ),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(R.r(12)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.add_rounded, color: Colors.white, size: 16),
                  SizedBox(width: R.w(4)),
                  Text(
                    'Add Item',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: R.fs(13),
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _KitchenWall extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Positioned.fill(
    child: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 0.35, 0.351, 1.0],
          colors: [
            Color(0xFFF0DFC0),
            Color(0xFFE0C898),
            Color(0xFFC8A865),
            Color(0xFFB8943D),
          ],
        ),
      ),
    ),
  );
}

class _WallTiles extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Positioned(
    top: 0,
    left: 0,
    right: 0,
    child: SizedBox(
      height: R.h(380 * 0.35),
      child: CustomPaint(painter: _TileGridPainter()),
    ),
  );
}

class _Floor extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Positioned(
    bottom: 0,
    left: 0,
    right: 0,
    child: Container(
      height: R.h(380 * 0.32),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFB8943D), Color(0xFFA07828)],
        ),
      ),
      child: CustomPaint(painter: _TileGridPainter(isFloor: true)),
    ),
  );
}

class _Countertop extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Positioned(
    bottom: R.h(380 * 0.32) - R.h(2),
    left: 0,
    right: 0,
    child: Container(
      height: R.h(380 * 0.08),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE8E0D0), Color(0xFFD8CFC0)],
        ),
        border: Border.symmetric(
          horizontal: BorderSide(color: const Color(0xFFF5F0E8), width: R.h(2)),
        ),
      ),
    ),
  );
}

class _TileGridPainter extends CustomPainter {
  final bool isFloor;
  _TileGridPainter({this.isFloor = false});
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.black.withOpacity(0.04)
      ..strokeWidth = 1;
    final hS = isFloor ? 48.0 : 60.0;
    final vS = isFloor ? 32.0 : 48.0;
    for (double x = 0; x <= size.width; x += hS)
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    for (double y = 0; y <= size.height; y += vS)
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _FridgeWidget extends StatelessWidget {
  final KitchenZone zone;
  const _FridgeWidget({required this.zone});
  @override
  Widget build(BuildContext context) {
    final w = R.w(78);
    final h = R.h(220);
    return SizedBox(
      width: w,
      height: h,
      child: Stack(
        children: [
          Container(
            width: w,
            height: h,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment(-0.3, -1),
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFE8F0F8),
                  Color(0xFFD0DCE8),
                  Color(0xFFC0CCD8),
                ],
              ),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(R.r(8)),
                bottom: Radius.circular(R.r(4)),
              ),
              border: Border.all(color: const Color(0xFFA8B8C8), width: 2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x59000000),
                  blurRadius: 16,
                  offset: Offset(3, 6),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: R.w(4),
            child: Container(
              width: R.w(8),
              height: h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white.withOpacity(0.3), Colors.transparent],
                ),
                borderRadius: BorderRadius.circular(R.r(4)),
              ),
            ),
          ),
          Positioned(
            top: R.h(4),
            right: R.w(10),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: R.w(5),
                vertical: R.h(1),
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF4A9EFF),
                borderRadius: BorderRadius.circular(R.r(8)),
              ),
              child: Text(
                '${zone.itemCount}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: R.fs(8),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          Positioned(
            right: R.w(6),
            top: R.h(18),
            child: _Handle(width: R.w(5), height: R.h(28)),
          ),
          Positioned(
            top: R.h(8),
            left: R.w(6),
            child: Wrap(
              spacing: R.w(3),
              runSpacing: R.h(3),
              children: zone.items
                  .take(5)
                  .map(
                    (i) => Text(
                      i.emoji,
                      style: TextStyle(fontSize: R.sp(13), height: 1),
                    ),
                  )
                  .toList(),
            ),
          ),
          Positioned(
            top: h * 0.48,
            left: 0,
            right: 0,
            child: Container(height: R.h(3), color: const Color(0xFFA0B0C0)),
          ),
          Positioned(
            right: R.w(6),
            top: h * 0.52,
            child: _Handle(width: R.w(5), height: R.h(22)),
          ),
          Positioned(
            top: h * 0.52 + R.h(6),
            left: R.w(6),
            child: Wrap(
              spacing: R.w(3),
              runSpacing: R.h(3),
              children: zone.items
                  .skip(5)
                  .take(4)
                  .map(
                    (i) => Text(
                      i.emoji,
                      style: TextStyle(fontSize: R.sp(13), height: 1),
                    ),
                  )
                  .toList(),
            ),
          ),
          Positioned(
            bottom: R.h(6),
            left: 0,
            right: 0,
            child: Text(
              'FRIDGE',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: R.fs(9),
                fontWeight: FontWeight.w600,
                color: const Color(0xFF506878),
                letterSpacing: 0.05,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Handle extends StatelessWidget {
  final double width, height;
  const _Handle({required this.width, required this.height});
  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF8090A0), Color(0xFFA0B0C0)],
      ),
      borderRadius: BorderRadius.circular(R.r(3)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x4D000000),
          blurRadius: 3,
          offset: Offset(1, 1),
        ),
      ],
    ),
  );
}

class _UpperCabinetLeft extends StatelessWidget {
  final KitchenZone zone;
  const _UpperCabinetLeft({required this.zone});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: R.w(72),
      height: R.h(100),
      child: Stack(
        children: [
          Container(
            width: R.w(72),
            height: R.h(100),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment(-0.3, -1),
                end: Alignment.bottomRight,
                colors: [Color(0xFFD4A855), Color(0xFFB88830)],
              ),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(R.r(4)),
                bottom: Radius.circular(R.r(2)),
              ),
              border: Border.all(color: const Color(0xFF906820), width: 2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x66000000),
                  blurRadius: 12,
                  offset: Offset(2, 4),
                ),
              ],
            ),
          ),
          Positioned(
            top: R.h(4),
            left: R.w(4),
            right: R.w(4),
            bottom: R.h(4),
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment(-0.3, -1),
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFDDB858), Color(0xFFC09830)],
                ),
                borderRadius: BorderRadius.circular(R.r(3)),
                border: Border.all(color: const Color(0xFFA07820)),
              ),
              child: Column(
                children: [
                  SizedBox(height: R.h(8)),
                  Wrap(
                    spacing: R.w(4),
                    runSpacing: R.h(2),
                    alignment: WrapAlignment.center,
                    children: zone.items
                        .take(4)
                        .map<Widget>(
                          (i) => Text(
                            i.emoji,
                            style: TextStyle(fontSize: R.sp(12)),
                          ),
                        )
                        .toList(),
                  ),
                  const Spacer(),
                  Center(
                    child: Container(
                      width: R.w(20),
                      height: R.h(4),
                      margin: EdgeInsets.only(bottom: R.h(8)),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF786028), Color(0xFFA08848)],
                        ),
                        borderRadius: BorderRadius.circular(R.r(2)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -R.h(16),
            left: 0,
            right: 0,
            child: Text(
              'SPICES',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: R.fs(9),
                fontWeight: FontWeight.w600,
                color: const Color(0xFF9A7030),
                letterSpacing: 0.04,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OpenShelf extends StatelessWidget {
  final KitchenZone zone;
  const _OpenShelf({required this.zone});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: R.w(72),
      height: R.h(70),
      child: Stack(
        children: [
          Positioned(
            top: R.h(2),
            left: 0,
            right: 0,
            child: Text(
              'PANTRY',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: R.fs(8),
                fontWeight: FontWeight.w600,
                color: const Color(0xFF9A7030),
                letterSpacing: 0.04,
              ),
            ),
          ),
          Positioned(
            bottom: R.h(8),
            left: R.w(4),
            right: R.w(4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _ShelfJar(
                  c1: const Color(0xFF8FBC6A),
                  c2: const Color(0xFF5A8A3C),
                  h: R.h(26),
                ),
                _ShelfBottle(),
                _ShelfJar(
                  c1: const Color(0xFFE8A830),
                  c2: const Color(0xFFB87820),
                  h: R.h(22),
                ),
                _ShelfJar(
                  c1: const Color(0xFF8FBC6A),
                  c2: const Color(0xFF5A8A3C),
                  h: R.h(26),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: R.h(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFD4A840), Color(0xFFA07820)],
                ),
                borderRadius: BorderRadius.circular(R.r(2)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x4D000000),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShelfJar extends StatelessWidget {
  final Color c1, c2;
  final double h;
  const _ShelfJar({required this.c1, required this.c2, required this.h});
  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: R.w(6),
        height: R.h(5),
        decoration: BoxDecoration(
          color: const Color(0xFF8A7020),
          borderRadius: BorderRadius.vertical(top: Radius.circular(R.r(2))),
        ),
      ),
      Container(
        width: R.w(16),
        height: h,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [c1, c2],
          ),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(R.r(4)),
            bottom: Radius.circular(R.r(2)),
          ),
          border: Border.all(color: const Color(0xFF3A6A2C)),
        ),
      ),
    ],
  );
}

class _ShelfBottle extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: R.w(10),
    height: R.h(30),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFA8C870), Color(0xFF607840)],
      ),
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(R.r(5)),
        bottom: Radius.circular(R.r(1)),
      ),
      border: Border.all(color: const Color(0xFF405028)),
    ),
  );
}

class _UpperCabinetRight extends StatelessWidget {
  final KitchenZone zone;
  const _UpperCabinetRight({required this.zone});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: R.w(82),
      height: R.h(106),
      child: Stack(
        children: [
          Container(
            width: R.w(82),
            height: R.h(106),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment(-0.3, -1),
                end: Alignment.bottomRight,
                colors: [Color(0xFFD4A855), Color(0xFFB88830)],
              ),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(R.r(4)),
                bottom: Radius.circular(R.r(2)),
              ),
              border: Border.all(color: const Color(0xFF906820), width: 2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x66000000),
                  blurRadius: 12,
                  offset: Offset(-2, 4),
                ),
              ],
            ),
          ),
          Positioned(
            top: R.h(4),
            left: R.w(2),
            right: R.w(4) + R.w(82) / 2,
            bottom: R.h(4),
            child: _CabinetDoor(items: zone.items.take(2).toList()),
          ),
          Positioned(
            top: R.h(4),
            left: R.w(4) + R.w(82) / 2,
            right: R.w(2),
            bottom: R.h(4),
            child: _CabinetDoor(items: zone.items.skip(2).take(2).toList()),
          ),
        ],
      ),
    );
  }
}

class _CabinetDoor extends StatelessWidget {
  final List<KitchenItem> items;
  const _CabinetDoor({required this.items});
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment(-0.3, -1),
        end: Alignment.bottomRight,
        colors: [Color(0xFFDDB858), Color(0xFFC09830)],
      ),
      borderRadius: BorderRadius.circular(R.r(3)),
      border: Border.all(color: const Color(0xFFA07820)),
    ),
    child: Stack(
      children: [
        Padding(
          padding: EdgeInsets.all(R.r(4)),
          child: Wrap(
            spacing: R.w(2),
            runSpacing: R.h(2),
            children: items
                .map<Widget>(
                  (i) => Text(i.emoji, style: TextStyle(fontSize: R.sp(11))),
                )
                .toList(),
          ),
        ),
        Positioned(
          bottom: R.h(8),
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              width: R.w(16),
              height: R.h(4),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF786028), Color(0xFFA08848)],
                ),
                borderRadius: BorderRadius.circular(R.r(2)),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class _LowerCabinet extends StatelessWidget {
  const _LowerCabinet();
  @override
  Widget build(BuildContext context) => Container(
    width: R.w(186),
    height: R.h(72),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFC89838), Color(0xFFA07820)],
      ),
      border: Border.all(color: const Color(0xFF806018), width: 2),
      borderRadius: BorderRadius.circular(R.r(2)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x66000000),
          blurRadius: 12,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: Row(
      children: [
        Expanded(child: _LowerDoor()),
        Expanded(child: _LowerDoor()),
      ],
    ),
  );
}

class _LowerDoor extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.all(R.r(4)),
    child: Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment(-0.3, -1),
          end: Alignment.bottomRight,
          colors: [Color(0xFFD4A840), Color(0xFFB08828)],
        ),
        borderRadius: BorderRadius.circular(R.r(2)),
        border: Border.all(color: const Color(0xFF906820)),
      ),
      child: Center(
        child: Container(
          width: R.w(20),
          height: R.h(4),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF786028), Color(0xFFA08848)],
            ),
            borderRadius: BorderRadius.circular(R.r(2)),
          ),
        ),
      ),
    ),
  );
}

class _BasketWidget extends StatelessWidget {
  final KitchenZone zone;
  const _BasketWidget({required this.zone});
  @override
  Widget build(BuildContext context) => SizedBox(
    width: R.w(82),
    height: R.h(68),
    child: Stack(
      children: [
        Container(
          width: R.w(82),
          height: R.h(58),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment(-0.3, -1),
              end: Alignment.bottomRight,
              colors: [Color(0xFFC8A04A), Color(0xFFA07828)],
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(R.r(4)),
              topRight: Radius.circular(R.r(4)),
              bottomLeft: Radius.circular(R.r(8)),
              bottomRight: Radius.circular(R.r(8)),
            ),
            border: Border.all(color: const Color(0xFF806020), width: 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(R.r(4)),
              topRight: Radius.circular(R.r(4)),
              bottomLeft: Radius.circular(R.r(8)),
              bottomRight: Radius.circular(R.r(8)),
            ),
            child: Stack(
              children: [
                CustomPaint(
                  painter: _WeavePainter(),
                  child: const SizedBox.expand(),
                ),
                Positioned(
                  top: R.h(4),
                  left: R.w(4),
                  right: R.w(4),
                  child: Wrap(
                    spacing: R.w(2),
                    runSpacing: R.h(2),
                    alignment: WrapAlignment.center,
                    children: zone.items
                        .take(4)
                        .map<Widget>(
                          (i) => Text(
                            i.emoji,
                            style: TextStyle(fontSize: R.sp(14)),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Text(
            'BASKET',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: R.fs(9),
              fontWeight: FontWeight.w600,
              color: const Color(0xFF9A7030),
            ),
          ),
        ),
      ],
    ),
  );
}

class _WeavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.black.withOpacity(0.08)
      ..strokeWidth = 2;
    for (double i = -size.height; i < size.width + size.height; i += 8) {
      canvas.drawLine(Offset(i, 0), Offset(i + size.height, size.height), p);
      canvas.drawLine(Offset(i + size.height, 0), Offset(i, size.height), p);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

class _ZonePill extends StatelessWidget {
  final String emoji, label;
  final int count, expiring;
  final VoidCallback onTap;
  const _ZonePill({
    required this.emoji,
    required this.label,
    required this.count,
    required this.expiring,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: R.w(7), vertical: R.h(3)),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.72),
        border: Border.all(
          color: expiring > 0
              ? AppColors.warning.withOpacity(0.5)
              : AppColors.primary.withOpacity(0.4),
        ),
        borderRadius: BorderRadius.circular(R.r(10)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: TextStyle(fontSize: R.fs(9))),
          SizedBox(width: R.w(3)),
          Text(
            label,
            style: TextStyle(
              fontSize: R.fs(9),
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              letterSpacing: 0.04,
            ),
          ),
          SizedBox(width: R.w(4)),
          Container(
            padding: EdgeInsets.symmetric(horizontal: R.w(5), vertical: R.h(1)),
            decoration: BoxDecoration(
              color: expiring > 0
                  ? AppColors.warning.withOpacity(0.2)
                  : AppColors.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(R.r(6)),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: R.fs(8),
                fontWeight: FontWeight.w700,
                color: expiring > 0 ? AppColors.warning : AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _ZoneSummaryList extends StatelessWidget {
  final KitchenController ctrl;
  const _ZoneSummaryList({required this.ctrl});
  @override
  Widget build(BuildContext context) {
    if (ctrl.allItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🏪', style: TextStyle(fontSize: 36)),
            const SizedBox(height: 8),
            const Text(
              'Kitchen is empty',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Tap + Add Item to start',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }
    return ListView(
      padding: EdgeInsets.fromLTRB(R.w(16), R.h(12), R.w(16), R.h(20)),
      children: ctrl.zones
          .where((z) => z.itemCount > 0)
          .map(
            (z) => _ZoneSummaryCard(
              zone: z,
              ctrl: ctrl,
            ).animate().fadeIn(delay: 100.ms),
          )
          .toList(),
    );
  }
}

class _ZoneSummaryCard extends StatelessWidget {
  final KitchenZone zone;
  final KitchenController ctrl;
  const _ZoneSummaryCard({required this.zone, required this.ctrl});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: R.h(10)),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(R.r(14)),
        border: Border.all(color: AppColors.cardBorder, width: 0.5),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => ctrl.openZone(zone.id),
            child: Padding(
              padding: EdgeInsets.all(R.r(12)),
              child: Row(
                children: [
                  Text(zone.emoji, style: TextStyle(fontSize: R.sp(20))),
                  SizedBox(width: R.w(10)),
                  Expanded(
                    child: Text(
                      zone.label,
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: R.fs(14),
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  if (zone.expiringCount > 0)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: R.w(8),
                        vertical: R.h(3),
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(R.r(20)),
                      ),
                      child: Text(
                        '${zone.expiringCount} expiring',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: R.fs(10),
                          fontWeight: FontWeight.w600,
                          color: AppColors.warning,
                        ),
                      ),
                    ),
                  SizedBox(width: R.w(6)),
                  Text(
                    '${zone.itemCount} items',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: R.fs(12),
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(width: R.w(4)),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: R.sp(12),
                    color: AppColors.textHint,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: R.h(52),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.fromLTRB(R.w(12), 0, R.w(12), R.h(10)),
              itemCount: zone.items.length,
              separatorBuilder: (_, __) => SizedBox(width: R.w(8)),
              itemBuilder: (_, i) {
                final item = zone.items[i];
                final isExp = item.status == 'expired';
                final isWarn = item.status == 'expiring';
                return GestureDetector(
                  onTap: () => ctrl.openItem(item),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: R.w(10),
                      vertical: R.h(4),
                    ),
                    decoration: BoxDecoration(
                      color: isExp
                          ? AppColors.danger.withOpacity(0.08)
                          : isWarn
                          ? AppColors.warning.withOpacity(0.08)
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(R.r(10)),
                      border: Border.all(
                        color: isExp
                            ? AppColors.danger.withOpacity(0.3)
                            : isWarn
                            ? AppColors.warning.withOpacity(0.3)
                            : AppColors.cardBorder,
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(item.emoji, style: TextStyle(fontSize: R.sp(16))),
                        SizedBox(width: R.w(5)),
                        Text(
                          item.name,
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: R.fs(11),
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
