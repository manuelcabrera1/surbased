import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surbased/src/category/application/provider/category_provider.dart';
import 'package:surbased/src/survey/application/provider/survey_provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:surbased/src/shared/application/provider/lang_provider.dart';

class SurveyEventsCalendar extends StatefulWidget {
  const SurveyEventsCalendar({super.key});

  @override
  State<SurveyEventsCalendar> createState() => _SurveyEventsCalendarState();
}

class _SurveyEventsCalendarState extends State<SurveyEventsCalendar> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late Map<DateTime, List<dynamic>> _events;
  bool _isExpanded =
      false; // Variable para controlar si la lista está expandida

  @override
  void dispose() {
    super.dispose();
    _events.clear();
  }

  @override
  void initState() {
    super.initState();
    _events = {};
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadEvents();
  }

  void _loadEvents() {
    try {
      final surveyProvider =
          Provider.of<SurveyProvider>(context, listen: false);
      final categoryProvider =
          Provider.of<CategoryProvider>(context, listen: false);

      _events.clear();

      DateTime now = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      );

      if (surveyProvider.surveys.isNotEmpty) {
        for (var survey in surveyProvider.surveys) {
          if (survey.endDate != null) {
            if (survey.endDate!.isAfter(now) ||
                survey.endDate!.isAtSameMomentAs(now)) {
              for (DateTime date = survey.startDate;
                  date.isBefore(survey.endDate!) ||
                      date.isAtSameMomentAs(survey.endDate!);
                  date = date.add(const Duration(days: 1))) {
                final eventDate = DateTime(date.year, date.month, date.day);
                if (!_events.containsKey(eventDate)) {
                  _events[eventDate] = [];
                }
                _events[eventDate]!.add({
                  'surveyName': survey.name,
                  'surveyDescription': survey.description,
                  'surveyCategory':
                      categoryProvider.getCategoryById(survey.categoryId).name,
                });
              }
            }
          }
        }
      }

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.events_loading_error),
          ),
        );
      }
    }
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    final now = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );

    // No mostrar eventos para días anteriores al actual
    if (day.isBefore(now)) {
      return [];
    }

    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surveyProvider = Provider.of<SurveyProvider>(context);
    final langProvider = Provider.of<LangProvider>(context);

    if (surveyProvider.surveys.isNotEmpty && _events.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _loadEvents();
        }
      });
    }

    if (surveyProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 25),
                child: Text(AppLocalizations.of(context)!.calendar_page_title,
                    style: theme.textTheme.displayMedium),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding:
                  const EdgeInsets.only(left: 8, right: 8, bottom: 20, top: 8),
              child: TableCalendar(
                locale: Localizations.localeOf(context).languageCode,
                firstDay: DateTime.utc(1970, 1, 1),
                lastDay: DateTime.utc(2025, 12, 31),
                startingDayOfWeek: StartingDayOfWeek.monday,
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: theme.textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  leftChevronIcon: Icon(
                    Icons.chevron_left,
                    color: theme.colorScheme.primary,
                  ),
                  rightChevronIcon: Icon(
                    Icons.chevron_right,
                    color: theme.colorScheme.primary,
                  ),
                ),
                calendarStyle: CalendarStyle(
                  cellMargin: const EdgeInsets.symmetric(vertical: 9),
                  markersMaxCount: 1,
                  markerSize: 6,
                  markerDecoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  todayTextStyle: TextStyle(color: theme.colorScheme.primary),
                  markerMargin: const EdgeInsets.only(top: 7),
                  todayDecoration: BoxDecoration(
                    border:
                        Border.all(color: theme.colorScheme.primary, width: 2),
                    shape: BoxShape.circle,
                  ),
                  selectedTextStyle:
                      TextStyle(color: theme.colorScheme.onPrimary),
                  selectedDecoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  weekendTextStyle: TextStyle(
                    color: theme.colorScheme.primary.withOpacity(0.7),
                  ),
                  outsideTextStyle: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
                eventLoader: _getEventsForDay,
              ),
            ),
            const SizedBox(height: 15),
            if (_selectedDay != null)
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: theme.colorScheme.onPrimary.withOpacity(0.9),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        Text(
                          AppLocalizations.of(context)!.calendar_surveys_for(
                            _selectedDay!.day,
                            _selectedDay!.month,
                            _selectedDay!.year,
                          ),
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Divider(
                          thickness: 0.2,
                        ),
                        if (_selectedDay != null &&
                            _getEventsForDay(_selectedDay!).isNotEmpty) ...[
                          const SizedBox(height: 20),
                          // Obtener la lista de eventos para el día seleccionado
                          Builder(builder: (context) {
                            final events = _getEventsForDay(_selectedDay!);
                            final eventCount = events.length;
                            final showExpandButton = eventCount > 2;
                            final displayCount =
                                _isExpanded || !showExpandButton
                                    ? eventCount
                                    : 2;

                            return Column(
                              children: [
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  padding: EdgeInsets.zero,
                                  itemCount: displayCount,
                                  itemBuilder: (context, index) {
                                    final event = events[index];
                                    return Card(
                                      margin: const EdgeInsets.only(bottom: 20),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      elevation: 1,
                                      color: theme.colorScheme.primaryContainer
                                          .withOpacity(0.4),
                                      child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${event['surveyName']} - ${event['surveyCategory']}',
                                              style: theme.textTheme.titleMedium
                                                  ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    theme.colorScheme.primary,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${event['surveyDescription']}',
                                              style: theme.textTheme.bodyMedium,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                if (showExpandButton)
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _isExpanded = !_isExpanded;
                                      });
                                    },
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          _isExpanded
                                              ? AppLocalizations.of(context)!
                                                  .show_less
                                              : AppLocalizations.of(context)!
                                                  .show_all(eventCount - 2),
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                            color: theme.colorScheme.primary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Icon(
                                          _isExpanded
                                              ? Icons.keyboard_arrow_up
                                              : Icons.keyboard_arrow_down,
                                          size: 16,
                                          color: theme.colorScheme.primary,
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            );
                          }),
                          const SizedBox(height: 10),
                        ] else ...[
                          SizedBox(
                            height: 150,
                            child: Center(
                              child: Text(
                                AppLocalizations.of(context)!
                                    .calendar_no_surveys_for_day,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                  fontStyle: FontStyle.italic,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ]
                      ]),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
