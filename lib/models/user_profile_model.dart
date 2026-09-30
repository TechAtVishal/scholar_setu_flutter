class UserProfileModel {
  String fullName;
  String aadhaarNumber;
  String dob;
  String gender;
  String category;
  String subTribe;
  String state;
  String district;
  String currentClass;
  String institution;
  String course;
  String annualIncome;
  String bankAccountNumber;
  String ifscCode;
  String bankName;
  String mobileNumber;
  String email;
  String guardianName;
  String guardianMobile;

  UserProfileModel({
    this.fullName = '',
    this.aadhaarNumber = '',
    this.dob = '',
    this.gender = '',
    this.category = 'ST',
    this.subTribe = '',
    this.state = '',
    this.district = '',
    this.currentClass = '',
    this.institution = '',
    this.course = '',
    this.annualIncome = '',
    this.bankAccountNumber = '',
    this.ifscCode = '',
    this.bankName = '',
    this.mobileNumber = '',
    this.email = '',
    this.guardianName = '',
    this.guardianMobile = '',
  });

  int get profileStrength {
    final fields = [
      fullName, dob, gender, state, district,
      institution, currentClass, annualIncome, bankAccountNumber, ifscCode,
    ];
    return fields.where((f) => f.isNotEmpty).length;
  }

  double get profilePercent => profileStrength / 10.0;

  Map<String, dynamic> toJson() => {
    'fullName': fullName, 'aadhaarNumber': aadhaarNumber,
    'dob': dob, 'gender': gender, 'category': category,
    'subTribe': subTribe, 'state': state, 'district': district,
    'currentClass': currentClass, 'institution': institution,
    'course': course, 'annualIncome': annualIncome,
    'bankAccountNumber': bankAccountNumber, 'ifscCode': ifscCode,
    'bankName': bankName, 'mobileNumber': mobileNumber,
    'email': email, 'guardianName': guardianName,
    'guardianMobile': guardianMobile,
  };

  factory UserProfileModel.fromJson(Map<String, dynamic> j) => UserProfileModel(
    fullName: j['fullName'] ?? '', aadhaarNumber: j['aadhaarNumber'] ?? '',
    dob: j['dob'] ?? '', gender: j['gender'] ?? '',
    category: j['category'] ?? 'ST', subTribe: j['subTribe'] ?? '',
    state: j['state'] ?? '', district: j['district'] ?? '',
    currentClass: j['currentClass'] ?? '', institution: j['institution'] ?? '',
    course: j['course'] ?? '', annualIncome: j['annualIncome'] ?? '',
    bankAccountNumber: j['bankAccountNumber'] ?? '',
    ifscCode: j['ifscCode'] ?? '', bankName: j['bankName'] ?? '',
    mobileNumber: j['mobileNumber'] ?? '', email: j['email'] ?? '',
    guardianName: j['guardianName'] ?? '', guardianMobile: j['guardianMobile'] ?? '',
  );

  UserProfileModel copyWith({
    String? fullName, String? aadhaarNumber, String? dob,
    String? gender, String? category, String? subTribe,
    String? state, String? district, String? currentClass,
    String? institution, String? course, String? annualIncome,
    String? bankAccountNumber, String? ifscCode, String? bankName,
    String? mobileNumber, String? email, String? guardianName,
    String? guardianMobile,
  }) => UserProfileModel(
    fullName: fullName ?? this.fullName,
    aadhaarNumber: aadhaarNumber ?? this.aadhaarNumber,
    dob: dob ?? this.dob, gender: gender ?? this.gender,
    category: category ?? this.category, subTribe: subTribe ?? this.subTribe,
    state: state ?? this.state, district: district ?? this.district,
    currentClass: currentClass ?? this.currentClass,
    institution: institution ?? this.institution, course: course ?? this.course,
    annualIncome: annualIncome ?? this.annualIncome,
    bankAccountNumber: bankAccountNumber ?? this.bankAccountNumber,
    ifscCode: ifscCode ?? this.ifscCode, bankName: bankName ?? this.bankName,
    mobileNumber: mobileNumber ?? this.mobileNumber, email: email ?? this.email,
    guardianName: guardianName ?? this.guardianName,
    guardianMobile: guardianMobile ?? this.guardianMobile,
  );
}
