import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeless/utils/employer_migration_helper.dart';
import 'package:timeless/services/employer_service.dart';

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
      setState(() {
        _statusReport = report;
      });
    } catch (e) {
      print('Error loading status report: $e');
    }
  }

  Future<void> _runMigration() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final results = await EmployerMigrationHelper.migrateExistingEmployers();
      
      Get.snackbar(
        '✅ Migration Complete',
        'Processed: ${results['employersProcessed']}\nActivated: ${results['employersActivated']}\nJobs marked: ${results['jobsMarked']}',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );

      // Reload status report
      await _loadStatusReport();

    } catch (e) {
      Get.snackbar(
        '❌ Migration Failed',
        'Error: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _cleanupDemoData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final deletedCount = await EmployerMigrationHelper.cleanupDemoData();
      
      Get.snackbar(
        '🧹 Cleanup Complete',
        'Deleted $deletedCount demo jobs',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );

      await _loadStatusReport();

    } catch (e) {
      Get.snackbar(
        '❌ Cleanup Failed',
        'Error: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Employer Administration',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
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
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_statusReport != null) ...[
                      _buildStatusRow('Total Employers', _statusReport!['employers']['total'].toString()),
                      _buildStatusRow('Active Employers', '${_statusReport!['employers']['active']} (${_statusReport!['employers']['activePercentage']}%)'),
                      _buildStatusRow('Verified Employers', _statusReport!['employers']['verified'].toString()),
                      const Divider(),
                      _buildStatusRow('Total Jobs', _statusReport!['jobs']['total'].toString()),
                      _buildStatusRow('Verified Jobs', '${_statusReport!['jobs']['verified']} (${_statusReport!['jobs']['verifiedPercentage']}%)'),
                      _buildStatusRow('Unverified Jobs', _statusReport!['jobs']['unverified'].toString()),
                    ] else
                      const CircularProgressIndicator(),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Actions
            Text(
              'Actions',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            // Migration Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _runMigration,
                icon: _isLoading 
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.migration),
                label: Text(
                  'Run Employer Migration',
                  style: GoogleFonts.poppins(),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF000647),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Cleanup Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _cleanupDemoData,
                icon: const Icon(Icons.cleaning_services),
                label: Text(
                  'Cleanup Demo Data',
                  style: GoogleFonts.poppins(),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Refresh Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isLoading ? null : _loadStatusReport,
                icon: const Icon(Icons.refresh),
                label: Text(
                  'Refresh Status',
                  style: GoogleFonts.poppins(),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF000647),
                  side: const BorderSide(color: Color(0xFF000647)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
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
                      style: GoogleFonts.poppins(
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
            style: GoogleFonts.poppins(fontSize: 14),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}