import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tutor_finder_app/core/presentation/widgets/main_drawer.dart';
import 'package:tutor_finder_app/core/presentation/widgets/responsive_dashboard_layout.dart';
import 'package:tutor_finder_app/core/theme/theme_provider.dart';
import 'package:tutor_finder_app/features/admin/domain/usecases/get_all_bookings_usecase.dart';
import 'package:tutor_finder_app/features/admin/domain/usecases/get_all_reports_usecase.dart';
import 'package:tutor_finder_app/features/admin/domain/usecases/get_all_reviews_usecase.dart';
import 'package:tutor_finder_app/features/admin/domain/usecases/get_all_students_usecase.dart';
import 'package:tutor_finder_app/features/admin/domain/usecases/get_all_tutors_usecase.dart';
import 'package:tutor_finder_app/features/admin/domain/usecases/verify_tutor_usecase.dart';
import 'package:tutor_finder_app/features/auth/data/models/user_model.dart';
import 'package:tutor_finder_app/features/booking/data/models/booking_model.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    _AdminOverviewTab(key: ValueKey('overview')),
    _AdminTutorsTab(key: ValueKey('tutors')),
    _AdminStudentsTab(key: ValueKey('students')),
    _AdminBookingsTab(key: ValueKey('bookings')),
    _AdminReviewsTab(key: ValueKey('reviews')),
    _AdminReportsTab(key: ValueKey('reports')),
    _AdminSchedulesTab(key: ValueKey('schedules')),
    _AdminSettingsTab(key: ValueKey('settings')),
  ];

  final List<String> _titles = [
    'Admin Overview',
    'Manage Tutors',
    'Manage Students',
    'All Bookings',
    'Reviews',
    'Reports',
    'Schedules',
    'Settings',
  ];

  void _onItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (MediaQuery.of(context).size.width < 600) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveDashboardLayout(
      title: _titles[_selectedIndex],
      drawerChild: MainDrawer(
        onItemSelected: _onItemSelected,
        menuItems: [
          DrawerItem(icon: Icons.dashboard, title: 'Overview', onTap: () => _onItemSelected(0)),
          DrawerItem(icon: Icons.school, title: 'Tutors', onTap: () => _onItemSelected(1)),
          DrawerItem(icon: Icons.people, title: 'Students', onTap: () => _onItemSelected(2)),
          DrawerItem(icon: Icons.book_online, title: 'Bookings', onTap: () => _onItemSelected(3)),
          DrawerItem(icon: Icons.star, title: 'Reviews', onTap: () => _onItemSelected(4)),
          DrawerItem(icon: Icons.report, title: 'Reports', onTap: () => _onItemSelected(5)),
          DrawerItem(icon: Icons.calendar_month, title: 'Schedules', onTap: () => _onItemSelected(6)),
          DrawerItem(icon: Icons.settings, title: 'Settings', onTap: () => _onItemSelected(7)),
        ],
      ),
      child: _pages[_selectedIndex],
    );
  }
}

class _AdminOverviewTab extends StatelessWidget {
  const _AdminOverviewTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: const [
         _TutorStatCard(),
         SizedBox(height: 16),
         _StudentStatCard(),
         SizedBox(height: 16),
         _ReviewStatCard(),
         SizedBox(height: 16),
         _ReportStatCard(),
         SizedBox(height: 16),
         _RevenueStatCard(),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String count;
  final IconData icon;
  final Color? color;

  const _StatCard({required this.title, required this.count, required this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: ListTile(
        contentPadding: const EdgeInsets.all(24),
        leading: Icon(icon, size: 48, color: color ?? Theme.of(context).primaryColor),
        title: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        subtitle: Text(count, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class _TutorStatCard extends StatelessWidget {
  const _TutorStatCard();
  @override
  Widget build(BuildContext context) {
    final useCase = Provider.of<GetAllTutorsUseCase>(context, listen: false);
    return StreamBuilder(
      stream: useCase(),
      builder: (context, snapshot) => _StatCard(
        title: 'Total Tutors',
        count: snapshot.data?.length.toString() ?? '...',
        icon: Icons.school,
        color: Colors.blue,
      ),
    );
  }
}

class _StudentStatCard extends StatelessWidget {
  const _StudentStatCard();
  @override
  Widget build(BuildContext context) {
    final useCase = Provider.of<GetAllStudentsUseCase>(context, listen: false);
    return StreamBuilder(
      stream: useCase(),
      builder: (context, snapshot) => _StatCard(
        title: 'Total Students',
        count: snapshot.data?.length.toString() ?? '...',
        icon: Icons.people,
        color: Colors.orange,
      ),
    );
  }
}

class _ReviewStatCard extends StatelessWidget {
  const _ReviewStatCard();
  @override
  Widget build(BuildContext context) {
    final useCase = Provider.of<GetAllReviewsUseCase>(context, listen: false);
    return StreamBuilder(
      stream: useCase(),
      builder: (context, snapshot) => _StatCard(
        title: 'Total Reviews',
        count: snapshot.data?.length.toString() ?? '...',
        icon: Icons.star,
        color: Colors.amber,
      ),
    );
  }
}

class _ReportStatCard extends StatelessWidget {
  const _ReportStatCard();
  @override
  Widget build(BuildContext context) {
    final useCase = Provider.of<GetAllReportsUseCase>(context, listen: false);
    return StreamBuilder(
      stream: useCase(),
      builder: (context, snapshot) => _StatCard(
        title: 'Total Reports',
        count: snapshot.data?.length.toString() ?? '...',
        icon: Icons.report_problem,
        color: Colors.red,
      ),
    );
  }
}

class _RevenueStatCard extends StatelessWidget {
  const _RevenueStatCard();
  @override
  Widget build(BuildContext context) {
    final useCase = Provider.of<GetAllBookingsUseCase>(context, listen: false);
    return StreamBuilder<List<BookingModel>>(
      stream: useCase(),
      builder: (context, snapshot) {
        final revenue = snapshot.data
            ?.where((b) => b.paymentStatus == 'paid')
            .fold(0.0, (sum, b) => sum + b.totalPrice) ?? 0.0;
        return _StatCard(
          title: 'Total Revenue',
          count: '\$${revenue.toStringAsFixed(2)}',
          icon: Icons.attach_money,
          color: Colors.green,
        );
      },
    );
  }
}

class _AdminTutorsTab extends StatelessWidget {
  const _AdminTutorsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final getAllTutors = Provider.of<GetAllTutorsUseCase>(context, listen: false);
    final verifyTutor = Provider.of<VerifyTutorUseCase>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Implement Create Logic
        },
        label: const Text('Add Tutor'),
        icon: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<UserModel>>(
        stream: getAllTutors(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final tutors = snapshot.data!;
          
          if (tutors.isEmpty) return const Center(child: Text("No tutors found."));

          return LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: DataTable(
                columns: const [
                  DataColumn(label: Text('User')),
                  DataColumn(label: Text('Role')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: tutors.map((tutor) {
                  final isVerified = tutor.isMobilePhoneVerified && tutor.isEmailVerified;
                  return DataRow(cells: [
                    DataCell(Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: tutor.profileImageUrl != null ? NetworkImage(tutor.profileImageUrl!) : null,
                          child: tutor.profileImageUrl == null ? Text(tutor.username[0].toUpperCase()) : null,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('${tutor.firstName} ${tutor.lastName}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text(tutor.email, style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ],
                    )),
                    DataCell(Text(tutor.role.toStringValue.toUpperCase())),
                    DataCell(
                      isVerified
                          ? const Chip(
                              label: Text('Verified', style: TextStyle(color: Colors.white, fontSize: 10)),
                              backgroundColor: Colors.green,
                              visualDensity: VisualDensity.compact,
                            )
                          : ElevatedButton(
                              onPressed: () => verifyTutor(tutor.uid),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                minimumSize: const Size(60, 30),
                              ),
                              child: const Text('Verify', style: TextStyle(fontSize: 10)),
                            ),
                    ),
                    DataCell(Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.visibility, color: Colors.blue),
                          tooltip: 'View Details',
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.orange),
                          tooltip: 'Edit User',
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          tooltip: 'Delete User',
                          onPressed: () {},
                        ),
                      ],
                    )),
                  ]);
                }).toList(),
              ),
            ),
          ),
            );
          },
        );
      },
    ),
  );
  }
}

class _AdminStudentsTab extends StatelessWidget {
  const _AdminStudentsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final useCase = Provider.of<GetAllStudentsUseCase>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Implement Create Logic
        },
        label: const Text('Add Student'),
        icon: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<UserModel>>(
        stream: useCase(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final students = snapshot.data!;

          if (students.isEmpty) return const Center(child: Text("No students found."));

          return LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: DataTable(
                columns: const [
                  DataColumn(label: Text('User')),
                  DataColumn(label: Text('Email')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: students.map((student) {
                  return DataRow(cells: [
                    DataCell(Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: student.profileImageUrl != null ? NetworkImage(student.profileImageUrl!) : null,
                          child: student.profileImageUrl == null ? Text(student.username[0].toUpperCase()) : null,
                        ),
                        const SizedBox(width: 12),
                        Text('${student.firstName} ${student.lastName}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    )),
                    DataCell(Text(student.email)),
                    DataCell(Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.visibility, color: Colors.blue),
                          tooltip: 'View Details',
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.orange),
                          tooltip: 'Edit User',
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          tooltip: 'Delete User',
                          onPressed: () {},
                        ),
                      ],
                    )),
                  ]);
                }).toList(),
              ),
            ),
          ),
            );
          },
        );
      },
    ),
  );
  }
}

class _AdminBookingsTab extends StatelessWidget {
  const _AdminBookingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final useCase = Provider.of<GetAllBookingsUseCase>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: StreamBuilder<List<BookingModel>>(
        stream: useCase(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final bookings = snapshot.data!;

          if (bookings.isEmpty) return const Center(child: Text("No bookings yet."));

          return LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Subject')),
                        DataColumn(label: Text('Price')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Payment')),
                        DataColumn(label: Text('Date')),
                      ],
                      rows: bookings.map((booking) {
                        return DataRow(cells: [
                          DataCell(Text(booking.subject)),
                          DataCell(Text('\$${booking.totalPrice}')),
                          DataCell(Text(booking.status)),
                          DataCell(Text(booking.paymentStatus)),
                          DataCell(Text(booking.startTime.toString().split(' ')[0])),
                        ]);
                      }).toList(),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _AdminSchedulesTab extends StatelessWidget {
  const _AdminSchedulesTab({super.key});

  @override
  Widget build(BuildContext context) {
     final useCase = Provider.of<GetAllBookingsUseCase>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: StreamBuilder<List<BookingModel>>(
        stream: useCase(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          // Sort bookings by date
          final bookings = List<BookingModel>.from(snapshot.data!)
            ..sort((a, b) => a.startTime.compareTo(b.startTime));

          if (bookings.isEmpty) return const Center(child: Text("No scheduled classes."));

          return LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Date')),
                        DataColumn(label: Text('Time')),
                        DataColumn(label: Text('Subject')),
                        DataColumn(label: Text('Status')),
                      ],
                      rows: bookings.map((booking) {
                         final date = booking.startTime.toString().split(' ')[0];
                         final time = booking.startTime.toString().split(' ')[1].substring(0, 5);
                        return DataRow(cells: [
                          DataCell(Text(date)),
                          DataCell(Text(time)),
                          DataCell(Text(booking.subject)),
                          DataCell(Text(booking.status)),
                        ]);
                      }).toList(),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _AdminReviewsTab extends StatelessWidget {
  const _AdminReviewsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final useCase = Provider.of<GetAllReviewsUseCase>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: StreamBuilder(
        stream: useCase(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final reviews = snapshot.data!;

          if (reviews.isEmpty) return const Center(child: Text("No reviews found."));

          return LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Reviewer')),
                        DataColumn(label: Text('Rating')),
                        DataColumn(label: Text('Comment')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: reviews.map((review) {
                        return DataRow(cells: [
                          DataCell(Text(review.studentName)),
                          DataCell(Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 16),
                              Text('${review.rating}'),
                            ],
                          )),
                          DataCell(SizedBox(
                            width: 200,
                            child: Text(
                              review.comment,
                              overflow: TextOverflow.ellipsis,
                            ),
                          )),
                          DataCell(Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.visibility, color: Colors.blue),
                                onPressed: () {},
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {},
                              ),
                            ],
                          )),
                        ]);
                      }).toList(),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _AdminReportsTab extends StatelessWidget {
  const _AdminReportsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final useCase = Provider.of<GetAllReportsUseCase>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: StreamBuilder(
        stream: useCase(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final reports = snapshot.data!;

          if (reports.isEmpty) return const Center(child: Text("No reports found."));

          return LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Reporter ID')),
                        DataColumn(label: Text('Reason')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: reports.map((report) {
                        return DataRow(cells: [
                          DataCell(Text(report.reporterId)),
                          DataCell(Text(report.reason)),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: report.status == 'resolved' ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                report.status.toUpperCase(),
                                style: TextStyle(
                                  color: report.status == 'resolved' ? Colors.green : Colors.red,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          DataCell(Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.check_circle, color: Colors.green),
                                tooltip: 'Resolve',
                                onPressed: () {},
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                tooltip: 'Delete',
                                onPressed: () {},
                              ),
                            ],
                          )),
                        ]);
                      }).toList(),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _AdminSettingsTab extends StatelessWidget {
  const _AdminSettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        SwitchListTile(
          title: const Text('Dark Mode'),
          value: Provider.of<ThemeProvider>(context).isDarkMode,
          onChanged: (val) {
             Provider.of<ThemeProvider>(context, listen: false).toggleTheme(val);
          }, 
        ),
        const ListTile(
          leading: Icon(Icons.notifications),
          title: Text('Notification Settings'),
        ),
        const ListTile(
          leading: Icon(Icons.security),
          title: Text('Security'),
        ),
        const Divider(),
        const ListTile(
          leading: Icon(Icons.info),
          title: Text('App Version'),
          trailing: Text('1.0.0'),
        ),
      ],
    );
  }
}
