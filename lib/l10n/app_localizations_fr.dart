// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'D-helper — Plateforme de livraison';

  @override
  String get deliveryPlatform => 'Plateforme de livraison';

  @override
  String get controlPanel => 'Panneau de contrôle';

  @override
  String get login => 'Connexion';

  @override
  String get enterBtn => 'Entrer';

  @override
  String get signInWithGoogle => 'Se connecter avec Google';

  @override
  String get welcome => 'Bienvenue';

  @override
  String get logout => 'Déconnexion';

  @override
  String get logoutTitle => 'Déconnexion';

  @override
  String get logoutConfirm => 'Voulez-vous vraiment quitter?';

  @override
  String get settings => 'Paramètres';

  @override
  String get language => 'Langue';

  @override
  String get profile => 'Profil';

  @override
  String get demoAccount => 'Compte démo';

  @override
  String get email => 'Email';

  @override
  String get passwordField => 'Mot de passe';

  @override
  String get forgotPassword => 'Mot de passe oublié?';

  @override
  String get recoverPassword => 'Récupérer le mot de passe';

  @override
  String get enterEmail => 'Entrez votre email';

  @override
  String get codeWillBeSent => 'Nous vous enverrons un code de vérification.';

  @override
  String get sendCode => 'Envoyer le code';

  @override
  String get enterCode => 'Entrez le code';

  @override
  String codeSentTo(String email) {
    return 'Code envoyé à $email';
  }

  @override
  String get demoMode => 'Mode démo';

  @override
  String get yourCode => 'Votre code:';

  @override
  String get sixDigitCode => 'Code à 6 chiffres';

  @override
  String get verifyCode => 'Vérifier';

  @override
  String get choosePassword => 'Choisissez un mot de passe sécurisé.';

  @override
  String get newPassword => 'Nouveau mot de passe';

  @override
  String get confirmPassword => 'Confirmer';

  @override
  String get savePassword => 'Enregistrer';

  @override
  String get passwordUpdated => 'Mot de passe mis à jour ✓';

  @override
  String get passwordsDontMatch => 'Les mots de passe ne correspondent pas';

  @override
  String get minPassword => 'Min. 6 caractères';

  @override
  String get fillAllFields => 'Remplissez tous les champs';

  @override
  String get emailNotFound => 'Email non trouvé';

  @override
  String get wrongCode => 'Code incorrect';

  @override
  String get dashboard => 'Tableau de bord';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get thisMonth => 'Ce mois';

  @override
  String get thisYear => 'Cette année';

  @override
  String get totalOrders => 'Total commandes';

  @override
  String get fromCalls => 'Appels';

  @override
  String get earnings => 'Revenus';

  @override
  String get avgDeliveryTime => 'Temps moyen';

  @override
  String get perDelivery => 'par livraison';

  @override
  String get avgPerOrder => 'Moy. / commande';

  @override
  String get ordersLast7Days => '7 derniers jours';

  @override
  String get cashVsCard => 'Espèces vs Carte';

  @override
  String get inProgress => 'En cours';

  @override
  String get callLabel => 'Appel';

  @override
  String get orders => 'Commandes';

  @override
  String get newOrder => 'Nouvelle commande';

  @override
  String get noOrdersYet => 'Aucune commande';

  @override
  String get createOrder => 'Créer commande';

  @override
  String get customerName => 'Nom du client';

  @override
  String get phoneNumber => 'Téléphone';

  @override
  String get deliveryAddress => 'Adresse de livraison';

  @override
  String get foodItems => 'Articles';

  @override
  String get addItem => 'Ajouter article';

  @override
  String get removeItem => 'Supprimer';

  @override
  String get itemName => 'Nom article';

  @override
  String get quantity => 'Quantité';

  @override
  String get price => 'Prix';

  @override
  String get paymentType => 'Mode paiement';

  @override
  String get cash => 'Espèces';

  @override
  String get card => 'Carte';

  @override
  String get online => 'En ligne';

  @override
  String get submitOrder => 'Soumettre';

  @override
  String get cancel => 'Annuler';

  @override
  String get confirm => 'Confirmer';

  @override
  String get save => 'Enregistrer';

  @override
  String get delete => 'Supprimer';

  @override
  String get loading => 'Chargement...';

  @override
  String get error => 'Une erreur s\'est produite';

  @override
  String get orderStatus => 'Statut';

  @override
  String get pending => 'En attente';

  @override
  String get accepted => 'Accepté';

  @override
  String get preparing => 'En préparation';

  @override
  String get ready => 'Prêt';

  @override
  String get pickedUp => 'Récupéré';

  @override
  String get delivered => 'Livré';

  @override
  String get rejected => 'Rejeté';

  @override
  String get all => 'Tous';

  @override
  String get orderDetails => 'Détails commande';

  @override
  String get orderCreated => 'Commande créée';

  @override
  String get addAtLeastOneItem => 'Ajoutez au moins un article';

  @override
  String get required => 'Obligatoire';

  @override
  String get mapTab => 'Carte';

  @override
  String get driversTab => 'Livreurs';

  @override
  String get restaurantsTab => 'Restaurants';

  @override
  String get addDriver => 'Ajouter livreur';

  @override
  String get addRestaurant => 'Ajouter restaurant';

  @override
  String get noDrivers => 'Aucun livreur';

  @override
  String get noRestaurants => 'Aucun restaurant';

  @override
  String get addFirstHint => 'Appuyez + pour ajouter';

  @override
  String get fullName => 'Nom complet';

  @override
  String get vehicleType => 'Véhicule';

  @override
  String get motorcycle => 'Moto';

  @override
  String get car => 'Voiture';

  @override
  String get bike => 'Vélo';

  @override
  String get onlineLabel => 'En ligne';

  @override
  String get offlineLabel => 'Hors ligne';

  @override
  String get deleteDriverTitle => 'Supprimer livreur';

  @override
  String get deleteRestaurantTitle => 'Supprimer restaurant';

  @override
  String confirmDelete(String name) {
    return 'Supprimer $name?';
  }

  @override
  String get restaurantLabel => 'Restaurant';

  @override
  String get restaurantName => 'Nom du restaurant';

  @override
  String get restaurantAddress => 'Adresse';

  @override
  String totalItems(int count) {
    return '$count articles';
  }
}
