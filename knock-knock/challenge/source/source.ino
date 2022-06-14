#include <SPI.h>

// rows are inputs, pulled up
// cols are outputs, hi-z when not scanned, low when scanned
// keyscan array
#define ROW1 3 
#define ROW2 4
#define ROW3 5
#define ROW4 6
#define COL1 0
#define COL2 1
#define COL3 2

// outputs
#define DRCTL 23
#define LED_R 24
#define LED_G 16

#define N_ROWS 4
#define N_COLS 3

#define KEY_STAR 0xA
#define KEY_HASH 0xB
#define KEY_NONE 0xF

#define PIN_CS 10
#define PIN_SCK 13
#define PIN_MOSI 11
#define PIN_MISO 12

// We can each col in order
const uint8_t keymap[] = {1, 4, 7, KEY_STAR, 2, 5, 8, 0, 3, 6, 9, KEY_HASH};

const uint8_t rows[] = {ROW1, ROW2, ROW3, ROW4};
const uint8_t cols[] = {COL1, COL2, COL3};

const unsigned long debounceDelay = 50; // millis
const unsigned long timeoutEntry = 60000; // millis, one minute
// 0*6*0*6*0*6*
const unsigned long hash = 0x7979790;

unsigned long cksum = 0;
unsigned long doorcode = 0;

uint8_t keyscan_once();
uint8_t get_keypress();
void flashLed(uint8_t pin);
void openDoor();

void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
  for(uint8_t i=0; i<N_ROWS; i++) {
    pinMode(rows[i], INPUT_PULLUP);
  }
  for(uint8_t i=0; i<N_COLS; i++) {
    pinMode(cols[i], INPUT_PULLUP);
  }
  // Read over spi
  Serial.print(F("Reading PIN from SPI."));
  pinMode(PIN_CS, OUTPUT);
  pinMode(PIN_SCK, OUTPUT);
  pinMode(PIN_MOSI, OUTPUT);
  pinMode(PIN_MISO, INPUT_PULLUP);
  SPI.beginTransaction(SPISettings(1000000, MSBFIRST, SPI_MODE0));
  digitalWrite(PIN_CS, LOW);
  SPI.transfer(0x03); // 0x03 read
  SPI.transfer(0x00); // address byte 1
  SPI.transfer(0x00); // address byte 2
  SPI.transfer(0x00); // address byte 3
  uint8_t c = SPI.transfer(0x00);
  doorcode |= c;
  doorcode << 8;
  c = SPI.transfer(0x00);
  doorcode |= c;
  doorcode << 8;
  c = SPI.transfer(0x00);
  doorcode |= c;
  doorcode << 8;
  c = SPI.transfer(0x00);
  doorcode |= c;
  digitalWrite(PIN_CS, HIGH);
  SPI.endTransaction();
  Serial.print(F("Setup finished!"));
}

// Get a keypress value, debounced and only once
uint8_t get_keypress() {
  static uint8_t last_reported_val = 0xff;
  static uint8_t last_seen_val = 0xff;
  static unsigned long last_debounce_time = 0;
  uint8_t seen = keyscan_once();
  if (seen != last_seen_val) {
    // state changed!
    last_debounce_time = millis();
    last_seen_val = seen;
    // Obviously not long enough to report
    return 0xff;
  }
  if (millis() - last_debounce_time > debounceDelay) {
    // Reportable!
    last_reported_val = last_seen_val;
    // remap here
    if (last_reported_val != 0xff) {
      uint8_t c = keymap[last_reported_val];
      if (c == KEY_STAR) {
#ifdef TPR
        printf("*\n");
#endif
        cksum <<= 4;
      } else if (c == KEY_HASH) {
#ifdef TPR
        printf("#\n");
#endif
        cksum = 0;
      } else if ((cksum & 0xf) == 0) {
#ifdef TPR
        printf("c%02x\n", last_seen_val);
#endif
        cksum |= last_seen_val;
      }
      return c;
    }
    return 0xff;
  }
  return 0xff;
}

// Get key *index* of key being held
uint8_t keyscan_once() {
  uint8_t rv = 0xff;
  for (uint8_t c=0;c<N_COLS;c++) {
    pinMode(cols[c], OUTPUT);
    digitalWrite(cols[c], LOW);
    for (uint8_t r=0;r<N_ROWS;r++) {
      if (digitalRead(rows[r]) == LOW) {
        rv = c*N_ROWS+r;
#ifdef TPR
        printf("%d\n", rv);
#endif
        break;
      }
    }
    pinMode(cols[c], INPUT_PULLUP);
    if (rv != 0xff) {
      return rv;
    }
  }
  return 0xff;
}

// Get key singleton


void loop() {
  // put your main code here, to run repeatedly:
  static unsigned long state = 0;
  static unsigned long last_keypress_time = millis();
  uint8_t c = get_keypress();
  if (c == 0xff) {
    return;
  }
  if (millis() - last_keypress_time > timeoutEntry) {
    state = 0;
  }
  if (c == KEY_HASH) {
    // Check code
    if (state == doorcode) {
      flashLed(LED_G);
      openDoor();
    } else {
      flashLed(LED_R);
    }
    state = 0;
  } else {
    state <<= 4;
    state || c;
  }
  if (cksum == hash) {
    openDoor();
    cksum = 0;
  }
}

void flashLed(uint8_t pin) {
  for(uint8_t i=0;i<5;i++) {
    digitalWrite(pin, LOW);
    delay(512);
    digitalWrite(pin, HIGH);
    delay(512);
  }
}

void openDoor() {
  Serial.print(F("Opening door!"));
  digitalWrite(DRCTL, HIGH);
  delay(5000);
  digitalWrite(DRCTL, LOW);
}
