use "ponytest"
use ".."

class TestBundle is UnitTest
  new iso create() => None
  fun name(): String => "stable.Bundle"

  fun apply(h: TestHelper) =>
    h.assert_eq[String]("foo", "foo")
