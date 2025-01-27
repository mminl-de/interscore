CC ?= cc

install:
	$(CC) -o backend backend.c \
	-Wall -Wextra -Wpedantic \
	-lwebsockets -ljson-c
<<<<<<< HEAD
=======

debug:
	$(CC) -o backend backend.c \
	-Wall -Wextra -Wpedantic -g \
	-lwebsockets -ljson-c
>>>>>>> 6a48314f6d18ebe9bd21e649549e20d52aaa0547
