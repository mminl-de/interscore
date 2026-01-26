CC ?= cc
SRC ?= main.c mongoose/mongoose.c
OUT ?= interscore-backend # TODO find better name
CFLAGS ?= -std=c23 -Wall -Wextra -Wpedantic -Wunused -Wunreachable-code -Wunused-macros -fshort-enums

install:
	$(CC) -o $(OUT) $(SRC) \
	-Oz $(CFLAGS) -s \
	-ljson-c \
	-D MG_TLS=MG_TLS_OPENSSL
debug:
	$(CC) -o $(OUT) $(SRC) \
	$(CFLAGS) -g \
	-ljson-c
fast:
	$(CC) -o $(OUT) $(SRC) \
	-fshort-enums \
	-lm -ljson-c \
	-D MG_TLS=MG_TLS_OPENSSL -lssl -lcrypto
run: fast
	./$(OUT)
