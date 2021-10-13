when not defined(emscripten) or defined(emscripten_worker):
  from wavecorepkg/db/vfs import nil
  from constants import nil
  vfs.readUrl = constants.address & "/" & constants.dbFilename
  vfs.register()

when defined(emscripten_worker):
  from wavecorepkg/client/emscripten_worker import nil
else:
  from gui import nil
  when isMainModule:
    gui.main()

