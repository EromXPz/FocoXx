import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const FocoXApp());

class FocoXApp extends StatelessWidget {
  const FocoXApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'FocoX',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6C63FF)), useMaterial3: true),
    home: const FocoHome(),
  );
}

class FocoHome extends StatefulWidget {
  const FocoHome({super.key});
  @override
  State<FocoHome> createState() => _FocoHomeState();
}

class _FocoHomeState extends State<FocoHome> {
  static const platform = MethodChannel('app.focox/control');
  final apps = <String, String>{
    'com.instagram.android': 'Instagram',
    'com.zhiliaoapp.musically': 'TikTok',
    'com.google.android.youtube': 'YouTube',
    'com.whatsapp': 'WhatsApp',
    'com.twitter.android': 'X',
    'com.kwai.video': 'Kwai',
    'com.reddit.frontpage': 'Reddit',
  };
  final selected = <String>{};
  int minutes = 25;
  bool enabled = false;
  String status = 'Configure os aplicativos que deseja bloquear.';
  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    try {
      final data = await platform.invokeMapMethod<String, dynamic>('loadSettings');
      if (!mounted || data == null) return;
      setState(() {
        selected.addAll((data['packages'] as List<dynamic>? ?? []).cast<String>());
        minutes = (data['minutes'] as int?) ?? 25;
        enabled = (data['enabled'] as bool?) ?? false;
      });
    } on PlatformException catch (e) { if (mounted) setState(() => status = 'Erro ao carregar: ${e.message}'); }
  }
  Future<void> _save() async {
    try {
      await platform.invokeMethod('saveSettings', {'packages': selected.toList(), 'minutes': minutes, 'enabled': enabled});
      if (mounted) setState(() => status = enabled ? 'Foco ativo. Ative a Acessibilidade nas configurações do Android.' : 'Configurações salvas neste aparelho.');
    } on PlatformException catch (e) { if (mounted) setState(() => status = 'Não foi possível salvar: ${e.message}'); }
  }
  Future<void> _accessibility() async {
    try { await platform.invokeMethod('openAccessibilitySettings'); }
    on PlatformException catch (e) { if (mounted) setState(() => status = e.message ?? 'Não foi possível abrir as configurações.'); }
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Row(children: [Icon(Icons.shield_moon_rounded), SizedBox(width: 10), Text('FocoX')]), actions: [IconButton(onPressed: _accessibility, tooltip: 'Acessibilidade', icon: const Icon(Icons.accessibility_new))]),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: theme.colorScheme.primaryContainer, borderRadius: BorderRadius.circular(24)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(enabled ? Icons.lock_rounded : Icons.center_focus_strong_rounded, size: 36, color: theme.colorScheme.onPrimaryContainer),
          const SizedBox(height: 12),
          Text(enabled ? 'Modo foco configurado' : 'Recupere seu foco', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimaryContainer)),
          const SizedBox(height: 6),
          Text('Escolha os apps que tiram sua atenção e configure um período de foco.', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onPrimaryContainer)),
          const SizedBox(height: 12),
          SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Ativar bloqueio'), value: enabled, onChanged: (v) { setState(() => enabled = v); _save(); }),
        ])),
        const SizedBox(height: 24),
        Text('Duração do foco', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(spacing: 8, children: [15, 25, 45, 60].map((m) => ChoiceChip(label: Text('$m min'), selected: minutes == m, onSelected: (_) { setState(() => minutes = m); _save(); })).toList()),
        const SizedBox(height: 24),
        Text('Aplicativos para bloquear', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('Selecione os apps instalados que deseja limitar.', style: theme.textTheme.bodySmall),
        const SizedBox(height: 8),
        ...apps.entries.map((e) => Card(child: CheckboxListTile(value: selected.contains(e.key), onChanged: (v) { setState(() { if (v == true) { selected.add(e.key); } else { selected.remove(e.key); } }); _save(); }, secondary: const Icon(Icons.apps_rounded), title: Text(e.value)))),
        const SizedBox(height: 16),
        FilledButton.icon(onPressed: _accessibility, icon: const Icon(Icons.settings), label: const Text('Configurar acessibilidade')),
        const SizedBox(height: 12),
        Text(status, style: theme.textTheme.bodySmall),
        const SizedBox(height: 8),
        Text('O bloqueio depende da Acessibilidade permanecer ativada. O Android permite desativá-la ou desinstalar o app.', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      ]),
    );
  }
}