import 'package:flutter/material.dart';
import '../main.dart';
import '../models/history_data.dart';
import '../services/history_service.dart';
import '../widgets/history_card.dart';
import 'history_map.dart';


class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final HistoryService _historyService = HistoryService();
  final ScrollController _scrollController = ScrollController();
  final List<HistoryData> _detections = [];

  bool _isLoadingInitial = true;
  bool _isLoadingMore = false;
  bool _hasError = false;
  String _errorMessage = '';
  String _selectedFilter = 'all';

  final Map<String, String?> _filterMap = {
    'all': null,
    'dangerous': 'dangerous',
    'wild': 'wild',
    'week': 'week',
  };

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadInitialData();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  /// Detect when user scrolls near bottom → load more
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreData();
    }
  }

  /// Initial fetch
  Future<void> _loadInitialData() async {
    setState(() {
      _isLoadingInitial = true;
      _hasError = false;
      _detections.clear();
    });

    _historyService.resetPagination();

    try {
      final results = await _historyService.fetchDetections(
        filterType: _filterMap[_selectedFilter],
      );
      setState(() {
        _detections.addAll(results);
        _isLoadingInitial = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingInitial = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  /// Load next page
  Future<void> _loadMoreData() async {
    if (_isLoadingMore || !_historyService.hasMore) return;

    setState(() => _isLoadingMore = true);

    try {
      final results = await _historyService.fetchDetections(
        filterType: _filterMap[_selectedFilter],
      );
      setState(() {
        _detections.addAll(results);
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  /// When a filter chip is tapped
  void _onFilterSelected(String filter) {
    if (_selectedFilter == filter) return;
    setState(() => _selectedFilter = filter);
    _loadInitialData();
  }

  /// Navigate to map screen with selected detection
  void _onDetectionTap(HistoryData detection) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetectionMapScreen(alert: detection),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('Detection History'),
        backgroundColor: AppTheme.darkBackground,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadInitialData,
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Filter Chips ──
          Container(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: 'All',
                    isSelected: _selectedFilter == 'all',
                    onTap: () => _onFilterSelected('all'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Dangerous',
                    isSelected: _selectedFilter == 'dangerous',
                    onTap: () => _onFilterSelected('dangerous'),
                    color: AppTheme.alertRed,
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Wild',
                    isSelected: _selectedFilter == 'wild',
                    onTap: () => _onFilterSelected('wild'),
                    color: AppTheme.forestGreen,
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'This Week',
                    isSelected: _selectedFilter == 'week',
                    onTap: () => _onFilterSelected('week'),
                    color: Colors.blueAccent,
                  ),
                ],
              ),
            ),
          ),

          // ── Body ──
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    // Initial loading
    if (_isLoadingInitial) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.forestGreen),
      );
    }

    // Error state
    if (_hasError && _detections.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline,
                  size: 64, color: AppTheme.alertRed.withValues(alpha: 0.7)),
              const SizedBox(height: 16),
              Text(
                'Failed to load detections',
                style: TextStyle(
                    color: AppTheme.white.withValues(alpha: 0.9),
                    fontSize: 18,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: AppTheme.white.withValues(alpha: 0.5),
                    fontSize: 13),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadInitialData,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.forestGreen),
              ),
            ],
          ),
        ),
      );
    }

    // Empty state
    if (_detections.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.pets,
                size: 64, color: AppTheme.white.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text(
              'No detections found',
              style: TextStyle(
                  color: AppTheme.white.withValues(alpha: 0.7), fontSize: 16),
            ),
          ],
        ),
      );
    }

    // Detection list with lazy loading
    return RefreshIndicator(
      onRefresh: () async => _loadInitialData(),
      color: AppTheme.forestGreen,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        // +1 for the loading indicator at bottom
        itemCount: _detections.length + (_historyService.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          // Bottom loader
          if (index == _detections.length) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: _isLoadingMore
                    ? const CircularProgressIndicator(
                    color: AppTheme.forestGreen, strokeWidth: 2)
                    : TextButton(
                  onPressed: _loadMoreData,
                  child: Text('Load more',
                      style: TextStyle(
                          color:
                          AppTheme.white.withValues(alpha: 0.6))),
                ),
              ),
            );
          }

          final detection = _detections[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: HistoryCard(
              history: detection,
              onTap: () => _onDetectionTap(detection),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Filter Chip Widget
// ─────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? color;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (color ?? AppTheme.forestGreen)
              : AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? (color ?? AppTheme.forestGreen)
                : AppTheme.white.withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? AppTheme.white
                : AppTheme.white.withValues(alpha: 0.7),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}