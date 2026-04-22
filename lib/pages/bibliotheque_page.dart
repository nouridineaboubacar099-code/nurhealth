// ============================================================
//  NurHealth — Bibliothèque Islamique Complète
//  lib/pages/bibliotheque_page.dart
// ============================================================

import 'package:flutter/material.dart';
import '../data/hadith_nawawi_data.dart';
import '../data/riyad_salihin_data.dart';

// ── Couleurs ─────────────────────────────────────────────
const Color kVert      = Color(0xFF1B5E20);
const Color kVertClair = Color(0xFF4CAF50);
const Color kOr        = Color(0xFFFFD700);
const Color kOrClair   = Color(0xFFFFF9C4);
const Color kBlanc     = Color(0xFFFFFFFF);
const Color kFond      = Color(0xFFF8F9FA);

// ============================================================
//  PAGE PRINCIPALE BIBLIOTHÈQUE
// ============================================================
class BibliothequeIslamiquePage extends StatefulWidget {
  const BibliothequeIslamiquePage({super.key});

  @override
  State<BibliothequeIslamiquePage> createState() => _BibliothequeIslamiquePageState();
}

class _BibliothequeIslamiquePageState extends State<BibliothequeIslamiquePage>
    with SingleTickerProviderStateMixin {

  late TabController _tabController;

  final List<_LivreMeta> _livres = [
    _LivreMeta(
      titre: '40 Hadiths\nAn-Nawawi',
      titreArabe: 'الأربعون النووية',
      icone: Icons.format_list_numbered,
      couleur: const Color(0xFF1B5E20),
      nombreItems: '42 hadiths',
      description: 'Les hadiths fondamentaux de l\'Islam selon Imam An-Nawawi',
    ),
    _LivreMeta(
      titre: 'Riyad\nAs-Salihin',
      titreArabe: 'رياض الصالحين',
      icone: Icons.auto_stories,
      couleur: const Color(0xFF1565C0),
      nombreItems: '20 chapitres',
      description: 'Les jardins des vertueux — Imam An-Nawawi',
    ),
    _LivreMeta(
      titre: 'Bulugh\nAl-Maram',
      titreArabe: 'بلوغ المرام',
      icone: Icons.balance,
      couleur: const Color(0xFF6A1B9A),
      nombreItems: 'Jurisprudence',
      description: 'Hadiths de jurisprudence islamique — Ibn Hajar Al-Asqalani',
    ),
    _LivreMeta(
      titre: 'Fiqh —\n4 Madhhabs',
      titreArabe: 'الفقه المقارن',
      icone: Icons.account_balance,
      couleur: const Color(0xFF880E4F),
      nombreItems: 'Résumé comparé',
      description: 'Résumé comparatif des 4 écoles de jurisprudence',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _livres.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kFond,
      body: Column(
        children: [
          _EnteteLibrairie(livres: _livres, tabController: _tabController),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _VueHadithsNawawi(),
                _VueRiyadSalihin(),
                _VueBulughMaram(),
                _VueFiqhMadhhabs(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── En-tête ────────────────────────────────────────────────
class _EnteteLibrairie extends StatelessWidget {
  final List<_LivreMeta> livres;
  final TabController tabController;

  const _EnteteLibrairie({required this.livres, required this.tabController});

  @override
  Widget build(BuildContext context) {
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Icon(Icons.menu_book, color: kOr, size: 28),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Bibliothèque Islamique',
                          style: TextStyle(color: kBlanc, fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('المكتبة الإسلامية',
                          style: TextStyle(color: kOr, fontSize: 14, fontFamily: 'Amiri')),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            TabBar(
              controller: tabController,
              isScrollable: true,
              indicatorColor: kOr,
              indicatorWeight: 3,
              labelColor: kOr,
              unselectedLabelColor: Colors.white60,
              tabs: livres.map((l) => Tab(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(l.icone, size: 18),
                    const SizedBox(height: 2),
                    Text(l.titreArabe,
                      style: const TextStyle(fontSize: 11, fontFamily: 'Amiri')),
                  ],
                ),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
//  VUE 1 — 40 HADITHS AN-NAWAWI
// ============================================================
class _VueHadithsNawawi extends StatefulWidget {
  @override
  State<_VueHadithsNawawi> createState() => _VueHadithsNawawiState();
}

class _VueHadithsNawawiState extends State<_VueHadithsNawawi> {
  int? _ouvert;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _BandeauLivre(
          titre: '40 Hadiths An-Nawawi',
          arabe: 'الأربعون النووية',
          auteur: 'Imam Yahya ibn Sharaf An-Nawawi (631-676 H)',
          couleur: kVert,
          description: 'Recueil des hadiths fondamentaux de l\'Islam. Chaque hadith est un principe universel de la religion.',
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: hadithsNawawi.length,
            itemBuilder: (ctx, i) {
              final h = hadithsNawawi[i];
              final estOuvert = _ouvert == i;
              return _CarteHadithNawawi(
                hadith: h,
                estOuvert: estOuvert,
                onTap: () => setState(() => _ouvert = estOuvert ? null : i),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CarteHadithNawawi extends StatelessWidget {
  final HadithNawawi hadith;
  final bool estOuvert;
  final VoidCallback onTap;

  const _CarteHadithNawawi({
    required this.hadith,
    required this.estOuvert,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: kBlanc,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: estOuvert ? kVert : Colors.grey.shade200,
          width: estOuvert ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: estOuvert
                ? kVert.withValues(alpha: 0.15)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: estOuvert ? 12 : 4,
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête
              Row(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: kVert,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text('${hadith.numero}',
                        style: const TextStyle(
                          color: kBlanc,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        )),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(hadith.narrateur,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: Color(0xFF333333),
                          )),
                        Text(hadith.source,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          )),
                      ],
                    ),
                  ),
                  Icon(
                    estOuvert ? Icons.expand_less : Icons.expand_more,
                    color: kVert,
                  ),
                ],
              ),

              // Arabe
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: kOrClair,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: kOr.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    hadith.arabe,
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      fontSize: 18,
                      fontFamily: 'Amiri',
                      color: Color(0xFF5D4037),
                      height: 1.8,
                    ),
                  ),
                ),
              ),

              // Texte (toujours visible, tronqué si fermé)
              if (!estOuvert)
                Text(
                  hadith.texte,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                ),

              if (estOuvert) ...[
                Text(
                  hadith.texte,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF333333),
                    height: 1.7,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: kVert.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: kVert.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.lightbulb_outline, color: kVert, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          hadith.lecon,
                          style: const TextStyle(
                            fontSize: 13,
                            color: kVert,
                            fontStyle: FontStyle.italic,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
//  VUE 2 — RIYAD AS-SALIHIN
// ============================================================
class _VueRiyadSalihin extends StatefulWidget {
  @override
  State<_VueRiyadSalihin> createState() => _VueRiyadSalihinState();
}

class _VueRiyadSalihinState extends State<_VueRiyadSalihin> {
  int? _chapitreOuvert;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _BandeauLivre(
          titre: 'Riyad As-Salihin',
          arabe: 'رياض الصالحين',
          auteur: 'Imam An-Nawawi (631-676 H)',
          couleur: const Color(0xFF1565C0),
          description: 'Les Jardins des Vertueux. Un guide complet de spiritualité et de morale islamique.',
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: riyadSalihin.length,
            itemBuilder: (ctx, i) {
              final chapitre = riyadSalihin[i];
              final estOuvert = _chapitreOuvert == i;
              return _CarteChapitreRiyad(
                chapitre: chapitre,
                estOuvert: estOuvert,
                onTap: () => setState(() => _chapitreOuvert = estOuvert ? null : i),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CarteChapitreRiyad extends StatelessWidget {
  final ChapitreRiyad chapitre;
  final bool estOuvert;
  final VoidCallback onTap;

  const _CarteChapitreRiyad({
    required this.chapitre,
    required this.estOuvert,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const couleur = Color(0xFF1565C0);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: kBlanc,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: estOuvert ? couleur : Colors.grey.shade200,
        ),
        boxShadow: [BoxShadow(
          color: estOuvert ? couleur.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.04),
          blurRadius: 8,
        )],
      ),
      child: Column(
        children: [
          // En-tête du chapitre
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: couleur,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text('${chapitre.numero}',
                        style: const TextStyle(color: kBlanc, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(chapitre.titre,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFF222222),
                          )),
                        Text(chapitre.titreArabe,
                          style: const TextStyle(
                            fontSize: 13,
                            fontFamily: 'Amiri',
                            color: couleur,
                          )),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: couleur.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('${chapitre.hadiths.length} h.',
                      style: const TextStyle(fontSize: 11, color: couleur, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 6),
                  Icon(estOuvert ? Icons.expand_less : Icons.expand_more, color: couleur),
                ],
              ),
            ),
          ),

          // Hadiths du chapitre
          if (estOuvert) ...[
            Divider(height: 1, color: couleur.withValues(alpha: 0.2)),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Introduction
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      chapitre.introduction,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF0D47A1),
                        fontStyle: FontStyle.italic,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Hadiths
                  ...chapitre.hadiths.map((h) => _MiniCarteHadith(hadith: h, couleur: couleur)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MiniCarteHadith extends StatelessWidget {
  final HadithRiyad hadith;
  final Color couleur;

  const _MiniCarteHadith({required this.hadith, required this.couleur});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kFond,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: couleur.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: couleur,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('Hadith ${hadith.numero}',
                  style: const TextStyle(color: kBlanc, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(hadith.narrateur,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            hadith.texte,
            style: const TextStyle(fontSize: 13, color: Color(0xFF333333), height: 1.6),
          ),
          const SizedBox(height: 6),
          Text('📚 ${hadith.source}',
            style: TextStyle(fontSize: 11, color: couleur, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ============================================================
//  VUE 3 — BULUGH AL-MARAM (résumé par chapitres)
// ============================================================
class _VueBulughMaram extends StatefulWidget {
  @override
  State<_VueBulughMaram> createState() => _VueBulughMaramState();
}

class _VueBulughMaramState extends State<_VueBulughMaram> {
  int? _ouvert;

  final List<_ChapitreSimple> _chapitres = const [
    _ChapitreSimple(
      numero: 1,
      titre: 'La Purification (Tahara)',
      arabe: 'كتاب الطهارة',
      couleur: Color(0xFF6A1B9A),
      contenu: [
        _ContenuBulugh(
          titre: 'L\'eau et ses types',
          texte: '• L\'eau est de deux types : pure et purifiante (tahour) ou pure mais non purifiante (tahir).\n• Hadith 1 — Abou Hourayra : "L\'eau est pure, rien ne la rend impure sauf ce qui en change la couleur, l\'odeur ou le goût." (Abou Dawoud, Ibn Maja)\n• Hadith 2 — Abou Sa\'id Al-Khudri : "L\'eau est pure, rien ne la rend impure." (At-Tirmidhi)\n\nRègle : L\'eau en grande quantité (plus de 2 qoulla = ±270 litres) ne se salit pas sauf si ses caractéristiques changent.',
        ),
        _ContenuBulugh(
          titre: 'Le Wudu (Ablutions)',
          texte: '• Hadith 41 — Abou Hourayra : "La prière de l\'un de vous n\'est pas acceptée s\'il perd sa pureté jusqu\'à ce qu\'il fasse ses ablutions." (Al-Bukhari et Muslim)\n• Hadith 44 — Othmane ibn Affan : Description complète du wudu du Prophète ﷺ — lavage des mains 3 fois, rinçage de bouche et des narines, lavage du visage 3 fois, mains jusqu\'aux coudes 3 fois, essuyage de la tête, lavage des pieds 3 fois. (Al-Bukhari et Muslim)\n\nConditions du wudu : Islam, discernement, intention, eau pure, aucun obstacle sur les membres.',
        ),
        _ContenuBulugh(
          titre: 'Les causes de rupture du wudu',
          texte: '• Sortie de quelque chose des deux voies (avant et arrière)\n• Perte de conscience (sommeil profond, évanouissement)\n• Contact de la chair de deux personnes de sexe opposé (selon certains madhhabs)\n• Hadith 68 — Ali ibn Abi Talib : "La clé de la prière c\'est la purification." (Ahmad, Abou Dawoud)\n\nRègle An-Nawawi : Le doute sur la rupture du wudu ne rompt pas la pureté — la certitude prime.',
        ),
      ],
    ),
    _ChapitreSimple(
      numero: 2,
      titre: 'La Prière (Salat)',
      arabe: 'كتاب الصلاة',
      couleur: Color(0xFF6A1B9A),
      contenu: [
        _ContenuBulugh(
          titre: 'Obligation et conditions',
          texte: '• Hadith 140 — Ibn Omar : "L\'islam est bâti sur cinq piliers : la shahada, la prière, la zakat, le jeûne du Ramadan et le pèlerinage." (Al-Bukhari et Muslim)\n• Conditions : Islam, discernement, puberté, purification, vêtement couvrant l\'awra, temps de prière, direction de la qibla, intention.\n• La prière est obligatoire 5 fois par jour pour tout Muslim pubère sain d\'esprit.',
        ),
        _ContenuBulugh(
          titre: 'Les temps des prières',
          texte: '• Fajr : de l\'aube vraie au lever du soleil\n• Dhuhr : du déclin du soleil jusqu\'à ce que l\'ombre d\'un objet soit égale à lui + son ombre à midi\n• Asr : du temps précédent au coucher du soleil\n• Maghrib : du coucher du soleil à la disparition du crépuscule rouge\n• Icha : de la disparition du crépuscule rouge jusqu\'au milieu de la nuit (ou l\'aube)\n\nHadith 152 — Jabir : Jibrîl enseigne les temps au Prophète ﷺ en priant avec lui deux jours. (Ahmad, At-Tirmidhi)',
        ),
        _ContenuBulugh(
          titre: 'L\'appel à la prière (Adhan)',
          texte: '• Hadith 178 — Abou Hourayra : "Quand l\'appel est lancé pour la prière, le diable s\'enfuit en flatant jusqu\'à ce qu\'il n\'entende plus l\'adhan." (Al-Bukhari et Muslim)\n• L\'adhan est fard kifaya (obligation collective) pour les hommes.\n• Il est recommandé de répéter les paroles du muezzin sauf au "Hayya ala as-salah" et "Hayya ala al-falah" où on dit : "La hawla wala quwwata illa billah."',
        ),
      ],
    ),
    _ChapitreSimple(
      numero: 3,
      titre: 'La Zakat',
      arabe: 'كتاب الزكاة',
      couleur: Color(0xFF6A1B9A),
      contenu: [
        _ContenuBulugh(
          titre: 'Obligation et nisab',
          texte: '• Hadith 606 — Ibn Abbas : "La zakat est obligatoire sur l\'or, l\'argent, les céréales, les dattes et le bétail." (Ibn Maja)\n• Nisab de l\'or : 85 grammes\n• Nisab de l\'argent : 595 grammes\n• Nisab des céréales : 653 kg\n• Taux : 2,5% pour l\'or, l\'argent et le commerce\n• Condition : possession d\'un nisab pendant une année lunaire complète (hawl)',
        ),
        _ContenuBulugh(
          titre: 'Bénéficiaires de la zakat',
          texte: '• Allah a fixé 8 catégories (At-Tawba : 60) :\n1. Les pauvres (fuqara)\n2. Les nécessiteux (masakin)\n3. Les collecteurs de zakat\n4. Ceux dont les cœurs sont à gagner\n5. L\'affranchissement des esclaves\n6. Les endettés\n7. Dans la voie d\'Allah\n8. Le voyageur en détresse\n\nHadith 622 — Mu\'adh ibn Jabal : "Elle est prélevée sur leurs riches et rendue à leurs pauvres." (Al-Bukhari et Muslim)',
        ),
      ],
    ),
    _ChapitreSimple(
      numero: 4,
      titre: 'Le Jeûne (Siyam)',
      arabe: 'كتاب الصيام',
      couleur: Color(0xFF6A1B9A),
      contenu: [
        _ContenuBulugh(
          titre: 'Obligation et vertus',
          texte: '• Hadith 682 — Abou Hourayra : "Allah dit : \'Tout acte du fils d\'Adam est pour lui sauf le jeûne qui est pour Moi et c\'est Moi qui en récompenserai.\'" (Al-Bukhari et Muslim)\n• Hadith 688 — Abou Hourayra : "Celui qui jeûne le Ramadan avec foi et en espérant la récompense, ses péchés antérieurs lui seront pardonnés." (Al-Bukhari et Muslim)\n• Le jeûne est obligatoire pour tout Muslim adulte, sain, sédentaire, non en voyage, non malade.',
        ),
        _ContenuBulugh(
          titre: 'Ce qui rompt le jeûne',
          texte: '• Manger et boire intentionnellement\n• Les relations conjugales\n• La menstruation et les lochies\n• L\'éjaculation intentionnelle\n\nCe qui ne rompt pas le jeûne :\n• L\'oubli (hadith 714 — Al-Bukhari et Muslim)\n• Le rinçage de bouche sans avaler\n• Les injections (différend des savants contemporains)\n• Le vomissement involontaire\n\nHadith 713 — Abou Hourayra : "Celui qui oublie et mange ou boit, qu\'il achève son jeûne. C\'est Allah qui l\'a nourri et abreuvé."',
        ),
      ],
    ),
    _ChapitreSimple(
      numero: 5,
      titre: 'Le Pèlerinage (Hajj)',
      arabe: 'كتاب الحج',
      couleur: Color(0xFF6A1B9A),
      contenu: [
        _ContenuBulugh(
          titre: 'Obligation et conditions',
          texte: '• Hadith 736 — Ibn Omar : "L\'Islam est bâti sur cinq piliers — dont le Hajj." (Al-Bukhari et Muslim)\n• Conditions du Hajj : Islam, liberté, puberté, santé d\'esprit, capacité physique et financière\n• Le Hajj est obligatoire une fois dans la vie pour celui qui en a les moyens\n• La Omra est sunna selon la majorité des savants',
        ),
        _ContenuBulugh(
          titre: 'Piliers du Hajj',
          texte: '• L\'Ihram (intention de Hajj/Omra)\n• La station à Arafat — le 9 Dhul Hijja\n• Le Tawaf Al-Ifada (7 tours autour de la Kaaba)\n• Le Sa\'y entre Safa et Marwa\n\nHadith 762 — Jabir : "Apprenez de moi vos rites du Hajj, je ne sais pas si je ferai le Hajj après cette année." (Muslim)',
        ),
      ],
    ),
    _ChapitreSimple(
      numero: 6,
      titre: 'Les Transactions (Buyu\')',
      arabe: 'كتاب البيوع',
      couleur: Color(0xFF6A1B9A),
      contenu: [
        _ContenuBulugh(
          titre: 'Principes généraux',
          texte: '• Hadith 801 — Hakim ibn Hizam : "Le vendeur et l\'acheteur ont le droit d\'option tant qu\'ils ne se sont pas séparés. S\'ils sont honnêtes et transparents, leur transaction sera bénie ; s\'ils cachent et mentent, la bénédiction sera supprimée." (Al-Bukhari et Muslim)\n• Principe : Les transactions sont permises par défaut sauf preuve d\'interdiction\n• Interdit : La vente du ce qu\'on ne possède pas, la vente de l\'incertain (gharar), le riba (intérêt)',
        ),
        _ContenuBulugh(
          titre: 'L\'interdiction du Riba',
          texte: '• Hadith 876 — Jabir : "Le Messager d\'Allah ﷺ a maudit celui qui prend le riba, celui qui le donne, celui qui l\'écrit et les deux témoins, en disant : \'Ils sont tous égaux.\'" (Muslim)\n• Types de riba : riba al-fadl (excès dans l\'échange) et riba an-nasia (délai avec surplus)\n• Les 6 articles du riba : or, argent, blé, orge, dattes, sel — échangés en excès ou avec délai',
        ),
      ],
    ),
    _ChapitreSimple(
      numero: 7,
      titre: 'Le Mariage (Nikah)',
      arabe: 'كتاب النكاح',
      couleur: Color(0xFF6A1B9A),
      contenu: [
        _ContenuBulugh(
          titre: 'Obligation et encouragement',
          texte: '• Hadith 982 — Ibn Mas\'ud : "Ô groupe de jeunes ! Que celui d\'entre vous qui peut se marier se marie car cela préserve mieux le regard et protège mieux les parties intimes. Que celui qui ne le peut pas jeûne car c\'est pour lui une protection." (Al-Bukhari et Muslim)\n• Le mariage est recommandé pour celui qui en a les moyens et en ressent le besoin\n• Il devient obligatoire si l\'on craint de tomber dans le péché',
        ),
        _ContenuBulugh(
          titre: 'Conditions du mariage',
          texte: '• L\'offre et l\'acceptation (ijab wa qabul)\n• Le tuteur (wali) pour la femme\n• Deux témoins\n• La dot (mahr) — obligatoire\n\nHadith 990 — Aïcha : "Pas de mariage sans tuteur." (Ahmad, Abou Dawoud)\nHadith 1000 — Jabir : "La femme ne peut pas se marier elle-même, ni marier une autre femme." (Ad-Daraqutni)',
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _BandeauLivre(
          titre: 'Bulugh Al-Maram',
          arabe: 'بلوغ المرام',
          auteur: 'Ibn Hajar Al-Asqalani (773-852 H)',
          couleur: const Color(0xFF6A1B9A),
          description: 'Hadiths des jugements juridiques islamiques. Base de la jurisprudence islamique pratique.',
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: _chapitres.length,
            itemBuilder: (ctx, i) {
              final ch = _chapitres[i];
              final estOuvert = _ouvert == i;
              return _CarteBulugh(
                chapitre: ch,
                estOuvert: estOuvert,
                onTap: () => setState(() => _ouvert = estOuvert ? null : i),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CarteBulugh extends StatelessWidget {
  final _ChapitreSimple chapitre;
  final bool estOuvert;
  final VoidCallback onTap;

  const _CarteBulugh({required this.chapitre, required this.estOuvert, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: kBlanc,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: estOuvert ? chapitre.couleur : Colors.grey.shade200,
        ),
        boxShadow: [BoxShadow(
          color: estOuvert ? chapitre.couleur.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.04),
          blurRadius: 8,
        )],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: chapitre.couleur,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(child: Text('${chapitre.numero}',
                      style: const TextStyle(color: kBlanc, fontWeight: FontWeight.bold))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(chapitre.titre,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        Text(chapitre.arabe,
                          style: TextStyle(
                            fontSize: 13, fontFamily: 'Amiri', color: chapitre.couleur)),
                      ],
                    ),
                  ),
                  Icon(estOuvert ? Icons.expand_less : Icons.expand_more, color: chapitre.couleur),
                ],
              ),
            ),
          ),
          if (estOuvert) ...[
            Divider(height: 1, color: chapitre.couleur.withValues(alpha: 0.2)),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: chapitre.contenu.map((c) => _SectionBulugh(contenu: c, couleur: chapitre.couleur)).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionBulugh extends StatelessWidget {
  final _ContenuBulugh contenu;
  final Color couleur;

  const _SectionBulugh({required this.contenu, required this.couleur});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kFond,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: couleur.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(contenu.titre,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: couleur)),
          const SizedBox(height: 8),
          Text(contenu.texte,
            style: const TextStyle(fontSize: 13, color: Color(0xFF333333), height: 1.6)),
        ],
      ),
    );
  }
}

// ============================================================
//  VUE 4 — FIQH 4 MADHHABS
// ============================================================
class _VueFiqhMadhhabs extends StatefulWidget {
  @override
  State<_VueFiqhMadhhabs> createState() => _VueFiqhMadhhabsState();
}

class _VueFiqhMadhhabsState extends State<_VueFiqhMadhhabs> {
  int? _sujetOuvert;

  final List<_SujetFiqh> _sujets = const [
    _SujetFiqh(
      titre: 'La Purification (Tahara)',
      icone: Icons.water_drop,
      couleur: Color(0xFF0277BD),
      hanafi: 'L\'eau de mer est pure. Le wudu se fait sur les membres obligatoires. La niyya n\'est pas obligatoire selon les Hanafis (elle est sunna). L\'essuyage sur la chaussette (khuff) est permis 1 jour pour le résident, 3 jours pour le voyageur.',
      maliki: 'La niyya est obligatoire dans le wudu. L\'essuyage du khuff est permis sans limite de durée selon certains savants. La petite quantité d\'eau n\'est pas rendue impure par simple contact d\'impureté.',
      shafii: 'La niyya est obligatoire pour la purification. L\'eau se divise en mutlaq (pure et purifiante), musta\'mal (utilisée) et najis. La tertib (ordre) et la muwalat (continuité) sont obligatoires dans le wudu.',
      hanbali: 'La niyya est obligatoire. Le tartib (ordre des membres) est obligatoire. Essuyer tout le khuff est obligatoire. L\'eau peu abondante est rendue impure si touchée par une najasa même sans changement de caractéristiques.',
    ),
    _SujetFiqh(
      titre: 'La Prière (Salat)',
      icone: Icons.mosque,
      couleur: Color(0xFF2E7D32),
      hanafi: 'Le Fatiha n\'est pas une condition absolue (suffisance d\'un verset). La prière du Witr est wajib (obligatoire). La Tasmia (Bismillah) au début de la Fatiha est lue en silence. Lever les mains n\'est fait qu\'au début.',
      maliki: 'La Tasmia n\'est pas récitée dans la prière obligatoire (ni à voix haute, ni en silence). Les mains sont posées le long du corps (irisal) dans les prières obligatoires. L\'Iqama est récitée en double comme l\'Adhan.',
      shafii: 'La Fatiha est un pilier. La Tasmia est un pilier de la Fatiha et récitée en silence dans les prières silencieuses, à voix haute dans les prières récitées à voix haute. Le Qunut de Fajr est recommandé.',
      hanbali: 'La Fatiha est obligatoire dans chaque rak\'a. Lever les mains est sunna en 4 positions. La Tasmia est dite en silence. Le Qunut de Witr est recommandé. La bonne intention doit précéder le takbir.',
    ),
    _SujetFiqh(
      titre: 'La Zakat',
      icone: Icons.volunteer_activism,
      couleur: Color(0xFF6A1B9A),
      hanafi: 'La zakat est obligatoire sur les biens du commerce dès le nisab. Le nisab de l\'or est 85g, de l\'argent 595g. L\'ushr (10% ou 5%) sur les cultures irriguées. Pas de zakat sur les chevaux utilisés personnellement.',
      maliki: 'La zakat des cultures est calculée à la récolte sans condition de hawl. Le nisab des récoltes est 653 kg. La zakat est obligatoire sur les bijoux selon une opinion. Les dettes ne déduisent pas le nisab du bétail.',
      shafii: 'Pas de zakat sur les bijoux selon l\'avis dominant de l\'école. La zakat sur les cultures : 10% si irrigation naturelle, 5% si irrigation artificielle. Les dettes déduisent le nisab dans certaines conditions.',
      hanbali: 'La zakat est obligatoire sur les bijoux d\'or et d\'argent utilisés. Le hawl commence dès la possession du nisab. Les dettes peuvent réduire le nisab. La zakat du commerce se calcule sur valeur de vente.',
    ),
    _SujetFiqh(
      titre: 'Le Jeûne (Siyam)',
      icone: Icons.nights_stay,
      couleur: Color(0xFF00695C),
      hanafi: 'L\'intention doit être faite avant Fajr pour les jeûnes obligatoires. Le vomissement intentionnel rompt le jeûne. Les injections intraveineuses rompent le jeûne selon certains savants contemporains hanafis. Le Witr est obligatoire.',
      maliki: 'L\'intention la veille est suffisante pour tout le mois. Les baisers ne rompent pas le jeûne si maîtrisé. La Kafara (expiation) pour rupture intentionnelle est : libérer un esclave, ou jeûner 2 mois consécutifs, ou nourrir 60 pauvres.',
      shafii: 'L\'intention doit être renouvelée chaque nuit pour les jeûnes obligatoires. Goûter la nourriture sans l\'avaler ne rompt pas le jeûne. Les injections ne rompent pas le jeûne car elles ne passent pas par la voie normale.',
      hanbali: 'L\'intention peut être faite le matin pour les jeûnes facultatifs. La saignée thérapeutique rompt le jeûne. L\'injection intraveineuse ne rompt pas le jeûne car ce n\'est pas de la nourriture. La Kafara est obligatoire pour tout rapport sexuel en Ramadan.',
    ),
    _SujetFiqh(
      titre: 'Le Mariage (Nikah)',
      icone: Icons.favorite,
      couleur: Color(0xFF880E4F),
      hanafi: 'La femme adulte saine d\'esprit peut se marier sans tuteur selon les Hanafis (elle devient son propre wali). La dot peut être différée. Le mariage temporaire (mut\'a) est interdit. Le mariage sans témoin est invalide.',
      maliki: 'Le wali est une condition du mariage même pour la femme majeure. Le wali peut être contraint par le juge s\'il refuse sans raison valable. La femme peut inclure des conditions dans le contrat. La dot minimale est définie.',
      shafii: 'Le wali est une condition absolue. Sans wali, le mariage est invalide même pour la femme majeure. Le wali passe du père au grand-père puis aux fils... jusqu\'au juge. La dot est une condition de validité.',
      hanbali: 'Le wali est une condition obligatoire. Le père peut marier sa vierge sans son consentement explicite (selon un avis ancien). La femme majeure et saine peut choisir son époux mais le wali prononce le contrat. Le silence de la vierge vaut consentement.',
    ),
    _SujetFiqh(
      titre: 'Le Divorce (Talaq)',
      icone: Icons.people_outline,
      couleur: Color(0xFFBF360C),
      hanafi: 'Le triple talaq prononcé en une fois compte comme trois. Le talaq pendant les règles est bid\'i mais compte. Le talaq du ivre compte. La revocabilité est possible après 1er et 2ème talaq pendant la idda.',
      maliki: 'Le talaq prononcé trois fois en une fois compte comme un seul selon l\'opinion de certains Malikis contemporains. Le talaq khul\' (compensation) appartient à la femme. La idda est de 3 quru\' (cycles menstruels).',
      shafii: 'Le triple talaq en une fois compte comme trois. Le talaq doit être fait en période de pureté. La idda est de 3 quru\'. La révocabilité est possible pendant la idda pour le 1er et 2ème talaq. L\'ila\' (serment d\'abstinence) est de 4 mois.',
      hanbali: 'Le triple talaq en une fois compte comme un seul selon Ibn Taymiyya et Ibn Al-Qayyim — avis suivi par beaucoup de savants contemporains. Le talaq pendant les règles est interdit mais compte. La période de idda varie selon la situation.',
    ),
    _SujetFiqh(
      titre: 'L\'Alimentation (At\'ima)',
      icone: Icons.restaurant,
      couleur: Color(0xFF558B2F),
      hanafi: 'Les poissons et sauterelles sont halal. Les animaux aquatiques autres que les poissons sont makrouh ou haram selon les savants. Le lièvre est permis. Le sang des poissons est excusé. L\'étourdissement avant abattage est controversé.',
      maliki: 'Tous les animaux marins sont permis, morts ou vivants. Les animaux terrestres sont permis s\'ils sont abattus correctement. Le cheval est permis. Les animaux à crocs sont haram. L\'égorgement par un non-Muslim kitabi est permis.',
      shafii: 'Les animaux terrestres carnivores sont haram. Les animaux marins sont tous permis. Le cheval est halal. L\'âne domestique est haram. La grenouille et le crocodile sont haram. L\'abattage doit couper la trachée, l\'œsophage et les deux jugulaires.',
      hanbali: 'Tout animal avec crocs ou griffes est haram. Les animaux marins sont généralement permis. Le cheval est permis. L\'abattage correct nécessite la coupure de la trachée, de l\'œsophage et idéalement des deux jugulaires.',
    ),
    _SujetFiqh(
      titre: 'L\'Héritage (Mawarith)',
      icone: Icons.account_tree,
      couleur: Color(0xFF37474F),
      hanafi: 'Le grand-père paternel hérite comme le père en l\'absence du père. La 'asaba (héritiers masculins) priment. Les dettes doivent être réglées avant distribution. Les legs ne peuvent dépasser 1/3 pour les non-héritiers.',
      maliki: 'Le grand-père est préféré aux frères selon les Malikis. Le Radd (retour du surplus aux héritiers) est permis sauf pour le conjoint. Le Murshida (outil de calcul de parts) est appliqué strictement selon les versets coraniques.',
      shafii: 'Le frère germain prime sur le frère utérin (même père). Le grand-père hérite en présence des frères selon une répartition précise. Le Radd ne s\'applique qu\'aux agnats. Les 6 parts fixes (fard) sont : 1/2, 1/4, 1/8, 2/3, 1/3, 1/6.',
      hanbali: 'Même approche générale. Le grand-père hérite selon la règle "un tiers ou le même que les frères — le plus avantageux". La règle de l\'Akdariyya (cas particulier de la femme, mère, mari et grand-père) est résolue différemment des autres écoles.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _BandeauLivre(
          titre: 'Fiqh — Les 4 Madhhabs',
          arabe: 'الفقه المقارن بين المذاهب الأربعة',
          auteur: 'Résumé comparatif — Hanafi • Maliki • Shafi\'i • Hanbali',
          couleur: const Color(0xFF880E4F),
          description: 'Comparaison des positions des 4 grandes écoles de jurisprudence islamique sur les sujets essentiels.',
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: _sujets.length,
            itemBuilder: (ctx, i) {
              final s = _sujets[i];
              final estOuvert = _sujetOuvert == i;
              return _CarteFiqh(
                sujet: s,
                estOuvert: estOuvert,
                onTap: () => setState(() => _sujetOuvert = estOuvert ? null : i),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CarteFiqh extends StatelessWidget {
  final _SujetFiqh sujet;
  final bool estOuvert;
  final VoidCallback onTap;

  const _CarteFiqh({required this.sujet, required this.estOuvert, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: kBlanc,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: estOuvert ? sujet.couleur : Colors.grey.shade200),
        boxShadow: [BoxShadow(
          color: estOuvert ? sujet.couleur.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.04),
          blurRadius: 8,
        )],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: sujet.couleur,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(sujet.icone, color: kBlanc, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(sujet.titre,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                  // Badges madhhabs
                  ...['H', 'M', 'S', 'H+'].map((m) => Container(
                    margin: const EdgeInsets.only(left: 3),
                    width: 22, height: 22,
                    decoration: BoxDecoration(
                      color: estOuvert ? sujet.couleur : Colors.grey.shade300,
                      shape: BoxShape.circle,
                    ),
                    child: Center(child: Text(m,
                      style: TextStyle(
                        color: estOuvert ? kBlanc : Colors.grey.shade600,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ))),
                  )),
                  const SizedBox(width: 6),
                  Icon(estOuvert ? Icons.expand_less : Icons.expand_more, color: sujet.couleur),
                ],
              ),
            ),
          ),
          if (estOuvert) ...[
            Divider(height: 1, color: sujet.couleur.withValues(alpha: 0.2)),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  _ColonneMadhhab('🔵 Hanafi', sujet.hanafi, const Color(0xFF1565C0)),
                  _ColonneMadhhab('🟢 Maliki', sujet.maliki, const Color(0xFF2E7D32)),
                  _ColonneMadhhab('🟡 Shafi\'i', sujet.shafii, const Color(0xFFF57F17)),
                  _ColonneMadhhab('🔴 Hanbali', sujet.hanbali, const Color(0xFFC62828)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ColonneMadhhab extends StatelessWidget {
  final String madhhab;
  final String contenu;
  final Color couleur;

  const _ColonneMadhhab(this.madhhab, this.contenu, this.couleur);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: couleur.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border(left: BorderSide(color: couleur, width: 3)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(madhhab,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: couleur)),
          const SizedBox(height: 6),
          Text(contenu,
            style: const TextStyle(fontSize: 13, color: Color(0xFF333333), height: 1.6)),
        ],
      ),
    );
  }
}

// ============================================================
//  WIDGETS COMMUNS
// ============================================================

class _BandeauLivre extends StatelessWidget {
  final String titre;
  final String arabe;
  final String auteur;
  final Color couleur;
  final String description;

  const _BandeauLivre({
    required this.titre,
    required this.arabe,
    required this.auteur,
    required this.couleur,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: couleur,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: couleur.withValues(alpha: 0.35), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(arabe,
            style: const TextStyle(
              color: kOr, fontSize: 20, fontFamily: 'Amiri', height: 1.5)),
          const SizedBox(height: 4),
          Text(titre,
            style: const TextStyle(color: kBlanc, fontSize: 16, fontWeight: FontWeight.bold)),
          Text(auteur,
            style: TextStyle(color: kBlanc.withValues(alpha: 0.8), fontSize: 12)),
          const SizedBox(height: 8),
          Text(description,
            style: TextStyle(color: kBlanc.withValues(alpha: 0.85), fontSize: 13, height: 1.4)),
        ],
      ),
    );
  }
}

// ============================================================
//  MODÈLES DE DONNÉES
// ============================================================

class _LivreMeta {
  final String titre;
  final String titreArabe;
  final IconData icone;
  final Color couleur;
  final String nombreItems;
  final String description;

  const _LivreMeta({
    required this.titre,
    required this.titreArabe,
    required this.icone,
    required this.couleur,
    required this.nombreItems,
    required this.description,
  });
}

class _ChapitreSimple {
  final int numero;
  final String titre;
  final String arabe;
  final Color couleur;
  final List<_ContenuBulugh> contenu;

  const _ChapitreSimple({
    required this.numero,
    required this.titre,
    required this.arabe,
    required this.couleur,
    required this.contenu,
  });
}

class _ContenuBulugh {
  final String titre;
  final String texte;

  const _ContenuBulugh({required this.titre, required this.texte});
}

class _SujetFiqh {
  final String titre;
  final IconData icone;
  final Color couleur;
  final String hanafi;
  final String maliki;
  final String shafii;
  final String hanbali;

  const _SujetFiqh({
    required this.titre,
    required this.icone,
    required this.couleur,
    required this.hanafi,
    required this.maliki,
    required this.shafii,
    required this.hanbali,
  });
}
