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

    var setCodeInputs = $('#set-code').find('input');
    setCodeInputs.mask('0');
    setCodeInputs.keydown(function (e) {
        setCodeInputsHandler(e);
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

    $('#set-code-container').fadeOut('slow', function () {
        $('#waiting-for-opponent-container').fadeIn('slow');
    });

    $()
};