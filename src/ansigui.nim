when not defined(emscripten) or defined(emscripten_worker):
  from wavecorepkg/db/vfs import nil
  from ./constants import nil
  from wavecorepkg/paths import nil
  vfs.readUrl = constants.address & "/" & paths.db(paths.sysopPublicKey)
  vfs.register()

when defined(emscripten_worker):
  from wavecorepkg/client/emscripten import nil
else:
  from ./gui import nil
  when isMainModule:
    gui.main()

