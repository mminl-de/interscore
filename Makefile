CC ?= cc
CFLAGS ?= -std=c99 -Wall -Wextra -Wpedantic

bdebug:
	@echo "TODO"

CXX ?= c++
CXXFLAGS ?= -std=c++17 -Wall -Wextra -Wpedantic -fPIC
ROUT ?= rentnerend/interscore-server
RSRC ?= rentnerend/main.cpp
QTFLAGS ?= `pkg-config Qt6Widgets Qt6Multimedia --cflags --libs`

rdebug:
	$(CXX) -o $(ROUT) $(RSRC) $(CXXFLAGS) $(QTFLAGS) -g

rrelease:
	$(CXX) -o $(ROUT) $(RSRC) $(CXXFLAGS) -O3 -s $(QTFLAGS)

rrun:
	./$(ROUT)
