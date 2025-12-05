OLD_SRC ?= old_rentnerend.cc mongoose.o common.o
OUT ?= interscore
CXXFLAGS ?= -Wall -Wextra -Wpedantic -fpermissive -fPIC
LD_FLAGS ?= `pkg-config Qt6Widgets Qt6Multimedia --cflags --libs` -ljson-c

old:
	$(CXX) -o $(OUT)-old old_rentnerend.cc ../mongoose/mongoose.c ../common.c -D MG_TLS=MG_TLS_OPENSSL -lssl -lcrypto -fpermissive -fPIC $(LD_FLAGS)
