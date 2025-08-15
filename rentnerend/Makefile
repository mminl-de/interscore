SRC ?= *.cpp ../mongoose/mongoose.c
OLD_SRC ?= old_rentnerend.cc mongoose.o common.o
OUT ?= interscore
CXXFLAGS ?= -Wall -Wextra -Wpedantic -fpermissive -fPIC
LD_FLAGS ?= `pkg-config Qt6Widgets Qt6Multimedia --cflags --libs` -ljson-c
WIN_LD_FLAGS ?= -I/usr/x86_64-w64-mingw32/include/qt6 \
	-L/usr/x86_64-w64-mingw32/lib -lQt6Widgets.dll -lQt6Gui.dll -lQt6Core.dll \
	-lQt6Multimedia.dll -lQt6MultimediaWidgets.dll -lwinmm \
	-luser32 -lgdi32 -lshell32 -lws2_32 \
	-lole32 -loleaut32 -luuid -ljson-c

	#-I/usr/x86_64-w64-mingw32/include/c++/15.1.0 \
	#-I/usr/x86_64-w64-mingw32/include/c++/15.1.0/x86_64-w64-mingw32 \

# Windows compilation on Arch Linux needs mingw-w64-crt, mingw-w64-headers, mingw-w64-gcc
# On other pacman config:
# pacman -Syu --config win-pacman/p.conf mingw-w64-x86_64-qt6-base mingw-w64-x86_64-qt6-multimedia
# It can be done without clang but i will not bother
win64-old:
	../win-pacman/copy_msys2_to_system.sh || true
	x86_64-w64-mingw32-gcc -c ../common.c -o common.o
	x86_64-w64-mingw32-gcc -c ../mongoose/mongoose.c -o mongoose.o
	x86_64-w64-mingw32-g++ -std=gnu++17 -static \
		-static-libgcc -static-libstdc++ \
		-o interscore.exe $(OLD_SRC) \
		$(CXXFLAGS) $(WIN_LD_FLAGS) \

win32-old:
	../win-pacman/copy_msys2_to_system.sh
	clang --target=i686-windows-gnu -static \
		-static-libgcc -static-libstdc++ \
		$(CXXFLAGS) $(LD_FLAGS) \
		-o interscore.exe $(OLD_SRC)

install:
	$(CXX) -o $(OUT) $(SRC) -O3 $(CXXFLAGS) $(LD_FLAGS) -s

debug:
	$(CXX) -o $(OUT) $(SRC) $(CXXFLAGS) $(LD_FLAGS) -g

fast:
	$(CXX) -o $(OUT) $(SRC) -O0 -g0 -pipe -fpermissive -fPIC $(LD_FLAGS)

old:
	$(CXX) -o $(OUT)-old old_rentnerend.cc ../mongoose/mongoose.c ../common.c -fpermissive -fPIC $(LD_FLAGS)

run:
	./$(OUT)
