# Interscore
A livestream system for Cycleball that includes an OBS overlay, software for the judges, independent backend, advanced replay system, Android app to manage the OBS Overlay/replays etc.
[cycleball.eu](https://cycleball.eu) integration and docker images for all the backend stuff are planned.

## About
The OBS overlay is a single HTML file launched via the Browser source.
The DOM contents are controlled via the WebSocket protocol using a CLI server program, meant for admins.
Another client uses Qt6 and is meant for the referees and the public display in the hall. The can change the HTML contents by using the server as the middleman.
Another client is a android app, which controls the contents or "widgets" of the Stream/HTML file. It also has the ability to trigger replays.

Tournament metadata (competing teams, timer lengths, game plan) is fed using a JSON file.

The overlay supports multiple "widgets" showing goals and the timer, teams participating in the tournament, currently playing teams and even red and yellow cards.

This project was made for our personal use prior to a Cycleball tournament under ridiculous deadlines.

## Related Projects
- Android App: https://github.com/mminl-de/interscore-remoteend
- cycleball.eu library: https://github.com/mminl-de/cycleu

## Usage (legacy)
### Linux:
1. `git clone --recursive https://github.com/hiimsergey/interscore && cd interscore`
2. Compile the frontend script and the binaries with `make js b-install r-old`.
3. Fill out `input.json` given the template at `input.template.json`.
4. Ensure your OBS edition supports Browser Source.
5. Configure OBS profile with `make obs-install`
6. Change the OBS profile to your liking and configure path to `frontend/index.html`
7. Either connect a camera through cable or whatever to obs and skip to 11. or when using RTMP follow the next steps
8. Download nginx with rtmp patch.
9. Use `make nginx-install` to configure
10. Start nginx and in your camera put the IP of your nginx machine with Port 1935
11. Launch the `backend` binary. (Or use `make b-run`)
12. Give the `interscore` binary to your nearest referee and set up the correct IP/URL in `rentnerend/old_rentnerend.cc`
13. Reload the HTML page so that you see `Client upgraded to WebSocket connection!` in the backend terminal.
14. Press `?` (followed by Enter/Return) in the backend terminal to see possible actions.
15. Download apk and install it on an android device
16. Set up the correct IP in the app
17. connect and now you can toggle all widgets and replays

## Demonstrations
- https://www.youtube.com/watch?v=3LFNC_H9lVw (a little unstable but brings the idea across)

# TODO

## top features
- "gorgeous" UI
- replay support
- mobile app
- PDF export

## meta
- FINAL Checkliste for streams
- FINAL^2 assets folder in seperate repo (only logos)
- Anleitung um docker aufzusetzen und nginx ws weiterleitung usw für die domain

## frontend
- URGENT Reversing der anzeige, je nach Kameraposition
- URGENT widget pipelines:
	- 5s this widget, 5s that
	- absolute cinema
- team logos for gamestart
- Fix Font Problems wth Umlaute in Cards section
- Widget spawn animation fixen(manchmal kaputt)
- Display Team in Cards Widget (Color/Background Color/Border Color/Logo)
- FINAL animate line by line
- FINAL comment all relevant CSS
- FINAL handle dealing multiple cards
- FINAL IDEA Time estimates:
	- time key in json
	- sending signal to frontend to calculate all estimates
	- frontend calculates difference between promised and actual game lengths
	- schedule delayed by this difference
	- calculations done only when calling the gameplan
- FINAL IDEA Fullscreen Endscore with Team Badge (maybe only winning) (Could have false positives when referee calls "letzter Schlag" or wants more time):
	- post-tournament stats (game data, nothing fancy)
- FINAL Wenn z.B. mind. 3 Tore hintereinander von einem Team innerhalb von 2 min passieren ohne Gegentore, ist Team "on fire" (siehe CS):
	- integer for streak (0 by default)
	- fixed size timer for streak
	- if a team scores, timer resets and streak increments
	- if timer runs out of opponents scores, streak gets reset
- FINAL Kartengrund unterstützen:
	- second dropdown in the rentnerend
	- with default values ("refusing to elaborate") or a custom one
- FINAL Widget: Aktuelle Livetabelle der gesamten Liga (cycleball.eu):
	- part of the pipeline???
- FINAL Widget: Aktuelle Spielliste des Parallel-Spieltags (cycleball.eu):
	- part of the pipeline???
- FINAL Seite: Ads unten (or Vollbild/Seite)
- FINAL kompliziertere Animation vom Spielwidget (einzelne Elemente kurz hintereinander reinanimieren, so dass es sich aufbaut)
- FINAL² Widget: Stats für Teams (Win/Loss/Tie, Tor geschossen/Tor gekriegt, %nach Halbzeitführung converted, Torwart/Feldspieler, vorherige Liga, aktueller Ligaplatz) Daten aus cycleball.eu/radball.at
- FINAL i18n

## rentnerend
- URGENT Reversing der anzeige im Anzeigefenster, je nach Position des Bildschirms/Beamers
- URGENT change all icons to nice looking icons
- bind Ctrl-N for create new tournament
- JSON-Creator GUI for non-technical users
- prohibit changing games while the clock runs
- Halbzeituhr
- Add possibility of teams missing:
	- start screen in the rentnerend
- @julian :) Import tournaments from cycleball.eu (and Radball.at when library is ready)
- FINAL additional button + functionality for half time and side switch (mark the button somehow, so the user just has to press space or enter and the halfs switch, the clock resets and Halftimeclock starts):
	- visual guides
- @julian FINAL Import Spieler, Teams, Vereine, Ligen, Schiedsrichter for custom tournaments from cycleball.eu (and Radball.at)
- Pause Button färben/Icon ändern, je nach Pause/Nicht Pause
- FINAL Support more tournament modes, support leagues:
	- group games are built different because of unknown game order
	- abstract "normal tournaments" away by putting their games into one group
	- group games will use multiple game
	- thus we add a logic to handle multiple groups that wont get used in "normal tournaments"
- FINAL Add cycleball.eu push support:
	- radball.at writing key written into json
	- (push button in rentnerend start screen and gear icon)
- FINAL make the Justice UI not suck
- FINAL Cards for Coaches:
	- "Coach von Gifhorn 1 bekommt eine gelbe Karte"
- FINAL Ads in public window:
	- fullscreen video during a pause
- FINAL Next Game in public window:
	- before the fullscreen ad during a pause
- FINAL FINAL port to windows/mac
- FINAL FINAL add export to Spielplan-pdf:
	- we define a standard for what formular keys we expect
	- users can upload their template only if their matches our standard:
		- otherwise error dialog ig
	- we export the results as a writable formular
- FINAL³ Idee: Ansagen durch KI bei der Hälfte
- FINAL delte cards
- FINAL² Add referees
- FINAL ENSURE assets are always found by the executable

### design
- gray-black colorscheme
- primary colors for accents
- flat design language

## backend
- OBS Replays sind noch bisschen buggy irgendwie
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
