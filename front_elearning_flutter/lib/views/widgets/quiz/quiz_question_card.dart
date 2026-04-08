import 'package:flutter/material.dart';

import '../../../models/quiz/quiz_models.dart';
import '../../../viewmodels/quiz/quiz_screen_viewmodel.dart';
import '../common/catalunya_card.dart';

class QuizQuestionCard extends StatelessWidget {
  const QuizQuestionCard({
    super.key,
    required this.question,
    required this.answer,
    required this.hasAttempt,
    required this.onTextChanged,
    required this.onToggleMulti,
    required this.onSelectSingle,
  });

  final QuizQuestionModel question;
  final QuizAnswerModel? answer;
  final bool hasAttempt;
  final ValueChanged<String> onTextChanged;
  final void Function(String optionId, bool checked) onToggleMulti;
  final ValueChanged<String> onSelectSingle;

  @override
  Widget build(BuildContext context) {
    return CatalunyaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question.content),
          const SizedBox(height: 10),
          if (question.isTextQuestion)
            TextField(
              enabled: hasAttempt,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Nháº­p Ä‘Ã¡p Ã¡n',
              ),
              onChanged: onTextChanged,
            )
          else if (question.isMultiChoice)
            ...question.options.map((o) {
              final selected =
                  answer?.multiOptionIds.contains(o.optionId) ?? false;
              return CheckboxListTile(
                value: selected,
                title: Text(o.text),
                onChanged: !hasAttempt
                    ? null
                    : (v) => onToggleMulti(o.optionId, v == true),
              );
            })
          else
            ...question.options.map((o) {
              final selected = answer?.singleOptionId == o.optionId;
              return InkWell(
                onTap: !hasAttempt ? null : () => onSelectSingle(o.optionId),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected
                          ? Theme.of(context).colorScheme.primary
                          : const Color(0xFFD5E1F1),
                    ),
                    color: selected ? const Color(0xFFEFF8FF) : Colors.white,
                  ),
                  child: Text(o.text),
                ),
              );
            }),
        ],
      ),
    );
  }
}

