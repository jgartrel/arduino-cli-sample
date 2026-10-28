#include <Arduino.h>
#include <Adafruit_TinyUSB.h> // for Serial
#include <bluefruit.h>

void display_info()
{
  Serial.print("Board ID       : 0x");
  Serial.print(NRF_FICR->DEVICEADDR[1], HEX);
  Serial.print(NRF_FICR->DEVICEADDR[0], HEX);
  Serial.print(NRF_FICR->DEVICEID[1], HEX);
  Serial.print(NRF_FICR->DEVICEID[0], HEX);
  Serial.println();
}

void setup() {
  Bluefruit.begin();

  // Setup LEDs
  pinMode(LED_BUILTIN, OUTPUT);
  digitalWrite(LED_BUILTIN, !LED_STATE_ON);

  // Setup serial and delay for 10 secs
  Serial.begin(115200);
  delay(10000);

  // Display Board ID:
  display_info();
}

void loop() {
  digitalWrite(LED_BUILTIN, LED_STATE_ON);
  delay(25);
  digitalWrite(LED_BUILTIN, !LED_STATE_ON);
  Serial.println("Hello World");
  delay(20000);
}
