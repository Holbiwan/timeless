import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeless/common/widgets/timeless_components.dart';
import 'package:timeless/utils/color_res.dart';
import 'package:timeless/utils/app_dimensions.dart';
import 'package:timeless/utils/app_style.dart';

// Exemple d'écran de connexion modernisé avec les nouveaux composants
// Design optimisé : formulaire qui tient sur une page, couleurs harmonisées
class SignInModernScreen extends StatefulWidget {
  const SignInModernScreen({super.key});

  @override
  State<SignInModernScreen> createState() => _SignInModernScreenState();
}

class _SignInModernScreenState extends State<SignInModernScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isObscured = true;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return TimelessPageContainer(
      backgroundColor: ColorRes.backgroundColor,
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: AppDimensions.mega),
            
            // Logo et titre
            _buildHeader(),
            
            SizedBox(height: AppDimensions.huge),
            
            // Formulaire de connexion
            _buildSignInForm(),
            
            SizedBox(height: AppDimensions.xxxl),
            
            // Options alternatives
            _buildAlternativeOptions(),
            
            SizedBox(height: AppDimensions.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Logo placé ici si nécessaire
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: ColorRes.primaryBlue,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.work,
            size: AppDimensions.iconSizeXLarge,
            color: ColorRes.white,
          ),
        ),
        
        SizedBox(height: AppDimensions.xl),
        
        Text(
          'Connexion',
          style: AppTextStyles.h2,
        ),
        
        SizedBox(height: AppDimensions.sm),
        
        Text(
          'Accédez à votre espace Timeless',
          style: AppTextStyles.bodyMedium.copyWith(
            color: ColorRes.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSignInForm() {
    return TimelessForm(
      title: null, // Titre déjà affiché en haut
      children: [
        TimelessTextField(
          label: 'Email',
          hintText: 'votre.email@example.com',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icon(
            Icons.email_outlined,
            color: ColorRes.textTertiary,
            size: AppDimensions.iconSizeMedium,
          ),
        ),
        
        TimelessTextField(
          label: 'Mot de passe',
          hintText: 'Saisissez votre mot de passe',
          controller: _passwordController,
          obscureText: _isObscured,
          prefixIcon: Icon(
            Icons.lock_outline,
            color: ColorRes.textTertiary,
            size: AppDimensions.iconSizeMedium,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _isObscured ? Icons.visibility_off : Icons.visibility,
              color: ColorRes.textTertiary,
            ),
            onPressed: () => setState(() => _isObscured = !_isObscured),
          ),
        ),
        
        // Lien mot de passe oublié
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              // Navigation vers reset password
            },
            child: Text(
              'Mot de passe oublié ?',
              style: AppTextStyles.linkText.copyWith(
                fontSize: AppDimensions.fontSizeSM,
              ),
            ),
          ),
        ),
      ],
      submitButton: Column(
        children: [
          TimelessButton(
            text: 'Se connecter',
            onPressed: _isLoading ? null : _handleSignIn,
            isLoading: _isLoading,
            icon: Icons.login,
          ),
          
          SizedBox(height: AppDimensions.md),
          
          TimelessButton(
            text: 'Connexion avec Google',
            onPressed: _handleGoogleSignIn,
            isSecondary: true,
            icon: Icons.g_mobiledata, // Remplacer par l'icône Google si disponible
          ),
        ],
      ),
    );
  }

  Widget _buildAlternativeOptions() {
    return Column(
      children: [
        // Séparateur
        Row(
          children: [
            Expanded(child: Divider(color: ColorRes.dividerColor)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppDimensions.md),
              child: Text(
                'ou',
                style: AppTextStyles.caption,
              ),
            ),
            Expanded(child: Divider(color: ColorRes.dividerColor)),
          ],
        ),
        
        SizedBox(height: AppDimensions.lg),
        
        // Navigation vers inscription
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Pas encore de compte ? ',
              style: AppTextStyles.bodyMedium,
            ),
            GestureDetector(
              onTap: () {
                // Navigation vers sign up
              },
              child: Text(
                'Créer un compte',
                style: AppTextStyles.linkText,
              ),
            ),
          ],
        ),
        
        SizedBox(height: AppDimensions.lg),
        
        // Connexion employeur
        TimelessCard(
          backgroundColor: ColorRes.primaryOrange.withOpacity(0.1),
          child: Row(
            children: [
              Icon(
                Icons.business,
                color: ColorRes.primaryOrange,
                size: AppDimensions.iconSizeLarge,
              ),
              SizedBox(width: AppDimensions.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vous êtes recruteur ?',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: ColorRes.primaryOrange,
                      ),
                    ),
                    Text(
                      'Accédez à votre espace pro',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward,
                color: ColorRes.primaryOrange,
                size: AppDimensions.iconSizeMedium,
              ),
            ],
          ),
          onTap: () {
            // Navigation vers connexion employeur
          },
        ),
      ],
    );
  }

  void _handleSignIn() async {
    setState(() => _isLoading = true);
    
    // Simulation de la connexion
    await Future.delayed(Duration(seconds: 2));
    
    setState(() => _isLoading = false);
    
    // Navigation ou affichage d'erreur
    Get.snackbar(
      'Succès',
      'Connexion réussie !',
      backgroundColor: ColorRes.primaryBlue.withOpacity(0.1),
      colorText: ColorRes.primaryBlue,
    );
  }

  void _handleGoogleSignIn() {
    // Logique de connexion Google
    Get.snackbar(
      'Info',
      'Connexion Google en cours...',
      backgroundColor: ColorRes.primaryOrange.withOpacity(0.1),
      colorText: ColorRes.primaryOrange,
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}