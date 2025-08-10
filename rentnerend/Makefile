SRC ?= *.cpp ../mongoose/mongoose.c
OUT ?= interscore
CXXFLAGS ?= -Wall -Wextra -Wpedantic -fpermissive -fPIC
LD_FLAGS ?= `pkg-config Qt6Widgets Qt6Multimedia --cflags --libs` -ljson-c

install:
	$(CXX) -o $(OUT) $(SRC) -O3 $(CXXFLAGS) $(LD_FLAGS) -s

debug:
	$(CXX) -o $(OUT) $(SRC) $(CXXFLAGS) $(LD_FLAGS) -g

fast:
	$(CXX) -o $(OUT) $(SRC) -fpermissive -fPIC $(LD_FLAGS)

old:
	$(CXX) -o $(OUT)-old old_rentnerend.cc ../mongoose/mongoose.c ../common.c -fpermissive -fPIC $(LD_FLAGS)

run:
	./$(OUT)
