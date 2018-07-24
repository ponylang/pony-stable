use "ponytest"
use "collections"
use "files"
use "json"
use ".."

class TestDep is UnitTest
  new iso create() => None
  fun name(): String => "stable.Dep"

  fun apply(h: TestHelper) ? =>
    let path = FilePath(h.env.root as AmbientAuth, "stable/test/testdata/empty-deps")?
    let bundle = Bundle(path, LogNone, false)?
    var dep: DepAny

    var info: JsonObject box = JsonObject()
    h.assert_error({ ()? => Dep(bundle, info)? }, "empty JSON")

    // minimal github dep
    let github = Map[String, JsonType]
    github("type") = "github"
    github("repo") = "foo/bar"

    info = JsonObject.from_map(github)
    dep = Dep(bundle, info)?
    h.assert_eq[String]("https://github.com/foo/bar", (dep as DepGitHosted).url())
    h.assert_eq[String](path.join(".deps/foo/bar")?.path, dep.root_path())
    h.assert_eq[String](path.join(".deps/foo/bar")?.path, dep.packages_path())

    // complete github dep
    github("subdir") = "baz"
    github("tag") = "v1"

    info = JsonObject.from_map(github)
    dep = Dep(bundle, info)?
    h.assert_eq[String]("https://github.com/foo/bar", (dep as DepGitHosted).url())
    h.assert_eq[String](path.join(".deps/foo/bar")?.path, dep.root_path())
    h.assert_eq[String](path.join(".deps/foo/bar/baz")?.path, dep.packages_path())

    let incomplete_github = Map[String, JsonType]
    incomplete_github("type") = "github"
    info = JsonObject.from_map(incomplete_github)
    h.assert_error({ ()? => Dep(bundle, info)? }, "incomplete github dep info")

    // minimal local-git dep
    let local_git = Map[String, JsonType]
    local_git("type") = "local-git"
    local_git("local-path") = "../foo/bar"

    info = JsonObject.from_map(local_git)
    dep = Dep(bundle, info)?
    h.assert_eq[String](path.join(".deps/-foo-bar17972751887563456026")?.path, dep.root_path())
    h.assert_eq[String](path.join(".deps/-foo-bar17972751887563456026")?.path, dep.packages_path())

    // complete local-git dep
    local_git("tag") = "v2"

    info = JsonObject.from_map(local_git)
    dep = Dep(bundle, info)?
    h.assert_eq[String](path.join(".deps/-foo-bar17972751887563456026")?.path, dep.root_path())
    h.assert_eq[String](path.join(".deps/-foo-bar17972751887563456026")?.path, dep.packages_path())

    let incomplete_local_git = Map[String, JsonType]
    incomplete_local_git("type") = "local-git"
    info = JsonObject.from_map(incomplete_local_git)
    h.assert_error({ ()? => Dep(bundle, info)? }, "incomplete local-git dep info")

    // local dep
    let local = Map[String, JsonType]
    local("type") = "local"
    local("local-path") = "../foo/bar"

    info = JsonObject.from_map(local)
    dep = Dep(bundle, info)?

    h.assert_eq[String](Path.join(bundle.path.path, "../foo/bar"), dep.root_path())
    h.assert_eq[String](Path.join(bundle.path.path, "../foo/bar"), dep.packages_path())

    let incomplete_local = Map[String, JsonType]
    incomplete_local("type") = "local"
    info = JsonObject.from_map(incomplete_local)
    h.assert_error({ ()? => Dep(bundle, info)? }, "incomplete local dep info")

    // minimal gitlab dep
    let gitlab = Map[String, JsonType]
    gitlab("type") = "gitlab"
    gitlab("repo") = "foo/bar"

    info = JsonObject.from_map(gitlab)
    dep = Dep(bundle, info)?
    h.assert_eq[String]("https://gitlab.com/foo/bar", (dep as DepGitHosted).url())
    h.assert_eq[String](path.join(".deps/foo/bar")?.path, dep.root_path())
    h.assert_eq[String](path.join(".deps/foo/bar")?.path, dep.packages_path())

    // complete gitlab dep
    gitlab("subdir") = "baz"
    gitlab("tag") = "v1"

    info = JsonObject.from_map(gitlab)
    dep = Dep(bundle, info)?
    h.assert_eq[String]("https://gitlab.com/foo/bar", (dep as DepGitHosted).url())
    h.assert_eq[String](path.join(".deps/foo/bar")?.path, dep.root_path())
    h.assert_eq[String](path.join(".deps/foo/bar/baz")?.path, dep.packages_path())

    let incomplete_gitlab = Map[String, JsonType]
    incomplete_gitlab("type") = "gitlab"
    info = JsonObject.from_map(incomplete_gitlab)
    h.assert_error({ ()? => Dep(bundle, info)? }, "incomplete gitlab dep info")
