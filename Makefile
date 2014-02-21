.PHONY: setup build test clean

setup:
	@echo Setting up environment

	@which pod || gem install cocoapod
	@which storyboardlint || gem install storyboardlint
	@pod setup
	@pod install
	@brew upgrade xctool || brew install xctool
	@brew upgrade mogenerator || brew install mogenerator

build:
	@echo Building

	@xctool build \
  	-workspace Morsel.xcworkspace \
  	-scheme Morsel \
  	-sdk iphonesimulator7.0

test:
	@echo Testing

	@xctool \
  	-workspace Morsel.xcworkspace \
  	-scheme Morsel \
  	-sdk iphonesimulator7.0 \
  	-destination OS=7.0,name="iPhone Retina (4-inch)" \
		clean \
		test -only Morsel-Specs

clean:
	@echo Cleaning

	@xctool clean \
  	-workspace Morsel.xcworkspace \
  	-scheme Morsel
