-- https://luals.github.io/wiki/configuration/#custom-configuration-file
return {
    Lua = {
       -- https://luals.github.io/wiki/settings/#runtimepath

       diagnostics = {
          enable = {
             "global-element",
             "lowercase-global"
          },
          disable = {
          }
       },

       -- https://luals.github.io/wiki/settings/#workspacelibrary
       --  "Used to add library implementation code and definition files to the
       --   workspace scope. An array of absolute/workspace-relative paths that will
       --   be added to the workspace diagnosis - meaning you will get completion and
       --   context from these files. Can be a file or directory. Files included here
       --   will have some features disabled such as renaming fields to prevent
       --   accidentally renaming your library files."
       workspace = {
          library = {
             -- This next line should be loaded from `/app/.luarc.json` but that doesn't work. Which is as
             -- documented since I launch with `--configfile`.
             "/home/mtdcy/WeakAuras2",

             -- These following three ones are in the right place, but they should likely be updated to avoid
             -- having the lua version number hard-coded.
             os.getenv("HOME") .. "/.luarocks/share/lua/5.1/",
             "/usr/local/lib/lua/5.1/",
             "/usr/local/share/lua/5.1/",
          }
       }
    }
}
