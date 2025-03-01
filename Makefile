SRC ?= backend.c mongoose/mongoose.c
OUT ?= interscore
CC ?= cc

b-install:
	$(CC) -o $(OUT) $(SRC) \
	-O3 -Wall -Wextra -Wpedantic \
	-ljson-c \

b-debug:
	$(CC) -o $(OUT) $(SRC) \
	-Wall -Wextra -Wpedantic -g \
	-ljson-c

b-fast:
	$(CC) -o $(OUT) $(SRC) \
	-ljson-c

b-run:

	./interscore

r-install:
	$(CC) -o rentnerend/rentnerend rentnerend/rentnerend.c mongoose/mongoose.c \
	-O3 -Wall -Wextra -Wpedantic \
	`pkg-config gtk4 --cflags --libs` \
	-ljson-c

r-debug:
	$(CC) -o rentnerend/rentnerend rentnerend/rentnerend.c mongoose/mongoose.c \
	-Wall -Wextra -Wpedantic -g \
	`pkg-config gtk4 --cflags --libs` \
	-ljson-c

r-fast:
	$(CC) -o rentnerend/rentnerend rentnerend/rentnerend.c mongoose/mongoose.c \
	`pkg-config gtk4 --cflags --libs` \
	-ljson-c

r-run:
	./rentnerend/rentnerend

js:
	tsc --target es2017 frontend/script.ts
