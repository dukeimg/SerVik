// Global variables
var yourCode, yourTurn, me, rival, lang;

var Messages = {
    ru: {
        win: {
            title: 'Победа!',
            code_is_guessed: 'Поздравляем, вы отгадали код противника: ',
            opponent_disconnected: 'Потеряно соединение с оппонентом.',
            opponent_forfeits: 'Оппонент сдался. Его код: '
        },
        lose: {
            title: 'Поражение!',
            code_is_guessed: 'Ваш оппонент оказался быстрее вас. Его код: '
        }
    },
    en: {
        win: {
            title: 'Won!',
            code_is_guessed:  'Congratulations, you have guessed the enemy’s code: ',
            opponent_disconnected: 'Connection lost.',
            opponent_forfeits: 'Your opponent has gave up. His code: '
        },
        lose: {
            title: 'Lost!',
            code_is_guessed: 'Your opponent was faster this time. His code: '
        }
    }
};


App.web = {
    send_code: function (code) {
        App.game.perform('set_code', {'msg': code})
    },
    make_turn: function (code) {
        App.game.perform('make_turn', {'msg': code})
    }
};

$.fn.getCode = function () {
    var codeArray = [];
    $(this).find('input').each(function () {
        codeArray.push($(this).val());
    });
    var codeString = codeArray.join('');
    if(codeString.length == 4) {
        return codeString
    } else {
        return 'Invalid'
    }
};

$(document).ready(function () {
    lang = $('html').attr('lang');

    if (lang == 'ru') {
        me = 'Вы';
        rival = 'П';
    } else if ( lang == 'en') {
        me = 'Me';
        rival = 'R';
    }

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

    $('#set-code').find('input').keydown(function (e) {
        if (e.keyCode == 13) {
            setCode()
        }
    });

    // debugShit();
});

var startSeek = function () {
    $('.menu > ul').fadeOut('slow', function () {
        $('.loading-container').fadeIn('slow');
        App.game.perform('seek');
    });
    $('#banner').fadeOut('slow');
};

var stopSeek = function () {
    console.log('stop seek');
    App.cable.disconnect();
    $('.loading-container').fadeOut('slow', function () {
        $('.menu > ul').fadeIn('slow');
        App.cable.connect();
    });
    $('#banner').fadeIn('slow');
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
    var code = $('#set-code').getCode();
    if (code != 'Invalid') {
        App.game.perform('set_code', {msg: parseInt(code)});
        yourCode = code;

        $('#set-code-container').fadeOut('slow', function () {
            $('#waiting-for-opponent-container').fadeIn('slow');
        });
    }
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

    if (gameData.is_your_turn) {
        $('.send').removeClass('disabled');
        yourTurn = true;
        $('.row').find("[data-yours='1']").show();
    } else {
        $('.send').addClass('disabled');
        yourTurn = false;
        $('.row').find("[data-yours='0']").show();
    }

    $('body').toggleClass('game');

    $('#give-up-flag').click(function () {
        $('#give-up-flag').addClass('large').addClass('position--absolute');
        $('.give-up-flag-spacer').show();
        setTimeout(function () {
            $('#give-up-container').fadeIn('slow').addClass('show')
        }, 600)
    });

    $('#continue').click(function () {
        $('#give-up-container').hide().removeClass('show');
        $('#give-up-flag').removeClass('large');

        setTimeout(function () {
            $('.give-up-flag-spacer').hide();
            $('#give-up-flag').removeClass('position--absolute');
        }, 1000)
    });

    $('#give-up').click(function () {
        $('body').fadeOut('slow', function () {
            App.game.perform('forfeit');
            App.cable.disconnect();
            App.cable.connect();
            $('#roller').show();
            $('.give-up-flag-spacer').hide();
            $('#give-up-container').hide().removeClass('show');
            $('#give-up-flag').removeClass('large').removeClass('position--absolute');
            $('body').fadeIn('slow').removeClass('game');
            $('#game-container').hide();
            $('ul').show();
            $('#banner').fadeIn('slow');
        });
    });
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

function makeTurn() {
    var code = $('#input-code').getCode();
    if (code != 'Invalid' && yourTurn == true) {
        App.game.perform('make_turn', {msg: code});
        $('input').val('');
        $('.send').addClass('disabled');
        yourTurn = false;
        var message = "<div class='message-block my'><div class='message'>" + code + "</div><div class='me'>" + me +
            "</div></div>";
        var container= $('.messages-container');
        container.append(message).animate({scrollTop: $(container).get(0).scrollHeight}, 300);
    }
    $('.turn').hide();
}

function handleTurn(data) {
    yourTurn = data.is_your_turn;
    var container= $('.messages-container');
    if (yourTurn == true) {
        $('.send').removeClass('disabled');
        var message = "<div class='message-block his'><div class='him'>" + rival + "</div><div class='message'>"
            + data.code + " | " + data.msg + "</div></div>";
        container.append(message);
    } else {
        $('.send').addClass('disabled');
        $('.my:last-child .message').html(data.code + " | " + data.msg)
    }
    container.animate({scrollTop: $(container).get(0).scrollHeight}, 300);
    $('.turn').hide();
}


function handleEndGame(data) {
    $('.send').hide();
    $('#give-up-container').hide();
    yourTurn = false;
    if (data.win) {
        if(data.opponent_code == null) {
            data.opponent_code = ''
        }
        $('.end-game-title').text(Messages[lang].win.title);
        $('.end-game-message').text(Messages[lang].win[[data.reason]] + data.opponent_code)
    } else {
        $('.end-game-title').text(Messages[lang].lose.title);
        $('.end-game-message').text(Messages[lang].lose[[data.reason]] + data.opponent_code)
    }
    $('#end-game-modal').show();

    $('.close-btn').click(function () {
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
            $('.send').show();
            $('#end-game-modal').hide();
            $('#set-code-container').hide();
            $('#banner').fadeIn('slow');
            $('#waiting-for-opponent-container').hide();
        });
    })
}