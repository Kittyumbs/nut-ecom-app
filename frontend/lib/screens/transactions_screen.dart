import 'package:flutter/material.dart';
import 'package:nut_ecom_app/screens/transactionsadd_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Trigger rebuild khi chuyển tab
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Quản lý GIAO DỊCH'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildHeader(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTransactionList(income: true),
                _buildTransactionList(income: false),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const TransactionsAddScreen()),
          );
        },
        backgroundColor: const Color(0xFF18B4A5),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader() {
    final now = DateTime.now();
    final monthYear = DateFormat('MM/yyyy').format(now);

    final startOfMonth = DateTime(now.year, now.month, 1);
    final startOfNextMonth = DateTime(now.year, now.month + 1, 1);

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('transactions')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        double totalIncome = 0;
        double totalExpense = 0;

        if (snapshot.hasData) {
          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final timestampStr = data['timestamp'] as String?;
            if (timestampStr != null) {
              final timestamp = DateTime.tryParse(timestampStr);
              if (timestamp != null &&
                  timestamp.isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
                  timestamp.isBefore(startOfNextMonth)) {
                final amount = (data['amount'] as num? ?? 0).toDouble();
                if (amount > 0) {
                  totalIncome += amount;
                } else {
                  totalExpense += amount.abs();
                }
              }
            }
          }
        }

        final total = totalIncome - totalExpense;
        final formatter = NumberFormat('#,###');

        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Tháng $monthYear'),
                      const SizedBox(width: 8),
                      Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'THỰC TẾ',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                formatter.format(total),
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: total >= 0 ? const Color(0xFF18B4A5) : Colors.red,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildIncomeExpense(
                    'Thu',
                    '+${formatter.format(totalIncome)}',
                    Colors.green,
                  ),
                  Container(
                    height: 40,
                    width: 1,
                    color: Colors.grey.shade300,
                  ),
                  _buildIncomeExpense(
                    'Chi',
                    '-${formatter.format(totalExpense)}',
                    Colors.red,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, color: Color.fromARGB(255, 228, 228, 228)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIncomeExpense(String label, String amount, Color color) {
    return Column(
      children: [
        Text(
          amount,
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: color),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      height: 45,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: _tabController.index == 0
              ? const Color(0xFF18B4A5) // Màu xanh cho "Tiền vào"
              : Colors.red, // Màu đỏ cho "Tiền ra"
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey[700],
        labelStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        onTap: (index) {
          setState(() {}); // Trigger rebuild để cập nhật màu indicator
        },
        tabs: const [
          Tab(text: 'Tiền vào'),
          Tab(text: 'Tiền ra'),
        ],
      ),
    );
  }

  Widget _buildTransactionList({required bool income}) {
    final now = DateTime.now();
    final formatter = NumberFormat('#,###');

    final startOfMonth = DateTime(now.year, now.month, 1);
    final startOfNextMonth = DateTime(now.year, now.month + 1, 1);

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('transactions')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Lỗi: ${snapshot.error}'),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('Chưa có giao dịch nào'),
          );
        }

        // Lọc transactions theo tháng và income/expense
        final transactions = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final timestampStr = data['timestamp'] as String?;
          if (timestampStr == null) return false;
          final timestamp = DateTime.tryParse(timestampStr);
          if (timestamp == null) return false;
          
          // Kiểm tra trong tháng hiện tại
          if (!timestamp.isAfter(startOfMonth.subtract(const Duration(days: 1))) ||
              !timestamp.isBefore(startOfNextMonth)) {
            return false;
          }
          
          // Kiểm tra income/expense
          final amount = (data['amount'] as num? ?? 0).toDouble();
          return income ? amount > 0 : amount < 0;
        }).toList();

        if (transactions.isEmpty) {
          return Center(
            child: Text(income ? 'Chưa có giao dịch thu' : 'Chưa có giao dịch chi'),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16.0),
          itemCount: transactions.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            final doc = transactions[index];
            final data = doc.data() as Map<String, dynamic>;
            final amount = (data['amount'] as num? ?? 0).toDouble();
            final content = data['content'] as String? ?? '';
            final date = data['date'] as String? ?? '';
            final time = data['time'] as String? ?? '';
            final dateTime = '$date - $time';

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dateTime,
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          content,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${amount >= 0 ? '+' : ''}${formatter.format(amount)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: income ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
