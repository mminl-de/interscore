SRC ?= rentnerend.c
OUT ?= rentnerend
CC ?= cc

rentner:
	$(CC) -o $(OUT) $(SRC) \
	-O3 -Wall -Wextra -Wpedantic \
	`pkg-config gtk4 --cflags --libs`

run:
	./$(OUT)
