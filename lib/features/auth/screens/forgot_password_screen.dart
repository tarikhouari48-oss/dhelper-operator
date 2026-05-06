import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/firebase_service.dart';

const _green = Color(0xFF10B981);

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  // Steps: 0 = enter email, 1 = enter code, 2 = new password
  int _step = 0;
  final _emailCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _pass1Ctrl = TextEditingController();
  final _pass2Ctrl = TextEditingController();
  String? _sentCode;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _codeCtrl.dispose();
    _pass1Ctrl.dispose();
    _pass2Ctrl.dispose();
    super.dispose();
  }

  void _sendCode() {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      setState(() => _error = 'Introduce tu email');
      return;
    }
    final code = ref.read(firebaseServiceProvider).generateResetCode(email);
    if (code.isEmpty) {
      setState(() => _error = 'Email no encontrado');
      return;
    }
    setState(() {
      _sentCode = code;
      _step = 1;
      _error = null;
    });
  }

  void _verifyCode() {
    final code = _codeCtrl.text.trim();
    final ok = ref.read(firebaseServiceProvider).validateResetCode(code);
    if (!ok) {
      setState(() => _error = 'Código incorrecto');
      return;
    }
    setState(() { _step = 2; _error = null; });
  }

  void _changePassword() {
    final p1 = _pass1Ctrl.text;
    final p2 = _pass2Ctrl.text;
    if (p1.isEmpty || p2.isEmpty) {
      setState(() => _error = 'Rellena los dos campos');
      return;
    }
    if (p1.length < 6) {
      setState(() => _error = 'Mínimo 6 caracteres');
      return;
    }
    if (p1 != p2) {
      setState(() => _error = 'Las contraseñas no coinciden');
      return;
    }
    ref.read(firebaseServiceProvider).clearResetCode();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Contraseña actualizada ✓'),
        backgroundColor: _green,
      ),
    );
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recuperar contraseña'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Step indicator
              Row(
                children: List.generate(3, (i) => Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
                    height: 4,
                    decoration: BoxDecoration(
                      color: i <= _step ? _green : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                )),
              ),
              const SizedBox(height: 28),

              if (_step == 0) ...[
                Text('Introduce tu email', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Te enviaremos un código de verificación.', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
                const SizedBox(height: 24),
                TextField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),
                if (_error != null) ...[const SizedBox(height: 10), Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13))],
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: _sendCode,
                  style: FilledButton.styleFrom(minimumSize: const Size(double.infinity, 52), backgroundColor: _green),
                  child: const Text('Enviar código'),
                ),
              ],

              if (_step == 1) ...[
                Text('Introduce el código', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Código enviado a ${_emailCtrl.text}', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
                const SizedBox(height: 16),
                // Demo code hint
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _green.withAlpha(15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _green.withAlpha(50)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: _green, size: 18),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Modo demo', style: TextStyle(color: _green, fontWeight: FontWeight.bold, fontSize: 12)),
                          Text('Tu código: $_sentCode', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _codeCtrl,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: const InputDecoration(
                    labelText: 'Código de 6 dígitos',
                    prefixIcon: Icon(Icons.pin_outlined),
                    border: OutlineInputBorder(),
                    counterText: '',
                  ),
                ),
                if (_error != null) ...[const SizedBox(height: 10), Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13))],
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: _verifyCode,
                  style: FilledButton.styleFrom(minimumSize: const Size(double.infinity, 52), backgroundColor: _green),
                  child: const Text('Verificar'),
                ),
              ],

              if (_step == 2) ...[
                Text('Nueva contraseña', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Elige una contraseña segura.', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
                const SizedBox(height: 24),
                TextField(
                  controller: _pass1Ctrl,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText: 'Nueva contraseña',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _pass2Ctrl,
                  obscureText: _obscure,
                  decoration: const InputDecoration(
                    labelText: 'Confirmar contraseña',
                    prefixIcon: Icon(Icons.lock_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),
                if (_error != null) ...[const SizedBox(height: 10), Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13))],
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: _changePassword,
                  style: FilledButton.styleFrom(minimumSize: const Size(double.infinity, 52), backgroundColor: _green),
                  child: const Text('Guardar contraseña'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
