CC ?= cc

install:
	$(CC) -o backend backend.c \
	-Wall -Wextra -Wpedantic \
	-lwebsockets -ljson-c
