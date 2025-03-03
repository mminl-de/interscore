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

QT_FLAGS ?= `pkg-config Qt6Widgets --cflags --libs`

r-install:
	g++ -o rentnerend/rentnerend rentnerend/rentnerend.cpp mongoose/mongoose.c \
	-O3 -Wall -Wextra -Wpedantic -fpermissive -fPIC \
	$(QT_FLAGS) \
	-ljson-c

r-debug:
	g++ -o rentnerend/rentnerend rentnerend/rentnerend.cpp mongoose/mongoose.c \
	-Wall -Wextra -Wpedantic -g -fpermissive \
	$(QT_FLAGS) \
	-ljson-c

r-fast:
	g++ -o rentnerend/rentnerend rentnerend/rentnerend.cpp mongoose/mongoose.c \
	-fpermissive -fPIC \
	$(QT_FLAGS) \
	-ljson-c

r-fasttester:
	g++ -o rentnerend/rentnerend rentnerend/rentnerend0.1.cpp \
	$(QT_FLAGS)

r-run:
	./rentnerend/rentnerend

js:
	tsc --target es2017 frontend/script.ts
