
use "json"
use "debug"

interface BundleDep
  fun root_path(): String
  fun packages_path(): String
  fun ref fetch()?

interface tag ProjectRepo
  fun tag createDep(bundle: Bundle box, dep: JsonObject box): BundleDep?
  fun tag install(args: Array[String] box): JsonObject ref?

primitive ProjectRepoFactory
  fun apply(repoType: String box): ProjectRepo? =>
    match repoType
    | "github" => GithubProjectRepo
    | "local-git" => LocalGitProjectRepo
    | "local" => LocalProjectRepo
    else error
    end
