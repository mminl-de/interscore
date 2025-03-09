SRC ?= backend.c mongoose/mongoose.c
OUT ?= interscore
CFLAGS ?= -Wall -Wextra -Wpedantic -fshort-enums
CC ?= cc

b-install:
	$(CC) -o $(OUT) $(SRC) \
	-O3 $(CFLAGS) \
	-ljson-c \

b-debug:
	$(CC) -o $(OUT) $(SRC) \
	$(CFLAGS) -g \
	-ljson-c

b-fast:
	$(CC) -o $(OUT) $(SRC) \
	-fshort-enums \
	-ljson-c

b-run:
	./$(OUT)

RSRC ?= rentnerend/rentnerend.c mongoose/mongoose.c
ROUT ?= rentnerend/rentnerend

r-install:
	$(CC) -o $(ROUT) $(RSRC) \
	-O3 $(CFLAGS) \
	`pkg-config gtk4 --cflags --libs` \
	-ljson-c

r-debug:
	$(CC) -o $(ROUT) $(RSRC) \
	$(CFLAGS) -g \
	`pkg-config gtk4 --cflags --libs` \
	-ljson-c

r-fast:
	$(CC) -o $(ROUT) $(RSRC) \
	`pkg-config gtk4 --cflags --libs` \
	-ljson-c

r-run:
	./$(ROUT)

js:
	tsc --target es2017 frontend/script.ts
