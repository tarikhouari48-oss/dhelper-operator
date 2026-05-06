import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:operator_app/l10n/app_localizations.dart';
import '../../../core/models/order_model.dart';
import '../../../core/services/firebase_service.dart';

class CreateOrderScreen extends ConsumerStatefulWidget {
  const CreateOrderScreen({super.key});

  @override
  ConsumerState<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends ConsumerState<CreateOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  PaymentType _paymentType = PaymentType.cash;
  final List<FoodItem> _items = [];
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  void _showAddItemDialog() {
    final nameCtrl = TextEditingController();
    final qtyCtrl = TextEditingController(text: '1');
    final priceCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Item Name'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: qtyCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Qty'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: priceCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Price'),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (nameCtrl.text.trim().isNotEmpty) {
                setState(() => _items.add(FoodItem(
                      name: nameCtrl.text.trim(),
                      quantity: int.tryParse(qtyCtrl.text) ?? 1,
                      price: double.tryParse(priceCtrl.text) ?? 0,
                    )));
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one item')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final order = OrderModel(
        id: '',
        customerName: _nameCtrl.text.trim(),
        phoneNumber: _phoneCtrl.text.trim(),
        deliveryAddress: _addressCtrl.text.trim(),
        items: List.from(_items),
        paymentType: _paymentType,
        status: OrderStatus.pending,
        createdAt: DateTime.now(),
        operatorId: 'local',
      );
      await ref.read(firebaseServiceProvider).createOrder(order);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order created!')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.createOrder)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: InputDecoration(
                labelText: l10n.customerName,
                prefixIcon: const Icon(Icons.person_outline),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (v) => v?.trim().isEmpty == true ? l10n.required : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneCtrl,
              decoration: InputDecoration(
                labelText: l10n.phoneNumber,
                prefixIcon: const Icon(Icons.phone_outlined),
              ),
              keyboardType: TextInputType.phone,
              validator: (v) => v?.trim().isEmpty == true ? l10n.required : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressCtrl,
              decoration: InputDecoration(
                labelText: l10n.deliveryAddress,
                prefixIcon: const Icon(Icons.location_on_outlined),
              ),
              maxLines: 2,
              validator: (v) => v?.trim().isEmpty == true ? l10n.required : null,
            ),
            const SizedBox(height: 24),
            Text(l10n.paymentType, style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            SegmentedButton<PaymentType>(
              segments: [
                ButtonSegment(value: PaymentType.cash, label: Text(l10n.cash), icon: const Icon(Icons.money)),
                ButtonSegment(value: PaymentType.card, label: Text(l10n.card), icon: const Icon(Icons.credit_card)),
                ButtonSegment(value: PaymentType.online, label: Text(l10n.online), icon: const Icon(Icons.payment)),
              ],
              selected: {_paymentType},
              onSelectionChanged: (s) => setState(() => _paymentType = s.first),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.foodItems, style: theme.textTheme.titleSmall),
                TextButton.icon(
                  onPressed: _showAddItemDialog,
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(l10n.addItem),
                ),
              ],
            ),
            if (_items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  l10n.addAtLeastOneItem,
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13),
                ),
              ),
            ..._items.asMap().entries.map(
                  (e) => ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      radius: 16,
                      child: Text('${e.value.quantity}', style: const TextStyle(fontSize: 12)),
                    ),
                    title: Text(e.value.name),
                    subtitle: Text('\$${e.value.price.toStringAsFixed(2)}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                      onPressed: () => setState(() => _items.removeAt(e.key)),
                    ),
                  ),
                ),
            const SizedBox(height: 32),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else
              FilledButton(onPressed: _submit, child: Text(l10n.submitOrder)),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
