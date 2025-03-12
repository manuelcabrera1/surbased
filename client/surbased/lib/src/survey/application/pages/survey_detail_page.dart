import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surbased/src/auth/application/provider/auth_provider.dart';
import 'package:surbased/src/category/application/provider/category_provider.dart';
import 'package:surbased/src/config/app_routes.dart';
import 'package:surbased/src/survey/application/widgets/survey_participants.dart';

import '../../../user/domain/user_model.dart';
import '../../domain/survey_model.dart';
import '../provider/survey_provider.dart';
import '../widgets/survey_info.dart';

class SurveyDetailPage extends StatefulWidget {
  const SurveyDetailPage({super.key});

  @override
  State<SurveyDetailPage> createState() => _SurveyDetailPageState();
}

class _SurveyDetailPageState extends State<SurveyDetailPage>
    with SingleTickerProviderStateMixin {
  Survey? survey;
  late TabController tabController;
  bool _participantsLoaded = false;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);

    tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    if (tabController.indexIsChanging) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    tabController.removeListener(_handleTabSelection);
    tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_participantsLoaded) {
      _loadParticipants();
      setState(() {
        _participantsLoaded = true;
      });
    }
  }

  Future<void> _loadParticipants() async {
    try {
      final surveyProvider =
          Provider.of<SurveyProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      survey = surveyProvider.currentSurvey;

      if (survey != null && authProvider.token != null) {
        await surveyProvider.getSurveyParticipants(
            survey!.id!, authProvider.token!);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surveyProvider = Provider.of<SurveyProvider>(context);
    survey = surveyProvider.currentSurvey;

    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: Text(
            survey!.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          bottom: TabBar(
            controller: tabController,
            tabAlignment: TabAlignment.fill,
            tabs: [
              Tab(
                  text: 'Info',
                  icon: Icon(Icons.info, color: theme.colorScheme.surface)),
              Tab(
                  text: 'Participants',
                  icon: Icon(Icons.people, color: theme.colorScheme.surface)),
              Tab(
                  text: 'Stats',
                  icon:
                      Icon(Icons.bar_chart, color: theme.colorScheme.surface)),
            ],
          ),
          actions: [
            PopupMenuButton(
                icon: const Icon(Icons.more_vert),
                itemBuilder: (context) => [
                      PopupMenuItem(
                        onTap: () => {
                          Navigator.pushNamed(context, AppRoutes.surveyEdit)
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(Icons.edit, color: theme.colorScheme.primary),
                            const SizedBox(width: 12),
                            const Text('Edit'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        onTap: () => {},
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(Icons.delete,
                                color: theme.colorScheme.primary),
                            const SizedBox(width: 12),
                            const Text('Remove'),
                          ],
                        ),
                      ),
                    ])
          ]),
      body: TabBarView(
        controller: tabController,
        children: const [
          SurveyInfo(),
          SurveyParticipants(),
          Text('Stats'),
        ],
      ),
      floatingActionButton: tabController.index == 1
          ? FloatingActionButton(
              onPressed: () {
                // Lógica para añadir participantes
                print('Add participant button pressed');
              },
              tooltip: 'Add Participant',
              child: const Icon(Icons.person_add),
            )
          : null,
    );
  }
}
