// ============================================================
//  NurHealth — Riyad As-Salihin
//  lib/data/riyad_salihin_data.dart
// ============================================================

class ChapitreRiyad {
  final int numero;
  final String titre;
  final String titreArabe;
  final String introduction;
  final List<HadithRiyad> hadiths;

  const ChapitreRiyad({
    required this.numero,
    required this.titre,
    required this.titreArabe,
    required this.introduction,
    required this.hadiths,
  });
}

class HadithRiyad {
  final int numero;
  final String narrateur;
  final String texte;
  final String source;

  const HadithRiyad({
    required this.numero,
    required this.narrateur,
    required this.texte,
    required this.source,
  });
}

const List<ChapitreRiyad> riyadSalihin = [

  ChapitreRiyad(
    numero: 1,
    titre: 'L\'Intention (Niyya)',
    titreArabe: 'باب النية',
    introduction: 'Allah le Très-Haut dit : "Ils n\'ont été commandés que pour adorer Allah en Lui vouant sincèrement la religion." (Al-Bayyina : 5)',
    hadiths: [
      HadithRiyad(
        numero: 1,
        narrateur: 'Omar ibn Al-Khattab (qu\'Allah l\'agrée)',
        texte: 'Le Messager d\'Allah ﷺ a dit : "Les actes ne valent que par les intentions et chaque homme n\'obtient que ce qu\'il a eu l\'intention de faire."',
        source: 'Al-Bukhari et Muslim',
      ),
    ],
  ),

  ChapitreRiyad(
    numero: 2,
    titre: 'La Repentance (Tawba)',
    titreArabe: 'باب التوبة',
    introduction: 'Allah dit : "Revenez tous vers Allah, ô croyants, afin que vous réussissiez." (An-Nour : 31)',
    hadiths: [
      HadithRiyad(
        numero: 14,
        narrateur: 'Abou Hourayra (qu\'Allah l\'agrée)',
        texte: 'Le Messager d\'Allah ﷺ a dit : "Par Celui qui tient mon âme en Sa main ! Si vous ne péchiez pas, Allah vous ferait disparaître et ferait venir d\'autres gens qui pécheraient, et qui Lui demanderaient pardon, et Il leur pardonnerait."',
        source: 'Muslim',
      ),
      HadithRiyad(
        numero: 15,
        narrateur: 'Anas ibn Malik (qu\'Allah l\'agrée)',
        texte: 'Le Messager d\'Allah ﷺ a dit : "Allah est plus heureux du repentir de Son serviteur lorsque celui-ci se repent à Lui que l\'un de vous l\'est de retrouver sa chamelle perdue dans un endroit désertique."',
        source: 'Al-Bukhari et Muslim',
      ),
      HadithRiyad(
        numero: 16,
        narrateur: 'Abou Hourayra (qu\'Allah l\'agrée)',
        texte: 'Le Messager d\'Allah ﷺ a dit : "Allah étend Sa main la nuit pour accepter le repentir du pécheur du jour, et étend Sa main le jour pour accepter le repentir du pécheur de la nuit — jusqu\'à ce que le soleil se lève à l\'Occident."',
        source: 'Muslim',
      ),
    ],
  ),

  ChapitreRiyad(
    numero: 3,
    titre: 'La Persévérance et la Constance (Sabr)',
    titreArabe: 'باب الصبر',
    introduction: 'Allah dit : "Ô vous qui croyez ! Cherchez de l\'aide dans la patience et la prière, car Allah est avec les patients." (Al-Baqara : 153)',
    hadiths: [
      HadithRiyad(
        numero: 23,
        narrateur: 'Abou Yahya Suhayb ibn Sinan (qu\'Allah l\'agrée)',
        texte: 'Le Messager d\'Allah ﷺ a dit : "Que la situation du croyant est merveilleuse ! Tout ce qui lui arrive est bon pour lui, et cela n\'est pas le cas pour quelqu\'un d\'autre que le croyant. Si une chose heureuse lui arrive, il est reconnaissant, c\'est bon pour lui ; et si une épreuve le touche, il endure patiemment, c\'est aussi bon pour lui."',
        source: 'Muslim',
      ),
      HadithRiyad(
        numero: 24,
        narrateur: 'Anas ibn Malik (qu\'Allah l\'agrée)',
        texte: 'Le Messager d\'Allah ﷺ a dit : "La grandeur de la récompense dépend de la grandeur de l\'épreuve. Lorsqu\'Allah aime un peuple, Il le met à l\'épreuve. Celui qui accepte est agréé par Lui, et celui qui s\'indigne attire Sa colère."',
        source: 'At-Tirmidhi — bon',
      ),
    ],
  ),

  ChapitreRiyad(
    numero: 4,
    titre: 'La Véracité (Sidq)',
    titreArabe: 'باب الصدق',
    introduction: 'Allah dit : "Ô vous qui croyez ! Craignez Allah et soyez avec les véridiques." (At-Tawba : 119)',
    hadiths: [
      HadithRiyad(
        numero: 54,
        narrateur: 'Ibn Mas\'ud (qu\'Allah l\'agrée)',
        texte: 'Le Messager d\'Allah ﷺ a dit : "Vous devez pratiquer la véracité. La véracité mène à la vertu, et la vertu mène au Paradis. Un homme reste véridique et cherche à l\'être jusqu\'à ce qu\'il soit inscrit auprès d\'Allah comme Siddiq (grand véridique). Méfiez-vous du mensonge. Le mensonge mène au vice, et le vice mène au Feu. Un homme reste menteur et cherche à l\'être jusqu\'à ce qu\'il soit inscrit auprès d\'Allah comme grand menteur."',
        source: 'Al-Bukhari et Muslim',
      ),
    ],
  ),

  ChapitreRiyad(
    numero: 5,
    titre: 'La Vigilance (Muraqaba)',
    titreArabe: 'باب المراقبة',
    introduction: 'Allah dit : "Certes, Allah est toujours Surveillant sur vous." (An-Nisa : 1)',
    hadiths: [
      HadithRiyad(
        numero: 63,
        narrateur: 'Omar ibn Al-Khattab (qu\'Allah l\'agrée)',
        texte: 'Le Messager d\'Allah ﷺ a dit : "L\'Ihsan, c\'est d\'adorer Allah comme si tu Le voyais ; et si tu ne Le vois pas, sache qu\'Il te voit."',
        source: 'Al-Bukhari et Muslim',
      ),
      HadithRiyad(
        numero: 64,
        narrateur: 'Anas ibn Malik (qu\'Allah l\'agrée)',
        texte: 'Le Messager d\'Allah ﷺ a dit : "Crains Allah où que tu sois."',
        source: 'At-Tirmidhi — bon',
      ),
    ],
  ),

  ChapitreRiyad(
    numero: 6,
    titre: 'La Piété (Taqwa)',
    titreArabe: 'باب التقوى',
    introduction: 'Allah dit : "Et prenez des provisions, car la meilleure des provisions c\'est la piété." (Al-Baqara : 197)',
    hadiths: [
      HadithRiyad(
        numero: 68,
        narrateur: 'Abou Hourayra (qu\'Allah l\'agrée)',
        texte: 'Le Messager d\'Allah ﷺ fut interrogé sur ce pour quoi les gens entrent le plus souvent au Paradis. Il répondit : "La crainte d\'Allah et le bon caractère." Il fut interrogé sur ce pour quoi les gens entrent le plus souvent dans le Feu. Il répondit : "La bouche et les parties intimes."',
        source: 'At-Tirmidhi — authentique',
      ),
      HadithRiyad(
        numero: 70,
        narrateur: 'An-Nawwas ibn Sam\'an (qu\'Allah l\'agrée)',
        texte: 'Le Messager d\'Allah ﷺ a dit : "La vertu (birr) c\'est le bon caractère, et le péché c\'est ce qui remue dans ton âme et que tu n\'aimes pas que les gens voient."',
        source: 'Muslim',
      ),
    ],
  ),

  ChapitreRiyad(
    numero: 7,
    titre: 'La Certitude et la Confiance en Allah (Tawakkul)',
    titreArabe: 'باب اليقين والتوكل',
    introduction: 'Allah dit : "Et quiconque place sa confiance en Allah, Il lui suffit." (At-Talaq : 3)',
    hadiths: [
      HadithRiyad(
        numero: 79,
        narrateur: 'Ibn Abbas (qu\'Allah les agrée tous deux)',
        texte: 'Le Messager d\'Allah ﷺ a dit : "Soixante-dix mille de ma communauté entreront au Paradis sans compte ni châtiment : ce sont ceux qui ne recourent pas aux amulettes, ne croient pas aux présages et se fient à leur Seigneur."',
        source: 'Al-Bukhari et Muslim',
      ),
      HadithRiyad(
        numero: 80,
        narrateur: 'Omar ibn Al-Khattab (qu\'Allah l\'agrée)',
        texte: 'Le Messager d\'Allah ﷺ a dit : "Si vous vous confiez vraiment à Allah comme Il mérite qu\'on se confie à Lui, Il vous accordera la subsistance comme Il l\'accorde aux oiseaux : ils partent le ventre vide et reviennent rassasiés."',
        source: 'At-Tirmidhi — bon',
      ),
    ],
  ),

  ChapitreRiyad(
    numero: 8,
    titre: 'La Droiture (Istiqama)',
    titreArabe: 'باب الاستقامة',
    introduction: 'Allah dit : "Sois donc droit comme on te l\'a commandé." (Houd : 112)',
    hadiths: [
      HadithRiyad(
        numero: 86,
        narrateur: 'Abou Amr Sufyan ibn Abdallah Ath-Thaqafi (qu\'Allah l\'agrée)',
        texte: 'J\'ai dit : "Ô Messager d\'Allah ! Dis-moi en Islam une parole telle que je n\'aurai pas à en demander d\'autre après toi." Il dit : "Dis : Je crois en Allah, puis sois droit."',
        source: 'Muslim',
      ),
      HadithRiyad(
        numero: 87,
        narrateur: 'Abou Hourayra (qu\'Allah l\'agrée)',
        texte: 'Le Messager d\'Allah ﷺ a dit : "Soyez droits et vous ne pourrez pas être parfaits. Sachez que la meilleure de vos œuvres est la prière, et que personne ne maintient l\'ablution que le croyant."',
        source: 'Ibn Maja — authentique',
      ),
    ],
  ),

  ChapitreRiyad(
    numero: 9,
    titre: 'La Réflexion et la Vigilance sur l\'Âme',
    titreArabe: 'باب المحاسبة',
    introduction: 'Allah dit : "Ô vous qui croyez ! Craignez Allah et que chaque âme considère ce qu\'elle a envoyé pour demain." (Al-Hashr : 18)',
    hadiths: [
      HadithRiyad(
        numero: 95,
        narrateur: 'Ibn Omar (qu\'Allah les agrée tous deux)',
        texte: 'Le Messager d\'Allah ﷺ m\'a pris par les épaules et dit : "Sois dans le monde comme si tu étais un étranger ou un passant, et considère-toi parmi les gens du tombeau."',
        source: 'Al-Bukhari',
      ),
    ],
  ),

  ChapitreRiyad(
    numero: 10,
    titre: 'Se Hâter vers les Bonnes Œuvres',
    titreArabe: 'باب المسارعة إلى الخيرات',
    introduction: 'Allah dit : "Rivalisez donc dans les bonnes œuvres." (Al-Baqara : 148)',
    hadiths: [
      HadithRiyad(
        numero: 97,
        narrateur: 'Abou Hourayra (qu\'Allah l\'agrée)',
        texte: 'Le Messager d\'Allah ﷺ a dit : "Hâtez-vous de faire de bonnes œuvres avant que surviennent des épreuves semblables aux morceaux d\'une nuit obscure : l\'homme se lèvera croyant et se couchera incrédule, ou se couchera croyant et se lèvera incrédule, il vendra sa religion pour quelques biens mondains."',
        source: 'Muslim',
      ),
      HadithRiyad(
        numero: 100,
        narrateur: 'Jabir (qu\'Allah l\'agrée)',
        texte: 'Le Messager d\'Allah ﷺ a dit : "L\'action d\'un mort est figée, mais celle du moudjahid dans la voie d\'Allah continue jusqu\'au Jour de la Résurrection."',
        source: 'Abou Dawoud et At-Tirmidhi',
      ),
    ],
  ),

  ChapitreRiyad(
    numero: 11,
    titre: 'Le Jihad',
    titreArabe: 'باب الجهاد',
    introduction: 'Allah dit : "Combattez dans le chemin d\'Allah de la façon qui Lui convient." (Al-Hajj : 78)',
    hadiths: [
      HadithRiyad(
        numero: 1315,
        narrateur: 'Abou Hourayra (qu\'Allah l\'agrée)',
        texte: 'Le Messager d\'Allah ﷺ a dit : "Quelqu\'un a demandé au Messager d\'Allah ﷺ : \'Quel est l\'acte équivalent au jihad dans la voie d\'Allah ?\' Il répondit : \'Vous n\'en avez pas les moyens.\' On lui répéta deux ou trois fois et il dit à chaque fois : \'Vous n\'en avez pas les moyens.\' Puis il dit : \'L\'équivalent du combattant dans la voie d\'Allah est celui qui jeûne et prie sans se lasser, jusqu\'au retour du combattant.\'"',
        source: 'Al-Bukhari et Muslim',
      ),
    ],
  ),

  ChapitreRiyad(
    numero: 12,
    titre: 'La Connaissance (\'Ilm)',
    titreArabe: 'باب العلم',
    introduction: 'Allah dit : "Dis : Mon Seigneur, accroît mon savoir." (Ta Ha : 114)',
    hadiths: [
      HadithRiyad(
        numero: 1381,
        narrateur: 'Abou Hourayra (qu\'Allah l\'agrée)',
        texte: 'Le Messager d\'Allah ﷺ a dit : "Quand l\'homme meurt, ses œuvres s\'arrêtent sauf pour trois choses : une sadaqa jariya (aumône permanente), un savoir dont on profite et un enfant pieux qui fait dua pour lui."',
        source: 'Muslim',
      ),
      HadithRiyad(
        numero: 1382,
        narrateur: 'Abou Hourayra (qu\'Allah l\'agrée)',
        texte: 'Le Messager d\'Allah ﷺ a dit : "Allah facilite la voie du Paradis à celui qui s\'engage dans la voie de la recherche du savoir."',
        source: 'Muslim',
      ),
      HadithRiyad(
        numero: 1383,
        narrateur: 'Ibn Mas\'ud (qu\'Allah l\'agrée)',
        texte: 'Le Messager d\'Allah ﷺ a dit : "Il n\'est de jalousie permise que dans deux cas : un homme à qui Allah a donné des richesses et qu\'Il a dirigé à les dépenser dans la vérité, et un homme à qui Allah a donné la sagesse et qui juge avec elle et l\'enseigne."',
        source: 'Al-Bukhari et Muslim',
      ),
    ],
  ),

  ChapitreRiyad(
    numero: 13,
    titre: 'La Glorification d\'Allah — Dhikr',
    titreArabe: 'باب الذكر',
    introduction: 'Allah dit : "Rappelez-vous de Moi, Je me souviendrai de vous." (Al-Baqara : 152)',
    hadiths: [
      HadithRiyad(
        numero: 1408,
        narrateur: 'Abou Hourayra (qu\'Allah l\'agrée)',
        texte: 'Le Messager d\'Allah ﷺ a dit : "Allah le Très-Haut dit : \'Je suis tel que Mon serviteur pense de Moi. Je suis avec lui lorsqu\'il Me mentionne. S\'il Me mentionne en lui-même, Je le mentionne en Moi-même. S\'il Me mentionne dans une assemblée, Je le mentionne dans une assemblée meilleure que la sienne.\'"',
        source: 'Al-Bukhari et Muslim',
      ),
      HadithRiyad(
        numero: 1414,
        narrateur: 'Abou Moussa Al-Ash\'ari (qu\'Allah l\'agrée)',
        texte: 'Le Messager d\'Allah ﷺ a dit : "La différence entre celui qui mentionne Allah et celui qui ne Le mentionne pas est comme la différence entre le vivant et le mort."',
        source: 'Al-Bukhari',
      ),
      HadithRiyad(
        numero: 1422,
        narrateur: 'Abou Hourayra (qu\'Allah l\'agrée)',
        texte: 'Le Messager d\'Allah ﷺ a dit : "Deux paroles légères sur la langue, lourdes dans la balance, aimées du Tout-Miséricordieux : Subhan Allahi wa bihamdih, Subhan Allahil Azim."',
        source: 'Al-Bukhari et Muslim',
      ),
    ],
  ),

  ChapitreRiyad(
    numero: 14,
    titre: 'La Prière sur le Prophète ﷺ',
    titreArabe: 'باب الصلاة على النبي ﷺ',
    introduction: 'Allah dit : "Allah et Ses anges prient sur le Prophète. Ô vous qui croyez ! Priez sur lui et soumettez-vous complètement." (Al-Ahzab : 56)',
    hadiths: [
      HadithRiyad(
        numero: 1474,
        narrateur: 'Abdallah ibn Amr ibn Al-As (qu\'Allah les agrée tous deux)',
        texte: 'Le Messager d\'Allah ﷺ a dit : "Celui qui prie sur moi une fois, Allah prie sur lui dix fois."',
        source: 'Muslim',
      ),
      HadithRiyad(
        numero: 1477,
        narrateur: 'Abou Hourayra (qu\'Allah l\'agrée)',
        texte: 'Le Messager d\'Allah ﷺ a dit : "L\'avare est celui devant qui mon nom est mentionné et qui ne prie pas sur moi."',
        source: 'At-Tirmidhi — authentique',
      ),
    ],
  ),

  ChapitreRiyad(
    numero: 15,
    titre: 'L\'Invocation (Dua)',
    titreArabe: 'باب الدعاء',
    introduction: 'Allah dit : "Appelez-Moi, Je vous répondrai." (Ghafir : 60)',
    hadiths: [
      HadithRiyad(
        numero: 1465,
        narrateur: 'Nu\'man ibn Bashir (qu\'Allah les agrée tous deux)',
        texte: 'Le Messager d\'Allah ﷺ a dit : "Le dua est l\'adoration." Puis il récita : "Votre Seigneur a dit : \'Appelez-Moi, Je vous répondrai.\'"',
        source: 'Abou Dawoud et At-Tirmidhi — authentique',
      ),
      HadithRiyad(
        numero: 1466,
        narrateur: 'Abou Hourayra (qu\'Allah l\'agrée)',
        texte: 'Le Messager d\'Allah ﷺ a dit : "Rien n\'est plus noble auprès d\'Allah que le dua."',
        source: 'At-Tirmidhi et Ibn Maja — authentique',
      ),
      HadithRiyad(
        numero: 1470,
        narrateur: 'Abou Hourayra (qu\'Allah l\'agrée)',
        texte: 'Le Messager d\'Allah ﷺ a dit : "Allah répond au dua du serviteur tant qu\'il ne demande pas la rupture des liens de parenté. Il dit : \'Ô Allah ! Exauce-moi.\' Et Allah dit : \'Je t\'exauce tant que tu ne te précipites pas.\' On dit : \'Ô Messager d\'Allah ! Comment peut-il se précipiter ?\' Il dit : \'En disant : J\'ai fait du dua et je ne vois pas que mon dua ait été exaucé — et alors il abandonne le dua.\'"',
        source: 'Al-Bukhari et Muslim',
      ),
    ],
  ),

  ChapitreRiyad(
    numero: 16,
    titre: 'Le Bon Caractère (Akhlaq)',
    titreArabe: 'باب حسن الخلق',
    introduction: 'Allah dit (à propos du Prophète ﷺ) : "Et certes tu as un caractère immense." (Al-Qalam : 4)',
    hadiths: [
      HadithRiyad(
        numero: 626,
        narrateur: 'Abou Darda (qu\'Allah l\'agrée)',
        texte: 'Le Messager d\'Allah ﷺ a dit : "Rien ne sera plus lourd dans la balance du croyant au Jour de la Résurrection que le bon caractère. Allah hait en vérité l\'indécent et l\'impudent."',
        source: 'At-Tirmidhi — authentique',
      ),
      HadithRiyad(
        numero: 629,
        narrateur: 'Abou Hourayra (qu\'Allah l\'agrée)',
        texte: 'Le Messager d\'Allah ﷺ a dit : "Le croyant le plus parfait en foi est celui qui a le meilleur caractère, et les meilleurs d\'entre vous sont ceux qui sont les meilleurs avec leurs femmes."',
        source: 'At-Tirmidhi — authentique',
      ),
      HadithRiyad(
        numero: 634,
        narrateur: 'Abdallah ibn Amr (qu\'Allah les agrée tous deux)',
        texte: 'Le Messager d\'Allah ﷺ n\'était pas indécent ni impudent. Il disait : "Les meilleurs d\'entre vous sont ceux qui ont le meilleur caractère."',
        source: 'Al-Bukhari et Muslim',
      ),
    ],
  ),

  ChapitreRiyad(
    numero: 17,
    titre: 'La Générosité et la Dépense dans la Voie d\'Allah',
    titreArabe: 'باب الجود والكرم',
    introduction: 'Allah dit : "Et quoi que vous dépensiez, Il vous le remplacera, et Il est le Meilleur des pourvoyeurs." (Saba : 39)',
    hadiths: [
      HadithRiyad(
        numero: 539,
        narrateur: 'Abou Hourayra (qu\'Allah l\'agrée)',
        texte: 'Le Messager d\'Allah ﷺ a dit : "Chaque jour où les serviteurs se lèvent le matin, deux anges descendent : l\'un dit : \'Ô Allah ! Accorde la compensation à celui qui dépense\', et l\'autre dit : \'Ô Allah ! Donne la ruine à celui qui retient.\'"',
        source: 'Al-Bukhari et Muslim',
      ),
      HadithRiyad(
        numero: 540,
        narrateur: 'Haritha ibn Wahb Al-Khuza\'i (qu\'Allah l\'agrée)',
        texte: 'Le Messager d\'Allah ﷺ a dit : "Faites l\'aumône car il viendra sur vous un temps où un homme ira se promener avec sa sadaqa et ne trouvera personne pour la prendre."',
        source: 'Al-Bukhari et Muslim',
      ),
    ],
  ),

  ChapitreRiyad(
    numero: 18,
    titre: 'La Visite des Malades',
    titreArabe: 'باب عيادة المريض',
    introduction: 'Le Prophète ﷺ a établi la visite aux malades comme un droit du Muslim sur son frère.',
    hadiths: [
      HadithRiyad(
        numero: 895,
        narrateur: 'Abou Hourayra (qu\'Allah l\'agrée)',
        texte: 'Le Messager d\'Allah ﷺ a dit : "Les droits du Muslim envers le Muslim sont au nombre de cinq : répondre au salaam, visiter le malade, suivre le cortège funèbre, accepter l\'invitation et souhaiter la guérison à celui qui éternue."',
        source: 'Al-Bukhari et Muslim',
      ),
      HadithRiyad(
        numero: 896,
        narrateur: 'Ali ibn Abi Talib (qu\'Allah l\'agrée)',
        texte: 'Le Messager d\'Allah ﷺ a dit : "Tout Muslim qui rend visite à un Muslim malade le matin est escorté par soixante-dix mille anges qui prient pour lui jusqu\'au soir. Et s\'il lui rend visite le soir, soixante-dix mille anges prient pour lui jusqu\'au matin."',
        source: 'At-Tirmidhi et Abou Dawoud — authentique',
      ),
      HadithRiyad(
        numero: 903,
        narrateur: 'Ibn Abbas (qu\'Allah les agrée tous deux)',
        texte: 'Le Messager d\'Allah ﷺ, lorsqu\'il rendait visite à un malade, disait : "لَا بَأسَ طَهُورٌ إِنْ شَاءَ اللَّهُ — Pas de mal, c\'est une purification, si Allah le veut."',
        source: 'Al-Bukhari',
      ),
    ],
  ),

  ChapitreRiyad(
    numero: 19,
    titre: 'La Médecine Prophétique — Santé',
    titreArabe: 'باب الطب والتداوي',
    introduction: 'Le Prophète ﷺ a dit : "Allah n\'a pas fait descendre de maladie sans faire descendre son remède." (Al-Bukhari)',
    hadiths: [
      HadithRiyad(
        numero: 922,
        narrateur: 'Abou Hourayra (qu\'Allah l\'agrée)',
        texte: 'Le Messager d\'Allah ﷺ a dit : "Il n\'y a pas de maladie qu\'Allah a envoyée sans qu\'Il en ait envoyé le remède."',
        source: 'Al-Bukhari',
      ),
      HadithRiyad(
        numero: 923,
        narrateur: 'Usama ibn Shurayk (qu\'Allah l\'agrée)',
        texte: 'Le Messager d\'Allah ﷺ a dit : "Traitez-vous médicalement, ô serviteurs d\'Allah ! Car Allah n\'a pas placé de maladie sans placer son remède, sauf une seule : la vieillesse."',
        source: 'Abou Dawoud et At-Tirmidhi — authentique',
      ),
      HadithRiyad(
        numero: 924,
        narrateur: 'Ibn Mas\'ud (qu\'Allah l\'agrée)',
        texte: 'Le Messager d\'Allah ﷺ a dit : "Vous devez utiliser les deux remèdes : le miel et le Coran."',
        source: 'Ibn Maja — bon',
      ),
    ],
  ),

  ChapitreRiyad(
    numero: 20,
    titre: 'Les Vertus du Vendredi et des Prières',
    titreArabe: 'باب فضل الجمعة والصلوات',
    introduction: 'Allah dit : "Ô vous qui croyez ! Lorsque l\'appel est lancé pour la prière du vendredi, hâtez-vous vers le rappel d\'Allah." (Al-Jumu\'a : 9)',
    hadiths: [
      HadithRiyad(
        numero: 1155,
        narrateur: 'Abou Hourayra (qu\'Allah l\'agrée)',
        texte: 'Le Messager d\'Allah ﷺ a dit : "La meilleure prière après la prière obligatoire est la prière de la nuit."',
        source: 'Muslim',
      ),
      HadithRiyad(
        numero: 1156,
        narrateur: 'Jabir ibn Abdallah (qu\'Allah les agrée tous deux)',
        texte: 'Le Messager d\'Allah ﷺ a dit : "Le meilleur jour sur lequel le soleil s\'est levé est le vendredi. En ce jour Adam a été créé, en ce jour il est entré au Paradis et en ce jour il en est sorti."',
        source: 'Muslim',
      ),
    ],
  ),
];
