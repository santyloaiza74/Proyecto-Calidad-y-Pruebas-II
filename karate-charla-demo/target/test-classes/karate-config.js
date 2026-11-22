function fn() {
  var config = {
    baseUrl: 'https://thinking-tester-contact-list.herokuapp.com',
    testEmail: java.lang.System.getenv('TEST_EMAIL') || '',
    testPassword: java.lang.System.getenv('TEST_PASSWORD') || ''
  };
  karate.configure('connectTimeout', 15000);
  karate.configure('readTimeout', 15000);
  return config;
}