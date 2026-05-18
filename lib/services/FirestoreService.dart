import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:opso/modals/GSoC/Gsoc.dart';
import 'package:opso/modals/gsod/gsod_modal_old.dart';
import '../modals/fossasia_project_modal.dart';
import '../modals/gsod/gsod_modal_new.dart';
import '../modals/gssoc_project_modal.dart';
import '../modals/hyperledger_modal.dart';
import '../modals/osoc_modal.dart';
import '../modals/outreachy_project_modal.dart';
import '../modals/rsoc_project_modal.dart';
import '../modals/sob_project_modal.dart';
import '../modals/sokde_project_modal.dart';
import '../modals/swoc_project_modal.dart';
import '../modals/linux_foundation_modal.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Cache to avoid re-fetching same data
  final Map<String, List<dynamic>> _cache = {};

  String _cacheKey(String program, int year) => '${program}_$year';

  // ─── Generic Fetcher ───────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> _fetchProjects(
      String program, int year) async {
    final key = _cacheKey(program, year);
    if (_cache.containsKey(key)) {
      return _cache[key]!.cast<Map<String, dynamic>>();
    }

    final snapshot = await _db
        .collection('programs')
        .doc(program)
        .collection('projects')
        .where('year', isEqualTo: year)
        .get();

    final results = snapshot.docs.map((doc) => doc.data()).toList();
    _cache[key] = results;
    return results;
  }

  // ─── FOSSASIA ──────────────────────────────────────────────────────────────

  Future<List<FOSSASIAProjectModel>> getFossasiaProjects(int year) async {
    final data = await _fetchProjects('fossasia', year);
    return data
        .map((item) => FOSSASIAProjectModel(
              name: item['title'] ?? '',
              description: item['description'] ?? '',
              techStack: List<String>.from(item['techstack'] ?? []),
              link: item['links']?['official'] ?? '',
              year: item['year']?.toString() ?? year.toString(),
            ))
        .toList();
  }

  // ─── GSOD ──────────────────────────────────────────────────────────────────

  Future<List<GsodModalNew>> getGsodProjects(int year) async {
    final data = await _fetchProjects('gsod', year);

    return data
        .map((item) => GsodModalNew(
            organizationName: item['title'] ?? "",
            organizationUrl: item["links"]?["official"] ?? "",
            docsPage: item['title'] + "GsoD Page",
            docsPageUrl: item["links"]?["docs_page"] ?? "",
            budget: item['title'] + "budget",
            budgetUrl: item["links"]?["budget"] ?? "",
            acceptedProjectProposal: item["description"] ?? "",
            acceptedProjectProposalUrl:
            item["links"]?["accepted_project_proposal_url"] ?? "",
            caseStudy: "CaseStudy : " + item['title'],
            caseStudyUrl: item["links"]?["case_study_url"] ?? "",
            year: item['year']))
        .toList();
  }
  Future<List<GsodModalOld>> getGsodProjectsOld(int year) async {
  final data = await _fetchProjects('gsod', year);
  return data.map((item) => GsodModalOld(
    organizationName: item['title'] ?? '',
    organizationUrl: item['links']?['official'] ?? '',
    technicalWriter: item['extra']?['technicalWriter'] ?? '',
    mentor: item['extra']?['mentor'] ?? '',
    project: item['extra']?['project'] ?? '',
    projectUrl: item['extra']?['projectUrl'] ?? '',
    report: item['extra']?['report'] ?? '',
    reportUrl: item['extra']?['reportUrl'] ?? '',
    originalProjectProposal: item['extra']?['originalProjectProposal'] ?? '',
    originalProjectProposalUrl: item['extra']?['originalProjectProposalUrl'] ?? '',
    year: item['year'] ?? year,
  )).toList();
}

  // ─── GSSOC ─────────────────────────────────────────────────────────────────

  Future<List<GssocProjectModal>> getGssocProjects(int year) async {
    final data = await _fetchProjects('gssoc', year);
    return data
        .map((item) => GssocProjectModal(
              name: item['title'] ?? '',
              githubUrl: item['links']?['github'] ?? '',
              techstack: List<String>.from(item['techstack'] ?? []),
              hostedBy: item['extra']?['hostedBy'] ?? '',
              year: item['year']?.toString() ?? year.toString(),
            ))
        .toList();
  }

  // ─── HYPERLEDGER ───────────────────────────────────────────────────────────

  Future<List<HyperledgerProjectModal>> getHyperledgerProjects(int year) async {
    final data = await _fetchProjects('hyperledger', year);
    return data
        .map((item) => HyperledgerProjectModal(
              name: item['title'] ?? '',
              wiki: item['links']?['official'] ?? '',
              mentors: List<String>.from(item['extra']?['mentors'] ?? []),
              year: item['year']?.toString() ?? year.toString(),
            ))
        .toList();
  }

  // ─── OUTREACHY ─────────────────────────────────────────────────────────────

  Future<List<OutreachyProjectModal>> getOutreachyProjects(int year) async {
    final data = await _fetchProjects('outreachy', year);
    return data
        .map((item) => OutreachyProjectModal(
              name: item['title'] ?? '',
              description: item['description'] ?? '',
              skills: List<String>.from(item['techstack'] ?? []),
              spots: item['extra']?['spots'] ?? 0,
              year: item['year'] ?? year,
            ))
        .toList();
  }

  // ─── OSOC ──────────────────────────────────────────────────────────────────

  Future<List<OsocModal>> getOsocProjects(int year) async {
    final data = await _fetchProjects('osoc', year);
    return data
        .map((item) => OsocModal(
              name: item['title'] ?? '',
              description: item['description'] ?? '',
              image_url: item['links']?['image'] ?? '',
              project_url: item['links']?['official'] ?? '',
              year: item['year'] ?? year,
            ))
        .toList();
  }

  // ─── SOB ───────────────────────────────────────────────────────────────────

  Future<List<SobProjectModal>> getSobProjects(int year) async {
  final data = await _fetchProjects('sob', year);
  return data.map((item) => SobProjectModal(
    name: item['title'] ?? '',
    organization: item['extra']?['organization'] ?? '',
    description: item['description'] ?? '',
    mentor: item['extra']?['mentor'] ?? '',
    university: item['extra']?['university'] ?? '',
    country: item['extra']?['country'] ?? '',
    projects: List<String>.from(item['extra']?['project_links'] ?? []),
    year: item['year'] ?? year,
  )).toList();
}

  // ─── SOKDE ─────────────────────────────────────────────────────────────────

  Future<List<SokdeProjectModal>> getSokdeProjects(int year) async {
    final data = await _fetchProjects('sokde', year);
    return data
        .map((item) => SokdeProjectModal(
              name: item['title'] ?? '',
              mentors: List<String>.from(item['extra']['mentors']),
              mentees: List<String>.from(item['extra']['mentees']),
              wiki: item['links']?['official'] ?? '',
              year: item['year'] ?? year,
              
            ))
        .toList();
  }

  // ─── SWOC ──────────────────────────────────────────────────────────────────

  Future<List<SwocProjectModal>> getSwocProjects(int year) async {
    final data = await _fetchProjects('swoc', year);
    return data
        .map((item) => SwocProjectModal(
              name: item['title'] ?? '',
              repo: item['links']?['github'] ?? '',
              techstack: List<String>.from(item['techstack'] ?? []),
              year: item['year']?.toString() ?? year.toString(),
              owner: item['extra']['owner'] ?? '',
            ))
        .toList();
  }

  // ─── REDOX ─────────────────────────────────────────────────────────────────

  Future<List<RsocProjectModal>> getRedoxProjects() async {
    final snapshot = await _db
        .collection('programs')
        .doc('redox')
        .collection('projects')
        .get();

    return snapshot.docs.map((doc) {
      final item = doc.data();
      return RsocProjectModal(
        name: item['title'] ?? '',
        contributor: item['extra']?['contributor'] ?? '',
        description: item['description'] ?? '',
        githubUrl: item['links']?['official'] ?? '',
      );
    }).toList();
  }

  Future<List<LinuxFoundationModal>> getLinuxProjects() async {
    final snapshot = await _db.collection('programs').doc('linux_foundation').collection('projects').get();

    return snapshot.docs.map((doc){
      final item = doc.data();
      return LinuxFoundationModal(name: item['title'] ?? '', projectUrl: item['links']['official'] ?? '', imageUrl: item['extra']['image_url'] ?? '');
    }).toList();
  }
  
  Future<List<Organization>> getGsocOrgs(int year) async {
  final data = await _fetchProjects('gsoc', year);
  return data.map((item) => Organization(
    name: item['title'] ?? '',
    imageUrl: item['extra']?['imageUrl'] ?? '',
    imageBackgroundColor: item['extra']?['imageBackgroundColor'] ?? '',
    description: item['description'] ?? '',
    url: item['links']?['official'] ?? '',
    numProjects: item['extra']?['numProjects'] ?? 0,
    category: item['extra']?['category'] ?? '',
    projectsUrl: item['links']?['projects'] ?? '',
    ircChannel: item['extra']?['ircChannel'] ?? '',
    contactEmail: item['extra']?['contactEmail'] ?? '',
    mailingList: item['links']?['mailing_list'] ?? '',
    twitterUrl: item['links']?['twitter'] ?? '',
    blogUrl: item['extra']?['blogUrl'] ?? '',
    topics: List<String>.from(item['extra']?['topics'] ?? []),
    technologies: List<String>.from(item['techstack'] ?? []),
    projects: (item['extra']?['projects'] as List? ?? []).map((p) => Project(
      title: p['title'] ?? '',
      shortDescription: p['shortDescription'] ?? '',
      description: '',
      studentName: p['studentName'] ?? '',
      codeUrl: '',
      projectUrl: p['projectUrl'] ?? '',
    )).toList(),
  )).toList();
}
  // ─── Clear Cache ───────────────────────────────────────────────────────────

  void clearCache() => _cache.clear();
}
