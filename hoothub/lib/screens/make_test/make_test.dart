/// Every child Widget that edits the Test requests callbacks that actually mutate the state,
/// at the top widget: `MakeTest`.
library;

// backend
import 'package:firebase_core/firebase_core.dart';
import 'package:hoothub/firebase/models/test.dart';
import 'package:hoothub/firebase/api/tests.dart';
import 'package:hoothub/firebase/api/images.dart';
// frontend
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:hoothub/screens/make_test/editors.dart';
import 'package:hoothub/screens/make_test/image_editor.dart';
import 'package:hoothub/screens/make_test/slide_editor.dart';
import 'package:hoothub/screens/make_test/slide_preview.dart';
import 'package:hoothub/screens/styles.dart';
import 'package:hoothub/screens/widgets/info_downloader.dart';

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

class _MakeTestState extends State<MakeTest> {
  // default index. May not be in the bounds of `testModel!.questions`,
  // since that could be empty!
  late int _currentSlideIndex;
  late TestModelEditor _testModel;

  @override
  void initState() {
    super.initState();
    _currentSlideIndex = 0;
    _testModel = TestModelEditor.fromTest(widget.testModel);
  }

  /// Tries to save the test and the image.
  ///
  /// If something seems to go wrong, tries to spawn a `SnackBar`
  /// with the error.
  ///
  /// TODO: UPLOAD THE IMAGES TO THEIR CORRECT SLOTS IN CLOUD STORAGE AS WELL!
  Future<void> _onTestSaved(BuildContext context) async {
    Test testModel = _testModel.toTest();

    if (!(testModel.isValid()) && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid Test!')),
      );
    } else {
      // SAVE TEST

      // THIS SHOULD GIVE `testModel` A NON-NULL `id` FIELD!
      String saveTestResult = await saveTest(testModel);

      // DISPLAY ERRORS SAVING TEST, IF ANY:
      if (saveTestResult != 'Ok') {
        if (!(context.mounted)) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving test: $saveTestResult')),
        );
        return;
      }

      String saveResultMessage = 'Test saved successfully!';

      // SAVE TEST'S IMAGES

      // Need `_testModel` for the test's image
      Uint8List? testImage = await _testModel.image;

      if (testImage != null) {
        // Can't promote non-final fields
        try {
          // Need `testModel`, NOT `_testModel` FOR THE TEST'S ID.
          //
          // `testModel` SHOULD NOW HAVE AN `id` FIELD.
          // IF IT DOESN'T, THE ERROR MESSAGE WILL CATCH THE ERROR:
          await uploadTestImage(testModel.id!, testImage);
          debugPrint("UPLOADED TEST ${testModel.id}'s IMAGE SUCCESSFULLLY!");
        } on FirebaseException catch (error) {
          saveResultMessage = 'Error saving test image: ${error.message ?? error.code}';
        } catch (error) {
          saveResultMessage = 'Error saving test image: $error';
        }
      }

      // Need `_testModel.questionModelEditors` for the questions' images
      for (final (int index, QuestionModelEditor questionModelEditor) in _testModel.questionModelEditors.indexed) {
        final Uint8List? questionImage = await questionModelEditor.image;

        if (questionImage == null) continue;

        try {
          // Need `testModel`, NOT `_testModel` FOR THE TEST'S ID.
          //
          // `testModel` SHOULD NOW HAVE AN `id` FIELD.
          // IF IT DOESN'T, THE ERROR MESSAGE WILL CATCH THE ERROR:
          await uploadQuestionImage(testModel.id!, index, questionImage);
          debugPrint("UPLOADED TEST ${testModel.id}'s QUESTION #$index's IMAGE SUCCESSFULLLY!");
        } on FirebaseException catch (error) {
          saveResultMessage = "Error saving question $index's image: ${error.message ?? error.code}";
        } catch (error) {
          saveResultMessage = "Error saving question $index's image: $error";
        }
      }

      // DISPLAY TEST UPLOADING RESULTS:

      if (!(context.mounted)) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(saveResultMessage)),
      );

      // `testModel` SHOULD NOW HAVE ITS `id` AND OTHER FIELDS,
      // BECAUSE IT WAS UPLOADED BY `saveTest`.
      // NOW, WE HAVE TO UPDATE `_testModel` WITH IT:
      //
      // IF WE DON'T, AND THE PLAYER SAVES THIS TEST AGAIN,
      // AND THIS TEST IS A NEW TEST,
      // SINCE THE `_testModel` DOESN'T YET HAVE AN `id`,
      // IT WILL BE SAVED TWICE TO CLOUD FIRESTORE.

      if (!mounted) return;

      setState(() {
        _testModel = TestModelEditor.fromTest(testModel);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> sidePanelWithSlidePreviews = <Widget>[
      InfoDownloader(
        downloadInfo: () => _testModel.image,
        builder: (BuildContext context, Uint8List? result, bool downloaded) {
          return ImageEditor(
            imageData: result,
            asyncOnChange: (Uint8List newImage) {
              if (!mounted) return;

              setState(() {
                _testModel.image = Future<Uint8List?>.value(newImage);
              });
            },
            asyncOnImageNotRecieved: () {
              if (!(context.mounted)) return;

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Image not recieved!')),
              );
            },
          );
        },
        buildError: (BuildContext context, Object error) {
          return Text("Error building test ${_testModel.id}'s image: $error");
        },
      ),
    ];

    for (final (int index, QuestionModelEditor question) in _testModel.questionModelEditors.indexed) {
      sidePanelWithSlidePreviews.add(
        InkWell(
          onTap: () => setState(() {
            // `index` should be within the index bounds of `testModel.questions`,
            // so `_currentSlideIndex` should also be, after this `setState` call.
            // So, this assignment is valid.
            _currentSlideIndex = index;
          }),
          child: SlidePreview(
            questionIndex: index,
            // TODO: HOW TO REFRESH DISPLAYED QUESTION WHEN THE USER EDITS IT?
            question: question.questionEditingController.text, 
            questionImage: question.image,
            deleteQuestion: () => setState(() {
              _testModel.deleteQuestion(_currentSlideIndex);
            }),
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
            _currentSlideIndex = _testModel.questionModelEditors.length - 1;
          });
        },
      ),
    );

    final Widget currentSlideEditor = (
      // `_currentSlideIndex` may be out of the range of the list.
      // In the case that it is,
      // the `AddSlideButton` "slide" will be displayed instead.
      _currentSlideIndex < 0 || _currentSlideIndex >= _testModel.questionModelEditors.length
      ? const Center(child: Text('No questions yet!'))
      : Expanded(
        child: SlideEditor(
          questionModelEditor: _testModel.questionModelEditors[_currentSlideIndex],
          questionImageEditor: InfoDownloader<Uint8List>(
            downloadInfo: () => _testModel.questionModelEditors[_currentSlideIndex].image,
            builder: (BuildContext context, Uint8List? result, bool downloaded) {
              return ImageEditor(
                imageData: result,
                asyncOnChange: (Uint8List newImage) {
                  if (!mounted) return;

                  setState(() {
                    _testModel.questionModelEditors[_currentSlideIndex].image = Future<Uint8List?>.value(newImage);
                  });
                },
                asyncOnImageNotRecieved: () {
                  // TODO: I MEANT THE OUTER CONTEXT, THE CONTEXT FROM `_MakeTestState#build`!
                  // PLEASE CHECK IF USING THIS BUILDER'S CONTEXT AFFECTS ANYTHING,
                  // AND IF I MUST USE THE OUTER ONE INSTEAD!
                  if (!(context.mounted)) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Question's image not recieved!")),
                  );
                },
              );
            },
            buildError: (BuildContext context, Object error) {
              return Text("Error loading and displaying question #$_currentSlideIndex's image editor: $error");
            },
          ),
          deleteQuestion: () => setState(() {
            _testModel.deleteQuestion(_currentSlideIndex);
          }),
          addNewEmptyAnswer: () => setState(() {
            _testModel.addNewEmptyAnswer(_currentSlideIndex);
          }),
          deleteAnswer: (int answerIndex) => setState(() {
            _testModel.deleteAnswer(_currentSlideIndex, answerIndex);
          }),
          setCorrectAnswer: (int answerIndex) => setState(() {
            _testModel.setCorrectAnswer(_currentSlideIndex, answerIndex);
          }),
          setSecondsDuration: (int secondsDuration) => setState(() {
            _testModel.setSecondsDuration(_currentSlideIndex, secondsDuration);
          }),
        ),
      )
    );

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _testModel.nameEditingController,
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
          currentSlideEditor,
        ],
      ),
    );
  }
}
