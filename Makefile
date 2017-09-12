prefix ?= /usr/local
destdir ?= ${prefix}
config ?= release

BUILD_DIR ?= build/$(config)
SRC_DIR ?= stable
binary := $(BUILD_DIR)/stable

ifdef config
  ifeq (,$(filter $(config),debug release))
    $(error Unknown configuration "$(config)")
  endif
endif

ifeq ($(config),release)
	PONYC = ponyc
else
	PONYC = ponyc --debug
endif

SOURCE_FILES := $(shell find $(SRC_DIR) -name \*.pony)

$(binary): $(SOURCE_FILES) | $(BUILD_DIR)
	${PONYC} $(SRC_DIR) -o ${BUILD_DIR}

install: $(binary)
	mkdir -p $(prefix)/bin
	cp $^ $(prefix)/bin

clean:
	rm -rf $(BUILD_DIR)

all: $(binary)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

.PHONY: all clean install
