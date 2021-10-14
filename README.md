To develop, [install Nim](https://nim-lang.org/install.html) and do:

```
nimble run ansigui
```

Or to make a release build:

```
nimble build -d:release
```

Or to make a release build for the web:

```
nimble emscripten
```

NOTE: To build for the web, you must install Emscripten:

```
git clone https://github.com/emscripten-core/emsdk
cd emsdk
./emsdk install latest
./emsdk activate latest
# add the dirs that are printed by the last command to your PATH
```