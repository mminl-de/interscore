SRC ?= backend.c mongoose/mongoose.c common.c
OUT ?= interscore
CFLAGS ?= -Wall -Wextra -Wpedantic -fshort-enums
CC ?= cc
CPPC ?= c++

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

RSRC ?= rentnerend/rentnerend.cpp mongoose/mongoose.c common.c
ROUT ?= rentnerend/interscore-rentnerend
QT_FLAGS ?= `pkg-config Qt6Widgets Qt6Multimedia --cflags --libs`

r-install:
	$(CPPC) -o $(ROUT) $(RSRC) \
	-O3 $(CFLAGS) -fpermissive -fPIC $(QT_FLAGS) \
	-ljson-c

r-debug:
	$(CPPC) -o $(ROUT) $(RSRC) \
	$(CFLAGS) $(QT_FLAGS) -fpermissive -fPIC -g \
	-ljson-c

r-fast:
	$(CPPC) -o $(ROUT) $(RSRC) \
	$(QT_FLAGS) -fpermissive -fPIC -ljson-c

r-run:
	./$(ROUT)

js:
	tsc --target es2017 frontend/script.ts

clean:
	[ -f input.old.json ] && mv input.old.json input.json
	rm -f rentnerend/interscore-rentnerend interscore frontend/script.js input.old.json
