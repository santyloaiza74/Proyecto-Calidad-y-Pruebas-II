Feature: Pruebas de Contactos (CP-006)

  Background:
    * url baseUrl
  @CP-006
  Scenario: CP-006 Reemplazo total de la entidad contacto (PUT)
    Given path 'users'
    And request
      """
      {
        "firstName": "Boca",
        "lastName": "Juniors",
        "email": "boca.juniors@arg.com",
        "password": "boca123"
      }
      """
    When method post
    Then status 201
    * def tokenAuth = response.token

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
    * def contactId = response._id

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
    And match response.firstName != 'John'
    And match response.lastName != 'Doe'
    And match response.birthdate != '1990-01-01'
    And match response.email != 'jdoe@fake.com'
    And match response.phone != '8005555555'
    And match response.street1 != '1 Main St.'
    And match response.street2 != 'Apartment A'
    And match response.city != 'Anytown'
    And match response.stateProvince != 'KS'
    And match response.postalCode != '12345'
    And match response.country != 'USA'

    Given path 'users', 'me'
    And header Authorization = 'Bearer ' + tokenAuth
    When method delete
    Then status 200