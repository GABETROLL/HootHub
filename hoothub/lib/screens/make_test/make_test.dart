/// Every child Widget that edits the Test requests callbacks that actually mutate the state,
/// at the top widget: `MakeTest`.
library;

// backend
import 'package:hoothub/firebase/models/test.dart';
import 'package:hoothub/firebase/models/question.dart';
import 'package:hoothub/firebase/api/tests.dart';
// frontend
import 'package:flutter/material.dart';
import 'slide_editor.dart';
import 'slide_preview.dart';
import 'add_slide_button.dart';

/// Eventually pops with void. Edits the test, then saves it.
///
/// It has its own `Scaffold` wrapping all of its content,
/// and IT'S MEANT TO BE USED DIRECTLY IN A ROUTE.
class MakeTest extends StatefulWidget {
  const MakeTest({
    super.key,
    required this.testModel,
  });

  final Test testModel;

  @override
  State<MakeTest> createState() => _MakeTestState();
}

/* class SlideTextEditingControllers {
  const SlideTextEditingControllers({required this.questionTextEditingController, required this.answerTextEditingControllers});

  final TextEditingController questionTextEditingController;
  final List<TextEditingController> answerTextEditingControllers;
} */

class _MakeTestState extends State<MakeTest> {
  // int _currentSlideIndex = 0;
  late Widget _currentSlideEditor;
  late Test _testModel;
  // late List<SlideTextEditingControllers> _testTextEditingControllers;

  /// Sets `_currentSlideEditor` equal to a `SlideEditor` `Widget` that edits
  /// the `slideIndex`-th question, WHICH SHOULD BE THE ONE THE USER IS TRYING TO EDIT.
  ///
  /// If `slideIndex` is OUT OF THE RANGE OF `_testModel.questions`,
  /// this method assings `_currentSlideEditor` to a centered `AddSlideButton`
  /// instead.
  ///
  /// This method eliminates a problem:
  /// Each time a user would type text in one `TextField` in a `SlideEditor`,
  /// wouldn't press `Enter`, then would set some other state of the question inside
  /// that same `SlideEditor`, the text would be gone! Because the user never **saved**
  /// that text to the slide's `Question` by pressing `Enter`.
  ///
  /// Keeping track of the `_currentSlideEditor` allows the user to set state
  /// to this `_testModel`, and have this `Widget` RE-BUILD ITSELF,
  /// WITHOUT LOSING THE DATA IN THE SLIDE'S `TextEditingController`s, BECAUSE
  /// THE WIDGET WON'T BE RE-RENDERED AGAIN, WHICH MEANS THE `TextEditingController`s
  /// WON'T BE CHANGED!
  void _setCurrentSlideEditor({required int slideIndex}) {
    if (!(0 <= slideIndex && slideIndex < _testModel.questions.length)) {
      setState(() {
        _currentSlideEditor = Center(
          child: AddSlideButton(
            onPressed: () => setState(() {
              _testModel.addNewEmptyQuestion();
              _setCurrentSlideEditor(slideIndex: _testModel.questions.length);
            }),
          ),
        );
      });
    } else {
      setState(() {
        _currentSlideEditor = SlideEditor(
          questionModel: _testModel.questions[slideIndex],
          setQuestion: (String question) => setState(() {
            _testModel.setQuestion(slideIndex, question);
          }),
          addNewEmptyAnswer: () => setState(() {
            _testModel.addNewEmptyAnswer(slideIndex);
          }),
          setCorrectAnswer: (int answerIndex) => setState(() {
            _testModel.setCorrectAnswer(slideIndex, answerIndex);
          }),
          setAnswer: (int answerIndex, String answer) => setState(() {
            _testModel.setAnswer(slideIndex, answerIndex, answer);
          }),
          setSecondsDuration: (int secondsDuration) => setState(() {
            _testModel.setSecondsDuration(slideIndex, secondsDuration);
          }),
        );
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _testModel = widget.testModel;
    /* _testTextEditingControllers = <SlideTextEditingControllers>[];

    for (Question question in _testModel.questions) {
      final questionTextEditingController = TextEditingController(text: question.question);
      final answerTextEditingControllers = <TextEditingController>[];

      for (String answer in question.answers) {
        answerTextEditingControllers.add(TextEditingController(text: answer));
      }
      _testTextEditingControllers.add(
        SlideTextEditingControllers(
          questionTextEditingController: questionTextEditingController,
          answerTextEditingControllers: answerTextEditingControllers
        ),
      );
    } */
    _setCurrentSlideEditor(slideIndex: 0);
  }

  Future<void> _onTestSaved(BuildContext context) async {
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
          onPressed: () => _setCurrentSlideEditor(slideIndex: index),
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
            // set the current slide to be for the last question
            _setCurrentSlideEditor(slideIndex: _testModel.questions.length - 1);
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
              onPressed: () => _onTestSaved(context),
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
          Expanded(child: _currentSlideEditor),
        ],
      ),
    );
  }
}
