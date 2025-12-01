import 'package:flutter/material.dart';

class PrimaryCta extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool busy;

  const PrimaryCta({
    super.key,
    required this.label,
    required this.onTap,
    this.busy = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 70,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0E3B66), // Deep blue from the design
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
          elevation: 0,
        ),
        onPressed: busy ? null : onTap,
        child: busy
            ? SizedBox(
                height: 24,
                width: 24,
                child: Semantics(
                  label: 'Loading',
                  liveRegion: true,
                  container: true,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}
