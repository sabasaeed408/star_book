import 'package:flutter/cupertino.dart' as c;
import 'package:flutter/widgets.dart';
// Files
import '../routes/route_generator.dart';
import '../widgets/action_container.dart';
import '../models/activity.dart';
import '../widgets/my_container.dart';
import '../controllers/activity.dart';

class ActivityEditSheetRouteInitializer extends StatelessWidget {
  ActivityEditSheetRouteInitializer(this.activity);

  final Activity activity;

  Future<bool> _handlePopScope(BuildContext context) async {
    bool shouldClose = false;
    await c.showCupertinoModalPopup(
      context: context,
      builder: (context) => c.CupertinoActionSheet(
        actions: [
          c.CupertinoActionSheetAction(
            onPressed: () {
              shouldClose = true;
              Navigator.of(context).pop();
            },
            child: Text("Discard Changes"),
            isDestructiveAction: true,
          ),
        ],
        cancelButton: c.CupertinoActionSheetAction(
          onPressed: () {
            shouldClose = false;
            Navigator.of(context).pop();
          },
          child: Text("Cancel"),
        ),
      ),
    );
    return shouldClose;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _handlePopScope(context),
      child: Navigator(
        initialRoute: 'edit/title',
        onGenerateRoute: (settings) =>
            RouteGenerator.activityRoute(settings, activity),
      ),
    );
  }
}

class ActivityEditSheet extends c.StatefulWidget {
  ActivityEditSheet(this.activity);

  final Activity activity;

  @override
  _ActivityEditSheetState createState() => _ActivityEditSheetState();
}

class _ActivityEditSheetState extends c.State<ActivityEditSheet> {
  Activity activity;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    activity = Activity.from(widget.activity);
    titleController.text = activity.title;
    noteController.text = activity.note;
    titleController.addListener(onTitleChange);
    noteController.addListener(onNoteChange);
  }

  void onTitleChange() {
    this.activity.title = titleController.text;
  }

  void onNoteChange() {
    this.activity.note = noteController.text;
  }

  void onDone(BuildContext context) async {
    if (activity.isFilled()) {
      ActivityController.update(activity);
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  Widget _buildNavBar(BuildContext context) {
    return c.CupertinoNavigationBar(
      leading: Container(),
      middle: Text("Add/Edit"),
      trailing: GestureDetector(
        onTap: () => onDone(context),
        child: Text("Done"),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return c.SingleChildScrollView(
      child: SafeArea(
        child: c.Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(padding: EdgeInsets.symmetric(vertical: 18)),
            MyContainer(
              child: c.Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Date"),
                  Text(
                      "${activity.day.toString()} / ${activity.month.toString()} / ${activity.year.toString()}"),
                ],
              ),
              onTap: null,
            ),
            Padding(padding: EdgeInsets.symmetric(vertical: 8)),
            ActionContainer(
              text: "Mood",
              icon: c.CupertinoIcons.right_chevron,
              onTap: () async {
                dynamic moodId =
                    await Navigator.of(context).pushNamed("edit/mood");
                activity.moodId = moodId;
              },
            ),
            Padding(padding: EdgeInsets.symmetric(vertical: 8)),
            MyContainer(
              child: c.CupertinoTextField(
                controller: titleController,
                placeholder: "Title",
                decoration: null,
                maxLines: 1,
                onTap: null,
              ),
            ),
            Padding(padding: EdgeInsets.symmetric(vertical: 8)),
            MyContainer(
              child: c.CupertinoTextField(
                controller: noteController,
                placeholder: "Note",
                decoration: null,
                maxLines: null,
                minLines: 4,
                keyboardType: TextInputType.multiline,
                onTap: null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return c.CupertinoPageScaffold(
      backgroundColor: c.CupertinoDynamicColor.resolve(
        c.CupertinoColors.systemGroupedBackground,
        context,
      ),
      navigationBar: _buildNavBar(context),
      child: _buildBody(context),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    noteController.dispose();
    super.dispose();
  }
}
