#include <Arduino.h>

int main(void)
{
	init();

#if defined(USBCON)
	USB.attach();
#endif
	
	setup();
    
	for (;;) {
		loop();
		if (serialEventRun) serialEventRun();
	}
        
	return 0;
}

#line 1 "build/pubsub.pde"
#include <Ethernet.h>
#include <PubSubClient.h>
#include <SPI.h>


//Setup network connection

#include <Ethernet.h>
byte mac[] = { 0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };
byte ip[] = { 192, 168, 1, 176 };
byte gateway[] = {192,168,1,1};
byte server[] = { 192,168,1,31  }; // Server IP
byte subnet[] = { 255, 255, 255, 0 };

int port = 1883;
//Meter output spin
int meterPin = 9;

//Set initial bandwidth
float out = 0;

//MQTT client setup
PubSubClient client(server, port, callback);

//Add callback for when a message is recieved
//
// Takes bandwidth as 4 digit number e.g 44 = 0044
void callback(char* topic, byte* payload,unsigned int length) {

    Serial.println(payload);
  
}

//setup method
void setup()
{
  //start ethernet connection
  Ethernet.begin(mac, ip, gateway, subnet);

  //start serial connection for debugging
  Serial.begin(9600);

  //connect to MQTT Broker
  client.connect("arduino");

  //Subscribe to topic bandDown
  client.subscribe("a/#");
}

//main loop
void loop()
{
  //Tell the MQTT broker we're still here
  client.loop();
}

