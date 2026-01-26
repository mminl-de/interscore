# needs coverage deps for coverage generation to work (see below)
CC ?= cc
SRC ?= test.c munit.c ../../backend/main.c ../../backend/mongoose/mongoose.c
OUT ?= tests
OUT_COV ?= tests-coverage
ARGS ?= -fshort-enums
LIB ?= -lm -ljson-c -DUNIT_TEST -D MG_TLS=MG_TLS_OPENSSL -lssl -lcrypto

all: compile
	./$(OUT)

# Needs lcov, gcov
coverage: clean
	$(CC) -O0 -g --coverage -fcondition-coverage -fprofile-arcs -ftest-coverage $(ARGS) $(SRC) -o $(OUT) $(LIB)
	./$(OUT)
	gcov $(OUT)-test.gcno
	lcov --branch-coverage --mcdc-coverage --capture --directory . --output-file coverage.info
	# remove external / system files
	lcov --branch-coverage --mcdc-coverage --remove coverage.info '/usr/*' '*mongoose.c' '*test.c' --output-file coverage.info
	genhtml -mcdc-coverage --branch-coverage coverage.info --output-directory coverage-html

compile:
	$(CC) $(ARGS) $(SRC) -o $(OUT) $(LIB)

clean:
	rm -rf *.gcno *.gcda *.gcov coverage-html $(OUT)
