function go(yesterdayness) {
  // Define these here so we can change days
  let segment_start_x = STARTING_X;
  let segment_start_y = STARTING_Y;
  let current_x = STARTING_X;
  let current_y = STARTING_Y;
  let current_rotation = 0;
  let rotate_right = true;
  let data;

  $.get(`/past/${ yesterdayness }`)
    .done((updated_data) => {
      data = updated_data;

      // Reset everything
      current_x = STARTING_X;
      current_y = STARTING_Y;
      current_rotation = 0;
      BCTX.clearRect(0, 0, BACKGROUND.width, BACKGROUND.height);
      FCTX.clearRect(0, 0, FOREGROUND.width, FOREGROUND.height);

      // Draw the turtle
      FCTX.save();
      FCTX.translate(current_x, current_y);
      FCTX.rotate(current_rotation * Math.PI / 180);
      FCTX.drawImage(TURTLE_IMAGE, -TURTLE_WIDTH / 1.8, -TURTLE_HEIGHT / 1.8, TURTLE_WIDTH, TURTLE_HEIGHT);
      FCTX.restore();
    })
    .fail(() => {
      console.error("Request error!");
    })

  const get_next = () => {
    if(!data || data.length == 0) {
      return false;
    }

    while(data.length > 0) {
      let current = data[0];
      if(!current) {
        return false;
      }

      // If we're done with this segment (or there's no distance left), get rid
      // if it and try the next one
      if(current.distance <= 0) {
        data.shift();
        segment_start_x = current_x;
        segment_start_y = current_y;

        // Pick the more efficient direction
        // Ironically, do it in an insanely inefficient way because my brain
        // doesn't want to math right now
        if(data[0]) {
          rotate_right = false;
          for(let i = 0; i < 180; i++) {
            if(((current_rotation + i) % 360) == data[0].angle) {
              rotate_right = true;
              break;
            }
          }
        }

        continue;
      }

      // Move the current
      if(current_rotation != current.angle) {
        if(rotate_right) {
          current_rotation = (current_rotation + 1) % 360;
        } else {
          current_rotation = (current_rotation + 360 - 1) % 360;
        }
      } else {
        current_x += -SPEED * Math.cos(current_rotation * Math.PI / 180);
        current_y += -SPEED * Math.sin(current_rotation * Math.PI / 180);

        // Deduct from the current distance
        current.distance -= 1;
      }

      return true;
    }

    return false;
  };

  const tick = () => {
    // Get the current angle (returns undefined if we run out)
    if(get_next()) {
      BCTX.beginPath();
      BCTX.strokeStyle = "#" + ((1 << 24) + (GOOD_COLOR[0] << 16) + (GOOD_COLOR[1] << 8) + GOOD_COLOR[2]).toString(16).slice(1);
      BCTX.lineWidth = STROKE_WIDTH;
      BCTX.moveTo(segment_start_x, segment_start_y);
      BCTX.lineTo(current_x, current_y);
      BCTX.stroke();

      FCTX.clearRect(0, 0, FOREGROUND.width, FOREGROUND.height);
      FCTX.save();
      FCTX.translate(current_x, current_y);
      FCTX.rotate(current_rotation * Math.PI / 180);
      FCTX.drawImage(TURTLE_IMAGE, -TURTLE_WIDTH / 1.8, -TURTLE_HEIGHT / 1.8, TURTLE_WIDTH, TURTLE_HEIGHT);
      FCTX.restore();
    }

    requestAnimationFrame(tick);
  }

  requestAnimationFrame(tick);

  addEventListener('hashchange', () => {
    let thiserday = parseInt(window.location.hash.substr(1));
    $('#yesterday').attr("href", `/yesterday.html#${ thiserday + 1 }`);
    data = '';
    go(thiserday);
  });
}

// Update the "previous" link
let thiserday = parseInt(window.location.hash.substr(1))
let lasterday = thiserday + 1;
$('#yesterday').attr("href", `/yesterday.html#${ lasterday }`);
go(thiserday);
