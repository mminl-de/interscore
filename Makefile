CC ?= cc

install:
	$(CC) -o backend backend.c \
	-Wall -Wextra -Wpedantic \
	-lwebsockets -ljson-c

debug:
	$(CC) -o backend backend.c \
	-Wall -Wextra -Wpedantic -g \
	-lwebsockets -ljson-c
