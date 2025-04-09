import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surbased/src/auth/application/provider/auth_provider.dart';
import 'package:surbased/src/config/app_routes.dart';
import 'package:surbased/src/survey/application/widgets/survey_add_participants_dialog.dart';
import 'package:surbased/src/survey/application/widgets/survey_answers.dart';
import 'package:surbased/src/survey/application/widgets/survey_answers_download_dialog.dart';
import 'package:surbased/src/survey/application/widgets/survey_participants.dart';

import '../../domain/survey_model.dart';
import '../provider/survey_provider.dart';
import '../widgets/survey_info.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SurveyDetailsPage extends StatefulWidget {
  const SurveyDetailsPage({super.key});

  @override
  State<SurveyDetailsPage> createState() => _SurveyDetailsPageState();
}

class _SurveyDetailsPageState extends State<SurveyDetailsPage>
    with TickerProviderStateMixin {
  Survey? survey;
  late TabController tabController;
  bool _participantsLoaded = false;
  List<Tab> tabTitles = [];
  List<Widget> tabViews = [];

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 1, vsync: this);
    tabController.addListener(_handleTabSelection);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    if (!mounted) return;
    
    final surveyProvider = Provider.of<SurveyProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (surveyProvider.currentSurvey?.id != null && authProvider.token != null) {
      await surveyProvider.getUsersAssignedToSurvey(
        surveyProvider.currentSurvey!.id!,
        authProvider.token!
      );
    }

    if (!mounted) return;
    
    setState(() {
      _participantsLoaded = true;
    });
    
    _configureTabs();
  }

  void _handleTabSelection() {
    if (tabController.indexIsChanging) {
      setState(() {});
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_participantsLoaded) {
      _configureTabs();
    }
  }

  void _configureTabs() {
    final surveyProvider = Provider.of<SurveyProvider>(context, listen: false);
    final t = AppLocalizations.of(context)!;

    if (surveyProvider.isLoading || surveyProvider.currentSurvey == null) {
      return;
    }
    if (mounted) {
      final theme = Theme.of(context);
      if (surveyProvider.currentSurvey!.scope != 'public') {
          tabTitles = [
            Tab(
                    text: t.survey_info,
                    icon: Icon(Icons.info, color: theme.colorScheme.surface)),
                Tab(
                    text: t.survey_participants,
                    icon: Icon(Icons.people, color: theme.colorScheme.surface)),
                Tab(
                    text: t.survey_stats,
                    icon:
                        Icon(Icons.bar_chart, color: theme.colorScheme.surface)),
          ];
          tabViews = const [
            SurveyInfo(),
            SurveyParticipants(),
            SurveyAnswers(),
          ];
        
      } else {
        tabTitles = [
            Tab(
              text: t.survey_info,
              icon: Icon(Icons.info, color: theme.colorScheme.surface)),
            Tab(
                text: t.survey_stats,
                icon:
                    Icon(Icons.bar_chart, color: theme.colorScheme.surface)),
          ];
          tabViews = const [
            SurveyInfo(),
            SurveyAnswers(),
          ];
      }
    }

    tabController.dispose(); // Primero liberar el controlador actual
    tabController = TabController(length: tabTitles.length, vsync: this);
    tabController.addListener(_handleTabSelection);
    
    setState(() {}); // Forzar rebuild
  }

  void _showAddParticipantsModal() {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) => const SurveyAddParticipantsDialog(),
    );
  }

  void _removeSurvey() {
    final surveyProvider = Provider.of<SurveyProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      if (authProvider.token != null && mounted) {
        surveyProvider.removeSurvey(authProvider.token!);
        surveyProvider.clearCurrentSurvey();
        Navigator.pushNamed(context, AppRoutes.home);
        if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.survey_removed)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  void _showRemoveSurveyDialog() {
    final t = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.survey_remove),
        content: Text(t.survey_remove_confirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t.cancel),
          ),
          TextButton(
            onPressed: () => _removeSurvey(),
            child: Text(t.save),
          ),
        ],
      ),
    );
  }

  void _showDownloadDialog() {
    showDialog(
      context: context,
      builder: (context) => SurveyAnswersDownloadDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surveyProvider = Provider.of<SurveyProvider>(context);
    survey = surveyProvider.currentSurvey;
    final authProvider = Provider.of<AuthProvider>(context);
    final t = AppLocalizations.of(context)!;

     if (tabTitles.isEmpty || tabViews.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (survey == null || surveyProvider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
            surveyProvider.clearCurrentSurvey();
          },
          icon: const Icon(Icons.arrow_back),
        ),
        centerTitle: true,
        title: Text(
          survey!.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          bottom: TabBar(
            dividerHeight: 0,
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: theme.colorScheme.surface,
            unselectedLabelColor: theme.colorScheme.surface.withOpacity(0.7),
            indicatorColor: theme.colorScheme.surface,
            controller: tabController,
            tabAlignment: TabAlignment.fill,
            tabs: tabTitles,
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
                            Text(t.edit),
                          ],
                        ),
                      ),
                      if (surveyProvider.currentSurvey!.ownerId == authProvider.user!.id)
                      PopupMenuItem(
                        onTap: () => _showRemoveSurveyDialog(),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(Icons.delete,
                                color: theme.colorScheme.primary),
                            const SizedBox(width: 12),
                            Text(t.remove),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        onTap: () => _showDownloadDialog(),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(Icons.download,
                                color: theme.colorScheme.primary),
                            const SizedBox(width: 12),
                            Text(t.survey_download_answers),
                          ],
                        ),
                      ),
                    ])
          ]),
      body: TabBarView(
        controller: tabController,
        children: tabViews,
      ),
      floatingActionButton: tabController.index == 1 && surveyProvider.currentSurvey!.scope != 'public'
          ? FloatingActionButton(
              heroTag: 'participants',
              onPressed: () => _showAddParticipantsModal(),
              tooltip: t.survey_add_participant,
              child: const Icon(Icons.person_add),
            )
          : null,
    );
  }
}
