Feature: Pruebas de Autenticación y Usuarios (CP-001 a CP-005, CP-007 a CP-010)

  Background:
    * url baseUrl
    * def authHelper = 'classpath:demo/auth/auth-helper.feature'

  @CP-001
  Scenario: CP-001 Autenticación exitosa (Login) y captura de token
    # Reutilización de escenario mediante call read()
    * def sesion = call read(authHelper)
    * def email = sesion.userData.email
    * def password = sesion.userData.password

    Given path 'users', 'login'
    And request
      """
      {
        "email": "#(email)",
        "password": "#(password)"
      }
      """
    When method post
    Then status 200
    # Validación de tipos de datos
    And match response.token == '#string'
    And match response.user.firstName == '#string'
    And match response.user.lastName == '#string'
    And match response.user.email == email
    And match response.user.password == '#notpresent'
    * def tokenAuth = response.token

    # Limpieza del usuario creado
    Given path 'users', 'me'
    And header Authorization = 'Bearer ' + tokenAuth
    When method delete
    Then status 200

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
    And match response.error == '#string'
    And match response == { error: 'Please authenticate.' }

  @CP-003
  Scenario: CP-003 Eliminación de cuenta con esquema Authorization malformado
    * def sesion = call read(authHelper)
    * def tokenAuth = sesion.tokenAuth

    Given path 'users', 'me'
    And header Authorization = 'Be4rer' + tokenAuth
    When method delete
    Then status 401
    And match response contains { error: 'Please authenticate.' }

    Given path 'users', 'me'
    And header Authorization = 'Bearer ' + tokenAuth
    When method delete
    Then status 200

  @CP-004
  Scenario: CP-004 Registro de usuario público
    * def email = 'messi_' + java.util.UUID.randomUUID() + '@fake.com'

    Given path 'users'
    And request
      """
      {
        "firstName": "Messi",
        "lastName": "Lionel",
        "email": "#(email)",
        "password": "Password1234"
      }
      """
    When method post
    Then status 201
    And match response.token == '#string'
    And match response contains { token: '#string' }
    And match response.user contains { firstName: 'Messi', lastName: 'Lionel', email: '#(email)' }
    And match response.user.password == '#notpresent'
    * def tokenAuth = response.token

    Given path 'users', 'me'
    And header Authorization = 'Bearer ' + tokenAuth
    When method delete
    Then status 200

  @CP-005
  Scenario: CP-005 Consulta de perfil de usuario autenticado
    * def sesion = call read(authHelper)
    * def tokenAuth = sesion.tokenAuth
    * def emailEsperado = sesion.userData.email

    Given path 'users', 'me'
    And header Authorization = 'Bearer ' + tokenAuth
    When method get
    Then status 200
    And match response.email == '#string'
    And match response.firstName == '#string'
    And match response.lastName == '#string'
    And match response contains { firstName: 'Proyecto', lastName: 'CyP', email: '#(emailEsperado)' }
    And match response.password == '#notpresent'

    Given path 'users', 'me'
    And header Authorization = 'Bearer ' + tokenAuth
    When method delete
    Then status 200

  @CP-007
  Scenario: CP-007 Actualización parcial del perfil de usuario (PATCH)
    * def sesion = call read(authHelper)
    * def tokenAuth = sesion.tokenAuth

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
    And match response.firstName == '#string'
    And match response.lastName == '#string'
    And match response contains { firstName: 'Jacobo', lastName: 'Loaiza' }

    Given path 'users', 'me'
    And header Authorization = 'Bearer ' + tokenAuth
    When method delete
    Then status 200

  @CP-008
  Scenario: CP-008 Eliminación definitiva de cuenta de usuario autenticado
    * def sesion = call read(authHelper)
    * def tokenAuth = sesion.tokenAuth

    Given path 'users', 'me'
    And header Authorization = 'Bearer ' + tokenAuth
    When method delete
    Then status 200

  @CP-009 @CP-010
  Scenario Outline: <codigoCaso> Validación de contraseña en registro (<descripcion>)
    Given path 'users'
    And request <body>
    When method post
    Then status <codigo>
    And match response.message == '#string'
    And match response.message contains '<mensajeEsperado>'

    Examples:
      | codigoCaso | descripcion                   | body                                                                                   | codigo | mensajeEsperado                                                                                          |
      | CP-009     | password obligatorio omitido  | { firstName: 'Usuario', lastName: 'Test', email: 'usertest@fake.com' }                 | 400    | User validation failed: password: Path `password` is required.                                           |
      | CP-010     | password menor a longitud min | { firstName: 'Usuario', lastName: 'Test', email: 'usertest@fake.com', password: '12' } | 400    | User validation failed: password: Path `password` (`12`) is shorter than the minimum allowed length (7). |