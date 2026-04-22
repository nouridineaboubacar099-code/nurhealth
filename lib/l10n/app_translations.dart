// ============================================================
//  NurHealth — Système de Traductions
//  lib/l10n/app_translations.dart
// ============================================================

enum AppLangue { francais, anglais, haoussa }

class AppTranslations {
  final AppLangue langue;
  const AppTranslations(this.langue);

  // ── Navigation ───────────────────────────────────────────
  String get navAccueil => _t('Accueil', 'Home', 'Gida');
  String get navPrieres => _t('Prières', 'Prayers', 'Addu\'a');
  String get navSante   => _t('Santé', 'Health', 'Lafiya');
  String get navConsult => _t('Consultation', 'Consultation', 'Shawara');
  String get navBiblio  => _t('Bibliothèque', 'Library', 'Laburare');
  String get navCarte   => _t('Carte', 'Map', 'Taswirar Kasa');

  // ── Accueil ──────────────────────────────────────────────
  String get accueilBonjour    => _t('Assalamu Alaikum', 'Assalamu Alaikum', 'Assalamu Alaikum');
  String get accueilSousTitre  => _t('Votre compagnon de santé islamique', 'Your Islamic health companion', 'Abokinka na lafiya na Musulunci');
  String get accueilPriereDuJour => _t('Prière du moment', 'Current Prayer', 'Sallah ta yanzu');
  String get accueilSadaqa     => _t('Sadaqa du jour', 'Today\'s Sadaqa', 'Sadakar yau');
  String get accueilDonner     => _t('Donner maintenant', 'Donate now', 'Ba da gudummawa yanzu');
  String get accueilArticles   => _t('Articles santé', 'Health articles', 'Labarun lafiya');
  String get accueilVoirPlus   => _t('Voir plus', 'See more', 'Duba ƙari');

  // ── Prières ──────────────────────────────────────────────
  String get prieresFajr    => _t('Fajr', 'Fajr', 'Asuba');
  String get prieresDohr    => _t('Dhuhr', 'Dhuhr', 'Azahar');
  String get prieresAsr     => _t('Asr', 'Asr', 'Lasar');
  String get prieresMaghrib => _t('Maghrib', 'Maghrib', 'Magariba');
  String get prieresIcha    => _t('Icha', 'Isha', 'Lisha');
  String get prieresQibla   => _t('Direction Qibla', 'Qibla Direction', 'Alkibla');
  String get prieresCalendrier => _t('Calendrier des prières', 'Prayer calendar', 'Jadawalin sallah');
  String get prieresNotification => _t('Rappels activés', 'Reminders on', 'An kunna tunatarwa');
  String get prochainePriere => _t('Prochaine prière', 'Next prayer', 'Sallah ta gaba');
  String get resteTemps     => _t('Temps restant', 'Time remaining', 'Lokaci da ya rage');

  // ── Santé ────────────────────────────────────────────────
  String get santeTitre         => _t('Mon Espace Santé', 'My Health Space', 'Yankin Lafiyata');
  String get santeBMI           => _t('Calcul IMC', 'BMI Calculator', 'Lissafin BMI');
  String get santePoids         => _t('Poids (kg)', 'Weight (kg)', 'Nauyi (kg)');
  String get santeTaille        => _t('Taille (cm)', 'Height (cm)', 'Tsayi (cm)');
  String get santeCalculer      => _t('Calculer', 'Calculate', 'Lissafa');
  String get santeMedProphetique => _t('Médecine Prophétique', 'Prophetic Medicine', 'Magunguna na Annabi');
  String get santeArticles      => _t('Articles de santé', 'Health articles', 'Labarun lafiya');
  String get santeNormal        => _t('Normal', 'Normal', 'Al\'ada');
  String get santeSurpoids      => _t('Surpoids', 'Overweight', 'Kiba');
  String get santeMaigre        => _t('Insuffisance pondérale', 'Underweight', 'Rashin nauyi');
  String get santeObesité       => _t('Obésité', 'Obesity', 'Ciwo na kiba');

  // ── Consultation ─────────────────────────────────────────
  String get consultTitre       => _t('Consultation Médicale', 'Medical Consultation', 'Shawara ta Likita');
  String get consultMedecins    => _t('Nos médecins', 'Our doctors', 'Likitanmu');
  String get consultPrendre     => _t('Prendre RDV', 'Book appointment', 'Ɗauki alƙawari');
  String get consultDisponible  => _t('Disponible', 'Available', 'Yana nan');
  String get consultOccupe      => _t('Occupé', 'Busy', 'Yana da aiki');
  String get consultTeleconsult => _t('Téléconsultation', 'Teleconsultation', 'Shawarar nesa');
  String get consultUrgence     => _t('Urgence', 'Emergency', 'Gaggawa');
  String get consultConfirmer   => _t('Confirmer', 'Confirm', 'Tabbatar');
  String get consultAnnuler     => _t('Annuler', 'Cancel', 'Soke');

  // ── Bibliothèque ─────────────────────────────────────────
  String get biblioTitre        => _t('Bibliothèque Islamique', 'Islamic Library', 'Laburaren Musulunci');
  String get biblioNawawi       => _t('40 Hadiths An-Nawawi', '40 Hadiths An-Nawawi', 'Hadisai 40 na Nawawi');
  String get biblioRiyad        => _t('Riyad As-Salihin', 'Riyad As-Salihin', 'Riyad As-Salihin');
  String get biblioBulugh       => _t('Bulugh Al-Maram', 'Bulugh Al-Maram', 'Bulugh Al-Maram');
  String get biblioFiqh         => _t('Fiqh 4 Madhhabs', 'Fiqh 4 Schools', 'Fiqhu Mazhabobi 4');
  String get biblioQuran        => _t('Saint Coran', 'Holy Quran', 'Alƙur\'ani Mai Tsarki');
  String get biblioRecherche    => _t('Rechercher...', 'Search...', 'Bincika...');
  String get biblioChapitre     => _t('Chapitre', 'Chapter', 'Babi');
  String get biblioHadith       => _t('Hadith', 'Hadith', 'Hadisi');
  String get biblioLecon        => _t('Leçon', 'Lesson', 'Darasi');
  String get biblioSource       => _t('Source', 'Source', 'Tushe');

  // ── Carte ────────────────────────────────────────────────
  String get carteTitre         => _t('Carte NurHealth', 'NurHealth Map', 'Taswirar NurHealth');
  String get carteNiger         => _t('Niger', 'Niger', 'Nijar');
  String get carteZinder        => _t('Zinder', 'Zinder', 'Zinder');
  String get carteMaPosition    => _t('Ma position', 'My location', 'Wurina');
  String get carteEnvoyer       => _t('Envoyer au livreur', 'Send to delivery', 'Aika zuwa mai isarwa');
  String get carteQuartiers     => _t('Quartiers', 'Neighborhoods', 'Unguwanni');
  String get carteSante         => _t('Santé', 'Health', 'Lafiya');
  String get carteHopital       => _t('Hôpital', 'Hospital', 'Asibiti');
  String get cartePharmacie     => _t('Pharmacie', 'Pharmacy', 'Magunguna');
  String get carteLocalisation  => _t('Localisation...', 'Locating...', 'Ana nema...');

  // ── Tasbih / Dhikr ───────────────────────────────────────
  String get tasbihTitre        => _t('Tasbih Digital', 'Digital Tasbih', 'Tasbih na Dijital');
  String get tasbihCompteur     => _t('Compteur', 'Counter', 'Kidaya');
  String get tasbihReset        => _t('Réinitialiser', 'Reset', 'Sake saita');
  String get tasbihSubhanallah  => _t('Subhan Allah', 'Subhan Allah', 'Subhan Allah');
  String get tasbihAlhamdulillah => _t('Al-Hamdulillah', 'Al-Hamdulillah', 'Al-Hamdulillah');
  String get tasbihAllahuAkbar  => _t('Allahu Akbar', 'Allahu Akbar', 'Allahu Akbar');
  String get dhikrMatin         => _t('Adhkar du matin', 'Morning Adhkar', 'Azkarin safe');
  String get dhikrSoir          => _t('Adhkar du soir', 'Evening Adhkar', 'Azkarin yamma');

  // ── Général ──────────────────────────────────────────────
  String get genChargement      => _t('Chargement...', 'Loading...', 'Ana lodawa...');
  String get genErreur          => _t('Erreur', 'Error', 'Kuskure');
  String get genSucces          => _t('Succès', 'Success', 'Nasara');
  String get genFermer          => _t('Fermer', 'Close', 'Rufe');
  String get genRetour          => _t('Retour', 'Back', 'Koma');
  String get genSauvegarder     => _t('Sauvegarder', 'Save', 'Adana');
  String get genPartager        => _t('Partager', 'Share', 'Raba');
  String get genCopier          => _t('Copier', 'Copy', 'Kwafi');
  String get genWhatsApp        => _t('WhatsApp', 'WhatsApp', 'WhatsApp');
  String get genSMS             => _t('SMS', 'SMS', 'SMS');
  String get genOui             => _t('Oui', 'Yes', 'Ee');
  String get genNon             => _t('Non', 'No', 'A\'a');
  String get genConnexion       => _t('Connexion', 'Login', 'Shiga');
  String get genInscription     => _t('Inscription', 'Register', 'Yi rajista');
  String get genNom             => _t('Nom', 'Name', 'Suna');
  String get genEmail           => _t('Email', 'Email', 'Imel');
  String get genMotDePasse      => _t('Mot de passe', 'Password', 'Kalmar sirri');
  String get genTelephone       => _t('Téléphone', 'Phone', 'Wayar tarho');

  // ── Paramètres ───────────────────────────────────────────
  String get paramTitre         => _t('Paramètres', 'Settings', 'Saitunan');
  String get paramLangue        => _t('Langue', 'Language', 'Harshe');
  String get paramNotifications => _t('Notifications', 'Notifications', 'Sanarwa');
  String get paramTheme         => _t('Thème', 'Theme', 'Jigo');
  String get paramAPropos       => _t('À propos', 'About', 'Game da mu');
  String get paramFrancais      => _t('Français', 'French', 'Faransanci');
  String get paramAnglais       => _t('Anglais', 'English', 'Turanci');
  String get paramHaoussa       => _t('Haoussa', 'Hausa', 'Hausa');

  // ── Méthode interne ──────────────────────────────────────
  String _t(String fr, String en, String ha) {
    switch (langue) {
      case AppLangue.francais: return fr;
      case AppLangue.anglais:  return en;
      case AppLangue.haoussa:  return ha;
    }
  }
}

// ── Provider global de langue (à utiliser avec setState ou Provider) ──
class LangueManager {
  static AppLangue _langue = AppLangue.francais;

  static AppLangue get langue => _langue;
  static AppTranslations get t => AppTranslations(_langue);

  static void changer(AppLangue nouvelle) {
    _langue = nouvelle;
  }

  static String get nomLangue {
    switch (_langue) {
      case AppLangue.francais: return '🇫🇷 Français';
      case AppLangue.anglais:  return '🇬🇧 English';
      case AppLangue.haoussa:  return '🇳🇪 Hausa';
    }
  }

  static String get codeLangue {
    switch (_langue) {
      case AppLangue.francais: return 'fr';
      case AppLangue.anglais:  return 'en';
      case AppLangue.haoussa:  return 'ha';
    }
  }
}
