use "ponytest"
use "files"
use "process"
use ".."

actor EnvTests is TestList
  new create(env: Env) => PonyTest(env, this)
  new make() => None

  fun tag tests(test: PonyTest) =>
    test(TestEnvNoBundle)
    test(TestEnvEmptyBundleInSameDir)
    test(TestEnvBundleInSameDir)
    test(TestEnvBundleInSameDirWithCall)
    test(TestEnvBundleInParentDir)
    test(TestEnvBadBundleInNestedAndValidBundleInParentDir)

class TestEnvNoBundle is UnitTest
  new iso create() => None

  fun name(): String => "integration.Env(no tack.json)"

  fun apply(h: TestHelper) =>
    h.long_test(2_000_000_000)
    let tmp =
      try
        FilePath.mkdtemp(h.env.root as AmbientAuth,
          "stable/test/integration/tmp/")?
      else
        h.fail("failed to create temporary directory")
        h.complete(false)
        return
      end
    h.dispose_when_done(_CleanTmp(tmp))

    let notifier: ProcessNotify iso = _ExpectClient(h,
      None,
      ["No tack.json in current working directory or ancestors."],
      0)
    _Exec(h, "stable env", tmp.path, consume notifier)

class TestEnvEmptyBundleInSameDir is UnitTest
  new iso create() => None

  fun name(): String => "integration.Env(empty bundle in same directory)"

  fun apply(h: TestHelper) =>
    h.long_test(2_000_000_000)
    let tmp =
      try
        FilePath.mkdtemp(h.env.root as AmbientAuth,
          "stable/test/integration/tmp/")?
      else
        h.fail("failed to create temporary directory")
        h.complete(false)
        return
      end
    h.dispose_when_done(_CleanTmp(tmp))

    let f =
      try
        Directory(tmp)?.create_file("tack.json")?
      else
        h.fail("failed to create tack.json in temporary directory")
        h.complete(false)
        return
      end
    h.assert_true(f.write("{\"deps\":[]}\n"), "prepare tack.json")

    let notifier: ProcessNotify iso = _ExpectClient(h,
      ["PONYPATH=\n"], // empty
      None,
      0)
    _Exec(h, "stable env", tmp.path, consume notifier)

class TestEnvBundleInSameDir is UnitTest
  new iso create() => None

  fun name(): String => "integration.Env(bundle in same directory)"

  fun apply(h: TestHelper) =>
    h.long_test(2_000_000_000)
    let tmp =
      try
        FilePath.mkdtemp(h.env.root as AmbientAuth,
          "stable/test/integration/tmp/")?
      else
        h.fail("failed to create temporary directory")
        h.complete(false)
        return
      end
    h.dispose_when_done(_CleanTmp(tmp))

    let f =
      try
        Directory(tmp)?.create_file("tack.json")?
      else
        h.fail("failed to create tack.json in temporary directory")
        h.complete(false)
        return
      end
    h.assert_true(f.write("{\"deps\":[
      {\"type\": \"local\", \"local-path\":\"../local/a\"},
      {\"type\": \"local-git\", \"local-path\":\"../local-git/b\"},
      {\"type\": \"github\", \"repo\":\"github/c\"},
      {\"type\": \"gitlab\", \"repo\":\"gitlab/d\"}
      ]}\n"), "prepare tack.json")

    let expected =
      try
        Path.join(tmp.path, "../local/a") + ":" +
        tmp.join(".deps/-local-git-b16798852821555717647")?.path + ":" +
        tmp.join(".deps/github/c")?.path + ":" +
        tmp.join(".deps/gitlab/d")?.path
      else
        h.fail("failed to construct expected PONYPATH")
        h.complete(false)
        return
      end

    let notifier: ProcessNotify iso = _ExpectClient(h,
      ["PONYPATH=" + expected],
      None,
      0)
    _Exec(h, "stable env", tmp.path, consume notifier)

class TestEnvBundleInSameDirWithCall is UnitTest
  new iso create() => None

  fun name(): String => "integration.Env(calling a program)"

  fun apply(h: TestHelper) =>
    h.long_test(2_000_000_000)
    let tmp =
      try
        FilePath.mkdtemp(h.env.root as AmbientAuth,
          "stable/test/integration/tmp/")?
      else
        h.fail("failed to create temporary directory")
        h.complete(false)
        return
      end
    h.dispose_when_done(_CleanTmp(tmp))

    let f =
      try
        Directory(tmp)?.create_file("tack.json")?
      else
        h.fail("failed to create tack.json in temporary directory")
        h.complete(false)
        return
      end
    h.assert_true(f.write("{\"deps\":[
      {\"type\": \"local\", \"local-path\":\"../local/a\"}
      ]}\n"), "prepare tack.json")

    let notifier: ProcessNotify iso = _ExpectClient(h,
      ["../local/a"],
      None,
      0)
    _Exec(h, "stable env printenv PONYPATH", tmp.path, consume notifier)

class TestEnvBundleInParentDir is UnitTest
  new iso create() => None

  fun name(): String => "integration.Env(tack.json in parent dir)"

  fun apply(h: TestHelper) =>
    h.long_test(2_000_000_000)
    let tmp =
      try
        FilePath.mkdtemp(h.env.root as AmbientAuth,
          "stable/test/integration/tmp/")?
      else
        h.fail("failed to create temporary directory")
        h.complete(false)
        return
      end
    h.dispose_when_done(_CleanTmp(tmp))

    (let f, let nested) =
      try
        h.assert_true(Directory(tmp)?.mkdir("nested"), "create nested directory")
        let n = tmp.join("nested")?
        (Directory(tmp)?.create_file("tack.json")?, n)
      else
        h.fail("failed to create tack.json in nested temporary directory")
        h.complete(false)
        return
      end
    h.assert_true(f.write("{\"deps\":[
      {\"type\": \"local\", \"local-path\":\"../local/a\"}
      ]}\n"), "prepare tack.json")

    let notifier: ProcessNotify iso = _ExpectClient(h,
      ["PONYPATH=" + Path.join(tmp.path, "../local/a")],
      None,
      0)
    _Exec(h, "stable env", nested.path, consume notifier)

class TestEnvBadBundleInNestedAndValidBundleInParentDir is UnitTest
  new iso create() => None

  fun name(): String => "integration.Env(invalid tack.json in nested dir)"

  fun apply(h: TestHelper) =>
    h.long_test(2_000_000_000)
    let tmp =
      try
        FilePath.mkdtemp(h.env.root as AmbientAuth,
          "stable/test/integration/tmp/")?
      else
        h.fail("failed to create temporary directory")
        h.complete(false)
        return
      end
    h.dispose_when_done(_CleanTmp(tmp))

    (let bad_bundle, let good_bundle, let nested) =
      try
        h.assert_true(Directory(tmp)?.mkdir("nested"), "create nested directory")
        let n = tmp.join("nested")?
        (Directory(n)?.create_file("tack.json")?,
         Directory(tmp)?.create_file("tack.json")?,
         n)
      else
        h.fail("failed to create tack.json example data files")
        h.complete(false)
        return
      end
    h.assert_true(good_bundle.write("{\"deps\":[
      {\"type\": \"local\", \"local-path\":\"../local/a\"}
      ]}\n"), "prepare good tack.json")
    h.assert_true(bad_bundle.write("{}"), "prepare bad tack.json")

    // This verifies that the parent-dir tack.json isn't picked up if the
    // nested-dir tack.json is invalid.
    let notifier: ProcessNotify iso = _ExpectClient(h,
      ["PONYPATH=$"],
      ["JSON error at: " + bad_bundle.path.path + ": missing \"deps\" array"],
      0)
    _Exec(h, "stable env", nested.path, consume notifier)
