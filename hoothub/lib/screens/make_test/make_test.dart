/// Every child Widget that edits the Test requests callbacks that actually mutate the state,
/// at the top widget: `MakeTest`.
library;

// backend
import 'package:firebase_core/firebase_core.dart';
import 'package:hoothub/firebase/models/test.dart';
import 'package:hoothub/firebase/models/question.dart';
import 'package:hoothub/firebase/api/tests.dart';
import 'package:hoothub/firebase/api/images.dart';
// frontend
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:hoothub/screens/make_test/image_editor.dart';
import 'package:hoothub/screens/make_test/slide_editor.dart';
import 'package:hoothub/screens/make_test/slide_preview.dart';
import 'package:hoothub/screens/styles.dart';

class AddSlideButton extends StatelessWidget {
  const AddSlideButton({super.key, required this.onPressed});

  final void Function() onPressed;

  @override
  Widget build(BuildContext context) => Center(
    child: ElevatedButton(
      onPressed: onPressed,
      child: const Text('Add question'),
    ),
  );
}

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

class QuestionEditingControllers {
  QuestionEditingControllers({
    required this.questionEditingController,
    required this.answerEditingControllers,
  });

  TextEditingController questionEditingController;
  List<TextEditingController> answerEditingControllers;
}

class _MakeTestState extends State<MakeTest> {
  // default index. May not be in the bounds of `testModel!.questions`,
  // since that could be empty!
  late int _currentSlideIndex;
  late Test _testModel;
  Uint8List? _testImage;
  // [null for Question question in widget.testModel.questions]
  late List<Uint8List?> _questionImages;
  late bool _downloadedImages;
  // Text fields
  late TextEditingController testNameEditingController;
  late List<QuestionEditingControllers> questionEditingControllers;

  @override
  void initState() {
    super.initState();
    _currentSlideIndex = 0;
    _testModel = widget.testModel;
    _testImage = null;
    _questionImages = List<Uint8List?>.from(
      widget.testModel.questions.map<Uint8List?>((Question question) => null),
    );
    _downloadedImages = false;
    // Something 
    testNameEditingController = TextEditingController(text: widget.testModel.name);
    questionEditingControllers = [];

    for (Question question in widget.testModel.questions) {
      final TextEditingController questionEditingController = TextEditingController(
        text: question.question,
      );
      final List<TextEditingController> answerEditingControllers = [];

      for (String answer in question.answers) {
        answerEditingControllers.add(
          TextEditingController(text: answer),
        );
      }

      questionEditingControllers.add(
        QuestionEditingControllers(
          questionEditingController: questionEditingController,
          answerEditingControllers: answerEditingControllers,
        ),
      );
    }
  }

  Future<void> _downloadImages() async {
    Uint8List? testImage;
    List<Uint8List?> questionImages = List<Uint8List?>.from(_questionImages);

    try {
      testImage = await downloadTestImage(_testModel.id!);
    } catch (error) {
      print("`_MakeTestState`: Error downloading test ${_testModel.id}'s image: $error");
    }

    for (final (int questionIndex, Question _) in _testModel.questions.indexed) {
      try {
        questionImages[questionIndex] = await downloadQuestionImage(_testModel.id!, questionIndex);
      } catch (error) {
        print("`_MakeTestState`: Error downloading question #$questionIndex's image of test ${_testModel.id}: $error");
      }
    }

    setState(() {
      _testImage = testImage;
      _questionImages = questionImages;
      _downloadedImages = true;
    });
  }

  /// Tries to save the test and the image.
  ///
  /// If something seems to go wrong, tries to spawn a `SnackBar`
  /// with the error.
  Future<void> _onTestSaved(BuildContext context) async {
    if (!(_testModel.isValid()) && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid Test!')),
      );
    } else {
      // PUT THE TEXT FROM EACH OF THE `TextEditingController`s BACK IN THE TEST MODEL
      // BEFORE UPLOADING IT:
      for (final (int questionIndex, QuestionEditingControllers questionEditingControllers) in questionEditingControllers.indexed) {
        final Question question = _testModel.questions[questionIndex];

        question.question = questionEditingControllers.questionEditingController.text;

        for (final (int answerIndex, TextEditingController answerEditingController) in questionEditingControllers.answerEditingControllers.indexed) {
          question.answers[answerIndex] = answerEditingController.text;
        }
      }

      // SAVE TEST
      String saveTestResult = await saveTest(_testModel);

      // DISPLAY TEST SAVING RESULTS
      if (saveTestResult != 'Ok') {
        if (!(context.mounted)) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving test: $saveTestResult')),
        );
        return;
      }

      String saveResultMessage = 'Test saved successfully!';

      // SAVE TEST'S IMAGES

      if (_testImage != null) {
        // Can't promote non-final fields
        try {
          await uploadTestImage(_testModel.id!, _testImage!);
          print("UPLOADED TEST ${_testModel.id}'s IMAGE SUCCESSFULLLY!");
        } on FirebaseException catch (error) {
          saveResultMessage = 'Error saving test image: ${error.message ?? error.code}';
        } catch (error) {
          saveResultMessage = 'Error saving test image: $error';
        }
      }

      for (final (int index, Uint8List? questionImage) in _questionImages.indexed) {
        if (questionImage == null) continue;

        try {
          await uploadQuestionImage(_testModel.id!, index, questionImage);
          print("UPLOADED TEST ${_testModel.id}'s QUESTION #$index's IMAGE SUCCESSFULLLY!");
        } on FirebaseException catch (error) {
          saveResultMessage = "Error saving question $index's image: ${error.message ?? error.code}";
        } catch (error) {
          saveResultMessage = "Error saving question $index's image: $error";
        }
      }

      // DISPLAY TEST IMAGES UPLOADING RESULTS
      if (!(context.mounted)) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(saveResultMessage)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_downloadedImages) {
      _downloadImages();
    }

    final List<Widget> sidePanelWithSlidePreviews = [
      ImageEditor(
        imageData: _testImage,
        asyncOnChange: (Uint8List newImage) {
          if (!mounted) return;

          setState(() {
            _testImage = newImage;
          });
        },
        asyncOnImageNotRecieved: () {
          if (!(context.mounted)) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image not recieved!')),
          );
        },
      ),
    ];

    for (final (int index, Question question) in _testModel.questions.indexed) {
      sidePanelWithSlidePreviews.add(
        InkWell(
          onTap: () => setState(() {
            // `index` should be within the index bounds of `testModel.questions`,
            // so `_currentSlideIndex` should also be, after this `setState` call.
            _currentSlideIndex = index;
          }),
          child: SlidePreview(
            questionIndex: index,
            question: question,
            questionImage: _questionImages[index],
          ),
        ),
      );
    }

    /*
      Add an `AddSlideButton` at the bottom of the `slidePreviews` `List<Widget>`.
      When pressed, it should add a new (EMPTY) question to `testModel.questions`,
      add a new null image to `_questionImages`,
      and automatically change `_currentSlideIndex` to the index of this new `Question`.

      This means that pressing this `AddSlideButton` will automatically jump to the last
      slide, where the user SHOULD be able to edit the last question.
    */
    sidePanelWithSlidePreviews.add(
      AddSlideButton(
        onPressed: () {
          setState(() {
            _testModel.addNewEmptyQuestion();
            _questionImages.add(null);
            _currentSlideIndex = _testModel.questions.length - 1;
          });
        },
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: testNameEditingController,
          cursorColor: white,
          decoration: const InputDecoration(
            hintText: 'Title',
          ),
        ),
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
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: ListView(
              children: sidePanelWithSlidePreviews,
            ),
          ),
          // `_currentSlideIndex` may be out of the range of the list.
          // In the case that it is,
          // the `AddSlideButton` "slide" will be displayed instead.
          (
            _currentSlideIndex < 0 || _currentSlideIndex >= _testModel.questions.length
            ? const Center(child: Text('No questions yet!'))
            : Expanded(
              child: SlideEditor(
                questionModel: _testModel.questions[_currentSlideIndex],
                questionEditingController: questionEditingControllers[_currentSlideIndex].questionEditingController,
                answerEditingControllers: questionEditingControllers[_currentSlideIndex].answerEditingControllers,
                questionImageEditor: ImageEditor(
                  imageData: _questionImages[_currentSlideIndex],
                  asyncOnChange: (Uint8List newImage) {
                    if (!(context.mounted)) return;

                    setState(() {
                      _questionImages[_currentSlideIndex] = newImage;
                    });
                  },
                  asyncOnImageNotRecieved: () {
                    if (!(context.mounted)) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Question's image not recieved!")),
                    );
                  },
                ),
                addNewEmptyAnswer: () => setState(() {
                  _testModel.addNewEmptyAnswer(_currentSlideIndex);
                }),
                setCorrectAnswer: (int index) => setState(() {
                  _testModel.setCorrectAnswer(_currentSlideIndex, index);
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
