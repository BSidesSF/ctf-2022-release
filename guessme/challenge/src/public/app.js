let count = 0;
let done = false;

const create_question = (num) => {
  $.get('/clue')
    .done(function(data) {
      // Clear on the first time
      if(num == 0) {
        $('#game').empty();
      }

      let clue = $("<span>")
        .addClass('clue')
        .html(`${ data.clue } &rarr; `);

      let guess = $("<input type='text' placeholder='type answer and press enter, quick!'>")
        .addClass('guess');

      let inner = $('<div>')
        .addClass('inner')
        .append(clue)
        .append(guess);

      let question = $(`<div id=question${ num }>`)
        .addClass('question')
        .append(inner);

      guess.on('keypress', function (e) {
         if(e.which === 13) {
            $(this).attr("disabled", "disabled");

            $.ajax('/check', {
              data: JSON.stringify({
                token: data['token'],
                guess: $(this).text(),
              }),
              contentType: 'application/json',
              type: 'POST',
            }).done((result) => {
              inner.html(result.message);

              if(result.result === true) {
                question.addClass('win');
                done = true;
              } else {
                question.addClass('lose');
                question.fadeOut(3000);
              }
            }).fail(function() {
              console.error("Request error!");
            })
         }
      });

      $('#game').prepend(question);
      question.fadeIn(1000);

      if(num > 9) {
        $(`#question${ num - 10 }`).fadeOut(() => {
          $(this).remove();
        });
      }
    })
    .fail(function() {
      console.error("Request error!");
    })
}

const gogogo = () => {
  if(!done) {
    create_question(count++);
    window.setTimeout(gogogo, 2000);
  }
}

$( document ).ready(() => {
  gogogo();
});
