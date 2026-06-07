import 'package:flutter/material.dart';

import 'package:siddhivinayak_enterprise/core/models/employee_model.dart';
import 'package:siddhivinayak_enterprise/modules/payroll/utils/image_helper.dart';

class EmployeeAvatar extends StatelessWidget {
  final EmployeeModel employee;
  final String? aadhaarImagePath;
  final double size;
  final bool showAadhaarBadge;
  final VoidCallback? onAadhaarClick;

  const EmployeeAvatar({
    super.key,
    required this.employee,
    this.aadhaarImagePath,
    this.size = 48,
    this.showAadhaarBadge = false,
    this.onAadhaarClick,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        _buildAvatar(context),
        if (showAadhaarBadge) _buildAadhaarBadge(context),
      ],
    );
  }

  Widget _buildAvatar(BuildContext context) {
    final theme = Theme.of(context);
    final hasImage = aadhaarImagePath != null && aadhaarImagePath!.isNotEmpty;

    if (hasImage) {
      final provider = ImageHelper.getImageProvider(aadhaarImagePath);
      if (provider != null) {
        return ClipOval(
          child: Image(
            image: provider,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _buildInitials(context),
          ),
        );
      }
    }

    return _buildInitials(context);
  }

  Widget _buildInitials(BuildContext context) {
    final initials = _getInitials();
    final color = _getColor(initials);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontSize: size * 0.4,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  String _getInitials() {
    final name = employee.fullName;
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0].substring(0, 2).toUpperCase();
  }

  Color _getColor(String initials) {
    final hash = initials.hashCode;
    final hue = (hash % 360).toDouble();
    return HSLColor.fromAHSL(1.0, hue, 0.7, 0.5).toColor();
  }

  Widget _buildAadhaarBadge(BuildContext context) {
    final hasImage = aadhaarImagePath != null && aadhaarImagePath!.isNotEmpty;
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: hasImage ? Colors.green : Colors.grey,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Icon(
        Icons.fingerprint_rounded,
        size: 12,
        color: Colors.white,
      ),
    );
  }
}
