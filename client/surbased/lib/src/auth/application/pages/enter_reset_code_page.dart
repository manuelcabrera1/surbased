import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surbased/src/auth/application/provider/auth_provider.dart';
import 'package:surbased/src/auth/application/widgets/custom_otp_field.dart';
import 'package:surbased/src/user/application/pages/user_edit_password_page.dart';
class EnterResetCodePage extends StatefulWidget {
  const EnterResetCodePage({super.key});

  @override
  State<EnterResetCodePage> createState() => _EnterResetCodePageState();
}

class _EnterResetCodePageState extends State<EnterResetCodePage> {
  List<String> inputResetCode = [];

  @override
  void initState() {  
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        _initInputResetCode();
      });
    });
  }

  void _initInputResetCode() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final resetCodeLength = authProvider.resetCode!.toString().length;
    for (int i = 0; i < resetCodeLength; i++) {
      inputResetCode.add('');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back),
                  ),
                  Expanded(
                    child: Text(
                      'Reset Code',
                      style: theme.textTheme.displayMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 24),
                ],
              ),
              const SizedBox(height: 40),
              Text(
                        'Please enter the 6-digit code that we sent to your email address.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
              ),
              const SizedBox(height: 30),
              Form(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ...List.generate(
                      authProvider.resetCode!.toString().length,
                      (index) => CustomOTPField(
                        onChanged: (value) {
                          setState(() {                          
                            inputResetCode[index] = value;
                          });
                          print(authProvider.resetCode!);
                        },
                        isFirstField: index == 0,
                        isLastField: index == authProvider.resetCode!.toString().length - 1,
                      )
                    ),
                  ]
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed:  () {
                  if (inputResetCode.join() == authProvider.resetCode!.toString()) {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const UserEditPasswordPage()));
                  }
                  else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Invalid reset code')),
                    );
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

