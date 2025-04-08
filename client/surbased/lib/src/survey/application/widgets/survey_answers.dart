import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surbased/src/auth/application/provider/auth_provider.dart';
import 'package:surbased/src/survey/application/provider/survey_answers_provider.dart';
import 'package:surbased/src/survey/application/provider/survey_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;

class SurveyAnswers extends StatefulWidget {
  const SurveyAnswers({super.key});

  @override
  State<SurveyAnswers> createState() => _SurveyAnswersState();
}

class _SurveyAnswersState extends State<SurveyAnswers> {
  final Map<String, String> _selectedVisualization = {};

  final Map<String, List<String>> _visualizationTypes = {
    'likert_scale': ['descriptive_stats', 'frequency_chart'],
    'single_choice': ['pie_chart', 'bar_chart', 'spectrum'],
    'multiple_choice': ['pie_chart', 'bar_chart', 'spectrum'],
  };

  String _getVisualizationName(String type, AppLocalizations t) {
    switch (type) {
      case 'descriptive_stats':
        return 'Estadísticas descriptivas';
      case 'frequency_chart':
        return 'Gráfico de frecuencias';
      case 'pie_chart':
        return 'Gráfico circular';
      case 'bar_chart':
        return 'Histograma';
      case 'spectrum':
        return 'Gráfico de espectro';
      default:
        return type;
    }
  }

  String _getDefaultVisualization(String questionType) {
    if (!_visualizationTypes.containsKey(questionType)) {
      return '';
    }
    return questionType == 'likert_scale' ? 'descriptive_stats' : 'pie_chart';
  }

  bool _isValidVisualization(String questionType, String? visualization) {
    return _visualizationTypes[questionType]?.contains(visualization) ?? false;
  }

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

  void _updateVisualization(String questionId, String questionType, String newValue) {
    print("Actualizando visualización - ID: $questionId, Tipo: $questionType, Nuevo valor: $newValue");
    if (_visualizationTypes[questionType]?.contains(newValue) ?? false) {
      setState(() {
        _selectedVisualization[questionId] = newValue;
      });
      print("Visualización actualizada - Nuevo estado: ${_selectedVisualization[questionId]}");
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

          Text(
            'Estadísticas por Pregunta',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...answersProvider.statistics['questions'].entries.map((entry) {
            final questionData = entry.value;
            return QuestionStatsCard(
              key: ValueKey('question_${entry.key}'),
              questionData: questionData,
            );
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
}

class QuestionStatsCard extends StatefulWidget {
  final Map<String, dynamic> questionData;

  const QuestionStatsCard({
    required this.questionData,
    super.key,
  });

  @override
  State<QuestionStatsCard> createState() => _QuestionStatsCardState();
}

class _QuestionStatsCardState extends State<QuestionStatsCard> {
  String? _selectedVisualization;
  
  final Map<String, List<String>> _visualizationTypes = {
    'likert_scale': ['descriptive_stats', 'diverging_chart', 'distribution_chart', 'box_plot'],
    'single_choice': ['pie_chart', 'bar_chart', 'spectrum'],
    'multiple_choice': ['pie_chart', 'bar_chart', 'spectrum'],
  };

  @override
  void initState() {
    super.initState();
    final questionType = widget.questionData['type'] as String;
    _selectedVisualization = _getDefaultVisualization(questionType);
  }

  String _getDefaultVisualization(String questionType) {
    switch (questionType) {
      case 'likert_scale':
        return 'descriptive_stats';
      case 'single_choice':
      case 'multiple_choice':
        return 'pie_chart';
      default:
        return '';
    }
  }

  String _getVisualizationName(String type, AppLocalizations t) {
    switch (type) {
      case 'descriptive_stats':
        return 'Estadísticas descriptivas';
      case 'diverging_chart':
        return 'Gráfico de divergencia';
      case 'distribution_chart':
        return 'Distribución y tendencia';
      case 'box_plot':
        return 'Diagrama de caja';
      case 'pie_chart':
        return 'Gráfico circular';
      case 'bar_chart':
        return 'Histograma';
      case 'spectrum':
        return 'Gráfico de espectro';
      default:
        return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final questionType = widget.questionData['type'] as String;
    final description = widget.questionData['description'] as String;
    final options = Map<String, dynamic>.from(widget.questionData['options']);
    final totalResponses = widget.questionData['total_responses'] as int;

    // Asegurarse de que tenemos un tipo de visualización válido
    final availableTypes = _visualizationTypes[questionType];
    if (_selectedVisualization == null || 
        availableTypes == null || 
        !availableTypes.contains(_selectedVisualization!)) {
      _selectedVisualization = _getDefaultVisualization(questionType);
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
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
                    ],
                  ),
                ),
                if (questionType != 'open' && _visualizationTypes.containsKey(questionType))
                  PopupMenuButton<String>(
                    initialValue: _selectedVisualization,
                    tooltip: 'Cambiar visualización',
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.insert_chart,
                            color: theme.colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_drop_down,
                            color: theme.colorScheme.onSurface,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                    onSelected: (String newValue) {
                      setState(() {
                        _selectedVisualization = newValue;
                      });
                    },
                    itemBuilder: (BuildContext context) => 
                      _visualizationTypes[questionType]?.map((type) {
                        IconData icon;
                        switch (type) {
                          case 'descriptive_stats':
                            icon = Icons.analytics_outlined;
                            break;
                          case 'diverging_chart':
                            icon = Icons.stacked_bar_chart;
                            break;
                          case 'distribution_chart':
                            icon = Icons.show_chart;
                            break;
                          case 'box_plot':
                            icon = Icons.candlestick_chart;
                            break;
                          case 'pie_chart':
                            icon = Icons.pie_chart_outline;
                            break;
                          case 'bar_chart':
                            icon = Icons.bar_chart;
                            break;
                          case 'spectrum':
                            icon = Icons.linear_scale;
                            break;
                          default:
                            icon = Icons.analytics_outlined;
                        }
                        
                        return PopupMenuItem<String>(
                          value: type,
                          child: Row(
                            children: [
                              Icon(
                                icon,
                                color: _selectedVisualization == type 
                                    ? theme.colorScheme.primary 
                                    : theme.colorScheme.onSurface,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                _getVisualizationName(type, AppLocalizations.of(context)!),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: _selectedVisualization == type 
                                      ? theme.colorScheme.primary 
                                      : null,
                                  fontWeight: _selectedVisualization == type 
                                      ? FontWeight.bold 
                                      : null,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList() ?? [],
                  ),
              ],
            ),
            const SizedBox(height: 16),
            _buildVisualizationContent(questionType, options, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildVisualizationContent(
    String questionType,
    Map<String, dynamic> options,
    ThemeData theme,
  ) {
    if (questionType == 'likert_scale') {
      return _buildLikertScaleVisualization(options, theme);
    } else if ((questionType == 'single_choice' || questionType == 'multiple_choice') && 
              _visualizationTypes.containsKey(questionType)) {
      return _buildChoiceVisualization(options, theme);
    } else {
      return _buildOpenAnswers(options, theme);
    }
  }

  Widget _buildLikertScaleVisualization(Map<String, dynamic> options, ThemeData theme) {
    switch (_selectedVisualization) {
      case 'descriptive_stats':
        return _buildDescriptiveStats(_calculateLikertStats(options.entries.toList()), theme);
      case 'diverging_chart':
        return _buildDivergingChart(options, theme);
      case 'distribution_chart':
        return _buildDistributionChart(options, theme);
      case 'box_plot':
        return _buildBoxPlot(options, theme);
      default:
        return const SizedBox();
    }
  }

  Widget _buildChoiceVisualization(Map<String, dynamic> options, ThemeData theme) {
    switch (_selectedVisualization) {
      case 'pie_chart':
        return _buildPieChart(options, theme);
      case 'bar_chart':
        return _buildBarChart(options, theme);
      case 'spectrum':
        return _buildSpectrumChart(options, theme);
      default:
        return const SizedBox();
    }
  }

  Widget _buildDescriptiveStats(Map<String, double> stats, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
    );
  }

  Widget _buildStatBox(String label, String value, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivergingChart(Map<String, dynamic> options, ThemeData theme) {
    final sortedOptions = options.entries.toList()
      ..sort((a, b) {
        final pointsA = a.value['points'] ?? 0;
        final pointsB = b.value['points'] ?? 0;
        return pointsA.compareTo(pointsB);
      });

    // Encontrar el punto medio de la escala
    final middlePoint = (sortedOptions.first.value['points'] + sortedOptions.last.value['points']) / 2;

    return Column(
      children: [
        Container(
          height: 220,
          padding: const EdgeInsets.fromLTRB(40, 16, 8, 24),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.center,
              maxY: 100,
              minY: -100,
              groupsSpace: 8,
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  tooltipBgColor: theme.colorScheme.surface,
                  tooltipPadding: const EdgeInsets.all(8),
                  tooltipMargin: 4,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final option = sortedOptions[group.x.toInt()];
                    final percentage = double.parse(option.value['percentage']);
                    return BarTooltipItem(
                      '${option.value['description']}\n${percentage.abs()}%',
                      TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontSize: 12,
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
                    reservedSize: 36,
                    getTitlesWidget: (value, meta) {
                      if (value < 0 || value >= sortedOptions.length) return const Text('');
                      return Transform.rotate(
                        angle: -0.5,
                        child: Text(
                          sortedOptions[value.toInt()].value['description'],
                          style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
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
                      return Text('${value.abs().toInt()}%');
                    },
                  ),
                ),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 20,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: value == 0 
                        ? theme.colorScheme.outline 
                        : theme.colorScheme.outline.withOpacity(0.2),
                    strokeWidth: value == 0 ? 2 : 1,
                  );
                },
              ),
              borderData: FlBorderData(show: false),
              barGroups: sortedOptions.asMap().entries.map((entry) {
                final option = entry.value;
                final points = option.value['points'] as int;
                final percentage = double.parse(option.value['percentage']);
                final isNegative = points < middlePoint;

                return BarChartGroupData(
                  x: entry.key,
                  barRods: [
                    BarChartRodData(
                      toY: isNegative ? -percentage : percentage,
                      color: isNegative 
                          ? theme.colorScheme.error 
                          : theme.colorScheme.primary,
                      width: 20,
                      borderRadius: const BorderRadius.all(Radius.circular(2)),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            _buildLegendStat(
              'Respuestas Positivas',
              '${_calculatePositivePercentage(sortedOptions, middlePoint)}%',
              theme,
              color: theme.colorScheme.primary,
            ),
            _buildLegendStat(
              'Respuestas Negativas',
              '${_calculateNegativePercentage(sortedOptions, middlePoint)}%',
              theme,
              color: theme.colorScheme.error,
            ),
            _buildLegendStat(
              'Neutrales',
              '${_calculateNeutralPercentage(sortedOptions, middlePoint)}%',
              theme,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPieChart(Map<String, dynamic> options, ThemeData theme) {
    return _buildChoiceChart(options, theme);  // Reutilizamos el existente
  }

  Widget _buildBarChart(Map<String, dynamic> options, ThemeData theme) {
    final sortedOptions = options.entries.toList()
      ..sort((a, b) => (b.value['percentage'] as String)
          .compareTo(a.value['percentage'] as String));

    // Colores para las diferentes opciones
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.pink,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
      Colors.amber,
    ];

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Título del gráfico
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              'Respuestas (%)',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          // Gráfico de barras
          Container(
            height: 240,
            padding: const EdgeInsets.only(left: 24, right: 16),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 100,
                minY: 0,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: theme.colorScheme.surface,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final option = sortedOptions[group.x.toInt()];
                      final percentage = double.parse(option.value['percentage']);
                      final count = option.value['count'] as int;
                      return BarTooltipItem(
                        '${option.value['description']}\n$count respuestas (${percentage.toStringAsFixed(1)}%)',
                        TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
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
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        if (value < 0 || value >= sortedOptions.length) return const Text('');
                        
                        String description = sortedOptions[value.toInt()].value['description'];
                        
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            description,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 20,
                      reservedSize: 24,
                      getTitlesWidget: (value, meta) {
                        if (value % 20 != 0) return const Text('');
                        return Padding(
                          padding: const EdgeInsets.only(right: 2),
                          child: Text(
                            '${value.toInt()}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                            ),
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
                  drawVerticalLine: false,
                  horizontalInterval: 20,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: theme.colorScheme.outline.withOpacity(0.3),
                      strokeWidth: value % 40 == 0 ? 1.0 : 0.5,
                    );
                  },
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    bottom: BorderSide(color: theme.colorScheme.outline.withOpacity(0.5), width: 1),
                    left: BorderSide(color: theme.colorScheme.outline.withOpacity(0.5), width: 1),
                  ),
                ),
                barGroups: sortedOptions.asMap().entries.map((entry) {
                  final index = entry.key;
                  final option = entry.value;
                  final percentage = double.parse(option.value['percentage']);
                  
                  // Calcular ancho de barra en función del número de elementos
                  final barWidth = sortedOptions.length <= 2 ? 36.0 : 
                                   sortedOptions.length <= 3 ? 28.0 : 22.0;
                  
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: percentage,
                        color: colors[index % colors.length],
                        width: barWidth,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          
          // Leyenda
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 4),
            child: Center(
              child: Wrap(
                spacing: 12,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: sortedOptions.asMap().entries.map((entry) {
                  final index = entry.key;
                  final option = entry.value;
                  final percentage = double.parse(option.value['percentage']);
                  final count = option.value['count'] as int;
                
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: colors[index % colors.length].withOpacity(0.1),
                      border: Border.all(color: colors[index % colors.length].withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: colors[index % colors.length],
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${option.value['description']}: $count (${percentage.toStringAsFixed(1)}%)',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpectrumChart(Map<String, dynamic> options, ThemeData theme) {
    final sortedOptions = options.entries.toList()
      ..sort((a, b) => (b.value['percentage'] as String)
          .compareTo(a.value['percentage'] as String));

    return Column(
      children: [
        ...sortedOptions.map((option) {
          final percentage = double.parse(option.value['percentage']);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  option.value['description'],
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: theme.colorScheme.surfaceVariant,
                    color: theme.colorScheme.primary,
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
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

  double _calculatePositivePercentage(List<MapEntry<String, dynamic>> options, double middlePoint) {
    return options
        .where((option) => option.value['points'] > middlePoint)
        .fold(0.0, (sum, option) => sum + double.parse(option.value['percentage']));
  }

  double _calculateNegativePercentage(List<MapEntry<String, dynamic>> options, double middlePoint) {
    return options
        .where((option) => option.value['points'] < middlePoint)
        .fold(0.0, (sum, option) => sum + double.parse(option.value['percentage']));
  }

  double _calculateNeutralPercentage(List<MapEntry<String, dynamic>> options, double middlePoint) {
    return options
        .where((option) => option.value['points'] == middlePoint)
        .fold(0.0, (sum, option) => sum + double.parse(option.value['percentage']));
  }

  Widget _buildDistributionChart(Map<String, dynamic> options, ThemeData theme) {
    final sortedOptions = options.entries.toList()
      ..sort((a, b) {
        final pointsA = a.value['points'] ?? 0;
        final pointsB = b.value['points'] ?? 0;
        return pointsA.compareTo(pointsB);
      });

    // Calcular estadísticas
    final stats = _calculateLikertStats(sortedOptions);
    final mean = stats['mean']!;
    final stdDev = stats['stdDev']!;

    // Preparar datos para el gráfico
    final List<FlSpot> spots = [];
    double maxPercentage = 0;

    for (var i = 0; i < sortedOptions.length; i++) {
      final percentage = double.parse(sortedOptions[i].value['percentage']);
      spots.add(FlSpot(i.toDouble(), percentage));
      if (percentage > maxPercentage) maxPercentage = percentage;
    }

    return Column(
      children: [
        Container(
          height: 220,
          padding: const EdgeInsets.fromLTRB(40, 16, 24, 24),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 20,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: theme.colorScheme.outline.withOpacity(0.2),
                    strokeWidth: 1,
                  );
                },
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 32,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      if (value < 0 || value >= sortedOptions.length) return const Text('');
                      return Transform.rotate(
                        angle: -0.5,
                        child: Text(
                          sortedOptions[value.toInt()].value['description'],
                          style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 20,
                    reservedSize: 35,
                    getTitlesWidget: (value, meta) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Text('${value.toInt()}%'),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border(
                  bottom: BorderSide(color: theme.colorScheme.outline.withOpacity(0.5)),
                  left: BorderSide(color: theme.colorScheme.outline.withOpacity(0.5)),
                ),
              ),
              minX: -0.2,
              maxX: sortedOptions.length - 0.8,
              minY: 0,
              maxY: (maxPercentage / 10).ceil() * 10 + 10,
              lineBarsData: [
                // Línea de distribución
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: theme.colorScheme.primary,
                  barWidth: 4,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 6,
                        color: theme.colorScheme.surface,
                        strokeWidth: 2,
                        strokeColor: theme.colorScheme.primary,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    color: theme.colorScheme.primary.withOpacity(0.1),
                  ),
                ),
              ],
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  tooltipBgColor: theme.colorScheme.surface,
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      final index = spot.x.toInt();
                      final option = sortedOptions[index];
                      return LineTooltipItem(
                        '${option.value['description']}\n${spot.y}%',
                        TextStyle(color: theme.colorScheme.onSurface),
                      );
                    }).toList();
                  },
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            _buildLegendStat(
              'Media',
              mean.toStringAsFixed(2),
              theme,
              color: theme.colorScheme.tertiary,
            ),
            _buildLegendStat(
              'Desv. Est.',
              stdDev.toStringAsFixed(2),
              theme,
              color: theme.colorScheme.tertiary.withOpacity(0.7),
            ),
            _buildLegendStat(
              'Mediana',
              stats['median']!.toStringAsFixed(2),
              theme,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBoxPlot(Map<String, dynamic> options, ThemeData theme) {
    final sortedOptions = options.entries.toList()
      ..sort((a, b) {
        final pointsA = a.value['points'] ?? 0;
        final pointsB = b.value['points'] ?? 0;
        return pointsA.compareTo(pointsB);
      });

    // Preparar datos para el box plot
    final List<double> values = [];
    int totalResponses = 0;
    
    for (var option in sortedOptions) {
      final count = option.value['count'] as int;
      final points = option.value['points'] as int;
      totalResponses += count;
      for (var i = 0; i < count; i++) {
        values.add(points.toDouble());
      }
    }

    if (values.isEmpty || totalResponses < 2) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Se necesitan al menos dos respuestas para mostrar el diagrama de caja',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    values.sort();
    final stats = _calculateBoxPlotStats(values);

    return Column(
      children: [
        Container(
          height: 180,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: CustomPaint(
            size: const Size(double.infinity, 180),
            painter: BoxPlotPainter(
              min: stats['min']!,
              max: stats['max']!,
              q1: stats['q1']!,
              q2: stats['median']!,
              q3: stats['q3']!,
              theme: theme,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            _buildLegendStat(
              'Mínimo',
              stats['min']!.toStringAsFixed(1),
              theme,
              color: theme.colorScheme.primary.withOpacity(0.7),
            ),
            _buildLegendStat(
              'Q1',
              stats['q1']!.toStringAsFixed(1),
              theme,
            ),
            _buildLegendStat(
              'Mediana',
              stats['median']!.toStringAsFixed(1),
              theme,
              color: theme.colorScheme.primary,
            ),
            _buildLegendStat(
              'Q3',
              stats['q3']!.toStringAsFixed(1),
              theme,
            ),
            _buildLegendStat(
              'Máximo',
              stats['max']!.toStringAsFixed(1),
              theme,
              color: theme.colorScheme.primary.withOpacity(0.7),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendStat(String label, String value, ThemeData theme, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color ?? theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
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
    final stdDev = math.sqrt(variance);

    return {
      'mean': mean,
      'median': median,
      'mode': mode,
      'stdDev': stdDev,
      'min': min.toDouble(),
      'max': max.toDouble(),
    };
  }

  Map<String, double> _calculateBoxPlotStats(List<double> values) {
    if (values.isEmpty) {
      return {
        'min': 0,
        'max': 0,
        'q1': 0,
        'median': 0,
        'q3': 0,
      };
    }

    values.sort();
    final n = values.length;
    
    final min = values.first;
    final max = values.last;

    // Calcular mediana (Q2)
    final medianIndex = n ~/ 2;
    final median = n.isOdd 
        ? values[medianIndex]
        : (values[medianIndex - 1] + values[medianIndex]) / 2;

    // Calcular Q1 y Q3
    final q1Index = n ~/ 4;
    final q3Index = (3 * n) ~/ 4;

    final q1 = n < 4 
        ? min 
        : n.isOdd 
            ? values[q1Index]
            : (values[q1Index - 1] + values[q1Index]) / 2;

    final q3 = n < 4 
        ? max 
        : n.isOdd 
            ? values[q3Index]
            : (values[q3Index - 1] + values[q3Index]) / 2;

    return {
      'min': min,
      'max': max,
      'q1': q1,
      'median': median,
      'q3': q3,
    };
  }
}

class BoxPlotPainter extends CustomPainter {
  final double min;
  final double max;
  final double q1;
  final double q2;
  final double q3;
  final ThemeData theme;

  BoxPlotPainter({
    required this.min,
    required this.max,
    required this.q1,
    required this.q2,
    required this.q3,
    required this.theme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = theme.colorScheme.primary
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = theme.colorScheme.primary.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final medianPaint = Paint()
      ..color = theme.colorScheme.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final whiskerPaint = Paint()
      ..color = theme.colorScheme.primary.withOpacity(0.7)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final height = size.height;
    final width = size.width;
    final padding = width * 0.1;
    final boxWidth = width - (padding * 2);
    final boxHeight = height * 0.3;
    final y = height / 2;

    // Función para mapear valores a posiciones X
    double mapToX(double value) {
      return padding + ((value - min) / (max - min)) * boxWidth;
    }

    // Dibujar líneas de bigotes
    final minX = mapToX(min);
    final maxX = mapToX(max);
    final q1X = mapToX(q1);
    final q2X = mapToX(q2);
    final q3X = mapToX(q3);

    // Dibujar línea horizontal completa (bigotes)
    canvas.drawLine(
      Offset(minX, y),
      Offset(maxX, y),
      whiskerPaint,
    );

    // Dibujar líneas verticales en min y max
    canvas.drawLine(Offset(minX, y - boxHeight/2), Offset(minX, y + boxHeight/2), whiskerPaint);
    canvas.drawLine(Offset(maxX, y - boxHeight/2), Offset(maxX, y + boxHeight/2), whiskerPaint);

    // Dibujar caja
    final rect = Rect.fromPoints(
      Offset(q1X, y - boxHeight),
      Offset(q3X, y + boxHeight),
    );
    canvas.drawRect(rect, fillPaint);
    canvas.drawRect(rect, paint);

    // Dibujar línea mediana
    canvas.drawLine(
      Offset(q2X, y - boxHeight),
      Offset(q2X, y + boxHeight),
      medianPaint,
    );

    // Dibujar etiquetas
    final textStyle = TextStyle(
      color: theme.colorScheme.onSurface,
      fontSize: 11,
    );
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    void drawLabel(double value, double x, double y) {
      textPainter.text = TextSpan(
        text: value.toStringAsFixed(1),
        style: textStyle,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y),
      );
    }

    // Dibujar etiquetas con valores
    drawLabel(min, minX, y + boxHeight + 10);
    drawLabel(max, maxX, y + boxHeight + 10);
    drawLabel(q2, q2X, y - boxHeight - 15);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}