@ignore
Feature: Helper de autenticación y creación de usuario

  Background:
    * url baseUrl

  Scenario: Registrar usuario temporal y obtener token
    * def emailUnico = 'user_' + java.util.UUID.randomUUID() + '@cyp.com'
    * def passwordDefecto = 'Password1234'

    Given path 'users'
    And request
      """
      {
        "firstName": "Proyecto",
        "lastName": "CyP",
        "email": "#(emailUnico)",
        "password": "#(passwordDefecto)"
      }
      """
    When method post
    Then status 201
    * def tokenAuth = response.token
    * def userData = { email: '#(emailUnico)', password: '#(passwordDefecto)', token: '#(tokenAuth)' }