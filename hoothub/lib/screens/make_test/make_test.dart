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

/// Edits `testModel`, saves it to Cloud Firestore,
/// THEN POPS ITS ROUTE with type `Test?`:
/// either the `testModel`, with the changes the user made to it,
/// or null, meaning the user didn't make any changes to `testModel`.
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
  late int _currentSlideIndex;

  late Test _latestVersion;
  late Future<TestModelEditor> _testModelEditor;
  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    _currentSlideIndex = 0;
    _latestVersion = widget.testModel;
    _testModelEditor = TestModelEditor.fromTest(_latestVersion);
  }

  void _onExit() {
    print('EXITING!!!!');
    // TODO: ASK USER IF THEY WANT TO SAVE CHANGES
    Navigator.pop<Test>(context, null);
  }

  /// Tries to save the test and the image.
  ///
  /// If something seems to go wrong, tries to spawn a `SnackBar`
  /// with the error.
  ///
  /// TODO: UPLOAD THE IMAGES TO THEIR CORRECT SLOTS IN CLOUD STORAGE AS WELL!
  Future<void> _onTestSaved(BuildContext context, TestModelEditor testModelEditor) async {
    Test testModel = testModelEditor.toTest();
    SaveTestResult? saveTestResult;

    // TODO: SAVE `testModel` EVEN IF IT'S INVALID

    if (!(testModel.isValid()) && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid Test!')),
      );
    } else {
      // SAVE TEST

      saveTestResult = await saveTest(testModel);

      // saveTestResult.updatedTest.id != null

      // DISPLAY ERRORS SAVING TEST, IF ANY:
      if (saveTestResult.status != 'Ok') {
        if (!(context.mounted)) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving test: ${saveTestResult.status}')),
        );
        return;
      }

      String saveResultMessage = 'Test saved successfully!';

      // SAVE TEST'S IMAGES

      // Need `testModelEditor` for the test's image
      Uint8List? testImage = testModelEditor.image;

      if (testImage != null) {
        // Can't promote non-final fields
        try {
          // If `saveTestResult.updatedTest.id` is null, the error will handle it:
          await uploadTestImage(saveTestResult.updatedTest.id!, testImage);
          debugPrint("UPLOADED TEST ${saveTestResult.updatedTest.id}'s IMAGE SUCCESSFULLLY!");
        } on FirebaseException catch (error) {
          saveResultMessage = 'Error saving test image: ${error.message ?? error.code}';
        } catch (error) {
          saveResultMessage = 'Error saving test image: $error';
        }
      }

      // Need `testModelEditor.questionModelEditors` for the questions' images
      for (final (int index, QuestionModelEditor questionModelEditor) in testModelEditor.questionModelEditors.indexed) {
        final Uint8List? questionImage = questionModelEditor.image;

        if (questionImage == null) continue;

        try {
          // If `saveTestResult.updatedTest.id` is null, the error will handle it:
          await uploadQuestionImage(saveTestResult.updatedTest.id!, index, questionImage);
          debugPrint("UPLOADED TEST ${saveTestResult.updatedTest.id}'s QUESTION #$index's IMAGE SUCCESSFULLLY!");
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
    }

    // `saveTestResult.updatedTest`, IF IT WAS DEFINED, MAY NOW HAVE ITS OPTIONAL FIELDS,
    // INCLUDING `id`.
    //
    // WE MUST SAVE `saveTestResult.updatedTest` TO `_latestVersion` AND `_testModelEditor`,
    // SO THAT IF THE USER SAVES THE TEST AGAIN, THE TEST WON'T BE DUPLICATED IN CLOUD FIRESTORE,
    // OR OTHER ERRORS.
    //
    // If `saveTestResult` is null, we'll re-assign `_latestVersion` and `_testModelEditor`
    // to it instead, for a just-in-case reset.

    if (!mounted) return;

    setState(() {
      _latestVersion = saveTestResult != null ? saveTestResult.updatedTest : testModel;
      _testModelEditor = TestModelEditor.fromTest(saveTestResult != null ? saveTestResult.updatedTest : testModel);
      _hasUnsavedChanges = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return InfoDownloader<TestModelEditor>(
      downloadInfo: () => _testModelEditor,
      builder: (BuildContext context, TestModelEditor? testModelEditor, bool downloaded) {
        // IN THIS FUNCTION, WE CHANGE FIELDS INSIDE `_testModel`,
        // BY CHANGING `testModel`. THEY SHOULD BOTH BE THE SAME INSTANCE IN MEMORY.
        //
        // IF `downloaded: true`, THEN `_testModel` SHOULD HAVE COMPLETED,
        // AND WE COULD ACCESS AND MODIFY THE FIELDS IN `_testModel`,
        // BUT TYPE-CASTING `_testModel` to `TestModelEditor` EVERYWHERE
        // OR DEFINING ANOTHER VARIABLE IN THIS CALLBACK TO POINT
        // TO `_testModel as TestModelEditor` WOULD BE REDUNDANT.

        if (testModelEditor == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('HootHub'),
              actions: <Widget>[
                ElevatedButton(
                  onPressed: _onExit,
                  child: const Text('Exit'),
                ),
              ],
            ),
            body: Center(
              child: Text(
                (
                  downloaded
                  ? "Oops! The test's model editor didn't load!"
                  : "Loading..."
                ),
              ),
            ),
          );
        }

        final List<Widget> sidePanelWithSlidePreviews = <Widget>[
          ImageEditor(
            imageData: testModelEditor.image,
            asyncOnChange: (Uint8List newImage) {
              if (!mounted) return;

              setState(() {
                testModelEditor.image = newImage;
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

        for (final (int index, QuestionModelEditor question) in testModelEditor.questionModelEditors.indexed) {
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
                  testModelEditor.deleteQuestion(index);
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
                testModelEditor.addNewEmptyQuestion();
                _currentSlideIndex = testModelEditor.questionModelEditors.length - 1;
              });
            },
          ),
        );

        final Widget currentSlideEditor = (
          // `_currentSlideIndex` may be out of the range of the list.
          // In the case that it is,
          // the `AddSlideButton` "slide" will be displayed instead.
          _currentSlideIndex < 0 || _currentSlideIndex >= testModelEditor.questionModelEditors.length
          ? const Center(child: Text('No questions yet!'))
          : Expanded(
            child: SlideEditor(
              questionModelEditor: testModelEditor.questionModelEditors[_currentSlideIndex],
              questionImageEditor: ImageEditor(
                imageData: testModelEditor.questionModelEditors[_currentSlideIndex].image,
                asyncOnChange: (Uint8List newImage) {
                  if (!mounted) return;

                  setState(() {
                    testModelEditor.questionModelEditors[_currentSlideIndex].image = newImage;
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
              ),
              deleteQuestion: () => setState(() {
                testModelEditor.deleteQuestion(_currentSlideIndex);
              }),
              addNewEmptyAnswer: () => setState(() {
                testModelEditor.addNewEmptyAnswer(_currentSlideIndex);
              }),
              deleteAnswer: (int answerIndex) => setState(() {
                testModelEditor.deleteAnswer(_currentSlideIndex, answerIndex);
              }),
              setCorrectAnswer: (int answerIndex) => setState(() {
                testModelEditor.setCorrectAnswer(_currentSlideIndex, answerIndex);
              }),
              setSecondsDuration: (int secondsDuration) => setState(() {
                testModelEditor.setSecondsDuration(_currentSlideIndex, secondsDuration);
              }),
            ),
          )
        );

        return Scaffold(
          appBar: AppBar(
            title: TextField(
              controller: testModelEditor.nameEditingController,
              cursorColor: white,
              decoration: const InputDecoration(
                hintText: 'Title',
              ),
            ),
            actions: <Widget>[
              ElevatedButton(
                onPressed: _onExit,
                child: const Text('Exit'),
              ),
              Builder(
                builder: (BuildContext context) =>  ElevatedButton(
                  onPressed: () => _onTestSaved(context, testModelEditor),
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
      },
      buildError: (BuildContext context, Object error) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('HootHub'),
            actions: <Widget>[
              ElevatedButton(
                onPressed: _onExit,
                child: const Text('Exit'),
              ),
            ],
          ),
          body: const Center(child: Text("Oops! There was an error loading the test's model editor!")),
        );
      },
    );
  }
}
