import 'package:flutter/material.dart';
import 'package:nut_ecom_app/screens/transactionsadd_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
                  const Text('Tháng 7/2025'),
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
          const Text(
            '10.000.000',
            style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Color(0xFF18B4A5)),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildIncomeExpense('Thu', '+5.000.000', Colors.green),
              Container(
                height: 40,
                width: 1,
                color: Colors.grey.shade300,
              ),
              _buildIncomeExpense('Chi', '-5.000.000', Colors.red),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color.fromARGB(255, 228, 228, 228)),
        ],
      ),
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
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 45,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: const Color(0xFF18B4A5),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.black,
        tabs: const [
          Tab(text: 'Tiền vào'),
          Tab(text: 'Tiền ra'),
        ],
      ),
    );
  }

  Widget _buildTransactionList({required bool income}) {
    final transactions = income
        ? [
            {
              'date': '16/07/2025 - 15:00:00',
              'desc':
                  'Description: Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
              'amount': '+500.000'
            },
            {
              'date': '15/07/2025 - 10:20:00',
              'desc': 'Description: Nhận tiền hoàn từ Shopee.',
              'amount': '+200.000'
            },
            {
              'date': '13/07/2025 - 09:10:00',
              'desc': 'Description: Bán hàng online.',
              'amount': '+1.000.000'
            },
          ]
        : [
            {
              'date': '18/07/2025 - 11:00:00',
              'desc': 'Description: Chi phí nhập hàng.',
              'amount': '-2.000.000'
            },
            {
              'date': '14/07/2025 - 14:30:00',
              'desc': 'Description: Trả lương nhân viên.',
              'amount': '-3.000.000'
            },
          ];

    return ListView.separated(
      padding: const EdgeInsets.all(16.0),
      itemCount: transactions.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final transaction = transactions[index];
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
                      transaction['date']!,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      transaction['desc']!,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
              Text(
                transaction['amount']!,
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
  }
}
