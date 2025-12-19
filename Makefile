b-install:
	${MAKE} --no-print-directory -C backend install
b-debug:
	${MAKE} --no-print-directory -C backend debug
b-fast:
	${MAKE} --no-print-directory -C backend fast
b-run:
	${MAKE} --no-print-directory -C backend run

js:
	m4 -DTS MessageType.m4 > frontend/MessageType.ts
	m4 -DTS MessageType.m4 > MessageType.ts
	bun build frontend/script.ts --target browser --outdir ./frontend --minify

flutter:
	m4 -DDART MessageType.m4 > rentnerend/lib/MessageType.dart

clean:
	rm -f backend interscore frontend/script.js
