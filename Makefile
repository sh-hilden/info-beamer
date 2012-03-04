# See Copyright Notice in LICENSE.txt

RELEASE = 0.9-beta

VERSION = $(RELEASE).$(shell git rev-parse --short=6 HEAD)

ifdef DEBUG
CFLAGS ?= -ggdb -DDEBUG
else
CFLAGS ?= -O3 -DNDEBUG
endif

LUA_CFLAGS  ?= $(shell pkg-config lua5.1 --cflags)
LUA_LDFLAGS ?= $(shell pkg-config lua5.1 --libs)

CFLAGS += -DVERSION='"$(VERSION)"'
CFLAGS += $(LUA_CFLAGS) -I/usr/include/freetype2/ -I/usr/include/ffmpeg -std=c99 -Wall -Wno-unused-function -Wno-unused-variable -Wno-deprecated-declarations 
LDFLAGS = $(LUA_LDFLAGS) -levent -lglfw -lGL -lGLU -lGLEW -lftgl -lpng -ljpeg -lavformat -lavcodec -lavutil -lswscale -lz 

all: info-beamer

info-beamer: main.o image.o font.o video.o shader.o vnc.o framebuffer.o misc.o tlsf.o struct.o
	$(CC) -o $@ $^ $(LDFLAGS) 

doc:
	$(MAKE) -C doc

main.o: main.c kernel.h userlib.h

bin2c: bin2c.c
	$(CC) $^ -o $@

%.h: %.lua bin2c $(LUAC)
	luac -o $<.compiled $<
	./bin2c $* < $<.compiled > $@

.PHONY: clean doc

clean:
	rm -f *.o info-beamer kernel.h userlib.h bin2c *.compiled
	$(MAKE) -C doc clean
