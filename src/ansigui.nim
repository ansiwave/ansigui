when not defined(emscripten) or defined(emscripten_worker):
  from wavecorepkg/db/vfs import nil
  from ./constants import nil
  from wavecorepkg/board import nil
  vfs.readUrl = constants.address & "/" & board.sysopPublicKey & "/" & board.dbFilename
  vfs.register()

when defined(emscripten_worker):
  from wavecorepkg/client/emscripten import nil
else:
  from ./gui import nil
  when isMainModule:
    gui.main()

