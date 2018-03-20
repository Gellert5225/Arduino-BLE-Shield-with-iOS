#include <SPI.h> // Serial Peripheral Interface 
#include <RBL_nRF8001.h> // go to cpp file and change to const
#include <RBL_services.h> // change name
#include <Servo.h>

Servo myservo;

#define trigPin 4
#define echoPin 10

void setup() {
    pinMode(11, OUTPUT);

    pinMode(trigPin, OUTPUT);
    pinMode(echoPin, INPUT);
    
    //myservo.attach(11);
    
    ble_set_pins(9, 8);
    
    ble_set_name("TEST");
    
    SPI.setDataMode(SPI_MODE0);
    SPI.setBitOrder(LSBFIRST); // least significant bit
    SPI.setClockDivider(SPI_CLOCK_DIV16);
    SPI.begin();
  
    ble_begin();
    
    Serial.begin(57600);
}

String content;
long previousDistance = 0;

void loop() {
    if ( ble_available() ) {
        while ( ble_available() ) {
            auto c = ble_read();
            content += char(c);
        }
    
        Serial.println(content);
        
        if (content == "ON") {
            digitalWrite(11, HIGH);
        } else if (content == "OFF") {
            digitalWrite(11, LOW);
        } else {
            
        }
          
        Serial.println();
    
        content = "";
    }
  
    ultraSonic();
    
    ble_do_events();

}

void ultraSonic() {
    long duration, distance;
    digitalWrite(trigPin, LOW);  
    delayMicroseconds(2); 
    digitalWrite(trigPin, HIGH);
    delay(200);
    digitalWrite(trigPin, LOW);
    duration = pulseIn(echoPin, HIGH);
    distance = (duration/58.138);
    if (previousDistance != distance) {
        Serial.println(distance);
  
        Serial.println("Writing data");
        ble_write( distance ); 
    }
    previousDistance = distance;
}
