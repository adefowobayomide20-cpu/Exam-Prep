import "../quiz_question.dart";

QuizQuestion _q(String subject, String text, List<String> options, String correct, String explanation) {
  return QuizQuestion(
    subject: subject,
    text: text,
    options: options,
    correctIndex: options.indexOf(correct),
    explanation: explanation,
  );
}

const _frenchSubject = "French";

QuizQuestion _fq(String text, List<String> options, String correct, String explanation) =>
    _q(_frenchSubject, text, options, correct, explanation);

/// Obafemi Awolowo University (OAU), Ile-Ife Post-UTME elective practice
/// bank for French — 100 medium-to-hard, JAMB/Post-UTME-style multiple
/// choice questions covering Written Comprehension, Grammar/Pronouns,
/// Verbs/Conjugation, Sentence Transformations, Number/Gender Agreement,
/// Phonetics, and Culture/Civilization. This is a general-purpose practice
/// set, not an official OAU past-question paper.
List<QuizQuestion> buildOauFrenchQuestions() {
  return [
    ..._writtenComprehension,
    ..._grammarAndPronouns,
    ..._verbsAndConjugation,
    ..._sentenceTransformations,
    ..._numberAndGenderAgreement,
    ..._phonetics,
    ..._cultureAndCivilization,
  ];
}

// ---------------------------------------------------------------------------
// Written Comprehension — two short original passages, several questions
// each.
// ---------------------------------------------------------------------------

const _passageOne =
    "Amina vient d'un petit village situe pres d'Ibadan. Depuis son enfance, elle reve de devenir medecin "
    "afin d'aider les habitants de sa region, ou les hopitaux sont rares. Apres avoir termine ses etudes "
    "secondaires avec de tres bons resultats, elle a obtenu une bourse pour etudier la medecine a "
    "l'universite. Ses parents, qui sont agriculteurs, etaient tres fiers d'elle, meme s'ils savaient que "
    "les etudes seraient longues et difficiles. Aujourd'hui, Amina passe ses vacances a soigner "
    "gratuitement les malades de son village, en attendant de terminer sa formation. Elle espere qu'un "
    "jour, grace a son travail, moins de gens mourront de maladies faciles a soigner.";

QuizQuestion _c1q(String question, List<String> options, String correct, String explanation) =>
    _fq("$_passageOne\n\n$question", options, correct, explanation);

const _passageTwo =
    "Le marche d'Oshodi est l'un des plus grands marches de Lagos. On y trouve de tout : des vetements, "
    "des fruits, des legumes, des appareils electroniques et meme des pieces de voiture. Chaque matin, des "
    "milliers de commercants arrivent tres tot pour installer leurs etals avant l'arrivee des premiers "
    "clients. L'ambiance y est toujours bruyante et animee, avec des vendeurs qui crient pour attirer "
    "l'attention des passants. Malgre la chaleur et la foule, beaucoup de familles preferent ce marche aux "
    "grands centres commerciaux, car les prix y sont plus bas et on peut souvent negocier avec le vendeur.";

QuizQuestion _c2q(String question, List<String> options, String correct, String explanation) =>
    _fq("$_passageTwo\n\n$question", options, correct, explanation);

final _writtenComprehension = [
  _c1q("D'ou vient Amina ?",
      ["D'un petit village pres d'Ibadan", "D'une grande ville pres de Lagos", "D'un village pres de Kano", "D'une ville universitaire en France"], "D'un petit village pres d'Ibadan",
      "The passage opens with 'Amina vient d'un petit village situe pres d'Ibadan', naming her origin directly."),
  _c1q("Quel est le reve d'Amina depuis son enfance ?",
      ["Devenir medecin", "Devenir enseignante", "Devenir agricultrice", "Devenir avocate"], "Devenir medecin",
      "The text states 'elle reve de devenir medecin afin d'aider les habitants de sa region', identifying her childhood dream."),
  _c1q("Pourquoi Amina veut-elle devenir medecin, selon le texte ?",
      ["Pour aider les habitants de sa region, ou les hopitaux sont rares", "Pour gagner beaucoup d'argent rapidement", "Pour voyager a l'etranger", "Pour suivre les traces de ses parents"], "Pour aider les habitants de sa region, ou les hopitaux sont rares",
      "The passage explains she wants to help people in her area 'ou les hopitaux sont rares' (where hospitals are rare)."),
  _c1q("Comment Amina a-t-elle obtenu une place a l'universite ?",
      ["Grace a une bourse, apres de tres bons resultats", "En payant des frais tres eleves", "Grace a un concours de beaute", "Par l'intermediaire d'un oncle riche"], "Grace a une bourse, apres de tres bons resultats",
      "The text says she 'a obtenu une bourse pour etudier la medecine' after finishing secondary school with excellent results."),
  _c1q("Quelle est la profession des parents d'Amina ?",
      ["Agriculteurs", "Medecins", "Enseignants", "Commercants"], "Agriculteurs",
      "The passage describes 'Ses parents, qui sont agriculteurs' (her parents, who are farmers)."),
  _c1q("Que fait Amina pendant ses vacances, d'apres le texte ?",
      ["Elle soigne gratuitement les malades de son village", "Elle se repose sans rien faire", "Elle travaille dans un hopital de Lagos", "Elle voyage a l'etranger"], "Elle soigne gratuitement les malades de son village",
      "The passage states 'Amina passe ses vacances a soigner gratuitement les malades de son village'."),
  _c1q("Quel est l'espoir final exprime par Amina a la fin du texte ?",
      ["Que moins de gens meurent de maladies faciles a soigner", "Qu'elle devienne riche grace a la medecine", "Qu'elle quitte son village pour toujours", "Que ses parents cessent d'etre agriculteurs"], "Que moins de gens meurent de maladies faciles a soigner",
      "The final sentence expresses her hope that fewer people will die from easily treatable illnesses because of her work."),
  _c1q("Comment les parents d'Amina ont-ils reagi a sa reussite, selon le texte ?",
      ["Ils etaient tres fiers d'elle", "Ils etaient decus par son choix", "Ils etaient indifferents", "Ils s'y sont opposes fermement"], "Ils etaient tres fiers d'elle",
      "The passage says her parents 'etaient tres fiers d'elle', despite knowing the studies would be long and difficult."),
  _c1q("Dans la phrase 'meme s'ils savaient que les etudes seraient longues et difficiles', l'expression 'meme si' introduit une idee de",
      ["concession", "cause", "consequence", "but"], "concession",
      "'Meme si' introduces a concession — an idea acknowledged despite being an obstacle, similar to 'although' in English."),
  _c1q("Quel est le theme principal de ce texte ?",
      ["La determination d'une jeune fille a aider sa communaute par la medecine", "La vie quotidienne des agriculteurs nigerians", "L'histoire de la ville d'Ibadan", "Les difficultes financieres des universites"], "La determination d'une jeune fille a aider sa communaute par la medecine",
      "The passage centers on Amina's determination to become a doctor and help her community despite challenges."),
  _c2q("Ou se trouve le marche decrit dans le texte ?",
      ["A Oshodi, a Lagos", "A Ibadan", "A Abuja", "A Kano"], "A Oshodi, a Lagos",
      "The passage opens with 'Le marche d'Oshodi est l'un des plus grands marches de Lagos'."),
  _c2q("Que peut-on trouver au marche d'Oshodi, selon le texte ?",
      ["Des vetements, des fruits, des legumes, des appareils electroniques et des pieces de voiture", "Uniquement des vetements et des chaussures", "Seulement des produits alimentaires", "Des livres et des fournitures scolaires"], "Des vetements, des fruits, des legumes, des appareils electroniques et des pieces de voiture",
      "The text lists these items directly: 'des vetements, des fruits, des legumes, des appareils electroniques et meme des pieces de voiture'."),
  _c2q("A quelle heure les commercants arrivent-ils au marche ?",
      ["Tres tot le matin", "Tard dans la soiree", "Vers midi", "Pendant la nuit"], "Tres tot le matin",
      "The passage states commerçants 'arrivent tres tot' every morning to set up before customers arrive."),
  _c2q("Comment le texte decrit-il l'ambiance du marche ?",
      ["Bruyante et animee", "Calme et silencieuse", "Triste et vide", "Organisee et sans bruit"], "Bruyante et animee",
      "The passage describes the atmosphere as 'toujours bruyante et animee' (always noisy and lively)."),
  _c2q("Pourquoi beaucoup de familles preferent-elles ce marche aux grands centres commerciaux ?",
      ["Les prix y sont plus bas et on peut negocier", "Le marche est climatise", "Il y a moins de monde", "Les produits y sont de meilleure qualite"], "Les prix y sont plus bas et on peut negocier",
      "The passage explains families prefer the market because 'les prix y sont plus bas et on peut souvent negocier avec le vendeur'."),
  _c2q("Que font les vendeurs pour attirer l'attention des passants ?",
      ["Ils crient", "Ils chantent des chansons", "Ils distribuent des cadeaux gratuits", "Ils restent silencieux"], "Ils crient",
      "The text says vendors 'crient pour attirer l'attention des passants' (shout to attract passers-by)."),
  _c2q("Le mot 'etals' dans le texte se refere probablement a",
      ["des tables ou des stands de vente", "des voitures garees", "des maisons privees", "des bureaux administratifs"], "des tables ou des stands de vente",
      "'Etals' refers to market stalls or stands where vendors display and sell their goods."),
  _c2q("Quel est le theme general de ce texte ?",
      ["La vie et l'ambiance d'un grand marche a Lagos", "L'histoire politique du Nigeria", "Les problemes de circulation a Lagos", "La construction de nouveaux centres commerciaux"], "La vie et l'ambiance d'un grand marche a Lagos",
      "The passage as a whole describes the daily life and lively atmosphere of the Oshodi market."),
];

// ---------------------------------------------------------------------------
// Grammar / Pronouns
// ---------------------------------------------------------------------------

final _grammarAndPronouns = [
  _fq("Complete correctement : 'Marie et moi, ___ allons au marche ensemble.'",
      ["nous", "vous", "ils", "elle"], "nous",
      "'Marie et moi' together form a first-person plural subject, requiring the pronoun 'nous'."),
  _fq("Choisissez le pronom relatif correct : 'Voici la maison ___ j'habite.'",
      ["ou", "que", "qui", "dont"], "ou",
      "'Ou' is used as a relative pronoun of place, meaning 'where', linking 'la maison' to the place someone lives."),
  _fq("Quel pronom complement remplace 'a mes amis' dans 'Je parle a mes amis' ?",
      ["Leur", "Les", "Lui", "Eux"], "Leur",
      "'Leur' is the indirect object pronoun used to replace a plural noun introduced by 'a', here 'a mes amis'."),
  _fq("Dans la phrase 'C'est MOI qui ai raison', le mot souligne est un pronom",
      ["personnel tonique (accentue)", "possessif", "demonstratif", "relatif"], "personnel tonique (accentue)",
      "'Moi' here is a stressed (tonic) personal pronoun, used for emphasis after 'c'est'."),
  _fq("Choisissez l'adjectif possessif correct : '___ soeur habite a Ibadan.' (a moi, feminin singulier)",
      ["Ma", "Mon", "Mes", "Ton"], "Ma",
      "'Ma' is the feminine singular possessive adjective agreeing with the feminine noun 'soeur'."),
  _fq("Quel pronom demonstratif complete la phrase : '___ qui travaille dur reussira.'",
      ["Celui", "Celle-ci", "Ceux", "Ce"], "Celui",
      "'Celui' (masculine singular demonstrative pronoun) means 'the one', matching the generic singular subject implied here."),
  _fq("Choisissez la bonne preposition : 'Elle vient ___ Nigeria.'",
      ["du", "de la", "de", "au"], "du",
      "Country names that are masculine, like 'le Nigeria', require the contraction 'du' (de + le) to express origin."),
  _fq("Quel article convient : '___ eau que je bois est fraiche.'",
      ["L'", "Le", "La", "Les"], "L'",
      "Before a vowel sound like 'eau', the definite article elides to 'l'', regardless of the noun's gender."),
  _fq("Identifiez la fonction du mot souligne : 'Il a repondu RAPIDEMENT a la question.'",
      ["Adverbe de maniere", "Adjectif qualificatif", "Nom commun", "Pronom indefini"], "Adverbe de maniere",
      "'Rapidement' describes how the action of answering was done, making it an adverb of manner."),
  _fq("Choisissez le pronom interrogatif correct : '___ est le directeur de cette ecole ?'",
      ["Qui", "Que", "Quoi", "Ou"], "Qui",
      "'Qui' is used to ask about a person as the subject of the sentence, here identifying the school's director."),
  _fq("Dans la phrase 'Donne-le-MOI', le pronom souligne est place",
      ["apres le verbe, a l'imperatif affirmatif", "avant le verbe, a l'imperatif negatif", "au milieu du verbe", "avant le sujet"], "apres le verbe, a l'imperatif affirmatif",
      "In the affirmative imperative, object pronouns follow the verb and are attached with hyphens, as in 'donne-le-moi'."),
  _fq("Quel pronom possessif remplace 'leurs livres' (masculin pluriel) ?",
      ["Les leurs", "Le leur", "La leur", "Les siens"], "Les leurs",
      "'Les leurs' is the plural possessive pronoun corresponding to 'leurs livres', agreeing in number with the plural noun replaced."),
  _fq("Choisissez l'adjectif indefini correct : '___ eleves ont reussi l'examen.'",
      ["Plusieurs", "Chaque", "Aucun", "Chacun"], "Plusieurs",
      "'Plusieurs' (several) is an indefinite adjective that agrees with a plural noun like 'eleves', unlike 'chaque' or 'aucun', which are singular."),
  _fq("Dans 'Je pense a toi', quel pronom tonique remplace correctement 'toi' si l'on parle d'un groupe (vous) ?",
      ["Vous", "Elles", "Eux", "Nous"], "Vous",
      "'Vous' is the tonic (stressed) form used after prepositions like 'a' when addressing more than one person or formally."),
  _fq("Quelle est la nature du mot souligne : 'Il y a BEAUCOUP d'etudiants dans la salle.'",
      ["Adverbe de quantite", "Adjectif qualificatif", "Nom commun", "Pronom demonstratif"], "Adverbe de quantite",
      "'Beaucoup' is an adverb of quantity, expressing a large amount, here modifying the noun phrase 'd'etudiants'."),
];

// ---------------------------------------------------------------------------
// Verbs / Conjugation
// ---------------------------------------------------------------------------

final _verbsAndConjugation = [
  _fq("Conjuguez 'aller' au present avec 'je' :",
      ["Je vais", "Je vas", "J'allais", "J'irai"], "Je vais",
      "'Aller' is irregular; its first-person singular present form is 'je vais'."),
  _fq("Conjuguez 'venir' au present avec 'ils' :",
      ["Ils viennent", "Ils venent", "Ils viens", "Ils venons"], "Ils viennent",
      "'Venir' is irregular in the plural third person, taking the form 'ils viennent' in the present tense."),
  _fq("Mettez 'manger' au passe compose avec 'elle' :",
      ["Elle a mange", "Elle est mangee", "Elle mangeait", "Elle mangera"], "Elle a mange",
      "'Manger' takes the auxiliary 'avoir' in the passe compose: 'elle a mange'."),
  _fq("Mettez 'partir' au passe compose avec 'nous' (masculin) :",
      ["Nous sommes partis", "Nous avons parti", "Nous partons", "Nous partions"], "Nous sommes partis",
      "'Partir' is a verb of movement conjugated with 'etre' in the passe compose, agreeing with the subject: 'nous sommes partis'."),
  _fq("Quelle est la forme correcte de 'faire' au present avec 'vous' ?",
      ["Vous faites", "Vous faisez", "Vous font", "Vous fais"], "Vous faites",
      "'Faire' is irregular; the second-person plural present form is 'vous faites', not the regular '-ez' ending."),
  _fq("Conjuguez 'pouvoir' au present avec 'tu' :",
      ["Tu peux", "Tu peut", "Tu pouves", "Tu pouvez"], "Tu peux",
      "'Pouvoir' is irregular; its second-person singular present form is 'tu peux'."),
  _fq("Quel est le futur simple du verbe 'etre' avec 'je' ?",
      ["Je serai", "Je serais", "J'etais", "Je suis"], "Je serai",
      "The future stem of 'etre' is irregular ('ser-'), giving 'je serai' in the futur simple."),
  _fq("Conjuguez 'vouloir' a l'imparfait avec 'nous' :",
      ["Nous voulions", "Nous voulons", "Nous voudrons", "Nous voulussions"], "Nous voulions",
      "The imparfait is formed from the 'nous' present stem plus imparfait endings; 'voulons' becomes 'voulions' for 'nous'."),
  _fq("Quelle est la forme correcte de l'imperatif de 'etre' pour 'tu' ?",
      ["Sois", "Es", "Etais", "Serais"], "Sois",
      "'Etre' has an irregular imperative form for 'tu': 'sois' (be)."),
  _fq("Conjuguez 'savoir' au present avec 'je' :",
      ["Je sais", "Je sait", "Je save", "Je saurai"], "Je sais",
      "'Savoir' is irregular; its first-person singular present form is 'je sais'."),
  _fq("Mettez 'finir' au futur simple avec 'ils' :",
      ["Ils finiront", "Ils finiraient", "Ils finissent", "Ils finissaient"], "Ils finiront",
      "The futur simple of regular -ir verbs is formed from the infinitive plus endings: 'ils finiront'."),
  _fq("Quelle est la forme correcte du conditionnel present de 'avoir' avec 'vous' ?",
      ["Vous auriez", "Vous avez", "Vous aurez", "Vous aviez"], "Vous auriez",
      "The conditional is formed from the future stem 'aur-' plus imparfait endings, giving 'vous auriez'."),
  _fq("Conjuguez 'se lever' au present avec 'elles' :",
      ["Elles se levent", "Elles se levons", "Elles se leve", "Elles se levez"], "Elles se levent",
      "Reflexive verb 'se lever' conjugates like a regular -er verb with the reflexive pronoun agreeing with the subject: 'elles se levent'."),
  _fq("Quel est le participe passe du verbe 'prendre' ?",
      ["Pris", "Prendu", "Pri", "Prendé"], "Pris",
      "'Prendre' has an irregular past participle: 'pris', used in compound tenses like 'j'ai pris'."),
  _fq("Conjuguez 'devoir' au present avec 'nous' :",
      ["Nous devons", "Nous devez", "Nous doivent", "Nous devrons"], "Nous devons",
      "'Devoir' is irregular; its first-person plural present form is 'nous devons'."),
  _fq("Quelle est la bonne forme du subjonctif present de 'faire' avec 'que je' ?",
      ["Que je fasse", "Que je fais", "Que je ferai", "Que je faisais"], "Que je fasse",
      "'Faire' has an irregular subjunctive stem 'fass-', giving 'que je fasse' in the present subjunctive."),
];

// ---------------------------------------------------------------------------
// Sentence Transformations
// ---------------------------------------------------------------------------

final _sentenceTransformations = [
  _fq("Mettez a la forme negative : 'Il mange du riz.'",
      ["Il ne mange pas de riz.", "Il ne mange pas du riz.", "Il mange pas de riz.", "Il non mange de riz."], "Il ne mange pas de riz.",
      "In negative sentences, the partitive article 'du' becomes 'de' after 'ne...pas', giving 'il ne mange pas de riz'."),
  _fq("Transformez a la voix passive : 'Le professeur corrige les devoirs.'",
      ["Les devoirs sont corriges par le professeur.", "Les devoirs corrigent le professeur.", "Le professeur est corrige par les devoirs.", "Les devoirs ont corrige le professeur."], "Les devoirs sont corriges par le professeur.",
      "In the passive voice, the object 'les devoirs' becomes the subject, and the agent 'le professeur' follows 'par'."),
  _fq("Mettez a la forme interrogative avec inversion : 'Tu aimes le chocolat.'",
      ["Aimes-tu le chocolat ?", "Tu aimes-tu le chocolat ?", "Est-ce tu aimes le chocolat ?", "Aime tu le chocolat ?"], "Aimes-tu le chocolat ?",
      "Inversion questions swap subject and verb order and add a hyphen: 'Aimes-tu le chocolat ?'"),
  _fq("Transformez au discours indirect : Il dit : 'Je suis fatigue.'",
      ["Il dit qu'il est fatigue.", "Il dit que je suis fatigue.", "Il dit il est fatigue.", "Il a dit je suis fatigue."], "Il dit qu'il est fatigue.",
      "In reported speech, 'je' becomes 'il' and the conjunction 'que' introduces the reported clause: 'il dit qu'il est fatigue'."),
  _fq("Reliez les deux phrases avec un pronom relatif : 'J'ai un livre. Ce livre est interessant.'",
      ["J'ai un livre qui est interessant.", "J'ai un livre que est interessant.", "J'ai un livre dont est interessant.", "J'ai un livre ou est interessant."], "J'ai un livre qui est interessant.",
      "'Qui' replaces the subject 'ce livre' in the second clause, correctly joining the two sentences."),
  _fq("Mettez au pluriel : 'Le cheval blanc court vite.'",
      ["Les chevaux blancs courent vite.", "Les chevals blancs courent vite.", "Les chevaux blanc court vite.", "Le chevaux blancs courent vite."], "Les chevaux blancs courent vite.",
      "'Cheval' has an irregular plural 'chevaux', and the adjective 'blanc' and verb 'court' must also agree/adjust in the plural."),
  _fq("Transformez a la forme emphatique : 'Je veux ce livre.'",
      ["C'est ce livre que je veux.", "C'est moi qui veux ce livre.", "Ce livre, je veux.", "Je veux, c'est ce livre."], "C'est ce livre que je veux.",
      "The emphatic structure 'C'est... que' highlights the object 'ce livre' by fronting it with 'c'est...que'."),
  _fq("Mettez a la forme negative : 'Elle a deja fini son travail.'",
      ["Elle n'a pas encore fini son travail.", "Elle a pas deja fini son travail.", "Elle n'a jamais deja fini son travail.", "Elle a fini pas encore son travail."], "Elle n'a pas encore fini son travail.",
      "The negation of 'deja' (already) in a compound tense is expressed by 'ne...pas encore' (not yet)."),
  _fq("Transformez au futur proche : 'Nous visitons le musee.'",
      ["Nous allons visiter le musee.", "Nous avons visite le musee.", "Nous visiterons le musee bientot pas.", "Nous visitions le musee."], "Nous allons visiter le musee.",
      "The futur proche is formed with the present tense of 'aller' plus an infinitive: 'nous allons visiter'."),
  _fq("Reecrivez en remplaçant le nom souligne par un pronom : 'Il regarde LA TELEVISION chaque soir.'",
      ["Il la regarde chaque soir.", "Il le regarde chaque soir.", "Il les regarde chaque soir.", "Il lui regarde chaque soir."], "Il la regarde chaque soir.",
      "'La television' is feminine singular, so it is replaced by the direct object pronoun 'la', placed before the verb."),
  _fq("Mettez a la forme comparative de superiorite : 'Ali est intelligent. Musa est intelligent.' (Ali > Musa)",
      ["Ali est plus intelligent que Musa.", "Ali est aussi intelligent que Musa.", "Ali est moins intelligent que Musa.", "Ali est le plus intelligent que Musa."], "Ali est plus intelligent que Musa.",
      "'Plus...que' expresses superiority in comparisons, correctly showing Ali is more intelligent than Musa."),
  _fq("Transformez a l'imperatif : 'Tu dois fermer la porte.'",
      ["Ferme la porte.", "Fermes la porte.", "Tu fermes la porte.", "Fermer la porte tu dois."], "Ferme la porte.",
      "The imperative of a regular -er verb for 'tu' drops the final 's' from the present tense form: 'ferme la porte'."),
];

// ---------------------------------------------------------------------------
// Number / Gender Agreement
// ---------------------------------------------------------------------------

final _numberAndGenderAgreement = [
  _fq("Choisissez la forme correcte : 'Une ___ voiture.' (nouveau)",
      ["nouvelle", "nouveau", "nouveaux", "nouvelles"], "nouvelle",
      "'Nouveau' becomes 'nouvelle' before a feminine singular noun like 'voiture'."),
  _fq("Accordez l'adjectif : 'Des maisons ___.' (blanc)",
      ["blanches", "blanc", "blancs", "blanche"], "blanches",
      "'Blanc' agrees with the feminine plural noun 'maisons', becoming 'blanches'."),
  _fq("Quel est le feminin de 'acteur' ?",
      ["Actrice", "Acteure", "Acteuse", "Actrise"], "Actrice",
      "'Acteur' has an irregular feminine form 'actrice', following the -teur/-trice pattern."),
  _fq("Quel est le pluriel de 'un journal' ?",
      ["Des journaux", "Des journals", "Des journeaux", "Des journale"], "Des journaux",
      "Nouns ending in '-al' typically form their plural in '-aux': 'un journal' becomes 'des journaux'."),
  _fq("Accordez le participe passe : 'Les lettres qu'elle a ___ sont sur la table.' (ecrire)",
      ["ecrites", "ecrit", "ecris", "ecrite"], "ecrites",
      "With avoir, the past participle agrees with a preceding direct object; 'que' refers to 'les lettres' (feminine plural), giving 'ecrites'."),
  _fq("Quel est le feminin de l'adjectif 'beau' ?",
      ["Belle", "Beau", "Beaus", "Beaux"], "Belle",
      "'Beau' has the irregular feminine form 'belle', used before a feminine noun."),
  _fq("Choisissez la forme correcte : 'Ces ___ enfants sont polis.' (petit)",
      ["petits", "petit", "petite", "petites"], "petits",
      "'Petit' agrees with the masculine plural noun 'enfants', becoming 'petits'."),
  _fq("Quel est le pluriel de 'un oeil' ?",
      ["Des yeux", "Des oeils", "Des oeuils", "Des yeuls"], "Des yeux",
      "'Oeil' has a completely irregular plural form: 'des yeux'."),
  _fq("Accordez : 'Elle est ___ de son succes.' (fier)",
      ["fiere", "fier", "fiers", "fieres"], "fiere",
      "'Fier' becomes 'fiere' to agree with the feminine subject 'elle'."),
  _fq("Quel est le feminin de 'directeur' ?",
      ["Directrice", "Directeure", "Directeuse", "Directrise"], "Directrice",
      "'Directeur' follows the -teur/-trice pattern, giving the feminine form 'directrice'."),
  _fq("Choisissez la forme correcte : 'Les fleurs sont ___.' (frais)",
      ["fraiches", "frais", "fraiche", "fraîches et frais"], "fraiches",
      "'Frais' has the irregular feminine form 'fraiche', which becomes plural 'fraiches' to agree with 'fleurs'."),
  _fq("Quel est le pluriel de 'un travail' ?",
      ["Des travaux", "Des travails", "Des travaus", "Des traval"], "Des travaux",
      "'Travail' has an irregular plural: 'des travaux', unlike the regular '-s' pattern."),
  _fq("Accordez l'adjectif possessif : '___ amies sont gentilles.' (mon/ma/mes, feminin pluriel)",
      ["Mes", "Ma", "Mon", "Sa"], "Mes",
      "The possessive adjective agrees in number with the plural noun 'amies', giving 'mes amies' regardless of gender in the plural."),
  _fq("Quel est le feminin de l'adjectif 'sportif' ?",
      ["Sportive", "Sportife", "Sportif", "Sportifs"], "Sportive",
      "Adjectives ending in '-if' generally change to '-ive' in the feminine: 'sportif' becomes 'sportive'."),
];

// ---------------------------------------------------------------------------
// Phonetics
// ---------------------------------------------------------------------------

final _phonetics = [
  _fq("Quel mot contient le son nasal [ɑ̃] comme dans 'dans' ?",
      ["Enfant", "Fini", "Petit", "Livre"], "Enfant",
      "'Enfant' contains the nasal vowel [ɑ̃], produced through the letters 'en' and 'an', similar to the sound in 'dans'."),
  _fq("Dans quel mot la lettre finale 's' est-elle prononcee ?",
      ["Fils", "Chats", "Livres", "Amis"], "Fils",
      "In 'fils' (son), the final 's' is exceptionally pronounced, unlike most French words where a final 's' is silent."),
  _fq("Quel mot contient un son [u] comme dans 'nous' ?",
      ["Vous", "Vu", "Vent", "Vin"], "Vous",
      "'Vous' contains the vowel sound [u], spelled 'ou', matching the sound heard in 'nous'."),
  _fq("Quelle lettre est generalement muette a la fin du mot 'petit' ?",
      ["T", "P", "E", "I"], "T",
      "The final 't' in 'petit' is silent in standard pronunciation, unless followed by a vowel in liaison (e.g., 'petit ami')."),
  _fq("Quel mot illustre la liaison obligatoire ?",
      ["Les_amis", "Les / chats", "Un / livre", "Deux / femmes"], "Les_amis",
      "Liaison is obligatory between 'les' and a following vowel-initial word, pronounced 'lez‿amis'."),
  _fq("Quel son la combinaison de lettres 'ch' represente-t-elle generalement en francais ?",
      ["[ʃ] comme dans 'chat'", "[k] comme dans 'kilo'", "[s] comme dans 'sac'", "[g] comme dans 'gare'"], "[ʃ] comme dans 'chat'",
      "In standard French, 'ch' is typically pronounced [ʃ], the 'sh' sound, as in 'chat' (cat)."),
  _fq("Quel mot contient le son nasal [ɛ̃] comme dans 'vin' ?",
      ["Pain", "Pomme", "Poule", "Paix"], "Pain",
      "'Pain' contains the nasal vowel [ɛ̃], spelled 'ain', producing a sound similar to that in 'vin'."),
  _fq("Dans le mot 'hotel', la lettre 'h' est",
      ["muette (h muet)", "aspiree fortement", "prononcee comme en anglais", "toujours accentuee"], "muette (h muet)",
      "Most French words beginning with 'h' have a silent 'h muet', allowing elision, as in 'l'hotel'."),
  _fq("Quel mot rime phonetiquement avec 'beau' ?",
      ["Chateau", "Belle", "Bonne", "Boule"], "Chateau",
      "'Beau' and 'chateau' both end with the vowel sound [o], making them rhyme phonetically."),
  _fq("Quelle est la particularite phonetique de l'accent circonflexe dans 'fenetre' ?",
      ["Il peut indiquer une voyelle historiquement plus longue mais souvent prononcee comme un 'e' ouvert", "Il rend la lettre muette", "Il transforme la voyelle en consonne", "Il indique toujours une nasalisation"], "Il peut indiquer une voyelle historiquement plus longue mais souvent prononcee comme un 'e' ouvert",
      "The circumflex accent in 'fenetre' often marks a historically lost 's' and is pronounced as an open 'e' sound in modern French."),
];

// ---------------------------------------------------------------------------
// Culture / Civilization
// ---------------------------------------------------------------------------

final _cultureAndCivilization = [
  _fq("Quelle est la capitale de la France ?",
      ["Paris", "Lyon", "Marseille", "Nice"], "Paris",
      "Paris is the capital and largest city of France, its political and cultural center."),
  _fq("Quel fleuve traverse la ville de Paris ?",
      ["La Seine", "La Loire", "Le Rhone", "La Garonne"], "La Seine",
      "The Seine river flows through the heart of Paris, past landmarks such as the Eiffel Tower and Notre-Dame."),
  _fq("Quelle est la monnaie utilisee en France ?",
      ["L'euro", "Le franc", "Le dollar", "La livre sterling"], "L'euro",
      "France, as a member of the eurozone, uses the euro as its official currency."),
  _fq("Quel pays d'Afrique de l'Ouest a le francais comme langue officielle et partage une frontiere avec le Nigeria ?",
      ["Le Benin", "Le Ghana", "La Sierra Leone", "Le Liberia"], "Le Benin",
      "Benin, a French-speaking country, shares a border with Nigeria and uses French as its official language."),
  _fq("Comment appelle-t-on l'ensemble des pays ou le francais est parle officiellement ou couramment ?",
      ["La francophonie", "L'anglophonie", "La latinophonie", "L'europhonie"], "La francophonie",
      "'La francophonie' refers to the community of French-speaking countries and regions across the world."),
  _fq("Quel est le monument le plus celebre de Paris, construit pour l'Exposition universelle de 1889 ?",
      ["La tour Eiffel", "L'Arc de Triomphe", "Le Louvre", "Notre-Dame de Paris"], "La tour Eiffel",
      "The Eiffel Tower was built for the 1889 World's Fair and remains Paris's most iconic monument."),
  _fq("Quelle fete nationale francaise est celebree le 14 juillet ?",
      ["La fete nationale (prise de la Bastille)", "Noel", "La fete du travail", "La fete de la musique"], "La fete nationale (prise de la Bastille)",
      "14 July commemorates the storming of the Bastille in 1789 and is celebrated as France's national day."),
  _fq("Quel musee parisien abrite le tableau de la Joconde ?",
      ["Le Louvre", "Le musee d'Orsay", "Le Centre Pompidou", "Le musee Rodin"], "Le Louvre",
      "The Mona Lisa (la Joconde) is housed in the Louvre Museum in Paris."),
  _fq("Quel pays d'Afrique du Nord, ancienne colonie francaise, est connu pour sa proximite avec l'Europe et son usage du francais dans l'administration ?",
      ["Le Maroc", "L'Egypte", "Le Kenya", "La Somalie"], "Le Maroc",
      "Morocco, a former French protectorate, retains French as an important language in administration, business, and education."),
  _fq("Quel plat est traditionnellement associe a la gastronomie francaise ?",
      ["Le coq au vin", "Le jollof rice", "Le couscous marocain", "Le sushi"], "Le coq au vin",
      "'Coq au vin' (chicken cooked in wine) is a classic French dish, a staple of traditional French cuisine."),
  _fq("Quel ecrivain francais est l'auteur des 'Miserables' ?",
      ["Victor Hugo", "Albert Camus", "Jean-Paul Sartre", "Voltaire"], "Victor Hugo",
      "Victor Hugo, a major 19th-century French writer, is the author of the classic novel 'Les Miserables'."),
  _fq("Quelle organisation regroupe plusieurs pays francophones pour promouvoir la langue et la culture francaises dans le monde ?",
      ["L'Organisation internationale de la Francophonie (OIF)", "L'Union africaine", "L'ONU", "La CEDEAO"], "L'Organisation internationale de la Francophonie (OIF)",
      "The OIF is the international body that unites French-speaking countries to promote the French language and shared cultural values."),
  _fq("Quelle ville francaise est reputee pour ses vignobles et sa production de vin de renommee mondiale ?",
      ["Bordeaux", "Lille", "Strasbourg", "Rennes"], "Bordeaux",
      "Bordeaux is world-famous for its extensive vineyards and high-quality wine production."),
  _fq("Quel pays francophone d'Afrique de l'Ouest est le voisin direct du Nigeria a l'ouest, connu pour son ancienne capitale Porto-Novo ?",
      ["Le Benin", "Le Togo", "Le Niger", "Le Cameroun"], "Le Benin",
      "Benin, whose official capital is Porto-Novo, lies directly to the west of Nigeria and is Francophone."),
  _fq("Comment dit-on 'bonjour' de maniere informelle en francais familier, souvent utilisee entre amis ?",
      ["Salut", "Adieu", "Au revoir", "Pardon"], "Salut",
      "'Salut' is an informal greeting used casually among friends, unlike the more formal 'bonjour'."),
];
