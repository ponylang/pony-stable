use "json"
use "cli"

primitive AddCmd
  fun name(): String => "add"
  fun command_spec(): CommandSpec ? =>
    CommandSpec.leaf(
      name(),
      "Adds a new dependency to the local `bundle.json`.",
      [ // options
        OptionSpec.string(
          "tag",
          "Specifies a tag from the source repository",
          't',
          "")
        OptionSpec.string(
          "subdir",
          "Fetch only a subdirectory of the repository",
          'd',
          "")
      ],
      [  // args
        ArgSpec.string(
          "type",
          "The type of the dependency to add. Possible values: github, gitlab, local-git, local")
        ArgSpec.string(
          "source",
          "The path addressing the dependency to add. For github and gitlab: <ORGANIZATION>/<REPOSITORY>, for local-git and local: a path.")
      ]
    )?

  fun apply(cmd: Command, bundle: Bundle, log: Log) ? =>
    let kind = cmd.arg("type").string()
    let prim =
      match kind
      | "github" => AddGitHosted
      | "gitlab" => AddGitHosted
      | "local-git" => AddLocalGit
      | "local" => AddLocal
      else
        log("Couldn't find type '" + kind + "'.")
        log("Available types are github, gitlab, local-git, and local.")
        error
      end
    let info: JsonObject ref = JsonObject
    info.data("type") = kind.clone()
    prim(cmd, info)
    bundle.add_dep(info)?
    bundle.fetch()

primitive AddGitHosted
  fun apply(cmd: Command, info: JsonObject) =>
    info.data("repo") = cmd.arg("source").string()
    let git_tag = cmd.option("tag").string()
    if git_tag.size() > 0 then
      info.data("tag") = git_tag
    end
    let subdir = cmd.option("subdir").string()
    if subdir.size() > 0 then
      info.data("subdir") = subdir
    end

primitive AddLocalGit
  fun apply(cmd: Command, info: JsonObject) =>
    info.data("local-path") = cmd.arg("source").string()

    let git_tag = cmd.option("tag").string()
    if git_tag.size() > 0 then
      info.data("tag") = git_tag
    end

primitive AddLocal
  fun apply(cmd: Command, info: JsonObject) =>
    info.data("local-path") = cmd.arg("source").string()
