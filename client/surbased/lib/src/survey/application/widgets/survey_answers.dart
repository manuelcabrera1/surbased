import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surbased/src/auth/application/provider/auth_provider.dart';
import 'package:surbased/src/shared/application/provider/lang_provider.dart';
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
        return t.survey_answers_visualization_descriptive_stats;
      case 'diverging_chart':
        return t.survey_answers_visualization_diverging_chart;
      case 'distribution_chart':
        return t.survey_answers_visualization_distribution_chart;
      case 'pie_chart':
        return t.survey_answers_visualization_pie_chart;
      case 'bar_chart':
        return t.survey_answers_visualization_bar_chart;
      case 'spectrum':
        return t.survey_answers_visualization_spectrum;
      default:
        return type;
    }
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final answersProvider = Provider.of<SurveyAnswersProvider>(context);
    final surveyProvider = Provider.of<SurveyProvider>(context);
    final t = AppLocalizations.of(context)!;

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
          t.survey_answers_no_responses,
          style: theme.textTheme.titleMedium,
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                t.survey_answers_general_summary,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCard(
                        t.survey_answers_total_responses,
                        answersProvider.statistics['total_answers'].toString(),
                        Icons.people,
                        theme.colorScheme.primary,
                      ),
                      _buildStatCard(
                        t.survey_answers_questions,
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
            t.survey_answers_question_stats,
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
  String? _summary;
  
  final Map<String, List<String>> _visualizationTypes = {
    'likert_scale': ['descriptive_stats', 'diverging_chart', 'distribution_chart'],
    'single_choice': ['pie_chart', 'bar_chart', 'spectrum'],
    'multiple_choice': ['pie_chart', 'bar_chart', 'spectrum'],
  };

  String _getVisualizationName(String type, AppLocalizations t) {
    switch (type) {
      case 'descriptive_stats':
        return t.survey_answers_visualization_descriptive_stats;
      case 'diverging_chart':
        return t.survey_answers_visualization_diverging_chart;
      case 'distribution_chart':
        return t.survey_answers_visualization_distribution_chart;
      case 'pie_chart':
        return t.survey_answers_visualization_pie_chart;
      case 'bar_chart':
        return t.survey_answers_visualization_bar_chart;
      case 'spectrum':
        return t.survey_answers_visualization_spectrum;
      default:
        return type;
    }
  }

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

  IconData _getVisualizationIcon(String type) {
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
    return icon;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context)!;
    final String questionType = widget.questionData['type'];
    final String description = widget.questionData['description'];
    final Map<String, dynamic> options = Map<String, dynamic>.from(widget.questionData['options']);
    final int totalResponses = widget.questionData['total_responses'];
    final surveyProvider = Provider.of<SurveyProvider>(context, listen: false);
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
                        totalResponses > 1 
                            ? t.survey_answers_responses_count(totalResponses.toString())
                            : t.survey_answers_response,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (questionType != 'open' && _visualizationTypes.containsKey(questionType)) ...[
                  PopupMenuButton<String>(
                    initialValue: _selectedVisualization,
                    tooltip: t.survey_answers_visualization_change,
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
                            _getVisualizationIcon(_selectedVisualization!),
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
                        final icon = _getVisualizationIcon(type);
                        
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
                                _getVisualizationName(type, t),
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
                if (questionType == 'open') ...[
                  FilledButton(
                    onPressed: surveyProvider.isGeneratingSummary ? null : () => _handleGenerateSummary(description, options),
                    child: Row(children: [
                      if (!surveyProvider.isGeneratingSummary) ...[
                        GestureDetector(
                          child: const Icon(CupertinoIcons.sparkles, size: 20),
                        ),
                        const SizedBox(width: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
                          child: Wrap(children: [
                            Text(t.generate_summary, 
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: 13.5, 
                                color: theme.colorScheme.onPrimary
                              )
                            )
                          ],),
                        )
                      ] else ...[
                        CircularProgressIndicator(
                          strokeWidth: 0.5, 
                          color: theme.colorScheme.onPrimary
                        )
                      ]
                    ],)
                  ),
                ]
              ],
            ),
            const SizedBox(height: 16),
            _buildVisualizationContent(questionType, options),
          ],
        ),
      ),
    );
  }

  Future<void> _handleGenerateSummary(String questionDescription, Map<String, dynamic> options) async {
    try {
      final surveyProvider = Provider.of<SurveyProvider>(context, listen: false);
      final locale = Provider.of<LangProvider>(context, listen: false).locale;
      List<String> optionsArray = [];
      options.forEach((key, value) {
        optionsArray.add(value['text']);
      });
      final summary = await surveyProvider.generateSummary(questionDescription, optionsArray, locale.toString());
      if (summary != null && summary.isNotEmpty) {
        setState(() {
          _summary = summary;
        });
      } else {
        setState(() {
          _summary = null;
        });
      }
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  Widget _buildVisualizationContent(
    String questionType,
    Map<String, dynamic> options,
  ) {
    if (questionType == 'likert_scale') {
      return _buildLikertScaleVisualization(options);
    } else if ((questionType == 'single_choice' || questionType == 'multiple_choice') && 
              _visualizationTypes.containsKey(questionType)) {
      return _buildChoiceVisualization(options);
    } else {
      return _buildOpenAnswers(options, _summary ?? '');
    }
  }

  Widget _buildLikertScaleVisualization(Map<String, dynamic> options) {
    switch (_selectedVisualization) {
      case 'descriptive_stats':
        return _buildDescriptiveStats(_calculateLikertStats(options.entries.toList()));
      case 'diverging_chart':
        return _buildDivergingChart(options);
      case 'distribution_chart':
        return _buildDistributionChart(options);
      default:
        return const SizedBox();
    }
  }

  Widget _buildChoiceVisualization(Map<String, dynamic> options) {
    switch (_selectedVisualization) {
      case 'pie_chart':
        return _buildPieChart(options);
      case 'bar_chart':
        return _buildBarChart(options);
      case 'spectrum':
        return _buildSpectrumChart(options);
      default:
        return const SizedBox();
    }
  }

  Widget _buildDescriptiveStats(Map<String, double> stats) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatBox(t.survey_answers_mean, stats['mean']?.toStringAsFixed(2) ?? '0.00', theme),
                _buildStatBox(t.survey_answers_median, stats['median']?.toStringAsFixed(2) ?? '0.00', theme),
                _buildStatBox(t.survey_answers_mode, stats['mode']?.toStringAsFixed(2) ?? '0.00', theme),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatBox(t.survey_answers_std_dev, stats['stdDev']?.toStringAsFixed(2) ?? '0.00', theme),
                _buildStatBox(t.survey_answers_min, stats['min']?.toInt().toString() ?? '0', theme),
                _buildStatBox(t.survey_answers_max, stats['max']?.toInt().toString() ?? '0', theme),
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

  Widget _buildDivergingChart(Map<String, dynamic> options) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context)!;
    final sortedOptions = options.entries.toList()
      ..sort((a, b) {
        final pointsA = a.value['points'] ?? 0;
        final pointsB = b.value['points'] ?? 0;
        return pointsA.compareTo(pointsB);
      });

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
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
              t.survey_answers_positive_responses,
              '${_calculatePositivePercentage(sortedOptions, middlePoint)}%',
              theme,
              color: theme.colorScheme.primary,
            ),
            _buildLegendStat(
              t.survey_answers_negative_responses,
              '${_calculateNegativePercentage(sortedOptions, middlePoint)}%',
              theme,
              color: theme.colorScheme.error,
            ),
            _buildLegendStat(
              t.survey_answers_neutral_responses,
              '${_calculateNeutralPercentage(sortedOptions, middlePoint)}%',
              theme,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPieChart(Map<String, dynamic> options) {
    return _buildChoiceChart(options);  // Reutilizamos el existente
  }

  Widget _buildBarChart(Map<String, dynamic> options) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context)!;
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
              t.survey_answers_responses_percentage,
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
                        '${option.value['description']}\n${t.survey_answers_responses_count(count.toString())} (${percentage.toStringAsFixed(1)}%)',
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
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
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

  Widget _buildSpectrumChart(Map<String, dynamic> options) {
    final theme = Theme.of(context);
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

  Widget _buildChoiceChart(Map<String, dynamic> options) {
    final theme = Theme.of(context);
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

  Widget _buildOpenAnswers(Map<String, dynamic> options, String summary) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context)!;
    const maxNumberOfAnswers = 5;
    final totalAnswers = options.length;
    final answersToShow = options.entries.take(maxNumberOfAnswers).toList();
    final hasMoreAnswers = totalAnswers > maxNumberOfAnswers;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (summary.isNotEmpty) ...[
            Card(
              margin: const EdgeInsets.only(bottom: 8),
              elevation: 10,
              color: theme.colorScheme.onTertiaryContainer.withOpacity(0.15),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.survey_answers_ai_summary,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      summary,
                      style: theme.textTheme.bodyMedium,
                      maxLines: 7,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
          Text(
            t.survey_answers_responses_count(totalAnswers.toString()),
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 9),
          ...answersToShow.map((entry) {
            return Card(
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
                side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.5)),
              ),
              color: theme.colorScheme.onPrimary,
              margin: const EdgeInsets.only(bottom: 6),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.value['text'] ?? entry.value['description'],
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
          if (hasMoreAnswers) ...[
            const SizedBox(height: 8),
            Center(
              child: Text(
                t.survey_answers_more_responses(totalAnswers - maxNumberOfAnswers),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
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

  Widget _buildDistributionChart(Map<String, dynamic> options) {
    final theme = Theme.of(context);
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
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
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

}
