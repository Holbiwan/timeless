import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeless/services/preferences_service.dart';
import 'package:timeless/utils/pref_keys.dart';
import 'package:timeless/services/accessibility_service.dart';
import 'package:timeless/common/widgets/neumorphic_button.dart';

class EmployerAnalyticsScreen extends StatelessWidget {
  const EmployerAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final accessibilityService = AccessibilityService.instance;
    final String currentUserId = PreferencesService.getString(PrefKeys.userId);
    final String employerId = PreferencesService.getString(PrefKeys.employerId);
    final String actualEmployerId = employerId.isNotEmpty ? employerId : currentUserId;
    
    return Obx(() => Scaffold(
      backgroundColor: accessibilityService.backgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF000647),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF000647),
                      const Color(0xFF000647).withOpacity(0.8),
                      const Color(0xFFE67E22).withOpacity(0.1),
                    ],
                    stops: const [0.0, 0.7, 1.0],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      bottom: 30,
                      left: 20,
                      right: 80,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Company Analytics',
                            style: GoogleFonts.inter(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Real-time recruitment performance',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Get.back(),
              ),
            ),
          ),
          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRealTimeOverviewCards(actualEmployerId),
                  const SizedBox(height: 32),
                  
                  _buildRealTimeJobPerformanceChart(actualEmployerId),
                  const SizedBox(height: 24),
                  
                  _buildRealTimeApplicationStatusChart(actualEmployerId),
                  const SizedBox(height: 24),
                  
                  _buildRealTimeMonthlyTrendsChart(actualEmployerId),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildRealTimeOverviewCards(String employerId) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('allPost')
                    .where('EmployerId', isEqualTo: employerId)
                    .where('isActive', isEqualTo: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  int count = 0;
                  if (snapshot.hasData) {
                    count = snapshot.data!.docs.length;
                  }
                  return _buildOverviewCard("Active Jobs", count.toString(), Icons.work_outline, const Color(0xFF000647));
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('applications')
                    .where('employerId', isEqualTo: employerId)
                    .snapshots(),
                builder: (context, snapshot) {
                  int count = 0;
                  if (snapshot.hasData) {
                    count = snapshot.data!.docs.length;
                  }
                  return _buildOverviewCard("Applications", count.toString(), Icons.people, const Color(0xFFE67E22));
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('applications')
                    .where('employerId', isEqualTo: employerId)
                    .where('status', isEqualTo: 'interview')
                    .snapshots(),
                builder: (context, snapshot) {
                  int count = 0;
                  if (snapshot.hasData) {
                    count = snapshot.data!.docs.length;
                  }
                  return _buildOverviewCard("Interviews", count.toString(), Icons.event, const Color(0xFF28A745));
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('applications')
                    .where('employerId', isEqualTo: employerId)
                    .where('status', isEqualTo: 'accepted')
                    .snapshots(),
                builder: (context, snapshot) {
                  int count = 0;
                  if (snapshot.hasData) {
                    count = snapshot.data!.docs.length;
                  }
                  return _buildOverviewCard("Hired", count.toString(), Icons.verified, const Color(0xFF17A2B8));
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOverviewCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.9),
            blurRadius: 10,
            offset: const Offset(-4, -4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF000647),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRealTimeJobPerformanceChart(String employerId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('allPost')
          .where('EmployerId', isEqualTo: employerId)
          .limit(5)
          .snapshots(),
      builder: (context, jobSnapshot) {
        if (!jobSnapshot.hasData || jobSnapshot.data!.docs.isEmpty) {
          return _buildChartCard(
            "Job Performance",
            "No job postings available",
            const Center(child: Text("No data available")),
          );
        }

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('applications')
              .where('employerId', isEqualTo: employerId)
              .snapshots(),
          builder: (context, appSnapshot) {
            Map<String, int> jobApplicationCounts = {};
            
            if (appSnapshot.hasData) {
              for (var app in appSnapshot.data!.docs) {
                String jobId = app['jobId'] ?? '';
                jobApplicationCounts[jobId] = (jobApplicationCounts[jobId] ?? 0) + 1;
              }
            }

            List<BarChartGroupData> barGroups = [];
            List<String> jobTitles = [];
            
            for (int i = 0; i < jobSnapshot.data!.docs.length; i++) {
              var job = jobSnapshot.data!.docs[i];
              String jobId = job.id;
              String jobTitle = (job.data() as Map<String, dynamic>)['Position'] ?? 'Job ${i + 1}';
              int applicationCount = jobApplicationCounts[jobId] ?? 0;
              
              jobTitles.add(jobTitle.length > 10 ? '${jobTitle.substring(0, 10)}...' : jobTitle);
              
              barGroups.add(
                BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: applicationCount.toDouble(),
                      color: const Color(0xFF000647),
                      width: 20,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ],
                ),
              );
            }

            return _buildChartCard(
              "Job Performance",
              "Applications received per job posting",
              _buildBarChart(barGroups, jobTitles),
            );
          },
        );
      },
    );
  }

  Widget _buildRealTimeApplicationStatusChart(String employerId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('applications')
          .where('employerId', isEqualTo: employerId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildChartCard(
            "Application Status",
            "No applications available",
            const Center(child: Text("No data available")),
          );
        }

        Map<String, int> statusCounts = {
          'pending': 0,
          'interview': 0,
          'accepted': 0,
          'rejected': 0,
        };

        for (var doc in snapshot.data!.docs) {
          String status = doc['status'] ?? 'pending';
          statusCounts[status] = (statusCounts[status] ?? 0) + 1;
        }

        List<PieChartSectionData> sections = [];
        List<Color> colors = [
          const Color(0xFFE67E22), // pending - orange
          const Color(0xFF28A745), // interview - green
          const Color(0xFF17A2B8), // accepted - blue
          const Color(0xFFDC3545), // rejected - red
        ];

        int colorIndex = 0;
        statusCounts.forEach((status, count) {
          if (count > 0) {
            sections.add(
              PieChartSectionData(
                color: colors[colorIndex % colors.length],
                value: count.toDouble(),
                title: '${status.toUpperCase()}\n$count',
                radius: 60,
                titleStyle: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            );
          }
          colorIndex++;
        });

        return _buildChartCard(
          "Application Status Distribution",
          "Status breakdown of all applications",
          _buildPieChart(sections),
        );
      },
    );
  }

  Widget _buildRealTimeMonthlyTrendsChart(String employerId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('applications')
          .where('employerId', isEqualTo: employerId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildChartCard(
            "Monthly Trends",
            "No application data available",
            const Center(child: Text("No data available")),
          );
        }

        Map<int, int> monthlyApplications = {};
        Map<int, int> monthlyHires = {};

        DateTime now = DateTime.now();
        for (int i = 5; i >= 0; i--) {
          DateTime monthDate = DateTime(now.year, now.month - i, 1);
          monthlyApplications[5 - i] = 0;
          monthlyHires[5 - i] = 0;
        }

        for (var doc in snapshot.data!.docs) {
          var data = doc.data() as Map<String, dynamic>;
          if (data['createdAt'] != null) {
            DateTime createdAt = (data['createdAt'] as Timestamp).toDate();
            int monthsAgo = (now.year - createdAt.year) * 12 + (now.month - createdAt.month);
            
            if (monthsAgo >= 0 && monthsAgo < 6) {
              int index = 5 - monthsAgo;
              monthlyApplications[index] = (monthlyApplications[index] ?? 0) + 1;
              
              if (data['status'] == 'accepted') {
                monthlyHires[index] = (monthlyHires[index] ?? 0) + 1;
              }
            }
          }
        }

        List<FlSpot> applicationSpots = [];
        List<FlSpot> hireSpots = [];

        for (int i = 0; i < 6; i++) {
          applicationSpots.add(FlSpot(i.toDouble(), (monthlyApplications[i] ?? 0).toDouble()));
          hireSpots.add(FlSpot(i.toDouble(), (monthlyHires[i] ?? 0).toDouble()));
        }

        return _buildChartCard(
          "6-Month Trends",
          "Applications and hires over last 6 months",
          _buildLineChart(applicationSpots, hireSpots),
        );
      },
    );
  }

  Widget _buildChartCard(String title, String subtitle, Widget chart) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.9),
            blurRadius: 20,
            offset: const Offset(-8, -8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF000647),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: chart,
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(List<BarChartGroupData> barGroups, List<String> jobTitles) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: barGroups.isNotEmpty ? 
            barGroups.map((g) => g.barRods.first.toY).reduce((a, b) => a > b ? a : b) + 5 : 
            10,
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (value, meta) {
                int index = value.toInt();
                if (index >= 0 && index < jobTitles.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      jobTitles[index],
                      style: GoogleFonts.inter(
                        fontSize: 8,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    color: Colors.grey[600],
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        barGroups: barGroups,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 5,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.withOpacity(0.3),
              strokeWidth: 1,
            );
          },
        ),
      ),
    );
  }

  Widget _buildPieChart(List<PieChartSectionData> sections) {
    return PieChart(
      PieChartData(
        pieTouchData: PieTouchData(enabled: true),
        borderData: FlBorderData(show: false),
        sectionsSpace: 2,
        centerSpaceRadius: 50,
        sections: sections,
      ),
    );
  }

  Widget _buildLineChart(List<FlSpot> applicationSpots, List<FlSpot> hireSpots) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 5,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.withOpacity(0.3),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                DateTime now = DateTime.now();
                DateTime monthDate = DateTime(now.year, now.month - (5 - value.toInt()), 1);
                List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                return Text(
                  months[monthDate.month - 1],
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    color: Colors.grey[600],
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    color: Colors.grey[600],
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: applicationSpots,
            isCurved: true,
            color: const Color(0xFF000647),
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 3,
                  color: const Color(0xFF000647),
                  strokeWidth: 1,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: const Color(0xFF000647).withOpacity(0.1),
            ),
          ),
          LineChartBarData(
            spots: hireSpots,
            isCurved: true,
            color: const Color(0xFFE67E22),
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 3,
                  color: const Color(0xFFE67E22),
                  strokeWidth: 1,
                  strokeColor: Colors.white,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}