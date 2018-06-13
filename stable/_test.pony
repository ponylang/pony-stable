use "ponytest"
use "files"

actor PrivateTests is TestList
  new create(env: Env) => PonyTest(env, this)
  new make() => None

  fun tag tests(test: PonyTest) =>
    test(_TestBundleLocator)

class _TestBundleLocator is UnitTest
  new iso create() => None
  fun name(): String => "stable._BundleLocator"

  fun bundle(subpath: String): String =>
    Path.join("stable/test/testdata", subpath).string()

  fun apply(h: TestHelper) ? =>
    h.assert_eq[String]("stable/test/testdata/nested",
      _BundleLocator(h.env, bundle("nested")) as String)

    // nested has one, but so does nested/deeply
    h.assert_eq[String]("stable/test/testdata/nested/deeply",
      _BundleLocator(h.env, bundle("nested/deeply")) as String)

    // nested/empty has no bundle.json
    h.assert_eq[String]("stable/test/testdata/nested",
      _BundleLocator(h.env, bundle("nested/empty")) as String)

    // stable itself has no bundle.json, so this ancestor-checking
    // from stable/test/testdata/empty yields no bundle.json
    h.assert_eq[None](None, _BundleLocator(h.env, bundle("empty")) as None)
