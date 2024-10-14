import 'package:bd_manager/local/db_helper.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> allNotes = [];
  DBHelper? dbRef;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    dbRef = DBHelper.getInstance;
    getNotes();
  }

  void getNotes() async {
    allNotes = await dbRef!.getAllNotes();
    setState(() {});
  }

  //controllers
  TextEditingController titleConroller = TextEditingController();
  TextEditingController descConroller = TextEditingController();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Arman DB"),
      ),

      // all notes viewed here
      body: allNotes.isNotEmpty // Show ListView.builder when there are notes
          ? ListView.builder(
              itemCount: allNotes.length,
              itemBuilder: (_, index) {
                return ListTile(
                  // leading: Text("${allNotes[index][DBHelper.COLUMN_NOTE_SNO]}"),
                  leading: Text("${index + 1}"),
                  title: Text(allNotes[index][DBHelper.COLUMN_NOTE_TITLE]),
                  subtitle: Text(allNotes[index][DBHelper.COLUMN_NOTE_DESC]),
                  trailing: SizedBox(
                    width: 55,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () {
                            showMaterialModalBottomSheet(
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(35),
                                    topRight: Radius.circular(35),
                                  ),
                                ),
                                context: context,
                                builder: (context) {
                                  titleConroller.text = allNotes[index][DBHelper.COLUMN_NOTE_TITLE];
                                  descConroller.text = allNotes[index][DBHelper.COLUMN_NOTE_DESC];
                                  return getBottomSheetWidget(isUpdate: true, sno: allNotes[index][DBHelper.COLUMN_NOTE_SNO]);
                                });
                          },
                            child: const Icon(Icons.edit)),
                        InkWell(
                            onTap: () async {
                              bool check = await dbRef!.deleteNote(sno: allNotes[index][DBHelper.COLUMN_NOTE_SNO]);
                              if(check) {
                                getNotes();
                              }
                            },
                            child: Icon(Icons.delete, color: Colors.red)),
                      ],
                    ),
                  ),
                );
              })
          : const Center(
              // Show this message when there are no notes
              child: Text("No Notes Yet!!"),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          //todo: note to be added from here
          /*bool check = await dbRef!.addNote(mTitle: "Personal Fav note",
            mDesc: "Do What you love or love what you do.");
        if (check) {
          getNotes();
        }*/

          showMaterialModalBottomSheet(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(35),
                  topRight: Radius.circular(35),
                ),
              ),
              context: context,
              builder: (context) {
                titleConroller.clear();
                descConroller.clear();
                return getBottomSheetWidget();
              });
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget getBottomSheetWidget({bool isUpdate = false, int sno = 0}) {
    return Container(
      padding: const EdgeInsets.all(12),
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.50,
      decoration: const BoxDecoration(
        // color: kPinksColor.withOpacity(0.1),
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30))),
      child: Column(
        children: [
          Text(isUpdate ? "Update Note" : "Add Note",
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 21),
          TextField(
            controller: titleConroller,
            decoration: InputDecoration(
                hintText: "Enter title here",
                label: const Text("Title *"),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(11),
                )),
          ),
          const SizedBox(height: 11),
          TextField(
            controller: descConroller,
            maxLines: 4,
            decoration: InputDecoration(
                hintText: "Enter Description here",
                label: const Text("Desc *"),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(11),
                )),
          ),
          const SizedBox(height: 11),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                          side: const BorderSide(width: 1),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(11))),
                      onPressed: () async {
                        var title = titleConroller.text;
                        var desc = descConroller.text;
                        if (title.isNotEmpty &&
                            desc.isNotEmpty) {
                          bool check = isUpdate ? await dbRef!.updateNote(title: title, desc: desc, sno: sno) : await dbRef!.addNote(mTitle: title, mDesc: desc);
                          if (check) {
                            getNotes();
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("* Please fill all the required blanks")));
                        }
                        Navigator.pop(context);
                      },
                      child: Text(isUpdate ? "Update Note" : "Add Note"))),
              const SizedBox(width: 10),
              Expanded(
                  child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                          side: const BorderSide(width: 1),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(11))),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Cancel"))),

            ],
          )
        ],
      ),
    );
  }

}
