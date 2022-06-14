#include <stdint.h>
#include <stdio.h>
#include <string>
#include <string.h>

#define LOW 0
#define HIGH 1
#define SPI_MODE0 0
#define MSBFIRST 0
#define INPUT 0
#define INPUT_PULLUP 1
#define OUTPUT 2
void delay(int len);
void pinMode(uint8_t pin, uint8_t direction);
void digitalWrite(uint8_t pin, uint8_t value);
uint8_t digitalRead(uint8_t pin);
unsigned long millis();

uint8_t cur_pins_[32];

#define F(x) (x)

class SerialInterface {
  public:
    void print(std::string str) {
      printf("%s\n", str.c_str());
    }
    void begin(int speed) {}
};

SerialInterface Serial;

class SPIInterface {
  public:
    void beginTransaction(int x){}
    void endTransaction(){}
    uint8_t transfer(uint8_t v){return 0;}
};

SPIInterface SPI;
int SPISettings(int, int, int){return 0;}

#define TPR 1

#include "source/source.ino"


unsigned long cur_millis_ = 0;

unsigned long millis() {
  return cur_millis_;
}

uint8_t write_pin_=0;
uint8_t read_pin_=0;
uint8_t pin_val_=0;

void delay(unsigned long len){
  cur_millis_ += len;
}
void delay(int len) {
  delay((unsigned long)len);
}

void pinMode(uint8_t pin, uint8_t direction){}

void digitalWrite(uint8_t pin, uint8_t val){
  if (pin == write_pin_) {
    cur_pins_[read_pin_] = pin_val_;
    write_pin_ = 0xFF;
  }
  //printf("dw: %02x %02x\n", pin, val);
  cur_pins_[pin] = val;
}

uint8_t digitalRead(uint8_t pin){
  uint8_t rv = cur_pins_[pin];
  //printf("dr: %02x %02x\n", pin, rv);
  return rv;
}

void read_after_write(uint8_t write_pin, uint8_t read_pin, uint8_t val) {
  write_pin_ = write_pin;
  read_pin_ = read_pin;
  pin_val_ = val;
}

void do_char(uint8_t col, uint8_t row) {
  read_after_write(col, row, LOW);
  loop();
  cur_pins_[row] = HIGH;
  read_after_write(col, row, LOW);
  delay(51);
  loop();
  cur_pins_[row] = HIGH;
  loop();
  delay(51);
  loop();
  delay(51);
  loop();
}

int main(int argc, char **argv) {
  memset(cur_pins_, 1, sizeof(cur_pins_));
  setup();
  // 6 = col3, row2
  // 0 = col2, row4
  // * = col1, row4
  do_char(COL2, ROW4);
  printf("%08lx\n", cksum);
  do_char(COL1, ROW4);
  printf("%08lx\n", cksum);
  do_char(COL3, ROW2);
  printf("%08lx\n", cksum);
  do_char(COL1, ROW4);
  printf("%08lx\n", cksum);
  do_char(COL2, ROW4);
  printf("%08lx\n", cksum);
  do_char(COL1, ROW4);
  printf("%08lx\n", cksum);
  do_char(COL3, ROW2);
  printf("%08lx\n", cksum);
  do_char(COL1, ROW4);
  printf("%08lx\n", cksum);
  do_char(COL2, ROW4);
  printf("%08lx\n", cksum);
  do_char(COL1, ROW4);
  printf("%08lx\n", cksum);
  do_char(COL3, ROW2);
  printf("%08lx\n", cksum);
  do_char(COL1, ROW4);
  printf("%08lx\n", cksum);
}
