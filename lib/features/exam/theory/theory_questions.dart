import 'dart:math';

import 'agricultural_science_theory_questions.dart';
import 'chemistry_theory_questions.dart';
import 'physics_theory_questions.dart';

/// A single hand-authored WAEC theory-paper question. Unlike the objective
/// (multiple-choice) banks, there's no `correctIndex` here — grading is
/// still handled by the `gradeTheoryAnswer` Cloud Function, which works out
/// the correct answer itself and compares it against whatever the student
/// submits, then explains in detail only if they got it wrong.
class TheoryQuestion {
  const TheoryQuestion({required this.topic, required this.question});

  final String topic;
  final String question;
}

final _random = Random();

/// Ready-made theory questions, keyed by subject. Subjects not listed here
/// have no ready-made bank yet, and [readyMadeTheoryQuestion] returns null
/// for them — callers should fall back to generating a question on demand
/// via the `generateTheoryQuestion` Cloud Function instead.
final Map<String, List<TheoryQuestion>> _theoryQuestionBanks = {
  'Mathematics': _mathematicsTheoryQuestions,
  'English Language': _englishTheoryQuestions,
  'Chemistry': chemistryTheoryQuestions,
  'Physics': physicsTheoryQuestions,
  'Agricultural Science': agriculturalScienceTheoryQuestions,
};

/// Returns a random ready-made theory question for [subject], or null if no
/// ready-made bank exists for that subject yet.
TheoryQuestion? readyMadeTheoryQuestion(String subject) {
  final bank = _theoryQuestionBanks[subject];
  if (bank == null || bank.isEmpty) return null;
  return bank[_random.nextInt(bank.length)];
}

const _mathematicsTheoryQuestions = [
  TheoryQuestion(
    topic: 'Quadratic Equations',
    question: 'Solve the equation 2x² - 5x - 3 = 0, showing all working. Give your answers correct to '
        'two decimal places where necessary.',
  ),
  TheoryQuestion(
    topic: 'Simultaneous Linear Equations',
    question: 'Solve the pair of simultaneous equations:\n'
        '3x + 2y = 16\n'
        '5x - y = 11\n'
        'showing your method clearly.',
  ),
  TheoryQuestion(
    topic: 'Circle Theorems',
    question: 'In a circle with centre O, a chord PQ subtends an angle of 70° at the centre. Calculate the '
        'angle subtended by the chord PQ at a point R on the major arc, and state the circle theorem you used.',
  ),
  TheoryQuestion(
    topic: 'Trigonometry',
    question: 'A ladder 8m long leans against a vertical wall so that it makes an angle of 62° with the '
        'ground. Calculate, correct to one decimal place, (a) the height the ladder reaches up the wall, '
        'and (b) the distance of the foot of the ladder from the wall.',
  ),
  TheoryQuestion(
    topic: 'Mensuration',
    question: 'A cylindrical tank has a radius of 3.5m and a height of 6m. Calculate (a) the volume of '
        'the tank, and (b) its total surface area. (Take pi = 22/7.)',
  ),
  TheoryQuestion(
    topic: 'Statistics',
    question: 'The scores of 8 students in a test are: 4, 7, 5, 9, 6, 7, 8, 6. Calculate the mean, the '
        'median, and the mode of the scores, showing your working.',
  ),
  TheoryQuestion(
    topic: 'Indices and Logarithms',
    question: 'Solve for x: 2^(x+1) = 32. Then evaluate log₂ 64, showing your steps.',
  ),
  TheoryQuestion(
    topic: 'Variation',
    question: 'y varies directly as the square of x. If y = 18 when x = 3, find (a) the equation '
        'connecting y and x, and (b) the value of y when x = 5.',
  ),
  TheoryQuestion(
    topic: 'Sequences and Series',
    question: 'The first term of an Arithmetic Progression (A.P.) is 5 and the common difference is 3. '
        'Find (a) the 12th term of the A.P., and (b) the sum of the first 12 terms.',
  ),
  TheoryQuestion(
    topic: 'Word Problems (Simple Interest)',
    question: 'A man deposited N50,000 in a bank that pays simple interest at 6% per annum. Calculate '
        '(a) the interest earned after 3 years, and (b) the total amount in the account at the end of the '
        '3 years.',
  ),
];

const _englishTheoryQuestions = [
  TheoryQuestion(
    topic: 'Essay Writing (Narrative)',
    question: 'Write an essay of about 450 words narrating an experience that taught you an important '
        'lesson about honesty.',
  ),
  TheoryQuestion(
    topic: 'Essay Writing (Descriptive)',
    question: 'Write an essay of about 450 words describing a busy market in your town or city, using '
        'vivid sensory details (sights, sounds, and smells) to bring the scene to life.',
  ),
  TheoryQuestion(
    topic: 'Essay Writing (Argumentative)',
    question: 'Write an essay of about 450 words arguing for or against the statement: "Social media does '
        'more harm than good to young people." Support your position with clear reasons and examples.',
  ),
  TheoryQuestion(
    topic: 'Essay Writing (Expository)',
    question: 'Write an essay of about 450 words explaining the steps a student should take to prepare '
        'effectively for a major examination.',
  ),
  TheoryQuestion(
    topic: 'Formal Letter Writing',
    question: 'Write a formal letter to the Principal of your school requesting permission to organise a '
        'career-guidance seminar for final-year students.',
  ),
  TheoryQuestion(
    topic: 'Informal Letter Writing',
    question: 'Write a letter to a friend who lives in another town, describing how you spent your last '
        'school holiday.',
  ),
  TheoryQuestion(
    topic: 'Article Writing',
    question: 'Write an article suitable for publication in your school magazine on the topic: "The '
        'importance of extracurricular activities in secondary school."',
  ),
  TheoryQuestion(
    topic: 'Speech Writing',
    question: 'As the outgoing Head Student of your school, write the speech you would deliver at the '
        'send-forth ceremony, encouraging your fellow graduating students as they prepare to leave school.',
  ),
  TheoryQuestion(
    topic: 'Summary Writing',
    question:
        'Read the passage below and then summarise it in not more than 100 words of continuous prose.\n\n'
        'Passage: The rise of ride-hailing applications has quietly transformed transportation in Nigerian '
        'cities over the past decade. Where commuters once haggled endlessly with bus conductors or waited '
        'indefinitely for danfo buses to fill up, many now summon a car with a few taps on a smartphone '
        'screen. The convenience is undeniable: fixed fares eliminate haggling, GPS tracking reassures '
        'anxious relatives, and cashless payment removes the need to carry loose change. Yet the '
        'revolution has not been without friction. Traditional taxi drivers have staged protests in '
        'several cities, arguing that app-based drivers operate with lower overheads and undercut '
        'established fares unfairly. Regulators, meanwhile, have struggled to keep pace, drafting rules '
        'for an industry that barely existed when most transport legislation was written.',
  ),
  TheoryQuestion(
    topic: 'Summary Writing',
    question:
        'Read the passage below and then summarise it in not more than 100 words of continuous prose.\n\n'
        'Passage: Traffic congestion has become one of the most visible challenges facing Lagos, a city '
        'whose population has grown far faster than its road network. Commuters routinely spend hours '
        'travelling distances that should take minutes, and the resulting stress and lost productivity '
        'carry a real economic cost. In response, the state government has invested in mass transit '
        'options, including a light rail system and an expanded fleet of high-capacity buses, aiming to '
        'reduce the number of private vehicles on the road. Critics argue that these measures, while '
        'welcome, cannot succeed unless they are matched by stricter enforcement of traffic regulations '
        'and continued investment in road infrastructure.',
  ),
];
