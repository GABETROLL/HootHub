/// Every child Widget that edits the Test requests callbacks that actually mutate the state,
/// at the top widget: `MakeTest`.
library;

// backend
import 'package:hoothub/firebase/models/test.dart';
import 'package:hoothub/firebase/models/question.dart';
import 'package:hoothub/firebase/api/tests.dart';
// frontend
import 'package:flutter/material.dart';
import 'package:hoothub/screens/make_test/slide_editor.dart';
import 'package:hoothub/screens/slide_preview.dart';

class AddSlideButton extends StatelessWidget {
  const AddSlideButton({super.key, this.onPressed});

  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) => Center(
    child: ElevatedButton(
      onPressed: onPressed ?? (() { }),
      child: const Text('Add question'),
    ),
  );
}

/// Eventually pops with void. Edits the test, then saves it.
class MakeTest extends StatefulWidget {
  const MakeTest({
    super.key,
    required this.testModel,
  });

  final Test testModel;

  @override
  State<MakeTest> createState() => _MakeTestState();
}

class _MakeTestState extends State<MakeTest> {
  // default index. May not be in the bounds of `testModel!.questions`,
  // since that could be empty!
  int _currentSlideIndex = 0;
  // assigned by `initState`.
  late Test _testModel;

  @override
  void initState() {
    super.initState();
    _testModel = widget.testModel;
  }

  Future<void> onTestSaved(BuildContext context) async {
    if (!(_testModel.isValid()) && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid Test!')),
      );
    } else {
      String saveResult = await saveTest(_testModel);

      if (!(context.mounted)) return;

      if (saveResult != 'Ok') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving test: $saveResult')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Test saved successfully!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> slidePreviews = [];

    for (final (int index, Question question) in _testModel.questions.indexed) {
      slidePreviews.add(
        IconButton(
          onPressed: () => setState(() {
            // `index` should be within the index bounds of `testModel.questions`,
            // so `_currentSlideIndex` should also be, after this `setState` call.
            _currentSlideIndex = index;
          }),
          icon: const SlidePreview(),
        ),
      );
    }

    /*
      Add an `AddSlideButton` at the bottom of the `slidePreviews` `List<Widget>`.
      When pressed, it should add a new (EMPTY) question to `testModel.questions`,
      and automatically change `_currentSlideIndex` to the index of this new `Question`.

      This means that pressing this `AddSlideButton` will automatically jump to the last
      slide, where the user SHOULD be able to edit the last question.
    */
    slidePreviews.add(
      AddSlideButton(
        onPressed: () {
          setState(() {
            _testModel.addNewEmptyQuestion();
            _currentSlideIndex = _testModel.questions.length - 1;
          });
        },
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(_testModel.name),
        actions: <Widget>[
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Exit'),
          ),
          Builder(
            builder: (BuildContext context) =>  ElevatedButton(
              onPressed: () => onTestSaved(context),
              child: const Text('Save'),
            ),
          ),
        ],
      ),
      body: Row(
        children: <Widget>[
          Column(
            children: slidePreviews,
          ),
          // `_currentSlideIndex` may be out of the range of the list.
          // In the case that it is,
          // the `AddSlideButton` "slide" will be displayed instead.
          (
            _currentSlideIndex < 0 || _currentSlideIndex >= _testModel.questions.length
            ? const Center(child: AddSlideButton())
            : Expanded(
              child: SlideEditor(
                questionModel: _testModel.questions[_currentSlideIndex],
                setQuestion: (String question) => setState(() {
                  _testModel.setQuestion(_currentSlideIndex, question);
                }),
                addNewEmptyAnswer: () => setState(() {
                  _testModel.addNewEmptyAnswer(_currentSlideIndex);
                }),
                setCorrectAnswer: (int index) => setState(() {
                  _testModel.setCorrectAnswer(_currentSlideIndex, index);
                }),
                setAnswer: (int index, String answer) => setState(() {
                  _testModel.setAnswer(_currentSlideIndex, index, answer);
                }),
                setSecondsDuration: (int secondsDuration) => setState(() {
                  _testModel.setSecondsDuration(_currentSlideIndex, secondsDuration);
                }),
              ),
            )
          ),
        ],
      ),
    );
  }
}
