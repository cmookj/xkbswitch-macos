all: xkbswitch
# https://developer.apple.com/documentation/apple-silicon/building-a-universal-macos-binary

SDK := $(shell xcrun --sdk macosx --show-sdk-path)

xkbswitch-x86: xkbswitch.swift
	swiftc -o $@ $< -framework Carbon -target x86_64-apple-macos10.15 -sdk $(SDK)

xkbswitch-arm: xkbswitch.swift
	swiftc -o $@ $< -framework Carbon -target arm64-apple-macos11 -sdk $(SDK)

xkbswitch: xkbswitch-x86 xkbswitch-arm
	lipo -create -output $@ $^

clean:
	rm -f xkbswitch xkbswitch-x86 xkbswitch-arm
