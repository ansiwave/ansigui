when defined(emscripten_worker):
  from wavecorepkg/client import nil
else:
  from gui import nil
  when isMainModule:
    gui.main()

