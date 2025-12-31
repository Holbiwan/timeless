import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeless/utils/employer_migration_helper.dart';

class EmployerAdminScreen extends StatefulWidget {
  const EmployerAdminScreen({super.key});

  @override
  State<EmployerAdminScreen> createState() => _EmployerAdminScreenState();
}

class _EmployerAdminScreenState extends State<EmployerAdminScreen> {
  bool _isLoading = false;
  Map<String, dynamic>? _statusReport;

  @override
  void initState() {
    super.initState();
    _loadStatusReport();
  }

  Future<void> _loadStatusReport() async {
    try {
      final report = await EmployerMigrationHelper.generateStatusReport();
      if (mounted) {
        setState(() {
          _statusReport = report;
        });
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar(
          '⚠️ Status Load Error',
          'Failed to load status report: $e',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
      }
    }
  }

  Future<void> _runMigration() async {
    final confirmed = await _showConfirmationDialog(
      'Run Migration',
      'This will migrate all existing employers. This action affects the production database. Continue?',
    );
    
    if (!confirmed) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final results = await EmployerMigrationHelper.migrateExistingEmployers();
      
      if (!mounted) return;
      
      Get.snackbar(
        '✅ Migration Complete',
        'Processed: ${results['employersProcessed']}\nActivated: ${results['employersActivated']}\nJobs marked: ${results['jobsMarked']}',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );

      await _loadStatusReport();

    } catch (e) {
      if (!mounted) return;
      
      Get.snackbar(
        '❌ Migration Failed',
        'Error: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 8),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _cleanupDemoData() async {
    final confirmed = await _showConfirmationDialog(
      'Cleanup Demo Data',
      'This will permanently delete all demo jobs. This action cannot be undone. Continue?',
    );
    
    if (!confirmed) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final deletedCount = await EmployerMigrationHelper.cleanupDemoData();
      
      if (!mounted) return;
      
      Get.snackbar(
        '🧹 Cleanup Complete',
        'Deleted $deletedCount demo jobs',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );

      await _loadStatusReport();

    } catch (e) {
      if (!mounted) return;
      
      Get.snackbar(
        '❌ Cleanup Failed',
        'Error: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 8),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Employer Administration',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF000647),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Report
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Status',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_statusReport != null) ...[
                      _buildStatusRow('Total Employers', _statusReport!['employers']['total']?.toString() ?? '0'),
                      _buildStatusRow('Active Employers', '${_statusReport!['employers']['active'] ?? 0} (${_statusReport!['employers']['activePercentage'] ?? 0}%)'),
                      _buildStatusRow('Verified Employers', _statusReport!['employers']['verified']?.toString() ?? '0'),
                      const Divider(),
                      _buildStatusRow('Total Jobs', _statusReport!['jobs']['total']?.toString() ?? '0'),
                      _buildStatusRow('Verified Jobs', '${_statusReport!['jobs']['verified'] ?? 0} (${_statusReport!['jobs']['verifiedPercentage'] ?? 0}%)'),
                      _buildStatusRow('Unverified Jobs', _statusReport!['jobs']['unverified']?.toString() ?? '0'),
                    ] else
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Actions
            Text(
              'Actions',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            // Migration Button
            Tooltip(
              message: 'Migrate and validate all existing employers in the database',
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _runMigration,
                  icon: _isLoading 
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.business),
                  label: Text(
                    'Run Employer Migration',
                    style: GoogleFonts.inter(),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF000647),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Cleanup Button
            Tooltip(
              message: 'Permanently delete all demo and test data from the database',
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _cleanupDemoData,
                  icon: const Icon(Icons.cleaning_services),
                  label: Text(
                    'Cleanup Demo Data',
                    style: GoogleFonts.inter(),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Refresh Button
            Tooltip(
              message: 'Reload the current status report from the database',
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isLoading ? null : _loadStatusReport,
                  icon: const Icon(Icons.refresh),
                  label: Text(
                    'Refresh Status',
                    style: GoogleFonts.inter(),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF000647),
                    side: const BorderSide(color: Color(0xFF000647)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),

            const Spacer(),

            // Warning
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: Colors.amber),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'These actions affect the production database. Use with caution!',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.amber.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 14),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _showConfirmationDialog(String title, String message) async {
    return await Get.dialog<bool>(
      AlertDialog(
        title: Text(
          title,
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        content: Text(
          message,
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF000647),
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Confirm',
              style: GoogleFonts.inter(),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    ) ?? false;
  }
}