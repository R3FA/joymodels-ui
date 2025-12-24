enum JwtClaimKeyApiModel {
  nameIdentifier(
    'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier',
  ),
  userName('http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name'),
  role('http://schemas.microsoft.com/ws/2008/06/identity/claims/role'),
  exp('exp'),
  iss('iss'),
  aud('aud');

  final String key;
  const JwtClaimKeyApiModel(this.key);
}
