SRC ?= backend.c mongoose/mongoose.c
OUT ?= interscore
CC ?= cc

install:
	$(CC) -o $(OUT) $(SRC) \
	-O3 -Wall -Wextra -Wpedantic \
	-ljson-c \

debug:
	$(CC) -o $(OUT) $(SRC) \
	-Wall -Wextra -Wpedantic -g \
	-ljson-c

fast:
	$(CC) -o $(OUT) $(SRC) \
	-ljson-c

run:

	./interscore

rentner:
	$(CC) -o rentnerend/rentnerend rentnerend/rentnerend.c \
	-O3 -Wall -Wextra -Wpedantic \
	`pkg-config gtk4 --cflags --libs` \
	-ljson-c

rentner-debug:
	$(CC) -o rentnerend/rentnerend rentnerend/rentnerend.c \
	-Wall -Wextra -Wpedantic -g \
	`pkg-config gtk4 --cflags --libs` \
	-ljson-c

rentner-test:
	c++ -o rentnerend/test rentnerend/test.cpp \
	-Wall -Wextra -Wpedantic -g \
	`pkg-config Qt6Widgets Qt6Core Qt6Gui --cflags --libs` \

js:
	tsc --target es2017 frontend/scoreboard.ts
