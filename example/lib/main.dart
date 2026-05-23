// ignore_for_file: use_build_context_synchronously

import 'package:device_permission/device_permission.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Device Permission Example',
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
      home: const PermissionExamplePage(),
    );
  }
}

const double _largeScreenBreakpoint = 700;

class PermissionExamplePage extends StatefulWidget {
  const PermissionExamplePage({super.key});

  @override
  State<PermissionExamplePage> createState() => _PermissionExamplePageState();
}

class _PermissionExamplePageState extends State<PermissionExamplePage> {
  final Map<Permission, PermissionStatus> _statuses = {};
  final Set<Permission> _unsupported = {};
  final Set<String> _errors = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkAllPermissions();
  }

  Future<void> _checkAllPermissions() async {
    final allPermissions = Permission.values;

    for (final permission in allPermissions) {
      try {
        final status = await permission.status;
        if (mounted) {
          setState(() {
            _statuses[permission] = status;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _unsupported.add(permission);
            _errors.add('${_permissionName(permission)}: $e');
          });
        }
      }
    }

    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _requestPermission(Permission permission) async {
    try {
      final status = await permission.request();
      if (mounted) {
        setState(() {
          _statuses[permission] = status;
          _unsupported.remove(permission);
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_permissionName(permission)}: ${status.name}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } on UnimplementedError catch (_) {
      if (mounted) {
        setState(() {
          _unsupported.add(permission);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${_permissionName(permission)} is not supported on this platform.',
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } on UnsupportedError catch (_) {
      if (mounted) {
        setState(() {
          _unsupported.add(permission);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${_permissionName(permission)} is not supported on this platform.',
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error requesting ${_permissionName(permission)}: $e',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  String _permissionName(Permission p) {
    return p.toString().replaceAll('Permission.', '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Permissions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _statuses.clear();
                _unsupported.clear();
                _errors.clear();
                _loading = true;
              });
              _checkAllPermissions();
            },
            tooltip: 'Refresh all',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              try {
                await openAppSettings();
              } catch (_) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Cannot open app settings on this platform.',
                      ),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              }
            },
            tooltip: 'Open App Settings',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                final isLarge = constraints.maxWidth > _largeScreenBreakpoint;
                if (isLarge) {
                  return _buildLargeLayout(constraints.maxWidth);
                }
                return _buildSmallLayout();
              },
            ),
    );
  }

  Widget _buildLargeLayout(double maxWidth) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Permission Statuses',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...Permission.values
                .where(
                  (p) => _statuses.containsKey(p) || _unsupported.contains(p),
                )
                .toList()
                .expand((permission) {
                  final status = _statuses[permission];
                  final unsupported = _unsupported.contains(permission);
                  return [
                    _PermissionTile(
                      permission: permission,
                      status: status,
                      unsupported: unsupported,
                      onRequest: () => _requestPermission(permission),
                      compact: false,
                    ),
                  ];
                }),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallLayout() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: Permission.values.length,
      itemBuilder: (context, index) {
        final permission = Permission.values[index];
        final status = _statuses[permission];
        final unsupported = _unsupported.contains(permission);
        return _PermissionTile(
          permission: permission,
          status: status,
          unsupported: unsupported,
          onRequest: () => _requestPermission(permission),
          compact: true,
        );
      },
    );
  }
}

class _PermissionTile extends StatelessWidget {
  final Permission permission;
  final PermissionStatus? status;
  final bool unsupported;
  final VoidCallback onRequest;
  final bool compact;

  const _PermissionTile({
    required this.permission,
    required this.status,
    required this.unsupported,
    required this.onRequest,
    required this.compact,
  });

  Color _statusColor() {
    if (unsupported) return Colors.grey.shade400;
    if (status == null) return Colors.grey;
    switch (status!) {
      case PermissionStatus.granted:
        return Colors.green;
      case PermissionStatus.denied:
        return Colors.orange;
      case PermissionStatus.permanentlyDenied:
        return Colors.red;
      case PermissionStatus.restricted:
        return Colors.grey;
      case PermissionStatus.limited:
        return Colors.blue;
      case PermissionStatus.provisional:
        return Colors.lightBlue;
    }
  }

  IconData _statusIcon() {
    if (unsupported) return Icons.do_not_disturb_alt;
    if (status == null) return Icons.schedule;
    switch (status!) {
      case PermissionStatus.granted:
        return Icons.check_circle;
      case PermissionStatus.denied:
        return Icons.help_outline;
      case PermissionStatus.permanentlyDenied:
        return Icons.cancel;
      case PermissionStatus.restricted:
        return Icons.block;
      case PermissionStatus.limited:
        return Icons.warning_amber;
      case PermissionStatus.provisional:
        return Icons.info_outline;
    }
  }

  String _subtitle() {
    if (unsupported) return 'Not supported on this platform';
    if (status == null) return 'Checking...';
    return status!.name;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: compact ? 6 : 8),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 12 : 16,
          vertical: compact ? 4 : 8,
        ),
        child: Row(
          children: [
            Icon(_statusIcon(), color: _statusColor(), size: compact ? 20 : 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    permission.toString().replaceAll('Permission.', ''),
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: unsupported ? Colors.grey : null,
                      fontSize: compact ? 14 : 16,
                    ),
                  ),
                  Text(
                    _subtitle(),
                    style: TextStyle(
                      color: unsupported ? Colors.grey : null,
                      fontSize: compact ? 11 : 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: onRequest,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: compact ? 12 : 16,
                  vertical: compact ? 4 : 8,
                ),
                textStyle: TextStyle(fontSize: compact ? 12 : 14),
              ),
              child: const Text('Request'),
            ),
          ],
        ),
      ),
    );
  }
}
