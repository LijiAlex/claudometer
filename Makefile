APP = Claudometer.app
BIN = .build/release/Claudometer

.PHONY: build app install uninstall test clean

build:
	swift build -c release

app: build
	rm -rf $(APP)
	mkdir -p $(APP)/Contents/MacOS
	cp $(BIN) $(APP)/Contents/MacOS/Claudometer
	cp Info.plist $(APP)/Contents/Info.plist

install: app
	rm -rf /Applications/$(APP)
	cp -R $(APP) /Applications/$(APP)
	@echo "Installed to /Applications/$(APP). Launch it from Spotlight."

uninstall:
	rm -rf /Applications/$(APP)

test:
	swift test

clean:
	rm -rf .build $(APP)
