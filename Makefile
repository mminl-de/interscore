OUT ?= interscore
CC ?= cc

install:
	$(CC) -o $(OUT) backend.c \
	-O3 -Wall -Wextra -Wpedantic \
	-lwebsockets -lssl -ljson-c

debug:
	$(CC) -o $(OUT) backend.c \
	-Wall -Wextra -Wpedantic -g \
	-lwebsockets -lssl -ljson-c

run: debug
	./interscore
