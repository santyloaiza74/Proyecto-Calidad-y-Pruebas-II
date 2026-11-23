Feature: Pruebas de Autenticación y Usuarios (CP-001 a CP-005, CP-007, CP-008, CP-009, CP-010)

  Background:
    * url baseUrl

  @CP-001
  Scenario: CP-001 Autenticación exitosa (Login) y captura de token
    Given path 'users'
    And request
      """
      {
        "firstName": "Proyecto",
        "lastName": "CyP",
        "email": "proyecto@cyp.com",
        "password": "ProyectoCyP"
      }
      """
    When method post
    Then status 201

    Given path 'users', 'login'
    And request
      """
      {
        "email": "proyecto@cyp.com",
        "password": "ProyectoCyP"
      }
      """
    When method post
    Then status 200
    * def tokenAuth = response.token
    And match tokenAuth != null

  @CP-002
  Scenario: CP-002 Modificación de perfil sin cabecera de autorización
    Given path 'users', 'me'
    And request
      """
      {
        "firstName": "Santiago",
        "lastName": "Loaiza",
        "email": "santiago.loaiza@proyecto.com",
        "password": "Asdf1234"
      }
      """
    When method patch
    Then status 401
    And match response.error == 'Please authenticate.'

  @CP-004
  Scenario: CP-004 Registro de usuario público
    Given path 'users'
    And request
      """
      {
        "firstName": "Messi",
        "lastName": "Lionel",
        "email": "messi.lionel@fake.com",
        "password": "Contraseña1234"
      }
      """
    When method post
    Then status 201
    * def tokenAuth = response.token
    Given path 'users', 'me'
    And header Authorization = 'Bearer ' + tokenAuth
    When method delete
    Then status 200

  @CP-003
  Scenario: CP-003 Eliminación de cuenta con esquema malformado
    Given path 'users'
    And request
      """
      {
        "firstName": "messi",
        "lastName": "Lionel",
        "email": "messi.lionel@fake.com",
        "password": "Contraseña1234"
      }
      """
    When method post
    Then status 201
    * def tokenAuth = response.token

    Given path 'users', 'me'
    And header Authorization = 'Be4rer' + tokenAuth
    When method delete
    Then status 401
    And match response.error == 'Please authenticate.'

    Given path 'users', 'me'
    And header Authorization = 'Bearer ' + tokenAuth
    When method delete
    Then status 200

  @CP-005
  Scenario: CP-005 Consulta de perfil de usuario autenticado
    Given path 'users', 'login'
    And request
      """
      {
        "email": "proyecto@cyp.com",
        "password": "ProyectoCyP"
      }
      """
    When method post
    Then status 200
    * def tokenAuth = response.token

    Given path 'users', 'me'
    And header Authorization = 'Bearer ' + tokenAuth
    When method get
    Then status 200
    And match response.firstName == 'Proyecto'
    And match response.lastName == 'CyP'
    And match response.email == 'proyecto@cyp.com'
    And match response.password == '#notpresent'

  @CP-007
  Scenario: CP-007 Actualización parcial del perfil de usuario (PATCH)
    Given path 'users', 'login'
    And request
      """
      {
        "email": "proyecto@cyp.com",
        "password": "ProyectoCyP"
      }
      """
    When method post
    Then status 200
    * def tokenAuth = response.token

    Given path 'users', 'me'
    And header Authorization = 'Bearer ' + tokenAuth
    And request
      """
      {
        "firstName": "Jacobo",
        "lastName": "Loaiza"
      }
      """
    When method patch
    Then status 200
    And match response.firstName != 'Proyecto'
    And match response.lastName != 'CyP'

  @CP-008
  Scenario: CP-008 Eliminación definitiva de cuenta de usuario autenticado
    Given path 'users', 'login'
    And request
      """
      {
        "email": "proyecto@cyp.com",
        "password": "ProyectoCyP"
      }
      """
    When method post
    Then status 200
    * def tokenAuth = response.token

    Given path 'users', 'me'
    And header Authorization = 'Bearer ' + tokenAuth
    When method delete
    Then status 200
  @CP-009
  Scenario: CP-009 Registro de usuario omitiendo atributo obligatorio password
    Given path 'users'
    And request
      """
      {
        "firstName": "Usuario",
        "lastName": "Test",
        "email": "usertest@fake.com"
      }
      """
    When method POST
    Then status 400
    And match response.message contains 'User validation failed: password: Path `password` is required.'
  
  @CP-010
  Scenario: CP-010 Registro de usuario con contraseña inferior a la longitud mínima
    Given path 'users'
    And request
      """
      {
        "firstName": "Usuario",
        "lastName": "Test",
        "email": "usertest@fake.com",
        "password": "12"
      }
      """
    When method POST
    Then status 400
    And match response.message contains 'User validation failed: password: Path `password` (`12`) is shorter than the minimum allowed length (7).'