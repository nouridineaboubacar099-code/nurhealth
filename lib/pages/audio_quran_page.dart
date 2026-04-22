// ============================================================
//  NurHealth — Audio Quran Complet
//  lib/pages/audio_quran_page.dart
//  Placer dans : lib/pages/
// ============================================================
//
//  DÉPENDANCES REQUISES dans pubspec.yaml :
//  dependencies:
//    just_audio: ^0.9.36
//    audio_session: ^0.1.18
//
//  PERMISSIONS Android (android/app/src/main/AndroidManifest.xml)
//  Ajouter avant <application :
//  <uses-permission android:name="android.permission.INTERNET"/>
//  <uses-permission android:name="android.permission.WAKE_LOCK"/>
//
// ============================================================

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

// ── Couleurs ─────────────────────────────────────────────
const Color kVert      = Color(0xFF1B5E20);
const Color kVertClair = Color(0xFF4CAF50);
const Color kOr        = Color(0xFFFFD700);
const Color kOrClair   = Color(0xFFFFF9C4);
const Color kBlanc     = Color(0xFFFFFFFF);
const Color kFond      = Color(0xFFF8F9FA);

// ============================================================
//  DONNÉES — 114 Sourates
// ============================================================
class Sourate {
  final int numero;
  final String nom;
  final String nomArabe;
  final String signification;
  final int versets;
  final String revelation; // mecquoise / médinoise

  const Sourate({
    required this.numero,
    required this.nom,
    required this.nomArabe,
    required this.signification,
    required this.versets,
    required this.revelation,
  });

  // URL audio Mishary Al-Afasy — CDN Islamic Network (fiable)
  String get urlAudio {
    final num = numero.toString().padLeft(3, '0');
    return 'https://cdn.islamic.network/quran/audio-surah/128/ar.alafasy/$num.mp3';
  }

  // URL audio alternative (EveryAyah)
  String get urlAudioAlt {
    final num = numero.toString().padLeft(3, '0');
    return 'https://download.quranicaudio.com/quran/mishaari_raashid_al_3afaasee/$num.mp3';
  }
}

const List<Sourate> sourates = [
  Sourate(numero: 1,   nom: 'Al-Fatiha',     nomArabe: 'الفاتحة',      signification: 'L\'Ouverture',          versets: 7,   revelation: 'Mecquoise'),
  Sourate(numero: 2,   nom: 'Al-Baqara',     nomArabe: 'البقرة',       signification: 'La Vache',              versets: 286, revelation: 'Médinoise'),
  Sourate(numero: 3,   nom: 'Al-Imran',      nomArabe: 'آل عمران',     signification: 'La Famille d\'Imran',   versets: 120, revelation: 'Médinoise'),
  Sourate(numero: 4,   nom: 'An-Nisa',       nomArabe: 'النساء',       signification: 'Les Femmes',            versets: 176, revelation: 'Médinoise'),
  Sourate(numero: 5,   nom: 'Al-Maida',      nomArabe: 'المائدة',      signification: 'La Table Servie',       versets: 120, revelation: 'Médinoise'),
  Sourate(numero: 6,   nom: 'Al-An\'am',     nomArabe: 'الأنعام',      signification: 'Les Bestiaux',          versets: 165, revelation: 'Mecquoise'),
  Sourate(numero: 7,   nom: 'Al-A\'raf',     nomArabe: 'الأعراف',      signification: 'Les Murailles',         versets: 206, revelation: 'Mecquoise'),
  Sourate(numero: 8,   nom: 'Al-Anfal',      nomArabe: 'الأنفال',      signification: 'Les Butins',            versets: 75,  revelation: 'Médinoise'),
  Sourate(numero: 9,   nom: 'At-Tawba',      nomArabe: 'التوبة',       signification: 'Le Repentir',           versets: 129, revelation: 'Médinoise'),
  Sourate(numero: 10,  nom: 'Yunus',         nomArabe: 'يونس',         signification: 'Jonas',                 versets: 109, revelation: 'Mecquoise'),
  Sourate(numero: 11,  nom: 'Hud',           nomArabe: 'هود',          signification: 'Hud',                   versets: 123, revelation: 'Mecquoise'),
  Sourate(numero: 12,  nom: 'Yusuf',         nomArabe: 'يوسف',         signification: 'Joseph',                versets: 111, revelation: 'Mecquoise'),
  Sourate(numero: 13,  nom: 'Ar-Ra\'d',      nomArabe: 'الرعد',        signification: 'Le Tonnerre',           versets: 43,  revelation: 'Médinoise'),
  Sourate(numero: 14,  nom: 'Ibrahim',       nomArabe: 'إبراهيم',      signification: 'Abraham',               versets: 52,  revelation: 'Mecquoise'),
  Sourate(numero: 15,  nom: 'Al-Hijr',       nomArabe: 'الحجر',        signification: 'Al-Hijr',               versets: 99,  revelation: 'Mecquoise'),
  Sourate(numero: 16,  nom: 'An-Nahl',       nomArabe: 'النحل',        signification: 'Les Abeilles',          versets: 128, revelation: 'Mecquoise'),
  Sourate(numero: 17,  nom: 'Al-Isra',       nomArabe: 'الإسراء',      signification: 'Le Voyage Nocturne',    versets: 111, revelation: 'Mecquoise'),
  Sourate(numero: 18,  nom: 'Al-Kahf',       nomArabe: 'الكهف',        signification: 'La Caverne',            versets: 110, revelation: 'Mecquoise'),
  Sourate(numero: 19,  nom: 'Maryam',        nomArabe: 'مريم',         signification: 'Marie',                 versets: 98,  revelation: 'Mecquoise'),
  Sourate(numero: 20,  nom: 'Ta-Ha',         nomArabe: 'طه',           signification: 'Ta-Ha',                 versets: 135, revelation: 'Mecquoise'),
  Sourate(numero: 21,  nom: 'Al-Anbiya',     nomArabe: 'الأنبياء',     signification: 'Les Prophètes',         versets: 112, revelation: 'Mecquoise'),
  Sourate(numero: 22,  nom: 'Al-Hajj',       nomArabe: 'الحج',         signification: 'Le Pèlerinage',         versets: 78,  revelation: 'Médinoise'),
  Sourate(numero: 23,  nom: 'Al-Mu\'minun',  nomArabe: 'المؤمنون',     signification: 'Les Croyants',          versets: 118, revelation: 'Mecquoise'),
  Sourate(numero: 24,  nom: 'An-Nur',        nomArabe: 'النور',        signification: 'La Lumière',            versets: 64,  revelation: 'Médinoise'),
  Sourate(numero: 25,  nom: 'Al-Furqan',     nomArabe: 'الفرقان',      signification: 'Le Discernement',       versets: 77,  revelation: 'Mecquoise'),
  Sourate(numero: 26,  nom: 'Ash-Shu\'ara',  nomArabe: 'الشعراء',      signification: 'Les Poètes',            versets: 227, revelation: 'Mecquoise'),
  Sourate(numero: 27,  nom: 'An-Naml',       nomArabe: 'النمل',        signification: 'Les Fourmis',           versets: 93,  revelation: 'Mecquoise'),
  Sourate(numero: 28,  nom: 'Al-Qasas',      nomArabe: 'القصص',        signification: 'Les Récits',            versets: 88,  revelation: 'Mecquoise'),
  Sourate(numero: 29,  nom: 'Al-Ankabut',    nomArabe: 'العنكبوت',     signification: 'L\'Araignée',           versets: 69,  revelation: 'Mecquoise'),
  Sourate(numero: 30,  nom: 'Ar-Rum',        nomArabe: 'الروم',        signification: 'Les Byzantins',         versets: 60,  revelation: 'Mecquoise'),
  Sourate(numero: 31,  nom: 'Luqman',        nomArabe: 'لقمان',        signification: 'Luqman',                versets: 34,  revelation: 'Mecquoise'),
  Sourate(numero: 32,  nom: 'As-Sajda',      nomArabe: 'السجدة',       signification: 'La Prosternation',      versets: 30,  revelation: 'Mecquoise'),
  Sourate(numero: 33,  nom: 'Al-Ahzab',      nomArabe: 'الأحزاب',      signification: 'Les Coalisés',          versets: 73,  revelation: 'Médinoise'),
  Sourate(numero: 34,  nom: 'Saba',          nomArabe: 'سبأ',          signification: 'Saba',                  versets: 54,  revelation: 'Mecquoise'),
  Sourate(numero: 35,  nom: 'Fatir',         nomArabe: 'فاطر',         signification: 'Le Créateur',           versets: 45,  revelation: 'Mecquoise'),
  Sourate(numero: 36,  nom: 'Ya-Sin',        nomArabe: 'يس',           signification: 'Ya-Sin',                versets: 83,  revelation: 'Mecquoise'),
  Sourate(numero: 37,  nom: 'As-Saffat',     nomArabe: 'الصافات',      signification: 'Les Rangées',           versets: 182, revelation: 'Mecquoise'),
  Sourate(numero: 38,  nom: 'Sad',           nomArabe: 'ص',            signification: 'Sad',                   versets: 88,  revelation: 'Mecquoise'),
  Sourate(numero: 39,  nom: 'Az-Zumar',      nomArabe: 'الزمر',        signification: 'Les Groupes',           versets: 75,  revelation: 'Mecquoise'),
  Sourate(numero: 40,  nom: 'Ghafir',        nomArabe: 'غافر',         signification: 'Le Pardonneur',         versets: 85,  revelation: 'Mecquoise'),
  Sourate(numero: 41,  nom: 'Fussilat',      nomArabe: 'فصلت',         signification: 'Détaillés',             versets: 54,  revelation: 'Mecquoise'),
  Sourate(numero: 42,  nom: 'Ash-Shura',     nomArabe: 'الشورى',       signification: 'La Consultation',       versets: 53,  revelation: 'Mecquoise'),
  Sourate(numero: 43,  nom: 'Az-Zukhruf',    nomArabe: 'الزخرف',       signification: 'Les Ornements',         versets: 89,  revelation: 'Mecquoise'),
  Sourate(numero: 44,  nom: 'Ad-Dukhan',     nomArabe: 'الدخان',       signification: 'La Fumée',              versets: 59,  revelation: 'Mecquoise'),
  Sourate(numero: 45,  nom: 'Al-Jathiya',    nomArabe: 'الجاثية',      signification: 'L\'Agenouillée',        versets: 37,  revelation: 'Mecquoise'),
  Sourate(numero: 46,  nom: 'Al-Ahqaf',      nomArabe: 'الأحقاف',      signification: 'Les Dunes',             versets: 35,  revelation: 'Mecquoise'),
  Sourate(numero: 47,  nom: 'Muhammad',      nomArabe: 'محمد',         signification: 'Muhammad',              versets: 38,  revelation: 'Médinoise'),
  Sourate(numero: 48,  nom: 'Al-Fath',       nomArabe: 'الفتح',        signification: 'La Victoire',           versets: 29,  revelation: 'Médinoise'),
  Sourate(numero: 49,  nom: 'Al-Hujurat',    nomArabe: 'الحجرات',      signification: 'Les Appartements',      versets: 18,  revelation: 'Médinoise'),
  Sourate(numero: 50,  nom: 'Qaf',           nomArabe: 'ق',            signification: 'Qaf',                   versets: 45,  revelation: 'Mecquoise'),
  Sourate(numero: 51,  nom: 'Adh-Dhariyat',  nomArabe: 'الذاريات',     signification: 'Les Vents',             versets: 60,  revelation: 'Mecquoise'),
  Sourate(numero: 52,  nom: 'At-Tur',        nomArabe: 'الطور',        signification: 'Le Mont',               versets: 49,  revelation: 'Mecquoise'),
  Sourate(numero: 53,  nom: 'An-Najm',       nomArabe: 'النجم',        signification: 'L\'Étoile',             versets: 62,  revelation: 'Mecquoise'),
  Sourate(numero: 54,  nom: 'Al-Qamar',      nomArabe: 'القمر',        signification: 'La Lune',               versets: 55,  revelation: 'Mecquoise'),
  Sourate(numero: 55,  nom: 'Ar-Rahman',     nomArabe: 'الرحمن',       signification: 'Le Miséricordieux',     versets: 78,  revelation: 'Médinoise'),
  Sourate(numero: 56,  nom: 'Al-Waqi\'a',    nomArabe: 'الواقعة',      signification: 'L\'Événement',          versets: 96,  revelation: 'Mecquoise'),
  Sourate(numero: 57,  nom: 'Al-Hadid',      nomArabe: 'الحديد',       signification: 'Le Fer',                versets: 29,  revelation: 'Médinoise'),
  Sourate(numero: 58,  nom: 'Al-Mujadila',   nomArabe: 'المجادلة',     signification: 'La Discussion',         versets: 22,  revelation: 'Médinoise'),
  Sourate(numero: 59,  nom: 'Al-Hashr',      nomArabe: 'الحشر',        signification: 'L\'Exode',              versets: 24,  revelation: 'Médinoise'),
  Sourate(numero: 60,  nom: 'Al-Mumtahana',  nomArabe: 'الممتحنة',     signification: 'L\'Éprouvée',           versets: 13,  revelation: 'Médinoise'),
  Sourate(numero: 61,  nom: 'As-Saf',        nomArabe: 'الصف',         signification: 'Le Rang',               versets: 14,  revelation: 'Médinoise'),
  Sourate(numero: 62,  nom: 'Al-Jumu\'a',    nomArabe: 'الجمعة',       signification: 'Le Vendredi',           versets: 11,  revelation: 'Médinoise'),
  Sourate(numero: 63,  nom: 'Al-Munafiqun',  nomArabe: 'المنافقون',    signification: 'Les Hypocrites',        versets: 11,  revelation: 'Médinoise'),
  Sourate(numero: 64,  nom: 'At-Taghabun',   nomArabe: 'التغابن',      signification: 'La Tromperie',          versets: 18,  revelation: 'Médinoise'),
  Sourate(numero: 65,  nom: 'At-Talaq',      nomArabe: 'الطلاق',       signification: 'Le Divorce',            versets: 12,  revelation: 'Médinoise'),
  Sourate(numero: 66,  nom: 'At-Tahrim',     nomArabe: 'التحريم',      signification: 'L\'Interdiction',       versets: 12,  revelation: 'Médinoise'),
  Sourate(numero: 67,  nom: 'Al-Mulk',       nomArabe: 'الملك',        signification: 'La Royauté',            versets: 30,  revelation: 'Mecquoise'),
  Sourate(numero: 68,  nom: 'Al-Qalam',      nomArabe: 'القلم',        signification: 'La Plume',              versets: 52,  revelation: 'Mecquoise'),
  Sourate(numero: 69,  nom: 'Al-Haqqa',      nomArabe: 'الحاقة',       signification: 'L\'Inévitable',         versets: 52,  revelation: 'Mecquoise'),
  Sourate(numero: 70,  nom: 'Al-Ma\'arij',   nomArabe: 'المعارج',      signification: 'Les Degrés',            versets: 44,  revelation: 'Mecquoise'),
  Sourate(numero: 71,  nom: 'Nuh',           nomArabe: 'نوح',          signification: 'Noé',                   versets: 28,  revelation: 'Mecquoise'),
  Sourate(numero: 72,  nom: 'Al-Jinn',       nomArabe: 'الجن',         signification: 'Les Djinns',            versets: 28,  revelation: 'Mecquoise'),
  Sourate(numero: 73,  nom: 'Al-Muzzammil',  nomArabe: 'المزمل',       signification: 'L\'Enveloppé',          versets: 20,  revelation: 'Mecquoise'),
  Sourate(numero: 74,  nom: 'Al-Muddaththir',nomArabe: 'المدثر',       signification: 'Le Couvert',            versets: 56,  revelation: 'Mecquoise'),
  Sourate(numero: 75,  nom: 'Al-Qiyama',     nomArabe: 'القيامة',      signification: 'La Résurrection',       versets: 40,  revelation: 'Mecquoise'),
  Sourate(numero: 76,  nom: 'Al-Insan',      nomArabe: 'الإنسان',      signification: 'L\'Homme',              versets: 31,  revelation: 'Médinoise'),
  Sourate(numero: 77,  nom: 'Al-Mursalat',   nomArabe: 'المرسلات',     signification: 'Les Envoyés',           versets: 50,  revelation: 'Mecquoise'),
  Sourate(numero: 78,  nom: 'An-Naba',       nomArabe: 'النبأ',        signification: 'La Nouvelle',           versets: 40,  revelation: 'Mecquoise'),
  Sourate(numero: 79,  nom: 'An-Nazi\'at',   nomArabe: 'النازعات',     signification: 'Les Arracheurs',        versets: 46,  revelation: 'Mecquoise'),
  Sourate(numero: 80,  nom: 'Abasa',         nomArabe: 'عبس',          signification: 'Il Fronça les Sourcils',versets: 42,  revelation: 'Mecquoise'),
  Sourate(numero: 81,  nom: 'At-Takwir',     nomArabe: 'التكوير',      signification: 'L\'Enroulement',        versets: 29,  revelation: 'Mecquoise'),
  Sourate(numero: 82,  nom: 'Al-Infitar',    nomArabe: 'الانفطار',     signification: 'La Déchirure',          versets: 19,  revelation: 'Mecquoise'),
  Sourate(numero: 83,  nom: 'Al-Mutaffifin', nomArabe: 'المطففين',     signification: 'Les Fraudeurs',         versets: 36,  revelation: 'Mecquoise'),
  Sourate(numero: 84,  nom: 'Al-Inshiqaq',   nomArabe: 'الانشقاق',     signification: 'La Fissure',            versets: 25,  revelation: 'Mecquoise'),
  Sourate(numero: 85,  nom: 'Al-Buruj',      nomArabe: 'البروج',       signification: 'Les Constellations',    versets: 22,  revelation: 'Mecquoise'),
  Sourate(numero: 86,  nom: 'At-Tariq',      nomArabe: 'الطارق',       signification: 'L\'Astre Nocturne',     versets: 17,  revelation: 'Mecquoise'),
  Sourate(numero: 87,  nom: 'Al-A\'la',      nomArabe: 'الأعلى',       signification: 'Le Très-Haut',          versets: 19,  revelation: 'Mecquoise'),
  Sourate(numero: 88,  nom: 'Al-Ghashiya',   nomArabe: 'الغاشية',      signification: 'L\'Enveloppante',       versets: 26,  revelation: 'Mecquoise'),
  Sourate(numero: 89,  nom: 'Al-Fajr',       nomArabe: 'الفجر',        signification: 'L\'Aube',               versets: 30,  revelation: 'Mecquoise'),
  Sourate(numero: 90,  nom: 'Al-Balad',      nomArabe: 'البلد',        signification: 'La Cité',               versets: 20,  revelation: 'Mecquoise'),
  Sourate(numero: 91,  nom: 'Ash-Shams',     nomArabe: 'الشمس',        signification: 'Le Soleil',             versets: 15,  revelation: 'Mecquoise'),
  Sourate(numero: 92,  nom: 'Al-Layl',       nomArabe: 'الليل',        signification: 'La Nuit',               versets: 21,  revelation: 'Mecquoise'),
  Sourate(numero: 93,  nom: 'Ad-Duha',       nomArabe: 'الضحى',        signification: 'La Matinée',            versets: 11,  revelation: 'Mecquoise'),
  Sourate(numero: 94,  nom: 'Ash-Sharh',     nomArabe: 'الشرح',        signification: 'L\'Expansion',          versets: 8,   revelation: 'Mecquoise'),
  Sourate(numero: 95,  nom: 'At-Tin',        nomArabe: 'التين',        signification: 'Le Figuier',            versets: 8,   revelation: 'Mecquoise'),
  Sourate(numero: 96,  nom: 'Al-Alaq',       nomArabe: 'العلق',        signification: 'L\'Adhérence',          versets: 19,  revelation: 'Mecquoise'),
  Sourate(numero: 97,  nom: 'Al-Qadr',       nomArabe: 'القدر',        signification: 'La Nuit du Destin',     versets: 5,   revelation: 'Mecquoise'),
  Sourate(numero: 98,  nom: 'Al-Bayyina',    nomArabe: 'البينة',       signification: 'La Preuve',             versets: 8,   revelation: 'Médinoise'),
  Sourate(numero: 99,  nom: 'Az-Zalzala',    nomArabe: 'الزلزلة',      signification: 'Le Séisme',             versets: 8,   revelation: 'Médinoise'),
  Sourate(numero: 100, nom: 'Al-Adiyat',     nomArabe: 'العاديات',     signification: 'Les Coureurs',          versets: 11,  revelation: 'Mecquoise'),
  Sourate(numero: 101, nom: 'Al-Qari\'a',    nomArabe: 'القارعة',      signification: 'Le Fracas',             versets: 11,  revelation: 'Mecquoise'),
  Sourate(numero: 102, nom: 'At-Takathur',   nomArabe: 'التكاثر',      signification: 'L\'Accumulation',       versets: 8,   revelation: 'Mecquoise'),
  Sourate(numero: 103, nom: 'Al-Asr',        nomArabe: 'العصر',        signification: 'Le Temps',              versets: 3,   revelation: 'Mecquoise'),
  Sourate(numero: 104, nom: 'Al-Humaza',     nomArabe: 'الهمزة',       signification: 'Le Calomniateur',       versets: 9,   revelation: 'Mecquoise'),
  Sourate(numero: 105, nom: 'Al-Fil',        nomArabe: 'الفيل',        signification: 'L\'Éléphant',           versets: 5,   revelation: 'Mecquoise'),
  Sourate(numero: 106, nom: 'Quraysh',       nomArabe: 'قريش',         signification: 'Quraysh',               versets: 4,   revelation: 'Mecquoise'),
  Sourate(numero: 107, nom: 'Al-Ma\'un',     nomArabe: 'الماعون',      signification: 'L\'Ustensile',          versets: 7,   revelation: 'Mecquoise'),
  Sourate(numero: 108, nom: 'Al-Kawthar',    nomArabe: 'الكوثر',       signification: 'L\'Abondance',          versets: 3,   revelation: 'Mecquoise'),
  Sourate(numero: 109, nom: 'Al-Kafirun',    nomArabe: 'الكافرون',     signification: 'Les Infidèles',         versets: 6,   revelation: 'Mecquoise'),
  Sourate(numero: 110, nom: 'An-Nasr',       nomArabe: 'النصر',        signification: 'Le Secours',            versets: 3,   revelation: 'Médinoise'),
  Sourate(numero: 111, nom: 'Al-Masad',      nomArabe: 'المسد',        signification: 'Les Fibres',            versets: 5,   revelation: 'Mecquoise'),
  Sourate(numero: 112, nom: 'Al-Ikhlas',     nomArabe: 'الإخلاص',      signification: 'La Pureté',             versets: 4,   revelation: 'Mecquoise'),
  Sourate(numero: 113, nom: 'Al-Falaq',      nomArabe: 'الفلق',        signification: 'L\'Aube Naissante',     versets: 5,   revelation: 'Mecquoise'),
  Sourate(numero: 114, nom: 'An-Nas',        nomArabe: 'الناس',        signification: 'Les Hommes',            versets: 6,   revelation: 'Mecquoise'),
];

// ============================================================
//  PAGE PRINCIPALE
// ============================================================
class AudioQuranPage extends StatefulWidget {
  const AudioQuranPage({super.key});

  @override
  State<AudioQuranPage> createState() => _AudioQuranPageState();
}

class _AudioQuranPageState extends State<AudioQuranPage> {
  final AudioPlayer _player = AudioPlayer();
  final TextEditingController _searchCtrl = TextEditingController();

  Sourate? _sourateActive;
  bool _chargement = false;
  bool _lecture = false;
  bool _erreur = false;
  String _messageErreur = '';
  Duration _position = Duration.zero;
  Duration _duree = Duration.zero;
  String _recherche = '';

  // Récitation sélectionnée
  int _recitateur = 0; // 0 = Mishary, 1 = alternatif
  final List<String> _recitateurs = ['Mishary Al-Afasy', 'Mishary (Alt)'];

  @override
  void initState() {
    super.initState();
    _player.positionStream.listen((p) {
      if (mounted) setState(() => _position = p);
    });
    _player.durationStream.listen((d) {
      if (mounted && d != null) setState(() => _duree = d);
    });
    _player.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _lecture = state.playing;
          if (state.processingState == ProcessingState.completed) {
            _lecture = false;
            _position = Duration.zero;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _player.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Lire une sourate ─────────────────────────────────────
  Future<void> _lire(Sourate s) async {
    try {
      setState(() {
        _chargement = true;
        _erreur = false;
        _sourateActive = s;
        _lecture = false;
        _position = Duration.zero;
        _duree = Duration.zero;
      });

      await _player.stop();

      final url = _recitateur == 0 ? s.urlAudio : s.urlAudioAlt;

      await _player.setAudioSource(
        AudioSource.uri(Uri.parse(url)),
      );

      setState(() => _chargement = false);
      await _player.play();

    } catch (e) {
      setState(() {
        _chargement = false;
        _erreur = true;
        _messageErreur = 'Connexion internet requise pour l\'audio.\nVérifiez votre connexion.';
      });
    }
  }

  Future<void> _toggleLecture() async {
    if (_sourateActive == null) return;
    if (_lecture) {
      await _player.pause();
    } else {
      if (_player.processingState == ProcessingState.completed) {
        await _player.seek(Duration.zero);
      }
      await _player.play();
    }
  }

  Future<void> _arreter() async {
    await _player.stop();
    setState(() {
      _lecture = false;
      _position = Duration.zero;
    });
  }

  Future<void> _precedente() async {
    if (_sourateActive == null || _sourateActive!.numero <= 1) return;
    final idx = sourates.indexWhere((s) => s.numero == _sourateActive!.numero - 1);
    if (idx >= 0) await _lire(sourates[idx]);
  }

  Future<void> _suivante() async {
    if (_sourateActive == null || _sourateActive!.numero >= 114) return;
    final idx = sourates.indexWhere((s) => s.numero == _sourateActive!.numero + 1);
    if (idx >= 0) await _lire(sourates[idx]);
  }

  String _formatDuree(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  List<Sourate> get _souratesFiltrees {
    if (_recherche.isEmpty) return sourates;
    return sourates.where((s) =>
      s.nom.toLowerCase().contains(_recherche.toLowerCase()) ||
      s.nomArabe.contains(_recherche) ||
      s.signification.toLowerCase().contains(_recherche.toLowerCase()) ||
      s.numero.toString() == _recherche
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kFond,
      body: Column(
        children: [
          _entete(),
          if (_sourateActive != null) _lecteur(),
          _barreRecherche(),
          Expanded(child: _listeSourates()),
        ],
      ),
    );
  }

  // ── En-tête ───────────────────────────────────────────────
  Widget _entete() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              const Icon(Icons.menu_book, color: kOr, size: 28),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('القرآن الكريم',
                      style: TextStyle(color: kOr, fontSize: 20, fontFamily: 'Amiri')),
                    Text('Saint Coran — Mishary Al-Afasy',
                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
              // Sélecteur récitateur
              GestureDetector(
                onTap: () => setState(() => _recitateur = (_recitateur + 1) % 2),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(_recitateurs[_recitateur],
                    style: const TextStyle(color: kOr, fontSize: 10)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Lecteur audio ─────────────────────────────────────────
  Widget _lecteur() {
    final s = _sourateActive!;
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [kVert, const Color(0xFF2E7D32)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(
          color: kVert.withValues(alpha: 0.4),
          blurRadius: 16,
          offset: const Offset(0, 6),
        )],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Titre sourate
            Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: kOr,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text('${s.numero}',
                      style: const TextStyle(
                        color: kVert, fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.nomArabe,
                        style: const TextStyle(
                          color: kOr, fontSize: 18, fontFamily: 'Amiri')),
                      Text('${s.nom} — ${s.versets} versets — ${s.revelation}',
                        style: const TextStyle(color: Colors.white70, fontSize: 11)),
                    ],
                  ),
                ),
                // Erreur
                if (_erreur)
                  const Icon(Icons.wifi_off, color: Colors.orangeAccent, size: 20),
              ],
            ),

            if (_erreur) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_messageErreur,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.orangeAccent, fontSize: 11)),
              ),
            ],

            const SizedBox(height: 12),

            // Barre de progression
            SliderTheme(
              data: SliderThemeData(
                thumbColor: kOr,
                activeTrackColor: kOr,
                inactiveTrackColor: Colors.white24,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
              ),
              child: Slider(
                value: _duree.inSeconds > 0
                    ? _position.inSeconds.toDouble().clamp(0, _duree.inSeconds.toDouble())
                    : 0,
                max: _duree.inSeconds > 0 ? _duree.inSeconds.toDouble() : 1,
                onChanged: (v) => _player.seek(Duration(seconds: v.toInt())),
              ),
            ),

            // Temps
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_formatDuree(_position),
                    style: const TextStyle(color: Colors.white60, fontSize: 11)),
                  Text(_formatDuree(_duree),
                    style: const TextStyle(color: Colors.white60, fontSize: 11)),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Contrôles
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Précédente
                IconButton(
                  onPressed: _sourateActive!.numero > 1 ? _precedente : null,
                  icon: const Icon(Icons.skip_previous_rounded),
                  color: kBlanc,
                  iconSize: 32,
                ),
                const SizedBox(width: 8),
                // Play / Pause / Chargement
                GestureDetector(
                  onTap: _chargement ? null : _toggleLecture,
                  child: Container(
                    width: 60, height: 60,
                    decoration: BoxDecoration(
                      color: kOr,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(
                        color: kOr.withValues(alpha: 0.4), blurRadius: 12)],
                    ),
                    child: _chargement
                        ? const Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(
                              color: kVert, strokeWidth: 3),
                          )
                        : Icon(
                            _lecture ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            color: kVert, size: 36,
                          ),
                  ),
                ),
                const SizedBox(width: 8),
                // Suivante
                IconButton(
                  onPressed: _sourateActive!.numero < 114 ? _suivante : null,
                  icon: const Icon(Icons.skip_next_rounded),
                  color: kBlanc,
                  iconSize: 32,
                ),
                const SizedBox(width: 16),
                // Stop
                IconButton(
                  onPressed: _arreter,
                  icon: const Icon(Icons.stop_rounded),
                  color: Colors.white54,
                  iconSize: 28,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Barre de recherche ────────────────────────────────────
  Widget _barreRecherche() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: kBlanc,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
        ),
        child: TextField(
          controller: _searchCtrl,
          decoration: InputDecoration(
            hintText: 'Rechercher sourate (nom, numéro, signification...)',
            hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
            prefixIcon: const Icon(Icons.search, color: kVert),
            suffixIcon: _recherche.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      _searchCtrl.clear();
                      setState(() => _recherche = '');
                    },
                    child: const Icon(Icons.close, color: Colors.grey),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onChanged: (v) => setState(() => _recherche = v),
        ),
      ),
    );
  }

  // ── Liste des sourates ────────────────────────────────────
  Widget _listeSourates() {
    final liste = _souratesFiltrees;
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 80),
      itemCount: liste.length,
      itemBuilder: (_, i) {
        final s = liste[i];
        final estActive = _sourateActive?.numero == s.numero;
        return GestureDetector(
          onTap: () => _lire(s),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.only(bottom: 6),
            decoration: BoxDecoration(
              color: estActive ? kVert : kBlanc,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: estActive ? kVert : Colors.grey.shade200,
                width: estActive ? 0 : 1,
              ),
              boxShadow: [BoxShadow(
                color: estActive
                    ? kVert.withValues(alpha: 0.25)
                    : Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
              )],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  // Numéro
                  Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                      color: estActive ? kOr : kVert.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text('${s.numero}',
                        style: TextStyle(
                          color: estActive ? kVert : kVert,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        )),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Infos
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.nom,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: estActive ? kBlanc : Colors.black87,
                          )),
                        Text(s.signification,
                          style: TextStyle(
                            fontSize: 11,
                            color: estActive ? Colors.white70 : Colors.grey.shade600,
                          )),
                      ],
                    ),
                  ),
                  // Arabe + versets
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(s.nomArabe,
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Amiri',
                          color: estActive ? kOr : kVert,
                        )),
                      Text('${s.versets} v.',
                        style: TextStyle(
                          fontSize: 10,
                          color: estActive ? Colors.white60 : Colors.grey.shade500,
                        )),
                    ],
                  ),
                  const SizedBox(width: 8),
                  // Icône
                  Icon(
                    estActive && _lecture
                        ? Icons.volume_up_rounded
                        : Icons.play_circle_outline_rounded,
                    color: estActive ? kOr : Colors.grey.shade400,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
