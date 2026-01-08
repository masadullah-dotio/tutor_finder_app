enum BookingType {
  online,
  home;

  String toDisplayName() {
    switch (this) {
      case BookingType.online:
        return 'Online';
      case BookingType.home:
        return 'Home';
    }
  }
}
