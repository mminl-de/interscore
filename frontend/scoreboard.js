var socket = new WebSocket("ws://localhost:8080", "interscore");
socket.binaryType = "arraybuffer";
var scoreboard_team_1 = document.querySelector(".scoreboard > .team-1");
var scoreboard_team_2 = document.querySelector(".scoreboard > .team-2");
var scoreboard_score_1 = document.querySelector(".scoreboard > .score-1");
var scoreboard_score_2 = document.querySelector(".scoreboard > .score-2");
var game_plan_team_1 = document.querySelector(".game-plan > .team-1");
var game_plan_team_2 = document.querySelector(".game-plan > .team-2");
var game_plan_score_1 = document.querySelector(".game-plan > .score-1");
var game_plan_score_2 = document.querySelector(".game-plan > .score-2");
var card_graphic = document.querySelector(".card-graphic");
var card_receiver = document.querySelector(".card-receiver");
var card_message = document.querySelector(".card-message");
var BUFFER_LEN = 100;
function write_scoreboard(view) {
    console.log("Writing data to scoreboard:\n", view);
    var offset = 1;
    var team_1 = "";
    var team_2 = "";
    for (var i = 0; i < BUFFER_LEN; ++i) {
        team_1 += String.fromCharCode(view.getUint8(offset));
        team_2 += String.fromCharCode(view.getUint8(offset + BUFFER_LEN));
        ++offset;
    }
    scoreboard_team_1.innerHTML = team_1.toString();
    scoreboard_team_2.innerHTML = team_2.toString();
    scoreboard_score_1.innerHTML = view.getUint8(1 + 2 * BUFFER_LEN).toString();
    scoreboard_score_2.innerHTML = view.getUint8(1 + 2 * BUFFER_LEN + 1).toString();
    // TODO
    // let is_halftime = view.getUint8(202)
}
function write_game_plan(view) {
    var offset = 1;
    var games_n = view.getUint8(offset);
    ++offset;
    for (var game = 0; game < games_n; ++game) {
        var team_1 = "";
        var team_2 = "";
        for (var name_char = 0; name_char < BUFFER_LEN; ++name_char) {
            team_1 += String.fromCharCode(view.getUint8(offset));
            team_2 += String.fromCharCode(view.getUint8(offset + games_n * BUFFER_LEN));
            ++offset;
        }
        game_plan_team_1.innerHTML = team_1.toString();
        game_plan_team_2.innerHTML = team_2.toString();
        ++offset;
    }
}
function write_card(view) {
    var offset = 1;
    var receiver = "";
    for (var name_1 = 0; name_1 < BUFFER_LEN; ++name_1) {
        receiver += String.fromCharCode(view.getUint8(offset));
        ++offset;
    }
    card_receiver.innerHTML = receiver.toString();
    var is_red = view.getUint8(offset);
    if (is_red === 1) {
        card_graphic.style.backgroundColor = "#ff0000";
        card_message.innerHTML = "bekommt eine rote Karte";
    }
    else {
        card_graphic.style.backgroundColor = "#ffff00";
        card_message.innerHTML = "bekommt eine gelbe Karte";
    }
}
socket.onopen = function () {
    console.log("Connected to WebSocket server!");
};
socket.onmessage = function (event) {
    // TODO
    if (!(event.data instanceof ArrayBuffer))
        console.error("Sent data is not in proper binary format!");
    console.log("TODO about to receive data");
    var buffer = event.data;
    var view = new DataView(buffer);
    var mode = view.getUint8(0);
    switch (mode) {
        case 0:
            return;
        case 2:
            console.log("Operating in mode 0 (Scoreboard enabled)");
            write_scoreboard(view);
            break;
    }
    console.log("done");
};
socket.onerror = function (error) {
    console.error("WebSocket Error: ", error);
};
socket.onclose = function () {
    console.log("WebSocket connection closed!");
};
console.log("TODO: hi from scoreboard.js (this always runs)");
