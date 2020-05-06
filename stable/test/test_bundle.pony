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
    h.assert_error(_BundleCreate(h.env, bundle("empty"))?, "no bundle.json")
    h.assert_error(_BundleCreate(h.env, bundle("bad/empty"))?, "empty bundle.json")
    h.assert_error(_BundleCreate(h.env, bundle("bad/wrong_format"))?, "wrong bundle.json")

    h.assert_no_error(_BundleCreate(h.env, bundle("empty-deps"))?, "empty deps")
    h.assert_no_error(_BundleCreate(h.env, bundle("github"))?, "github dep")
    h.assert_no_error(_BundleCreate(h.env, bundle("local-git"))?, "local-git dep")
    h.assert_no_error(_BundleCreate(h.env, bundle("local"))?, "local dep")


    h.assert_no_error(_BundleCreate(h.env, bundle("abitofeverything"))?, "mixed deps")

    h.assert_error(_BundleCreate(h.env, "notfound", true)?, "create in nonexistant directory")

    h.assert_no_error(_BundleCreate(h.env, bundle("empty"), true)?, "create in directory with no bunde.json")

    let file = FilePath(h.env.root as AmbientAuth, bundle("empty/bundle.json"))?
    h.assert_true(file.exists(), "empty bundle.json created")
    let f = OpenFile(file) as File
    let content: String = f.read_string(f.size())
    h.assert_eq[String]("{\"deps\":[]}\n", content)

  fun tear_down(h: TestHelper) =>
    let created_bundle = bundle("empty/bundle.json")
    try
      FilePath(h.env.root as AmbientAuth, created_bundle)?.remove()
    else
      h.log("failed to clean up " + created_bundle)
    end

class TestBundleSelfReferentialPaths is UnitTest
  new iso create() => None
  fun name(): String => "stable.Bundle.self-referential-paths"

  fun apply(h: TestHelper) ? =>
    let b = Bundle(_Path(h.env, "self-referential")?) ?
    let paths = b.paths()
    h.assert_eq[USize](1, paths.size())
    h.assert_true(paths(0)?
     .contains(Path.clean("stable/test/testdata/self-referential")))

class TestBundleMutuallyRecursivePaths is UnitTest
  new iso create() => None
  fun name(): String => "stable.Bundle.mutually-recursive-paths"
  fun apply(h: TestHelper) ? =>
    let bar_paths = Bundle(_Path(h.env, "mutually-recursive/bar")?)?.paths()
    let foo_paths = Bundle(_Path(h.env, "mutually-recursive/foo")?)?.paths()

    h.assert_eq[USize](1, bar_paths.size())
    h.assert_true(bar_paths(0)?
     .contains(Path.clean("stable/test/testdata/mutually-recursive/foo")))

    h.assert_eq[USize](1, foo_paths.size())
    h.assert_true(foo_paths(0)?
     .contains(Path.clean("stable/test/testdata/mutually-recursive/bar")))

primitive _Path
  fun apply(env: Env, relative_path: String) : FilePath ? =>
    FilePath(env.root as AmbientAuth,
      Path.join("stable/test/testdata", relative_path)
        .string())?

class _BundleCreate is ITest
  let path: FilePath
  let create_missing: Bool

  new create(env': Env val, path': String, create': Bool = false) ? =>
    path = FilePath(env'.root as AmbientAuth, path')?
    create_missing = create'

  fun apply() ? => Bundle(path, LogNone, create_missing)?
