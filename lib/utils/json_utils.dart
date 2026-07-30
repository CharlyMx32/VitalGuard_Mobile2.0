dynamic normalizeJsonKeys(dynamic value) {
  if (value is Map<String, dynamic>) {
    final result = <String, dynamic>{};
    value.forEach((key, val) {
      String camelKey = key.replaceAllMapped(
        RegExp(r'_([a-z])'),
        (match) => match.group(1)!.toUpperCase(),
      );
      if (camelKey == 'treatmentDetails') camelKey = 'details';
      if (camelKey == 'medicationLogs') camelKey = 'logs';
      if (camelKey == 'deviceCompartments') camelKey = 'compartments';
      if (camelKey == 'appProfiles') camelKey = 'appProfile';
      result[camelKey] = normalizeJsonKeys(val);
    });
    return result;
  } else if (value is List) {
    return value.map((e) => normalizeJsonKeys(e)).toList();
  }
  return value;
}
