import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ProgressView extends StatefulWidget {
  final Map<String, dynamic> userData;

  const ProgressView({Key? key, required this.userData}) : super(key: key);

  @override
  State<ProgressView> createState() => _ProgressViewState();
}

class _ProgressViewState extends State<ProgressView> {
  String _selectedMetric = 'Peso';
  String _selectedPeriod = 'Último mes';

  final List<String> _metrics = [
    'Peso',
    'IMC',
    'Grasa Corporal',
    'Masa Muscular'
  ];
  final List<String> _periods = [
    'Última semana',
    'Último mes',
    'Últimos 3 meses',
    'Último año'
  ];

  // Datos de ejemplo para las gráficas
  final List<FlSpot> _weightData = [
    FlSpot(0, 75.2),
    FlSpot(5, 75.0),
    FlSpot(10, 74.5),
    FlSpot(15, 74.1),
    FlSpot(20, 73.8),
    FlSpot(25, 73.3),
    FlSpot(30, 72.8),
  ];

  final List<FlSpot> _bmiData = [
    FlSpot(0, 26.2),
    FlSpot(5, 26.1),
    FlSpot(10, 25.9),
    FlSpot(15, 25.7),
    FlSpot(20, 25.6),
    FlSpot(25, 25.4),
    FlSpot(30, 25.2),
  ];

  final List<FlSpot> _bodyFatData = [
    FlSpot(0, 22.5),
    FlSpot(5, 22.3),
    FlSpot(10, 22.0),
    FlSpot(15, 21.8),
    FlSpot(20, 21.5),
    FlSpot(25, 21.3),
    FlSpot(30, 21.0),
  ];

  final List<FlSpot> _muscleMassData = [
    FlSpot(0, 42.1),
    FlSpot(5, 42.3),
    FlSpot(10, 42.6),
    FlSpot(15, 42.9),
    FlSpot(20, 43.2),
    FlSpot(25, 43.5),
    FlSpot(30, 43.9),
  ];

  List<FlSpot> _getDataForMetric() {
    switch (_selectedMetric) {
      case 'Peso':
        return _weightData;
      case 'IMC':
        return _bmiData;
      case 'Grasa Corporal':
        return _bodyFatData;
      case 'Masa Muscular':
        return _muscleMassData;
      default:
        return _weightData;
    }
  }

  Color _getColorForMetric() {
    switch (_selectedMetric) {
      case 'Peso':
        return Colors.blue;
      case 'IMC':
        return Colors.green;
      case 'Grasa Corporal':
        return Colors.red;
      case 'Masa Muscular':
        return Colors.purple;
      default:
        return Colors.blue;
    }
  }

  String _getUnit() {
    switch (_selectedMetric) {
      case 'Peso':
        return 'kg';
      case 'IMC':
        return 'kg/m²';
      case 'Grasa Corporal':
      case 'Masa Muscular':
        return '%';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = _getDataForMetric();
    final color = _getColorForMetric();
    final unit = _getUnit();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tu Progreso',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Visualiza tu evolución y alcanza tus objetivos',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildFilterChip('Métrica', _selectedMetric, _metrics),
                        const SizedBox(width: 12),
                        _buildFilterChip('Periodo', _selectedPeriod, _periods),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            _selectedMetric,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: color,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              '${data.last.y.toStringAsFixed(1)} $unit',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Evolución - $_selectedPeriod',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: _buildChart(data, color),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildProgressSummary(),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String selected, List<String> options) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selected,
                icon: const Icon(Icons.arrow_drop_down),
                iconSize: 24,
                elevation: 16,
                isExpanded: true,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      if (label == 'Métrica') {
                        _selectedMetric = newValue;
                      } else {
                        _selectedPeriod = newValue;
                      }
                    });
                  }
                },
                items: options.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(List<FlSpot> data, Color color) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey[300],
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                // Simplificado para ejemplo
                if (value % 10 == 0) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
                    ),
                  );
                }
                return const Text('');
              },
              reservedSize: 22,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toStringAsFixed(0),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                );
              },
              reservedSize: 28,
            ),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            bottom: BorderSide(color: Colors.grey[300]!),
            left: BorderSide(color: Colors.grey[300]!),
          ),
        ),
        minX: 0,
        maxX: 30,
        minY: data.map((spot) => spot.y).reduce((a, b) => a < b ? a : b) - 1,
        maxY: data.map((spot) => spot.y).reduce((a, b) => a > b ? a : b) + 1,
        lineBarsData: [
          LineChartBarData(
            spots: data,
            isCurved: true,
            color: color,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: Colors.white,
                  strokeWidth: 2,
                  strokeColor: color,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: color.withOpacity(0.15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSummary() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumen de Progreso',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildProgressCard(
                  'Peso Inicial',
                  '75.2 kg',
                  Icons.scale,
                  Colors.blue,
                ),
                const SizedBox(width: 16),
                _buildProgressCard(
                  'Peso Actual',
                  '72.8 kg',
                  Icons.scale_outlined,
                  Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildProgressCard(
                  'Cambio',
                  '-2.4 kg',
                  Icons.trending_down,
                  Colors.orange,
                ),
                const SizedBox(width: 16),
                _buildProgressCard(
                  'Objetivo',
                  '70.0 kg',
                  Icons.flag,
                  Colors.purple,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
