SRC ?= backend.c mongoose/mongoose.c
OUT ?= backend
CFLAGS ?= -Wall -Wextra -Wpedantic -fshort-enums
WIN_LIBS ?= -ljson-c -lwinpthread -lws2_32 -liphlpapi -luserenv
CC ?= cc
CXX ?= c++

b-install:
	$(CC) -o $(OUT) $(SRC) \
	-Oz $(CFLAGS) -s \
	-ljson-c \

b-debug:
	$(CC) -o $(OUT) $(SRC) \
	$(CFLAGS) -g \
	-ljson-c

b-fast:
	$(CC) -o $(OUT) $(SRC) \
	-fshort-enums \
	-lm -ljson-c \
	-D MG_TLS=MG_TLS_OPENSSL -lssl -lcrypto

b-run:
	./$(OUT)

r-fast:
	${MAKE} --no-print-directory -C rentnerend fast

# Windows compilation on Arch Linux has several dependencies, see rentnerend/Makefile
win64-r-old:
	${MAKE} --no-print-directory -C rentnerend win64-old

r-old:
	${MAKE} --no-print-directory -C rentnerend old

r-old-run:
	rentnerend/interscore-old

r-run:
	rentnerend/interscore

js:
	tsc --target es2017 frontend/script.ts

js-new:
	m4 -DTS MessageType.m4 > MessageType.ts
	tsc --target es2017 new-frontend/script.ts

flutter:
	m4 -DDART MessageType.m4 > flutter_rentnerend/lib/MessageType.dart

clean:
	[ -f input.old.json ] && mv input.old.json input.json
	rm -f backend rentnerend/interscore-rentnerend interscore frontend/script.js input.old.json
