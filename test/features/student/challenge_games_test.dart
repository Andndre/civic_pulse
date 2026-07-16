import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:civic_pulse/features/student/learning/widgets/challenge_games/matching_game_card.dart';
import 'package:civic_pulse/features/student/learning/widgets/challenge_games/multiple_choice_card.dart';
import 'package:civic_pulse/features/student/learning/widgets/challenge_games/sorting_game_card.dart';
import 'package:civic_pulse/features/student/learning/widgets/challenge_games/true_false_swipe_card.dart';
import 'package:civic_pulse/shared/services/data_models.dart';

LearningNode _node(String gameType, Map<String, dynamic> payload) => LearningNode(
      id: 1,
      materialId: 1,
      orderIndex: 0,
      nodeType: 'challenge',
      title: 'Tantangan Uji',
      body: 'Instruksi tantangan',
      gameType: gameType,
      payload: payload,
    );

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('MultipleChoiceCard', () {
    final node = _node('multiple_choice', {
      'question': 'Apa arti toleransi?',
      'options': [
        {'id': 'a', 'label': 'Menghormati perbedaan'},
        {'id': 'b', 'label': 'Memaksakan pendapat'},
      ],
      'correct': 'a',
    });

    testWidgets('memilih jawaban lalu konfirmasi memanggil onComplete', (tester) async {
      Map<String, dynamic>? result;
      await tester.pumpWidget(_wrap(
        MultipleChoiceCard(node: node, onComplete: (a) => result = a),
      ));

      expect(find.text('Apa arti toleransi?'), findsOneWidget);

      await tester.tap(find.text('Menghormati perbedaan'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Konfirmasi Jawaban'));
      await tester.pumpAndSettle();

      expect(find.text('Benar! Jawaban tepat.'), findsOneWidget);
      await tester.tap(find.text('Lanjutkan'));
      expect(result, {'selected': 'a'});
    });
  });

  group('TrueFalseSwipeCard', () {
    final node = _node('true_false_swipe', {
      'statements': [
        {'id': 's1', 'text': 'Pernyataan satu', 'answer': true},
        {'id': 's2', 'text': 'Pernyataan dua', 'answer': false},
      ],
    });

    testWidgets('menjawab lewat tombol sampai ringkasan lalu onComplete', (tester) async {
      Map<String, dynamic>? result;
      await tester.pumpWidget(_wrap(
        TrueFalseSwipeCard(node: node, onComplete: (a) => result = a),
      ));

      expect(find.text('Pernyataan satu'), findsOneWidget);

      await tester.tap(find.text('Benar'));
      await tester.pump(const Duration(milliseconds: 1000));
      expect(find.text('Pernyataan dua'), findsOneWidget);

      await tester.tap(find.text('Salah'));
      await tester.pump(const Duration(milliseconds: 1000));
      await tester.pumpAndSettle();

      expect(find.text('2/2'), findsWidgets);
      await tester.tap(find.text('Lanjutkan'));
      expect(result?['correct'], 2);
    });

    testWidgets('swipe kanan menjawab benar', (tester) async {
      await tester.pumpWidget(_wrap(
        TrueFalseSwipeCard(node: node, onComplete: (_) {}),
      ));

      await tester.drag(find.text('Pernyataan satu'), const Offset(250, 0));
      // Tick pertama memulai epoch animasi, tick kedua menyelesaikan
      // slide-out (220ms), tick ketiga merender state hasil
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pump();
      expect(find.text('Benar!'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 1000));
      expect(find.text('Pernyataan dua'), findsOneWidget);
    });
  });

  group('MatchingGameCard', () {
    final node = _node('matching', {
      'pairs': [
        {'id': 'p1', 'left': 'Toleransi', 'right': 'Menghormati perbedaan'},
        {'id': 'p2', 'left': 'Moderasi', 'right': 'Sikap tidak berlebihan'},
      ],
    });

    testWidgets('mencocokkan semua pasangan lalu konfirmasi', (tester) async {
      Map<String, dynamic>? result;
      await tester.pumpWidget(_wrap(
        MatchingGameCard(node: node, onComplete: (a) => result = a),
      ));

      await tester.tap(find.text('Toleransi'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Menghormati perbedaan'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Moderasi'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sikap tidak berlebihan'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Konfirmasi Jawaban'));
      await tester.pumpAndSettle();

      expect(find.text('Semua pasangan benar! Hebat!'), findsOneWidget);
      await tester.tap(find.text('Lanjutkan'));
      expect(result, {
        'matches': {
          'Toleransi': 'Menghormati perbedaan',
          'Moderasi': 'Sikap tidak berlebihan',
        },
      });
    });
  });

  group('SortingGameCard', () {
    final node = _node('sorting', {
      'categories': ['Toleran', 'Intoleran'],
      'items': [
        {'id': 'a', 'label': 'Membiarkan teman beribadah', 'category': 'Toleran'},
        {'id': 'b', 'label': 'Mengejek teman beda agama', 'category': 'Intoleran'},
      ],
    });

    testWidgets('menyeret item ke keranjang lalu konfirmasi', (tester) async {
      Map<String, dynamic>? result;
      await tester.pumpWidget(_wrap(
        SortingGameCard(node: node, onComplete: (a) => result = a),
      ));

      await tester.drag(
        find.text('Membiarkan teman beribadah'),
        tester.getCenter(find.text('Toleran')) -
            tester.getCenter(find.text('Membiarkan teman beribadah')),
      );
      await tester.pumpAndSettle();

      await tester.drag(
        find.text('Mengejek teman beda agama'),
        tester.getCenter(find.text('Intoleran')) -
            tester.getCenter(find.text('Mengejek teman beda agama')),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Konfirmasi Jawaban'));
      await tester.pumpAndSettle();

      expect(find.text('Sempurna! Semua item di kategori yang benar!'), findsOneWidget);
      await tester.tap(find.text('Lanjutkan'));
      expect(result?['correct'], 2);
    });
  });
}
