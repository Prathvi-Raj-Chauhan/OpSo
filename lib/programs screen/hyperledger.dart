import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:opso/modals/book_mark_model.dart';
import 'package:opso/modals/hyperledger_modal.dart';
import 'package:opso/programs_info_pages/hyperledger_info.dart';
import 'package:opso/services/FirestoreService.dart';
import 'package:opso/widgets/hyperledger_widget.dart';
import 'package:opso/widgets/year_button.dart';

class Hyperledger extends StatefulWidget {
  const Hyperledger({super.key});

  @override
  _HyperledgerState createState() => _HyperledgerState();
}

class _HyperledgerState extends State<Hyperledger> {
  String currectPage = "/hyperledger";
  String currentProject = "Hyperledger";
  bool isBookmarked = true;
  int selectedYear = 2024;
  List<int> yearList = [2021,2022,2023,2024];
  List<HyperledgerProjectModal> projectList = [];
  late Future<void> getProjectFunction;

  Future<void> initializeProjectLists() async {
    final data = await FirestoreService().getHyperledgerProjects(selectedYear);
    setState(() {
      projectList = data;
    });
  }

  @override
  void initState() {
    super.initState();
    getProjectFunction = initializeProjectLists();
    _checkBookmarkStatus();
  }

  Future<void> _checkBookmarkStatus() async {
    bool bookmarkStatus = await HandleBookmark.isBookmarked(currentProject);
    setState(() {
      isBookmarked = bookmarkStatus;
    });
  }

  void searchTag(String searchTag) {
    projectList = projectList
        .where((element) => element.name.toLowerCase().contains(searchTag))
        .toList();
    setState(() {});
  }

  void search(String searchText) {
    if (searchText.isEmpty) {
      
      initializeProjectLists(); // resets the project list according to the selected year
      
      return;
    }
    searchText = searchText.toLowerCase();
    projectList = projectList
        .where((element) =>
            element.name.toLowerCase().contains(searchText) ||
            element.mentors.contains(searchText))
        .toList();
    setState(() {});
  }

  Future<void> _refresh() async {
    await initializeProjectLists();

    setState(() {});
  }
  Future<void> _onYearChanged(int year) async {
    setState(() {
      selectedYear = year;
      projectList = [];
    });
    final data = await FirestoreService().getHyperledgerProjects(year);
    setState(() {
      projectList = data;
    });
  }


  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: Scaffold(
        appBar: AppBar(
           leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
         
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
          title: const Text('Hyperledger'),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                isBookmarked
                    ? Icons.bookmark_add_rounded
                    : Icons.bookmark_add_outlined,
              ),
              onPressed: () {
                setState(() {
                  isBookmarked = !isBookmarked;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isBookmarked ? 'Bookmark added' : 'Bookmark removed',
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
                if (isBookmarked) {
                  HandleBookmark.addBookmark(currentProject, currectPage);
                } else {
                  HandleBookmark.deleteBookmark(currentProject);
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const HYPERLEDGERInfo()),
                );
              },
            ),
          ],
        ),
        body: FutureBuilder<void>(
          future: getProjectFunction,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } else if (snapshot.connectionState == ConnectionState.done) {
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 46, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        decoration: InputDecoration(
                          filled: true,
                          hintText: 'Search',
                          suffixIcon: const Icon(Icons.search),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                const BorderSide(color: Color(0xFFEEEEEE)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                const BorderSide(color: Color(0xFFEEEEEE)),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                const BorderSide(color: Color(0xFFEEEEEE)),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                const BorderSide(color: Color(0xFFEEEEEE)),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: ScreenUtil().setHeight(12),
                            horizontal: ScreenUtil().setWidth(20),
                          ),
                        ),
                        onFieldSubmitted: (value) {
                          search(value.trim());
                        },
                        onChanged: (value) {
                          if (value.isEmpty) {
                            search(value);
                          }
                        },
                      ),
                      SizedBox(height: ScreenUtil().setHeight(20)),
                      Container(
                          constraints: BoxConstraints(
                            maxHeight: MediaQuery.sizeOf(context).height * 0.2,
                          ),
                          width: MediaQuery.sizeOf(context).width,
                          child: GridView(
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 1.5 / 0.6,
                              crossAxisSpacing: 15,
                              mainAxisSpacing: 15,
                            ),
                            children: [
                              ...yearList.map((year) => YearButton(
                                  year: year.toString(),
                                  isEnabled: year == selectedYear,
                                  onTap : (){
                                    _onYearChanged(year);
                                  },
                                  backgroundColor: selectedYear == year
                                    ? Colors.white
                                    : const Color.fromRGBO(255, 183, 77, 1),
                                )
                              ),
                              
                              
                            ],
                          )),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: projectList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: HyperledgerProjectWidget(
                              modal: projectList[index],
                              height: ScreenUtil().screenHeight * 0.2,
                              width: ScreenUtil().screenWidth,
                              index: index + 1,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return const Center(child: Text("Some error occurred"));
            }
          },
        ),
      ),
    );
  }
}