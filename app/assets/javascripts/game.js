var yourCode;

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

    var setCodeInputs = $('.welcome').find('input');
    setCodeInputs.mask('0');
    setCodeInputs.keydown(function (e) {
        setCodeInputsHandler(e);
    });

    // debugShit();
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

var showSetCode = function () {
    $('.loading-container').fadeOut('slow', function () {
        $('#set-code-container').fadeIn('slow');
    })
};

var setCodeInputsHandler = function (e) {
    var numKeys = [48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105];
    setTimeout(function () {
        if(e.currentTarget.value.length > 0){
            if ($.inArray(e.keyCode, numKeys) != -1) {
                $(e.currentTarget).val(e.key)
            }
            if (e.currentTarget.nextElementSibling){
                e.currentTarget.nextElementSibling.focus()
            }
        } else {
            if(e.currentTarget.previousElementSibling && e.keyCode == 8){
                e.currentTarget.previousElementSibling.focus()
            }
        }
    }, 1);
};


var generateRandomCode = function () {
    var code = (Math.random() * 10000).toFixed().split('');
    while(code.length < 4) {
        code.unshift("0")
    }
    $('#set-code').find('input').each(function (index) {
        $(this).val(code[index]);
    })
};

var setCode = function () {
    var codeArray = [];
    $('#set-code').find('input').each(function () {
        codeArray.push($(this).val());
    });
    var codeString = codeArray.join('');
    App.game.perform('set_code', {msg: parseInt(codeString)});
    yourCode = codeString;

    $('#set-code-container').fadeOut('slow', function () {
        $('#waiting-for-opponent-container').fadeIn('slow');
    });
};

var initGame = function(gameData) {
    initTimer();

    setTimeout(function () {
        $('#roller').fadeOut('slow');
        $('#waiting-for-opponent-container').fadeOut('slow', function () {
            $('#game-container').fadeIn('slow');
        });
    }, 1000);

    var yourCodeContainer = $('.your-code');
    yourCodeContainer.text(yourCodeContainer.text() + ' ' + yourCode);

    if(gameData.is_your_turn) {

    } else {

    }

    $('body').toggleClass('game');

    $('#give-up-flag').click(function () {
        $('#give-up-flag').addClass('large').addClass('position--absolute');
        $('.give-up-flag-spacer').show();
        setTimeout(function () {
            $('#give-up-container').fadeIn('slow').addClass('show')
        }, 1000)
    });

    $('#continue').click(function () {
        $('#give-up-container').hide().removeClass('show');
        $('#give-up-flag').removeClass('large');

        setTimeout(function () {
            $('.give-up-flag-spacer').hide();
            $('#give-up-flag').removeClass('position--absolute');
        }, 1500)
    });

    $('#give-up').click(function () {
        $('body').fadeOut('slow', function () {
            App.cable.disconnect();
            App.cable.connect();
            $('#roller').show();
            $('.give-up-flag-spacer').hide();
            $('#give-up-container').hide().removeClass('show');
            $('#give-up-flag').removeClass('large').removeClass('position--absolute');
            $('body').fadeIn('slow').removeClass('game');
            $('#game-container').hide();
            $('ul').show();
        });
    })
};

var initTimer = function () {
    var start_time = new Date();
    var timer = {};

    function getCurrentValue() {
        timer.raw = (new Date() - start_time) / 1000;
        timer.mins = Math.floor(timer.raw / 60);
        timer.secs = Math.floor(timer.raw - (timer.mins * 60));

        $('.mins').html(('0' + timer.mins).slice(-2));
        $('.secs').html(('0' + timer.secs).slice(-2));
    }

    setInterval(function () {
        getCurrentValue();
    }, 1000);
};

// DEBUG SHIT

function debugShit() {
    initTimer();
    var code = 6431;
    var yourCode = $('.your-code');
    yourCode.text(yourCode.text() + ' ' + code);
    $('body').toggleClass('game');

    $('#give-up-flag').click(function () {
        $('#give-up-flag').addClass('large').addClass('position--absolute');
        $('.give-up-flag-spacer').show();
        setTimeout(function () {
            $('#give-up-container').fadeIn('slow').addClass('show')
        }, 1000)
    });

    $('#continue').click(function () {
        $('#give-up-container').hide().removeClass('show');
        $('#give-up-flag').removeClass('large');

        setTimeout(function () {
            $('.give-up-flag-spacer').hide();
            $('#give-up-flag').removeClass('position--absolute');
        }, 1500)
    });

    $('#give-up').click(function () {
        $('body').fadeOut('slow', function () {
            App.cable.disconnect().connect();
            $('#roller').show();
            $('.give-up-flag-spacer').hide();
            $('#give-up-container').hide().removeClass('show');
            $('#give-up-flag').removeClass('large').removeClass('position--absolute');
            $('body').fadeIn('slow').removeClass('game');
            $('#game-container').hide();
            $('ul').show();
        });
    })
}