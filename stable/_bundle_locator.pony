use "files"

primitive _BundleLocator
  fun apply(env: Env, start_path: String): (String | None) =>
    var path = start_path
    while path.size() > 0 do
      let candidate = try
          FilePath(env.root as AmbientAuth, path)?.join("bundle.json")?
        else
          return None
        end
      if candidate.exists() then
        return path
      else
        path = Path.split(path)._1
      end
    end

    None
