App.web = {
    send_code: function (code) {
        App.game.perform('set_code', {'msg': code})
    },
    make_turn: function (code) {
        App.game.perform('make_turn', {'msg': code})
    }
};

$(document).ready(function () {
    $('#code_submit').click(function () {
        var code = $('#code_field').val();
        console.log(code, typeof(code));
        if(!isNaN(code)) {
            App.web.send_code(code)
        }
    });

    $('#guess_submit').click(function () {
        var code = $('#guess_field').val();
        console.log(code, typeof(code));
        if(!isNaN(code)) {
            App.web.make_turn(code)
        }
    });
});


var startSeek = function () {
    console.log('start seek');
    $('.menu > ul').fadeOut('slow', function () {
        $('.loading-container').fadeIn('slow');
        App.game.perform('seek');
    })
};

var stopSeek = function () {
    console.log('stop seek');
    App.cable.disconnect();
    $('.loading-container').fadeOut('slow', function () {
        $('.menu > ul').fadeIn('slow');
        App.cable.connect();
    })
};