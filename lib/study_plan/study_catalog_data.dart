// GENERATED FILE. Do not edit by hand.
// Source: .github/learning/study_plan.json in the workspace hub.
// Regenerate: python3 scripts/gen_study_plan_catalog.py
import 'study_game_data.dart';

/// Every game's Study Plan data. A game is offered in the picker only when `ready`.
const Map<String, StudyGameData> kStudyGameData = <String, StudyGameData>{
  'alpha_kids': StudyGameData(
    ready: true,
    allModesNote: 'Your child works through every alphabet activity.',
    modes: <StudyModeInfo>[
      StudyModeInfo(
        id: 'learn-alphabet',
        title: 'Learn the Alphabet',
        description: 'Practice A to Z with letter sounds.',
      ),
      StudyModeInfo(
        id: 'flashcards',
        title: 'Emoji Flashcards',
        description: 'Flip cards to reveal the word and say it aloud.',
      ),
      StudyModeInfo(
        id: 'missing-letter',
        title: 'Find Missing Letter',
        description: 'Fill in gaps in letter sequences.',
      ),
      StudyModeInfo(
        id: 'vowels',
        title: 'Learn Your Vowels',
        description: 'Learn and quiz vowels.',
      ),
      StudyModeInfo(
        id: 'emoji-letter-match',
        title: 'Emoji Letter Match',
        description: 'Choose emojis that start with a letter.',
      ),
    ],
  ),
  'calendar_kids': StudyGameData(
    ready: true,
    allModesNote: 'Your child practices days, months and seasons.',
    modes: <StudyModeInfo>[
      StudyModeInfo(
        id: 'days',
        title: 'Days of the Week',
        description: 'Learn weekday order and names.',
      ),
      StudyModeInfo(
        id: 'months',
        title: 'Months of the Year',
        description: 'Practice all 12 months in order.',
      ),
      StudyModeInfo(
        id: 'seasons',
        title: 'Seasons',
        description: 'Match each season to its weather and vibe.',
      ),
    ],
  ),
  'emergency_kids': StudyGameData(
    ready: true,
    allModesNote: 'Your child practices every emergency skill.',
    modes: <StudyModeInfo>[
      StudyModeInfo(
        id: 'who-helps',
        title: 'Who Helps You',
        description:
            'Learn who can help in an emergency, such as police, firefighters and doctors.',
      ),
      StudyModeInfo(
        id: 'send-help',
        title: 'Send Help!',
        description: 'Pick the right helper to send for different emergencies.',
      ),
      StudyModeInfo(
        id: 'dial-practice',
        title: 'Dial Practice',
        description: 'Practice dialing the emergency number on a keypad.',
      ),
      StudyModeInfo(
        id: 'safety-info',
        title: 'My Safety Info',
        description:
            'Practice the personal safety information a child should know.',
      ),
    ],
  ),
  'speak_repeat': StudyGameData(
    ready: true,
    allModesNote: 'Your child practices every listen-and-repeat activity.',
    modes: <StudyModeInfo>[
      StudyModeInfo(
        id: 'repeat-words',
        title: 'Repeat Words',
        description:
            'Listen to a word, then say it back. The game keeps track of words mastered.',
      ),
      StudyModeInfo(
        id: 'pronoun-cues',
        title: 'He/She/They',
        description:
            'Practice the pronouns he, she and they with picture cues.',
      ),
    ],
  ),
  'countin_kids': StudyGameData(
    ready: true,
    allModesNote: 'Your child practices every counting activity.',
    modes: <StudyModeInfo>[
      StudyModeInfo(
        id: 'count-by-one',
        title: 'Count the Number',
        description: 'Pick a target and count from 1 step-by-step.',
      ),
      StudyModeInfo(
        id: 'count-down',
        title: 'Count Down',
        description: 'Pick a number and count down to 1.',
      ),
      StudyModeInfo(
        id: 'count-by',
        title: 'Count By',
        description: 'Skip count by 2s, 3s, 4s, 5s, 10s and more.',
      ),
      StudyModeInfo(
        id: 'flashcards',
        title: 'Flashcard Count',
        description: 'Front: emoji groups. Back: number and number word.',
      ),
      StudyModeInfo(
        id: 'missing-number',
        title: 'Find Missing Number',
        description: 'Fill in gaps in counting sequences.',
      ),
      StudyModeInfo(
        id: 'number-match',
        title: 'Match Items to Number',
        description: 'Choose every item that shows the target number.',
      ),
    ],
  ),
  'make_it': StudyGameData(
    ready: true,
    allModesNote: 'Your child works through every recipe activity.',
    modes: <StudyModeInfo>[
      StudyModeInfo(
        id: 'selection',
        title: 'Selection Mode',
        description: 'Pick exactly the required number of correct items.',
      ),
      StudyModeInfo(
        id: 'elimination',
        title: 'Elimination Mode',
        description:
            'Remove every incorrect item and keep only core ingredients.',
      ),
      StudyModeInfo(
        id: 'spelling',
        title: 'Spelling Mode',
        description: 'Spell each ingredient name to complete the recipe.',
      ),
      StudyModeInfo(
        id: 'sequence',
        title: 'Sequence Mode',
        description: 'Arrange the steps in the correct order.',
      ),
    ],
  ),
  'memory_match': StudyGameData(
    ready: true,
    allModesNote:
        'Your child plays every memory mode, in a mixed learning path.',
    modes: <StudyModeInfo>[
      StudyModeInfo(
        id: 'number-match',
        title: 'Number Match',
        description: 'Pair identical numbers on a visible board.',
      ),
      StudyModeInfo(
        id: 'sight-word-match',
        title: 'Sight Word Match',
        description:
            'Match identical sight words, including single-letter words.',
      ),
      StudyModeInfo(
        id: 'memory',
        title: 'Memory',
        description: 'Reveal hidden cards and remember where the pairs are.',
      ),
    ],
  ),
  'mahjong': StudyGameData(
    ready: true,
    allModesNote: 'Your child plays every tile-matching style.',
    modes: <StudyModeInfo>[
      StudyModeInfo(
        id: 'classic',
        title: 'Classic',
        description: 'Match pairs of free tiles to clear the board.',
      ),
      StudyModeInfo(
        id: 'equation',
        title: 'Equation',
        description: 'Select two free tiles and solve the equation.',
      ),
      StudyModeInfo(
        id: 'emojis',
        title: 'Emojis',
        description: 'Match pairs of emoji tiles to clear the board.',
      ),
      StudyModeInfo(
        id: 'emojis-faces',
        title: 'Emojis - Faces',
        description: 'Match pairs of face emoji tiles to clear the board.',
      ),
      StudyModeInfo(
        id: 'alphabet',
        title: 'Alphabet',
        description: 'Match pairs of letter tiles to clear the board.',
      ),
    ],
  ),
  'does_it_solve': StudyGameData(
    ready: true,
    allModesNote: 'Your child works through every math logic activity.',
    modes: <StudyModeInfo>[
      StudyModeInfo(
        id: 'more-or-less',
        title: 'More or Less',
        description: 'Decide whether one number is more or less than another.',
      ),
      StudyModeInfo(
        id: 'more-or-less-advanced',
        title: 'More or Less Advanced',
        description: 'A harder version of More or Less.',
      ),
      StudyModeInfo(
        id: 'equation-builder',
        title: 'Equation Builder',
        description: 'Build a correct equation from the pieces given.',
      ),
      StudyModeInfo(
        id: 'math-solver',
        title: 'Math Solver',
        description: 'Solve the math problem.',
      ),
      StudyModeInfo(
        id: 'equation-match-all',
        title: 'Equation Match All',
        description: 'Find every equation that matches.',
      ),
    ],
  ),
  'math_adventures_kids': StudyGameData(
    ready: true,
    allModesNote: 'Your child practices every math activity.',
    modes: <StudyModeInfo>[
      StudyModeInfo(
        id: 'math',
        title: 'Math',
        description: 'Practice addition, subtraction, and multiplication.',
      ),
      StudyModeInfo(
        id: 'math-steps',
        title: 'Math Steps',
        description: 'Solve longer + or - equations in guided parts.',
      ),
      StudyModeInfo(
        id: 'break-it-down',
        title: 'Break It Down',
        description: 'Rewrite and solve equations in smaller steps.',
      ),
      StudyModeInfo(
        id: 'number-patterns',
        title: 'Number Patterns',
        description: 'Find the missing number in a counting sequence.',
      ),
      StudyModeInfo(
        id: 'linear-pattern',
        title: 'Linear Pattern',
        description: 'Solve increasing or decreasing number ladders.',
      ),
      StudyModeInfo(
        id: 'equation-pairs',
        title: 'Equation Pairs',
        description: 'Solve for x in simple equations.',
      ),
      StudyModeInfo(
        id: 'quantity-match',
        title: 'Find Quantity',
        description: 'Find all emoji groups that match the target number.',
      ),
      StudyModeInfo(
        id: 'number-to-emoji',
        title: 'Connect Number',
        description: 'Drag from each number to the matching emoji group.',
      ),
      StudyModeInfo(
        id: 'word-equation',
        title: 'Word Equation',
        description:
            'Solve short story problems with emoji clues and spoken prompts.',
      ),
    ],
  ),
  'realm_breaker': StudyGameData(
    ready: true,
    allModesNote: 'Your child plays every part of the realm.',
    modes: <StudyModeInfo>[
      StudyModeInfo(
        id: 'brick-breaker',
        title: 'Brick Breaker',
        description: 'Bounce a ball to break bricks and collect power-ups.',
      ),
      StudyModeInfo(
        id: 'realm-quest',
        title: 'Realm Quest',
        description: 'Follow a quest through the realm.',
      ),
      StudyModeInfo(
        id: 'story-books',
        title: 'Story Books',
        description: 'Read picture books.',
      ),
    ],
  ),
  'make_change': StudyGameData(
    ready: true,
    allModesNote: 'Your child practices every money activity.',
    modes: <StudyModeInfo>[
      StudyModeInfo(
        id: 'money',
        title: 'Money',
        description: 'Learn coins and bills and their values.',
      ),
      StudyModeInfo(
        id: 'roll-lab',
        title: 'Roll Lab',
        description: 'Learn the value of coin rolls.',
      ),
      StudyModeInfo(
        id: 'currency-connection',
        title: 'Currency Connection',
        description: 'Match coins and bills to their values.',
      ),
      StudyModeInfo(
        id: 'break-it-down',
        title: 'Break It Down',
        description: 'Break an amount of money into smaller parts.',
      ),
      StudyModeInfo(
        id: 'shop-pay',
        title: 'Shop & Pay',
        description: 'Choose the money to pay for something in a shop.',
      ),
      StudyModeInfo(
        id: 'fewest-bucks',
        title: 'Fewest Bucks',
        description: 'Make an amount using the fewest bills and coins.',
      ),
      StudyModeInfo(
        id: 'money-stories',
        title: 'Money Stories',
        description: 'Solve short money story problems.',
      ),
      StudyModeInfo(
        id: 'take-away',
        title: 'Take Away',
        description: 'Take an amount away, like counting back change.',
      ),
    ],
  ),
  'grammar_adventures_kids': StudyGameData(
    ready: true,
    allModesNote: 'Your child practices every grammar activity.',
    modes: <StudyModeInfo>[
      StudyModeInfo(
        id: 'flashcards',
        title: 'Grammar Flashcards',
        description: 'Flip cards to review each grammar word and its meaning.',
      ),
      StudyModeInfo(
        id: 'parts-of-speech-mix',
        title: 'Parts of Speech Mix',
        description: 'Choose the correct grammar type for each word.',
      ),
      StudyModeInfo(
        id: 'language-helpers',
        title: 'Language Helpers',
        description:
            'Identify pronouns, adverbs, and prepositions from options.',
      ),
      StudyModeInfo(
        id: 'identify-in-sentence',
        title: 'Identify in a Sentence',
        description:
            'Find the target grammar word in mixed-difficulty sentences.',
      ),
      StudyModeInfo(
        id: 'fill-in-the-blank',
        title: 'Fill in the Blank',
        description:
            'Choose the best word to complete mixed-difficulty sentences.',
      ),
      StudyModeInfo(
        id: 'line-connect',
        title: 'Grammar Connection',
        description:
            'Draw a line from each grammar word to a matching example.',
      ),
      StudyModeInfo(
        id: 'global-definitions',
        title: 'Definition Lab',
        description: 'Review every grammar word and its definition.',
      ),
    ],
  ),
  'word_blend_kids': StudyGameData(
    ready: true,
    allModesNote: 'Your child practices every contraction activity.',
    modes: <StudyModeInfo>[
      StudyModeInfo(
        id: 'word-builder',
        title: 'Word Builder',
        description: 'Tap the correct contraction.',
      ),
      StudyModeInfo(
        id: 'match-pair',
        title: 'Match the Pair',
        description: 'Match the shortened and full forms.',
      ),
      StudyModeInfo(
        id: 'story-mode',
        title: 'Story Mode',
        description: 'Tap the contractions in context.',
      ),
      StudyModeInfo(
        id: 'contraction-library',
        title: 'Contraction Library',
        description: 'Browse every contraction.',
      ),
    ],
  ),
  'reading_writing_kids': StudyGameData(
    ready: true,
    allModesNote: 'Your child practices every reading and writing activity.',
    modes: <StudyModeInfo>[
      StudyModeInfo(
        id: 'spelling',
        title: 'Spelling',
        description: 'Type the word that matches the clue.',
      ),
      StudyModeInfo(
        id: 'choose-word',
        title: 'Choose the Word',
        description: 'Pick the correctly spelled word.',
      ),
      StudyModeInfo(
        id: 'reading',
        title: 'Reading',
        description: 'Read and answer a quick comprehension prompt.',
      ),
      StudyModeInfo(
        id: 'word-patterns',
        title: 'Word Patterns',
        description: 'Find words that match a letter pattern.',
      ),
      StudyModeInfo(
        id: 'missing-letters',
        title: 'Missing Letters',
        description: 'Fill in missing letters in a word.',
      ),
    ],
  ),
  'sight_word_search': StudyGameData(
    ready: true,
    allModesNote: 'Your child practices every sight word activity.',
    modes: <StudyModeInfo>[
      StudyModeInfo(
        id: 'word-search',
        title: 'Word Search',
        description: 'Find sight words hidden in a grid.',
      ),
      StudyModeInfo(
        id: 'see-and-spell',
        title: 'See and Spell',
        description: 'See a word, then spell it.',
      ),
      StudyModeInfo(
        id: 'missing-letters',
        title: 'Missing Letters',
        description: 'Fill in the missing letters in a sight word.',
      ),
      StudyModeInfo(
        id: 'choose-correct',
        title: 'Choose Correct Spelling',
        description: 'Pick the correct spelling of a sight word.',
      ),
      StudyModeInfo(
        id: 'listen-and-spell',
        title: 'Listen and Spell',
        description: 'Hear a word, then spell it.',
      ),
      StudyModeInfo(
        id: 'sentence-fill',
        title: 'Sentence Fill-In',
        description: 'Pick the sight word that completes the sentence.',
      ),
    ],
  ),
  'clockwork': StudyGameData(
    ready: true,
    allModesNote: 'Your child practices every telling-time activity.',
    modes: <StudyModeInfo>[
      StudyModeInfo(
        id: 'clock-parts',
        title: 'Parts of a Clock',
        description: 'Learn the parts of a clock.',
      ),
      StudyModeInfo(
        id: 'time-parts',
        title: 'Parts of Time',
        description: 'Learn how time is divided into hours and minutes.',
      ),
      StudyModeInfo(
        id: 'fold-clock',
        title: 'Fold Clock',
        description:
            'Fold the clock to see which side a time is on, read hours and minutes, and add time.',
      ),
      StudyModeInfo(
        id: 'minute-hand',
        title: 'Minute Hand',
        description:
            'Read the minute hand as minutes, as a time phrase, or by picking the matching clock.',
      ),
      StudyModeInfo(
        id: 'read-clock',
        title: 'Read the Clock',
        description: 'Read the time shown on a clock.',
      ),
      StudyModeInfo(
        id: 'set-clock',
        title: 'Set the Clock',
        description: 'Move the clock hands to show a given time.',
      ),
      StudyModeInfo(
        id: 'digital-clock',
        title: 'Digital Clock',
        description: 'Practice reading and matching digital times.',
      ),
      StudyModeInfo(
        id: 'say-time',
        title: 'Say the Time',
        description: 'Practice saying the time in words, such as quarter past.',
      ),
      StudyModeInfo(
        id: 'am-pm',
        title: 'AM or PM',
        description:
            'Decide whether a time is in the morning or the afternoon and evening.',
      ),
      StudyModeInfo(
        id: 'how-long',
        title: 'How Long?',
        description: 'Work out how much time passes between two times.',
      ),
    ],
  ),
  'chem_kids': StudyGameData(
    ready: true,
    allModesNote: 'Your child explores every chemistry activity.',
    modes: <StudyModeInfo>[
      StudyModeInfo(
        id: 'explore',
        title: 'Explore the Table',
        description: 'Explore the periodic table and learn about each element.',
      ),
      StudyModeInfo(
        id: 'build-equation',
        title: 'Build Chemicals',
        description:
            'Combine elements to build chemical formulas and equations.',
      ),
      StudyModeInfo(
        id: 'experiments',
        title: 'Lab Experiments',
        description: 'Try simple lab experiments.',
      ),
    ],
  ),
  'slice_it': StudyGameData(
    ready: true,
    allModesNote: 'Your child practices every fraction activity.',
    modes: <StudyModeInfo>[
      StudyModeInfo(
        id: 'fraction-coach',
        title: 'Fraction Coach',
        description: 'Learn how fractions work, step by step.',
      ),
      StudyModeInfo(
        id: 'slice-ninja',
        title: 'Slice Ninja',
        description: 'Swipe to cut fruit into equal parts.',
      ),
      StudyModeInfo(
        id: 'balance-scale',
        title: 'Balance the Scale',
        description: 'Make both sides equal.',
      ),
      StudyModeInfo(
        id: 'same-amount',
        title: 'Same Amount',
        description: 'Find fractions that are equal.',
      ),
      StudyModeInfo(
        id: 'pizza-shop',
        title: 'Pizza Shop',
        description: 'Cut and serve the exact order.',
      ),
    ],
  ),
  'book_fixers': StudyGameData(
    ready: true,
    allModesNote:
        'Your child works through every proofreading and book-parts activity.',
    modes: <StudyModeInfo>[
      StudyModeInfo(
        id: 'capitals',
        title: 'Capital Letters',
        description: 'Fix names, days and the first word of a sentence.',
      ),
      StudyModeInfo(
        id: 'end-marks',
        title: 'End Marks',
        description: 'Pick the right mark at the end of a sentence.',
      ),
      StudyModeInfo(
        id: 'commas-apostrophes',
        title: 'Commas & Apostrophes',
        description: 'Fix commas, contractions and owners.',
      ),
      StudyModeInfo(
        id: 'quotes',
        title: 'Talking Marks',
        description: 'Add quotation marks around what people say.',
      ),
      StudyModeInfo(
        id: 'spelling',
        title: 'Spelling Check',
        description: 'Find the words that are spelled wrong.',
      ),
      StudyModeInfo(
        id: 'book-parts',
        title: 'Book Parts',
        description:
            'Use the cover, contents, glossary and index. (Three stations inside: Covers & Titles, Table of Contents, Glossary & Index.)',
      ),
      StudyModeInfo(
        id: 'word-detectives',
        title: 'Word Detectives',
        description: 'Find nouns, verbs and more in the stories.',
      ),
    ],
  ),
  'pumpkin_carver': StudyGameData(
    ready: true,
    allModesNote:
        'Your child can carve any way they like, with stencils or by drawing.',
    modes: <StudyModeInfo>[
      StudyModeInfo(
        id: 'stencil',
        title: 'Stencil',
        description: 'Carve along a ready-made shape, like a face or a star.',
      ),
      StudyModeInfo(
        id: 'free-draw',
        title: 'Free draw',
        description:
            'Draw their own cuts with a loop or a slice, then light the pumpkin up.',
      ),
    ],
  ),
  'piano_synth_demo': StudyGameData(
    ready: true,
    allModesNote: 'Your child can use every piano activity.',
    modes: <StudyModeInfo>[
      StudyModeInfo(
        id: 'free-play',
        title: 'Free play',
        description: 'Play any keys with no goal. Good for exploring sounds.',
      ),
      StudyModeInfo(
        id: 'listen',
        title: 'Listen',
        description:
            'Hear a short song, then listen to it again. No playing required.',
      ),
      StudyModeInfo(
        id: 'play-along',
        title: 'Play along',
        description: 'Follow a song and press the keys as they light up.',
      ),
      StudyModeInfo(
        id: 'chord',
        title: 'Play this chord',
        description: 'Shown a chord, find and play its notes.',
      ),
      StudyModeInfo(
        id: 'connection',
        title: 'Connection mode',
        description: 'Match music symbols (notes and rests) to their names.',
      ),
    ],
  ),
  'cooking_kids': StudyGameData(
    ready: true,
    allModesNote: 'Your child can use every cooking activity.',
    modes: <StudyModeInfo>[
      StudyModeInfo(
        id: 'mix-it',
        title: 'Mix-It Bowl',
        description: 'Drop ingredients into the bowl and see what they cook.',
      ),
      StudyModeInfo(
        id: 'word-search',
        title: 'Pantry Word Search',
        description:
            'Find ingredient words hidden in a grid. Practices reading and spelling.',
      ),
      StudyModeInfo(
        id: 'recipe-cards',
        title: 'Recipe Cards',
        description: 'Read recipe steps and sort or put them in order.',
      ),
      StudyModeInfo(
        id: 'spell',
        title: 'Spell the Ingredient',
        description: 'See an ingredient and write its name.',
      ),
      StudyModeInfo(
        id: 'measure',
        title: 'Measure & Scale',
        description:
            'Count and measure ingredients, and double or halve a recipe.',
      ),
    ],
  ),
  'paint_by_number': StudyGameData(
    ready: true,
    allModesNote: 'Your child can use both painting styles.',
    modes: <StudyModeInfo>[
      StudyModeInfo(
        id: 'guided',
        title: 'Paint by Number',
        description:
            'Match the numbers to the colors. Only the right color fits each space.',
      ),
      StudyModeInfo(
        id: 'free',
        title: 'Free Paint',
        description:
            'Use any colors they like on any space, with an eraser and custom colors.',
      ),
    ],
  ),
  'anatomy_kids': StudyGameData(
    ready: true,
    allModesNote: 'Your child explores the body from skin to skeleton.',
  ),
  'farm_kids': StudyGameData(
    ready: true,
    allModesNote: 'Your child runs the whole farm.',
  ),
  'comic_kids': StudyGameData(
    ready: true,
    allModesNote: 'Your child creates comics.',
  ),
  'arcade_lab': StudyGameData(
    ready: true,
    allModesNote: 'Your child can play any of the arcade games.',
  ),
  'measure_it': StudyGameData(
    ready: true,
    allModesNote: 'Your child practices every measuring activity.',
    modes: <StudyModeInfo>[
      StudyModeInfo(
        id: 'scoop-and-level',
        title: 'Scoop & Level',
        description:
            'Measure flour, sugar and rice with cups and level them off.',
      ),
      StudyModeInfo(
        id: 'spoon-ladder',
        title: 'Spoon Ladder',
        description:
            'Pour teaspoons into tablespoons and cups to see how they compare.',
      ),
      StudyModeInfo(
        id: 'pour-lab',
        title: 'Pour Lab',
        description: 'Fill a jug to cups, pints, quarts and gallons.',
      ),
      StudyModeInfo(
        id: 'balance-scale',
        title: 'Balance Scale',
        description: 'Weigh things in ounces and pounds on a balance scale.',
      ),
      StudyModeInfo(
        id: 'stretch-ruler',
        title: 'Stretch Ruler',
        description: 'Measure objects in inches, feet and yards.',
      ),
      StudyModeInfo(
        id: 'recipe-scaling',
        title: 'Recipe Scaling',
        description: 'Double, triple or halve the amounts in a recipe.',
      ),
      StudyModeInfo(
        id: 'estimate',
        title: 'Estimate',
        description:
            'Pick the unit that makes sense, like ounces, pounds or tons.',
      ),
    ],
  ),
};

/// Games deliberately left out of Study Plans for now, with the reason.
const Map<String, String> kStudyPlanNotYet = <String, String>{
  'be_with_god':
      'Has a lot of uncommitted work; hooked up after it is committed.',
  'math_solitaire_kids': 'Placeholder on the home, not live yet.',
};
