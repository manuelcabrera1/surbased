import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:surbased/src/auth/application/provider/auth_provider.dart';
import 'package:surbased/src/survey/application/provider/survey_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SurveyAnswersDownloadDialog extends StatefulWidget {


 const SurveyAnswersDownloadDialog({super.key});

  @override
  State<SurveyAnswersDownloadDialog> createState() => _SurveyAnswersDownloadDialogState();
}

class _SurveyAnswersDownloadDialogState extends State<SurveyAnswersDownloadDialog> {
  final Map<String, String> formats = {
    'csv': 'Valores separados por comas',
    'xlsx': 'Formato Excel',
  };
  String selectedFormat = 'csv';
  final formKey = GlobalKey<FormState>();
  final filenameController = TextEditingController();
  late String defaultFileName;


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final surveyProvider = Provider.of<SurveyProvider>(context, listen: false);
      final survey = surveyProvider.currentSurvey;
      if (survey != null) {
        setState(() {
          defaultFileName = 'survey_${survey.id}_answers_${DateTime.now().millisecondsSinceEpoch}';
          selectedFormat = 'csv';
        });
      }
    });
    
  }

  String? _fieldValidator(String? value) {
    if (value == null || value.isEmpty || value.trim().isEmpty) {
      return AppLocalizations.of(context)!.input_error_required;
    }
    return null;
  }

  Future<void> _downloadFile(String? f, String? name) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final surveyProvider = Provider.of<SurveyProvider>(context, listen: false);
    final token = authProvider.token;
    final surveyId = surveyProvider.currentSurvey?.id;
    final fileName = name != null && name != '' ? name : defaultFileName;
    final format = f ?? selectedFormat;

    
    if (token == null || surveyId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo autenticar la descarga')),
      );
      return;
    }

    var permissionStatus = await Permission.storage.status;
    if (permissionStatus.isDenied) {
        await Permission.storage.request();
        if (permissionStatus.isDenied) {
          permissionStatus = await Permission.mediaLibrary.request();
          if (permissionStatus.isDenied) {
            await openAppSettings();
          }
        }
    } else if (permissionStatus.isPermanentlyDenied) {

        await openAppSettings();
    } else {
        try {
        // Usar el directorio de documentos de la aplicación que no requiere permisos especiales
        final appDir = await getDownloadsDirectory();
        final appDirPath = appDir!.path;

        print(appDirPath);
        
        // Asegurarse de que el directorio existe
        if (!await appDir.exists()) {
          await appDir.create(recursive: true);
        }

        final url = 'http://192.168.1.69:8000/surveys/$surveyId/answers/export/$format?filename=$fileName';

        print(url);

        final taskId = await FlutterDownloader.enqueue(
          url: url.toString(),
          headers: {'Authorization': 'Bearer $token'},
          savedDir: appDirPath,
          fileName: '$fileName.$format',
          showNotification: true,
          openFileFromNotification: true,
          allowCellular: true,
        );

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Descarga iniciada: $fileName.$format en $appDirPath'),
              action: SnackBarAction(
                label: 'Abrir',
                onPressed: () {
                  if (taskId != null) {
                    FlutterDownloader.open(taskId: taskId);
                  }
                },
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al descargar: $e')),
          );
        }
      }
    }
    

    
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(t.survey_download_answers),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            TextFormField(
              controller: filenameController,
              keyboardType: TextInputType.name,
              decoration: InputDecoration(
                labelText: t.survey_download_answers_filename,
              ),
              validator: _fieldValidator,
            ),
            const SizedBox(height: 30),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: t.survey_download_answers_format,
                border: const OutlineInputBorder(),
              ),
              items: formats.entries.map((entry) => DropdownMenuItem(
                value: entry.key.toUpperCase(),
                child: Text(entry.key.toUpperCase()),
              )).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedFormat = newValue!;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t.cancel),
          ),
          FilledButton(
            onPressed: () => _downloadFile(selectedFormat, filenameController.value.text),
            child: Text(t.export),
          ),
        ],
    );
  }

  
}
