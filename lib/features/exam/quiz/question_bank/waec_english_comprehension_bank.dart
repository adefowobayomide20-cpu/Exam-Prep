import "../quiz_question.dart";

const _subject = "English Language";

class _PassageQ {
  const _PassageQ(this.question, this.options, this.correct, this.explanation);

  final String question;
  final List<String> options;
  final String correct;
  final String explanation;
}

List<QuizQuestion> _passage(String text, List<_PassageQ> questions) {
  return questions
      .map((q) => QuizQuestion(
            subject: _subject,
            text: "$text\n\n${q.question}",
            options: q.options,
            correctIndex: q.options.indexOf(q.correct),
            explanation: q.explanation,
          ))
      .toList();
}

/// WAEC Reading Comprehension (Paper 2, Section B): each short passage is
/// followed by ten questions covering factual recall, inference, figures of
/// speech, vocabulary-in-context, and the grammatical function of specific
/// phrases or clauses within the passage — matching the real paper's format.
List<QuizQuestion> buildWaecEnglishComprehensionQuestions() {
  return [
    ..._passage1,
    ..._passage2,
    ..._passage3,
    ..._passage4,
    ..._passage5,
    ..._passage6,
    ..._passage7,
    ..._passage8,
    ..._passage9,
    ..._passage10,
    ..._passage11,
    ..._passage12,
    ..._passage13,
    ..._passage14,
    ..._passage15,
    ..._passage16,
    ..._passage17,
    ..._passage18,
    ..._passage19,
    ..._passage20,
  ];
}

const _text1 =
    "When Ngozi's father lost his job at the textile factory, the family's fortunes changed almost overnight. "
    "Gone were the weekend outings to the cinema; gone too was the extra plate of meat at dinner. Ngozi, "
    "then in her final year of secondary school, watched her mother take up petty trading to keep the household "
    "afloat, rising before dawn to fry akara by the roadside. Rather than sink into despair, Ngozi resolved that "
    "her family's hardship would be the fuel, not the flame, that consumed her ambitions. She studied by candlelight "
    "when the electricity failed, borrowed textbooks from wealthier classmates, and tutored younger pupils for a "
    "small fee to contribute to the family's income. When the results of the West African Senior School Certificate "
    "Examination were released, Ngozi had distinctions in eight subjects — a feat that stunned even her teachers. "
    "Her story, whispered admiringly around the school compound, became a quiet rebuke to anyone who believed that "
    "poverty was an excuse for mediocrity.";

final _passage1 = _passage(_text1, const [
  _PassageQ("According to the passage, what event changed the fortunes of Ngozi's family?",
      ["Her father lost his job", "Her mother fell ill", "The family home was destroyed", "Ngozi failed her examinations"],
      "Her father lost his job", "The passage opens by stating that the father's job loss at the textile factory changed the family's fortunes."),
  _PassageQ("What did Ngozi's mother do to support the household?",
      ["She took up petty trading, frying akara", "She sold the family car", "She travelled abroad for work", "She asked relatives for a loan"],
      "She took up petty trading, frying akara", "The passage states the mother took up petty trading, rising before dawn to fry akara by the roadside."),
  _PassageQ("What can be inferred about Ngozi's character from the passage?",
      ["She is resilient and determined despite hardship", "She is dependent on others for success", "She is indifferent to her family's struggles", "She gave up on her education"],
      "She is resilient and determined despite hardship", "Her decision to study by candlelight and tutor others despite hardship shows resilience and determination."),
  _PassageQ("Why did Ngozi tutor younger pupils, based on the passage?",
      ["To contribute to the family's income", "To become a teacher in future", "Because her school required it", "To avoid doing house chores"],
      "To contribute to the family's income", "The passage states she tutored younger pupils for a small fee to contribute to the family's income."),
  _PassageQ("In the context of the passage, the word 'mediocrity' is nearest in meaning to:",
      ["excellence", "average or unremarkable performance", "extreme poverty", "academic failure only"], "average or unremarkable performance",
      "'Mediocrity' refers to a quality that is only average or unremarkable, not necessarily total failure."),
  _PassageQ("In the context of the passage, the word 'rebuke' is nearest in meaning to:",
      ["a reprimand or criticism", "a celebration", "a reward", "an invitation"], "a reprimand or criticism",
      "'Rebuke' means an expression of criticism or disapproval, here directed at those who use poverty as an excuse."),
  _PassageQ("What figure of speech is used in the phrase 'the fuel, not the flame, that consumed her ambitions'?",
      ["Metaphor", "Simile", "Onomatopoeia", "Alliteration"], "Metaphor",
      "This is a metaphor, comparing hardship to fuel that powers ambition rather than a flame that destroys it, without using 'like' or 'as'."),
  _PassageQ("Which of the following best captures the main idea of the passage?",
      ["Hardship can be transformed into motivation for success", "Poverty always leads to academic failure", "Family support guarantees good grades", "Trading is more profitable than education"],
      "Hardship can be transformed into motivation for success", "The passage centres on how Ngozi turned her family's hardship into motivation to excel academically."),
  _PassageQ("In the sentence 'Rather than sink into despair, Ngozi resolved that her family's hardship would be the fuel...', what is the grammatical function of 'Rather than sink into despair'?",
      ["An adverbial clause of contrast/manner modifying the main clause", "A noun clause functioning as the subject", "An adjectival clause modifying 'Ngozi'", "A relative clause modifying 'despair'"],
      "An adverbial clause of contrast/manner modifying the main clause",
      "This clause shows what Ngozi chose not to do, contrasting with her actual response, functioning adverbially."),
  _PassageQ("In the sentence 'Her story, whispered admiringly around the school compound, became a quiet rebuke...', what is the grammatical function of 'whispered admiringly around the school compound'?",
      ["A participial (adjectival) phrase modifying 'story'", "The main verb of the sentence", "A noun clause functioning as the object", "An adverbial clause of time"],
      "A participial (adjectival) phrase modifying 'story'",
      "This non-finite participial phrase gives extra descriptive information about 'her story', functioning adjectivally."),
]);

const _text2 =
    "The rapid spread of smartphones across rural Nigeria has quietly transformed the way farmers conduct business. "
    "A decade ago, a maize farmer in a remote village had to rely on middlemen to learn the going price of grain in "
    "distant urban markets, a arrangement that often left him at the mercy of unscrupulous traders. Today, that same "
    "farmer can consult a mobile application, compare prices across three states, and negotiate from a position of "
    "knowledge rather than ignorance. Agricultural extension officers have also embraced the technology, sending "
    "voice notes in local languages to warn of impending pest outbreaks or advise on planting seasons. Yet the "
    "revolution remains incomplete. Many villages still lack reliable network coverage, and older farmers, unfamiliar "
    "with touchscreens, often depend on their literate grandchildren to operate the very devices meant to empower "
    "them. Bridging this final gap, analysts argue, will determine whether the digital transformation of agriculture "
    "becomes a genuine leveller or merely another advantage reserved for the already privileged.";

final _passage2 = _passage(_text2, const [
  _PassageQ("According to the passage, what problem did farmers face a decade ago?",
      ["They had to rely on middlemen for price information", "They had no access to fertile land", "They could not grow maize successfully", "They lacked farming tools"],
      "They had to rely on middlemen for price information", "The passage states farmers relied on middlemen to learn grain prices in distant markets."),
  _PassageQ("What are agricultural extension officers doing with technology, according to the passage?",
      ["Sending voice notes about pests and planting seasons", "Building new roads to villages", "Selling smartphones to farmers", "Constructing new markets"],
      "Sending voice notes about pests and planting seasons", "The passage states extension officers send voice notes warning of pest outbreaks or advising on planting seasons."),
  _PassageQ("What can be inferred about older farmers from the passage?",
      ["They may struggle with new technology and need help from younger relatives", "They refuse to use any modern equipment", "They earn more money than younger farmers", "They have abandoned farming entirely"],
      "They may struggle with new technology and need help from younger relatives",
      "The passage states older farmers depend on their literate grandchildren to operate the devices, implying difficulty with the technology."),
  _PassageQ("What does the passage suggest could prevent the digital transformation from truly benefiting all farmers?",
      ["Unequal access to network coverage and technology literacy", "A lack of interest in farming among the youth", "Poor soil quality across the country", "Government bans on mobile phones"],
      "Unequal access to network coverage and technology literacy",
      "The passage highlights unreliable network coverage and unfamiliarity with technology as barriers to inclusive benefit."),
  _PassageQ("In the context of the passage, the word 'unscrupulous' is nearest in meaning to:",
      ["dishonest or unprincipled", "highly organised", "generous", "inexperienced"], "dishonest or unprincipled",
      "'Unscrupulous' describes people who behave dishonestly or without moral principles, as suggested by traders exploiting farmers' ignorance."),
  _PassageQ("In the context of the passage, the word 'leveller' is nearest in meaning to:",
      ["something that creates equal opportunity", "a farming tool", "a type of currency", "a government policy"], "something that creates equal opportunity",
      "A 'leveller' is something that removes inequality, giving all people the same opportunity, as hoped for with digital technology."),
  _PassageQ("What figure of speech is present in the phrase 'left him at the mercy of unscrupulous traders'?",
      ["Personification of mercy as something that can be controlled by traders", "Simile", "Onomatopoeia", "Hyperbole"], "Personification of mercy as something that can be controlled by traders",
      "The phrase attributes a human-like quality of control to an abstract situation, suggesting the farmer had no power, a form of figurative language bordering on personification of the situation."),
  _PassageQ("Which of the following best captures the main idea of the passage?",
      ["Mobile technology has improved farming but has not yet reached everyone equally", "All farmers now use smartphones successfully", "Farming has declined due to technology", "Middlemen still control all agricultural trade"],
      "Mobile technology has improved farming but has not yet reached everyone equally",
      "The passage discusses both the benefits of mobile technology for farmers and the remaining gaps in access."),
  _PassageQ("In the sentence 'Today, that same farmer can consult a mobile application, compare prices...and negotiate from a position of knowledge rather than ignorance', what is the grammatical function of 'rather than ignorance'?",
      ["An adverbial phrase of contrast modifying 'negotiate'", "A noun phrase functioning as the subject", "An adjectival phrase modifying 'farmer'", "The direct object of 'consult'"],
      "An adverbial phrase of contrast modifying 'negotiate'",
      "'Rather than ignorance' contrasts with 'from a position of knowledge', modifying how the farmer negotiates."),
  _PassageQ("In the sentence 'Bridging this final gap, analysts argue, will determine whether the digital transformation...becomes a genuine leveller', what is the grammatical function of 'Bridging this final gap'?",
      ["A gerund phrase functioning as the subject of the sentence", "An adjectival clause modifying 'analysts'", "A prepositional phrase showing location", "An interjection"],
      "A gerund phrase functioning as the subject of the sentence",
      "'Bridging this final gap' is a verbal (gerund) phrase acting as the subject of the verb 'will determine'."),
]);

const _text3 =
    "Few sporting rivalries in West Africa stir as much passion as the annual inter-secondary schools athletics "
    "championship held in the capital. Students who have trained for months on dusty school fields descend upon "
    "the stadium, their school colours fluttering like a thousand competing flags. Last year's final one hundred "
    "metre race will long be remembered, not for the eventual winner, but for a moment of extraordinary sportsmanship. "
    "Halfway through the race, the front-runner, sensing that a rival behind him had stumbled and fallen, slowed his "
    "own stride, turned back, and helped the fallen boy to his feet before both resumed running. Neither finished "
    "among the medal positions, yet the crowd rose as one, applauding a display of character that no trophy could "
    "adequately reward. The incident, captured on countless phone cameras, spread quickly across social media, "
    "prompting the sports ministry to introduce a new fair play award, to be presented annually alongside the "
    "conventional medals for speed and strength.";

final _passage3 = _passage(_text3, const [
  _PassageQ("According to the passage, where is the inter-secondary schools athletics championship held?",
      ["In the capital", "In a rural village", "Outside the country", "At a private school"], "In the capital",
      "The passage states the championship is held annually in the capital."),
  _PassageQ("What happened to the rival runner during the race, according to the passage?",
      ["He stumbled and fell", "He won the race", "He refused to compete", "He injured the front-runner"], "He stumbled and fell",
      "The passage states the rival behind the front-runner had stumbled and fallen."),
  _PassageQ("What can be inferred about the crowd's reaction to the incident?",
      ["They valued sportsmanship more than winning", "They were angry that no one won", "They demanded a rematch", "They ignored the incident completely"],
      "They valued sportsmanship more than winning", "The crowd rising to applaud despite neither runner winning shows they valued the display of character over victory."),
  _PassageQ("What was the outcome for the sports ministry as a result of the incident, according to the passage?",
      ["It introduced a new fair play award", "It banned the athletics championship", "It disqualified both runners", "It reduced funding for sports"],
      "It introduced a new fair play award", "The passage states the incident prompted the sports ministry to introduce a new fair play award."),
  _PassageQ("In the context of the passage, the word 'stride' is nearest in meaning to:",
      ["a step or pace while running", "a type of shoe", "a racing lane", "a finish line"], "a step or pace while running",
      "'Stride' refers to a long, deliberate step, especially while running or walking."),
  _PassageQ("In the context of the passage, the phrase 'rose as one' is nearest in meaning to:",
      ["stood up together in unison", "left the stadium quietly", "argued among themselves", "sat down in protest"], "stood up together in unison",
      "'Rose as one' means the crowd stood up together simultaneously, showing unified reaction."),
  _PassageQ("What figure of speech is used in the phrase 'their school colours fluttering like a thousand competing flags'?",
      ["Simile", "Metaphor", "Onomatopoeia", "Personification"], "Simile",
      "This is a simile because it uses 'like' to compare the school colours to competing flags."),
  _PassageQ("Which of the following best captures the main idea of the passage?",
      ["A moment of sportsmanship became more memorable than winning the race", "The championship was cancelled due to an accident", "Only the fastest runner is remembered from competitions", "Social media coverage of sports is always negative"],
      "A moment of sportsmanship became more memorable than winning the race",
      "The passage focuses on how an act of sportsmanship overshadowed the actual competition results."),
  _PassageQ("In the sentence 'Halfway through the race, the front-runner, sensing that a rival behind him had stumbled and fallen, slowed his own stride...', what is the grammatical function of 'sensing that a rival behind him had stumbled and fallen'?",
      ["A participial phrase modifying 'the front-runner'", "A noun clause functioning as the object of 'slowed'", "An adverbial clause of place", "The main verb phrase of the sentence"],
      "A participial phrase modifying 'the front-runner'",
      "This non-finite participial phrase describes the front-runner's awareness, modifying the subject 'the front-runner'."),
  _PassageQ("In the sentence 'The incident, captured on countless phone cameras, spread quickly across social media...', what is the grammatical function of 'captured on countless phone cameras'?",
      ["A participial (adjectival) phrase modifying 'the incident'", "An adverbial clause of reason", "A noun clause functioning as the subject", "A prepositional phrase showing time"],
      "A participial (adjectival) phrase modifying 'the incident'",
      "This phrase describes 'the incident', giving additional information about how it was recorded, functioning adjectivally."),
]);

const _text4 =
    "In many Nigerian households, the extended family system functions as an informal social security network, "
    "quietly absorbing shocks that would otherwise devastate a nuclear family. When Uncle Tunde's small business "
    "collapsed during the economic downturn, it was his brothers and cousins, rather than any government agency, "
    "who pooled resources to keep his children in school. Sociologists have long debated whether this arrangement "
    "is a strength or a burden. Proponents argue that it fosters resilience, spreading risk across dozens of "
    "shoulders rather than concentrating it on two overworked parents. Critics counter that the system can breed "
    "resentment, as the more financially successful members of a family are perpetually expected to subsidise "
    "relatives who make little effort to improve their own circumstances. Whatever one's view, the extended family "
    "shows no sign of disappearing; if anything, the retreat of the state from social welfare provision in recent "
    "decades has only deepened society's reliance on this ancient, unwritten contract between kin.";

final _passage4 = _passage(_text4, const [
  _PassageQ("According to the passage, what happened to Uncle Tunde's business?",
      ["It collapsed during the economic downturn", "It expanded rapidly", "It was sold to a competitor", "It was taken over by the government"],
      "It collapsed during the economic downturn", "The passage states Uncle Tunde's small business collapsed during the economic downturn."),
  _PassageQ("Who helped Uncle Tunde's children remain in school, according to the passage?",
      ["His brothers and cousins", "A government agency", "A private charity", "His employer"], "His brothers and cousins",
      "The passage states it was his brothers and cousins who pooled resources to keep his children in school."),
  _PassageQ("What can be inferred about the role of government welfare in this context?",
      ["It appears limited, leaving families to support each other", "It fully replaces the need for family support", "It is more effective than family support", "It does not exist in Nigeria"],
      "It appears limited, leaving families to support each other",
      "The passage notes the family, not government agency, stepped in, and mentions the retreat of state welfare provision."),
  _PassageQ("According to critics mentioned in the passage, what is a drawback of the extended family system?",
      ["It can cause resentment among successful members", "It always leads to business failure", "It discourages education", "It weakens family bonds entirely"],
      "It can cause resentment among successful members",
      "The passage states critics argue successful members may resent perpetually subsidising less industrious relatives."),
  _PassageQ("In the context of the passage, the word 'proponents' is nearest in meaning to:",
      ["supporters of an idea", "opponents of an idea", "government officials", "sociology students"], "supporters of an idea",
      "'Proponents' refers to people who support or argue in favour of something, here the extended family system."),
  _PassageQ("In the context of the passage, the word 'subsidise' is nearest in meaning to:",
      ["financially support", "criticise", "ignore", "compete with"], "financially support",
      "'Subsidise' means to provide financial support to reduce a cost or burden for someone."),
  _PassageQ("What figure of speech is used in the phrase 'this ancient, unwritten contract between kin'?",
      ["Metaphor", "Simile", "Onomatopoeia", "Hyperbole"], "Metaphor",
      "Describing the family obligation as a 'contract' is a metaphor, since no literal legal document exists."),
  _PassageQ("Which of the following best captures the main idea of the passage?",
      ["The extended family system serves as an informal safety net with both benefits and drawbacks", "Extended families always cause financial ruin", "Government welfare has replaced family support entirely", "Nigerian families no longer support each other"],
      "The extended family system serves as an informal safety net with both benefits and drawbacks",
      "The passage explores both the supportive function and the criticisms of the extended family system."),
  _PassageQ("In the sentence 'When Uncle Tunde's small business collapsed during the economic downturn, it was his brothers and cousins...who pooled resources...', what is the grammatical function of 'When Uncle Tunde's small business collapsed during the economic downturn'?",
      ["An adverbial clause of time", "A noun clause functioning as the subject", "An adjectival clause modifying 'brothers'", "A prepositional phrase of place"],
      "An adverbial clause of time", "This clause tells us when the main action took place, functioning as an adverbial clause of time."),
  _PassageQ("In the sentence 'Critics counter that the system can breed resentment, as the more financially successful members...are perpetually expected to subsidise relatives...', what is the grammatical function of 'that the system can breed resentment'?",
      ["A noun clause functioning as the object of 'counter'", "An adjectival clause modifying 'critics'", "An adverbial clause of purpose", "A relative clause modifying 'resentment'"],
      "A noun clause functioning as the object of 'counter'",
      "'That the system can breed resentment' functions as the object of the verb 'counter', making it a noun clause."),
]);

const _text5 =
    "The abandoned railway line that once connected the northern city to the coast is, for most travellers, "
    "little more than a rusting curiosity glimpsed from a bus window. Yet for a small but determined group of "
    "railway enthusiasts, it represents a lost golden age of national infrastructure. Built during the colonial "
    "era to transport groundnuts and cotton to the ports, the railway carried not just cargo but also generations "
    "of students, traders, and civil servants who could not otherwise have afforded to travel such distances. Its "
    "gradual decline, beginning in the 1980s as road transport became cheaper and more flexible, mirrors a broader "
    "pattern across the continent, where ambitious colonial-era rail networks were left to decay rather than "
    "modernised. Recently, however, renewed interest from foreign investors, eager to move minerals more efficiently "
    "than congested roads allow, has breathed fresh hope into plans for restoration. Whether this hope translates "
    "into steel and concrete, or remains another unfulfilled promise in a long list of abandoned proposals, only "
    "time will tell.";

final _passage5 = _passage(_text5, const [
  _PassageQ("According to the passage, what was the railway originally built to transport, aside from passengers?",
      ["Groundnuts and cotton", "Oil and gas", "Timber and rubber", "Livestock only"], "Groundnuts and cotton",
      "The passage states the railway was built to transport groundnuts and cotton to the ports."),
  _PassageQ("When did the railway's decline begin, according to the passage?",
      ["The 1980s", "The 1960s", "The 1990s", "The 2000s"], "The 1980s",
      "The passage states the gradual decline began in the 1980s as road transport became cheaper and more flexible."),
  _PassageQ("What can be inferred about the attitude of railway enthusiasts mentioned in the passage?",
      ["They value the railway's historical significance", "They believe the railway should be demolished", "They think road transport is inferior in every way", "They are uninterested in infrastructure history"],
      "They value the railway's historical significance", "The passage states enthusiasts see the railway as representing a lost golden age of infrastructure."),
  _PassageQ("What is suggested as a reason for renewed interest in restoring the railway?",
      ["Foreign investors want to move minerals more efficiently", "The government has unlimited funds", "Road transport has been banned", "Passenger numbers have increased sharply"],
      "Foreign investors want to move minerals more efficiently",
      "The passage states foreign investors are eager to move minerals more efficiently than congested roads allow."),
  _PassageQ("In the context of the passage, the word 'curiosity' is nearest in meaning to:",
      ["an object of casual interest", "a valuable treasure", "a dangerous structure", "a modern invention"], "an object of casual interest",
      "'Curiosity' here refers to something that draws mild, casual interest, as in a rusting relic seen from a bus window."),
  _PassageQ("In the context of the passage, the word 'mirrors' is nearest in meaning to:",
      ["reflects or resembles", "contradicts", "improves upon", "ignores"], "reflects or resembles",
      "'Mirrors' means to closely resemble or reflect something else, here comparing the railway's decline to a wider pattern."),
  _PassageQ("What figure of speech is present in the phrase 'a rusting curiosity glimpsed from a bus window'?",
      ["Imagery appealing to visual sense", "Onomatopoeia", "Alliteration", "Hyperbole"], "Imagery appealing to visual sense",
      "This phrase uses descriptive, visual imagery to help the reader picture the railway's current state."),
  _PassageQ("Which of the following best captures the main idea of the passage?",
      ["A historic railway's decline may be reversed by renewed investment interest", "The railway was never useful to the country", "All colonial infrastructure has been successfully modernised", "Road transport has completely replaced the need for railways everywhere"],
      "A historic railway's decline may be reversed by renewed investment interest",
      "The passage traces the railway's history, decline, and the possibility of restoration through new investment."),
  _PassageQ("In the sentence 'Built during the colonial era to transport groundnuts and cotton to the ports, the railway carried not just cargo but also generations of students...', what is the grammatical function of 'Built during the colonial era to transport groundnuts and cotton to the ports'?",
      ["A participial phrase modifying 'the railway'", "A noun clause functioning as the subject", "An adverbial clause of condition", "The main verb phrase"],
      "A participial phrase modifying 'the railway'",
      "This non-finite participial phrase gives background information about the railway, modifying the noun 'the railway'."),
  _PassageQ("In the sentence 'Whether this hope translates into steel and concrete...only time will tell', what is the grammatical function of 'Whether this hope translates into steel and concrete, or remains another unfulfilled promise'?",
      ["A noun clause functioning as the subject of 'will tell' (in inverted position)", "An adjectival clause modifying 'hope'", "An adverbial clause of place", "A prepositional phrase"],
      "A noun clause functioning as the subject of 'will tell' (in inverted position)",
      "This 'whether...or' clause functions as a noun clause, effectively the topic that 'only time will tell' about."),
]);

const _text6 =
    "Doctor Amara had seen countless cases of malaria during her years at the rural clinic, but nothing had "
    "prepared her for the outbreak that swept through the fishing community that rainy season. Stagnant pools left "
    "by the flooding had become breeding grounds for mosquitoes, and within weeks, the clinic's twelve beds were "
    "hopelessly insufficient for the flood of feverish patients. Working with little more than a handful of "
    "volunteers and a dwindling stock of medication, she improvised a triage system on the veranda, prioritising "
    "children and pregnant women whose lives hung most precariously in the balance. News of the crisis eventually "
    "reached the state ministry of health, and reinforcements arrived, but not before three lives had already been "
    "lost. In the aftermath, Doctor Amara campaigned tirelessly for a permanent drainage system in the community, "
    "arguing that treating the disease without addressing its environmental cause was like mopping a floor while "
    "the tap kept running. Her advocacy eventually bore fruit; two years later, a functioning drainage network "
    "reduced malaria cases in the community by more than half.";

final _passage6 = _passage(_text6, const [
  _PassageQ("According to the passage, what caused the malaria outbreak in the fishing community?",
      ["Stagnant pools from flooding became mosquito breeding grounds", "A shortage of clean water", "An outbreak of cholera first", "Poor quality medication"],
      "Stagnant pools from flooding became mosquito breeding grounds", "The passage states stagnant pools left by flooding became breeding grounds for mosquitoes."),
  _PassageQ("Who did Doctor Amara prioritise in her triage system, according to the passage?",
      ["Children and pregnant women", "The elderly only", "Government officials", "Fishermen only"], "Children and pregnant women",
      "The passage states she prioritised children and pregnant women whose lives hung most precariously in the balance."),
  _PassageQ("What can be inferred about the clinic's resources during the outbreak?",
      ["They were severely inadequate for the scale of the crisis", "They were more than sufficient", "They had been recently upgraded", "They were unaffected by the outbreak"],
      "They were severely inadequate for the scale of the crisis",
      "The passage describes twelve beds as 'hopelessly insufficient' and mentions a 'dwindling stock of medication'."),
  _PassageQ("What was the long-term result of Doctor Amara's advocacy, according to the passage?",
      ["A drainage network reduced malaria cases by more than half", "The clinic was permanently closed", "The community relocated entirely", "Malaria cases increased further"],
      "A drainage network reduced malaria cases by more than half",
      "The passage states that two years later, a functioning drainage network reduced malaria cases by more than half."),
  _PassageQ("In the context of the passage, the word 'precariously' is nearest in meaning to:",
      ["in an uncertain or dangerous state", "in a safe and secure state", "in a joyful state", "in a permanent state"], "in an uncertain or dangerous state",
      "'Precariously' describes a situation that is unstable and dangerous, here referring to lives at risk."),
  _PassageQ("In the context of the passage, the phrase 'bore fruit' is nearest in meaning to:",
      ["produced positive results", "failed completely", "grew literal fruit trees", "was ignored by officials"], "produced positive results",
      "'Bore fruit' is an idiom meaning that efforts eventually produced successful or positive results."),
  _PassageQ("What figure of speech is used in the phrase 'like mopping a floor while the tap kept running'?",
      ["Simile", "Metaphor", "Onomatopoeia", "Personification"], "Simile",
      "This is a simile, using 'like' to compare treating disease symptoms without addressing the cause to mopping a floor with the tap still running."),
  _PassageQ("Which of the following best captures the main idea of the passage?",
      ["Addressing the root cause of a health crisis proved more effective than treating symptoms alone", "Malaria cannot be prevented through infrastructure", "The clinic had more than enough resources for the outbreak", "Government reinforcements arrived before any lives were lost"],
      "Addressing the root cause of a health crisis proved more effective than treating symptoms alone",
      "The passage highlights how tackling the environmental cause (stagnant water) through drainage ultimately reduced malaria cases."),
  _PassageQ("In the sentence 'Working with little more than a handful of volunteers and a dwindling stock of medication, she improvised a triage system...', what is the grammatical function of 'Working with little more than a handful of volunteers and a dwindling stock of medication'?",
      ["A participial phrase modifying 'she'", "A noun clause functioning as the object", "An adverbial clause of condition", "A relative clause modifying 'medication'"],
      "A participial phrase modifying 'she'",
      "This non-finite participial phrase describes the circumstances under which the subject 'she' acted."),
  _PassageQ("In the sentence 'News of the crisis eventually reached the state ministry of health, and reinforcements arrived, but not before three lives had already been lost', what is the grammatical function of 'but not before three lives had already been lost'?",
      ["An adverbial clause of time showing a contrasting sequence", "A noun clause functioning as the subject", "An adjectival clause modifying 'reinforcements'", "An interjection"],
      "An adverbial clause of time showing a contrasting sequence",
      "This clause shows the timing of events in contrast to the arrival of reinforcements, functioning as an adverbial clause of time."),
]);

const _text7 =
    "It is easy, from the comfort of a well-lit office, to romanticise the life of a long-distance truck driver "
    "hauling goods across the trans-Saharan trade route. The reality, as any veteran driver will attest, is a "
    "gruelling test of endurance measured in cracked windscreens, sleepless nights, and the ever-present risk of "
    "armed robbery on isolated stretches of highway. Alhaji Musa has driven this route for over twenty years, "
    "ferrying everything from bags of rice to secondhand car parts between the coast and the interior. He speaks "
    "of the job not with romantic nostalgia but with the weary pragmatism of a man who has simply found no better "
    "alternative to feed his family. The introduction of GPS tracking and mobile banking has eased some burdens, "
    "allowing drivers to alert their companies instantly in emergencies and receive payment without carrying "
    "dangerous amounts of cash. Yet the fundamental hazards of the road, from potholes the size of small ponds to "
    "checkpoints manned by officials seeking bribes, remain stubbornly unchanged, a reminder that technology alone "
    "cannot repair what decades of poor infrastructure investment have broken.";

final _passage7 = _passage(_text7, const [
  _PassageQ("According to the passage, how long has Alhaji Musa driven the trans-Saharan route?",
      ["Over twenty years", "Five years", "Ten years", "Two years"], "Over twenty years",
      "The passage states Alhaji Musa has driven this route for over twenty years."),
  _PassageQ("What goods does Alhaji Musa transport, according to the passage?",
      ["Bags of rice and secondhand car parts", "Only fuel and oil", "Livestock exclusively", "Electronics only"], "Bags of rice and secondhand car parts",
      "The passage states he ferries everything from bags of rice to secondhand car parts."),
  _PassageQ("What can be inferred about Alhaji Musa's attitude toward his job?",
      ["He does it out of necessity rather than romantic passion", "He finds the job glamorous and exciting", "He plans to quit immediately", "He is unaware of the job's dangers"],
      "He does it out of necessity rather than romantic passion",
      "The passage states he speaks of the job with 'weary pragmatism' as someone who found no better alternative to feed his family."),
  _PassageQ("What technological improvement has helped drivers, according to the passage?",
      ["GPS tracking and mobile banking", "Self-driving trucks", "Free fuel provided by the government", "New highways built across the desert"],
      "GPS tracking and mobile banking", "The passage states GPS tracking and mobile banking have eased some burdens for drivers."),
  _PassageQ("In the context of the passage, the word 'romanticise' is nearest in meaning to:",
      ["to view something as more appealing than it really is", "to criticise harshly", "to document accurately", "to ignore completely"], "to view something as more appealing than it really is",
      "'Romanticise' means to make something seem more idealistic or attractive than it truly is."),
  _PassageQ("In the context of the passage, the word 'pragmatism' is nearest in meaning to:",
      ["a practical, realistic approach", "an emotional, sentimental attitude", "a careless attitude", "an aggressive approach"], "a practical, realistic approach",
      "'Pragmatism' refers to dealing with situations in a sensible, realistic way rather than based on ideals."),
  _PassageQ("What figure of speech is used in the phrase 'potholes the size of small ponds'?",
      ["Hyperbole", "Onomatopoeia", "Personification", "Alliteration"], "Hyperbole",
      "This is a hyperbole, an exaggeration used to emphasise how large and dangerous the potholes are."),
  _PassageQ("Which of the following best captures the main idea of the passage?",
      ["Technology has eased but not eliminated the hardships faced by long-distance truck drivers", "Truck driving has become completely safe due to modern technology", "Alhaji Musa regrets his career choice deeply", "Poor infrastructure has been fully repaired in recent years"],
      "Technology has eased but not eliminated the hardships faced by long-distance truck drivers",
      "The passage shows that while GPS and mobile banking help, fundamental road hazards remain unchanged."),
  _PassageQ("In the sentence 'He speaks of the job not with romantic nostalgia but with the weary pragmatism of a man who has simply found no better alternative...', what is the grammatical function of 'who has simply found no better alternative to feed his family'?",
      ["An adjectival clause modifying 'a man'", "A noun clause functioning as the object", "An adverbial clause of reason", "A prepositional phrase"],
      "An adjectival clause modifying 'a man'",
      "This relative clause describes 'a man', giving more information about him, functioning as an adjectival clause."),
  _PassageQ("In the sentence 'Yet the fundamental hazards of the road...remain stubbornly unchanged, a reminder that technology alone cannot repair what decades of poor infrastructure investment have broken', what is the grammatical function of 'that technology alone cannot repair what decades of poor infrastructure investment have broken'?",
      ["A noun clause in apposition to 'a reminder'", "An adverbial clause of place", "A relative clause modifying 'hazards'", "The subject of the sentence"],
      "A noun clause in apposition to 'a reminder'",
      "This clause explains or renames 'a reminder', functioning as a noun clause in apposition."),
]);

const _text8 =
    "The debate over whether social media has been a net positive or negative for Nigerian youth shows no sign of "
    "resolution. Advocates point to the democratisation of information: a teenager in a remote village can now "
    "access lectures from world-renowned universities, follow breaking news as it unfolds, and even build a "
    "small business selling handmade crafts to customers thousands of kilometres away. Critics, meanwhile, warn "
    "of the corrosive effects of constant comparison, as curated images of wealth and beauty foster anxiety and "
    "discontent among impressionable minds. Mental health professionals report a marked increase in young patients "
    "citing social media as a contributing factor to their distress, though establishing a direct causal link "
    "remains scientifically contentious. Perhaps the most honest conclusion is that social media, like fire, is "
    "neither inherently good nor evil; its ultimate effect depends entirely on how it is wielded, and by whom. "
    "Parents, educators, and policymakers alike are still groping for the right balance between harnessing its "
    "benefits and shielding young minds from its more corrosive tendencies.";

final _passage8 = _passage(_text8, const [
  _PassageQ("According to the passage, what benefit of social media do advocates highlight?",
      ["Access to educational content and business opportunities", "Guaranteed financial wealth for all users", "Complete elimination of mental health issues", "Unlimited free internet access"],
      "Access to educational content and business opportunities",
      "The passage states advocates point to access to university lectures, breaking news, and building small businesses."),
  _PassageQ("What concern do critics raise about social media, according to the passage?",
      ["It fosters anxiety through constant comparison", "It has completely replaced traditional education", "It has eliminated all forms of business", "It has no effect on young people at all"],
      "It fosters anxiety through constant comparison",
      "The passage states critics warn that curated images of wealth and beauty foster anxiety and discontent."),
  _PassageQ("What can be inferred about the scientific understanding of social media's effect on mental health?",
      ["It is still uncertain and debated among professionals", "It has been fully proven and is undisputed", "It shows social media has no impact at all", "It proves social media is entirely harmless"],
      "It is still uncertain and debated among professionals",
      "The passage states establishing a direct causal link 'remains scientifically contentious'."),
  _PassageQ("According to the passage, what determines whether social media's effect is good or bad?",
      ["How it is used and by whom", "The type of phone being used", "The country where it is used", "The amount of money spent on it"],
      "How it is used and by whom", "The passage states its ultimate effect 'depends entirely on how it is wielded, and by whom'."),
  _PassageQ("In the context of the passage, the word 'corrosive' is nearest in meaning to:",
      ["damaging or destructive over time", "beneficial and healing", "temporary and harmless", "exciting and joyful"], "damaging or destructive over time",
      "'Corrosive' describes something that gradually causes damage, here referring to negative psychological effects."),
  _PassageQ("In the context of the passage, the word 'contentious' is nearest in meaning to:",
      ["likely to cause disagreement", "widely accepted as true", "completely irrelevant", "easily solved"], "likely to cause disagreement",
      "'Contentious' describes something that causes controversy or disagreement, as with the scientific debate mentioned."),
  _PassageQ("What figure of speech is used in the phrase 'social media, like fire, is neither inherently good nor evil'?",
      ["Simile", "Metaphor", "Onomatopoeia", "Alliteration"], "Simile",
      "This is a simile, using 'like' to compare social media to fire in terms of moral neutrality."),
  _PassageQ("Which of the following best captures the main idea of the passage?",
      ["Social media has both benefits and risks, and its impact depends on how it is used", "Social media is entirely harmful to young people", "Social media has been scientifically proven to cause depression", "Only wealthy people benefit from social media"],
      "Social media has both benefits and risks, and its impact depends on how it is used",
      "The passage presents both the advantages and disadvantages of social media, concluding that its effect depends on usage."),
  _PassageQ("In the sentence 'Advocates point to the democratisation of information: a teenager in a remote village can now access lectures from world-renowned universities...', what is the grammatical function of 'in a remote village'?",
      ["A prepositional (adjectival) phrase modifying 'a teenager'", "An adverbial clause of time", "A noun clause functioning as the subject", "The main verb phrase"],
      "A prepositional (adjectival) phrase modifying 'a teenager'",
      "This prepositional phrase describes where the teenager lives, modifying the noun 'a teenager'."),
  _PassageQ("In the sentence 'Parents, educators, and policymakers alike are still groping for the right balance between harnessing its benefits and shielding young minds...', what is the grammatical function of 'harnessing its benefits and shielding young minds from its more corrosive tendencies'?",
      ["A gerund phrase functioning as the object of the preposition 'between'", "An adjectival clause modifying 'balance'", "An adverbial clause of condition", "A noun clause functioning as the subject"],
      "A gerund phrase functioning as the object of the preposition 'between'",
      "This verbal (gerund) phrase functions as the object of the preposition 'between', naming the two things being balanced."),
]);

const _text9 =
    "The city council's decision to convert an abandoned industrial site into a public park was met with scepticism "
    "by residents who had grown accustomed to years of empty promises. For nearly a decade, the derelict warehouse "
    "had served as an unofficial dumping ground, its rusting hulk a magnet for scrap metal thieves and stray dogs. "
    "Community organiser Blessing Eze recalls the first town hall meeting on the proposal, where elderly attendees "
    "openly laughed at officials, having heard similar pledges made and abandoned by three previous administrations. "
    "Yet this time, something was different. A coalition of youth volunteers, armed with little more than "
    "wheelbarrows and stubborn optimism, began clearing debris every Saturday morning, refusing to wait for "
    "government machinery that might never arrive. Their visible progress shamed the council into action, "
    "accelerating budget approvals that might otherwise have languished for years. Eighteen months later, children "
    "who had never known anything but broken glass and weeds now play football on a patch of grass their "
    "grandparents once thought impossible.";

final _passage9 = _passage(_text9, const [
  _PassageQ("According to the passage, what had the derelict warehouse become before the park project began?",
      ["An unofficial dumping ground", "A thriving marketplace", "A school building", "A police station"], "An unofficial dumping ground",
      "The passage states the warehouse had served as an unofficial dumping ground for nearly a decade."),
  _PassageQ("Why did elderly attendees laugh at officials during the town hall meeting, according to the passage?",
      ["They had heard similar broken promises from previous administrations", "They found the proposal genuinely funny", "They did not understand the proposal", "They supported the officials completely"],
      "They had heard similar broken promises from previous administrations",
      "The passage states they had heard similar pledges made and abandoned by three previous administrations."),
  _PassageQ("What can be inferred about the impact of the youth volunteers' actions?",
      ["Their visible effort pressured the council into faster action", "Their actions were ignored by everyone", "They completed the entire project alone without support", "The council opposed their efforts"],
      "Their visible effort pressured the council into faster action",
      "The passage states their visible progress 'shamed the council into action', accelerating budget approvals."),
  _PassageQ("What is the current use of the once-derelict site, according to the passage?",
      ["Children play football there", "It remains an abandoned warehouse", "It has been turned into a shopping mall", "It is used for scrap metal storage"],
      "Children play football there", "The passage states children now play football on the patch of grass at the site."),
  _PassageQ("In the context of the passage, the word 'derelict' is nearest in meaning to:",
      ["abandoned and in poor condition", "newly constructed", "heavily guarded", "extremely valuable"], "abandoned and in poor condition",
      "'Derelict' describes a structure that has been abandoned and allowed to fall into disrepair."),
  _PassageQ("In the context of the passage, the word 'languished' is nearest in meaning to:",
      ["remained neglected or delayed", "progressed rapidly", "was completed early", "was celebrated publicly"], "remained neglected or delayed",
      "'Languished' means to remain in a state of neglect or inactivity for a long period."),
  _PassageQ("What figure of speech is used in the phrase 'its rusting hulk a magnet for scrap metal thieves'?",
      ["Metaphor", "Simile", "Onomatopoeia", "Hyperbole"], "Metaphor",
      "Describing the warehouse as a 'magnet' is a metaphor, implying it strongly attracted thieves without literally being magnetic."),
  _PassageQ("Which of the following best captures the main idea of the passage?",
      ["Persistent community action succeeded in transforming an abandoned site despite official delays", "Government officials completed the park project entirely on their own", "The community never trusted the park project would succeed", "The site remains abandoned to this day"],
      "Persistent community action succeeded in transforming an abandoned site despite official delays",
      "The passage traces how youth volunteers' persistence led to the successful transformation of the site into a park."),
  _PassageQ("In the sentence 'A coalition of youth volunteers, armed with little more than wheelbarrows and stubborn optimism, began clearing debris every Saturday morning...', what is the grammatical function of 'armed with little more than wheelbarrows and stubborn optimism'?",
      ["A participial phrase modifying 'a coalition of youth volunteers'", "A noun clause functioning as the object", "An adverbial clause of time", "The main verb of the sentence"],
      "A participial phrase modifying 'a coalition of youth volunteers'",
      "This non-finite participial phrase describes the volunteers' limited resources, modifying the subject."),
  _PassageQ("In the sentence 'Eighteen months later, children who had never known anything but broken glass and weeds now play football...', what is the grammatical function of 'who had never known anything but broken glass and weeds'?",
      ["An adjectival clause modifying 'children'", "A noun clause functioning as the subject", "An adverbial clause of time", "A prepositional phrase"],
      "An adjectival clause modifying 'children'",
      "This relative clause describes 'children', giving background information about their past experience."),
]);

const _text10 =
    "Chief Okonjo's decision to send all four of his daughters to university, at a time when many of his peers "
    "considered such an investment wasted on girls destined for marriage, was regarded in the village as either "
    "visionary or reckless, depending on whom one asked. He had little formal education himself, having left school "
    "after primary six to help on the family farm, and he often said that his own limitations were precisely why he "
    "refused to impose them on his children. His eldest daughter now practises medicine in the state capital; the "
    "second manages a thriving textile business; the third teaches physics to secondary school students; and the "
    "youngest, still in her final year, hopes to become an engineer. Neighbours who once whispered that Chief Okonjo "
    "was squandering his modest savings on daughters who would simply marry and leave now send their own daughters "
    "to ask his advice. He accepts the belated praise with characteristic modesty, insisting that he merely refused "
    "to let tradition dictate the limits of what his children could achieve.";

final _passage10 = _passage(_text10, const [
  _PassageQ("According to the passage, what did Chief Okonjo decide to do for his daughters?",
      ["Send all four of them to university", "Arrange marriages for all of them", "Keep them at home to help on the farm", "Send only the eldest to school"],
      "Send all four of them to university", "The passage states he decided to send all four of his daughters to university."),
  _PassageQ("Why did Chief Okonjo leave school, according to the passage?",
      ["To help on the family farm", "Because he failed his examinations", "Because the school closed down", "Because his family could not afford fees"],
      "To help on the family farm", "The passage states he left school after primary six to help on the family farm."),
  _PassageQ("What can be inferred about the villagers' initial attitude toward Chief Okonjo's decision?",
      ["Many considered it a poor investment because his children were daughters", "Everyone fully supported his decision from the start", "They believed it would bring immediate wealth", "They were indifferent to his choice"],
      "Many considered it a poor investment because his children were daughters",
      "The passage states his peers considered such investment wasted on girls destined for marriage, and neighbours once whispered he was squandering savings."),
  _PassageQ("What are the current occupations of Chief Okonjo's daughters, according to the passage?",
      ["Medicine, textile business, teaching, and engineering studies", "All four are farmers", "All four are unemployed", "All four became traders"],
      "Medicine, textile business, teaching, and engineering studies",
      "The passage lists medicine, a textile business, teaching physics, and studying to become an engineer."),
  _PassageQ("In the context of the passage, the word 'squandering' is nearest in meaning to:",
      ["wasting resources carelessly", "investing wisely", "saving carefully", "donating generously"], "wasting resources carelessly",
      "'Squandering' means spending or using something, especially money, wastefully."),
  _PassageQ("In the context of the passage, the word 'belated' is nearest in meaning to:",
      ["coming later than expected", "arriving on time", "given in advance", "completely undeserved"], "coming later than expected",
      "'Belated' describes something that occurs later than it should have, here referring to praise that came after years of doubt."),
  _PassageQ("What figure of speech, if any, best describes the phrase 'let tradition dictate the limits'?",
      ["Personification of tradition as having authority to command", "Simile", "Onomatopoeia", "Hyperbole"], "Personification of tradition as having authority to command",
      "Tradition is given the human quality of being able to 'dictate', which is a form of personification."),
  _PassageQ("Which of the following best captures the main idea of the passage?",
      ["A father's unconventional investment in his daughters' education ultimately proved successful", "Education for girls is unnecessary in traditional societies", "Chief Okonjo regretted his decision to educate his daughters", "The daughters all abandoned their careers after marriage"],
      "A father's unconventional investment in his daughters' education ultimately proved successful",
      "The passage traces how Chief Okonjo's decision, once doubted, resulted in his daughters' successful careers."),
  _PassageQ("In the sentence 'He had little formal education himself, having left school after primary six to help on the family farm...', what is the grammatical function of 'having left school after primary six to help on the family farm'?",
      ["A participial phrase modifying 'He'", "A noun clause functioning as the object", "An adverbial clause of condition", "The main verb of the sentence"],
      "A participial phrase modifying 'He'",
      "This non-finite participial phrase explains background information about the subject 'He', functioning adjectivally."),
  _PassageQ("In the sentence 'He accepts the belated praise with characteristic modesty, insisting that he merely refused to let tradition dictate the limits of what his children could achieve', what is the grammatical function of 'that he merely refused to let tradition dictate the limits of what his children could achieve'?",
      ["A noun clause functioning as the object of 'insisting'", "An adjectival clause modifying 'praise'", "An adverbial clause of time", "A prepositional phrase"],
      "A noun clause functioning as the object of 'insisting'",
      "This clause states what he insists, functioning as the direct object of the participle 'insisting'."),
]);

const _text11 =
    "Few natural phenomena capture the imagination quite like the harmattan, the dry, dust-laden wind that sweeps "
    "down from the Sahara each year, coating rooftops in a fine ochre film and turning the sky a hazy grey-brown "
    "for weeks on end. For children in many parts of West Africa, the harmattan season carries a peculiar magic: "
    "school mornings so cold that breath fogs in the air, followed by afternoons where the same dust that irritates "
    "throats and cracks lips also produces spectacular sunsets, the sun reduced to a dull orange disc one can stare "
    "at directly. Farmers view the season with more ambivalence, welcoming the dry conditions that ease harvesting "
    "but dreading the moisture the parched air steals from their remaining crops. Meteorologists, meanwhile, study "
    "the harmattan's intensity as an indicator of the coming rainy season, with an unusually fierce harmattan often, "
    "though not always reliably, preceding heavier rains. Whatever one's perspective, the harmattan remains an "
    "unshakeable fixture of the regional calendar, as certain and as commented upon as the changing of the seasons "
    "anywhere else in the world.";

final _passage11 = _passage(_text11, const [
  _PassageQ("According to the passage, where does the harmattan wind originate?",
      ["The Sahara", "The Atlantic Ocean", "The mountains of East Africa", "The Mediterranean Sea"], "The Sahara",
      "The passage states the harmattan sweeps down from the Sahara each year."),
  _PassageQ("What effect does the harmattan have on farmers, according to the passage?",
      ["It eases harvesting but dries out remaining crops", "It has no effect on farming at all", "It destroys all crops immediately", "It only benefits farmers with no drawbacks"],
      "It eases harvesting but dries out remaining crops",
      "The passage states farmers welcome the dry conditions for harvesting but dread the moisture stolen from their crops."),
  _PassageQ("What can be inferred about meteorologists' view of the harmattan?",
      ["They see it as a possible, though imperfect, indicator of the coming rainy season", "They believe it has no connection to future weather", "They consider it entirely predictable and reliable", "They ignore it in weather forecasting"],
      "They see it as a possible, though imperfect, indicator of the coming rainy season",
      "The passage states an unusually fierce harmattan often, though not always reliably, precedes heavier rains."),
  _PassageQ("What do children in the passage seem to associate with the harmattan?",
      ["Cold mornings and spectacular sunsets", "Extreme heat only", "Heavy rainfall", "School closures every day"], "Cold mornings and spectacular sunsets",
      "The passage describes cold school mornings and spectacular sunsets as part of children's experience of the harmattan."),
  _PassageQ("In the context of the passage, the word 'ambivalence' is nearest in meaning to:",
      ["mixed or contradictory feelings", "complete certainty", "extreme anger", "total indifference"], "mixed or contradictory feelings",
      "'Ambivalence' describes having mixed feelings, here welcoming some effects of the harmattan while dreading others."),
  _PassageQ("In the context of the passage, the word 'parched' is nearest in meaning to:",
      ["extremely dry", "soaking wet", "freshly watered", "freezing cold"], "extremely dry",
      "'Parched' describes something that has become extremely dry, especially due to heat or lack of moisture."),
  _PassageQ("What figure of speech is used in the phrase 'the sun reduced to a dull orange disc one can stare at directly'?",
      ["Imagery appealing to the visual sense", "Onomatopoeia", "Alliteration", "Personification"], "Imagery appealing to the visual sense",
      "This phrase creates a vivid visual picture of the dust-dimmed sun, appealing to the reader's sense of sight."),
  _PassageQ("Which of the following best captures the main idea of the passage?",
      ["The harmattan affects different groups of people in varied ways, but remains a defining seasonal feature", "The harmattan is universally disliked by everyone in West Africa", "The harmattan has no impact on daily life", "The harmattan always predicts exact rainfall patterns"],
      "The harmattan affects different groups of people in varied ways, but remains a defining seasonal feature",
      "The passage presents varied perspectives (children, farmers, meteorologists) while establishing the harmattan as a consistent seasonal phenomenon."),
  _PassageQ("In the sentence 'Farmers view the season with more ambivalence, welcoming the dry conditions that ease harvesting but dreading the moisture the parched air steals from their remaining crops', what is the grammatical function of 'that ease harvesting'?",
      ["An adjectival clause modifying 'the dry conditions'", "A noun clause functioning as the subject", "An adverbial clause of manner", "A prepositional phrase"],
      "An adjectival clause modifying 'the dry conditions'",
      "This relative clause describes 'the dry conditions', functioning as an adjectival clause."),
  _PassageQ("In the sentence 'Meteorologists, meanwhile, study the harmattan's intensity as an indicator of the coming rainy season, with an unusually fierce harmattan often...preceding heavier rains', what is the grammatical function of 'with an unusually fierce harmattan often...preceding heavier rains'?",
      ["An adverbial phrase providing additional supporting detail", "The main verb phrase of the sentence", "A noun clause functioning as the object", "An interjection"],
      "An adverbial phrase providing additional supporting detail",
      "This phrase, introduced by 'with', adds extra explanatory detail about the relationship being discussed, functioning adverbially."),
]);

const _text12 =
    "When the government first announced plans to phase out the popular but heavily polluting two-stroke motorcycle "
    "taxis, known locally as okada, from the city centre, the reaction from riders was swift and furious. For tens "
    "of thousands of young men, many of whom had abandoned fruitless searches for formal employment, the okada "
    "represented not just a job but a fragile foothold on economic dignity. Protests shut down major roads for "
    "three consecutive days, forcing the transport ministry back to the negotiating table. The eventual compromise, "
    "brokered after weeks of tense discussion, allowed riders to convert their two-stroke engines to cleaner "
    "four-stroke alternatives at a heavily subsidised cost, spreading payments over eighteen months. Environmental "
    "campaigners grumbled that the deal was too generous to an industry they blamed for choking the city with "
    "exhaust fumes, while riders' associations complained that even subsidised conversion costs remained beyond "
    "the reach of the poorest operators. The policy, imperfect as it was, nonetheless demonstrated that even the "
    "most entrenched conflicts between economic survival and environmental necessity could yield to patient, if "
    "imperfect, negotiation.";

final _passage12 = _passage(_text12, const [
  _PassageQ("According to the passage, what did the government initially announce plans to do?",
      ["Phase out two-stroke okada motorcycles from the city centre", "Ban all motorcycles permanently nationwide", "Increase taxes on all vehicles", "Build new roads for okada riders"],
      "Phase out two-stroke okada motorcycles from the city centre",
      "The passage states the government announced plans to phase out two-stroke okada from the city centre."),
  _PassageQ("How did riders initially react to the announcement, according to the passage?",
      ["They protested, shutting down major roads for three days", "They immediately accepted the policy", "They ignored the announcement completely", "They relocated to another city"],
      "They protested, shutting down major roads for three days",
      "The passage states protests shut down major roads for three consecutive days."),
  _PassageQ("What can be inferred about the significance of okada work for many young men, according to the passage?",
      ["It provided crucial economic opportunity where formal jobs were scarce", "It was considered an unimportant, minor source of income", "It was primarily a hobby rather than a job", "It required extensive government support to operate"],
      "It provided crucial economic opportunity where formal jobs were scarce",
      "The passage states many riders had abandoned fruitless searches for formal employment and saw okada as a foothold on economic dignity."),
  _PassageQ("What was the eventual compromise reached, according to the passage?",
      ["Subsidised conversion to cleaner four-stroke engines over eighteen months", "A complete and immediate ban on all okada", "Free replacement of motorcycles with cars", "No changes were made to the original policy"],
      "Subsidised conversion to cleaner four-stroke engines over eighteen months",
      "The passage states riders could convert engines to four-stroke alternatives at a subsidised cost over eighteen months."),
  _PassageQ("In the context of the passage, the word 'entrenched' is nearest in meaning to:",
      ["firmly established and difficult to change", "newly created", "easily resolved", "completely imaginary"], "firmly established and difficult to change",
      "'Entrenched' describes something so firmly established that it is difficult to change or remove."),
  _PassageQ("In the context of the passage, the word 'brokered' is nearest in meaning to:",
      ["negotiated or arranged", "cancelled entirely", "ignored completely", "enforced by force"], "negotiated or arranged",
      "'Brokered' means to arrange or negotiate an agreement, typically between conflicting parties."),
  _PassageQ("What figure of speech is used in the phrase 'a fragile foothold on economic dignity'?",
      ["Metaphor", "Simile", "Onomatopoeia", "Hyperbole"], "Metaphor",
      "Describing economic dignity as a 'foothold' is a metaphor, comparing an abstract concept to a physical grip or position."),
  _PassageQ("Which of the following best captures the main idea of the passage?",
      ["A contentious policy conflict was resolved through negotiated compromise, though not without lingering complaints", "The government completely banned okada with no compromise", "Environmental campaigners were fully satisfied with the outcome", "Riders abandoned their protests without any government response"],
      "A contentious policy conflict was resolved through negotiated compromise, though not without lingering complaints",
      "The passage shows how the conflict was resolved through compromise, while noting complaints from both environmentalists and riders."),
  _PassageQ("In the sentence 'For tens of thousands of young men, many of whom had abandoned fruitless searches for formal employment, the okada represented not just a job but a fragile foothold on economic dignity', what is the grammatical function of 'many of whom had abandoned fruitless searches for formal employment'?",
      ["A non-defining adjectival clause modifying 'young men'", "A noun clause functioning as the subject", "An adverbial clause of purpose", "A prepositional phrase"],
      "A non-defining adjectival clause modifying 'young men'",
      "This clause gives extra, non-essential information about the young men, functioning as a non-defining adjectival clause."),
  _PassageQ("In the sentence 'The policy, imperfect as it was, nonetheless demonstrated that even the most entrenched conflicts...could yield to patient...negotiation', what is the grammatical function of 'imperfect as it was'?",
      ["An adverbial clause of concession", "A noun clause functioning as the object", "An adjectival clause modifying 'negotiation'", "A prepositional phrase of place"],
      "An adverbial clause of concession",
      "This clause concedes a limitation of the policy before the main point is made, functioning as an adverbial clause of concession."),
]);

const _text13 =
    "The old woman who sells roasted corn beneath the flame tree at the junction has become, without ever intending "
    "it, an unofficial historian of the neighbourhood. Ask her about the year the floods reached the mosque steps, "
    "or which family first owned the plot where the new supermarket now stands, and she will recount the details "
    "with the precision of someone reading from a ledger, though she has never learned to read at all. Her memory, "
    "honed by decades of listening to the gossip and grievances exchanged over her charcoal brazier, has become a "
    "resource that no municipal archive can rival. Urban planners, oddly enough, have begun to seek her out when "
    "disputes arise over land boundaries, since her recollections of who built what fence, and when, often settle "
    "arguments that official documents, lost or falsified over the years, cannot. She finds this newfound relevance "
    "amusing, remarking with a wry smile that after seventy years of being overlooked, it is strange to suddenly "
    "matter to men in suits who once would not have glanced twice at a corn seller.";

final _passage13 = _passage(_text13, const [
  _PassageQ("According to the passage, what does the old woman sell?",
      ["Roasted corn", "Fried fish", "Fresh vegetables", "Bread and pastries"], "Roasted corn", "The passage states she sells roasted corn beneath the flame tree at the junction."),
  _PassageQ("How has the old woman acquired her extensive knowledge of the neighbourhood, according to the passage?",
      ["By listening to gossip and grievances exchanged at her stall over decades", "By reading official government documents", "By attending community meetings for many years", "By working for the local council"],
      "By listening to gossip and grievances exchanged at her stall over decades",
      "The passage states her memory was honed by decades of listening to gossip and grievances exchanged over her charcoal brazier."),
  _PassageQ("What can be inferred about the reliability of official land documents, based on the passage?",
      ["They are sometimes lost or falsified, making them unreliable", "They are always completely accurate", "They do not exist at all", "They are more reliable than personal memory"],
      "They are sometimes lost or falsified, making them unreliable",
      "The passage states official documents are 'lost or falsified over the years', unlike her recollections."),
  _PassageQ("Why do urban planners seek out the old woman, according to the passage?",
      ["Her recollections help settle disputes over land boundaries", "She provides free food during meetings", "She is a licensed surveyor", "She owns significant property in the area"],
      "Her recollections help settle disputes over land boundaries",
      "The passage states planners seek her out because her recollections of who built what fence often settle arguments official documents cannot."),
  _PassageQ("In the context of the passage, the word 'ledger' is nearest in meaning to:",
      ["a book of formal written records", "a cooking pot", "a musical instrument", "a type of tree"], "a book of formal written records",
      "A 'ledger' is a book used for keeping detailed formal records, here used to describe her precise memory despite being unable to read."),
  _PassageQ("In the context of the passage, the phrase 'newfound relevance' is nearest in meaning to:",
      ["recently gained importance", "old, forgotten status", "financial wealth", "physical strength"], "recently gained importance",
      "'Newfound relevance' refers to importance or significance that has only recently been recognised, contrasting with her past being overlooked."),
  _PassageQ("What figure of speech is used in the phrase 'with the precision of someone reading from a ledger'?",
      ["Simile", "Metaphor", "Onomatopoeia", "Personification"], "Simile",
      "This is a simile, using 'the precision of' to compare her recall to someone reading precise, recorded facts, marked by the comparative structure typical of similes."),
  _PassageQ("Which of the following best captures the main idea of the passage?",
      ["An ordinary woman's lived memory has become an unexpectedly valuable community resource", "The old woman is a trained historian by profession", "Official records are always more trustworthy than personal memory", "The woman has stopped selling corn to become a full-time consultant"],
      "An ordinary woman's lived memory has become an unexpectedly valuable community resource",
      "The passage shows how her informal, lived knowledge has become valuable enough for planners to consult her over official records."),
  _PassageQ("In the sentence 'Ask her about the year the floods reached the mosque steps...and she will recount the details with the precision of someone reading from a ledger, though she has never learned to read at all', what is the grammatical function of 'though she has never learned to read at all'?",
      ["An adverbial clause of concession", "A noun clause functioning as the subject", "An adjectival clause modifying 'ledger'", "A prepositional phrase of time"],
      "An adverbial clause of concession",
      "This clause concedes a surprising fact (she cannot read) that contrasts with her precise recall, functioning as an adverbial clause of concession."),
  _PassageQ("In the sentence 'She finds this newfound relevance amusing, remarking with a wry smile that after seventy years of being overlooked, it is strange to suddenly matter to men in suits...', what is the grammatical function of 'that after seventy years of being overlooked, it is strange to suddenly matter to men in suits'?",
      ["A noun clause functioning as the object of 'remarking'", "An adjectival clause modifying 'smile'", "An adverbial clause of place", "The subject of the main sentence"],
      "A noun clause functioning as the object of 'remarking'",
      "This clause expresses what she remarks, functioning as the direct object of the participle 'remarking'."),
]);

const _text14 =
    "Nobody in the small coastal town expected the annual canoe regatta to attract international attention, least "
    "of all the fishermen who had organised it for generations as little more than a friendly test of strength "
    "and skill after the fishing season ended. Yet when a documentary crew, drawn initially by unrelated stories "
    "of coastal erosion, happened to film the colourful, chaotic spectacle of forty hand-carved canoes racing "
    "through the surf, the footage went unexpectedly viral online. Within months, a tourism board that had never "
    "previously acknowledged the town's existence was funding improved facilities, and hotels that once struggled "
    "to fill a handful of rooms found themselves fully booked during regatta season. The fishermen, initially "
    "bemused by the sudden influx of camera-wielding visitors, have since organised themselves into an association "
    "to negotiate fairer terms with tour operators, determined that outsiders profiting from their tradition would "
    "not do so at the expense of the community that had sustained it for so long.";

final _passage14 = _passage(_text14, const [
  _PassageQ("According to the passage, why was the canoe regatta originally organised?",
      ["As a friendly test of strength and skill after the fishing season", "To attract international tourists", "As a religious ceremony", "To raise funds for the town council"],
      "As a friendly test of strength and skill after the fishing season",
      "The passage states fishermen organised it for generations as a friendly test of strength and skill after the fishing season ended."),
  _PassageQ("How did the regatta gain international attention, according to the passage?",
      ["Footage filmed by a documentary crew went viral online", "The government launched an advertising campaign", "Fishermen travelled abroad to promote it", "A famous celebrity visited the town"],
      "Footage filmed by a documentary crew went viral online",
      "The passage states a documentary crew filmed the spectacle and the footage went unexpectedly viral online."),
  _PassageQ("What can be inferred about the town's tourism infrastructure before the regatta became famous?",
      ["It was underdeveloped, with hotels struggling to fill rooms", "It was already highly developed and popular", "It did not exist at all", "It was funded entirely by the fishermen"],
      "It was underdeveloped, with hotels struggling to fill rooms",
      "The passage states hotels 'once struggled to fill a handful of rooms', implying limited tourism before the viral attention."),
  _PassageQ("Why did the fishermen form an association, according to the passage?",
      ["To negotiate fairer terms with tour operators", "To ban all tourists from the regatta", "To relocate the regatta to another town", "To stop fishing entirely"],
      "To negotiate fairer terms with tour operators",
      "The passage states they organised an association to negotiate fairer terms, determined outsiders would not profit at the community's expense."),
  _PassageQ("In the context of the passage, the word 'bemused' is nearest in meaning to:",
      ["confused or puzzled", "extremely angry", "completely indifferent", "overjoyed"], "confused or puzzled",
      "'Bemused' describes a state of mild confusion or puzzlement, here referring to the fishermen's reaction to sudden attention."),
  _PassageQ("In the context of the passage, the word 'influx' is nearest in meaning to:",
      ["a large and sudden arrival", "a gradual decline", "a permanent departure", "a small, insignificant number"], "a large and sudden arrival",
      "'Influx' refers to a large number of people or things arriving at once, here referring to visitors."),
  _PassageQ("What figure of speech is used in the phrase 'the colourful, chaotic spectacle of forty hand-carved canoes racing through the surf'?",
      ["Imagery appealing to the visual sense", "Onomatopoeia", "Simile", "Alliteration"], "Imagery appealing to the visual sense",
      "This descriptive phrase creates a vivid visual picture of the event for the reader."),
  _PassageQ("Which of the following best captures the main idea of the passage?",
      ["An unexpected viral moment transformed a local tradition into an economic opportunity that the community sought to control", "The regatta was always intended to attract global tourism", "The fishermen rejected all forms of tourism after gaining fame", "The documentary crew took full ownership of the regatta's profits"],
      "An unexpected viral moment transformed a local tradition into an economic opportunity that the community sought to control",
      "The passage traces how unplanned viral fame led to economic change, and the fishermen's effort to protect their interests."),
  _PassageQ("In the sentence 'Yet when a documentary crew, drawn initially by unrelated stories of coastal erosion, happened to film the colourful, chaotic spectacle...the footage went unexpectedly viral online', what is the grammatical function of 'drawn initially by unrelated stories of coastal erosion'?",
      ["A participial phrase modifying 'a documentary crew'", "A noun clause functioning as the subject", "An adverbial clause of place", "The main verb phrase"],
      "A participial phrase modifying 'a documentary crew'",
      "This non-finite participial phrase explains why the crew was originally there, modifying 'a documentary crew'."),
  _PassageQ("In the sentence 'The fishermen...have since organised themselves into an association to negotiate fairer terms with tour operators, determined that outsiders profiting from their tradition would not do so at the expense of the community...', what is the grammatical function of 'to negotiate fairer terms with tour operators'?",
      ["An infinitive phrase functioning as an adverbial of purpose", "A noun clause functioning as the subject", "An adjectival clause modifying 'association'", "A prepositional phrase of place"],
      "An infinitive phrase functioning as an adverbial of purpose",
      "This infinitive phrase explains the purpose of organising the association, functioning as an adverbial of purpose."),
]);

const _text15 =
    "The controversy surrounding the proposed dam project pits two seemingly incompatible visions of progress "
    "against one another. Supporters, chiefly government engineers and energy companies, point to the dam's "
    "potential to triple the region's electricity generation, finally ending the rolling blackouts that have "
    "throttled small businesses for a generation. Opponents, drawn largely from the fishing communities that would "
    "be displaced by the reservoir, argue that the promised electricity has, in similar past projects elsewhere, "
    "rarely reached the very villages sacrificed for its generation, flowing instead to distant cities and "
    "industrial estates. Independent environmental assessors have added a further complication, warning that the "
    "dam could disrupt fish migration patterns that thousands of downstream families depend upon for their "
    "livelihoods, a concern the project's engineers dismiss as manageable through unproven mitigation technology. "
    "As construction machinery sits idle awaiting a final court ruling, the dam has become a proxy battle for a "
    "larger, unresolved national question: who bears the cost of progress, and who reaps its rewards?";

final _passage15 = _passage(_text15, const [
  _PassageQ("According to the passage, what benefit do supporters of the dam project claim it will bring?",
      ["Tripling the region's electricity generation", "Immediate elimination of poverty", "Free housing for all residents", "A new international airport"],
      "Tripling the region's electricity generation", "The passage states supporters point to the dam's potential to triple the region's electricity generation."),
  _PassageQ("What do opponents of the dam argue, based on the passage?",
      ["Electricity from similar projects rarely reaches the sacrificed villages", "The dam will have no effect on electricity supply", "The dam will benefit fishing communities directly", "The project has already been approved and completed"],
      "Electricity from similar projects rarely reaches the sacrificed villages",
      "The passage states opponents argue promised electricity 'rarely reached the very villages sacrificed for its generation'."),
  _PassageQ("What can be inferred about the relationship between the engineers and environmental assessors mentioned in the passage?",
      ["They disagree about the seriousness of the dam's environmental risks", "They fully agree on every aspect of the project", "Neither group has expressed any opinion on the dam", "The engineers have abandoned the project entirely"],
      "They disagree about the seriousness of the dam's environmental risks",
      "The passage states engineers dismiss the assessors' concern as manageable, implying disagreement over risk severity."),
  _PassageQ("What is currently preventing construction from proceeding, according to the passage?",
      ["Construction machinery is awaiting a final court ruling", "The government has cancelled the project entirely", "All funding has been withdrawn", "The fishing communities have agreed to relocate"],
      "Construction machinery is awaiting a final court ruling",
      "The passage states construction machinery sits idle awaiting a final court ruling."),
  _PassageQ("In the context of the passage, the word 'throttled' is nearest in meaning to:",
      ["severely restricted or choked", "greatly boosted", "completely ignored", "financially rewarded"], "severely restricted or choked",
      "'Throttled' means to restrict or constrain severely, here referring to blackouts limiting small businesses."),
  _PassageQ("In the context of the passage, the word 'proxy' is nearest in meaning to:",
      ["a substitute representing a larger issue", "an exact duplicate", "a legal document", "a financial reward"], "a substitute representing a larger issue",
      "'Proxy' here means something that stands in for or represents a larger, more significant issue."),
  _PassageQ("What figure of speech is used in the phrase 'the rolling blackouts that have throttled small businesses'?",
      ["Personification of blackouts as having the power to choke", "Simile", "Onomatopoeia", "Hyperbole"], "Personification of blackouts as having the power to choke",
      "Blackouts are given the human-like ability to 'throttle', a form of personification emphasising their damaging effect."),
  _PassageQ("Which of the following best captures the main idea of the passage?",
      ["The dam project highlights a broader conflict over who benefits from and who pays for development", "The dam project has been universally supported by all parties", "The environmental risks of the dam have been fully resolved", "The fishing communities have already been compensated fairly"],
      "The dam project highlights a broader conflict over who benefits from and who pays for development",
      "The passage frames the dam dispute as representative of a larger question about the distribution of the costs and benefits of progress."),
  _PassageQ("In the sentence 'Opponents, drawn largely from the fishing communities that would be displaced by the reservoir, argue that the promised electricity...rarely reached the very villages sacrificed for its generation...', what is the grammatical function of 'that would be displaced by the reservoir'?",
      ["An adjectival clause modifying 'fishing communities'", "A noun clause functioning as the subject", "An adverbial clause of purpose", "A prepositional phrase of time"],
      "An adjectival clause modifying 'fishing communities'",
      "This relative clause describes the fishing communities, functioning as an adjectival clause."),
  _PassageQ("In the sentence 'As construction machinery sits idle awaiting a final court ruling, the dam has become a proxy battle for a larger, unresolved national question...', what is the grammatical function of 'As construction machinery sits idle awaiting a final court ruling'?",
      ["An adverbial clause of time", "A noun clause functioning as the object", "An adjectival clause modifying 'machinery'", "The main verb phrase of the sentence"],
      "An adverbial clause of time", "This clause establishes the time frame during which the main clause's situation exists, functioning adverbially."),
]);

const _text16 =
    "There is a particular kind of quiet heroism in the work of the community health volunteers who trek for hours "
    "along bush paths to deliver vaccines to villages too remote for any tarred road to reach. Mama Ijeoma, sixty-one "
    "years old and a volunteer for over two decades, carries a cool box strapped to her back containing vaccines "
    "that must remain within a strict temperature range or spoil entirely, rendering an already arduous journey "
    "worthless. She has waded through swollen streams during the rainy season and walked for six hours under a "
    "punishing sun during the dry months, motivated by nothing more than a modest stipend and an unshakeable "
    "conviction that no child's survival should depend on the accident of where they happen to be born. Public "
    "health statistics, dry and impersonal as they often are, rarely capture the individual toll of such journeys, "
    "yet it is precisely volunteers like Mama Ijeoma who have quietly driven down child mortality rates in areas "
    "that formal healthcare infrastructure has been slow, or unable, to reach.";

final _passage16 = _passage(_text16, const [
  _PassageQ("According to the passage, what does Mama Ijeoma carry on her journeys?",
      ["A cool box containing vaccines", "Farming tools", "Educational textbooks", "Construction materials"], "A cool box containing vaccines",
      "The passage states she carries a cool box strapped to her back containing vaccines."),
  _PassageQ("How long has Mama Ijeoma been volunteering, according to the passage?",
      ["Over two decades", "Five years", "One year", "Ten years"], "Over two decades", "The passage states she has been a volunteer for over two decades."),
  _PassageQ("What can be inferred about the challenges of her work, based on the passage?",
      ["The journeys are physically demanding and require careful handling of sensitive materials", "The work is easy and requires no special effort", "She travels only by car on paved roads", "The vaccines she carries never require special storage"],
      "The journeys are physically demanding and require careful handling of sensitive materials",
      "The passage describes wading through swollen streams, walking for hours in punishing sun, and the vaccines needing strict temperature control."),
  _PassageQ("What motivates Mama Ijeoma, according to the passage?",
      ["A modest stipend and a conviction that all children deserve survival regardless of birthplace", "A desire for fame and recognition", "A large financial reward", "Government pressure to volunteer"],
      "A modest stipend and a conviction that all children deserve survival regardless of birthplace",
      "The passage states she is motivated by a modest stipend and an unshakeable conviction about children's survival."),
  _PassageQ("In the context of the passage, the word 'arduous' is nearest in meaning to:",
      ["extremely difficult and tiring", "very easy and relaxing", "quick and effortless", "financially rewarding"], "extremely difficult and tiring",
      "'Arduous' describes a task that requires great effort and is difficult to accomplish."),
  _PassageQ("In the context of the passage, the word 'unshakeable' is nearest in meaning to:",
      ["firm and unable to be changed", "weak and easily influenced", "temporary and brief", "confused and uncertain"], "firm and unable to be changed",
      "'Unshakeable' describes something, like a conviction, that is extremely firm and cannot be altered or weakened."),
  _PassageQ("What figure of speech is used in the phrase 'the accident of where they happen to be born'?",
      ["Metaphor, treating birthplace as a matter of chance like an accident", "Simile", "Onomatopoeia", "Alliteration"], "Metaphor, treating birthplace as a matter of chance like an accident",
      "Calling birthplace an 'accident' is a metaphor emphasising the randomness of circumstance, without literal collision involved."),
  _PassageQ("Which of the following best captures the main idea of the passage?",
      ["Dedicated volunteers play a crucial, often unrecognised role in improving child health in remote areas", "Public health statistics fully capture the value of volunteer work", "Formal healthcare infrastructure has fully replaced the need for volunteers", "Mama Ijeoma works primarily for financial gain"],
      "Dedicated volunteers play a crucial, often unrecognised role in improving child health in remote areas",
      "The passage highlights how volunteers like Mama Ijeoma have driven down child mortality where formal healthcare cannot easily reach."),
  _PassageQ("In the sentence 'Mama Ijeoma, sixty-one years old and a volunteer for over two decades, carries a cool box strapped to her back containing vaccines that must remain within a strict temperature range or spoil entirely...', what is the grammatical function of 'that must remain within a strict temperature range or spoil entirely'?",
      ["An adjectival clause modifying 'vaccines'", "A noun clause functioning as the subject", "An adverbial clause of time", "A prepositional phrase"],
      "An adjectival clause modifying 'vaccines'",
      "This relative clause describes the vaccines' requirement, functioning as an adjectival clause."),
  _PassageQ("In the sentence 'Public health statistics, dry and impersonal as they often are, rarely capture the individual toll of such journeys, yet it is precisely volunteers like Mama Ijeoma who have quietly driven down child mortality rates...', what is the grammatical function of 'dry and impersonal as they often are'?",
      ["An adverbial clause of concession", "A noun clause functioning as the object", "An adjectival clause modifying 'journeys'", "A prepositional phrase of place"],
      "An adverbial clause of concession",
      "This clause concedes a characteristic of statistics before making the main point, functioning as an adverbial clause of concession."),
]);

const _text17 =
    "The renovation of the century-old central market was meant to be a straightforward exercise in modernisation: "
    "new roofing to replace the leaking asbestos sheets, proper drainage to end the seasonal flooding that ruined "
    "perishable goods, and designated parking to ease the chaotic congestion of delivery trucks. Instead, it became "
    "a protracted battle over identity and memory. Traders whose grandparents had occupied the same stalls for "
    "three generations resisted the council's plan to reorganise vendors by category rather than by the informal, "
    "decades-old arrangements everyone had simply inherited. To an outside consultant, the proposed changes seemed "
    "purely logistical, a sensible way to help customers navigate the market more efficiently. To the traders, "
    "however, their stall's specific location was inseparable from their family's history and reputation, built "
    "painstakingly over decades of loyal customers finding them in exactly the same spot. The eventual compromise "
    "preserved most traditional stall locations while introducing the promised infrastructure improvements, proving "
    "that successful modernisation sometimes requires bending to sentiment rather than insisting on pure efficiency.";

final _passage17 = _passage(_text17, const [
  _PassageQ("According to the passage, what infrastructure improvements were originally planned for the market?",
      ["New roofing, drainage, and designated parking", "A new market location entirely", "Free electricity for all vendors", "A ban on all deliveries"],
      "New roofing, drainage, and designated parking", "The passage states plans included new roofing, proper drainage, and designated parking."),
  _PassageQ("Why did traders resist the council's reorganisation plan, according to the passage?",
      ["Their stall locations were tied to their family's history and reputation", "They wanted the market permanently closed", "They opposed all forms of modernisation", "They demanded higher rent for their stalls"],
      "Their stall locations were tied to their family's history and reputation",
      "The passage states their stall's location was inseparable from their family's history and reputation built over decades."),
  _PassageQ("What can be inferred about the outside consultant's understanding of the situation?",
      ["The consultant initially failed to appreciate the emotional and historical significance of stall locations", "The consultant fully understood the traders' concerns from the start", "The consultant had no role in the renovation project", "The consultant sided completely with the traders"],
      "The consultant initially failed to appreciate the emotional and historical significance of stall locations",
      "The passage states the changes seemed 'purely logistical' to the consultant, contrasting with the traders' deeper attachment."),
  _PassageQ("What was the eventual outcome of the market renovation dispute, according to the passage?",
      ["A compromise preserved most stall locations while adding infrastructure improvements", "The market was demolished entirely", "The traders were forced to relocate permanently", "All infrastructure plans were cancelled"],
      "A compromise preserved most stall locations while adding infrastructure improvements",
      "The passage states the compromise preserved most traditional stall locations while introducing the promised infrastructure improvements."),
  _PassageQ("In the context of the passage, the word 'protracted' is nearest in meaning to:",
      ["lasting longer than expected", "brief and quickly resolved", "entirely peaceful", "financially costly only"], "lasting longer than expected",
      "'Protracted' describes something that continues for a long time, longer than expected or desired."),
  _PassageQ("In the context of the passage, the word 'painstakingly' is nearest in meaning to:",
      ["with great care and effort", "carelessly and quickly", "accidentally", "with government assistance"], "with great care and effort",
      "'Painstakingly' means done with great care, effort, and attention to detail."),
  _PassageQ("What figure of speech, if any, is present in the phrase 'a protracted battle over identity and memory'?",
      ["Metaphor, comparing the dispute to a literal battle", "Simile", "Onomatopoeia", "Alliteration"], "Metaphor, comparing the dispute to a literal battle",
      "Describing the dispute as a 'battle' is a metaphor, since no literal physical fighting occurred."),
  _PassageQ("Which of the following best captures the main idea of the passage?",
      ["Successful modernisation projects must sometimes balance efficiency with respect for tradition and sentiment", "Modernisation should always prioritise efficiency over sentiment", "The market renovation was cancelled due to trader opposition", "The council ignored trader concerns entirely"],
      "Successful modernisation projects must sometimes balance efficiency with respect for tradition and sentiment",
      "The passage concludes that the compromise proved modernisation sometimes requires bending to sentiment rather than pure efficiency."),
  _PassageQ("In the sentence 'Traders whose grandparents had occupied the same stalls for three generations resisted the council's plan to reorganise vendors by category...', what is the grammatical function of 'whose grandparents had occupied the same stalls for three generations'?",
      ["An adjectival clause modifying 'Traders'", "A noun clause functioning as the object", "An adverbial clause of time", "A prepositional phrase"],
      "An adjectival clause modifying 'Traders'",
      "This relative clause describes the traders' family history, functioning as an adjectival clause."),
  _PassageQ("In the sentence 'The eventual compromise preserved most traditional stall locations while introducing the promised infrastructure improvements, proving that successful modernisation sometimes requires bending to sentiment...', what is the grammatical function of 'that successful modernisation sometimes requires bending to sentiment rather than insisting on pure efficiency'?",
      ["A noun clause functioning as the object of 'proving'", "An adjectival clause modifying 'compromise'", "An adverbial clause of place", "The subject of the sentence"],
      "A noun clause functioning as the object of 'proving'",
      "This clause states what is proven, functioning as the direct object of the participle 'proving'."),
]);

const _text18 =
    "It is tempting to view the recent surge in youth entrepreneurship purely as an inspiring story of innovation "
    "and grit, but a closer look reveals a more complicated picture. Many of the young people launching small "
    "businesses, from mobile phone repair kiosks to social media marketing agencies, are doing so not out of "
    "burning entrepreneurial passion but because formal employment opportunities have simply failed to materialise "
    "in sufficient numbers for a rapidly growing, increasingly educated population. Necessity, rather than "
    "inspiration, is frequently the true engine of this entrepreneurial boom. This distinction matters for policy: "
    "programmes designed to celebrate and fund visionary innovators may do little for the vast majority of young "
    "entrepreneurs who would happily abandon their small enterprises the moment a stable salaried position became "
    "available. What this cohort needs is not motivational seminars about risk-taking, but practical support, "
    "affordable credit, reliable electricity, and simplified business registration, that allows their necessity-driven "
    "ventures to survive long enough to become something more permanent and, perhaps eventually, genuinely chosen "
    "rather than merely endured.";

final _passage18 = _passage(_text18, const [
  _PassageQ("According to the passage, what is often the true motivation behind youth entrepreneurship?",
      ["Necessity, due to a lack of formal employment opportunities", "Pure entrepreneurial passion and inspiration", "Government incentives and subsidies", "A desire to avoid all forms of work"],
      "Necessity, due to a lack of formal employment opportunities",
      "The passage states necessity, rather than inspiration, is frequently the true engine of the entrepreneurial boom."),
  _PassageQ("What examples of small businesses does the passage mention?",
      ["Mobile phone repair kiosks and social media marketing agencies", "Large manufacturing companies", "International trading firms", "Agricultural export businesses"],
      "Mobile phone repair kiosks and social media marketing agencies",
      "The passage mentions mobile phone repair kiosks and social media marketing agencies as examples."),
  _PassageQ("What can be inferred about many young entrepreneurs' attitude toward salaried employment, based on the passage?",
      ["Many would abandon their businesses for a stable salaried job if available", "They universally reject the idea of formal employment", "They have no interest in financial stability", "They prefer entrepreneurship over any other option"],
      "Many would abandon their businesses for a stable salaried job if available",
      "The passage states many entrepreneurs 'would happily abandon their small enterprises the moment a stable salaried position became available'."),
  _PassageQ("What kind of support does the passage suggest young entrepreneurs actually need?",
      ["Practical support like affordable credit, electricity, and simplified registration", "Motivational seminars about risk-taking", "Foreign investment exclusively", "Free advertising on television"],
      "Practical support like affordable credit, electricity, and simplified registration",
      "The passage states what is needed is practical support: affordable credit, reliable electricity, and simplified business registration."),
  _PassageQ("In the context of the passage, the word 'cohort' is nearest in meaning to:",
      ["a group of people with something in common", "a single individual", "a government agency", "a type of business loan"], "a group of people with something in common",
      "'Cohort' refers to a group of people sharing a common characteristic, here referring to necessity-driven young entrepreneurs."),
  _PassageQ("In the context of the passage, the word 'materialise' is nearest in meaning to:",
      ["to come into existence or become real", "to disappear completely", "to become more expensive", "to be cancelled"], "to come into existence or become real",
      "'Materialise' means for something to become real or actually happen, here referring to employment opportunities failing to appear."),
  _PassageQ("What figure of speech is used in the phrase 'necessity...is frequently the true engine of this entrepreneurial boom'?",
      ["Metaphor, comparing necessity to a mechanical engine", "Simile", "Onomatopoeia", "Hyperbole"], "Metaphor, comparing necessity to a mechanical engine",
      "Describing necessity as an 'engine' is a metaphor, comparing an abstract driving force to a literal machine part."),
  _PassageQ("Which of the following best captures the main idea of the passage?",
      ["Youth entrepreneurship is often driven by economic necessity rather than passion, requiring practical rather than inspirational support", "All young entrepreneurs are motivated purely by passion for innovation", "Government seminars are the most effective way to support young entrepreneurs", "Youth entrepreneurship has completely solved the unemployment problem"],
      "Youth entrepreneurship is often driven by economic necessity rather than passion, requiring practical rather than inspirational support",
      "The passage argues that recognising necessity as the driver should shift policy toward practical support rather than inspirational programmes."),
  _PassageQ("In the sentence 'Many of the young people launching small businesses...are doing so not out of burning entrepreneurial passion but because formal employment opportunities have simply failed to materialise...', what is the grammatical function of 'because formal employment opportunities have simply failed to materialise in sufficient numbers'?",
      ["An adverbial clause of reason", "A noun clause functioning as the subject", "An adjectival clause modifying 'people'", "A prepositional phrase of time"],
      "An adverbial clause of reason", "This clause explains the reason behind young people's actions, functioning as an adverbial clause of reason."),
  _PassageQ("In the sentence 'What this cohort needs is not motivational seminars about risk-taking, but practical support...that allows their necessity-driven ventures to survive long enough to become something more permanent...', what is the grammatical function of 'What this cohort needs'?",
      ["A noun clause functioning as the subject of the sentence", "An adjectival clause modifying 'seminars'", "An adverbial clause of manner", "A prepositional phrase"],
      "A noun clause functioning as the subject of the sentence",
      "'What this cohort needs' functions as the subject of the verb 'is', making it a noun clause."),
]);

const _text19 =
    "Grandfather's old transistor radio, held together at this point more by tape and stubbornness than by any "
    "remaining original casing, occupies a place of honour on the sitting room shelf despite the family owning "
    "three modern smart speakers that could easily replace its function. Ask him why he refuses to discard it, and "
    "he will tell you, with the patience of a man who has explained this many times before, that the radio carried "
    "him through the loneliest years of his life as a young migrant labourer in a foreign city, its crackling "
    "broadcasts of home-language news and music the only thread connecting him to a country he feared he might "
    "never see again. The smart speakers, for all their crisp digital clarity, cannot replicate the specific static "
    "hiss that, to him, sounds unmistakably like comfort. His grandchildren tease him gently about his sentimental "
    "attachment to what they consider obsolete junk, but even they have noticed that he seems to sit a little "
    "straighter, a little more present, whenever the old radio's dial catches a distant, half-audible signal on a "
    "quiet evening.";

final _passage19 = _passage(_text19, const [
  _PassageQ("According to the passage, what modern devices does the family own that could replace the old radio?",
      ["Three modern smart speakers", "A television set", "A new record player", "A modern telephone"], "Three modern smart speakers",
      "The passage states the family owns three modern smart speakers that could easily replace the radio's function."),
  _PassageQ("What role did the radio play during Grandfather's time as a migrant labourer, according to the passage?",
      ["It connected him to his home country through broadcasts of home-language news and music", "It provided him with financial income", "It helped him learn a new language", "It served as his only source of light"],
      "It connected him to his home country through broadcasts of home-language news and music",
      "The passage states its broadcasts were the only thread connecting him to a country he feared he might never see again."),
  _PassageQ("What can be inferred about Grandfather's emotional attachment to the radio?",
      ["It is tied to deep personal memories rather than the object's function", "He keeps it purely for its superior sound quality", "He is unaware of why he keeps it", "He plans to sell it soon"],
      "It is tied to deep personal memories rather than the object's function",
      "The passage explains his attachment stems from the comfort and memories associated with it during a lonely period, not its technical function."),
  _PassageQ("How do Grandfather's grandchildren react to his attachment to the radio, according to the passage?",
      ["They tease him gently but have noticed his emotional response to it", "They fully share his emotional attachment to the radio", "They insist he throw it away immediately", "They are completely indifferent to the radio"],
      "They tease him gently but have noticed his emotional response to it",
      "The passage states grandchildren tease him gently but have noticed he seems more present when using the radio."),
  _PassageQ("In the context of the passage, the word 'unmistakably' is nearest in meaning to:",
      ["clearly and without doubt", "vaguely and uncertainly", "rarely and occasionally", "loudly and harshly"], "clearly and without doubt",
      "'Unmistakably' means in a way that is completely clear and cannot be confused with anything else."),
  _PassageQ("In the context of the passage, the word 'obsolete' is nearest in meaning to:",
      ["no longer useful or up to date", "extremely valuable", "recently manufactured", "highly advanced"], "no longer useful or up to date",
      "'Obsolete' describes something outdated and no longer in common use, as the grandchildren view the old radio."),
  _PassageQ("What figure of speech is used in the phrase 'its crackling broadcasts...the only thread connecting him to a country he feared he might never see again'?",
      ["Metaphor, comparing the connection to a physical thread", "Simile", "Onomatopoeia", "Hyperbole"], "Metaphor, comparing the connection to a physical thread",
      "Describing the connection as a 'thread' is a metaphor, representing a fragile but vital link without literal string involved."),
  _PassageQ("Which of the following best captures the main idea of the passage?",
      ["An old object's value can lie in emotional memory rather than practical function", "Modern technology is always superior to old devices", "Grandfather refuses to accept any new technology in his home", "The grandchildren fully understand and share his attachment to the radio"],
      "An old object's value can lie in emotional memory rather than practical function",
      "The passage illustrates how Grandfather's attachment to the radio stems from emotional significance rather than its technical usefulness."),
  _PassageQ("In the sentence 'Grandfather's old transistor radio, held together at this point more by tape and stubbornness than by any remaining original casing, occupies a place of honour...', what is the grammatical function of 'held together at this point more by tape and stubbornness than by any remaining original casing'?",
      ["A participial phrase modifying 'Grandfather's old transistor radio'", "A noun clause functioning as the object", "An adverbial clause of condition", "The main verb of the sentence"],
      "A participial phrase modifying 'Grandfather's old transistor radio'",
      "This non-finite participial phrase describes the radio's current physical state, modifying the subject noun phrase."),
  _PassageQ("In the sentence 'His grandchildren tease him gently about his sentimental attachment to what they consider obsolete junk, but even they have noticed that he seems to sit a little straighter...', what is the grammatical function of 'that he seems to sit a little straighter, a little more present, whenever the old radio's dial catches a distant, half-audible signal'?",
      ["A noun clause functioning as the object of 'noticed'", "An adjectival clause modifying 'grandchildren'", "An adverbial clause of place", "A prepositional phrase"],
      "A noun clause functioning as the object of 'noticed'",
      "This clause states what the grandchildren have noticed, functioning as the direct object of the verb 'noticed'."),
]);

const _text20 =
    "The apprenticeship system practised among the Igbo trading community, known as Igba Boi, has quietly produced "
    "more small business owners than any single government entrepreneurship programme, though it rarely receives "
    "comparable academic or media attention. Under this arrangement, a young man works for an established trader, "
    "typically for five to seven years, receiving accommodation, feeding, and practical business training in "
    "exchange for his labour, but no direct salary. At the conclusion of this period, provided his service has "
    "been satisfactory, his master provides him with capital, sometimes substantial, to establish his own "
    "independent business, often in the same trade. Critics point out the system's vulnerability to exploitation, "
    "noting cases where masters extend the apprenticeship indefinitely or dismiss apprentices shortly before "
    "settlement to avoid payment. Defenders counter that such abuses, while real, represent a minority of cases, "
    "and that the system's overall track record of transforming penniless young men into self-sufficient business "
    "owners, without requiring any government subsidy or formal collateral, remains remarkable by any measure of "
    "economic development.";

final _passage20 = _passage(_text20, const [
  _PassageQ("According to the passage, what does the Igba Boi apprenticeship system typically involve?",
      ["A young man working for an established trader for five to seven years", "Government-funded business training for one year", "University education followed by an internship", "A short trial period of a few weeks"],
      "A young man working for an established trader for five to seven years",
      "The passage states a young man works for an established trader, typically for five to seven years."),
  _PassageQ("What does the apprentice receive in exchange for his labour, according to the passage?",
      ["Accommodation, feeding, and practical business training", "A monthly salary only", "University tuition fees", "Free housing after retirement"],
      "Accommodation, feeding, and practical business training",
      "The passage states the apprentice receives accommodation, feeding, and practical business training in exchange for labour."),
  _PassageQ("What happens at the end of a satisfactory apprenticeship, according to the passage?",
      ["The master provides capital to help establish an independent business", "The apprentice is required to continue working without pay", "The apprentice must repay the master for training received", "The government provides a loan instead of the master"],
      "The master provides capital to help establish an independent business",
      "The passage states the master provides capital, sometimes substantial, to establish his own independent business."),
  _PassageQ("What criticism of the system do critics raise, according to the passage?",
      ["Some masters extend apprenticeships or dismiss apprentices to avoid payment", "The system requires excessive government funding", "The system has never produced any successful business owners", "The system is only available to wealthy families"],
      "Some masters extend apprenticeships or dismiss apprentices to avoid payment",
      "The passage states critics note cases where masters extend the apprenticeship indefinitely or dismiss apprentices to avoid payment."),
  _PassageQ("In the context of the passage, the word 'penniless' is nearest in meaning to:",
      ["having no money at all", "extremely wealthy", "moderately well-off", "financially cautious"], "having no money at all",
      "'Penniless' describes someone who has no money whatsoever."),
  _PassageQ("In the context of the passage, the word 'collateral' is nearest in meaning to:",
      ["security or assets pledged for a loan", "a business partner", "a government subsidy", "a formal contract"], "security or assets pledged for a loan",
      "'Collateral' refers to an asset that a borrower offers as security to a lender in case of default."),
  _PassageQ("What figure of speech, if any, is present in the phrase 'transforming penniless young men into self-sufficient business owners'?",
      ["Imagery suggesting a dramatic change of state", "Onomatopoeia", "Simile", "Alliteration"], "Imagery suggesting a dramatic change of state",
      "This phrase paints a vivid picture of transformation from poverty to self-sufficiency, though without a direct comparative device like a simile."),
  _PassageQ("Which of the following best captures the main idea of the passage?",
      ["The Igba Boi apprenticeship system has a remarkable, if imperfect, record of creating successful entrepreneurs without government support", "The Igba Boi system is entirely free of any flaws or abuses", "Government entrepreneurship programmes are more effective than Igba Boi", "The Igba Boi system has been officially banned due to exploitation"],
      "The Igba Boi apprenticeship system has a remarkable, if imperfect, record of creating successful entrepreneurs without government support",
      "The passage acknowledges flaws in the system while highlighting its overall success in creating business owners without government subsidy."),
  _PassageQ("In the sentence 'At the conclusion of this period, provided his service has been satisfactory, his master provides him with capital...to establish his own independent business...', what is the grammatical function of 'provided his service has been satisfactory'?",
      ["An adverbial clause of condition", "A noun clause functioning as the subject", "An adjectival clause modifying 'master'", "A prepositional phrase of time"],
      "An adverbial clause of condition",
      "This clause sets a condition that must be met for the main clause to apply, functioning as an adverbial clause of condition."),
  _PassageQ("In the sentence 'Defenders counter that such abuses, while real, represent a minority of cases, and that the system's overall track record...remains remarkable by any measure of economic development', what is the grammatical function of 'that such abuses, while real, represent a minority of cases'?",
      ["A noun clause functioning as the object of 'counter'", "An adjectival clause modifying 'defenders'", "An adverbial clause of place", "The subject of the sentence"],
      "A noun clause functioning as the object of 'counter'",
      "This clause expresses what the defenders argue, functioning as the direct object of the verb 'counter'."),
]);
