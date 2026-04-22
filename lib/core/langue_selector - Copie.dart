// ============================================================
//  NurHealth — Sélecteur de Langue
//  lib/widgets/langue_selector.dart
// ============================================================

import 'package:flutter/material.dart';
import '../l10n/app_translations.dart';

const Color kVert     = Color(0xFF1B5E20);
const Color kOr       = Color(0xFFFFD700);
const Color kBlanc    = Color(0xFFFFFFFF);

// ── Widget compact (dans AppBar ou menu) ──────────────────
class BoutonLangue extends StatefulWidget {
  final VoidCallback? onLangueChange;
  const BoutonLangue({super.key, this.onLangueChange});

  @override
  State<BoutonLangue> createState() => _BoutonLangueState();
}

class _BoutonLangueState extends State<BoutonLangue> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          builder: (_) => _SheetLangue(
            onChoisir: (l) {
              setState(() => LangueManager.changer(l));
              widget.onLangueChange?.call();
            },
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: kOr.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: kOr.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.language, color: kOr, size: 16),
            const SizedBox(width: 6),
            Text(
              LangueManager.nomLangue,
              style: const TextStyle(color: kOr, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sheet de sélection ────────────────────────────────────
class _SheetLangue extends StatelessWidget {
  final Function(AppLangue) onChoisir;
  const _SheetLangue({required this.onChoisir});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: kBlanc,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Barre
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Choisir la langue / Choose language / Zaɓi harshe',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: kVert),
          ),
          const SizedBox(height: 20),
          _ItemLangue(
            drapeau: '🇫🇷',
            nom: 'Français',
            sousNom: 'French • Faransanci',
            langue: AppLangue.francais,
            actif: LangueManager.langue == AppLangue.francais,
            onTap: () { onChoisir(AppLangue.francais); Navigator.pop(context); },
          ),
          const SizedBox(height: 10),
          _ItemLangue(
            drapeau: '🇬🇧',
            nom: 'English',
            sousNom: 'Anglais • Turanci',
            langue: AppLangue.anglais,
            actif: LangueManager.langue == AppLangue.anglais,
            onTap: () { onChoisir(AppLangue.anglais); Navigator.pop(context); },
          ),
          const SizedBox(height: 10),
          _ItemLangue(
            drapeau: '🇳🇪',
            nom: 'Hausa',
            sousNom: 'Haoussa • هوسا',
            langue: AppLangue.haoussa,
            actif: LangueManager.langue == AppLangue.haoussa,
            onTap: () { onChoisir(AppLangue.haoussa); Navigator.pop(context); },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _ItemLangue extends StatelessWidget {
  final String drapeau;
  final String nom;
  final String sousNom;
  final AppLangue langue;
  final bool actif;
  final VoidCallback onTap;

  const _ItemLangue({
    required this.drapeau,
    required this.nom,
    required this.sousNom,
    required this.langue,
    required this.actif,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: actif ? kVert.withValues(alpha: 0.08) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: actif ? kVert : Colors.grey.shade200,
            width: actif ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(drapeau, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(nom,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: actif ? kVert : Colors.black87,
                    )),
                  Text(sousNom,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                ],
              ),
            ),
            if (actif)
              Container(
                width: 28, height: 28,
                decoration: const BoxDecoration(color: kVert, shape: BoxShape.circle),
                child: const Icon(Icons.check, color: kBlanc, size: 16),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Page Paramètres complète ──────────────────────────────
class ParametresPage extends StatefulWidget {
  const ParametresPage({super.key});

  @override
  State<ParametresPage> createState() => _ParametresPageState();
}

class _ParametresPageState extends State<ParametresPage> {
  bool _notifPrieres    = true;
  bool _notifDhikr      = true;
  bool _notifSante      = false;
  bool _notifSadaqa     = true;

  @override
  Widget build(BuildContext context) {
    final t = LangueManager.t;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: kVert,
        title: Text(t.paramTitre,
          style: const TextStyle(color: kBlanc, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: kBlanc),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Langue ───────────────────────────────────────
          _SectionTitre(titre: t.paramLangue, icone: Icons.language),
          const SizedBox(height: 10),
          _CarteLangue(onChanger: () => setState(() {})),

          const SizedBox(height: 20),

          // ── Notifications ─────────────────────────────────
          _SectionTitre(titre: t.paramNotifications, icone: Icons.notifications_outlined),
          const SizedBox(height: 10),
          _CarteParametre(
            children: [
              _LigneSwitch(
                label: t.prieresFajr + ' — ' + t.prieresIcha,
                sousLabel: t.prieresNotification,
                icone: Icons.access_time,
                couleur: kVert,
                valeur: _notifPrieres,
                onChange: (v) => setState(() => _notifPrieres = v),
              ),
              const Divider(height: 1),
              _LigneSwitch(
                label: t.dhikrMatin,
                sousLabel: 'Rappel après Fajr',
                icone: Icons.wb_sunny_outlined,
                couleur: Colors.orange,
                valeur: _notifDhikr,
                onChange: (v) => setState(() => _notifDhikr = v),
              ),
              const Divider(height: 1),
              _LigneSwitch(
                label: t.santeTitre,
                sousLabel: 'Rappel santé quotidien',
                icone: Icons.favorite_outline,
                couleur: Colors.red.shade400,
                valeur: _notifSante,
                onChange: (v) => setState(() => _notifSante = v),
              ),
              const Divider(height: 1),
              _LigneSwitch(
                label: t.accueilSadaqa,
                sousLabel: 'Rappel de donner',
                icone: Icons.volunteer_activism_outlined,
                couleur: const Color(0xFFFFD700),
                valeur: _notifSadaqa,
                onChange: (v) => setState(() => _notifSadaqa = v),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── À propos ──────────────────────────────────────
          _SectionTitre(titre: t.paramAPropos, icone: Icons.info_outline),
          const SizedBox(height: 10),
          _CarteParametre(
            children: [
              _LigneInfo(
                icone: Icons.medical_services_outlined,
                label: 'NurHealth — نور الصحة',
                valeur: 'Version 2.0',
                couleur: kVert,
              ),
              const Divider(height: 1),
              _LigneInfo(
                icone: Icons.business,
                label: 'SOCIETE ANY-SERVICE SARL',
                valeur: 'Zinder, Niger',
                couleur: Colors.blue.shade700,
              ),
              const Divider(height: 1),
              _LigneInfo(
                icone: Icons.phone,
                label: 'Contact',
                valeur: '+227 96307928',
                couleur: Colors.green.shade700,
              ),
              const Divider(height: 1),
              _LigneInfo(
                icone: Icons.gavel,
                label: 'RCCM',
                valeur: 'NE-ZIN-2025-B-0221',
                couleur: Colors.grey.shade600,
              ),
            ],
          ),

          const SizedBox(height: 30),

          // ── Bismillah ─────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Text('بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: kOr, fontSize: 22, fontFamily: 'Amiri', height: 1.8)),
                const SizedBox(height: 8),
                Text(
                  t.accueilSousTitre,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: kBlanc, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ── Widgets auxiliaires ───────────────────────────────────

class _SectionTitre extends StatelessWidget {
  final String titre;
  final IconData icone;
  const _SectionTitre({required this.titre, required this.icone});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icone, size: 18, color: kVert),
        const SizedBox(width: 8),
        Text(titre,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: kVert,
          )),
      ],
    );
  }
}

class _CarteParametre extends StatelessWidget {
  final List<Widget> children;
  const _CarteParametre({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kBlanc,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(children: children),
    );
  }
}

class _CarteLangue extends StatelessWidget {
  final VoidCallback onChanger;
  const _CarteLangue({required this.onChanger});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kBlanc,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        children: AppLangue.values.map((l) {
          final actif = LangueManager.langue == l;
          final infos = {
            AppLangue.francais: ('🇫🇷', 'Français', 'French • Faransanci'),
            AppLangue.anglais:  ('🇬🇧', 'English', 'Anglais • Turanci'),
            AppLangue.haoussa:  ('🇳🇪', 'Hausa', 'Haoussa • هوسا'),
          }[l]!;

          return Column(
            children: [
              ListTile(
                leading: Text(infos.$1, style: const TextStyle(fontSize: 24)),
                title: Text(infos.$2,
                  style: TextStyle(
                    fontWeight: actif ? FontWeight.bold : FontWeight.normal,
                    color: actif ? kVert : Colors.black87,
                  )),
                subtitle: Text(infos.$3, style: const TextStyle(fontSize: 12)),
                trailing: actif
                    ? Container(
                        width: 28, height: 28,
                        decoration: const BoxDecoration(color: kVert, shape: BoxShape.circle),
                        child: const Icon(Icons.check, color: kBlanc, size: 16),
                      )
                    : null,
                onTap: () {
                  LangueManager.changer(l);
                  onChanger();
                },
              ),
              if (l != AppLangue.values.last) const Divider(height: 1),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _LigneSwitch extends StatelessWidget {
  final String label;
  final String sousLabel;
  final IconData icone;
  final Color couleur;
  final bool valeur;
  final Function(bool) onChange;

  const _LigneSwitch({
    required this.label,
    required this.sousLabel,
    required this.icone,
    required this.couleur,
    required this.valeur,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: couleur.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icone, color: couleur, size: 20),
      ),
      title: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      subtitle: Text(sousLabel, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
      trailing: Switch.adaptive(
        value: valeur,
        onChanged: onChange,
        activeColor: kVert,
      ),
    );
  }
}

class _LigneInfo extends StatelessWidget {
  final IconData icone;
  final String label;
  final String valeur;
  final Color couleur;

  const _LigneInfo({
    required this.icone,
    required this.label,
    required this.valeur,
    required this.couleur,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: couleur.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icone, color: couleur, size: 20),
      ),
      title: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      trailing: Text(valeur,
        style: TextStyle(fontSize: 12, color: couleur, fontWeight: FontWeight.w600)),
    );
  }
}
