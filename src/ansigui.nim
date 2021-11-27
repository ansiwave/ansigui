when not defined(emscripten) or defined(emscripten_worker):
  from wavecorepkg/db/vfs import nil
  from ./constants import nil
  from wavecorepkg/paths import nil
  vfs.readUrl = paths.address & "/" & paths.boardsDir & "/" & paths.sysopPublicKey & "/" & paths.dbDir & "/" & paths.dbFilename
  vfs.register()

when defined(emscripten_worker):
  from wavecorepkg/client/emscripten import nil
else:
  from ./gui import nil
  when isMainModule:
    gui.main()

