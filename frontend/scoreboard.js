let socket = new WebSocket("ws://localhost:8080", "interscore");
socket.binaryType = "arraybuffer";
let scoreboard_t1 = document.querySelector(".scoreboard .t1");
let scoreboard_t2 = document.querySelector(".scoreboard .t2");
let scoreboard_score_1 = document.querySelector(".scoreboard .score-1");
let scoreboard_score_2 = document.querySelector(".scoreboard .score-2");
let scoreboard_time_minutes = document.querySelector(".scoreboard .time .minutes");
let scoreboard_time_seconds = document.querySelector(".scoreboard .time .seconds");
let game_plan_t1 = document.querySelector(".game-plan .t1");
let game_plan_t2 = document.querySelector(".game-plan .t2");
let game_plan_score_1 = document.querySelector(".game-plan .score-1");
let game_plan_score_2 = document.querySelector(".game-plan .score-2");
let card_graphic = document.querySelector(".card-graphic");
let card_receiver = document.querySelector(".card-receiver");
let card_message = document.querySelector(".card-message");
const BUFFER_LEN = 100;
function write_scoreboard(view) {
    console.log("Writing data to scoreboard:\n", view);
    let offset = 1;
    let t1 = "";
    let t2 = "";
    for (let i = 0; i < BUFFER_LEN && !(view.getUint8(offset) == 0); ++i) {
        t1 += String.fromCharCode(view.getUint8(offset));
        ++offset;
    }
    offset = 1;
    for (let i = 0; i < BUFFER_LEN && !(view.getUint8(offset) == 0); ++i) {
        t2 += String.fromCharCode(view.getUint8(BUFFER_LEN + offset));
        ++offset;
    }
    scoreboard_t1.innerHTML = t1.toString();
    scoreboard_t2.innerHTML = t2.toString();
    scoreboard_score_1.innerHTML = view.getUint8(offset).toString();
    ++offset;
    scoreboard_score_2.innerHTML = view.getUint8(offset).toString();
    ++offset;
    // TODO
    //const is_halftime = view.getUint8(offset)
    //++offset
}
function write_game_plan(view) {
    let offset = 1;
    const games_n = view.getUint8(offset);
    ++offset;
    for (let game = 0; game < games_n; ++game) {
        let t1 = "";
        let t2 = "";
        for (let name_char = 0; name_char < BUFFER_LEN; ++name_char) {
            t1 += String.fromCharCode(view.getUint8(offset));
            t2 += String.fromCharCode(view.getUint8(offset + games_n * BUFFER_LEN));
            ++offset;
        }
        game_plan_t1.innerHTML = t1.toString();
        game_plan_t2.innerHTML = t2.toString();
        ++offset;
    }
}
function write_card(view) {
    let offset = 1;
    let receiver = "";
    for (let name = 0; name < BUFFER_LEN; ++name) {
        receiver += String.fromCharCode(view.getUint8(offset));
        ++offset;
    }
    card_receiver.innerHTML = receiver.toString();
    const is_red = view.getUint8(offset);
    if (is_red === 1) {
        card_graphic.style.backgroundColor = "#ff0000";
        card_message.innerHTML = "bekommt eine rote Karte";
    }
    else {
        card_graphic.style.backgroundColor = "#ffff00";
        card_message.innerHTML = "bekommt eine gelbe Karte";
    }
}
function scoreboard_set_timer(view) {
    let offset = 1;
    const time_in_s = view.getUint16(offset);
    scoreboard_time_minutes.innerHTML = Math.floor(time_in_s / 60).toString().padStart(2, "0");
    scoreboard_time_seconds.innerHTML = (time_in_s % 60).toString().padStart(2, "0");
    start_timer(time_in_s);
}
// TODO FINAL MOVE TOP
let countdown;
let remaining_time = 0;
function start_timer(time_in_s) {
    clearInterval(countdown);
    remaining_time = time_in_s;
    update_display();
    countdown = setInterval(() => {
        if (remaining_time > 0) {
            --remaining_time;
            update_display();
        }
        else
            clearInterval(countdown);
    }, 1000);
}
function update_display() {
    const minutes = Math.floor(remaining_time / 60).toString().padStart(2, "0");
    const seconds = (remaining_time % 60).toString().padStart(2, "0");
    scoreboard_time_minutes.innerHTML = minutes;
    scoreboard_time_seconds.innerHTML = seconds;
}
socket.onopen = () => {
    console.log("Connected to WebSocket server!");
};
socket.onmessage = (event) => {
    // TODO
    console.log("TODO about to receive data");
    if (!(event.data instanceof ArrayBuffer))
        console.error("Sent data is not in proper binary format!");
    let buffer = event.data;
    let view = new DataView(buffer);
    const mode = view.getUint8(0);
    switch (mode) {
        case 0:
            return;
        case 2:
            console.log("Operating in mode 0 (Scoreboard enabled)");
            write_scoreboard(view);
            break;
        // TODO WIP
        case 9:
            console.log("Updating timer");
            scoreboard_set_timer(view);
        // TODO
        default:
            console.log("TODO not a classical mode, anyways, here's the data: ", view);
            break;
    }
};
socket.onerror = (error) => {
    console.error("WebSocket Error: ", error);
};
socket.onclose = () => {
    console.log("WebSocket connection closed!");
};
console.log("TODO: hi from scoreboard.js (this always runs)");
