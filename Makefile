APP_FILES=$(shell find . -type f -name '*.lua')
TARGET=rackspace-monitoring-agent

all: $(TARGET)

$(TARGET): lit $(APP_FILES)
	./lit make

test: lit
	./$(TARGET) -e tests

clean:
	rm -rf $(TARGET) lit

lit:
	curl -L https://github.com/luvit/lit/raw/1.0.3/get-lit.sh | sh

lint:
	find . -name "*.lua" | xargs luacheck

package:
	cmake -H. -Bbuild
	cmake --build build -- package

packagerepo:
	cmake --build build -- packagerepo

packagerepoupload:
	cmake --build build -- packagerepoupload

siggen:
	cmake --build build -- siggen

siggenupload:
	cmake --build build -- siggenupload

.PHONY: clean lint package packagerepo
