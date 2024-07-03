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
import 'editors.dart';
import 'slide_editor.dart';
import 'slide_preview.dart';
import 'package:hoothub/screens/styles.dart';
import 'package:hoothub/screens/widgets/image_editor.dart';
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

  @override
  void initState() {
    super.initState();
    _currentSlideIndex = 0;
    _latestVersion = widget.testModel;
    _testModelEditor = TestModelEditor.fromTest(_latestVersion);
  }

  /// First, awaits `_testModelEditor`.
  ///
  /// If `_testModelEditor` is equal to `_latestVersion`,
  /// this function just pops this route with `_latestVersion`
  /// as the result.
  ///
  /// If `_testModelEditor` has changes that are not saved in `_latestVersion`,
  /// this method spanws a pop-up that asks the user
  /// to 'Save and exit', 'Exit' or 'Cancel'.
  ///
  /// 'Save and exit' uploads `_testModelEditor` using `_uploadTest`,
  ///   then pops this route with the `Test` returned by `_uploadTest`, as the result.
  /// 'Exit' pops this route with `_latestVersion`,
  ///   WHICH DOESN'T HAVE THE CHANGES IN `_testModelEditor`.
  /// 'Cancel' just returns from this function without doing anything else,
  ///   sending the user back to editing.
  void _onExit(BuildContext context) async {
    TestModelEditor testModelEditor = await _testModelEditor;

    bool allChangesSaved = testModelEditor.toTest().equals(_latestVersion);

    if (allChangesSaved) {
      if (!(context.mounted)) return;

      Navigator.pop<Test>(context, _latestVersion);
      return;
    }

    bool? willSave = false;

    if (!(context.mounted)) return;

    willSave = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
        builder: (BuildContext context) => AlertDialog(
          title: const Text('You have unsaved changes!'),
          content: const Text('Save changes?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop<bool>(context, true),
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () => Navigator.pop<bool>(context, false),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.pop<bool>(context, null),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );

    // null means 'Cancel', or something else must have happened...
    //
    // unmounted context means the player must have somehow destroyed
    // `MakeTest` before this line happened.
    if (willSave == null || !(context.mounted)) return;

    if (willSave) {
      final (String _, Test savedTestModel) = await _uploadTest(testModelEditor);

      if (!(context.mounted)) return;

      Navigator.pop<Test>(context, savedTestModel);
    } else {
      Navigator.pop<Test>(context, _latestVersion);
    }
  }

  /// Tries to upload `testModelEditor`, in its `Test` form,
  /// to Cloud Firestore.
  /// tries to upload `testModelEditor`'s images to Cloud Storage.
  ///
  /// Returns the status string for the upload,
  /// and a new, updated version of `TestModelEditor` AS A `Test`,
  /// with the changes returned by `saveTest`.
  Future<(String, Test)> _uploadTest(TestModelEditor testModelEditor) async {
    Test testModel = testModelEditor.toTest();

    SaveTestResult? saveTestResult;

    String status = 'Test saved successfully!';

    if (!(testModel.isValid())) {
      status = 'Invalid Test!';
    } else {
      // SAVE TEST
      saveTestResult = await saveTest(testModel);

      // SAVE TEST'S IMAGES
      String? saveTestResultTestId = saveTestResult.updatedTest.id;

      if (saveTestResultTestId == null) {
        status = "Could not upload test's images: cannot get test's ID!";
      } else {
        String updateTestImagesStatus = await updateTestImages(
          saveTestResultTestId,
          testModelEditor.image,
          List<Uint8List?>.of(
            testModelEditor.questionModelEditors.map<Uint8List?>(
              (QuestionModelEditor questionModelEditor) => questionModelEditor.image,
            ),
          ),
        );

        if (updateTestImagesStatus != "Ok") {
          status = updateTestImagesStatus;
        }
      }
    }

    return (status, saveTestResult?.updatedTest ?? testModel);
  }

  /// Tries to upload `testModelEditor` through `_uploadTest`.
  ///
  /// If `context` is still mounted, tries to spawn a `SnackBar`
  /// with the upload's status.
  ///
  /// If this widget is still mounted, this method also
  /// updates `_latestVersion` and `_testModelEditor` to be
  /// the `Test` returned from `_uploadTest`,
  /// and set `_allChangesSaved: true`.
  Future<void> _onTestSaved(BuildContext context, TestModelEditor testModelEditor) async {
    // UPLOAD TEST INFORMATION:
    final (String status, Test updatedTest) = await _uploadTest(testModelEditor);

    // DISPLAY TEST UPLOADING RESULTS:
    if (!(context.mounted)) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(status)),
    );

    // [OUTDATED COMMENT?]
    //
    //`saveTestResult.updatedTest`, IF IT WAS DEFINED, MAY NOW HAVE ITS OPTIONAL FIELDS,
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
      _latestVersion = updatedTest;
      _testModelEditor = TestModelEditor.fromTest(updatedTest);
    });
  }

  @override
  Widget build(BuildContext outerContext) {
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
                  onPressed: () => _onExit(outerContext),
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

        const sidePanelConstraints = BoxConstraints(maxWidth: 400);

        final List<Widget> sidePanelWithSlidePreviews = <Widget>[
          ImageEditor(
            imageData: testModelEditor.image,
            defaultImage: Image.asset('assets/default_image.png'),
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
            onDelete: () => setState(() {
              testModelEditor.image = null;
            }),
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
                defaultImage: Image.asset('assets/default_image.png'),
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
                onDelete: () => setState(() {
                  testModelEditor.questionModelEditors[_currentSlideIndex].image = null;
                }),
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
                onPressed: () => _onExit(outerContext),
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
                constraints: sidePanelConstraints,
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
                onPressed: () => _onExit(outerContext),
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
