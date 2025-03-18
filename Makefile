# Detect the init system
ifeq ($(shell command -v systemctl 2>/dev/null),)
    INIT_SYSTEM = openrc
else
    INIT_SYSTEM = systemd
endif

SRC ?= backend.c mongoose/mongoose.c common.c
OUT ?= interscore
CFLAGS ?= -Wall -Wextra -Wpedantic -fshort-enums
CC ?= cc
CXX ?= c++

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
CPPFLAGS ?= -Wall -Wextra -Wpedantic -fpermissive -fPIC
LD_FLAGS ?= `pkg-config Qt6Widgets Qt6Multimedia --cflags --libs` -ljson-c

r-install:
	$(CXX) -o $(ROUT) $(RSRC) -O3 $(CPPFLAGS) $(LD_FLAGS)

r-debug:
	$(CXX) -o $(ROUT) $(RSRC) $(CPPFLAGS) $(LD_FLAGS) -g

r-fast:
	$(CXX) -o $(ROUT) $(RSRC) -fpermissive -fPIC $(LD_FLAGS)

r-run:
	./$(ROUT)

js:
	tsc --target es2017 frontend/script.ts

backer-install:
	mkdir -p /srv/www/fonts
	cp fonts/Kanit-Regular.ttf /srv/www/fonts/
	cd frontend && cp *.css *.html *.js /srv/www/
	chmod 644 /srv/www/*
	chmod 755 /srv/www/fonts
	cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.old || true
	cp nginx.conf /etc/nginx/nginx.conf
ifeq ($(INIT_SYSTEM), systemd)
	systemctl stop nginx
	systemctl start nginx
else ifeq ($(INIT_SYSTEM), openrc)
	rc-service nginx stop
	rc-service nginx start
else
	@echo "WARNING: Unsupported init system. Skipping restarting nginx"
endif


clean:
	[ -f input.old.json ] && mv input.old.json input.json
	rm -f rentnerend/interscore-rentnerend interscore frontend/script.js input.old.json
