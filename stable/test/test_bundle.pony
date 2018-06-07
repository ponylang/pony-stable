use "ponytest"
use "files"
use ".."

class TestBundle is UnitTest
  new iso create() => None
  fun name(): String => "stable.Bundle"

  fun bundle(subpath: String): String =>
    Path.join("stable/test/testdata", subpath).string()

  fun apply(h: TestHelper) ? =>
    h.assert_error(_BundleCreate(h.env, "notfound")?, "nonexistant directory")
    h.assert_error(_BundleCreate(h.env, bundle(""))?, "no bundle.json")
    h.assert_error(_BundleCreate(h.env, bundle("bad/empty"))?, "empty bundle.json")
    h.assert_error(_BundleCreate(h.env, bundle("bad/wrong_format"))?, "wrong bundle.json")

    h.assert_no_error(_BundleCreate(h.env, bundle("empty-deps"))?, "empty deps")
    h.assert_no_error(_BundleCreate(h.env, bundle("github"))?, "github dep")
    h.assert_no_error(_BundleCreate(h.env, bundle("local-git"))?, "local-git dep")
    h.assert_no_error(_BundleCreate(h.env, bundle("local"))?, "local dep")

    h.assert_no_error(_BundleCreate(h.env, bundle("abitofeverything"))?, "mixed deps")


class _BundleCreate is ITest
  let path: FilePath

  new create(env': Env val, path': String) ? =>
    path = FilePath(env'.root as AmbientAuth, path')?

  fun apply() ? => Bundle(path, LogNone, false)?
