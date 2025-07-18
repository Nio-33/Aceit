import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aceit/models/question_model.dart';
import 'package:aceit/models/flashcard_model.dart';
import 'package:aceit/models/mock_exam_model.dart';

class SeedDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _questionsCollection = 'questions';
  static const String _flashcardsCollection = 'flashcards';
  static const String _mockExamsCollection = 'mock_exams';

  // Seed sample questions for testing
  Future<void> seedSampleQuestions() async {
    try {
      // Check if questions already exist
      final existingQuestions =
          await _firestore.collection(_questionsCollection).limit(1).get();

      if (existingQuestions.docs.isNotEmpty) {
        print('Questions already exist, skipping seed');
        return;
      }

      final sampleQuestions = _generateSampleQuestions();

      // Add questions to Firestore
      final batch = _firestore.batch();
      for (final question in sampleQuestions) {
        final docRef =
            _firestore.collection(_questionsCollection).doc(question.id);
        batch.set(docRef, question.toJson());
      }

      await batch.commit();
      print('Successfully seeded ${sampleQuestions.length} questions');
    } catch (e) {
      print('Error seeding questions: $e');
      rethrow;
    }
  }

  // Seed sample flashcards
  Future<void> seedSampleFlashcards() async {
    try {
      // Check if flashcards already exist
      final existingFlashcards =
          await _firestore.collection(_flashcardsCollection).limit(1).get();

      if (existingFlashcards.docs.isNotEmpty) {
        print('Flashcards already exist, skipping seed');
        return;
      }

      final sampleFlashcards = _generateSampleFlashcards();

      // Add flashcards to Firestore
      final batch = _firestore.batch();
      for (final flashcard in sampleFlashcards) {
        final docRef =
            _firestore.collection(_flashcardsCollection).doc(flashcard.id);
        batch.set(docRef, flashcard.toJson());
      }

      await batch.commit();
      print('Successfully seeded ${sampleFlashcards.length} flashcards');
    } catch (e) {
      print('Error seeding flashcards: $e');
      rethrow;
    }
  }

  // Seed sample mock exams
  Future<void> seedSampleMockExams() async {
    try {
      // Check if mock exams already exist
      final existingExams =
          await _firestore.collection(_mockExamsCollection).limit(1).get();

      if (existingExams.docs.isNotEmpty) {
        print('Mock exams already exist, skipping seed');
        return;
      }

      // First, get some question IDs to use in mock exams
      final questionsSnapshot =
          await _firestore.collection(_questionsCollection).limit(50).get();

      if (questionsSnapshot.docs.isEmpty) {
        print('No questions found, seeding questions first');
        await seedSampleQuestions();
        return seedSampleMockExams();
      }

      final questionIds = questionsSnapshot.docs.map((doc) => doc.id).toList();
      final sampleExams = _generateSampleMockExams(questionIds);

      // Add mock exams to Firestore
      final batch = _firestore.batch();
      for (final exam in sampleExams) {
        final docRef = _firestore.collection(_mockExamsCollection).doc(exam.id);
        batch.set(docRef, exam.toJson());
      }

      await batch.commit();
      print('Successfully seeded ${sampleExams.length} mock exams');
    } catch (e) {
      print('Error seeding mock exams: $e');
      rethrow;
    }
  }

  // Seed all sample data
  Future<void> seedAllSampleData() async {
    try {
      print('Starting to seed sample data...');

      await seedSampleQuestions();
      await seedSampleFlashcards();
      await seedSampleMockExams();

      print('Successfully seeded all sample data');
    } catch (e) {
      print('Error seeding sample data: $e');
      rethrow;
    }
  }

  // Generate sample questions
  List<QuestionModel> _generateSampleQuestions() {
    return [
      // Mathematics - WAEC
      QuestionModel(
        id: 'math_waec_1',
        text: 'What is the value of x in the equation 2x + 5 = 13?',
        options: ['2', '3', '4', '5'],
        correctAnswerIndex: 2,
        explanation: 'Solving: 2x + 5 = 13, 2x = 8, x = 4',
        subject: 'Mathematics',
        examType: 'WAEC',
        difficultyLevel: 1,
      ),
      QuestionModel(
        id: 'math_waec_2',
        text:
            'If the circumference of a circle is 44cm, what is its radius? (Take π = 22/7)',
        options: ['5cm', '6cm', '7cm', '8cm'],
        correctAnswerIndex: 2,
        explanation: 'C = 2πr, so r = C/(2π) = 44/(2×22/7) = 44×7/(2×22) = 7cm',
        subject: 'Mathematics',
        examType: 'WAEC',
        difficultyLevel: 2,
      ),
      QuestionModel(
        id: 'math_waec_3',
        text: 'Simplify: 3x² - 2x + 1 - (x² + 3x - 2)',
        options: [
          '2x² - 5x + 3',
          '4x² + x - 1',
          '2x² - 5x - 1',
          '4x² - 5x + 3'
        ],
        correctAnswerIndex: 0,
        explanation: '3x² - 2x + 1 - x² - 3x + 2 = 2x² - 5x + 3',
        subject: 'Mathematics',
        examType: 'WAEC',
        difficultyLevel: 2,
      ),

      // English Language - WAEC
      QuestionModel(
        id: 'eng_waec_1',
        text: 'Choose the correct spelling:',
        options: ['Recieve', 'Receive', 'Receeve', 'Receve'],
        correctAnswerIndex: 1,
        explanation:
            'The correct spelling is "Receive" - remember "i before e except after c"',
        subject: 'English Language',
        examType: 'WAEC',
        difficultyLevel: 1,
      ),
      QuestionModel(
        id: 'eng_waec_2',
        text: 'What is the plural form of "child"?',
        options: ['Childs', 'Children', 'Childrens', 'Childes'],
        correctAnswerIndex: 1,
        explanation:
            'The plural of "child" is "children" - an irregular plural form',
        subject: 'English Language',
        examType: 'WAEC',
        difficultyLevel: 1,
      ),

      // Physics - WAEC
      QuestionModel(
        id: 'phy_waec_1',
        text: 'What is the unit of electric current?',
        options: ['Volt', 'Ampere', 'Ohm', 'Watt'],
        correctAnswerIndex: 1,
        explanation:
            'The unit of electric current is Ampere (A), named after André-Marie Ampère',
        subject: 'Physics',
        examType: 'WAEC',
        difficultyLevel: 1,
      ),
      QuestionModel(
        id: 'phy_waec_2',
        text: 'The acceleration due to gravity on Earth is approximately:',
        options: ['9.8 m/s²', '10.8 m/s²', '8.9 m/s²', '11.2 m/s²'],
        correctAnswerIndex: 0,
        explanation:
            'The acceleration due to gravity on Earth is approximately 9.8 m/s²',
        subject: 'Physics',
        examType: 'WAEC',
        difficultyLevel: 1,
      ),

      // Mathematics - JAMB
      QuestionModel(
        id: 'math_jamb_1',
        text: 'If log₁₀ 2 = 0.3010 and log₁₀ 3 = 0.4771, find log₁₀ 6',
        options: ['0.7781', '0.1761', '0.6020', '0.4771'],
        correctAnswerIndex: 0,
        explanation:
            'log₁₀ 6 = log₁₀ (2×3) = log₁₀ 2 + log₁₀ 3 = 0.3010 + 0.4771 = 0.7781',
        subject: 'Mathematics',
        examType: 'JAMB',
        difficultyLevel: 3,
      ),
      QuestionModel(
        id: 'math_jamb_2',
        text: 'Find the coefficient of x² in the expansion of (2x - 3)³',
        options: ['54', '-54', '36', '-36'],
        correctAnswerIndex: 1,
        explanation:
            'Using binomial expansion: (2x - 3)³ = 8x³ - 36x² + 54x - 27, coefficient of x² is -36',
        subject: 'Mathematics',
        examType: 'JAMB',
        difficultyLevel: 3,
      ),

      // Biology - JAMB
      QuestionModel(
        id: 'bio_jamb_1',
        text:
            'Which of the following is not a characteristic of living things?',
        options: ['Growth', 'Reproduction', 'Combustion', 'Respiration'],
        correctAnswerIndex: 2,
        explanation:
            'Combustion is not a characteristic of living things. The characteristics include growth, reproduction, respiration, excretion, etc.',
        subject: 'Biology',
        examType: 'JAMB',
        difficultyLevel: 1,
      ),
      QuestionModel(
        id: 'bio_jamb_2',
        text:
            'The process by which plants manufacture their own food is called:',
        options: [
          'Respiration',
          'Photosynthesis',
          'Transpiration',
          'Digestion'
        ],
        correctAnswerIndex: 1,
        explanation:
            'Photosynthesis is the process by which plants use sunlight, water, and carbon dioxide to produce glucose and oxygen',
        subject: 'Biology',
        examType: 'JAMB',
        difficultyLevel: 1,
      ),

      // Chemistry - NECO
      QuestionModel(
        id: 'chem_neco_1',
        text: 'What is the atomic number of Carbon?',
        options: ['4', '6', '8', '12'],
        correctAnswerIndex: 1,
        explanation:
            'Carbon has an atomic number of 6, meaning it has 6 protons in its nucleus',
        subject: 'Chemistry',
        examType: 'NECO',
        difficultyLevel: 1,
      ),
      QuestionModel(
        id: 'chem_neco_2',
        text: 'Which of the following is a noble gas?',
        options: ['Oxygen', 'Nitrogen', 'Helium', 'Hydrogen'],
        correctAnswerIndex: 2,
        explanation:
            'Helium is a noble gas (Group 18 element) with a complete outer electron shell',
        subject: 'Chemistry',
        examType: 'NECO',
        difficultyLevel: 1,
      ),

      // Geography - NECO
      QuestionModel(
        id: 'geo_neco_1',
        text: 'Which continent is known as the "Dark Continent"?',
        options: ['Asia', 'Africa', 'South America', 'Australia'],
        correctAnswerIndex: 1,
        explanation:
            'Africa was historically called the "Dark Continent" due to its unexplored nature in the past',
        subject: 'Geography',
        examType: 'NECO',
        difficultyLevel: 1,
      ),
      QuestionModel(
        id: 'geo_neco_2',
        text:
            'The imaginary line that divides the Earth into Northern and Southern hemispheres is:',
        options: [
          'Prime Meridian',
          'Tropic of Cancer',
          'Equator',
          'Tropic of Capricorn'
        ],
        correctAnswerIndex: 2,
        explanation:
            'The Equator (0° latitude) divides the Earth into Northern and Southern hemispheres',
        subject: 'Geography',
        examType: 'NECO',
        difficultyLevel: 1,
      ),
    ];
  }

  // Generate sample flashcards
  List<FlashcardModel> _generateSampleFlashcards() {
    return [
      FlashcardModel(
        id: 'flash_math_1',
        front: 'What is the Pythagorean theorem?',
        back:
            'a² + b² = c²\nIn a right triangle, the square of the hypotenuse equals the sum of squares of the other two sides.',
        subject: 'Mathematics',
      ),
      FlashcardModel(
        id: 'flash_math_2',
        front: 'What is the quadratic formula?',
        back:
            'x = (-b ± √(b² - 4ac)) / 2a\nUsed to solve quadratic equations of the form ax² + bx + c = 0',
        subject: 'Mathematics',
      ),
      FlashcardModel(
        id: 'flash_eng_1',
        front: 'Define a metaphor',
        back:
            'A figure of speech that directly compares two unlike things without using "like" or "as".\nExample: "Life is a journey"',
        subject: 'English Language',
      ),
      FlashcardModel(
        id: 'flash_eng_2',
        front: 'What is alliteration?',
        back:
            'The repetition of the same consonant sound at the beginning of words in close succession.\nExample: "Peter Piper picked a peck"',
        subject: 'English Language',
      ),
      FlashcardModel(
        id: 'flash_phy_1',
        front: 'State Newton\'s First Law of Motion',
        back:
            'An object at rest stays at rest and an object in motion stays in motion with the same speed and in the same direction unless acted upon by an unbalanced force.',
        subject: 'Physics',
      ),
      FlashcardModel(
        id: 'flash_phy_2',
        front: 'What is the formula for kinetic energy?',
        back: 'KE = ½mv²\nWhere:\nKE = kinetic energy\nm = mass\nv = velocity',
        subject: 'Physics',
      ),
      FlashcardModel(
        id: 'flash_bio_1',
        front: 'What is photosynthesis?',
        back:
            'The process by which plants convert light energy into chemical energy (glucose) using carbon dioxide and water.\n6CO₂ + 6H₂O + light → C₆H₁₂O₆ + 6O₂',
        subject: 'Biology',
      ),
      FlashcardModel(
        id: 'flash_bio_2',
        front: 'What is DNA?',
        back:
            'Deoxyribonucleic Acid - the hereditary material in humans and almost all organisms. It carries genetic information in the form of genes.',
        subject: 'Biology',
      ),
      FlashcardModel(
        id: 'flash_chem_1',
        front: 'What is an acid?',
        back:
            'A substance that donates hydrogen ions (H⁺) in aqueous solution. Has a pH less than 7.\nExamples: HCl, H₂SO₄, HNO₃',
        subject: 'Chemistry',
      ),
      FlashcardModel(
        id: 'flash_chem_2',
        front: 'What is the periodic table?',
        back:
            'A tabular arrangement of chemical elements ordered by atomic number, showing recurring properties and trends.',
        subject: 'Chemistry',
      ),
    ];
  }

  // Generate sample mock exams
  List<MockExamModel> _generateSampleMockExams(List<String> questionIds) {
    return [
      MockExamModel(
        id: 'exam_math_waec_1',
        title: 'Mathematics Practice Test 1',
        subject: 'Mathematics',
        examType: 'WAEC',
        durationInMinutes: 180,
        numberOfQuestions: 10,
        questionIds: questionIds.take(10).toList(),
        passMarkPercentage: 50,
      ),
      MockExamModel(
        id: 'exam_eng_waec_1',
        title: 'English Language Practice Test 1',
        subject: 'English Language',
        examType: 'WAEC',
        durationInMinutes: 180,
        numberOfQuestions: 10,
        questionIds: questionIds.skip(2).take(10).toList(),
        passMarkPercentage: 50,
      ),
      MockExamModel(
        id: 'exam_math_jamb_1',
        title: 'Mathematics JAMB Mock Exam',
        subject: 'Mathematics',
        examType: 'JAMB',
        durationInMinutes: 120,
        numberOfQuestions: 8,
        questionIds: questionIds.skip(4).take(8).toList(),
        passMarkPercentage: 60,
      ),
      MockExamModel(
        id: 'exam_bio_jamb_1',
        title: 'Biology JAMB Mock Exam',
        subject: 'Biology',
        examType: 'JAMB',
        durationInMinutes: 120,
        numberOfQuestions: 8,
        questionIds: questionIds.skip(6).take(8).toList(),
        passMarkPercentage: 60,
      ),
      MockExamModel(
        id: 'exam_chem_neco_1',
        title: 'Chemistry NECO Practice Test',
        subject: 'Chemistry',
        examType: 'NECO',
        durationInMinutes: 150,
        numberOfQuestions: 10,
        questionIds: questionIds.skip(8).take(10).toList(),
        passMarkPercentage: 50,
      ),
    ];
  }

  // Clear all sample data (for testing)
  Future<void> clearAllSampleData() async {
    try {
      print('Clearing all sample data...');

      // Clear questions
      final questionsSnapshot =
          await _firestore.collection(_questionsCollection).get();
      final questionBatch = _firestore.batch();
      for (final doc in questionsSnapshot.docs) {
        questionBatch.delete(doc.reference);
      }
      await questionBatch.commit();

      // Clear flashcards
      final flashcardsSnapshot =
          await _firestore.collection(_flashcardsCollection).get();
      final flashcardBatch = _firestore.batch();
      for (final doc in flashcardsSnapshot.docs) {
        flashcardBatch.delete(doc.reference);
      }
      await flashcardBatch.commit();

      // Clear mock exams
      final examsSnapshot =
          await _firestore.collection(_mockExamsCollection).get();
      final examBatch = _firestore.batch();
      for (final doc in examsSnapshot.docs) {
        examBatch.delete(doc.reference);
      }
      await examBatch.commit();

      print('Successfully cleared all sample data');
    } catch (e) {
      print('Error clearing sample data: $e');
      rethrow;
    }
  }
}
