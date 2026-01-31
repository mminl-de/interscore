b-install:
	${MAKE} --no-print-directory -C backend install
b-debug:
	${MAKE} --no-print-directory -C backend debug
b-fast:
	${MAKE} --no-print-directory -C backend fast
b-run:
	${MAKE} --no-print-directory -C backend run

js:
	m4 -DTS MessageType.m4 > MessageType.ts
	cp MessageType.ts frontend/MessageType.ts # TODO
	bun install --cwd frontend
	bun build frontend/script.ts --target browser --outdir ./frontend --minify

f-m4:
	m4 -DDART MessageType.m4 > rentnerend/lib/MessageType.dart

f-freezed:
	${MAKE} --no-print-directory -C rentnerend freezed

f-run:
	${MAKE} --no-print-directory -C rentnerend flutter

clean:
	rm -f backend interscore frontend/script.js
