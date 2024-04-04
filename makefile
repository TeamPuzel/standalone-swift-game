
default:
	@echo Use "make run" to run the program

run: mac
	@./build/game

mac: game.o
	@ld -o build/game -syslibroot `xcrun -sdk macosx --show-sdk-path` -lc -arch arm64 -lsystem -lsdl2 -L/opt/homebrew/lib build/game.o

game.o: src/main.swift
	@swiftc -target arm64-apple-macosx14.0 -enable-experimental-feature Embedded -wmo -Xcc -fdeclspec -sdk /Applications/Xcode-beta.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX14.4.sdk -Xcc -I/opt/homebrew/include -Xcc -fmodule-map-file=sys/module.modulemap -parse-as-library -Osize src/main.swift -c -o build/game.o

clean:
	@rm -r build/*
