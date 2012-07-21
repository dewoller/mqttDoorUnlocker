#include <SPI.h>
#include <Ethernet.h>
#include <PubSubClient.h>



//Setup network connection

byte mac[] = { 0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };
byte ip[] = { 192, 168, 1, 176 };
byte gateway[] = {192,168,1,1};
byte server[] = { 192,168,1,31  }; // Server IP
byte subnet[] = { 255, 255, 255, 0 };

int port = 1883;
//Meter output spin
#define strikePlate 9
#define unlockSeconds 5
#define ledPin 13
char clientName[] ="doorUnlockArduino";
char clientTopic[] ="doorUnlock";
char clientKey[] ="doorUnlock";

//MQTT client setup
PubSubClient client(server, port, callback);

//Add callback for when a message is recieved
//
void callback(char* topic, byte* payload,unsigned int length) {

    Serial.println("unlock attempt with payload:");
    Serial.println((char*)payload);
    client.publish(clientTopic,"unlock attempt");
    if (memcmp((char*)payload,clientKey,9) == 0 );
    {
	unlock(); 
        Serial.println("sucessful unlocking");
	client.publish(clientTopic,"unlock success");
    }
    flash();
}
void unlock() {
  digitalWrite(ledPin, HIGH);
  digitalWrite(strikePlate, HIGH);
  delay(unlockSeconds * 1000);
  digitalWrite(strikePlate, LOW);
  digitalWrite(ledPin, LOW);
}
void flash() {
  digitalWrite(ledPin, HIGH);
  delay(unlockSeconds * 100);
  digitalWrite(ledPin, LOW);
  delay(unlockSeconds * 100);
}


//setup method
void setup()
{
  //start ethernet connection
  Ethernet.begin(mac, ip, gateway, subnet);

  //start serial connection for debugging
  Serial.begin(9600);
  // setup unlocker
  pinMode(ledPin, OUTPUT);
  digitalWrite(ledPin, LOW);
  pinMode(strikePlate, OUTPUT);
  digitalWrite(strikePlate, LOW);


    flash();
    Serial.println("Starting pre connect");
    Serial.println(clientName);
  //connect to MQTT Broker
  client.connect("test");;

  //Subscribe to topic bandDown
  client.subscribe("doorUnlock");

  Serial.println("Starting post connect");
  client.publish("doorUnlock","Starting unlock client");

}

//main loop
void loop()
{
  //Tell the MQTT broker we're still here
  client.loop();
}

