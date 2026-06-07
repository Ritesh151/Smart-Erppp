import 'package:flutter/material.dart';

import 'package:siddhivinayak_enterprise/core/extensions/context_extensions.dart';
import 'package:siddhivinayak_enterprise/core/responsive/breakpoints.dart';
import 'package:siddhivinayak_enterprise/core/widgets/app_button.dart';
import 'package:siddhivinayak_enterprise/core/widgets/app_card.dart';
import 'package:siddhivinayak_enterprise/modules/payroll/utils/image_helper.dart';
import 'package:siddhivinayak_enterprise/modules/payroll/widgets/image_preview_dialog.dart';

class AadhaarUploadCard extends StatelessWidget {
  final String? currentImage;
  final String employeeName;
  final VoidCallback? onUpload;
  final VoidCallback? onReplace;
  final VoidCallback? onDelete;
  final VoidCallback? onViewFull;
  final bool isLoading;
  final bool isDesktop;

  const AadhaarUploadCard({
    super.key,
    this.currentImage,
    required this.employeeName,
    this.onUpload,
    this.onReplace,
    this.onDelete,
    this.onViewFull,
    this.isLoading = false,
    this.isDesktop = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final deviceType = context.deviceType;
    final isDesktopLayout = isDesktop || deviceType == DeviceType.desktop || deviceType == DeviceType.largeDesktop;

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.fingerprint_rounded,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Aadhaar Card',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      currentImage != null
                          ? 'Aadhaar card uploaded'
                          : 'Upload employee Aadhaar card image',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (currentImage != null)
            _buildImagePreview(context, theme, isDesktopLayout)
          else
            _buildUploadArea(context, theme, isDesktopLayout),
        ],
      ),
    );
  }

  Widget _buildImagePreview(BuildContext context, ThemeData theme, bool isDesktop) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: isDesktop ? 300 : 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.dividerColor.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (currentImage != null)
                Image(
                  image: ImageHelper.getImageProvider(currentImage) ?? const AssetImage('assets/images/placeholder.png'),
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => _buildPlaceholder(theme),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                )
              else
                _buildPlaceholder(theme),
              if (isLoading)
                Container(
                  color: Colors.black45,
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
              Positioned(
                top: 8,
                right: 8,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildIconButton(
                      icon: Icons.zoom_in_rounded,
                      tooltip: 'View Full',
                      onTap: () => _showPreviewDialog(context),
                    ),
                    const SizedBox(width: 4),
                    _buildIconButton(
                      icon: Icons.swap_horiz_rounded,
                      tooltip: 'Replace',
                      onTap: onReplace ?? onUpload,
                    ),
                    const SizedBox(width: 4),
                    _buildIconButton(
                      icon: Icons.delete_rounded,
                      tooltip: 'Remove',
                      color: theme.colorScheme.error,
                      onTap: onDelete,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isDesktop) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: 'View Full',
                  icon: Icons.zoom_in_rounded,
                  variant: AppButtonVariant.outline,
                  onPressed: () => _showPreviewDialog(context),
                  isFullWidth: true,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppButton(
                  text: 'Replace',
                  icon: Icons.swap_horiz_rounded,
                  variant: AppButtonVariant.outline,
                  onPressed: onReplace ?? onUpload,
                  isFullWidth: true,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppButton(
                  text: 'Remove',
                  icon: Icons.delete_rounded,
                  variant: AppButtonVariant.danger,
                  onPressed: onDelete,
                  isFullWidth: true,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildUploadArea(BuildContext context, ThemeData theme, bool isDesktop) {
    return InkWell(
      onTap: isLoading ? null : onUpload,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        height: isDesktop ? 260 : 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.dividerColor,
            width: 2,
          ),
          color: theme.colorScheme.surface.withOpacity(0.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: isLoading
                  ? SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: theme.colorScheme.primary,
                      ),
                    )
                  : Icon(
                      Icons.cloud_upload_outlined,
                      size: 40,
                      color: theme.colorScheme.primary,
                    ),
            ),
            const SizedBox(height: 16),
            Text(
              'Upload Aadhaar Card',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Tap to select image (JPG, JPEG, PNG)',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Max size: 5 MB',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.4),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(ThemeData theme) {
    return Container(
      color: theme.colorScheme.surface.withOpacity(0.3),
      child: Center(
        child: Icon(
          Icons.broken_image_outlined,
          size: 48,
          color: theme.colorScheme.onSurface.withOpacity(0.3),
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback? onTap,
    Color? color,
  }) {
    return Material(
      color: Colors.black45,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 18, color: color ?? Colors.white),
        ),
      ),
    );
  }

  void _showPreviewDialog(BuildContext context) {
    if (currentImage == null) return;
    showDialog(
      context: context,
      builder: (_) => ImagePreviewDialog(
        imageFile: currentImage!,
        employeeName: employeeName,
      ),
    );
  }
}
