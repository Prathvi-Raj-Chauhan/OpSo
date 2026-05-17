import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:opso/modals/sob_project_modal.dart';
import 'package:opso/programs_info_pages/sob_info.dart';
import 'package:opso/services/FirestoreService.dart';
import 'package:opso/widgets/sob_project_widget.dart';
import 'package:opso/widgets/year_button.dart';

import '../modals/book_mark_model.dart';
import '../widgets/SearchandFilterWidget.dart';

class SummerOfBitcoin extends StatefulWidget {
  const SummerOfBitcoin({super.key});

  @override
  State<SummerOfBitcoin> createState() => _SummerOfBitcoinState();
}

class _SummerOfBitcoinState extends State<SummerOfBitcoin> {
  List<String> selectedOrganizations = [];
  List<String> selectedProposals = ['ALL'];
  String currectPage = "/summer_of_bitcoin";
  String currentProject = "Summer of Bitcoin";
  bool isBookmarked = true;
  int selectedYear = 2023;
  List<int> yearList = [2021, 2022, 2023];

  List<SobProjectModal> projectList = [];
  Future<void>? getProjectFunction;

  Future<void> initializeProjectLists() async {
  final data = await FirestoreService().getSobProjects(selectedYear);
    setState(() {
      projectList = data;
    });
}

  Future<void> _onYearChanged(int year) async {
    setState(() {
      selectedYear = year;
      projectList = [];
    });
    final data = await FirestoreService().getSobProjects(year);
    setState(() {
      projectList = data;
    });
  }

  @override
  void initState() {
    getProjectFunction = initializeProjectLists();
    super.initState();
    _checkBookmarkStatus();
  }

  Future<void> _checkBookmarkStatus() async {
    bool bookmarkStatus = await HandleBookmark.isBookmarked(currentProject);
    setState(() {
      isBookmarked = bookmarkStatus;
    });
  }

  void searchTag(String searchTag) {
    setState(() {
      projectList = projectList
          .where((element) => element.organization.contains(searchTag))
          .toList();
    });
  }

  void search(String searchText) {
    if (searchText.isEmpty) {
      initializeProjectLists();
      return;
    }
    searchText = searchText.toLowerCase();
    setState(() {
      projectList = projectList
          .where((element) =>
              element.name.toLowerCase().contains(searchText) ||
              element.mentor.toLowerCase().contains(searchText) ||
              element.organization.toLowerCase().contains(searchText) ||
              element.description.toLowerCase().contains(searchText) ||
              element.university.toLowerCase().contains(searchText))
          .toList();
    });
  }

  List<String> languages = [
    'ALL',
    'Rust miniscript',
    'Core Lightning',
    'LDK',
    'Bitcoin Core',
    'Alby',
    'Eye of Satoshi',
    'Ledger Bitcoin App',
    'Galoy',
    'Fedimint',
    'VLS',
    'StratumV2',
    'bcoin',
    'LND',
    'Eclair'
  ];

  Future<void> _refresh() async {
    await initializeProjectLists();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.sizeOf(context).height;
    var width = MediaQuery.sizeOf(context).width;
    ScreenUtilInit(designSize: Size(360, 690));
    return RefreshIndicator(
      onRefresh: _refresh,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.of(context).pop(),
          ),
          centerTitle: true,
          title: const Text('Summer of Bitcoin'),
          actions: <Widget>[
            IconButton(
              icon: (isBookmarked)
                  ? const Icon(Icons.bookmark_add_rounded)
                  : const Icon(Icons.bookmark_add_outlined),
              onPressed: () {
                setState(() {
                  isBookmarked = !isBookmarked;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        isBookmarked ? 'Bookmark added' : 'Bookmark removed'),
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
                  MaterialPageRoute(builder: (context) => const SOBInfo()),
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
            } else if (snapshot.connectionState == ConnectionState.done) {
              return Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: ScreenUtil().setWidth(46),
                    vertical: ScreenUtil().setHeight(16)),
                child: SingleChildScrollView(
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
                            borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: ScreenUtil().setHeight(12),
                              horizontal: ScreenUtil().setWidth(20)),
                        ),
                        onFieldSubmitted: (value) => search(value.trim()),
                        onChanged: (value) {
                          if (value.isEmpty) search(value);
                        },
                      ),
                      SizedBox(height: ScreenUtil().setHeight(20)),
                      SizedBox(
                        height: height * 0.2,
                        width: width,
                        child: GridView(
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1.5 / 0.6,
                            crossAxisSpacing: 15,
                            mainAxisSpacing: 15,
                          ),
                          children: yearList
                              .map((year) => YearButton(
                                    year: year.toString(),
                                    isEnabled: selectedYear == year,
                                    onTap: () => _onYearChanged(year),
                                    backgroundColor: selectedYear == year
                                        ? Colors.white
                                        : const Color.fromRGBO(255, 183, 77, 1),
                                  ))
                              .toList(),
                        ),
                      ),
                      SizedBox(height: ScreenUtil().setHeight(20)),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const Text(
                            'Filter by Org:',
                            style: TextStyle(fontWeight: FontWeight.w400),
                          ),
                          Padding(
                            padding: EdgeInsets.all(ScreenUtil().setHeight(8)),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                DropdownWidget(
                                  items: languages,
                                  hintText: 'Org',
                                  onChanged: (newValue) async {
                                    final data = await FirestoreService()
                                        .getSobProjects(selectedYear);
                                    setState(() {
                                      projectList = data;
                                      searchTag(newValue);
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: ScreenUtil().setHeight(20)),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: ClampingScrollPhysics(),
                        itemCount: projectList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: SobProjectWidget(
                              modal: projectList[index],
                              height: ScreenUtil().screenHeight * 0.2,
                              width: ScreenUtil().screenWidth,
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