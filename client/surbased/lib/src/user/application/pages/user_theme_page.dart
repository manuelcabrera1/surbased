import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surbased/src/shared/application/provider/theme_provider.dart';

class UserThemePage extends StatefulWidget {
  const UserThemePage({super.key});

  @override
  State<UserThemePage> createState() => _UserThemePageState();
}

class _UserThemePageState extends State<UserThemePage> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tema'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Configuración de Tema',
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),

            // Card para el toggle de tema
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          themeProvider.isDarkMode
                              ? Icons.dark_mode
                              : Icons.light_mode,
                          color: theme.colorScheme.primary,
                          size: 28,
                        ),
                        const SizedBox(width: 16),
                        Text(
                          themeProvider.isDarkMode
                              ? 'Tema Oscuro'
                              : 'Tema Claro',
                          style: theme.textTheme.titleLarge,
                        ),
                      ],
                    ),
                    Switch(
                      value: themeProvider.isDarkMode,
                      onChanged: (value) {
                        themeProvider.toggleTheme();
                      },
                      activeColor: theme.colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Explicación del tema
            Text(
              'Select your preferred theme for the application. The dark theme can help reduce eye strain in low-light environments.',
              style: theme.textTheme.bodyMedium,
            ),

            // Previsualización del tema (opcional)
            const SizedBox(height: 32),
            Text(
              'Previsualización',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            // Ejemplos de elementos UI con el tema actual
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ejemplo de Tarjeta',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Este es un ejemplo de cómo se verán los elementos con el tema seleccionado.',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text('Botón de Ejemplo'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
