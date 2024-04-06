
SOURCES = $(wildcard src/*.swift) $(wildcard src/Core/*.swift) $(wildcard src/Core/Platform/*.swift)
MACSDK = /Applications/Xcode-beta.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX14.4.sdk
MACINCLUDE = /opt/homebrew/include

default:
	@echo Please use a specific command:
	@echo "run - run the native target"
	@echo "wasm - build for the wasm target"
	@echo "clean - erase the build folder"

run: mac
	@./build/game

mac:
	@swiftc -target arm64-apple-macosx14.0 -enable-experimental-feature Embedded -wmo -Xcc -fdeclspec -sdk $(MACSDK) -Xcc -I$(MACINCLUDE) -Xcc -fmodule-map-file=sys/module.modulemap -parse-as-library -Osize $(SOURCES) -c -o build/game-native.o
	@ld -o build/game -syslibroot `xcrun -sdk macosx --show-sdk-path` -lc -arch arm64 -lsystem -lsdl2 -L/opt/homebrew/lib build/game-native.o

wasm:
	@clang -target wasm32-none-wasm runtime/runtime.c -c -o build/runtime.o -nostdlib
	@swiftc -target wasm32-none-wasm -enable-experimental-feature Embedded -wmo -Xcc -fdeclspec -parse-as-library -Osize $(SOURCES) -c -o build/game-wasm.o
	@wasm-ld build/game-wasm.o build/runtime.o -o web/src/game.wasm --no-entry --export main --export frame --allow-undefined

clean:
	@rm -r build/*
