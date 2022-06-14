const FOREGROUND = document.querySelector('#foreground');
const FCTX = FOREGROUND.getContext('2d');

const BACKGROUND = document.querySelector('#background');
const BCTX = BACKGROUND.getContext('2d');

const TURTLE_WIDTH = 48;
const TURTLE_HEIGHT = 48;
const STARTING_X = 400;
const STARTING_Y = 400;
const BAD_COLOR  = [0xc6, 0xb5, 0x66];
const GOOD_COLOR = [0x79, 0xa8, 0x68];
const SPEED = 1;
const STROKE_WIDTH = 5;
const TURTLE_IMAGE = new Image(TURTLE_WIDTH, TURTLE_HEIGHT);
const BASE_COLOR = '#797d81';
TURTLE_IMAGE.src = 'turtle.svg';
