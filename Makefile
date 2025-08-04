SRC ?= backend.c mongoose/mongoose.c common.c
OUT ?= interscore
CFLAGS ?= -Wall -Wextra -Wpedantic -fshort-enums
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
	-lm -ljson-c

b-run:
	./$(OUT)

RSRC ?= rentnerend/rentnerend.cpp mongoose/mongoose.c common.c
ROUT ?= rentnerend/interscore-server
CPPFLAGS ?= -Wall -Wextra -Wpedantic -fpermissive -fPIC
LD_FLAGS ?= `pkg-config Qt6Widgets Qt6Multimedia --cflags --libs` -ljson-c

r-install:
	$(CXX) -o $(ROUT) $(RSRC) -O3 $(CPPFLAGS) $(LD_FLAGS) -s

r-debug:
	$(CXX) -o $(ROUT) $(RSRC) $(CPPFLAGS) $(LD_FLAGS) -g

r-fast:
	$(CXX) -o $(ROUT) $(RSRC) -fpermissive -fPIC $(LD_FLAGS)

r-run:
	./$(ROUT)

js:
	tsc --target es2017 frontend/script.ts

js-new:
	tsc --target es2017 new-frontend/script.ts

backer-install:
	mkdir -p ~/.config/obs-studio/basic/profiles
	mkdir -p ~/.config/obs-studio/basic/scenes
	cp obs/scenes/radball.json ~/.config/obs-studio/basic/scenes/
	cp -r obs/profiles/radball/ ~/.config/obs-studio/basic/profiles/
	mkdir -p /etc/nginx/
	cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.old || true
	cp nginx.conf /etc/nginx/nginx.conf

clean:
	[ -f input.old.json ] && mv input.old.json input.json
	rm -f rentnerend/interscore-rentnerend interscore frontend/script.js input.old.json
