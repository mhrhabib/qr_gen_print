import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/di.dart';
import '../../domain/services/purchase_service.dart';

class PaywallModal extends StatelessWidget {
  const PaywallModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 4,
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 32),
          Text('Unlock Pro Features', style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildFeatureRow(Icons.hd, 'High Resolution Exports (2048px)'),
          _buildFeatureRow(Icons.logo_dev, 'Add Custom Logo Center'),
          _buildFeatureRow(Icons.auto_awesome, 'Premium Design Styles'),
          _buildFeatureRow(Icons.picture_as_pdf, 'Vector (SVG) & PDF Export'),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                // Trigger purchase via DI service
                sl<IPurchaseService>().purchaseLifetime();
                Navigator.pop(context);
              },
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.all(20),
                backgroundColor: const Color(0xFF6366F1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: Text(
                'Get Lifetime Access • ${4.99}',
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Maybe Later')),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF6366F1)),
          const SizedBox(width: 16),
          Expanded(child: Text(text, style: GoogleFonts.outfit(fontSize: 16))),
        ],
      ),
    );
  }
}
