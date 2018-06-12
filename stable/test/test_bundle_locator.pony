use "ponytest"
use "files"
use ".."

class TestBundleLocator is UnitTest
  new iso create() => None
  fun name(): String => "stable.BundleLocator"

  fun bundle(subpath: String): String =>
    Path.join("stable/test/testdata", subpath).string()

  fun apply(h: TestHelper) ? =>
    h.assert_eq[String]("stable/test/testdata/nested",
      BundleLocator(h.env, bundle("nested")) as String)

    // nested has one, but so does nested/deeply
    h.assert_eq[String]("stable/test/testdata/nested/deeply",
      BundleLocator(h.env, bundle("nested/deeply")) as String)

    // nested/empty has no bundle.json
    h.assert_eq[String]("stable/test/testdata/nested",
      BundleLocator(h.env, bundle("nested/empty")) as String)

    // stable itself has no bundle.json, so this ancestor-checking
    // from stable/test/testdata/empty yields no bundle.json
    h.assert_eq[None](None, BundleLocator(h.env, bundle("empty")) as None)
