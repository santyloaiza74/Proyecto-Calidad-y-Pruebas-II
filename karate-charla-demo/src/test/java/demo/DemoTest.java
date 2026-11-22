package demo;

import com.intuit.karate.junit5.Karate;

class DemoTest {

    @Karate.Test
    Karate testAll() {
        return Karate.run("classpath:demo").relativeTo(getClass());
    }
}