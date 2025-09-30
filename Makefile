SRC ?= backend.c mongoose/mongoose.c
OUT ?= backend
CFLAGS ?= -Wall -Wextra -Wpedantic -fshort-enums
WIN_LIBS ?= -ljson-c -lwinpthread -lws2_32 -liphlpapi -luserenv
CC ?= cc
CXX ?= c++

# Windows compilation on Arch Linux needs mingw-w64-gcc
# It can be done without clang but i will not bother
win64-b:
	./win-pacman/copy_msys2_to_system.sh
	x86_64-w64-mingw32-gcc -static \
		-static-libgcc -static-libstdc++ \
		-o backend.exe $(SRC) \
		$(CFLAGS) \
		$(WIN_LIBS) \

win32-b:
	./win-pacman/copy_msys2_to_system.sh
	i686-w64-mingw32-gcc -static \
		-static-libgcc -static-libstdc++ \
		-o backend.exe $(SRC) \
		$(CFLAGS) \
		$(WIN_LIBS)

b-install:
	$(CC) -o $(OUT) $(SRC) \
	-Oz $(CFLAGS) -s \
	-ljson-c \
	cp backend docker-new/backend

b-debug:
	$(CC) -o $(OUT) $(SRC) \
	$(CFLAGS) -g \
	-ljson-c
	cp backend docker-new/backend

b-fast:
	$(CC) -o $(OUT) $(SRC) \
	-fshort-enums \
	-lm -ljson-c
	cp backend docker-new/backend

b-run:
	./$(OUT)

r-fast:
	${MAKE} --no-print-directory -C rentnerend fast

win64-r-old:
	${MAKE} --no-print-directory -C rentnerend win64-old

win32-r-old:
	${MAKE} --no-print-directory -C rentnerend win32-old

r-old:
	${MAKE} --no-print-directory -C rentnerend old

r-old-run:
	rentnerend/interscore-old

r-run:
	rentnerend/interscore

js:
	tsc --target es2017 frontend/script.ts

js-new:
	tsc --target es2017 new-frontend/script.ts

obs-install:
	mkdir -p ~/.config/obs-studio/basic/profiles
	mkdir -p ~/.config/obs-studio/basic/scenes
	cp obs/scenes/radball.json ~/.config/obs-studio/basic/scenes/
	cp -r obs/profiles/radball/ ~/.config/obs-studio/basic/profiles/

nginx-install:
	mkdir -p /etc/nginx/
	cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.old || true
	cp nginx.conf /etc/nginx/nginx.conf

clean:
	[ -f input.old.json ] && mv input.old.json input.json
	rm -f rentnerend/interscore-rentnerend interscore frontend/script.js input.old.json
