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

## Usage

### Docker
The current version is tailord to my server setup. A vps for static IP, connection to a dommainname. OBS hosted on a PC with dynamic IP and enough CPU/GPU Power to run obs and stream. This will be abstracted/automated in the future to be more flexible and easy to setup.
0. The VPS needs a user (interscore-tunnel) for which the Host-PC has a ssh-key.
1. make sure all ports are open on the VPS (8081, 4444)
2. `make b-install js-new`
3. cd docker/
4. Download obs binary with WebSocket support into ./ as obs
5. Change the path to the .ssh folder in the Makefile (default /home/mrmine/.ssh/) for yours
6. make build run
In docker we host a rtmp server. The streaming camera publishes to this server through rtmp. In order to have a static rtmp link we use a ddns service (and a CNAME DNS-Entry if you want to use your domain for rtmp as well). The config assumes a dyndns2 with dynu, the config can easily be changed though (docker/ddclient.conf)
1. set up an free account on dynu.com
2. change the address in docker/ddclient.conf to your ddns address
3. If wanted create CNAME DNS Entry in your Domain Registrar to forward to the ddns address
4. Add a port forwarding to the Docker-PC's local router with TCP and UDP on Port 1935 and a few above if you plan to host multiple docker instances
5. Give DNS credentials When running the image: cd docker; make run DYNU_LOGIN=blibla DYNU_PASSWORD=blub

## Demonstrations
- https://www.youtube.com/watch?v=3LFNC_H9lVw (a little unstable but brings the idea across)

# TODO

## meta
- FINAL^2 assets folder in seperate repo (only logos)
- FINAL^4 abstract program further to support other sports
	- Count time up instead of down (e.g. football)

## frontend
- Reversing der anzeige, je nach Kameraposition (in input.json)
- team logos for gamestart
- Fix Font Problems wth Umlaute in Cards section
- Widget spawn animation fixen(manchmal kaputt)
- Display Team in Cards Widget (Color/Background Color/Border Color/Logo)
- Dislpay Widgets for single groups/multiple groups etc
- FINAL make json_load resilient to bad input.json
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
- FINAL Seite: Ads unten (or Vollbild/Seite)
- FINAL kompliziertere Animation vom Spielwidget (einzelne Elemente kurz hintereinander reinanimieren, so dass es sich aufbaut)
- FINAL² Widget: Stats für Teams (Win/Loss/Tie, Tor geschossen/Tor gekriegt, %nach Halbzeitführung converted, Torwart/Feldspieler, vorherige Liga, aktueller Ligaplatz) Daten aus cycleball.eu/radball.at
- FINAL translations

## rentnerend
- URGENT widget pipelines:
	- 5s this widget, 5s that
	- absolute cinema
- JSON-Creator GUI for non-technical users
- allow changing time while the clock runs
- more keyboard binds
	- bind Ctrl-N for create new tournament
- @julian :) Import tournaments from cycleball.eu (and Radball.at when library is ready)
- Pause Button färben/Icon ändern, je nach Pause/Nicht Pause
- PDF Export
- @julian FINAL Import Spieler, Teams, Vereine, Ligen, Schiedsrichter for custom tournaments from cycleball.eu (and Radball.at)
- FINAL Reversing der anzeige im Anzeigefenster, je nach Position des Bildschirms/Beamers (maybe button anzeigen, wenn window im fokus?)
- FINAL additional button + functionality for half time and side switch (mark the button somehow, so the user just has to press space or enter and the halfs switch, the clock resets and Halftimeclock starts):
	- visual guides
- FINAL Add cycleball.eu push support
- FINAL Cards for Coaches: "Coach von Gifhorn 1 bekommt eine gelbe Karte"
- FINAL Ads in public window, e.g. fullscreen video/picture during a pause
- FINAL Next Game in public window, e.g. before the fullscreen ad during a pause
- FINAL delte cards
- FINAL deal with non-existing assets
- FINAL make json_load resilient to bad input.json
- FINAL FINAL add export to Spielplan-pdf:
	- we define a standard for what formular keys we expect
	- users can upload their template only if their matches our standard:
		- otherwise error dialog ig
	- we export the results as a writable formular
- FINAL² Add referees
- FINAL³ Idee: Ansagen durch KI bei der Hälfte

### design
- gray-black colorscheme
- primary colors for accents
- flat design language

## backend

## Docker
### Misc
- Check if we cant get obs appimage programmatically
### OBS
- Make replay System work properly, test it throughly
- Find a robust solution to combat delay (like blinking square)
- Let remoteend/rentnerend remotely start a stream-session
- Better UI for replays
- Better Transition-Animations
- Explore "hotkeys": {"ObsBrowser.Refresh"} option and others to hot reload frontend/rmtp stream etc.

## DEPRECATED Remoteend (rentnerend rewrite includes remoteend)
- Add Ability to start and end replay of a game
- FINAL Waterboard remoteend (dont kill websocket connection)
- FINAL server sends widgets status (on/off)
- FINAL Display Gamerelated information:
	- Scoreboard Infos: Teams playing, Score, Time, Half
	- Connection Status of all Clients (backend, rentnerend, frontend)
	- OBS Scene / replay situation
- FINAL FINAL Add different replay possibilities (?? make setting for: speed of replay, length of replay)
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
