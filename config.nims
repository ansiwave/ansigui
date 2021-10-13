when defined(emscripten):
  # This path will only run if -d:emscripten is passed to nim.

  --nimcache:tmp # Store intermediate files close by in the ./tmp dir.

  --os:linux # Emscripten pretends to be linux.
  --cpu:wasm32 # Emscripten is 32bits.
  --cc:clang # Emscripten is very close to clang, so we ill replace it.
  when defined(windows):
    --clang.exe:emcc.bat  # Replace C
    --clang.linkerexe:emcc.bat # Replace C linker
    --clang.cpp.exe:emcc.bat # Replace C++
    --clang.cpp.linkerexe:emcc.bat # Replace C++ linker.
  else:
    --clang.exe:emcc  # Replace C
    --clang.linkerexe:emcc # Replace C linker
    --clang.cpp.exe:emcc # Replace C++
    --clang.cpp.linkerexe:emcc # Replace C++ linker.
  --listCmd # List what commands we are running so that we can debug them.

  --gc:arc # GC:arc is friendlier with crazy platforms.
  --exceptions:goto # Goto exceptions are friendlier with crazy platforms.
  --define:noSignalHandler # Emscripten doesn't support signal handlers.

  --define:useMalloc
  --opt:size

  # Pass this to Emscripten linker to generate html file scaffold for us.
  when defined(emscripten_worker):
    switch("passL", "-o worker.js -s USE_WEBGL2=1 -s EXPORTED_FUNCTIONS=\"['_main','_recvAction']\" -s BUILD_AS_WORKER")
  else:
    switch("passL", "-o index.html -s USE_WEBGL2=1 --shell-file shell_minimal.html")
elif defined(release):
  --app:gui

--define:chafa
--define:staticSqlite

when not defined(emscripten):
  --threads:on
