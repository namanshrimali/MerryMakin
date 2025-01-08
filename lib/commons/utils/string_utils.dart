  String getEmailWithoutDomain(String email) {
    if (email.isEmpty) {
      return "";
    }
    List<String> parts = email.split("@");
    if (parts.length == 2) {
      return parts[0];
    } else {
      // Email format is invalid, return the original email
      return email;
    }
  }