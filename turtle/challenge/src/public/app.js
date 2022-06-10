// This powers the playable app
function go() {
  let round = 0;
  let x = STARTING_X;
  let y = STARTING_Y;
  let rotation = 0;
  let distance = 0;
  let state = [];
  let historical_points = [] // Pretty sure I can calculate these, but this is easier
  let rotation_speed = 1;

  let segment_start_x;
  let segment_start_y;

  let spacebar = false;

  const show_wrongness = (results) => {
    BCTX.clearRect(0, 0, BACKGROUND.width, BACKGROUND.height);

    let last_point = { x: STARTING_X, y: STARTING_Y };
    for(let i = 0; i < 8; i++) {
      let p = historical_points[i];
      let result = results[i];

      // Badness %
      let badness = (((result.angle_off * 2) + result.distance_off) / 800);

      // Calculate a colour based on badness. Not 100% sure this works, but /shrug
      let c0 = Math.floor((GOOD_COLOR[0] + (Math.abs(BAD_COLOR[0] - GOOD_COLOR[0]) * badness)));
      let c1 = Math.floor((GOOD_COLOR[1] + (Math.abs(BAD_COLOR[1] - GOOD_COLOR[1]) * badness)));
      let c2 = Math.floor((GOOD_COLOR[2] + (Math.abs(BAD_COLOR[2] - GOOD_COLOR[2]) * badness)));

      let color = "#" + ((1 << 24) + (c0 << 16) + (c1 << 8) + c2).toString(16).slice(1);

      BCTX.beginPath();
      BCTX.lineWidth = STROKE_WIDTH;
      BCTX.strokeStyle = color;
      BCTX.moveTo(last_point.x, last_point.y);
      BCTX.lineTo(p.x, p.y);
      BCTX.stroke();
      last_point = p;
    }
  };

  const check = () => {
    $.ajax('/submit', {
      data: JSON.stringify({
        date: new Date().toISOString(),
        path: state,
      }),
      contentType: 'application/json',
      type: 'POST',
    }).done((result) => {
      if(!result.success) {
        console.error(`Something went wrong: ${ result.error }`);
        return;
      }

      if(result.wrongness == 0) {
        if(result.flag) {
          $('#result').html(`Wow, you did it! You've completed ${ result.completed } levels to get the flag: ${ result.flag }!`);
        } else {
          $('#result').html(`Great job, you've completed ${ result.completed } levels! Come back tomorrow for another`);
        }
      } else {
        $('#result').html(`Sorry, your wrongness was ${ result.wrongness }, refresh to try again!`);
        show_wrongness(result.results.results);
      }
    }).fail(function() {
      console.error("Request error!");
    })
  };

  const get_distance = () => {
    distance++;
    $('#distance').text(distance);

    x += -SPEED * Math.cos(rotation * Math.PI / 180);
    y += -SPEED * Math.sin(rotation * Math.PI / 180);

    // Draw the line
    BCTX.beginPath();
    BCTX.strokeStyle = BASE_COLOR;
    BCTX.lineWidth = STROKE_WIDTH;
    BCTX.moveTo(segment_start_x, segment_start_y);
    BCTX.lineTo(x, y);
    BCTX.stroke();

    FCTX.clearRect(0, 0, FOREGROUND.width, FOREGROUND.height);
    FCTX.save();
    FCTX.translate(x, y);
    FCTX.rotate(rotation * Math.PI / 180);
    FCTX.drawImage(TURTLE_IMAGE, -TURTLE_WIDTH / 1.8, -TURTLE_HEIGHT / 1.8, TURTLE_WIDTH, TURTLE_HEIGHT);
    FCTX.restore();

    if(!spacebar) {
      requestAnimationFrame(get_distance);
    } else {
      spacebar = false;
      state[round].distance = distance;
      historical_points.push({ x: x, y: y });
      round++;

      if(round == 8) {
        check();
      } else {
        requestAnimationFrame(get_rotation);
      }
    }
  }

  const get_rotation = () => {
    FCTX.clearRect(0, 0, FOREGROUND.width, FOREGROUND.height);
    FCTX.save();
    FCTX.translate(x, y);
    FCTX.rotate(rotation * Math.PI / 180);
    FCTX.drawImage(TURTLE_IMAGE, -TURTLE_WIDTH / 1.8, -TURTLE_HEIGHT / 1.8, TURTLE_WIDTH, TURTLE_HEIGHT);
    FCTX.restore();

    rotation = (rotation + rotation_speed + 360) % 360;
    $('#rotation').text(rotation);

    if(!spacebar) {
      requestAnimationFrame(get_rotation);
    } else {
      spacebar = false;
      state[round] = {
        angle: rotation,
      };

      distance = 0;
      segment_start_x = x;
      segment_start_y = y;
      $('#distance').text('n/a');
      requestAnimationFrame(get_distance);
    }
  }

  get_rotation();

  window.onkeydown = (event) => {
    if(event.keyCode == 32) {
      spacebar = true;
      event.preventDefault();
    } else {
      if(rotation_speed > 0) {
        rotation_speed = -1;
      } else {
        rotation_speed = 1;
      }
    }
  }
}

go();
