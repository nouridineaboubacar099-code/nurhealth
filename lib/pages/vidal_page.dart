// ============================================================
//  NurHealth — Vidal Médical (Accès Médecins uniquement)
//  lib/pages/vidal_page.dart
// ============================================================

import 'package:flutter/material.dart';

const Color kVert      = Color(0xFF1B5E20);
const Color kOr        = Color(0xFFFFD700);
const Color kBlanc     = Color(0xFFFFFFFF);
const Color kFond      = Color(0xFFF8F9FA);
const Color kBleuMed   = Color(0xFF0D47A1);
const Color kRouge     = Color(0xFFC62828);
const Color kOrange    = Color(0xFFE65100);

// ============================================================
//  GARDE D'ACCÈS — Vérification médecin
// ============================================================
class VidalGardePage extends StatefulWidget {
  final bool estMedecin;
  const VidalGardePage({super.key, required this.estMedecin});

  @override
  State<VidalGardePage> createState() => _VidalGardePageState();
}

class _VidalGardePageState extends State<VidalGardePage> {
  final _codeController = TextEditingController();
  bool _erreur = false;
  bool _acces = false;

  // Code PIN médecin (en production : vérifier via Firebase)
  static const String _codeMedecin = 'MED2025';

  @override
  void initState() {
    super.initState();
    // Si déjà médecin vérifié via le profil Firebase
    if (widget.estMedecin) _acces = true;
  }

  void _verifier() {
    if (_codeController.text.trim().toUpperCase() == _codeMedecin) {
      setState(() { _acces = true; _erreur = false; });
    } else {
      setState(() => _erreur = true);
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_acces || widget.estMedecin) {
      return const VidalPage();
    }
    return _PageVerification(
      controller: _codeController,
      erreur: _erreur,
      onVerifier: _verifier,
    );
  }
}

// ── Écran de vérification ─────────────────────────────────
class _PageVerification extends StatelessWidget {
  final TextEditingController controller;
  final bool erreur;
  final VoidCallback onVerifier;

  const _PageVerification({
    required this.controller,
    required this.erreur,
    required this.onVerifier,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kFond,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icône
                Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(
                    color: kBleuMed,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(
                      color: kBleuMed.withValues(alpha: 0.3),
                      blurRadius: 20,
                    )],
                  ),
                  child: const Icon(Icons.medical_information, color: kBlanc, size: 50),
                ),
                const SizedBox(height: 24),

                const Text('Vidal Médical',
                  style: TextStyle(
                    fontSize: 26, fontWeight: FontWeight.bold, color: kBleuMed)),
                const SizedBox(height: 8),
                Text(
                  'Accès réservé aux médecins vérifiés',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 4),
                Text(
                  'Medical reference • مرجع طبي',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                ),

                const SizedBox(height: 32),

                // Champ code
                Container(
                  decoration: BoxDecoration(
                    color: kBlanc,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: erreur ? Colors.red.shade400 : Colors.grey.shade300,
                      width: erreur ? 1.5 : 1,
                    ),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
                  ),
                  child: TextField(
                    controller: controller,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold,
                      letterSpacing: 4, color: kBleuMed,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Code médecin',
                      hintStyle: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.normal,
                        letterSpacing: 0, color: Colors.grey.shade400,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      prefixIcon: Icon(Icons.lock_outline, color: kBleuMed),
                    ),
                    onSubmitted: (_) => onVerifier(),
                  ),
                ),

                if (erreur) ...[
                  const SizedBox(height: 8),
                  Text(
                    '❌ Code incorrect. Contactez l\'administration.',
                    style: TextStyle(color: Colors.red.shade600, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],

                const SizedBox(height: 20),

                // Bouton
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onVerifier,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kBleuMed,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 4,
                    ),
                    child: const Text('Accéder au Vidal',
                      style: TextStyle(color: kBlanc, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),

                const SizedBox(height: 20),

                // Info
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: kBleuMed.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kBleuMed.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.info_outline, color: kBleuMed, size: 20),
                      const SizedBox(height: 6),
                      Text(
                        'Ce module contient des informations médicales professionnelles destinées aux praticiens de santé. L\'accès non autorisé est interdit.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600, height: 1.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
//  PAGE PRINCIPALE VIDAL
// ============================================================
class VidalPage extends StatefulWidget {
  const VidalPage({super.key});

  @override
  State<VidalPage> createState() => _VidalPageState();
}

class _VidalPageState extends State<VidalPage> with SingleTickerProviderStateMixin {
  late TabController _tabs;
  String _recherche = '';
  final _rechercheCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    _rechercheCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kFond,
      body: Column(
        children: [
          // ── AppBar ───────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [kBleuMed, Color(0xFF1565C0)],
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
                        const Icon(Icons.medical_information, color: kOr, size: 28),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Vidal Médical',
                                style: TextStyle(color: kBlanc, fontSize: 18, fontWeight: FontWeight.bold)),
                              Text('Réservé aux médecins • For doctors only',
                                style: TextStyle(color: Colors.white60, fontSize: 11)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.shade600,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified, color: kBlanc, size: 14),
                              SizedBox(width: 4),
                              Text('Médecin', style: TextStyle(color: kBlanc, fontSize: 11)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Barre de recherche
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _rechercheCtrl,
                        style: const TextStyle(color: kBlanc),
                        decoration: const InputDecoration(
                          hintText: 'Rechercher médicament, molécule, pathologie...',
                          hintStyle: TextStyle(color: Colors.white54, fontSize: 13),
                          prefixIcon: Icon(Icons.search, color: Colors.white54),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        onChanged: (v) => setState(() => _recherche = v.toLowerCase()),
                      ),
                    ),
                  ),
                  TabBar(
                    controller: _tabs,
                    isScrollable: true,
                    indicatorColor: kOr,
                    labelColor: kOr,
                    unselectedLabelColor: Colors.white60,
                    tabs: const [
                      Tab(icon: Icon(Icons.medication, size: 18), text: 'Médicaments'),
                      Tab(icon: Icon(Icons.science, size: 18), text: 'Molécules'),
                      Tab(icon: Icon(Icons.local_hospital, size: 18), text: 'Pathologies'),
                      Tab(icon: Icon(Icons.warning_amber, size: 18), text: 'Urgences'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Contenu ──────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _VueMedicaments(recherche: _recherche),
                _VueMolecules(recherche: _recherche),
                _VuePathologies(recherche: _recherche),
                _VueUrgences(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
//  ONGLET 1 — MÉDICAMENTS
// ============================================================
class _VueMedicaments extends StatelessWidget {
  final String recherche;
  const _VueMedicaments({required this.recherche});

  final List<_Medicament> _medicaments = const [
    _Medicament(
      nom: 'Amoxicilline 500mg',
      molecule: 'Amoxicilline',
      classe: 'Antibiotique — Pénicilline',
      indication: 'Infections bactériennes ORL, respiratoires, urinaires, dentaires',
      posologie: 'Adulte : 500mg × 3/j (toutes les 8h) pendant 7-10 jours\nEnfant : 50-100 mg/kg/j en 3 prises',
      contreIndications: '• Allergie aux pénicillines ou céphalosporines\n• Mononucléose infectieuse (risque d\'exanthème)',
      effetsIndesirables: 'Diarrhées, nausées, candidose, rash cutané, rarement anaphylaxie',
      interactions: 'Méthotrexate (toxicité augmentée), anticoagulants (potentialisation)',
      couleur: Color(0xFF1565C0),
      icone: Icons.coronavirus,
      grossesse: 'Compatible (catégorie B)',
      allaitement: 'Compatible avec précaution',
    ),
    _Medicament(
      nom: 'Paracétamol 500mg',
      molecule: 'Paracétamol (Acétaminophène)',
      classe: 'Antalgique — Antipyrétique',
      indication: 'Douleurs légères à modérées, fièvre',
      posologie: 'Adulte : 500mg à 1g toutes les 4-6h. Max 4g/jour\nEnfant : 15 mg/kg toutes les 6h. Max 60 mg/kg/j',
      contreIndications: '• Insuffisance hépatique sévère\n• Hypersensibilité au paracétamol\n• Alcoolisme chronique',
      effetsIndesirables: 'Bien toléré aux doses thérapeutiques. Hépatotoxicité en cas de surdosage',
      interactions: 'Warfarine (augmentation INR), alcool (hépatotoxicité), rifampicine (métabolisme accéléré)',
      couleur: Color(0xFF2E7D32),
      icone: Icons.thermostat,
      grossesse: 'Compatible (1er choix antalgique)',
      allaitement: 'Compatible',
    ),
    _Medicament(
      nom: 'Ibuprofène 400mg',
      molecule: 'Ibuprofène',
      classe: 'AINS — Anti-inflammatoire non stéroïdien',
      indication: 'Douleurs, inflammation, fièvre, dysménorrhée',
      posologie: 'Adulte : 400mg toutes les 6-8h avec repas. Max 2400mg/j\nEnfant >6 mois : 5-10 mg/kg toutes les 6-8h',
      contreIndications: '• Ulcère gastroduodénal actif\n• Insuffisance rénale/hépatique sévère\n• 3ème trimestre grossesse\n• Syndrome de Widal (aspirine-asthme)',
      effetsIndesirables: 'Troubles digestifs, ulcère, hémorragie digestive, insuffisance rénale aiguë, risque cardiovasculaire',
      interactions: 'Anticoagulants, aspirine, lithium, méthotrexate, antihypertenseurs (réduction d\'effet)',
      couleur: Color(0xFFE65100),
      icone: Icons.inflammation_outlined,
      grossesse: 'Contre-indiqué au 3ème trimestre',
      allaitement: 'Compatible avec précaution',
    ),
    _Medicament(
      nom: 'Métronidazole 500mg',
      molecule: 'Métronidazole',
      classe: 'Antibiotique — Antiparasitaire — Imidazolé',
      indication: 'Infections anaérobies, amibiase, giardiase, trichomonase, vaginose bactérienne',
      posologie: 'Amibiase intestinale : 750mg × 3/j pendant 10 jours\nGiardiase : 2g dose unique ou 500mg × 3/j 5-7 jours\nTrichomonase : 2g dose unique',
      contreIndications: '• Hypersensibilité aux imidazolés\n• 1er trimestre de grossesse\n• Prise d\'alcool (effet antabuse sévère)',
      effetsIndesirables: 'Nausées, goût métallique, neurotoxicité à forte dose, coloration des urines',
      interactions: 'Alcool (effet antabuse), warfarine (augmentation INR), lithium (toxicité)',
      couleur: Color(0xFF880E4F),
      icone: Icons.bug_report,
      grossesse: 'Contre-indiqué au 1er trimestre',
      allaitement: 'Interrompe l\'allaitement pendant traitement',
    ),
    _Medicament(
      nom: 'Artéméther + Luméfantrine',
      molecule: 'Artéméther / Luméfantrine',
      classe: 'Antipaludéen — CTA (Combinaison Thérapeutique à base d\'Artémisinine)',
      indication: 'Paludisme à Plasmodium falciparum non compliqué',
      posologie: '6 prises sur 3 jours — Dose selon poids :\n5-14 kg : 1 cp par prise\n15-24 kg : 2 cp par prise\n25-34 kg : 3 cp par prise\n>34 kg : 4 cp par prise\nPrendre avec repas gras pour meilleure absorption',
      contreIndications: '• Hypersensibilité\n• QT allongé\n• Arythmie cardiaque\n• Paludisme sévère (IV requis)',
      effetsIndesirables: 'Maux de tête, vertiges, nausées, vomissements, arthralgies, anémie hémolytique',
      interactions: 'Médicaments allongeant le QT, antiviraux, rifampicine (réduction efficacité)',
      couleur: Color(0xFF00695C),
      icone: Icons.pest_control,
      grossesse: 'Utilisable si bénéfice > risque (2ème-3ème trimestre)',
      allaitement: 'Précaution',
    ),
    _Medicament(
      nom: 'ORS — Sels de Réhydratation',
      molecule: 'NaCl + KCl + Citrate de sodium + Glucose',
      classe: 'Solution de réhydratation orale (OMS)',
      indication: 'Déshydratation par diarrhée aiguë, vomissements, choléra',
      posologie: 'Enfant <2 ans : 50-100 mL/kg sur 4-6h après chaque selle\nEnfant >2 ans : 100-200 mL/kg\nAdulte : Ad libitum — au moins 1L/h en phase aiguë de choléra\nPréparation : 1 sachet dans 1L eau potable propre',
      contreIndications: '• Iléus paralytique\n• Déshydratation sévère (voie IV préférable)\n• Trouble de conscience (risque d\'inhalation)',
      effetsIndesirables: 'Hypernatrémie si administré en excès',
      interactions: 'Aucune interaction médicamenteuse significative',
      couleur: Color(0xFF0277BD),
      icone: Icons.water_drop,
      grossesse: 'Indiqué et sans risque',
      allaitement: 'Indiqué et sans risque',
    ),
    _Medicament(
      nom: 'Cotrimoxazole (SMX/TMP)',
      molecule: 'Sulfaméthoxazole + Triméthoprime',
      classe: 'Antibiotique — Sulfamide',
      indication: 'Infections urinaires, pneumocystose, prophylaxie VIH, toxoplasmose',
      posologie: 'Infection urinaire simple : 960mg × 2/j pendant 3-7 jours\nProphylaxie VIH : 960mg/j\nPneumocystose : 15-20 mg/kg/j (TMP) en 3-4 prises',
      contreIndications: '• Allergie aux sulfamides\n• Insuffisance hépatique/rénale sévère\n• Déficit en G6PD\n• Grossesse (3ème trimestre) et nourrisson <1 mois',
      effetsIndesirables: 'Rash cutané, syndrome de Stevens-Johnson (rare), anémie hémolytique, néphrotoxicité',
      interactions: 'Warfarine (augmentation INR), phénytoïne, méthotrexate, ciclosporine',
      couleur: Color(0xFF4A148C),
      icone: Icons.medication_liquid,
      grossesse: 'Éviter au 1er trimestre et en fin de grossesse',
      allaitement: 'Déconseillé',
    ),
    _Medicament(
      nom: 'Diazépam 5mg',
      molecule: 'Diazépam',
      classe: 'Benzodiazépine — Anxiolytique / Anticonvulsivant',
      indication: 'Anxiété, sevrage alcoolique, convulsions, spasmes musculaires, prémédication',
      posologie: 'Anxiété : 2-10mg × 2-4/j\nConvulsions (adulte) : 5-10mg IV lent\nÉtat de mal épileptique : 10-20mg IV en perfusion\nEnfant (convulsion fébrile) : 0.3-0.5 mg/kg rectale',
      contreIndications: '• Insuffisance respiratoire sévère\n• Syndrome d\'apnée du sommeil\n• Glaucome à angle fermé\n• Myasthénie grave\n• Dépendance aux benzodiazépines',
      effetsIndesirables: 'Sédation, ataxie, troubles de mémoire, dépendance, dépression respiratoire en IV rapide',
      interactions: 'Alcool (dépression SNC), opioïdes, antidépresseurs, antiépileptiques',
      couleur: Color(0xFF37474F),
      icone: Icons.psychology,
      grossesse: 'Contre-indiqué (syndrome de sevrage néonatal)',
      allaitement: 'Contre-indiqué',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filtres = _medicaments.where((m) =>
      recherche.isEmpty ||
      m.nom.toLowerCase().contains(recherche) ||
      m.molecule.toLowerCase().contains(recherche) ||
      m.classe.toLowerCase().contains(recherche) ||
      m.indication.toLowerCase().contains(recherche)
    ).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: filtres.length,
      itemBuilder: (_, i) => _CarteMedicament(med: filtres[i]),
    );
  }
}

class _CarteMedicament extends StatefulWidget {
  final _Medicament med;
  const _CarteMedicament({required this.med});

  @override
  State<_CarteMedicament> createState() => _CarteMedicamentState();
}

class _CarteMedicamentState extends State<_CarteMedicament> {
  bool _ouvert = false;

  @override
  Widget build(BuildContext context) {
    final m = widget.med;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: kBlanc,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _ouvert ? m.couleur : Colors.grey.shade200),
        boxShadow: [BoxShadow(
          color: _ouvert ? m.couleur.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.04),
          blurRadius: 8,
        )],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _ouvert = !_ouvert),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 46, height: 46,
                    decoration: BoxDecoration(
                      color: m.couleur,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(m.icone, color: kBlanc, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(m.nom,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        Text(m.molecule,
                          style: TextStyle(fontSize: 12, color: m.couleur, fontWeight: FontWeight.w500)),
                        Text(m.classe,
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                  Icon(_ouvert ? Icons.expand_less : Icons.expand_more, color: m.couleur),
                ],
              ),
            ),
          ),
          if (_ouvert) ...[
            Divider(height: 1, color: m.couleur.withValues(alpha: 0.2)),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  _LigneVidal(Icons.check_circle_outline, 'Indication', m.indication, Colors.green.shade700),
                  _LigneVidal(Icons.medication, 'Posologie', m.posologie, kBleuMed),
                  _LigneVidal(Icons.block, 'Contre-indications', m.contreIndications, kRouge),
                  _LigneVidal(Icons.warning_amber, 'Effets indésirables', m.effetsIndesirables, kOrange),
                  _LigneVidal(Icons.swap_horiz, 'Interactions', m.interactions, const Color(0xFF6A1B9A)),
                  _LigneVidal(Icons.pregnant_woman, 'Grossesse', m.grossesse, const Color(0xFF880E4F)),
                  _LigneVidal(Icons.child_care, 'Allaitement', m.allaitement, const Color(0xFF00695C)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LigneVidal extends StatelessWidget {
  final IconData icone;
  final String titre;
  final String contenu;
  final Color couleur;

  const _LigneVidal(this.icone, this.titre, this.contenu, this.couleur);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: couleur.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border(left: BorderSide(color: couleur, width: 3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, color: couleur, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titre,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: couleur)),
                const SizedBox(height: 3),
                Text(contenu,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF333333), height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
//  ONGLET 2 — MOLÉCULES
// ============================================================
class _VueMolecules extends StatelessWidget {
  final String recherche;
  const _VueMolecules({required this.recherche});

  final List<_Molecule> _molecules = const [
    _Molecule('Pénicillines', 'Amoxicilline, Ampicilline, Oxacilline', 'Inhibent la synthèse de la paroi bactérienne. Bactéricides contre les bactéries Gram+.', Color(0xFF1565C0)),
    _Molecule('Macrolides', 'Azithromycine, Érythromycine, Clarithromycine', 'Inhibent la synthèse protéique (50S). Bactériostatiques. Allergie aux pénicillines = alternative.', Color(0xFF2E7D32)),
    _Molecule('Fluoroquinolones', 'Ciprofloxacine, Ofloxacine, Levofloxacine', 'Inhibent l\'ADN gyrase et la topo-isomérase IV. Bactéricides à large spectre.', Color(0xFFE65100)),
    _Molecule('Aminoglycosides', 'Gentamicine, Amikacine, Tobramycine', 'Inhibent la traduction ribosomale (30S). Bactéricides. Ototoxicité et néphrotoxicité.', Color(0xFF6A1B9A)),
    _Molecule('Artémisinines', 'Artéméther, Artésunate, Dihydroartémisinine', 'Actifs sur les formes asexuées du Plasmodium. Élimination rapide des parasites.', Color(0xFF00695C)),
    _Molecule('Corticoïdes', 'Prednisone, Dexaméthasone, Hydrocortisone', 'Anti-inflammatoires puissants. Agissent sur les récepteurs nucléaires glucocorticoïdes.', Color(0xFFBF360C)),
    _Molecule('Inhibiteurs ECA', 'Captopril, Énalapril, Lisinopril', 'Inhibent l\'enzyme de conversion. Indiqués dans HTA, insuffisance cardiaque, néphropathie diabétique.', Color(0xFF0D47A1)),
    _Molecule('Statines', 'Atorvastatine, Simvastatine, Rosuvastatine', 'Inhibent la HMG-CoA réductase. Réduction du LDL-cholestérol. Prévention cardiovasculaire.', Color(0xFF880E4F)),
    _Molecule('Benzodiazépines', 'Diazépam, Lorazépam, Clonazépam', 'Potentialisent l\'effet GABA-A. Anxiolytiques, hypnotiques, anticonvulsivants, myorelaxants.', Color(0xFF37474F)),
    _Molecule('Opioïdes', 'Morphine, Codéine, Tramadol, Fentanyl', 'Agonistes des récepteurs opioïdes μ (mu). Antalgiques centraux puissants. Risque de dépendance.', Color(0xFFC62828)),
  ];

  @override
  Widget build(BuildContext context) {
    final filtres = _molecules.where((m) =>
      recherche.isEmpty ||
      m.nom.toLowerCase().contains(recherche) ||
      m.exemples.toLowerCase().contains(recherche) ||
      m.mecanisme.toLowerCase().contains(recherche)
    ).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: filtres.length,
      itemBuilder: (_, i) {
        final m = filtres[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: kBlanc,
            borderRadius: BorderRadius.circular(14),
            border: Border(left: BorderSide(color: m.couleur, width: 4)),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(m.nom,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: m.couleur)),
              const SizedBox(height: 4),
              Text(m.exemples,
                style: const TextStyle(fontSize: 12, color: Color(0xFF555555), fontStyle: FontStyle.italic)),
              const SizedBox(height: 8),
              Text(m.mecanisme,
                style: const TextStyle(fontSize: 13, color: Color(0xFF333333), height: 1.5)),
            ],
          ),
        );
      },
    );
  }
}

// ============================================================
//  ONGLET 3 — PATHOLOGIES
// ============================================================
class _VuePathologies extends StatelessWidget {
  final String recherche;
  const _VuePathologies({required this.recherche});

  final List<_Pathologie> _pathologies = const [
    _Pathologie(
      nom: 'Paludisme (Malaria)',
      code: 'B50-B54',
      signes: 'Fièvre (>38.5°C) rythmée, frissons, sueurs, céphalées, myalgies, splénomégalie. Chez l\'enfant : convulsions fébriles, anémie.',
      diagnostic: 'TDR (Test de Diagnostic Rapide) positif. Frottis sanguin + goutte épaisse.',
      traitement: 'Non compliqué : Artéméther-Luméfantrine ou AS-AQ (artésunate-amodiaquine)\nGrave : Artésunate IV 2.4 mg/kg à H0, H12, H24 puis quotidien',
      couleur: Color(0xFF00695C),
      icone: Icons.pest_control,
    ),
    _Pathologie(
      nom: 'Diarrhée aiguë',
      code: 'A09',
      signes: 'Selles liquides >3/jour, crampes abdominales, nausées, vomissements. Signes de déshydratation : soif intense, oligurie, turgescence cutanée diminuée.',
      diagnostic: 'Clinique. Coproculture si selles sanglantes ou contexte épidémique.',
      traitement: 'Réhydratation : ORS oral ou Ringer Lactate IV si sévère\nZinc 20mg/j × 10 jours chez l\'enfant\nAntibiotiques si dysenterie : Ciprofloxacine 500mg × 2/j × 3 jours',
      couleur: Color(0xFF0277BD),
      icone: Icons.water_drop,
    ),
    _Pathologie(
      nom: 'Pneumonie communautaire',
      code: 'J18',
      signes: 'Fièvre, toux productive, dyspnée, douleur thoracique, crépitants à l\'auscultation. Chez l\'enfant : tirage sous-costal, battement des ailes du nez.',
      diagnostic: 'Radiographie thoracique (infiltrat/condensation). NFS, CRP, hémocultures.',
      traitement: 'Ambulatoire : Amoxicilline 1g × 3/j × 7 jours\nHospitalisé : Amoxicilline-Clavulanate + Macrolide IV\nSévère : Ceftriaxone 1-2g/j + Azithromycine',
      couleur: Color(0xFF1565C0),
      icone: Icons.air,
    ),
    _Pathologie(
      nom: 'Hypertension artérielle',
      code: 'I10',
      signes: 'TA ≥ 140/90 mmHg à 2 mesures distinctes. Souvent asymptomatique. Céphalées occipitales, vertiges en cas de poussée hypertensive.',
      diagnostic: 'MAPA (Mesure Ambulatoire sur 24h). Bilan : ECG, fond d\'œil, créatinine, protéinurie, glycémie.',
      traitement: '1ère intention : Amlodipine 5-10mg/j OU Énalapril 5-20mg/j\nSi non contrôlé : Association AINS + IEC\nUrgence hypertensive (>180/120) : Nicardipine IV ou Labetalol IV',
      couleur: Color(0xFFC62828),
      icone: Icons.monitor_heart,
    ),
    _Pathologie(
      nom: 'Diabète de type 2',
      code: 'E11',
      signes: 'Polyurie, polydipsie, polyphagie, amaigrissement. Glycémie à jeun ≥ 1.26 g/L à 2 reprises ou ≥ 2 g/L à tout moment.',
      diagnostic: 'Glycémie à jeun, HbA1c (≥6.5%), test HGPO.',
      traitement: 'MHD (Mesures Hygiéno-Diététiques) + Metformine 500-3000 mg/j\nSi HbA1c > 7.5% : Ajouter Glibenclamide ou Insuline\nObjectif HbA1c < 7%',
      couleur: Color(0xFF6A1B9A),
      icone: Icons.bloodtype,
    ),
    _Pathologie(
      nom: 'Tuberculose pulmonaire',
      code: 'A15',
      signes: 'Toux chronique > 2 semaines, hémoptysie, amaigrissement, sueurs nocturnes, fièvre vespérale, adénopathies.',
      diagnostic: 'Bacilloscopie des crachats (BAAR × 3). Radiographie thoracique (infiltrats apicaux, excavations). Xpert MTB/RIF.',
      traitement: 'Phase intensive (2 mois) : RHZE (Rifampicine + Isoniazide + Pyrazinamide + Éthambutol)\nPhase de continuation (4 mois) : RH\nTOD (Traitement Observé Directement) obligatoire',
      couleur: Color(0xFF880E4F),
      icone: Icons.biotech,
    ),
    _Pathologie(
      nom: 'Anémie',
      code: 'D64',
      signes: 'Pâleur conjonctivale, asthénie, dyspnée d\'effort, tachycardie, vertiges. Hb < 13 g/dL chez l\'homme, < 12 g/dL chez la femme.',
      diagnostic: 'NFS (VGM, CCMH, réticulocytes), fer sérique, ferritine, frottis sanguin, B12, folates.',
      traitement: 'Ferriprive : Sulfate ferreux 200mg × 2-3/j × 3-6 mois + Vitamine C\nParasitaire : Déparasitage + Supplémentation\nSévère (Hb <7) : Transfusion si symptomatique',
      couleur: Color(0xFFBF360C),
      icone: Icons.bloodtype,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filtres = _pathologies.where((p) =>
      recherche.isEmpty ||
      p.nom.toLowerCase().contains(recherche) ||
      p.code.toLowerCase().contains(recherche) ||
      p.signes.toLowerCase().contains(recherche) ||
      p.traitement.toLowerCase().contains(recherche)
    ).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: filtres.length,
      itemBuilder: (_, i) => _CartePathologie(patho: filtres[i]),
    );
  }
}

class _CartePathologie extends StatefulWidget {
  final _Pathologie patho;
  const _CartePathologie({required this.patho});

  @override
  State<_CartePathologie> createState() => _CartePathologieState();
}

class _CartePathologieState extends State<_CartePathologie> {
  bool _ouvert = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.patho;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: kBlanc,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _ouvert ? p.couleur : Colors.grey.shade200),
        boxShadow: [BoxShadow(
          color: _ouvert ? p.couleur.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.04),
          blurRadius: 8,
        )],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _ouvert = !_ouvert),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 46, height: 46,
                    decoration: BoxDecoration(color: p.couleur, borderRadius: BorderRadius.circular(12)),
                    child: Icon(p.icone, color: kBlanc, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.nom,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        Text('CIM-10 : ${p.code}',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                  Icon(_ouvert ? Icons.expand_less : Icons.expand_more, color: p.couleur),
                ],
              ),
            ),
          ),
          if (_ouvert) ...[
            Divider(height: 1, color: p.couleur.withValues(alpha: 0.2)),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  _LigneVidal(Icons.visibility, 'Signes cliniques', p.signes, Colors.blue.shade700),
                  _LigneVidal(Icons.science, 'Diagnostic', p.diagnostic, Colors.purple.shade700),
                  _LigneVidal(Icons.healing, 'Traitement', p.traitement, Colors.green.shade700),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ============================================================
//  ONGLET 4 — URGENCES
// ============================================================
class _VueUrgences extends StatelessWidget {
  const _VueUrgences();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _CarteUrgence(
          titre: '🫀 Arrêt Cardio-Respiratoire (ACR)',
          couleur: kRouge,
          etapes: [
            'Vérifier la conscience : stimuler, appeler',
            'Appeler les secours + chercher défibrillateur',
            'Pas de respiration → RCP : 30 compressions (100-120/min) + 2 insufflations',
            'Comprimer fort (5-6 cm) sur le centre du thorax',
            'Continuer jusqu\'au retour de conscience ou arrivée des secours',
            'Défibrillation dès que disponible',
          ],
        ),
        _CarteUrgence(
          titre: '🩸 Choc Hémorragique',
          couleur: Color(0xFFBF360C),
          etapes: [
            'Comprimer le site de saignement (pansement compressif)',
            'Position jambes surélevées (Trendelenburg si hypotension)',
            'Voie veineuse × 2 larges calibres',
            'Remplissage : Ringer Lactate 1-2L rapide',
            'Transfusion si Hb < 7 g/dL ou choc persistant',
            'Bilan : NFS, TP/TCA, groupage, lactates',
          ],
        ),
        _CarteUrgence(
          titre: '⚡ État de Mal Épileptique',
          couleur: Color(0xFF37474F),
          etapes: [
            'Protéger le patient (écarter objets dangereux)',
            'Position latérale de sécurité (PLS)',
            'Diazépam 10mg IV lent OU Midazolam buccal 10mg',
            'Si persistance > 5 min : répéter la dose',
            'Si persistance > 20 min : Phénytoïne 15-20 mg/kg IV',
            'Chercher la cause : hypoglycémie, fièvre, médicaments',
          ],
        ),
        _CarteUrgence(
          titre: '🌡️ Paludisme Grave (Enfant)',
          couleur: Color(0xFF00695C),
          etapes: [
            'Artésunate IV : 2.4 mg/kg à H0, H12, H24, puis 1×/j',
            'Si artésunate indisponible : Quinine 20 mg/kg sur 4h (dose de charge)',
            'Gestion hypoglycémie : Dextrose 10% si glycémie < 2.5 mmol/L',
            'Transfusion si anémie sévère (Hb < 5 g/dL)',
            'Antipyrétique : Paracétamol IV ou rectal',
            'Surveillance conscience, glycémie, diurèse',
          ],
        ),
        _CarteUrgence(
          titre: '😮‍💨 Crise d\'Asthme Sévère',
          couleur: Color(0xFF0277BD),
          etapes: [
            'Position assise, O2 à haut débit (≥ 8 L/min)',
            'Salbutamol nébulisé 5mg (ou 4-8 bouffées chambre inhalation)',
            'Répéter toutes les 20 min si nécessaire',
            'Corticoïdes : Prednisone 40-60 mg PO ou Hydrocortisone 100mg IV',
            'Si pas d\'amélioration : Bromure d\'ipratropium nébulisé',
            'Intubation si épuisement, cyanose, pause respiratoire',
          ],
        ),
        _CarteUrgence(
          titre: '💊 Surdosage / Intoxication',
          couleur: Color(0xFF4A148C),
          etapes: [
            'Identifier le toxique (médicament, heure, quantité)',
            'Ne PAS faire vomir si caustiques ou hydrocarbures',
            'Charbon activé 50g si ingestion < 1h (adulte)',
            'Voie veineuse, bilan biologique, scope',
            'Antidotes spécifiques : Naloxone (opioïdes), Flumazénil (benzodiazépines), N-Acétylcystéine (paracétamol)',
            'Contacter le Centre Antipoison si doute',
          ],
        ),
      ],
    );
  }
}

class _CarteUrgence extends StatefulWidget {
  final String titre;
  final Color couleur;
  final List<String> etapes;

  const _CarteUrgence({required this.titre, required this.couleur, required this.etapes});

  @override
  State<_CarteUrgence> createState() => _CarteUrgenceState();
}

class _CarteUrgenceState extends State<_CarteUrgence> {
  bool _ouvert = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: kBlanc,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _ouvert ? widget.couleur : Colors.grey.shade200),
        boxShadow: [BoxShadow(
          color: _ouvert ? widget.couleur.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.04),
          blurRadius: 8,
        )],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _ouvert = !_ouvert),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(widget.titre,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: widget.couleur,
                      )),
                  ),
                  Icon(_ouvert ? Icons.expand_less : Icons.expand_more, color: widget.couleur),
                ],
              ),
            ),
          ),
          if (_ouvert) ...[
            Divider(height: 1, color: widget.couleur.withValues(alpha: 0.2)),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                children: widget.etapes.asMap().entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24, height: 24,
                        decoration: BoxDecoration(color: widget.couleur, shape: BoxShape.circle),
                        child: Center(child: Text('${e.key + 1}',
                          style: const TextStyle(color: kBlanc, fontSize: 11, fontWeight: FontWeight.bold))),
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Text(e.value,
                        style: const TextStyle(fontSize: 13, color: Color(0xFF333333), height: 1.5))),
                    ],
                  ),
                )).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ============================================================
//  MODÈLES DE DONNÉES
// ============================================================

class _Medicament {
  final String nom, molecule, classe, indication, posologie;
  final String contreIndications, effetsIndesirables, interactions;
  final String grossesse, allaitement;
  final Color couleur;
  final IconData icone;

  const _Medicament({
    required this.nom, required this.molecule, required this.classe,
    required this.indication, required this.posologie,
    required this.contreIndications, required this.effetsIndesirables,
    required this.interactions, required this.grossesse, required this.allaitement,
    required this.couleur, required this.icone,
  });
}

class _Molecule {
  final String nom, exemples, mecanisme;
  final Color couleur;
  const _Molecule(this.nom, this.exemples, this.mecanisme, this.couleur);
}

class _Pathologie {
  final String nom, code, signes, diagnostic, traitement;
  final Color couleur;
  final IconData icone;
  const _Pathologie({
    required this.nom, required this.code, required this.signes,
    required this.diagnostic, required this.traitement,
    required this.couleur, required this.icone,
  });
}
