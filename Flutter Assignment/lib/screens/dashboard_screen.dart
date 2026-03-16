import 'package:flutter/material.dart';
import 'package:warehouse_admin/core/theme.dart';
import 'package:warehouse_admin/models/product.dart';
import 'package:warehouse_admin/services/api_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DashboardStats? _stats;
  List<StockMovement> _recentActivity = [];
  bool _isLoading = true;
  String _error = '';

  static const _headerTitleStyle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w900,
    color: Colors.white,
    letterSpacing: -0.3,
  );

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      setState(() => _isLoading = true);

      // Load stats from API
      final stats = await ApiService.getDashboardStats();

      // Load recent stock movements
      final movements = await ApiService.getStockMovements();

      setState(() {
        _stats = stats;
        _recentActivity = movements.take(5).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadDashboardData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_stats == null) {
      return const Center(
        child: Text('No data available'),
      );
    }

    final stats = _stats!;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        color: const Color(0xFFF7F7FB),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gradient header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 22),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.primaryColor.withOpacity(0.82),
                    AppTheme.successColor.withOpacity(0.55),
                  ],
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.25),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.dashboard_outlined,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Text('Dashboard', style: _headerTitleStyle),
                  const Spacer(),
                  IconButton(
                    onPressed: _loadDashboardData,
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    tooltip: 'Refresh',
                  ),
                ],
              ),
            ),

            // Body
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  isMobile
                      ? _buildMobileStatsGrid(stats)
                      : _buildDesktopStatsRow(stats),
                  const SizedBox(height: 18),
                  _buildRecentActivityCard(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileStatsGrid(DashboardStats stats) {
    return Column(
      children: [
        Row(
          children: [
            _buildGlassStatCard(
              'Total Products',
              '${stats.totalProducts}',
              Icons.inventory_2_outlined,
              AppTheme.primaryColor,
            ),
            const SizedBox(width: 12),
            _buildGlassStatCard(
              'Low Stock',
              '${stats.lowStockItems}',
              Icons.warning_amber_outlined,
              AppTheme.warningColor,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildGlassStatCard(
              'Out of Stock',
              '${stats.outOfStockItems}',
              Icons.error_outline,
              AppTheme.errorColor,
            ),
            const SizedBox(width: 12),
            _buildGlassStatCard(
              'Total Value',
              'Rs.${_formatValue(stats.totalInventoryValue)}',
              Icons.attach_money_outlined,
              AppTheme.successColor,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopStatsRow(DashboardStats stats) {
    return Row(
      children: [
        _buildGlassStatCard(
          'Total Products',
          '${stats.totalProducts}',
          Icons.inventory_2_outlined,
          AppTheme.primaryColor,
        ),
        const SizedBox(width: 16),
        _buildGlassStatCard(
          'Low Stock',
          '${stats.lowStockItems}',
          Icons.warning_amber_outlined,
          AppTheme.warningColor,
        ),
        const SizedBox(width: 16),
        _buildGlassStatCard(
          'Out of Stock',
          '${stats.outOfStockItems}',
          Icons.error_outline,
          AppTheme.errorColor,
        ),
        const SizedBox(width: 16),
        _buildGlassStatCard(
          'Total Value',
          'Rs.${_formatValue(stats.totalInventoryValue)}',
          Icons.currency_rupee_outlined,
          AppTheme.successColor,
        ),
      ],
    );
  }

  String _formatValue(double value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toStringAsFixed(0);
  }

  Widget _buildGlassStatCard(
      String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFEAEAF2), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: color.withOpacity(0.75),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        color.withOpacity(0.22),
                        color.withOpacity(0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
                height: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivityCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEAEAF2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.history,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Recent Activity',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_recentActivity.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: Text(
                  'No recent activity',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            )
          else
            ..._recentActivity.asMap().entries.map((entry) {
              final index = entry.key;
              final movement = entry.value;
              final isPositive = movement.type == 'in' || movement.type == 'IN';

              return Column(
                children: [
                  _buildGlassActivityItem(
                    movement.productName,
                    '${isPositive ? '+' : '-'}${movement.quantity} units',
                    _formatTimeAgo(movement.timestamp),
                    isPositive,
                    movement.reason,
                  ),
                  if (index < _recentActivity.length - 1)
                    Divider(
                      height: 16,
                      color: Colors.grey.shade200,
                    ),
                ],
              );
            }).toList(),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    }
  }

  Widget _buildGlassActivityItem(String product, String quantity, String time,
      bool isPositive, String reason) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: isPositive
                  ? AppTheme.successColor.withOpacity(0.12)
                  : AppTheme.errorColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isPositive ? Icons.south : Icons.north,
              color: isPositive ? AppTheme.successColor : AppTheme.errorColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  reason.isNotEmpty ? reason : 'Stock update',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            quantity,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: isPositive ? AppTheme.successColor : AppTheme.errorColor,
            ),
          ),
        ],
      ),
    );
  }
}
