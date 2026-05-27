import 'package:flutter/material.dart';
import 'package:smarterp/core/constants/app_constants.dart';
import 'package:smarterp/core/models/transport_model.dart';
import 'package:smarterp/core/models/transport_status_model.dart';

class TransportTimelineWidget extends StatelessWidget {
  final TransportModel transport;

  const TransportTimelineWidget({super.key, required this.transport});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Timeline', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        _buildTimelineItem(
          context: context,
          title: 'Transport Planned',
          subtitle: transport.departureDate.toLocal().toString().substring(0, 16),
          icon: Icons.schedule,
          color: Colors.orange,
          isCompleted: !transport.isPlanned,
          isActive: transport.isPlanned,
          isFirst: true,
        ),
        _buildConnectorLine(context, isActive: transport.isOnTheWay || transport.isDelivered),
        _buildTimelineItem(
          context: context,
          title: 'On The Way',
          subtitle: _getOnTheWaySubtitle(),
          icon: Icons.flight_takeoff,
          color: Colors.blue,
          isCompleted: transport.isDelivered,
          isActive: transport.isOnTheWay,
        ),
        _buildConnectorLine(context, isActive: transport.isDelivered),
        if (transport.isCancelled)
          _buildTimelineItem(
            context: context,
            title: 'Cancelled',
            subtitle: transport.updatedAt.toLocal().toString().substring(0, 16),
            icon: Icons.cancel,
            color: Colors.red,
            isCompleted: false,
            isActive: true,
            isTerminal: true,
          )
        else
          _buildTimelineItem(
            context: context,
            title: 'Delivered',
            subtitle: transport.actualArrival != null
                ? transport.actualArrival!.toLocal().toString().substring(0, 16)
                : transport.estimatedArrival != null
                    ? 'Est. ${transport.estimatedArrival!.toLocal().toString().substring(0, 16)}'
                    : 'Pending',
            icon: Icons.check_circle,
            color: Colors.green,
            isCompleted: transport.isDelivered,
            isActive: transport.isDelivered,
            isTerminal: true,
          ),
      ],
    );
  }

  String _getOnTheWaySubtitle() {
    if (transport.isOnTheWay) {
      return 'Departed ${transport.departureDate.toLocal().toString().substring(0, 16)}';
    }
    if (transport.isDelivered && transport.actualArrival != null) {
      return 'Arrived ${transport.actualArrival!.toLocal().toString().substring(0, 16)}';
    }
    if (transport.estimatedArrival != null) {
      return 'Est. arrival ${transport.estimatedArrival!.toLocal().toString().substring(0, 16)}';
    }
    return 'Pending departure';
  }

  Widget _buildTimelineItem({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isCompleted,
    required bool isActive,
    bool isFirst = false,
    bool isTerminal = false,
  }) {
    final effectiveColor = isCompleted || isActive ? color : Colors.grey.shade300;
    final opacity = isCompleted || isActive ? 1.0 : 0.4;

    return Padding(
      padding: EdgeInsets.only(top: isFirst ? 0 : 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isCompleted && !isActive
                      ? effectiveColor.withOpacity(0.15)
                      : isActive
                          ? effectiveColor
                          : Colors.grey.shade100,
                  shape: BoxShape.circle,
                  border: !isActive || isCompleted ? Border.all(color: effectiveColor.withOpacity(0.5), width: 2) : null,
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: isActive && !isCompleted ? Colors.white : effectiveColor,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isActive && !isTerminal
                    ? effectiveColor.withOpacity(0.05)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
                border: isActive && !isTerminal
                    ? Border.all(color: effectiveColor.withOpacity(0.2))
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.black.withOpacity(opacity),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.withOpacity(opacity),
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

  Widget _buildConnectorLine(BuildContext context, {required bool isActive}) {
    return Padding(
      padding: const EdgeInsets.only(left: 18),
      child: Container(
        width: 4,
        height: 32,
        decoration: BoxDecoration(
          color: isActive
              ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
              : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
