CC ?= cc
SRC ?= main.c mongoose/mongoose.c
OUT ?= interscore-backend # TODO find better name
CFLAGS ?= -Wall -Wextra -Wpedantic -Wunreachable-code -fshort-enums -D MG_TLS=MG_TLS_OPENSSL -lm -lssl -lcrypto -ljson-c

install:
	$(CC) -o $(OUT) $(SRC) \
	-O3 $(CFLAGS) -s

debug:
	$(CC) -o $(OUT) $(SRC) \
	$(CFLAGS) -g

fast:
	$(CC) -o $(OUT) $(SRC) \
	$(CFLAGS)

run: fast
	./$(OUT)
