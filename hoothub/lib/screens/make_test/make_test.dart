// backend
import 'package:hoothub/firebase/models/test.dart';
import 'package:hoothub/firebase/models/question.dart';
// frontend
import 'package:flutter/material.dart';
import 'package:hoothub/screens/make_test/slide_editor.dart';
import 'slide_preview.dart';

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
  /*
    default index. May not be in the bounds of `widget.testModel.questions`,
    since that could be empty!
  */
  int _currentSlideIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> slidePreviews = [];

    for (final (int index, Question question) in widget.testModel.questions.indexed) {
      slidePreviews.add(
        IconButton(
          onPressed: () => setState(() {
            /*
              `index` should be within the index bounds of `widget.testModel.questions`,
              so `_currentSlideIndex` should also be, after this `setState` call.
            */
            _currentSlideIndex = index;
          }),
          icon: const SlidePreview(),
        ),
      );
    }

    slidePreviews.add(const AddSlideButton());

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.testModel.name),
        actions: <Widget>[
          ElevatedButton(onPressed: () { }, child: const Text('Cancel')),
          ElevatedButton(onPressed: () { }, child: const Text('Save')),
        ],
      ),
      body: Row(
        children: <Widget>[
          Column(
            children: slidePreviews,
          ),
          /*
            `_currentSlideIndex` may be out of the range of the list.
            In the case that it is, it will 
          */
          (
            _currentSlideIndex < 0 || _currentSlideIndex >= widget.testModel.questions.length
            ? const AddSlideButton()
            : SlideEditor(question: widget.testModel.questions[_currentSlideIndex])
          ),
        ],
      ),
    );
  }
}
