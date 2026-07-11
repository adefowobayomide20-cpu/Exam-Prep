import 'theory_questions.dart';

/// Ready-made WAEC-style Chemistry theory (Paper 2) questions, in the same
/// free-response style as the questions in `theory_questions.dart`. Each
/// entry is a single self-contained task (no multi-part (a)(b)(c) questions)
/// so that it can be graded independently by `gradeTheoryAnswer`.
const List<TheoryQuestion> chemistryTheoryQuestions = [
  TheoryQuestion(
    topic: 'Electronic Configuration',
    question: 'Write the electronic configuration of an element with atomic number 19 and state which '
        'group and period it belongs to, giving reasons for your answer.',
  ),
  TheoryQuestion(
    topic: 'Electronic Configuration',
    question: 'An atom X has the electronic configuration 2,8,7. State the number of valence electrons in '
        'X, the group it belongs to, and whether it is likely to form a cation or an anion.',
  ),
  TheoryQuestion(
    topic: 'Chemical Bonding — Ionic',
    question: 'Using electron-dot (Lewis) diagrams, describe how an ionic bond is formed between sodium '
        'and chlorine atoms to produce sodium chloride.',
  ),
  TheoryQuestion(
    topic: 'Chemical Bonding — Covalent',
    question: 'Explain, with the aid of a diagram, how a covalent bond is formed between two chlorine '
        'atoms to produce a chlorine molecule, Cl2.',
  ),
  TheoryQuestion(
    topic: 'Chemical Bonding — Coordinate',
    question: 'Explain how a coordinate (dative) covalent bond is formed in the ammonium ion, NH4+, '
        'stating which species donates the lone pair of electrons.',
  ),
  TheoryQuestion(
    topic: 'Mole Concept',
    question: 'Calculate the mass of calcium trioxocarbonate(IV), CaCO3, required to produce 5.6 dm3 of '
        'carbon(IV) oxide gas at s.t.p. when reacted with excess dilute hydrochloric acid. [Ca=40, C=12, '
        'O=16, molar volume of gas at s.t.p. = 22.4 dm3]',
  ),
  TheoryQuestion(
    topic: 'Mole Concept',
    question: 'Calculate the number of moles of oxygen atoms present in 9.8 g of tetraoxosulphate(VI) '
        'acid, H2SO4. [H=1, S=32, O=16]',
  ),
  TheoryQuestion(
    topic: 'Empirical and Molecular Formula',
    question: 'A compound contains 40% carbon, 6.7% hydrogen and 53.3% oxygen by mass. If its molar mass '
        'is 180 g/mol, determine its empirical formula and its molecular formula. [C=12, H=1, O=16]',
  ),
  TheoryQuestion(
    topic: 'Gas Laws',
    question: 'A given mass of gas occupies 300 cm3 at 27°C and 760 mmHg pressure. Calculate the volume '
        'the gas would occupy at 127°C and 950 mmHg pressure.',
  ),
  TheoryQuestion(
    topic: 'Gas Laws',
    question: 'State Boyle\'s Law and use it to calculate the new volume when a gas occupying 500 cm3 at a '
        'pressure of 1 atmosphere is compressed to a pressure of 2.5 atmospheres at constant temperature.',
  ),
  TheoryQuestion(
    topic: 'Gas Laws',
    question: 'Calculate the relative molecular mass of a gas if 0.64 g of it occupies 400 cm3 at s.t.p. '
        '[Molar volume of gas at s.t.p. = 22,400 cm3]',
  ),
  TheoryQuestion(
    topic: 'Acids, Bases and Salts',
    question: 'Distinguish between a strong acid and a weak acid, giving one example of each.',
  ),
  TheoryQuestion(
    topic: 'Acids, Bases and Salts',
    question: 'Describe how a pure sample of lead(II) chloride, a insoluble salt, can be prepared in the '
        'laboratory, stating the reagents used and the method of separating the product.',
  ),
  TheoryQuestion(
    topic: 'Acids, Bases and Salts',
    question: 'Calculate the pH of a solution of hydrochloric acid with hydrogen ion concentration of '
        '1 x 10^-3 mol/dm3.',
  ),
  TheoryQuestion(
    topic: 'Acids, Bases and Salts',
    question: 'Describe briefly how you would prepare a pure, dry sample of a soluble salt, potassium '
        'trioxonitrate(V), starting from potassium hydroxide and dilute trioxonitrate(V) acid.',
  ),
  TheoryQuestion(
    topic: 'Energy Changes',
    question: 'Define enthalpy of neutralisation and calculate the heat evolved when 50 cm3 of 1 mol/dm3 '
        'HCl is completely neutralised by 50 cm3 of 1 mol/dm3 NaOH, given that the temperature rose by '
        '6.5°C. [Specific heat capacity of solution = 4.2 J/g/K, density = 1 g/cm3]',
  ),
  TheoryQuestion(
    topic: 'Energy Changes',
    question: 'Sketch and describe an energy profile diagram for an exothermic reaction, labelling the '
        'reactants, products, activation energy and enthalpy change.',
  ),
  TheoryQuestion(
    topic: 'Energy Changes',
    question: 'Distinguish between an exothermic reaction and an endothermic reaction, giving one example '
        'of each commonly encountered in the laboratory.',
  ),
  TheoryQuestion(
    topic: 'Rates of Reaction',
    question: 'State four factors that affect the rate of a chemical reaction and explain briefly how any '
        'one of them increases reaction rate in terms of collision theory.',
  ),
  TheoryQuestion(
    topic: 'Rates of Reaction',
    question: 'Explain, using collision theory, why an increase in temperature increases the rate of a '
        'chemical reaction.',
  ),
  TheoryQuestion(
    topic: 'Chemical Equilibrium',
    question: 'State Le Chatelier\'s principle and use it to predict the effect of increasing pressure on '
        'the position of equilibrium in the reaction: N2(g) + 3H2(g) ⇌ 2NH3(g), ΔH = -92 kJ/mol.',
  ),
  TheoryQuestion(
    topic: 'Chemical Equilibrium',
    question: 'With reference to the Haber process, explain the effect of increasing temperature on the '
        'yield of ammonia in the equilibrium N2(g) + 3H2(g) ⇌ 2NH3(g), ΔH = -92 kJ/mol.',
  ),
  TheoryQuestion(
    topic: 'Electrolysis',
    question: 'Using Faraday\'s law, calculate the mass of copper deposited at the cathode when a current '
        'of 2 amperes is passed through a solution of copper(II) tetraoxosulphate(VI) for 30 minutes. '
        '[Cu=64, 1 Faraday = 96500 C]',
  ),
  TheoryQuestion(
    topic: 'Electrolysis',
    question: 'Describe what happens at the anode and cathode when dilute tetraoxosulphate(VI) acid is '
        'electrolysed using platinum electrodes, giving the equations for the electrode reactions.',
  ),
  TheoryQuestion(
    topic: 'Electrolysis',
    question: 'Calculate the volume of gas liberated at the cathode, measured at s.t.p., when a current of '
        '0.5 A is passed through acidified water for 965 seconds. [1 Faraday = 96500 C, molar volume of '
        'gas at s.t.p. = 22,400 cm3]',
  ),
  TheoryQuestion(
    topic: 'Organic Chemistry — Naming',
    question: 'Draw the structural formula and give the IUPAC name of the organic compound formed when '
        'ethene reacts with steam in the presence of concentrated tetraoxosulphate(VI) acid as catalyst.',
  ),
  TheoryQuestion(
    topic: 'Organic Chemistry — Isomerism',
    question: 'Distinguish between structural isomers, using butane and 2-methylpropane as examples, and '
        'draw their structural formulae.',
  ),
  TheoryQuestion(
    topic: 'Organic Chemistry — Esterification',
    question: 'Write a balanced chemical equation for the esterification reaction between ethanoic acid '
        'and ethanol, naming the ester and the catalyst used.',
  ),
  TheoryQuestion(
    topic: 'Organic Chemistry — Saponification',
    question: 'Describe the process of saponification and write an equation showing the hydrolysis of a '
        'named fat or oil by sodium hydroxide to produce soap.',
  ),
  TheoryQuestion(
    topic: 'Organic Chemistry — Alkanes and Alkenes',
    question: 'Describe a simple laboratory test that can be used to distinguish between an alkane and an '
        'alkene, stating the observation expected with each.',
  ),
  TheoryQuestion(
    topic: 'Organic Chemistry — Alcohols',
    question: 'Write an equation for the fermentation of glucose to produce ethanol and state two '
        'conditions necessary for the reaction to occur.',
  ),
  TheoryQuestion(
    topic: 'Volumetric Analysis',
    question: '25 cm3 of a solution of sodium hydroxide required 22.5 cm3 of 0.1 mol/dm3 hydrochloric acid '
        'for complete neutralisation using methyl orange as indicator. Calculate the concentration of the '
        'sodium hydroxide solution in mol/dm3.',
  ),
  TheoryQuestion(
    topic: 'Volumetric Analysis',
    question: 'In a titration, 20 cm3 of 0.05 mol/dm3 potassium trioxomanganate(VII) solution reacted '
        'completely with 25 cm3 of iron(II) tetraoxosulphate(VI) solution. Calculate the concentration of '
        'the iron(II) solution in mol/dm3, given that the mole ratio of MnO4- to Fe2+ is 1:5.',
  ),
  TheoryQuestion(
    topic: 'Volumetric Analysis',
    question: 'Describe briefly how you would carry out a titration to determine the concentration of a '
        'given trioxonitrate(V) acid solution using a standard solution of sodium carbonate, stating the '
        'indicator you would use and the colour change at the end point.',
  ),
  TheoryQuestion(
    topic: 'Qualitative Analysis — Cations',
    question: 'Describe a chemical test, including the reagent used and the expected observation, that '
        'can be used to identify the presence of Fe3+ ions in a solution.',
  ),
  TheoryQuestion(
    topic: 'Qualitative Analysis — Cations',
    question: 'Describe how you would distinguish between a solution containing Zn2+ ions and one '
        'containing Pb2+ ions using sodium hydroxide solution, stating the observations in each case.',
  ),
  TheoryQuestion(
    topic: 'Qualitative Analysis — Anions',
    question: 'Describe a test that can be used to confirm the presence of the trioxocarbonate(IV) ion, '
        'CO3^2-, in a given salt, stating the reagent, the expected observation and the equation for the '
        'reaction.',
  ),
  TheoryQuestion(
    topic: 'Qualitative Analysis — Anions',
    question: 'Describe how you would test for the presence of sulphate(VI) ions, SO4^2-, in a solution, '
        'stating the reagents used and the expected observation.',
  ),
  TheoryQuestion(
    topic: 'Qualitative Analysis — Gases',
    question: 'Describe a simple test to identify carbon(IV) oxide gas, stating the reagent used and the '
        'expected observation.',
  ),
  TheoryQuestion(
    topic: 'Qualitative Analysis — Gases',
    question: 'Describe how you would test for the presence of ammonia gas, NH3, stating two observations '
        'that would confirm its identity.',
  ),
  TheoryQuestion(
    topic: 'Periodicity',
    question: 'Explain why atomic radius decreases across a period from left to right on the periodic '
        'table, using elements in Period 3 as an example.',
  ),
  TheoryQuestion(
    topic: 'Periodicity',
    question: 'Explain why ionisation energy generally increases across a period but decreases down a '
        'group in the periodic table.',
  ),
  TheoryQuestion(
    topic: 'Oxidation and Reduction',
    question: 'Define oxidation and reduction in terms of electron transfer, and identify the oxidising '
        'agent and reducing agent in the reaction: Zn(s) + Cu2+(aq) → Zn2+(aq) + Cu(s).',
  ),
  TheoryQuestion(
    topic: 'Oxidation and Reduction',
    question: 'Assign oxidation numbers to chromium in K2Cr2O7 and Cr2O3, and state whether chromium is '
        'oxidised or reduced when K2Cr2O7 is converted to Cr2O3.',
  ),
  TheoryQuestion(
    topic: 'Metals and Extraction',
    question: 'Describe briefly, with equations, how iron is extracted from its ore, haematite, in the '
        'blast furnace.',
  ),
  TheoryQuestion(
    topic: 'Metals and Extraction',
    question: 'Explain why aluminium is extracted by electrolysis rather than by chemical reduction with '
        'carbon.',
  ),
  TheoryQuestion(
    topic: 'Water and Hardness',
    question: 'Distinguish between temporary hardness and permanent hardness of water, stating the '
        'compounds responsible for each and one method of removing each type.',
  ),
  TheoryQuestion(
    topic: 'Air and Combustion',
    question: 'State the approximate percentage composition of nitrogen and oxygen in the atmosphere and '
        'describe an experiment to determine the percentage of oxygen in air.',
  ),
  TheoryQuestion(
    topic: 'Environmental Chemistry',
    question: 'Explain what is meant by acid rain, stating two gases responsible for its formation and two '
        'of its harmful effects on the environment.',
  ),
  TheoryQuestion(
    topic: 'Nomenclature and Formulae',
    question: 'Write the formula for iron(III) trioxonitrate(V) and calculate its relative molecular mass. '
        '[Fe=56, N=14, O=16]',
  ),
];
