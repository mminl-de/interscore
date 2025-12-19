CC ?= cc
SRC ?= main.c mongoose/mongoose.c
OUT ?= interscore-backend # TODO find better name
CFLAGS ?= -Wall -Wextra -Wpedantic -Wunused -Wunreachable-code -Wunused-macros -fshort-enums
# TODO CONSIDER DEPRECATE
WIN_LIBS ?= -ljson-c -lwinpthread -lws2_32 -liphlpapi -luserenv

install:
	$(CC) -o $(OUT) $(SRC) \
	-Oz $(CFLAGS) -s \
	-ljson-c
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
