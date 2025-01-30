OUT ?= interscore
CC ?= cc

install:
	$(CC) -o $(OUT) backend.c lib/mongoose.c \
	-O3 -Wall -Wextra -Wpedantic \
	-ljson-c \

debug:
	$(CC) -o $(OUT) backend.c \
	-Wall -Wextra -Wpedantic -g \
	-ljson-c

fast:
	$(CC) -o $(OUT) backend.c lib/mongoose.c \
	-ljson-c \

run: debug
	./interscore
