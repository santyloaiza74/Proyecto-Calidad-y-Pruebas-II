Feature: Pruebas de Contactos (CP-006)

  Background:
    * url baseUrl
    * def emailUnico = 'boca_' + java.util.UUID.randomUUID() + '@arg.com'

  @CP-006
  Scenario: CP-006 Reemplazo total de la entidad contacto (PUT)
    Given path 'users'
    And request
      """
      {
        "firstName": "Boca",
        "lastName": "Juniors",
        "email": "#(emailUnico)",
        "password": "boca123"
      }
      """
    When method post
    Then status 201
    * def tokenAuth = response.token

    # 2. Crear contacto inicial
    Given path 'contacts'
    And header Authorization = 'Bearer ' + tokenAuth
    And request
      """
      {
        "firstName": "John",
        "lastName": "Doe",
        "birthdate": "1990-01-01",
        "email": "jdoe@fake.com",
        "phone": "8005555555",
        "street1": "1 Main St.",
        "street2": "Apartment A",
        "city": "Anytown",
        "stateProvince": "KS",
        "postalCode": "12345",
        "country": "USA"
      }
      """
    When method post
    Then status 201
    And match response._id == '#string'
    * def contactId = response._id

    # 3. Reemplazo total con PUT
    Given path 'contacts', contactId
    And header Authorization = 'Bearer ' + tokenAuth
    And request
      """
      {
        "firstName": "Amy",
        "lastName": "Miller",
        "birthdate": "1992-02-02",
        "email": "amiller@fake.com",
        "phone": "8005554242",
        "street1": "13 School St.",
        "street2": "Apt. 5",
        "city": "Washington",
        "stateProvince": "QC",
        "postalCode": "A1A1A1",
        "country": "Canada"
      }
      """
    When method put
    Then status 200
    And match response._id == contactId
    And match response contains
      """
      {
        "firstName": "Amy",
        "lastName": "Miller",
        "birthdate": "1992-02-02",
        "email": "amiller@fake.com",
        "phone": "8005554242",
        "street1": "13 School St.",
        "street2": "Apt. 5",
        "city": "Washington",
        "stateProvince": "QC",
        "postalCode": "A1A1A1",
        "country": "Canada"
      }
      """

    Given path 'contacts', contactId
    And header Authorization = 'Bearer ' + tokenAuth
    When method delete
    Then status 200

    Given path 'users', 'me'
    And header Authorization = 'Bearer ' + tokenAuth
    When method delete
    Then status 200