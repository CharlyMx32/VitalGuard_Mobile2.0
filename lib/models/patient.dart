import 'enums.dart';

class Patient {
  final int id;
  final String firstName;
  final String paternalLastName;
  final String? maternalLastName;
  final DateTime birthDate;
  final GenderType gender;
  final String? phone;
  final String? address;
  final BloodType? bloodType;
  final String? medicalNotes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Patient({
    required this.id,
    required this.firstName,
    required this.paternalLastName,
    this.maternalLastName,
    required this.birthDate,
    required this.gender,
    this.phone,
    this.address,
    this.bloodType,
    this.medicalNotes,
    this.createdAt,
    this.updatedAt,
  });

  int get age {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  String get fullName {
    final parts = [firstName, paternalLastName, maternalLastName]
        .where((s) => s != null && s.isNotEmpty)
        .toList();
    return parts.join(' ');
  }

  String get initials {
    final first = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final last = paternalLastName.isNotEmpty ? paternalLastName[0].toUpperCase() : '';
    return '$first$last';
  }

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'] as int,
      firstName: json['firstName'] as String,
      paternalLastName: json['paternalLastName'] as String,
      maternalLastName: json['maternalLastName'] as String?,
      birthDate: DateTime.parse(json['birthDate'] as String),
      gender: json['gender'] == 'M' ? GenderType.m : GenderType.f,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      bloodType: json['bloodType'] != null
          ? BloodType.fromApi(json['bloodType'] as String)
          : null,
      medicalNotes: json['medicalNotes'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'paternalLastName': paternalLastName,
      'maternalLastName': maternalLastName,
      'birthDate': birthDate.toIso8601String().split('T')[0],
      'gender': gender == GenderType.m ? 'M' : 'F',
      if (phone != null) 'phone': phone,
      if (address != null) 'address': address,
      if (bloodType != null) 'bloodType': bloodType!.apiValue,
      if (medicalNotes != null) 'medicalNotes': medicalNotes,
    };
  }
}
