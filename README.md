# Interscore
A livestream system for Cycleball that includes an OBS overlay, software for the judges, independent backend, advanced replay system, Android app to manage the OBS Overlay/replays etc.
[cycleball.eu](https://cycleball.eu) integration and docker images for all the backend stuff are planned.

## About
The OBS overlay is a single HTML file launched via the Browser source.
The DOM contents are controlled via the WebSocket protocol using a CLI server program, meant for admins.
Another client uses Qt6 and is meant for the referees and the public display in the hall. The can change the HTML contents by using the server as the middleman.

Tournament metadata (competing teams, timer lengths, game plan) is fed using a JSON file.

The overlay supports multiple "widgets" showing goals and the timer, teams participating in the tournament, currently playing teams and even red and yellow cards.

This project was made for our personal use prior to a Cycleball tournament under ridiculous deadlines.

## Related Projects
- Android App: https://github.com/mminl-de/interscore-remoteend
- cycleball.eu library: https://github.com/mminl-de/cycleu

## Usage (legacy)
1. `git clone --recursive https://github.com/hiimsergey/interscore && cd interscore`
2. Ensure your OBS edition supports Browser Source.
3. Compile the frontend script and the binaries with `make js b-install r-install`.
4. Fill out `input.json` given the template at `input.template.json`.
5. Open `frontnend/index.html` in OBS Studio and set appropriate dimensions.
6. Launch the `interscore` binary.
7. Give the `interscore-rentnerend` binary to your nearest referee.
8. Reload the HTML page so that you see `Client upgraded to WebSocket connection!` in the backend terminal.
9. Press `?` (followed by Enter/Return) in the backend terminal to see possible actions.

## Demonstrations
- https://www.youtube.com/watch?v=3LFNC_H9lVw (a little unstable but brings the idea across)

# TODO

## meta
- rediscuss backend, frontend, rentnerend tasks
- FINAL Checkliste for streams
- FINAL^2 assets folder in seperate repo (only logos)

## frontend
- fix time bugs
- refresh green balken every time the time changes, ont only when time is not paused
- team logos for gamestart
- Fix Font Problems wth Umlaute in Cards section
- Widget spawn animation fixen(manchmal kaputt)
- Display Team in Cards Widget (Color/Background Color/Border Color/Logo)
- FINAL animate line by line
- FINAL comment all relevant CSS
- FINAL handle dealing multiple cards
- FINAL IDEA Time estimates
- FINAL IDEA Fullscreen Endscore with Team Badge (maybe only winning) (Could have false positives when referee calls "letzter Schlag" or wants more time)
- FINAL kompliziertere Animation vom Spielwidget (einzelne Elemente kurz hintereinander reinanimieren, so dass es sich aufbaut)
- FINAL Wenn z.B. mind. 3 Tore hintereinander von einem Team innerhalb von 2 min passieren ohne Gegentore, ist Team "on fire" (siehe CS)
- FINAL Kartengrund unterstützen
- FINAL Logos im Spielwidget
- FINAL Widget: Stats für Teams (Win/Loss/Tie, Tor geschossen/Tor gekriegt, %nach Halbzeitführung converted, Torwart/Feldspieler, vorherige Liga, aktueller Ligaplatz) Daten aus cycleball.eu/radball.at
- FINAL Widget: Aktuelle Livetabelle der gesamten Liga (cycleball.eu)
- FINAL Widget: Aktuelle Spielliste des Parralel-Spieltags (cycleball.eu)
- FINAL Farb-Gradient automatisch generieren vom Logo/von einer Farbe
- FINAL Seite: Adds Vollbild/Seite/Unten
- FINAL Widget: Feedback/Suggestions

## rentnerend
- additional button + functionality for half time and side switch (mark the button somehow, so the user just has to press space or enter and the halfs switch, the clock resets and Halftimeclock starts)
- Halbzeituhr
- see and pardon in the justice system UI
- Add possibility of teams missing
- JSON-Creator GUI for non-technical users
- Import tournaments from cycleball.eu (and Radball.at when library is ready)
- FINAL Import Spieler, Teams, Vereine, Ligen, Schiedsrichter for custom tournaments from cycleball.eu (and Radball.at)
- FINAL Support more tournament modi, support leagues
- FINAL Add cycleball.eu push support
- FINAL make the Justice UI not suck
- FINAL Cards for Coaches
- FINAL Add referees
- FINAL Ads in public window
- FINAL Next Game in public window
- FINAL FINAL change all icons to nice looking icons
- FINAL FINAL port to windows/mac
- FINAL FINAL add export to Spielplan-pdf
- FINAL³ Idee: Ansagen durch KI bei der Hälfte

## backend
- OBS Replays sind noch bisschen buggy irgendwie
- Time is not send when hot reloading/sending json
- FINAL make json_load resilient to bad input.json
- FINAL FINAL graceful Ctrl-C handling
- FINAL^4 add ability to count time up(+verlängerung) for other sports
- FINAL^4 abstract program so it's applicable for other games

## OBS
- Make replay System work properly, test it throughly
- Find a robust solution to combat delay (like blinking square)
- Make docker image and let remoteend/rentnerend remotely start a stream-session
- Better UI for replays
- Better Transition-Animations

## Remoteend
- Add Ability to start and end replay of a game
- FINAL Look into possibility of preview
- FINAL Waterboard remoteend (dont kill websocket connection)
- FINAL server sends widgets status (on/off)
- FINAL Display Gamerelated information:
	- Scoreboard Infos: Teams playing, Score, Time, Half
	- Connection Status of all Clients (backend, rentnerend, frontend)
	- OBS Scene / replay situation
- FINAL FINAL Add different replay possibilities (?? make setting for: speed of replay, length of replay)
- FINAL FINAL hybrid auto search for server/hardcoded ip (autosearch with popup and ability to ignore)(later autoconnect to server-urls)
- FINAL FINAL Allow changing/select Streaming Service
- FINAL FINAL basically clone capabilities of rentnerend, so we dont actually need rentnerend if not wanted
	- Change input.json (e.g. Gameplan order, later create whole input.json with remoteend, import from cycleball.eu)
	- sync game data with rentnerend
	- Change game data: pause time, scores, cards, next game, etc.

## interscore.mminl.de
- UX improvement: look like frontend
- mobile friendly
- tutorial page
- more images and widgets
- in depth view on features, usage

# Interscore input-gui

## Plan
- wizard type
- three pages:
	- General game settings:
		- length of game: number input
		- number of players: number input
		- types of roles: string list
	- Team config:
		- two panes:
			- teams: string list
			- info for selected team:
				- name: text input
				- logo: image button with preview
				- players:
					- name: text input
					- position: dropdown
	- Games: widget list
- final page contains "Generate" button that asks for the JSON location

# stuff
ffplay command for low latency: `ffplay -fflags nobuffer -flags low_delay -framedrop -analyzeduration 0 -sync ext -noframedrop -rtmp_buffer 10 -infbuf rtmp://localhost/live/test`
