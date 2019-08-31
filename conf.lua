function love.conf(t)
  t.window.width, t.window.height = 456,456
  t.releases = {
    title = "MADOU",              -- The project title (string)
    package = nil,            -- The project command and package name (string)
    loveVersion = "0.11.2",        -- The project LÖVE version
    version = "0.1",            -- The project version
    author = "piano_no_renshu",             -- Your name (string)
    email = nil,              -- Your email (string)
    description = nil,        -- The project description (string)
    homepage = nil,           -- The project homepage (string)
    identifier = nil,         -- The project Uniform Type Identifier (string)
    excludeFileList = {},     -- File patterns to exclude. (string list)
    releaseDirectory = nil,   -- Where to store the project releases (string)
  }
end
