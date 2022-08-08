all: clean build;

build: FORCE
	scripts/build.sh

clean:
	rm -rf build

test: clean build
	scripts/test.sh

validate: clean build test
	scripts/sourcehawk.sh

secrets:
	scripts/generate_secrets.sh

update:
	scripts/generate_expected.sh

testUpdate: clean build update test

FORCE: