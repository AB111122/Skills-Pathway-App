import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/opportunity_filter_model.dart';
import '../models/opportunity_model.dart';
import '../models/application_model.dart';
import 'application_repository.dart';
import 'opportunity_service.dart';

/// [MOCK IMPLEMENTATION]
/// Provides realistic verified and unverified opportunity records for Pakistan & International pathways.
class MockOpportunityService implements OpportunityService {
  static final MockOpportunityService instance = MockOpportunityService._internal();
  MockOpportunityService() {}
  MockOpportunityService._internal();
  static const _stateKey = 'opportunity_state';
  bool _hydrated = false;
  static final List<OpportunityModel> _mockDatabase = [
    OpportunityModel(
      id: 'opp_hec_01',
      title: 'HEC Undergraduate Indigenous Merit Scholarship 2026',
      organizationName: 'Higher Education Commission (HEC Pakistan)',
      type: OpportunityType.scholarship,
      location: 'Islamabad / All Public Universities',
      deadline: DateTime.now().add(const Duration(days: 4)),
      isVerified: true, // Strictly verified by HEC
      stipendOrFunding: '100% Tuition Fee + PKR 15,000 / mo',
      shortDescription:
          'Full tuition waiver and monthly living allowance for undergraduate students studying in recognized Pakistani public universities.',
      fullDescription:
          'The Higher Education Commission (HEC) of Pakistan offers the Indigenous Scholarship Scheme to promote higher education accessibility across all provinces. Eligible undergraduate students will receive full semester tuition coverage, hostel fee allowance, and a monthly maintenance stipend of PKR 15,000.',
      officialUrl: 'https://hec.gov.pk/english/scholarships/indigenous',
      requiredSkills: ['Academic Excellence', 'Pakistani Domicile', 'Full-time Enrollment'],
      eligibleFields: [
        'Computer Science & AI',
        'Software Engineering',
        'Electrical / Mechanical Engineering',
        'Natural Sciences & Mathematics',
        'Biotechnology',
      ],
      degreeLevel: 'Undergraduate',
      duration: '4 Years (8 Semesters)',
      eligibilityCriteria: [
        'Must be a Pakistani / AJK citizen with valid CNIC/B-Form.',
        'Enrolled in a regular 4-year undergraduate degree program at an HEC recognized university.',
        'Minimum 70% in Intermediate / HSSC or CGPA 3.0/4.0 in current semester.',
        'Not availing any other government scholarship simultaneously.',
      ],
      benefits: [
        '100% tuition and institutional fees paid directly to the university.',
        'PKR 15,000 monthly living stipend paid to student bank account.',
        'Book and research grant of PKR 25,000 per academic year.',
      ],
      requiredDocuments: [
        'Attested copy of CNIC or B-Form',
        'Matric and Intermediate Mark Sheets / Transcripts',
        'University Bonafide Student Certificate',
        'Father / Guardian Income Certificate or Salary Slip',
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 14)),
    ),

    OpportunityModel(
      id: 'opp_jazz_02',
      title: 'Jazz Summer Xplore Internship Program 2026',
      organizationName: 'Jazz (Telecom & Digital Services)',
      type: OpportunityType.internship,
      location: 'Islamabad / Lahore / Hybrid',
      deadline: DateTime.now().add(const Duration(days: 6)),
      isVerified: true, // Strictly verified corporate program
      isPaid: true,
      stipendOrFunding: 'PKR 45,000 / month',
      shortDescription:
          'Hands-on 8-week corporate tech & product immersion working on JazzCash, digital products, and telecom cloud infrastructure.',
      fullDescription:
          'Jazz Summer Xplore is the premier internship initiative by VEON/Jazz in Pakistan. Interns are placed directly into cross-functional agile squads covering Mobile Engineering, Fintech Product Design, Data Analytics, Cybersecurity, and Business Strategy.',
      officialUrl: 'https://jazz.com.pk/careers/summer-xplore',
      requiredSkills: ['Python', 'SQL', 'Flutter', 'Problem Solving', 'Data Analysis'],
      eligibleFields: [
        'Computer Science & AI',
        'Software Engineering',
        'Business & Finance',
        'Data Science',
      ],
      degreeLevel: 'Undergraduate',
      duration: '8 Weeks',
      eligibilityCriteria: [
        '3rd or 4th year undergraduate student or recent 2025/2026 graduate.',
        'Demonstrated interest in tech products, coding, or analytics.',
        'Available full-time during the June - August internship cycle.',
      ],
      benefits: [
        'Competitive monthly stipend of PKR 45,000.',
        'Direct mentorship from Jazz executive leadership and tech leads.',
        'Fast-track interview invitation for the Jazz Management Trainee (MTO) program.',
        'Hybrid working flexibility with official laptop provided.',
      ],
      requiredDocuments: [
        'Updated Resume / CV (PDF)',
        'Latest University Transcript',
        'GitHub / Portfolio link (for tech roles)',
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 8)),
    ),

    OpportunityModel(
      id: 'opp_systems_03',
      title: 'Systems Limited Associate Software Engineer Trainee',
      organizationName: 'Systems Limited',
      type: OpportunityType.internship,
      location: 'Lahore & Karachi, Pakistan',
      deadline: DateTime.now().add(const Duration(days: 14)),
      isVerified: true, // Strictly verified IT leader
      isPaid: true,
      stipendOrFunding: 'PKR 65,000 / month',
      shortDescription:
          'Fast-track trainee engineer onboarding in Cloud Computing, Flutter, .NET, and Enterprise AI with guaranteed permanent placement.',
      fullDescription:
          'Systems Limited, Pakistan\'s largest IT exporter and tech powerhouse, is recruiting top graduating seniors and fresh graduates for its 2026 Associate Software Engineer cohort. Trainees undergo 3 months of rigorous enterprise training with full compensation.',
      officialUrl: 'https://systemsltd.com/careers/fresh-graduates',
      requiredSkills: ['OOP', 'Data Structures & Algorithms', 'Dart/Flutter', 'C# / Java', 'SQL'],
      eligibleFields: [
        'Computer Science & AI',
        'Software Engineering',
        'Information Technology',
      ],
      degreeLevel: 'Fresh Grad',
      duration: '3 Months (Trailing to Permanent)',
      eligibilityCriteria: [
        'BS in Computer Science, Software Engineering, or related disciplines.',
        'Graduating in 2025 or 2026.',
        'Solid foundation in Object-Oriented Programming and relational databases.',
      ],
      benefits: [
        'PKR 65,000 monthly compensation during the 3-month probation/training.',
        'Permanent ASE offer (PKR 120,000+ base) upon successful evaluation.',
        'Health and life insurance coverage.',
        'Global project deployment opportunities.',
      ],
      requiredDocuments: [
        'Resume / CV',
        'Official or Unofficial Degree Transcript',
        'Final Year Project (FYP) abstract',
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),

    OpportunityModel(
      id: 'opp_chevening_04',
      title: 'UK Chevening Scholarships 2026/2027 (Pakistan)',
      organizationName: 'Foreign, Commonwealth & Development Office (UK)',
      type: OpportunityType.scholarship,
      location: 'United Kingdom (All Universities)',
      deadline: DateTime.now().add(const Duration(days: 45)),
      isVerified: true, // Strictly verified international government scholarship
      stipendOrFunding: 'Fully Funded (100% Tuition, Flights & Monthly Living)',
      shortDescription:
          'Prestigious fully-funded UK government scholarship for Pakistani leaders to undertake a 1-year Master\'s degree at any UK university.',
      fullDescription:
          'Chevening is the UK Government\'s global scholarship program, funded by the FCDO and partner organizations. Pakistan is one of the largest recipient countries. The scholarship provides full financial coverage for any master\'s course at Oxford, Cambridge, Imperial, LSE, Manchester, and other premier UK institutions.',
      officialUrl: 'https://chevening.org/scholarship/pakistan',
      requiredSkills: ['Leadership Potential', '2+ Years Work Experience', 'Academic Merit'],
      eligibleFields: [
        'Computer Science & AI',
        'Business & Finance',
        'Public Policy & Governance',
        'Climate Change & Sustainability',
        'Biotechnology & Health',
      ],
      degreeLevel: 'Master\'s',
      duration: '1 Year Full-Time',
      eligibilityCriteria: [
        'Citizen of Pakistan with intention to return for at least two years after studies.',
        'Have completed an undergraduate degree (16 years of education).',
        'Minimum two years of verifiable work experience (equivalent to 2,800 hours).',
        'Apply to three different eligible UK university master courses.',
      ],
      benefits: [
        'Full payment of tuition fees (no cap for standard master courses).',
        'Monthly living allowance in the UK (approx. £1,400 / month).',
        'Economy class return airfare from Pakistan to the UK.',
        'Visa application fee and arrival allowance.',
      ],
      requiredDocuments: [
        'Undergraduate Degree Certificate and Transcript',
        'Two Letters of Reference',
        'Valid Pakistani Passport',
        'Four 500-word Chevening Leadership & Career Plan essays',
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
    ),

    OpportunityModel(
      id: 'opp_nust_05',
      title: 'NUST Need-Based Financial Aid & Merit Grants',
      organizationName: 'National University of Sciences & Technology',
      type: OpportunityType.scholarship,
      location: 'Islamabad, Pakistan',
      deadline: DateTime.now().add(const Duration(days: 22)),
      isVerified: true, // Strictly verified university aid
      stipendOrFunding: 'Up to 100% Tuition Fee + Hostel Support',
      shortDescription:
          'Comprehensive financial aid for newly admitted undergraduate engineering, computing, and social sciences students.',
      fullDescription:
          'NUST is committed to ensuring that no talented student is denied education due to financial hardship. The NUST Need-Based Scholarship Trust provides full or partial tuition grants and hostel assistance based on family income evaluation.',
      officialUrl: 'https://nust.edu.pk/admissions/financial-aid',
      requiredSkills: ['NUST NET Qualified', 'Demonstrated Financial Need'],
      eligibleFields: [
        'Computer Science & AI',
        'Software Engineering',
        'Electrical / Mechanical Engineering',
        'Business & Finance',
      ],
      degreeLevel: 'Undergraduate',
      duration: '4 Years',
      eligibilityCriteria: [
        'Admitted to NUST undergraduate programs through the NUST Entry Test (NET).',
        'Family gross monthly income below the defined financial aid threshold.',
        'Maintain minimum SGPA/CGPA 2.5 during the study period.',
      ],
      benefits: [
        'Partial to 100% tuition waiver throughout the 4-year degree.',
        'Hostel room and mess subsidy for outstation students.',
      ],
      requiredDocuments: [
        'NUST Financial Aid Form',
        'Last 6 months electricity and gas utility bills',
        'Father / Guardian tax returns or salary slips',
        'Bank statements of all family accounts',
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),

    OpportunityModel(
      id: 'opp_unilever_06',
      title: 'Unilever Pakistan Future Leaders Internship 2026',
      organizationName: 'Unilever Pakistan',
      type: OpportunityType.internship,
      location: 'Karachi & Lahore, Pakistan',
      deadline: DateTime.now().add(const Duration(days: 18)),
      isVerified: true, // Strictly verified MNC
      isPaid: true,
      stipendOrFunding: 'PKR 60,000 / month',
      shortDescription:
          'Immersive FMCG summer internship tackling real-world brand marketing, supply chain robotics, and finance transformation projects.',
      fullDescription:
          'The Unilever Internship Program (ULIP) gives top university students hands-on ownership of real business projects from day one. You will work alongside seasoned leaders on iconic brands like Lifebuoy, Surf Excel, Knorr, and Sunsilk.',
      officialUrl: 'https://unilever.pk/careers/students-and-graduates',
      requiredSkills: ['Business Analytics', 'Digital Marketing', 'Supply Chain', 'Communication'],
      eligibleFields: [
        'Business & Finance',
        'Supply Chain & Industrial Engineering',
        'Computer Science & AI',
      ],
      degreeLevel: 'Undergraduate',
      duration: '6 to 8 Weeks',
      eligibilityCriteria: [
        'Enrolled in 3rd/4th year undergraduate or 1st/2nd year MBA/Master\'s program.',
        'Strong extra-curricular involvement and leadership experience.',
        'Available to work full-time on-site in Karachi or Lahore.',
      ],
      benefits: [
        'Monthly stipend of PKR 60,000.',
        'Direct project exposure with real business impact.',
        'Direct progression to the Unilever Future Leaders Program (UFLP) assessment center.',
      ],
      requiredDocuments: [
        'Resume / CV',
        'Academic Transcript',
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
    ),

    OpportunityModel(
      id: 'opp_lums_07',
      title: 'LUMS National Outreach Program (NOP) Scholarship',
      organizationName: 'Lahore University of Management Sciences',
      type: OpportunityType.scholarship,
      location: 'Lahore, Pakistan',
      deadline: DateTime.now().add(const Duration(days: 35)),
      isVerified: true, // Strictly verified
      stipendOrFunding: '100% Fully Funded (Tuition, Hostel, Books, Stipend)',
      shortDescription:
          'Transformative full scholarship program for matric/intermediate students from remote & underprivileged areas of Pakistan.',
      fullDescription:
          'The LUMS NOP initiative identifies brilliant students from across Pakistan and prepares them for the LUMS admission test through fully-funded summer coaching sessions. Successful candidates receive complete financial aid for their 4-year undergraduate degree.',
      officialUrl: 'https://nop.lums.edu.pk',
      requiredSkills: ['High Matric / Intermediate Marks', 'Underprivileged Background'],
      eligibleFields: [
        'Computer Science & AI',
        'Business & Finance',
        'Humanities & Social Sciences',
        'Law',
      ],
      degreeLevel: 'High School',
      duration: '4 Years Undergraduate',
      eligibilityCriteria: [
        'At least 80% marks in Matriculation / O-Levels.',
        'Financial need verifiable through the NOP evaluation committee.',
        'Currently studying in 1st year of F.Sc / FA / ICS or equivalent.',
      ],
      benefits: [
        'Zero tuition fee for the entire 4-year degree.',
        'Free campus accommodation and monthly living stipend.',
        'Books, laptop, and travel allowance provided.',
      ],
      requiredDocuments: [
        'Matric Mark Sheet',
        'Proof of Family Income & Utility Bills',
        'Domicile Certificate',
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
    ),

    OpportunityModel(
      id: 'opp_fatima_08',
      title: 'Fatima Fertilizer Graduate Trainee Engineer Program',
      organizationName: 'Fatima Group',
      type: OpportunityType.internship,
      location: 'Sadiqabad & Lahore, Pakistan',
      deadline: DateTime.now().add(const Duration(days: 12)),
      isVerified: true, // Strictly verified
      isPaid: true,
      stipendOrFunding: 'PKR 55,000 / month + Accommodation',
      shortDescription:
          'Structured plant engineering and industrial automation traineeship for fresh engineering graduates.',
      fullDescription:
          'Fatima Fertilizer Company Limited is inviting applications for its Graduate Trainee Engineer (GTE) program. Selected candidates undergo intensive technical, safety, and managerial training at our modern chemical and fertilizer complex.',
      officialUrl: 'https://fatima-group.com/careers',
      requiredSkills: ['Chemical / Mechanical / Electrical Engineering', 'Process Safety'],
      eligibleFields: [
        'Electrical / Mechanical Engineering',
        'Chemical Engineering',
      ],
      degreeLevel: 'Fresh Grad',
      duration: '1 Year Traineeship',
      eligibilityCriteria: [
        'B.Sc / B.E in Chemical, Mechanical, or Electrical Engineering.',
        'Minimum CGPA 3.0 or equivalent from PEC recognized universities.',
        'Age not more than 26 years at the time of application.',
      ],
      benefits: [
        'Stipend of PKR 55,000 with furnished bachelor accommodation at plant site.',
        'Subsidized mess, medical insurance, and sports complex access.',
        'Permanent induction as Assistant Manager upon completion.',
      ],
      requiredDocuments: [
        'PEC Registration Card',
        'Final Degree Transcript',
        'Resume / CV',
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
    ),

    OpportunityModel(
      id: 'opp_fulbright_09',
      title: 'Fulbright Foreign Student Program Pakistan 2026/2027',
      organizationName: 'USEFP & U.S. Department of State',
      type: OpportunityType.scholarship,
      location: 'United States (All Universities)',
      deadline: DateTime.now().add(const Duration(days: 60)),
      isVerified: true, // Strictly verified premier US program
      stipendOrFunding: 'Fully Funded (Tuition, Flights, Health, US Living Stipend)',
      shortDescription:
          'The largest Fulbright program in the world, sending over 130 Pakistani students every year for Master\'s and PhD studies in the USA.',
      fullDescription:
          'The United States Educational Foundation in Pakistan (USEFP) administers the Fulbright scholarship. It funds complete tuition, textbooks, airfare, a monthly living stipend, and health insurance for full-time Master\'s or PhD studies at top American universities.',
      officialUrl: 'https://usefp.org/scholarships/fulbright-student',
      requiredSkills: ['GRE Test', 'Academic Excellence', 'Community Commitment'],
      eligibleFields: [
        'Computer Science & AI',
        'Energy & Engineering',
        'Agriculture & Food Security',
        'Public Health',
        'Social Sciences & Education',
      ],
      degreeLevel: 'Master\'s',
      duration: '2 Years (Master\'s) / 4-5 Years (PhD)',
      eligibilityCriteria: [
        'Pakistani citizen with residence in Pakistan.',
        '16 years of formal education for Master\'s; 18 years of education for PhD.',
        'Valid GRE General score at the time of application submission.',
      ],
      benefits: [
        'Full university tuition and mandatory fees in the USA.',
        'Monthly living stipend matching US university cost of living.',
        'Round-trip international airfare.',
        'Comprehensive health benefits plan.',
      ],
      requiredDocuments: [
        'GRE Score Report',
        'Official Academic Transcripts with HEC attestation',
        'Three Letters of Recommendation',
        'Study Objectives Essay and Personal Statement',
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 25)),
    ),

    OpportunityModel(
      id: 'opp_dev_community_10',
      title: 'PakTech Open Source Winter Fellowship 2026',
      organizationName: 'PakTech Community Initiative',
      type: OpportunityType.internship,
      location: 'Remote',
      deadline: DateTime.now().add(const Duration(days: 28)),
      isVerified: false, // Community submitted, not yet verified
      isPaid: false,
      stipendOrFunding: 'Mentorship & Certificate',
      shortDescription:
          'Contribute to public digital goods for Pakistan while being mentored by senior engineers from Silicon Valley and Europe.',
      fullDescription:
          'PakTech Fellowship pairs aspiring student developers with veteran open-source maintainers. Build production-grade Flutter, Python, and Rust tools while learning Git workflow, CI/CD, and real-world system architecture.',
      officialUrl: 'https://github.com/paktech-fellowship/winter-2026',
      requiredSkills: ['Git', 'Flutter', 'Python', 'Open Source'],
      eligibleFields: [
        'Computer Science & AI',
        'Software Engineering',
      ],
      degreeLevel: 'Undergraduate',
      duration: '6 Weeks',
      eligibilityCriteria: [
        'Basic familiarity with Git and at least one programming language.',
        'Willing to dedicate 10-15 hours per week during the fellowship.',
      ],
      benefits: [
        '1-on-1 mentorship with engineers from FAANG and European tech firms.',
        'Verified contributor certificate and GitHub portfolio showcase.',
      ],
      requiredDocuments: [
        'GitHub Profile Link',
        'Short statement on why you want to contribute to open source',
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  @override
  Future<List<OpportunityModel>> getOpportunities({
    OpportunityFilterModel? filter,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    await _hydrate();

    if (filter == null) {
      return List.unmodifiable(
        _mockDatabase.where((item) => item.status != OpportunityStatus.closed),
      );
    }

    return _mockDatabase.where((opp) {
      if (opp.status == OpportunityStatus.closed) return false;
      // 1. Search Query
      if (filter.searchQuery.trim().isNotEmpty) {
        final query = filter.searchQuery.toLowerCase().trim();
        final matchesTitle = opp.title.toLowerCase().contains(query);
        final matchesOrg = opp.organizationName.toLowerCase().contains(query);
        final matchesDesc = opp.shortDescription.toLowerCase().contains(query);
        final matchesSkills = opp.requiredSkills.any(
          (s) => s.toLowerCase().contains(query),
        );
        final matchesFields = opp.eligibleFields.any(
          (f) => f.toLowerCase().contains(query),
        );
        if (!matchesTitle &&
            !matchesOrg &&
            !matchesDesc &&
            !matchesSkills &&
            !matchesFields) {
          return false;
        }
      }

      // 2. Opportunity Type
      if (filter.opportunityType != null &&
          opp.type != filter.opportunityType) {
        return false;
      }

      // 3. Location / Country
      if (filter.location != null &&
          filter.location != 'All' &&
          filter.location!.isNotEmpty) {
        final loc = filter.location!.toLowerCase();
        if (!opp.location.toLowerCase().contains(loc)) {
          return false;
        }
      }

      // 4. Field of Study
      if (filter.field != null &&
          filter.field != 'All' &&
          filter.field!.isNotEmpty) {
        final fieldLower = filter.field!.toLowerCase();
        final matchesField = opp.eligibleFields.any(
          (f) => f.toLowerCase().contains(fieldLower) || fieldLower.contains(f.toLowerCase()),
        );
        if (!matchesField) return false;
      }

      // 5. Degree Level
      if (filter.degreeLevel != null &&
          filter.degreeLevel != 'All' &&
          filter.degreeLevel!.isNotEmpty) {
        if (opp.degreeLevel != null &&
            !opp.degreeLevel!
                .toLowerCase()
                .contains(filter.degreeLevel!.toLowerCase())) {
          return false;
        }
      }

      // 6. Paid Only
      if (filter.isPaidOnly && (!opp.isInternship || !opp.isPaid)) {
        return false;
      }

      // 7. Fully Funded Only
      if (filter.isFullyFundedOnly) {
        final text = '${opp.stipendOrFunding} ${opp.shortDescription}'
            .toLowerCase();
        if (!text.contains('100%') &&
            !text.contains('fully funded') &&
            !text.contains('full tuition')) {
          return false;
        }
      }

      // 8. Verified Only (Crucial PRD requirement)
      if (filter.isVerifiedOnly && !opp.isVerified) {
        return false;
      }

      return true;
    }).toList();
  }

  @override
  Future<OpportunityModel?> getOpportunityById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    await _hydrate();
    try {
      return _mockDatabase.firstWhere((opp) => opp.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> toggleSaveOpportunity(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    await _hydrate();
    final index = _mockDatabase.indexWhere((opp) => opp.id == id);
    if (index != -1) {
      final current = _mockDatabase[index];
      _mockDatabase[index] = current.copyWith(isSaved: !current.isSaved);
      await _persist();
      return _mockDatabase[index].isSaved;
    }
    return false;
  }

  @override
  Future<bool> markAsApplied(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    await _hydrate();
    final index = _mockDatabase.indexWhere((opp) => opp.id == id);
    if (index != -1) {
      final current = _mockDatabase[index];
      if (current.isClosed || current.deadline.isBefore(DateTime.now())) return false;
      final existing = await MockApplicationRepository.instance.findForStudentAndOpportunity('usr_student_01', id);
      if (existing != null) return false;
      _mockDatabase[index] = current.copyWith(
        isApplied: true,
        appliedAt: DateTime.now(),
      );
      if (current.organizationId != null) {
        await MockApplicationRepository.instance.create(
          ApplicationModel(
            id: 'application-$id-usr_student_01',
            studentId: 'usr_student_01',
            studentName: 'Fatima Zahra',
            opportunityId: current.id,
            opportunityTitle: current.title,
            universityId: current.organizationId!,
            universityName: current.organizationName,
            applicationDate: DateTime.now(),
          ),
        );
      }
      await _persist();
      return true;
    }
    return false;
  }

  @override
  Future<bool> toggleDeadlineReminder(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    await _hydrate();
    final index = _mockDatabase.indexWhere((opp) => opp.id == id);
    if (index != -1) {
      final current = _mockDatabase[index];
      _mockDatabase[index] = current.copyWith(
        hasDeadlineReminder: !current.hasDeadlineReminder,
      );
      await _persist();
      return _mockDatabase[index].hasDeadlineReminder;
    }
    return false;
  }

  @override
  Future<List<OpportunityModel>> getSavedOpportunities() async {
    await Future.delayed(const Duration(milliseconds: 200));
    await _hydrate();
    return _mockDatabase.where((opp) => opp.isSaved).toList();
  }

  @override
  Future<List<OpportunityModel>> getAppliedOpportunities() async {
    await Future.delayed(const Duration(milliseconds: 200));
    await _hydrate();
    return _mockDatabase.where((opp) => opp.isApplied).toList();
  }

  Future<List<OpportunityModel>> getManagedOpportunities(String organizationId) async {
    await _hydrate();
    return _mockDatabase.where((item) => item.organizationId == organizationId).toList();
  }

  Future<void> _hydrate() async {
    if (_hydrated) return;
    List<String> stored;
    try {
      final preferences = await SharedPreferences.getInstance().timeout(
        const Duration(milliseconds: 100),
      );
      stored = preferences.getStringList(_stateKey) ?? [];
    } catch (_) {
      stored = [];
    }
    final savedById = <String, OpportunityModel>{};
    for (final value in stored) {
      final json = jsonDecode(value) as Map<String, dynamic>;
      final opportunity = OpportunityModel.fromJson(json);
      savedById[opportunity.id] = opportunity;
    }
    for (var index = 0; index < _mockDatabase.length; index++) {
      final saved = savedById[_mockDatabase[index].id];
      if (saved != null) {
        _mockDatabase[index] = _mockDatabase[index].copyWith(
          isSaved: saved.isSaved,
          isApplied: saved.isApplied,
          appliedAt: saved.appliedAt,
          hasDeadlineReminder: saved.hasDeadlineReminder,
        );
      }
    }
    _hydrated = true;
  }

  Future<void> _persist() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setStringList(
        _stateKey,
        _mockDatabase.map((opp) => jsonEncode(opp.toJson())).toList(),
      );
    } catch (_) {
      // The in-memory mock remains usable in unit-test environments.
    }
  }

  Future<OpportunityModel> createUniversityOpportunity({
    required String organizationId,
    required String organizationName,
    required String title,
    required String description,
    required OpportunityType type,
    required DateTime deadline,
    required String location,
    required String applicationUrl,
  }) async {
    final item = OpportunityModel(
      id: 'university-${DateTime.now().microsecondsSinceEpoch}',
      title: title,
      organizationName: organizationName,
      organizationId: organizationId,
      createdBy: organizationId,
      type: type,
      location: location,
      deadline: deadline,
      isVerified: false,
      isPaid: type == OpportunityType.internship,
      stipendOrFunding: 'See opportunity details',
      shortDescription: description,
      fullDescription: description,
      officialUrl: applicationUrl,
      requiredSkills: const [],
      eligibleFields: const [],
      createdAt: DateTime.now(),
    );
    _mockDatabase.insert(0, item);
    await _persist();
    return item;
  }

  Future<void> updateUniversityOpportunity(
    String organizationId,
    OpportunityModel updated,
  ) async {
    final index = _mockDatabase.indexWhere((item) => item.id == updated.id);
    if (index < 0) throw StateError('Opportunity not found.');
    if (_mockDatabase[index].organizationId != organizationId) {
      throw StateError('You can only manage your own opportunities.');
    }
    _mockDatabase[index] = updated;
    await _persist();
  }

  Future<void> closeUniversityOpportunity(String organizationId, String id) async {
    final item = await getOpportunityById(id);
    if (item == null) throw StateError('Opportunity not found.');
    await updateUniversityOpportunity(
      organizationId,
      item.copyWith(status: OpportunityStatus.closed),
    );
  }

  Future<void> deleteUniversityOpportunity(String organizationId, String id) async {
    final item = await getOpportunityById(id);
    if (item == null || item.organizationId != organizationId) {
      throw StateError('You can only manage your own opportunities.');
    }
    _mockDatabase.removeWhere((opportunity) => opportunity.id == id);
    await _persist();
  }
}
