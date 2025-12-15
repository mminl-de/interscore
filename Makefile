b-install:
	${MAKE} --no-print-directory -C backend install
b-debug:
	${MAKE} --no-print-directory -C backend debug
b-fast:
	${MAKE} --no-print-directory -C backend fast
b-run:
	${MAKE} --no-print-directory -C backend run

# TODO CONSIDER DEPRECATE
r-fast:
	${MAKE} --no-print-directory -C rentnerend fast

# Windows compilation on Arch Linux has several dependencies, see rentnerend/Makefile
win64-r-old:
	${MAKE} --no-print-directory -C rentnerend win64-old

r-old:
	${MAKE} --no-print-directory -C rentnerend old

r-old-run:
	rentnerend/interscore-old

r-run:
	rentnerend/interscore

js:
	m4 -DTS MessageType.m4 > frontend/MessageType.ts
	m4 -DTS MessageType.m4 > MessageType.ts
	bun build frontend/script.ts --target browser --outdir ./frontend --minify

flutter:
	m4 -DDART MessageType.m4 > flutter_rentnerend/lib/MessageType.dart

clean:
	[ -f input.old.json ] && mv input.old.json input.json
	rm -f backend rentnerend/interscore-rentnerend interscore frontend/script.js input.old.json
