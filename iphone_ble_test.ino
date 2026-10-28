#include <Arduino.h>
#include <Adafruit_TinyUSB.h> // for Serial
#include <bluefruit.h>

BLEUart g_BLEUart;

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
  Bluefruit.autoConnLed(false);
  Bluefruit.configPrphBandwidth(BANDWIDTH_MAX);
  Bluefruit.begin();
  Bluefruit.setTxPower(8);

  // Setup LEDs
  pinMode(LED_BUILTIN, OUTPUT);
  digitalWrite(LED_BUILTIN, !LED_STATE_ON);

  // Setup serial and delay for 10 secs
  Serial.begin(115200);
  delay(10000);

  // Display Board ID:
  display_info();

  // Configure and Start BLE Uart Service
  g_BLEUart.begin();

  // Advertising packet
  char ble_name[] = "Embedded Test1";
  Bluefruit.setName(ble_name);
  Bluefruit.Advertising.addFlags(BLE_GAP_ADV_FLAGS_LE_ONLY_GENERAL_DISC_MODE);
  Bluefruit.Advertising.addTxPower();
  Bluefruit.Advertising.addName();

  // Start Advertising
  Bluefruit.Advertising.restartOnDisconnect(true);
  Bluefruit.Advertising.setInterval(32, 244);    // in unit of 0.625 ms, fast mode = 20 ms, slow mode = 152.5 ms
  Bluefruit.Advertising.setFastTimeout(30);      // number of seconds in fast mode
  Bluefruit.Advertising.start(0);                // 0 = Don't stop advertising after n seconds

  Serial.print("BLE name: ");
  Serial.println(ble_name);
}

void loop() {
  digitalWrite(LED_BUILTIN, LOW);
  delay(25);
  digitalWrite(LED_BUILTIN, HIGH);
  g_BLEUart.println(millis());
  delay(975);
}
