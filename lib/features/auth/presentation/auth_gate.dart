import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hareup_design_system/design_system.dart';
import '../domain/auth_repository.dart';
import 'auth_cubit.dart';

/// Restores the Firebase session before showing the app or email auth form.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key, required this.signedInBuilder});
  final Widget Function(BuildContext context, AuthSession session)
  signedInBuilder;

  @override
  Widget build(BuildContext context) => BlocBuilder<AuthCubit, AuthState>(
    builder: (context, state) {
      if (!state.initialized) {
        return const Scaffold(body: HareupLoading());
      }
      final session = state.session;
      if (session != null) {
        return KeyedSubtree(
          key: ValueKey(session.userId),
          child: signedInBuilder(context, session),
        );
      }
      return const _EmailAuthPage();
    },
  );
}

class _EmailAuthPage extends StatefulWidget {
  const _EmailAuthPage();
  @override
  State<_EmailAuthPage> createState() => _EmailAuthPageState();
}

class _EmailAuthPageState extends State<_EmailAuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _creatingAccount = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: HareupContent(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: HareupSpacing.pageMargin,
            vertical: HareupSpacing.medium,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: HareupSpacing.maxContentWidth,
            ),
            child: Form(
              key: _formKey,
              child: BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(
                      child: CircleAvatar(
                        radius: 36,
                        backgroundColor: HareupColors.primary100,
                        child: Icon(
                          Icons.pets,
                          size: 36,
                          color: HareupColors.primary700,
                        ),
                      ),
                    ),
                    const SizedBox(height: HareupSpacing.medium),
                    Text(
                      '하릅 Hareup',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: HareupSpacing.small),
                    Text(
                      _creatingAccount
                          ? '함께 돌보는 가족을 위한 계정을 만들어 주세요.'
                          : '매일 사진으로 기록하고 함께 살피는 반려동물 건강 케어',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: HareupSpacing.large),
                    for (final provider in _orderedProviders(context)) ...[
                      OutlinedButton.icon(
                        style: _providerStyle(provider.id),
                        onPressed: state.working
                            ? null
                            : () => context
                                  .read<AuthCubit>()
                                  .signInWithProvider(provider.id),
                        icon: Icon(_providerIcon(provider.id)),
                        label: Text(provider.label),
                      ),
                      const SizedBox(height: HareupSpacing.small),
                    ],
                    if (context
                        .read<AuthCubit>()
                        .repository
                        .providers
                        .isNotEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: HareupSpacing.small,
                        ),
                        child: Center(child: Text('또는 이메일로 계속')),
                      ),
                    if (_creatingAccount) ...[
                      TextFormField(
                        controller: _name,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(labelText: '이름 (선택)'),
                        maxLength: 60,
                      ),
                      const SizedBox(height: HareupSpacing.small),
                    ],
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(labelText: '이메일'),
                      validator: (value) {
                        final email = value?.trim() ?? '';
                        return email.contains('@') && email.contains('.')
                            ? null
                            : '이메일 주소를 확인해 주세요.';
                      },
                    ),
                    const SizedBox(height: HareupSpacing.small),
                    TextFormField(
                      controller: _password,
                      obscureText: true,
                      autofillHints: [
                        _creatingAccount
                            ? AutofillHints.newPassword
                            : AutofillHints.password,
                      ],
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(context),
                      decoration: const InputDecoration(labelText: '비밀번호'),
                      validator: (value) => (value?.length ?? 0) >= 6
                          ? null
                          : '비밀번호를 6자 이상 입력해 주세요.',
                    ),
                    if (state.failure case final failure?) ...[
                      const SizedBox(height: HareupSpacing.medium),
                      Text(
                        failure.message,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                    const SizedBox(height: HareupSpacing.large),
                    FilledButton(
                      onPressed: state.working ? null : () => _submit(context),
                      child: state.working
                          ? const HareupLoading()
                          : Text(_creatingAccount ? '가입하기' : '로그인'),
                    ),
                    TextButton(
                      onPressed: state.working
                          ? null
                          : () => setState(
                              () => _creatingAccount = !_creatingAccount,
                            ),
                      child: Text(
                        _creatingAccount ? '이미 계정이 있나요? 로그인' : '계정이 없나요? 가입하기',
                      ),
                    ),
                    if (!state.initialized && state.failure != null)
                      TextButton(
                        onPressed: state.working
                            ? null
                            : () => context.read<AuthCubit>().start(),
                        child: const Text('세션 다시 확인'),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );

  Future<void> _submit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    final cubit = context.read<AuthCubit>();
    if (_creatingAccount) {
      await cubit.signUp(
        email: _email.text,
        password: _password.text,
        displayName: _name.text,
      );
    } else {
      await cubit.signIn(email: _email.text, password: _password.text);
    }
  }

  List<AuthProviderOption> _orderedProviders(BuildContext context) {
    const order = {'kakao': 0, 'apple': 1, 'google': 2};
    return [...context.read<AuthCubit>().repository.providers]
      ..sort((a, b) => (order[a.id] ?? 3).compareTo(order[b.id] ?? 3));
  }

  ButtonStyle? _providerStyle(String id) {
    final (background, foreground) = switch (id) {
      'kakao' => (const Color(0xfffee500), const Color(0xff191919)),
      'apple' => (const Color(0xff000000), HareupColors.neutral0),
      'google' => (HareupColors.neutral0, HareupColors.neutral900),
      _ => (null, null),
    };
    if (background == null || foreground == null) return null;
    return OutlinedButton.styleFrom(
      backgroundColor: background,
      foregroundColor: foreground,
      disabledBackgroundColor: HareupColors.neutral100,
      disabledForegroundColor: HareupColors.neutral400,
      side: BorderSide(
        color: id == 'google' ? HareupColors.neutral200 : background,
      ),
      minimumSize: const Size(48, 52),
    );
  }

  IconData _providerIcon(String id) => switch (id) {
    'google' => Icons.g_mobiledata,
    'apple' => Icons.apple,
    'kakao' => Icons.chat_bubble_outline,
    _ => Icons.login,
  };
}
