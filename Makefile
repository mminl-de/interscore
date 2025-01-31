SRC ?= backend.c lib/mongoose.c
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
	-ljson-c \

frontend/scoreboard.js:
	tsc frontend/main.ts

run: frontend debug
	./interscore
