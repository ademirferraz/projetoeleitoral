import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../services/billing_service.dart';

class TelaAtivacao extends StatefulWidget {
  final Widget child;
  const TelaAtivacao({super.key, required this.child});

  @override
  State<TelaAtivacao> createState() => _TelaAtivacaoState();
}

class _TelaAtivacaoState extends State<TelaAtivacao> {
  String? _comprandoId;
  bool _restaurando = false;

  @override
  void initState() {
    super.initState();
    if (BillingService.isInitialized && BillingService.isComprado) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    }
  }

  Future<void> _comprar(ProductDetails produto) async {
    if (_comprandoId != null) return;
    setState(() => _comprandoId = produto.id);

    final sucesso = await BillingService.iniciarCompra(produto);

    if (!sucesso && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível iniciar a compra. Tente novamente.'),
          backgroundColor: Colors.red,
        ),
      );
    }

    if (mounted) setState(() => _comprandoId = null);
  }

  Future<void> _restaurar() async {
    if (_restaurando) return;
    setState(() => _restaurando = true);

    await BillingService.restaurarCompras();

    if (mounted) {
      setState(() => _restaurando = false);
      if (!BillingService.isComprado) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nenhuma compra anterior encontrada.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _digitarCodigo() async {
    if (!mounted) return;
    final controlador = TextEditingController();
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Código de acesso'),
        content: TextField(
          controller: controlador,
          autofocus: true,
          autocorrect: false,
          enableSuggestions: false,
          decoration: const InputDecoration(
            hintText: 'Digite seu código',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (_) => Navigator.pop(ctx, true),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmado != true || !mounted) return;

    final ok = await BillingService.liberarPorCodigo(controlador.text);

    if (!mounted) return;
    if (ok) {
      setState(() {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Código inválido. Verifique e tente novamente.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// O Play devolve o título com o nome do app entre parênteses no fim.
  String _tituloLimpo(ProductDetails p) {
    return p.title.replaceAll(RegExp(r'\s*\([^)]*\)\s*$'), '').trim();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb || BillingService.isComprado) {
      return widget.child;
    }

    final planos = BillingService.produtos;

    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 40),
                const Icon(Icons.lock_outline, size: 80, color: Colors.amber),
                const SizedBox(height: 16),
                const Text(
                  'App Bloqueado',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  'Escolha seu plano e libere\ntodos os recursos do sistema.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Colors.grey[400]),
                ),
                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: _digitarCodigo,
                    icon: const Icon(Icons.key, color: Colors.black87),
                    label: const Text(
                      'Tenho um código de acesso',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.amber.shade700,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                _beneficio(Icons.assessment, 'Relatórios completos com gráficos'),
                _beneficio(Icons.people, 'Gestão de eleitores e candidatos'),
                _beneficio(Icons.bar_chart, 'Resultados em tempo real'),
                _beneficio(Icons.share, 'Compartilhamento de relatórios'),

                const SizedBox(height: 32),

                if (planos.isEmpty)
                  _planosIndisponiveis()
                else
                  ...planos.map(_cartaoPlano),

                const SizedBox(height: 12),

                TextButton(
                  onPressed: _restaurando ? null : _restaurar,
                  child: _restaurando
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white54))
                      : Text(
                          'Já comprei? Restaurar compras',
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[500]),
                        ),
                ),

                const SizedBox(height: 32),
                const Divider(color: Colors.white24),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _cartaoPlano(ProductDetails p) {
    final processando = _comprandoId == p.id;
    final bloqueado = _comprandoId != null && !processando;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            _tituloLimpo(p),
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white),
          ),
          if (p.description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              p.description,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey[400]),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            p.price,
            style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: Colors.amber),
          ),
          const SizedBox(height: 4),
          Text(
            'Pagamento único • Acesso para sempre',
            style: TextStyle(fontSize: 13, color: Colors.grey[400]),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: bloqueado ? null : () => _comprar(p),
              icon: processando
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.black87))
                  : const Icon(Icons.shopping_cart, color: Colors.black87),
              label: Text(
                processando ? 'Processando...' : 'COMPRAR AGORA',
                style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber.shade700,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _planosIndisponiveis() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: [
          const Icon(Icons.cloud_off, color: Colors.white54, size: 32),
          const SizedBox(height: 12),
          const Text(
            'Planos indisponíveis no momento',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white),
          ),
          const SizedBox(height: 6),
          Text(
            'Verifique sua conexão e a conta do Google Play,\ne tente novamente em instantes.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  Widget _beneficio(IconData icon, String texto) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.amber, size: 22),
          const SizedBox(width: 12),
          Text(texto,
              style: const TextStyle(fontSize: 15, color: Colors.white70)),
        ],
      ),
    );
  }
}
