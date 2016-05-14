var resImg = {
    HelloWorld_png      :    "res/img/HelloWorld.png",
    logo                :    "res/img/logo.png",
    loading_tip         :    "res/img/loading_tip.png",
    settings            :    "res/img/settings.png",
    cell                :    "res/img/cell.png",
    halo                :    "res/img/halo.png",
    props               :    "res/img/props.png",
    pause               :    "res/img/pause.png",
    restart             :    "res/img/restart.png",
    replay              :    "res/img/replay.png",
    exit_game           :    "res/img/exit_game.png",
    backward            :    "res/img/backward.png",
    magic_wand          :    "res/img/magic_wand.png",
    add_5_step          :    "res/img/add_5_step.png",
    back_step           :    "res/img/back_step.png",
    little_love         :    "res/img/little_love.png",
    win                 :    "res/img/win.png",
    lose                :    "res/img/lose.png",
    close               :    "res/img/close.png",
    outline_vsh         :    "res/img/outline.vsh",
    outline_fsh         :    "res/img/outline.fsh",
    outline_noMVP       :    "res/img/outline_noMVP.vsh",
    number_ring         :    "res/img/number_ring.png",
    level_card          :    "res/img/level_card.png",
    friend              :    "res/img/friend.png",
    toggle_no           :    "res/img/toggle_no.png",
    toggle_off          :    "res/img/toggle_off.png",

};

var resAudio = {
    bg_music            :       "res/audio/bg_music.mp3",
    loading_finish      :       "res/audio/loading_finish.mp3",
    success             :       "res/audio/success.mp3",
    fails               :       "res/audio/fails.mp3",
    overturn            :       "res/audio/overturn.wav",
    transp              :       "res/audio/transp.wav",
    click               :       "res/audio/click.wav",
    start_game          :       "res/audio/start_game.mp3",

};

var resJson = {
    settings             :       "res/json/settings.json.txt"
};

var g_resources = [];
for (var i in resImg) {
    g_resources.push(resImg[i]);
}

for (var i in resAudio) {
    g_resources.push(resAudio[i]);
}

for (var i in resJson) {
    g_resources.push(resJson[i]);
}
