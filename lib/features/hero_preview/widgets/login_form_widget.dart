import 'package:flutter/material.dart';
import 'package:self_improvement_app/ui/core/style_tokens.dart';

enum LoginFormStyle {
  glassmorphism,
  vintageHighway,
  modernSaaS,
}

class LoginFormWidget extends StatefulWidget {
  final StyleTokens tokens;
  final LoginFormStyle style;
  final VoidCallback? onLoginSuccess;
  final String title;
  final String subtitle;
  final Color? customCardBg;
  final Color? customBorderColor;
  final Color? customAccentColor;
  final Color? customTextColor;

  const LoginFormWidget({
    super.key,
    required this.tokens,
    this.style = LoginFormStyle.modernSaaS,
    this.onLoginSuccess,
    this.title = 'Station Portal Sign In',
    this.subtitle = 'Enter your operator credentials to access ERP features',
    this.customCardBg,
    this.customBorderColor,
    this.customAccentColor,
    this.customTextColor,
  });

  @override
  State<LoginFormWidget> createState() => _LoginFormWidgetState();
}

class _LoginFormWidgetState extends State<LoginFormWidget> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  bool _obscurePassword = true;
  String? _errorMessage;
  bool _isLoading = false;
  bool _isSuccess = false;

  @override
  void dispose() {
    _userController.dispose();
    _passController.dispose();
    super.dispose();
  }

  void _quickFill() {
    setState(() {
      _userController.text = 'Admin';
      _passController.text = 'Admin';
      _errorMessage = null;
    });
  }

  void _handleLogin() async {
    final username = _userController.text.trim();
    final password = _passController.text.trim();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    await Future.delayed(const Duration(milliseconds: 350));

    if (!mounted) return;

    if (username.toLowerCase() == 'admin' && password == 'Admin') {
      setState(() {
        _isLoading = false;
        _isSuccess = true;
      });
      if (widget.onLoginSuccess != null) {
        widget.onLoginSuccess!();
      }
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Invalid credentials. Use username "Admin" and password "Admin".';
      });
    }
  }

  void _resetForm() {
    setState(() {
      _userController.clear();
      _passController.clear();
      _errorMessage = null;
      _isSuccess = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = widget.tokens;
    final primaryAccent = widget.customAccentColor ?? tokens.accent;
    final textColor = widget.customTextColor ?? tokens.textMain;

    BoxDecoration decoration;
    switch (widget.style) {
      case LoginFormStyle.glassmorphism:
        decoration = BoxDecoration(
          color: widget.customCardBg ?? const Color(0xFF1E293B).withOpacity(0.85),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.customBorderColor ?? Colors.tealAccent.withOpacity(0.4),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: Colors.tealAccent.withOpacity(0.08),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        );
        break;
      case LoginFormStyle.vintageHighway:
        decoration = BoxDecoration(
          color: widget.customCardBg ?? const Color(0xFFFFFDF9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: widget.customBorderColor ?? const Color(0xFFC7462B),
            width: 2.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0x334A2E1A),
              blurRadius: 16,
              offset: const Offset(4, 6),
            ),
          ],
        );
        break;
      case LoginFormStyle.modernSaaS:
      default:
        decoration = BoxDecoration(
          color: widget.customCardBg ?? tokens.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: widget.customBorderColor ?? tokens.border.withOpacity(0.6),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: tokens.shadowColor.withOpacity(0.12),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        );
        break;
    }

    return Container(
      constraints: const BoxConstraints(maxWidth: 420),
      decoration: decoration,
      padding: const EdgeInsets.all(28),
      child: _isSuccess ? _buildSuccessView(tokens, primaryAccent) : _buildFormView(tokens, primaryAccent, textColor),
    );
  }

  Widget _buildFormView(StyleTokens tokens, Color primaryAccent, Color textColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Title & Subtitle
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryAccent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.lock_person_outlined, color: primaryAccent, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontFamily: widget.style == LoginFormStyle.vintageHighway
                          ? tokens.serifFont
                          : tokens.sansFont,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: widget.style == LoginFormStyle.glassmorphism
                          ? Colors.white
                          : tokens.textHeader,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.subtitle,
                    style: TextStyle(
                      fontFamily: tokens.sansFont,
                      fontSize: 12,
                      color: widget.style == LoginFormStyle.glassmorphism
                          ? Colors.white70
                          : textColor.withOpacity(0.75),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Quick-Fill Demo Helper Pill
        InkWell(
          onTap: _quickFill,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: primaryAccent.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: primaryAccent.withOpacity(0.3),
                style: BorderStyle.solid,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.bolt, size: 16, color: primaryAccent),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'Quick Fill Demo (Admin / Admin)',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: tokens.monoFont,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: primaryAccent,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 18),

        // Username Field
        Text(
          'Username',
          style: TextStyle(
            fontFamily: tokens.sansFont,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: widget.style == LoginFormStyle.glassmorphism ? const Color(0xE6FFFFFF) : textColor,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _userController,
          style: TextStyle(
            fontFamily: tokens.sansFont,
            color: widget.style == LoginFormStyle.glassmorphism ? Colors.white : tokens.textMain,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: 'e.g. Admin',
            hintStyle: TextStyle(
              color: widget.style == LoginFormStyle.glassmorphism ? Colors.white38 : tokens.textMain.withOpacity(0.4),
              fontSize: 13,
            ),
            prefixIcon: Icon(
              Icons.person_outline,
              size: 18,
              color: widget.style == LoginFormStyle.glassmorphism ? Colors.white70 : tokens.textMain.withOpacity(0.6),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            filled: true,
            fillColor: widget.style == LoginFormStyle.glassmorphism
                ? Colors.white.withOpacity(0.08)
                : tokens.background.withOpacity(0.6),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: tokens.border.withOpacity(0.4)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: tokens.border.withOpacity(0.4)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: primaryAccent, width: 1.5),
            ),
          ),
          onSubmitted: (_) => _handleLogin(),
        ),

        const SizedBox(height: 14),

        // Password Field
        Text(
          'Password',
          style: TextStyle(
            fontFamily: tokens.sansFont,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: widget.style == LoginFormStyle.glassmorphism ? const Color(0xE6FFFFFF) : textColor,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _passController,
          obscureText: _obscurePassword,
          style: TextStyle(
            fontFamily: tokens.sansFont,
            color: widget.style == LoginFormStyle.glassmorphism ? Colors.white : tokens.textMain,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: '••••••••',
            hintStyle: TextStyle(
              color: widget.style == LoginFormStyle.glassmorphism ? Colors.white38 : tokens.textMain.withOpacity(0.4),
              fontSize: 13,
            ),
            prefixIcon: Icon(
              Icons.lock_outline,
              size: 18,
              color: widget.style == LoginFormStyle.glassmorphism ? Colors.white70 : tokens.textMain.withOpacity(0.6),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                size: 18,
                color: widget.style == LoginFormStyle.glassmorphism ? Colors.white70 : tokens.textMain.withOpacity(0.6),
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            filled: true,
            fillColor: widget.style == LoginFormStyle.glassmorphism
                ? Colors.white.withOpacity(0.08)
                : tokens.background.withOpacity(0.6),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: tokens.border.withOpacity(0.4)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: tokens.border.withOpacity(0.4)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: primaryAccent, width: 1.5),
            ),
          ),
          onSubmitted: (_) => _handleLogin(),
        ),

        // Error message if any
        if (_errorMessage != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.12),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, size: 16, color: Colors.redAccent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 22),

        // Sign In Button
        ElevatedButton(
          onPressed: _isLoading ? null : _handleLogin,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryAccent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: widget.style == LoginFormStyle.glassmorphism ? 4 : 1,
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Sign In to ERP Portal',
                      style: TextStyle(
                        fontFamily: tokens.sansFont,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, size: 16),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildSuccessView(StyleTokens tokens, Color primaryAccent) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.greenAccent.withOpacity(0.15),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.greenAccent.withOpacity(0.6), width: 2),
          ),
          child: const Icon(Icons.check_circle_outline, color: Colors.green, size: 36),
        ),
        const SizedBox(height: 16),
        Text(
          'Authentication Verified',
          style: TextStyle(
            fontFamily: widget.style == LoginFormStyle.vintageHighway ? tokens.serifFont : tokens.sansFont,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: widget.style == LoginFormStyle.glassmorphism ? Colors.white : tokens.textHeader,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Welcome, Administrator. Full station operator permissions granted.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: tokens.sansFont,
            fontSize: 12,
            color: widget.style == LoginFormStyle.glassmorphism ? Colors.white70 : tokens.textMain.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 10,
          children: [
            OutlinedButton(
              onPressed: _resetForm,
              style: OutlinedButton.styleFrom(
                foregroundColor: widget.style == LoginFormStyle.glassmorphism ? Colors.white70 : tokens.textMain,
                side: BorderSide(
                  color: widget.style == LoginFormStyle.glassmorphism ? Colors.white30 : tokens.border,
                ),
              ),
              child: const Text('Sign Out / Reset'),
            ),
            ElevatedButton(
              onPressed: widget.onLoginSuccess,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryAccent,
                foregroundColor: Colors.white,
              ),
              child: const Text('Go to Live ERP'),
            ),
          ],
        ),
      ],
    );
  }
}
