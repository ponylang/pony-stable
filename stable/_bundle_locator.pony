use "files"

class _BundleLocator
  let _auth: AmbientAuth
  let _log: Log
  new create(auth: AmbientAuth, log: Log) =>
    _auth = auth
    _log = log

  fun locate(start_path: String): (String | None) =>
    """
    find a path, starting from start_path, that contains a bundle.json,
    ascend into parent directories if none is found locally.
    """
    var path = start_path
    while path.size() > 0 do
      let candidate = try
          FilePath(_auth, path)?.join("bundle.json")?
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

  fun load_from_cwd(create_on_missing: Bool = false): Bundle ? =>
    """
    locate and load a bundle from the current working directory
    """
    let cwd = Path.cwd()
    match locate(cwd)
    | let path: String =>
        Bundle(FilePath(_auth, path)?, _log, false)?
    | None =>
        if create_on_missing then
          Bundle(FilePath(_auth, cwd)?, _log, true)?
        else
          _log("No bundle.json in current working directory or ancestors.")
          error
        end
    end

