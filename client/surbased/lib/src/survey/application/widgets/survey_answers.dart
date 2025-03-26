import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surbased/src/auth/application/provider/auth_provider.dart';
import 'package:surbased/src/survey/application/provider/survey_answers_provider.dart';
import 'package:surbased/src/survey/application/provider/survey_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

class SurveyAnswers extends StatefulWidget {
  const SurveyAnswers({super.key});

  @override
  State<SurveyAnswers> createState() => _SurveyAnswersState();
}

class _SurveyAnswersState extends State<SurveyAnswers> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAnswers();
    });
  }

  void _loadAnswers() {
    final surveyProvider = Provider.of<SurveyProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final answersProvider = Provider.of<SurveyAnswersProvider>(context, listen: false);

    if (surveyProvider.currentSurvey != null && authProvider.token != null && surveyProvider.currentSurvey!.id != null) {
      answersProvider.loadSurveyAnswers(
        surveyProvider.currentSurvey!.id!,
        authProvider.token!,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final answersProvider = Provider.of<SurveyAnswersProvider>(context);
    final surveyProvider = Provider.of<SurveyProvider>(context);



    if (answersProvider.isLoading || surveyProvider.isLoading || surveyProvider.currentSurvey == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (answersProvider.error != null) {
      return Center(
        child: Text(
          answersProvider.error!,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.error,
          ),
        ),
      );
    }

    if (answersProvider.answers.isEmpty) {
      return Center(
        child: Text(
          'No hay respuestas para mostrar',
          style: theme.textTheme.titleMedium,
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Resumen general
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Resumen General',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCard(
                        'Total Respuestas',
                        answersProvider.statistics['total_answers'].toString(),
                        Icons.people,
                        theme.colorScheme.primary,
                      ),
                      _buildStatCard(
                        'Preguntas',
                        surveyProvider.currentSurvey?.questions.length.toString() ?? '0',
                        Icons.question_answer,
                        theme.colorScheme.secondary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Estadísticas por pregunta
          Text(
            'Estadísticas por Pregunta',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...answersProvider.statistics['questions'].entries.map((entry) {
            final questionId = entry.key;
            final questionData = entry.value;
            return _buildQuestionStats(questionData, theme);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionStats(Map<String, dynamic> questionData, ThemeData theme) {
    final questionType = questionData['type'];
    final description = questionData['description'];
    final options = Map<String, dynamic>.from(questionData['options']);
    final totalResponses = questionData['total_responses'];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              description,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Total respuestas: $totalResponses',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            if (questionType == 'likert_scale')
              _buildLikertScaleChart(options, theme)
            else if (questionType == 'single_choice' || questionType == 'multiple_choice')
              _buildChoiceChart(options, theme)
            else
              _buildOpenAnswers(options, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildLikertScaleChart(Map<String, dynamic> options, ThemeData theme) {
    final sortedOptions = options.entries.toList()
      ..sort((a, b) {
        final pointsA = a.value['points'] ?? 0;
        final pointsB = b.value['points'] ?? 0;
        return pointsA.compareTo(pointsB);
      });

    // Calcular estadísticas
    final stats = _calculateLikertStats(sortedOptions);

    return Column(
      children: [
        // Tarjeta de estadísticas principales
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estadísticas Descriptivas',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatBox('Media', stats['mean']?.toStringAsFixed(2) ?? '0.00', theme),
                    _buildStatBox('Mediana', stats['median']?.toStringAsFixed(2) ?? '0.00', theme),
                    _buildStatBox('Moda', stats['mode']?.toStringAsFixed(2) ?? '0.00', theme),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatBox('Desv. Est.', stats['stdDev']?.toStringAsFixed(2) ?? '0.00', theme),
                    _buildStatBox('Mínimo', stats['min']?.toInt().toString() ?? '0', theme),
                    _buildStatBox('Máximo', stats['max']?.toInt().toString() ?? '0', theme),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Gráfico de barras de frecuencia
        Container(
          height: 250,
          padding: const EdgeInsets.all(16),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 100,
              minY: 0,
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  tooltipBgColor: theme.colorScheme.surface,
                  tooltipRoundedRadius: 8,
                  tooltipMargin: 8,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final option = sortedOptions[group.x.toInt()].value;
                    return BarTooltipItem(
                      '${option['description']}\n${rod.toY.toStringAsFixed(1)}%\nPuntos: ${option['points']}',
                      theme.textTheme.bodyMedium!.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      if (value < 0 || value >= sortedOptions.length) return const Text('');
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          sortedOptions[value.toInt()].value['points'].toString(),
                          style: theme.textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    interval: 20,
                    getTitlesWidget: (value, meta) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Text(
                          '${value.toInt()}%',
                          style: theme.textTheme.bodySmall,
                        ),
                      );
                    },
                  ),
                ),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: FlGridData(
                show: true,
                horizontalInterval: 20,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: theme.colorScheme.outline.withOpacity(0.2),
                    strokeWidth: 1,
                  );
                },
              ),
              borderData: FlBorderData(show: false),
              barGroups: sortedOptions.asMap().entries.map((entry) {
                final optionData = Map<String, dynamic>.from(sortedOptions[entry.key].value);
                return BarChartGroupData(
                  x: entry.key,
                  barRods: [
                    BarChartRodData(
                      toY: double.parse(optionData['percentage']),
                      color: _getColorForValue(
                        optionData['points'] as int,
                        stats['min']?.toInt() ?? 0,
                        stats['max']?.toInt() ?? 0,
                        theme,
                      ),
                      width: 25,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      backDrawRodData: BackgroundBarChartRodData(
                        show: true,
                        toY: 100,
                        color: theme.colorScheme.surfaceVariant,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),

        // Leyenda de opciones
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Detalle de Opciones',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...sortedOptions.map((option) {
                final data = option.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _getColorForValue(
                            data['points'] as int,
                            stats['min']?.toInt() ?? 0,
                            stats['max']?.toInt() ?? 0,
                            theme,
                          ),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          data['description'],
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                      Text(
                        'Puntos: ${data['points']} - ${data['percentage']}%',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatBox(String label, String value, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorForValue(int value, int min, int max, ThemeData theme) {
    if (max == min) return theme.colorScheme.primary;
    
    final normalized = (value - min) / (max - min);
    
    if (normalized < 0.33) {
      return theme.colorScheme.error;
    } else if (normalized < 0.66) {
      return theme.colorScheme.primary;
    } else {
      return theme.colorScheme.tertiary;
    }
  }

  Map<String, double> _calculateLikertStats(List<MapEntry<String, dynamic>> sortedOptions) {
    final List<double> weightedValues = [];
    final List<int> frequencies = [];
    int totalResponses = 0;
    double sum = 0;
    int min = 999999;
    int max = -999999;

    // Recopilar datos
    for (var option in sortedOptions) {
      final points = option.value['points'] as int;
      final count = option.value['count'] as int;
      final percentage = double.parse(option.value['percentage']);
      
      weightedValues.add(points * percentage);
      frequencies.add(count);
      totalResponses += count;
      sum += points * count;
      
      if (points < min) min = points;
      if (points > max) max = points;
    }

    // Calcular media
    final mean = sum / totalResponses;

    // Calcular mediana
    final sortedValues = <int>[];
    for (var i = 0; i < sortedOptions.length; i++) {
      for (var j = 0; j < frequencies[i]; j++) {
        sortedValues.add(sortedOptions[i].value['points'] as int);
      }
    }
    sortedValues.sort();
    final median = sortedValues.length.isOdd
        ? sortedValues[sortedValues.length ~/ 2].toDouble()
        : (sortedValues[(sortedValues.length - 1) ~/ 2] +
                sortedValues[sortedValues.length ~/ 2]) /
            2.0;

    // Calcular moda
    int maxFreq = 0;
    double mode = 0;
    for (var i = 0; i < sortedOptions.length; i++) {
      if (frequencies[i] > maxFreq) {
        maxFreq = frequencies[i];
        mode = sortedOptions[i].value['points'].toDouble();
      }
    }

    // Calcular desviación estándar
    double sumSquaredDiff = 0;
    for (var i = 0; i < sortedOptions.length; i++) {
      final points = sortedOptions[i].value['points'] as int;
      final count = frequencies[i];
      sumSquaredDiff += count * (points - mean) * (points - mean);
    }
    final variance = sumSquaredDiff / totalResponses;
    final stdDev = sqrt(variance);

    return {
      'mean': mean,
      'median': median,
      'mode': mode,
      'stdDev': stdDev,
      'min': min.toDouble(),
      'max': max.toDouble(),
    };
  }

  Widget _buildChoiceChart(Map<String, dynamic> options, ThemeData theme) {
    final List<PieChartSectionData> sections = [];
    final List<Widget> indicators = [];
    final colors = [
      theme.colorScheme.primary,
      theme.colorScheme.secondary,
      theme.colorScheme.tertiary,
      theme.colorScheme.error,
      theme.colorScheme.primaryContainer,
      theme.colorScheme.secondaryContainer,
    ];

    int colorIndex = 0;
    for (var entry in options.entries) {
      final color = colors[colorIndex % colors.length];
      colorIndex++;

      sections.add(
        PieChartSectionData(
          value: double.parse(entry.value['percentage']),
          title: '${entry.value['percentage']}%',
          radius: 100,
          titleStyle: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.surface,
            fontWeight: FontWeight.bold,
          ),
          color: color,
          showTitle: double.parse(entry.value['percentage']) > 5, // Solo mostrar etiqueta si es > 5%
        ),
      );

      indicators.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  entry.value['description'],
                  style: theme.textTheme.bodySmall,
                ),
              ),
              Text(
                '${entry.value['percentage']}%',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: sections,
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                startDegreeOffset: -90,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Column(
            children: indicators,
          ),
        ],
      ),
    );
  }

  Widget _buildOpenAnswers(Map<String, dynamic> options, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: options.entries.map((entry) {
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.value['text'] ?? entry.value['description'],
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${entry.value['count']} respuestas (${entry.value['percentage']}%)',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}