
prefix ?= /usr/local
destdir ?= ${prefix}
debug ?= no

ifeq ($(debug),no)
	PONYC = ponyc
else
	PONYC = ponyc --debug
endif

SOURCE_FILES := $(shell find . -name \*.pony)

bin/stable: ${SOURCE_FILES}
	mkdir -p bin
	${PONYC} stable -o bin

install: bin/stable
	mkdir -p $(prefix)/bin
	cp $^ $(prefix)/bin

clean:
	rm -rf bin

all: bin/stable

.PHONY: all install
