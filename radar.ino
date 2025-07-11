#include <Servo.h>
Servo myservo;
int trig = 10;
int echo = 11;
long duration;
float distance;
int buzzer = 9;
int redLed = 5;

void setup() {
  myservo.attach(3);
  pinMode(trig, OUTPUT);
  pinMode(echo, INPUT);
  pinMode(buzzer, OUTPUT);
  pinMode(redLed, OUTPUT);
  Serial.begin(9600);
}

void loop() {
  for (int deg = 0; deg <= 180; deg++) {
    myservo.write(deg);
    delay(10);
    digitalWrite(trig, LOW);
    delayMicroseconds(2);
    digitalWrite(trig, HIGH);
    delayMicroseconds(10);
    digitalWrite(trig, LOW);
    duration = pulseIn(echo, HIGH);
    distance = duration * 0.017;
    Serial.print(deg);
    Serial.print(",");
    Serial.print((int)distance); 
    Serial.println(".");         
    if (distance <= 20) {
      digitalWrite(redLed, HIGH);
      tone(buzzer, 500);
    } else {
      digitalWrite(redLed, LOW);
      noTone(buzzer);
    }
  }
  for (int deg = 180; deg >= 0; deg--) {
    myservo.write(deg);
    delay(10);
    digitalWrite(trig, LOW);
    delayMicroseconds(2);
    digitalWrite(trig, HIGH);
    delayMicroseconds(10);
    digitalWrite(trig, LOW);
    duration = pulseIn(echo, HIGH);
    distance = duration * 0.017;
    Serial.print(deg);
    Serial.print(",");
    Serial.print((int)distance);
    Serial.println(".");
    if (distance <= 20) {
      digitalWrite(redLed, HIGH);
      tone(buzzer, 500);
    } else {
      digitalWrite(redLed, LOW);
      noTone(buzzer);
    }
  }
}
