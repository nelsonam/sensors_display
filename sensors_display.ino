// weigh sensor

// GND = black wire = blue wire
// VCC = red wire   = purple wire



int PD_SCK = A0;
int DOUT = A1;

uint32_t zerogram = 0;
uint32_t twentygram = 0;
uint32_t fiftygram = 0;

//HX711 scale(A1, A0);		// parameter "gain" is ommited; the default value 128 is used by the library

void setup() {
  Serial.begin(38400);
  pinMode(PD_SCK, OUTPUT);
  pinMode(DOUT, INPUT);
  
  zerogram = read_average();
  Serial.print("zero average:\t");
  Serial.println(zerogram);

  Serial.println("add fifty gram now");
  delay(5000);

  fiftygram = read_average();
  Serial.print("fiftygram average:\t");
  Serial.println(fiftygram);
}

void loop() {
  float val = adjusted_read();
  float avg = adjusted_read_average();
  
  Serial.print("one reading:\t");
  Serial.print(val);
  Serial.print("\t| average:\t");
  Serial.println(avg);
}

void clockUp() {
  digitalWrite(PD_SCK, HIGH);
}

void clockDown() {
  digitalWrite(PD_SCK, LOW);
}

uint32_t read() {
  while (digitalRead(DOUT) != LOW); // wait for it to become readable
  
  byte data[3];
  // pulse the clock pin 24 times to read the data
  for (byte j = 3; j--;) {
    for (char i = 8; i--;) {
      digitalWrite(PD_SCK, HIGH);
      bitWrite(data[j], i, digitalRead(DOUT));
      digitalWrite(PD_SCK, LOW);
    }
  }

  // set the channel and the gain factor for the next reading using the clock pin
  for (int i = 0; i < 1; i++) { // adjust i < ? to adjust gain level, 1 is 128 gain
    digitalWrite(PD_SCK, HIGH);
    digitalWrite(PD_SCK, LOW);
  }

  return ((uint32_t) data[2] << 16) | ((uint32_t) data[1] << 8) | (uint32_t) data[0];
}

uint32_t read_average() {
  uint32_t samplecount = 10;
  uint32_t sum = 0;
  for (int i=0; i<samplecount; i++) sum += read();
  return sum / samplecount;
}

float adjusted_read() {
  float val = read();
  float m = ( (float) (fiftygram-zerogram) ) / 50.0f;
  float zerof = zerogram;
  return (val - zerof) / m;  
}

float adjusted_read_average() {
  int samplecount = 10.0f;
  float sum = 0;
  for (int i=0; i<samplecount; i++) sum += adjusted_read();
  return sum / samplecount;
}

void goprintgo(uint32_t val) {
  Serial.print(val, BIN);
  Serial.print("\t");
  Serial.println(val);
}
void goprintgo(float val) {
  Serial.print(val, BIN);
  Serial.print("\t");
  Serial.println(val);
}
