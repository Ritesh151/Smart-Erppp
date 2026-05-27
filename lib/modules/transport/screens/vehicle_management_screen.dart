import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smarterp/core/constants/app_constants.dart';
import 'package:smarterp/core/extensions/context_extensions.dart';
import 'package:smarterp/core/theme/theme_extensions.dart';
import 'package:smarterp/core/widgets/app_shell.dart';
import 'package:smarterp/core/widgets/app_card.dart';
import 'package:smarterp/core/widgets/empty_state_widget.dart';
import 'package:smarterp/core/widgets/search_filter_bar.dart';
import 'package:smarterp/core/models/vehicle_model.dart';
import 'package:smarterp/modules/transport/providers/vehicle_provider.dart';
import 'package:smarterp/modules/transport/screens/vehicle_form_widget.dart';

class VehicleManagementScreen extends StatefulWidget {
  const VehicleManagementScreen({super.key});

  @override
  State<VehicleManagementScreen> createState() => _VehicleManagementScreenState();
}

class _VehicleManagementScreenState extends State<VehicleManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VehicleProvider>().loadVehicles();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final theme = context.theme;

    return AppShell(
      child: Consumer<VehicleProvider>(
        builder: (context, provider, _) {
          final vehicles = provider.vehicles;

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, provider),
                const SizedBox(height: 20),
                _buildSearchBar(context, provider),
                const SizedBox(height: 16),
                _buildStatsRow(context, provider),
                const SizedBox(height: 20),
                Expanded(
                  child: provider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : vehicles.isEmpty
                          ? _buildEmptyState(provider)
                          : _buildVehicleList(context, vehicles, provider),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, VehicleProvider provider) {
    final theme = context.theme;
    final colorScheme = context.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vehicle Management',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Manage your fleet vehicles and driver assignments.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () => _showVehicleForm(context, provider),
          icon: const Icon(Icons.add),
          label: const Text('Add Vehicle'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context, VehicleProvider provider) {
    return SearchFilterBar(
      hintText: 'Search by vehicle number, type, driver...',
      searchQuery: provider.searchQuery,
      onSearchChanged: (query) => provider.searchVehicles(query),
      onClearAll: () => provider.clearSearch(),
    );
  }

  Widget _buildStatsRow(BuildContext context, VehicleProvider provider) {
    final theme = context.theme;
    final colorScheme = context.colorScheme;

    return Row(
      children: [
        _buildStatCard('Total Vehicles', '${provider.totalVehicles}', Icons.local_shipping, colorScheme.primary, theme),
        const SizedBox(width: 16),
        _buildStatCard('Active Vehicles', '${provider.activeVehicles}', Icons.check_circle, Colors.green.shade600, theme),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color, ThemeData theme) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
              Text(value, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(VehicleProvider provider) {
    final hasSearch = provider.searchQuery.isNotEmpty;

    if (hasSearch) {
      return EmptyStateWidget(
        icon: Icons.search_off,
        title: 'No Vehicles Found',
        message: 'Try adjusting your search query.',
        actionLabel: 'Clear Search',
        onAction: () => provider.clearSearch(),
      );
    }

    return EmptyStateWidget(
      icon: Icons.local_shipping_outlined,
      title: 'No Vehicles Added Yet',
      message: 'Add your first vehicle to start managing your fleet.',
      actionLabel: 'Add Vehicle',
      onAction: () => _showVehicleForm(context, provider),
    );
  }

  Widget _buildVehicleList(
    BuildContext context,
    List<VehicleModel> vehicles,
    VehicleProvider provider,
  ) {
    final colorScheme = context.colorScheme;

    return SlidableAutoCloseBehavior(
      child: ListView.builder(
        itemCount: vehicles.length,
        itemBuilder: (context, index) {
          final vehicle = vehicles[index];
          final theme = context.theme;

          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
              side: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.5)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
              child: Slidable(
                key: ValueKey(vehicle.id),
                endActionPane: ActionPane(
                  motion: const DrawerMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (context) => _showVehicleForm(context, provider, vehicle: vehicle),
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      icon: Icons.edit,
                      label: 'Edit',
                    ),
                    SlidableAction(
                      onPressed: (context) => _confirmDelete(context, vehicle, provider),
                      backgroundColor: colorScheme.error,
                      foregroundColor: Colors.white,
                      icon: Icons.delete,
                      label: 'Delete',
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
                    ),
                    child: Icon(
                      Icons.local_shipping,
                      color: vehicle.isActive
                          ? colorScheme.primary
                          : Colors.grey,
                    ),
                  ),
                  title: Text(
                    vehicle.vehicleNumber,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '${vehicle.vehicleType} | ${vehicle.capacity} ${vehicle.capacityUnit}${vehicle.driverName != null ? ' | ${vehicle.driverName}' : ''}',
                      style: TextStyle(fontSize: 12, color: colorScheme.onSurface.withOpacity(0.6)),
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: vehicle.isActive
                              ? Colors.green.withOpacity(0.08)
                              : Colors.grey.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
                          border: Border.all(
                            color: vehicle.isActive
                                ? Colors.green.withOpacity(0.25)
                                : Colors.grey.withOpacity(0.25),
                            width: 0.5,
                          ),
                        ),
                        child: Text(
                          vehicle.isActive ? 'ACTIVE' : 'INACTIVE',
                          style: TextStyle(
                            color: vehicle.isActive ? Colors.green.shade600 : Colors.grey,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.chevron_right, size: 16),
                    ],
                  ),
                  onTap: () => _showVehicleDetailDialog(context, vehicle),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showVehicleForm(BuildContext context, VehicleProvider provider, {VehicleModel? vehicle}) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
        child: SizedBox(
          width: 500,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: VehicleFormWidget(
              vehicle: vehicle,
              onSave: vehicle == null
                  ? (number, type, capacity, unit, driver, phone) async {
                      try {
                        await provider.createVehicle(
                          vehicleNumber: number,
                          vehicleType: type,
                          capacity: capacity,
                          capacityUnit: unit,
                          driverName: driver,
                          driverPhone: phone,
                        );
                        if (context.mounted) {
                          Navigator.pop(context);
                          context.showSnackBar('Vehicle created successfully');
                        }
                      } catch (e) {
                        if (context.mounted) {
                          context.showSnackBar('Failed to create vehicle: $e', isError: true);
                        }
                      }
                    }
                  : (number, type, capacity, unit, driver, phone) async {
                      try {
                        await provider.updateVehicle(
                          id: vehicle.id,
                          vehicleNumber: number,
                          vehicleType: type,
                          capacity: capacity,
                          capacityUnit: unit,
                          driverName: driver,
                          driverPhone: phone,
                          isActive: vehicle.isActive,
                        );
                        if (context.mounted) {
                          Navigator.pop(context);
                          context.showSnackBar('Vehicle updated successfully');
                        }
                      } catch (e) {
                        if (context.mounted) {
                          context.showSnackBar('Failed to update vehicle: $e', isError: true);
                        }
                      }
                    },
            ),
          ),
        ),
      ),
    );
  }

  void _showVehicleDetailDialog(BuildContext context, VehicleModel vehicle) {
    final theme = context.theme;
    final colorScheme = context.colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
        title: Row(
          children: [
            Icon(Icons.local_shipping, color: colorScheme.primary),
            const SizedBox(width: 8),
            Text(vehicle.vehicleNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow('Type', vehicle.vehicleType),
            _detailRow('Capacity', '${vehicle.capacity} ${vehicle.capacityUnit}'),
            _detailRow('Driver Name', vehicle.driverName ?? 'N/A'),
            _detailRow('Driver Phone', vehicle.driverPhone ?? 'N/A'),
            _detailRow('Status', vehicle.isActive ? 'Active' : 'Inactive'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, VehicleModel vehicle, VehicleProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Vehicle?'),
        content: Text('Are you sure you want to permanently delete "${vehicle.vehicleNumber}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: context.colorScheme.error),
            onPressed: () async {
              try {
                await provider.deleteVehicle(vehicle.id);
                if (context.mounted) {
                  Navigator.pop(context);
                  context.showSnackBar('Vehicle deleted successfully');
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  context.showSnackBar('Failed to delete vehicle: $e', isError: true);
                }
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
