import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallet_manager/models/archive_summary.dart';
import 'package:wallet_manager/providers/app_state.dart';
import 'package:wallet_manager/screens/archive_details_screen.dart';
import 'package:wallet_manager/services/storage_service.dart';
import 'package:wallet_manager/theme/app_colors.dart';
import 'package:wallet_manager/theme/app_typography.dart';
import 'package:wallet_manager/widgets/archive_dialog.dart';
import 'package:wallet_manager/widgets/archive_summary_card.dart';

class ArchiveListScreen extends StatefulWidget {
  final bool isEmbedded;

  const ArchiveListScreen({
    super.key,
    this.isEmbedded = false,
  });

  @override
  State<ArchiveListScreen> createState() => _ArchiveListScreenState();
}

class _ArchiveListScreenState extends State<ArchiveListScreen> {
  final StorageService _storageService = StorageService();
  List<ArchiveSummary> _archives = [];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadArchives();
  }

  Future<void> _loadArchives() async {
    print('🔄 _loadArchives called');

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final archives = await _storageService.getAllArchiveSummaries();
      print('📋 Archives loaded: ${archives.length}');

      if (mounted) {
        setState(() {
          _archives = archives;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error loading archives: $e');
      if (mounted) {
        setState(() {
          _error = 'Failed to load archives: $e';
          _isLoading = false;
        });
      }
    }
  }

  List<ArchiveSummary> get _filteredArchives {
    if (_searchQuery.isEmpty) return _archives;

    return _archives.where((archive) {
      return archive.monthYearDisplay.toLowerCase().contains(
          _searchQuery.toLowerCase()
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Column(
      children: [
        // Search bar with manual refresh button
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search months...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                        : null,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Refresh button always visible
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadArchives,
                tooltip: 'Refresh list',
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.surfaceCard,
                  side: BorderSide(color: AppColors.border),
                  padding: const EdgeInsets.all(12),
                ),
              ),
            ],
          ),
        ),

        // Content
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: AppColors.expenseCoral,
                ),
                const SizedBox(height: 16),
                Text(
                  _error!,
                  style: AppTypography.bodyText(),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadArchives,
                  child: const Text('Retry'),
                ),
              ],
            ),
          )
              : RefreshIndicator(
            onRefresh: _loadArchives,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: _filteredArchives.length + 2,
              itemBuilder: (context, index) {
                if (index == 0) {
                  // Archive Current Month card
                  return const Padding(
                    padding: EdgeInsets.only(bottom: 0),
                  );
                }

                if (index == 1) {
                  // Current Cycle card
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildCurrentCycleCard(appState),
                  );
                }

                final archive = _filteredArchives[index - 2];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ArchiveSummaryCard(
                    summary: archive,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ArchiveDetailsScreen(
                            fileName: archive.fileName,
                            monthYear: archive.monthYearDisplay,
                          ),
                        ),
                      ).then((_) => _loadArchives());
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  // Archive Current Month card
  Widget _buildArchiveNowCard(AppState appState) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.archive_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Archive Current Month',
                  style: AppTypography.cardTitle().copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Save this month and start fresh',
                  style: AppTypography.caption().copyWith(
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.arrow_forward,
              color: Colors.white,
            ),
            onPressed: _showArchiveDialog,
          ),
        ],
      ),
    );
  }

  // Current Cycle card
  Widget _buildCurrentCycleCard(AppState appState) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.incomeSoftBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.today_outlined,
              color: AppColors.brandBlue,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Cycle',
                  style: AppTypography.cardTitle(),
                ),
                const SizedBox(height: 4),
                Text(
                  '${appState.transactions.length} transactions this month',
                  style: AppTypography.caption(),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: AppColors.incomeSoftTint,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Active',
              style: AppTypography.caption().copyWith(
                color: AppColors.incomeGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showArchiveDialog() async {
    print('🔄 Opening archive dialog...');

    final confirmed = await showArchiveDialog(context);
    print('📋 Archive dialog result: $confirmed');

    if (confirmed == true) {
      final appState = context.read<AppState>();

      // Archive the month
      await appState.archiveCurrentMonth();
      print('✅ Archive completed');

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Month archived successfully! Tap refresh to see it in the list.',
              style: AppTypography.bodyText().copyWith(color: Colors.white),
            ),
            backgroundColor: AppColors.incomeGreen,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}