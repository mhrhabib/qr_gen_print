import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../blocs/qr_cubit.dart';
import '../widgets/qr_preview_widget.dart';
import '../widgets/paywall_modal.dart';
import '../../domain/models/qr_config.dart';
import '../../core/di.dart';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import '../../domain/services/qr_export_service.dart';
import '../../domain/services/purchase_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => QrCubit(), child: const HomeView());
  }
}

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final TextEditingController _controller = TextEditingController();
  final GlobalKey _qrKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Use DI to listen to purchase status
    sl<IPurchaseService>().purchaseStatusStream.listen((purchased) {
      if (mounted) {
        context.read<QrCubit>().setPurchased(purchased);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QrCubit, QrState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(state),
                  const SizedBox(height: 32),
                  _buildStepIndicator(state),
                  const SizedBox(height: 32),
                  Center(
                    child: QrPreview(config: state.config, globalKey: _qrKey),
                  ),
                  const SizedBox(height: 40),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: state.step == 1 ? _buildStep1(context, state) : _buildStep2(context, state),
                  ),
                  const SizedBox(height: 32),
                  _buildFooter(context, state),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(QrState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Beautiful QR', style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold)),
        Text(
          state.step == 1 ? 'Step 1: Enter Content' : 'Step 2: Customize Design',
          style: GoogleFonts.outfit(color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildStepIndicator(QrState state) {
    return Row(
      children: [
        Expanded(child: _buildIndicatorBar(state.step >= 1)),
        const SizedBox(width: 12),
        Expanded(child: _buildIndicatorBar(state.step >= 2)),
      ],
    );
  }

  Widget _buildIndicatorBar(bool active) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 6,
      decoration: BoxDecoration(
        color: active ? const Color(0xFF6366F1) : Colors.black12,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  Widget _buildStep1(BuildContext context, QrState state) {
    return Column(
      key: const ValueKey(1),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _typeIcon(context, state, QrType.url, Icons.link, 'URL'),
            _typeIcon(context, state, QrType.text, Icons.notes, 'Text'),
            _typeIcon(context, state, QrType.wifi, Icons.wifi, 'WiFi'),
          ],
        ),
        const SizedBox(height: 32),
        TextField(
          controller: _controller..text = state.config.content,
          onChanged: (val) {
            context.read<QrCubit>().updateConfig(state.config.copyWith(content: val));
          },
          decoration: InputDecoration(
            hintText: 'Enter your content here...',
            prefixIcon: const Icon(Icons.edit_note, color: Color(0xFF6366F1)),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  Widget _buildStep2(BuildContext context, QrState state) {
    return Column(
      key: const ValueKey(2),
      children: [
        _buildStyleRow(
          'Foreground Color',
          child: _colorCircle(state.config.fgColor, () => _showColorPicker(context, true)),
        ),
        const SizedBox(height: 16),
        _buildStyleRow(
          'Background Color',
          child: _colorCircle(state.config.bgColor, () => _showColorPicker(context, false)),
        ),
        const SizedBox(height: 16),
        _buildStyleRow('Add Logo', child: _logoButton(context, state)),
      ],
    );
  }

  Widget _buildStyleRow(String label, {required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
          child,
        ],
      ),
    );
  }

  Widget _typeIcon(BuildContext context, QrState state, QrType type, IconData icon, String label) {
    bool selected = state.config.type == type;
    return GestureDetector(
      onTap: () => context.read<QrCubit>().updateConfig(state.config.copyWith(type: type)),
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: selected ? const Color(0xFF6366F1) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: selected
                  ? [BoxShadow(color: const Color(0xFF6366F1).withValues(alpha: 0.3), blurRadius: 10)]
                  : [],
            ),
            child: Icon(icon, color: selected ? Colors.white : Colors.black45),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.outfit(fontSize: 12, fontWeight: selected ? FontWeight.bold : FontWeight.normal),
          ),
        ],
      ),
    );
  }

  Widget _colorCircle(Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black12),
        ),
      ),
    );
  }

  Widget _logoButton(BuildContext context, QrState state) {
    return TextButton.icon(
      onPressed: () => _pickLogo(context, state),
      icon: const Icon(Icons.add_photo_alternate),
      label: Text(state.config.logoPath == null ? 'Select' : 'Change'),
    );
  }

  Future<void> _pickLogo(BuildContext context, QrState state) async {
    if (!state.isPurchased) {
      _showPaywall(context);
      return;
    }
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);

    // Check if the widget is still in the tree before using context
    if (!context.mounted) return;

    if (image != null) {
      context.read<QrCubit>().updateConfig(state.config.copyWith(logoPath: image.path));
    }
  }

  void _showColorPicker(BuildContext context, bool isForeground) {
    final cubit = context.read<QrCubit>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: isForeground ? cubit.state.config.fgColor : cubit.state.config.bgColor,
            onColorChanged: (color) {
              cubit.updateConfig(
                isForeground
                    ? cubit.state.config.copyWith(fgColor: color)
                    : cubit.state.config.copyWith(bgColor: color),
              );
            },
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Done'))],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, QrState state) {
    return Row(
      children: [
        if (state.step == 2)
          Expanded(
            child: OutlinedButton(
              onPressed: () => context.read<QrCubit>().previousStep(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text('Back'),
            ),
          ),
        if (state.step == 2) const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: FilledButton(
            onPressed: () {
              if (state.step == 1) {
                if (state.config.content.isNotEmpty) {
                  context.read<QrCubit>().nextStep();
                }
              } else {
                _showExportOptions(context);
              }
            },
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.all(20),
              backgroundColor: const Color(0xFF6366F1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: Text(state.step == 1 ? 'Next' : 'Export & Download'),
          ),
        ),
      ],
    );
  }

  void _showPaywall(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PaywallModal(),
    );
  }

  void _showExportOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('PNG (Standard)'),
              onTap: () {
                Navigator.pop(context);
                _saveImage(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.hd),
              title: const Text('PNG (HD - Premium)'),
              trailing: const Icon(Icons.lock, size: 16),
              onTap: () {
                Navigator.pop(context);
                _showPaywall(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('SVG / PDF (Premium)'),
              trailing: const Icon(Icons.lock, size: 16),
              onTap: () {
                Navigator.pop(context);
                _showPaywall(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveImage(BuildContext context) async {
    try {
      final boundary = _qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        final pngBytes = byteData.buffer.asUint8List();
        final path = await sl<IQrExportService>().saveImage(pngBytes);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('QR Code saved to $path')));
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save QR Code: $e')));
      }
    }
  }
}
