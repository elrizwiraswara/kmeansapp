import 'package:flutter/material.dart';
import 'package:kmeansapp/config/app_config.dart';
import 'package:kmeansapp/theme/theme.dart';

class LoginDialog extends StatelessWidget {
  const LoginDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController username = TextEditingController();
    TextEditingController password = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.loose,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(color: Colors.transparent),
          ),
          Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              constraints: BoxConstraints(
                maxWidth: 400,
                maxHeight: 302,
              ),
              padding: EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppColors.blackLv2,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Login Admin',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'login sebagai admin untuk dapat memperbarui data',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white54,
                    ),
                  ),
                  SizedBox(height: 28),
                  TextField(
                    controller: username,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.87),
                    ),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 16,
                      ),
                      filled: true,
                      fillColor: AppColors.blackLv1.withOpacity(0.84),
                      hintText: 'username',
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: Colors.white24,
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: password,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.87),
                    ),
                    obscureText: true,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 16,
                      ),
                      filled: true,
                      fillColor: AppColors.blackLv1.withOpacity(0.84),
                      hintText: 'password',
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: Colors.white24,
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  SizedBox(height: 28),
                  GestureDetector(
                    onTap: () {
                      if (username.text.isNotEmpty &&
                          password.text.isNotEmpty) {
                        if (username.text == AppConfig.admin.username &&
                            password.text == AppConfig.admin.password) {
                          AppConfig.user = AppConfig.admin;
                          username.clear();
                          password.clear();

                          Navigator.pop(context, 'success');
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              behavior: SnackBarBehavior.floating,
                              margin: EdgeInsets.all(18),
                              content: Text(
                                'Username atau password salah!',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontFamily: 'Montserrat'),
                              ),
                            ),
                          );
                        }
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(14),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.blackLv3.withOpacity(0.87),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LogoutDialog extends StatelessWidget {
  const LogoutDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 400,
        ),
        padding: EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: AppColors.blackLv2,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Logout Admin',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'apakah kamu yakin ingin keluar akun?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white60,
              ),
            ),
            SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: EdgeInsets.all(14),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.blackLv3.withOpacity(0.84),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Batal',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 18),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      AppConfig.user = null;
                      Navigator.pop(context, 'success');
                    },
                    child: Container(
                      padding: EdgeInsets.all(14),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.blackLv3.withOpacity(0.54),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
