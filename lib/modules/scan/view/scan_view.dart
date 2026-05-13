import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../config/app_colour.dart';
import '../../../config/app_size.dart';
import '../controller/scan_cont.dart';

class ScanView extends StatefulWidget {
  const ScanView({super.key});
  @override
  State<ScanView> createState() => _ScanViewState();
}

class _ScanViewState extends State<ScanView> {
  final _formKey = GlobalKey<FormState>();
  ScanController get _ctrl => Get.find<ScanController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Obx(() {
        if (_ctrl.aiSheetPending.value) {
          _ctrl.aiSheetShown();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) AiResultSheet.show(_ctrl);
          });
        }
        return _ctrl.isCameraMode.value
            ? _CameraTab(ctrl: _ctrl)
            : _ManualForm(ctrl: _ctrl, formKey: _formKey);
      }),
    );
  }
}

class _CameraTab extends StatelessWidget {
  final ScanController ctrl;
  const _CameraTab({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Stack(
      children: [
        Container(color: Colors.black),
        Positioned.fill(child: _ScanGrid()),

        Center(
          child: SizedBox(
            width: w * 0.65,
            height: w * 0.65,
            child: Stack(
              children: [
                _Corner(top: true, left: true),
                _Corner(top: true, left: false),
                _Corner(top: false, left: true),
                _Corner(top: false, left: false),
                _ScanLine(),
              ],
            ),
          ),
        ),

        SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: w * 0.05,
              vertical: h * 0.01,
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: R.w(38),
                    height: R.w(38),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(R.r(10)),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: R.sp(22),
                      color: Colors.white,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  'Scan Item',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: R.fs(16),
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                SizedBox(width: R.w(38)),
              ],
            ),
          ),
        ),

        Obx(
          () => ctrl.isAiScanning.value
              ? Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.7),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: R.w(60),
                          height: R.w(60),
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                            strokeWidth: 2.5,
                          ),
                        ),
                        SizedBox(height: R.h(20)),
                        Text(
                          'AI Analysing Image...',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: R.fs(16),
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: R.h(8)),
                        Text(
                          'Detecting item & expiry date',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: R.fs(13),
                            color: Colors.white60,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 200.ms),
                )
              : const SizedBox.shrink(),
        ),

        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: EdgeInsets.fromLTRB(
              w * 0.06,
              h * 0.025,
              w * 0.06,
              MediaQuery.of(context).padding.bottom + h * 0.025,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black, Colors.transparent],
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Point camera at grocery item or packaging',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: R.fs(13),
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: R.h(6)),
                Text(
                  'AI will detect item name & expiry date',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: R.fs(11),
                    color: AppColors.primary.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: R.h(24)),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _CircleAction(
                      icon: Icons.photo_library_outlined,
                      label: 'Gallery',
                      size: R.w(52),
                      onTap: () => ctrl.pickFromGallery(),
                    ),
                    SizedBox(width: R.w(24)),

                    GestureDetector(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        ctrl.captureAndAnalyse();
                      },
                      child: Container(
                        width: R.w(70),
                        height: R.w(70),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppColors.primaryGradient,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.5),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.camera_alt_rounded,
                          color: Colors.white,
                          size: R.sp(30),
                        ),
                      ),
                    ),
                    SizedBox(width: R.w(24)),

                    _CircleAction(
                      icon: Icons.qr_code_scanner_rounded,
                      label: 'Barcode',
                      size: R.w(52),
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        ctrl.onBarcodeDetected('8901030862466');
                      },
                    ),
                  ],
                ),
                SizedBox(height: R.h(16)),

                GestureDetector(
                  onTap: ctrl.switchToManual,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: R.w(20),
                      vertical: R.h(10),
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white30),
                      borderRadius: BorderRadius.circular(R.r(30)),
                    ),
                    child: Text(
                      'Enter manually instead',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: R.fs(13),
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CircleAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final double size;
  final VoidCallback onTap;
  const _CircleAction({
    required this.icon,
    required this.label,
    required this.size,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white12,
              border: Border.all(color: Colors.white24, width: 0.8),
            ),
            child: Icon(icon, color: Colors.white70, size: R.sp(22)),
          ),
          SizedBox(height: R.h(6)),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: R.fs(10),
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }
}

class AiResultSheet extends StatelessWidget {
  final ScanController ctrl;
  const AiResultSheet({super.key, required this.ctrl});

  static void show(ScanController ctrl) {
    Get.bottomSheet(
      AiResultSheet(ctrl: ctrl),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    final result = ctrl.aiResult.value;
    if (result == null) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(R.r(28))),
        border: Border.all(color: AppColors.cardBorder, width: 0.5),
      ),
      padding: EdgeInsets.fromLTRB(
        R.w(24),
        R.h(20),
        R.w(24),
        MediaQuery.of(context).padding.bottom + R.h(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: R.w(40),
              height: R.h(4),
              decoration: BoxDecoration(
                color: AppColors.cardBorder,
                borderRadius: BorderRadius.circular(R.r(2)),
              ),
            ),
          ),
          SizedBox(height: R.h(20)),

          Row(
            children: [
              Container(
                padding: EdgeInsets.all(R.r(10)),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(R.r(12)),
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.success,
                  size: R.sp(20),
                ),
              ),
              SizedBox(width: R.w(12)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Detected',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: R.fs(16),
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Review and confirm details',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: R.fs(12),
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: R.h(20)),

          Container(
            padding: EdgeInsets.all(R.r(16)),
            decoration: BoxDecoration(
              color: AppColors.bgDark,
              borderRadius: BorderRadius.circular(R.r(16)),
              border: Border.all(color: AppColors.cardBorder, width: 0.5),
            ),
            child: Column(
              children: [
                _ResultRow(
                  label: 'Item',
                  value:
                      '${result['emoji'] ?? '🛒'} ${result['name'] ?? 'Unknown'}',
                  highlight: true,
                ),
                if ((result['brand'] as String?)?.isNotEmpty == true) ...[
                  SizedBox(height: R.h(12)),
                  _ResultRow(label: 'Brand', value: result['brand']!),
                ],
                if ((result['category'] as String?)?.isNotEmpty == true) ...[
                  SizedBox(height: R.h(12)),
                  _ResultRow(label: 'Category', value: result['category']!),
                ],
                if ((result['expiryDate'] as String?)?.isNotEmpty == true) ...[
                  SizedBox(height: R.h(12)),
                  _ResultRow(
                    label: 'Expiry Date',
                    value: result['expiryDate']!,
                    isExpiry: true,
                  ),
                ],
                if ((result['storageZone'] as String?)?.isNotEmpty == true) ...[
                  SizedBox(height: R.h(12)),
                  _ResultRow(
                    label: 'Suggested Storage',
                    value: result['storageZone']!,
                  ),
                ],
                if ((result['confidence'] as String?)?.isNotEmpty == true) ...[
                  SizedBox(height: R.h(12)),
                  _ResultRow(
                    label: 'Confidence',
                    value: result['confidence']!,
                    isConfidence: true,
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: R.h(20)),

          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Get.back();
                    ctrl.clearAiResult();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: R.h(14)),
                    decoration: BoxDecoration(
                      color: AppColors.bgDark,
                      borderRadius: BorderRadius.circular(R.r(14)),
                      border: Border.all(
                        color: AppColors.cardBorder,
                        width: 0.8,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Retry Scan',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: R.fs(14),
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: R.w(12)),
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: () {
                    Get.back();
                    ctrl.applyAiResult();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: R.h(14)),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(R.r(14)),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'Use These Details',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: R.fs(14),
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().slideY(begin: 0.3, duration: 300.ms, curve: Curves.easeOut);
  }
}

class _ResultRow extends StatelessWidget {
  final String label, value;
  final bool highlight;
  final bool isExpiry;
  final bool isConfidence;
  const _ResultRow({
    required this.label,
    required this.value,
    this.highlight = false,
    this.isExpiry = false,
    this.isConfidence = false,
  });

  @override
  Widget build(BuildContext context) {
    Color valueColor = AppColors.textPrimary;
    if (isExpiry) valueColor = AppColors.warning;
    if (isConfidence) {
      final lower = value.toLowerCase();
      if (lower.contains('high'))
        valueColor = AppColors.success;
      else if (lower.contains('low'))
        valueColor = AppColors.danger;
      else
        valueColor = AppColors.warning;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: R.w(110),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: R.fs(12),
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: highlight ? R.fs(15) : R.fs(13),
              fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
              color: highlight ? AppColors.textPrimary : valueColor,
            ),
          ),
        ),
      ],
    );
  }
}

class _ScanGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _GridPainter());
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.04)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 30) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

class _Corner extends StatelessWidget {
  final bool top, left;
  const _Corner({required this.top, required this.left});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top ? 0 : null,
      bottom: top ? null : 0,
      left: left ? 0 : null,
      right: left ? null : 0,
      child: Container(
        width: R.w(28),
        height: R.w(28),
        decoration: BoxDecoration(
          border: Border(
            top: top
                ? const BorderSide(color: AppColors.primary, width: 3)
                : BorderSide.none,
            bottom: !top
                ? const BorderSide(color: AppColors.primary, width: 3)
                : BorderSide.none,
            left: left
                ? const BorderSide(color: AppColors.primary, width: 3)
                : BorderSide.none,
            right: !left
                ? const BorderSide(color: AppColors.primary, width: 3)
                : BorderSide.none,
          ),
          borderRadius: BorderRadius.only(
            topLeft: top && left ? const Radius.circular(4) : Radius.zero,
            topRight: top && !left ? const Radius.circular(4) : Radius.zero,
            bottomLeft: !top && left ? const Radius.circular(4) : Radius.zero,
            bottomRight: !top && !left ? const Radius.circular(4) : Radius.zero,
          ),
        ),
      ),
    );
  }
}

class _ScanLine extends StatefulWidget {
  @override
  State<_ScanLine> createState() => _ScanLineState();
}

class _ScanLineState extends State<_ScanLine>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat();
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ac,
      builder: (_, __) => Positioned(
        top: _ac.value * (MediaQuery.of(context).size.width * 0.65 - 2),
        left: 0,
        right: 0,
        child: Container(
          height: 2,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                AppColors.primary,
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ManualForm extends StatelessWidget {
  final ScanController ctrl;
  final GlobalKey<FormState> formKey;
  const _ManualForm({required this.ctrl, required this.formKey});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        elevation: 0,
        title: Text(
          'Add Grocery Item',
          style: TextStyle(
            fontFamily: 'Outfit',
            fontSize: R.fs(16),
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        leading: GestureDetector(
          onTap: () {
            if (!ctrl.isCameraMode.value) {
              ctrl.switchToCamera();
            } else {
              Navigator.of(context).pop();
            }
          },
          child: Container(
            margin: EdgeInsets.all(R.r(8)),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(R.r(10)),
              border: Border.all(color: AppColors.cardBorder, width: 0.5),
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: R.sp(14),
              color: AppColors.textPrimary,
            ),
          ),
        ),
        actions: [
          GestureDetector(
            onTap: ctrl.switchToCamera,
            child: Container(
              margin: EdgeInsets.only(right: R.w(14)),
              padding: EdgeInsets.symmetric(
                horizontal: R.w(12),
                vertical: R.h(6),
              ),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(R.r(10)),
                border: Border.all(color: AppColors.cardBorder, width: 0.5),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.qr_code_scanner_rounded,
                    size: R.sp(14),
                    color: AppColors.primary,
                  ),
                  SizedBox(width: R.w(4)),
                  Text(
                    'Scan',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: R.fs(12),
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: R.w(20), vertical: R.h(16)),
          children: [
            Obx(
              () => ctrl.barcodeResult.value.isNotEmpty
                  ? _BarcodeBadge(
                      code: ctrl.barcodeResult.value,
                    ).animate().fadeIn().slideY(begin: -0.2)
                  : const SizedBox.shrink(),
            ),

            Obx(
              () => ctrl.aiResult.value != null
                  ? _AiBanner(ctrl: ctrl).animate().fadeIn().slideY(begin: -0.2)
                  : const SizedBox.shrink(),
            ),

            _SectionLabel('Item Emoji'),
            SizedBox(height: R.h(8)),
            Obx(() => _EmojiPicker(ctrl: ctrl)),
            SizedBox(height: R.h(20)),

            _SectionLabel('Item Name *'),
            SizedBox(height: R.h(8)),
            TextFormField(
              controller: ctrl.nameCtrl,
              validator: ctrl.vRequired,
              textInputAction: TextInputAction.next,
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: R.fs(14),
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'e.g. Shimla Apples',
                prefixIcon: Icon(Icons.label_outline_rounded, size: R.sp(20)),
              ),
            ),
            SizedBox(height: R.h(14)),

            _SectionLabel('Brand (optional)'),
            SizedBox(height: R.h(8)),
            TextFormField(
              controller: ctrl.brandCtrl,
              textInputAction: TextInputAction.next,
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: R.fs(14),
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'e.g. Amul, MDH, Haldiram',
                prefixIcon: Icon(Icons.store_outlined, size: R.sp(20)),
              ),
            ),
            SizedBox(height: R.h(14)),

            _SectionLabel('Quantity & Unit'),
            SizedBox(height: R.h(8)),
            Row(
              children: [
                SizedBox(
                  width: R.w(100),
                  child: TextFormField(
                    controller: ctrl.quantityCtrl,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: R.fs(14),
                      color: AppColors.textPrimary,
                    ),
                    decoration: const InputDecoration(hintText: '1'),
                  ),
                ),
                SizedBox(width: R.w(10)),
                Expanded(
                  child: TextFormField(
                    controller: ctrl.unitCtrl,
                    textInputAction: TextInputAction.next,
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: R.fs(14),
                      color: AppColors.textPrimary,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'pcs / kg / L / g',
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: R.h(20)),

            _SectionLabel('Storage Zone'),
            SizedBox(height: R.h(8)),
            Obx(() => _ZonePicker(ctrl: ctrl)),
            SizedBox(height: R.h(20)),

            _SectionLabel('Expiry Date'),
            SizedBox(height: R.h(8)),
            Obx(
              () => GestureDetector(
                onTap: () => ctrl.pickExpiryDate(context),
                child: Container(
                  padding: EdgeInsets.all(R.r(14)),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(R.r(14)),
                    border: Border.all(
                      color: ctrl.expiryDate.value != null
                          ? AppColors.primary.withValues(alpha: 0.5)
                          : AppColors.cardBorder,
                      width: ctrl.expiryDate.value != null ? 1.5 : 0.8,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_month_rounded,
                        size: R.sp(20),
                        color: ctrl.expiryDate.value != null
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                      SizedBox(width: R.w(12)),
                      Text(
                        ctrl.expiryDate.value != null
                            ? DateFormat(
                                'dd MMM yyyy',
                              ).format(ctrl.expiryDate.value!)
                            : 'Tap to select expiry date',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: R.fs(14),
                          color: ctrl.expiryDate.value != null
                              ? AppColors.textPrimary
                              : AppColors.textHint,
                        ),
                      ),
                      const Spacer(),
                      if (ctrl.expiryDate.value != null)
                        GestureDetector(
                          onTap: () => ctrl.expiryDate.value = null,
                          child: Icon(
                            Icons.clear_rounded,
                            size: R.sp(16),
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: R.h(8)),

            Obx(() {
              final d = ctrl.expiryDate.value;
              if (d == null) return const SizedBox.shrink();
              final days = d.difference(DateTime.now()).inDays;
              if (days > 7) return const SizedBox.shrink();
              return Container(
                padding: EdgeInsets.all(R.r(10)),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(R.r(10)),
                  border: Border.all(
                    color: AppColors.warning.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Text('⚠️', style: TextStyle(fontSize: R.sp(14))),
                    SizedBox(width: R.w(8)),
                    Expanded(
                      child: Text(
                        days <= 0
                            ? 'This item is already expired!'
                            : 'Expires in $days days — will show in priority list',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: R.fs(12),
                          color: AppColors.warning,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            SizedBox(height: R.h(20)),

            Obx(
              () => ctrl.errorMsg.value.isNotEmpty
                  ? Container(
                      padding: EdgeInsets.all(R.r(12)),
                      decoration: BoxDecoration(
                        color: AppColors.danger.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(R.r(12)),
                        border: Border.all(
                          color: AppColors.danger.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Text(
                        ctrl.errorMsg.value,
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: R.fs(13),
                          color: AppColors.danger,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),

            SizedBox(height: R.h(24)),

            Obx(
              () => SizedBox(
                width: double.infinity,
                height: R.h(52),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(R.r(16)),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(R.r(16)),
                      onTap: ctrl.isSaving.value
                          ? null
                          : () => ctrl.saveItem(formKey),
                      child: Center(
                        child: ctrl.isSaving.value
                            ? SizedBox(
                                width: R.w(22),
                                height: R.w(22),
                                child: const CircularProgressIndicator(
                                  color: AppColors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.check_circle_outline_rounded,
                                    color: AppColors.white,
                                    size: R.sp(18),
                                  ),
                                  SizedBox(width: R.w(8)),
                                  Text(
                                    'Save to Kitchen',
                                    style: TextStyle(
                                      fontFamily: 'Outfit',
                                      fontSize: R.fs(15),
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.white,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: R.h(40)),
          ],
        ),
      ),
    );
  }
}

class _AiBanner extends StatelessWidget {
  final ScanController ctrl;
  const _AiBanner({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => AiResultSheet.show(ctrl),
      child: Container(
        margin: EdgeInsets.only(bottom: R.h(16)),
        padding: EdgeInsets.symmetric(horizontal: R.w(14), vertical: R.h(12)),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(R.r(14)),
          border: Border.all(
            color: AppColors.success.withValues(alpha: 0.3),
            width: 0.8,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.auto_awesome_rounded,
              color: AppColors.success,
              size: R.sp(18),
            ),
            SizedBox(width: R.w(10)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI filled in the details',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: R.fs(13),
                      fontWeight: FontWeight.w600,
                      color: AppColors.success,
                    ),
                  ),
                  Text(
                    'Tap to review AI detection',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: R.fs(11),
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: R.sp(12),
              color: AppColors.success,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'Outfit',
        fontSize: R.fs(11),
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
        letterSpacing: 0.06,
      ),
    );
  }
}

class _BarcodeBadge extends StatelessWidget {
  final String code;
  const _BarcodeBadge({required this.code});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: R.h(16)),
      padding: EdgeInsets.symmetric(horizontal: R.w(14), vertical: R.h(10)),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(R.r(12)),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Text('📷', style: TextStyle(fontSize: R.sp(16))),
          SizedBox(width: R.w(10)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Barcode scanned',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: R.fs(12),
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  ),
                ),
                Text(
                  code,
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: R.fs(11),
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmojiPicker extends StatelessWidget {
  final ScanController ctrl;
  const _EmojiPicker({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: R.h(50),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: ScanController.emojiOptions.length,
        separatorBuilder: (_, __) => SizedBox(width: R.w(8)),
        itemBuilder: (_, i) {
          final e = ScanController.emojiOptions[i];
          return Obx(() {
            final selected = ctrl.selectedEmoji.value == e;
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                ctrl.selectedEmoji.value = e;
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: R.w(46),
                height: R.w(46),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primary.withValues(alpha: 0.15)
                      : AppColors.card,
                  borderRadius: BorderRadius.circular(R.r(12)),
                  border: Border.all(
                    color: selected ? AppColors.primary : AppColors.cardBorder,
                    width: selected ? 1.5 : 0.5,
                  ),
                ),
                child: Center(
                  child: Text(e, style: TextStyle(fontSize: R.sp(22))),
                ),
              ),
            );
          });
        },
      ),
    );
  }
}

class _ZonePicker extends StatelessWidget {
  final ScanController ctrl;
  const _ZonePicker({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: R.h(80),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: ScanController.zones.length,
        separatorBuilder: (_, __) => SizedBox(width: R.w(10)),
        itemBuilder: (_, i) {
          final z = ScanController.zones[i];
          return Obx(() {
            final selected = ctrl.selectedZone.value == z['key'];
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                ctrl.selectedZone.value = z['key']!;
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: R.w(90),
                height: R.h(80),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : AppColors.card,
                  borderRadius: BorderRadius.circular(R.r(14)),
                  border: Border.all(
                    color: selected ? AppColors.primary : AppColors.cardBorder,
                    width: selected ? 1.5 : 0.5,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(z['emoji']!, style: TextStyle(fontSize: R.sp(24))),
                    SizedBox(height: R.h(4)),
                    Text(
                      z['label']!,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: R.fs(10),
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: selected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            );
          });
        },
      ),
    );
  }
}
