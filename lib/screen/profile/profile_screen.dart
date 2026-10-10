import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../getx_controller/app_controller.dart';
import '../../models/currency_model.dart';
import '../../models/user_model.dart';
import '../../utils/app_theme.dart';
import '../../widget/app_scaffold.dart';
import '../../widget/app_sheets.dart';
import '../../widget/money_field.dart';
import '../../widget/primary_button.dart';

/// Edit the profile: name, optional email, currency and daily limit.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _limit = TextEditingController();

  late CurrencyModel _currency;
  bool _saving = false;

  AppController get _app => Get.find<AppController>();

  @override
  void initState() {
    super.initState();
    final UserModel user = _app.user.value;
    _name.text = user.name;
    _email.text = user.email;
    final double l = user.dailyLimit;
    _limit.text = l <= 0
        ? ''
        : (l == l.roundToDouble() ? l.toStringAsFixed(0) : l.toString());
    _currency = CurrencyModel.byCode(user.currencyCode);
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _limit.dispose();
    super.dispose();
  }

  bool get _emailValid =>
      _email.text.trim().isEmpty || GetUtils.isEmail(_email.text.trim());

  double get _limitValue =>
      double.tryParse(_limit.text.replaceAll(',', '.')) ?? 0;

  bool get _canSave =>
      _name.text.trim().isNotEmpty && _emailValid && _limitValue > 0;

  Future<void> _save() async {
    setState(() => _saving = true);
    await _app.saveUser(
      _app.user.value.copyWith(
        name: _name.text.trim(),
        email: _email.text.trim(),
        currencyCode: _currency.code,
        dailyLimit: _limitValue,
      ),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    Get.back<void>();
    showToast('profile_saved'.tr);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return AppScaffold(
      title: 'edit_profile'.tr,
      bottom: PrimaryButton(
        label: 'save'.tr,
        loading: _saving,
        onPressed: _canSave ? _save : null,
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 8, bottom: 24),
        children: <Widget>[
          Center(
            child: Container(
              width: 84,
              height: 84,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: p.heroGradient,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Text(
                _name.text.trim().isEmpty
                    ? '🙂'
                    : _name.text.trim().characters.first.toUpperCase(),
                style: context.text.displaySmall?.copyWith(color: p.accent),
              ),
            ),
          ),
          const SizedBox(height: 28),
          AppTextField(
            label: 'name'.tr,
            hint: 'name_hint'.tr,
            icon: Icons.person_outline_rounded,
            controller: _name,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 18),
          AppTextField(
            label: 'email_optional'.tr,
            hint: 'email_hint'.tr,
            icon: Icons.alternate_email_rounded,
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            errorText: _emailValid ? null : 'email_invalid'.tr,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 18),
          AppPickerField(
            label: 'currency'.tr,
            value: '${_currency.name} (${_currency.code})',
            leading: Text(_currency.flag, style: const TextStyle(fontSize: 20)),
            onTap: () async {
              final CurrencyModel? picked =
                  await showCurrencySheet(context, selected: _currency);
              if (picked != null) setState(() => _currency = picked);
            },
          ),
          const SizedBox(height: 18),
          AppTextField(
            label: 'daily_limit'.tr,
            hint: '50',
            prefixText: '${_currency.symbol}  ',
            controller: _limit,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: amountFormatters,
            onChanged: (_) => setState(() {}),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 6, top: 6),
            child: Text('daily_limit_help'.tr, style: context.text.bodySmall),
          ),
        ],
      ),
    );
  }
}
