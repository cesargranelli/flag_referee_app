enum UserRole {
  admin,
  organizer,
  mesa,
  referee;

  static UserRole fromJson(String value) => switch (value.toUpperCase()) {
        'ADMIN' => UserRole.admin,
        'ORGANIZER' => UserRole.organizer,
        'MESA' => UserRole.mesa,
        'REFEREE' => UserRole.referee,
        _ => UserRole.mesa,
      };

  String toJson() => switch (this) {
        UserRole.admin => 'ADMIN',
        UserRole.organizer => 'ORGANIZER',
        UserRole.mesa => 'MESA',
        UserRole.referee => 'REFEREE',
      };

  /// Rótulo amigável em pt-BR.
  String get label => switch (this) {
        UserRole.admin => 'Administrador',
        UserRole.organizer => 'Organizador',
        UserRole.mesa => 'Mesa',
        UserRole.referee => 'Árbitro',
      };
}
