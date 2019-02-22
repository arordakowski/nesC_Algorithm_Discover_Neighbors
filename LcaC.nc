
#include "Timer.h"

module LcaC @safe(){
	
	uses{

	//GENERAL
  interface Boot;
  interface SplitControl as AMControl;

	//NETWORKING	
	interface Packet;
  interface AMPacket;
  interface AMSend;
  interface Receive;

	//TIMMER
	interface Timer<TMilli> as Timer0;
	}
}
implementation {
	
	message_t pkt;
  bool busy = FALSE;			// boolean that controls the sending of messages
	bool round = TRUE; 			// boolean for the control of broadcast of sensors
	uint16_t neighbors[7];	// sensor neighbors vector (set the size according to the number of nodes in the network)
	uint16_t aux;						// auxiliary counter for repeat loops

//----------------- implementation of methods  ------------------

	void discoveredNeighbors(uint16_t id){ 	// neighbor storage method in vector
		for(aux = 0x01; aux<0x07; aux++){			// set the control according to the size of the vector
			if(neighbors[aux] == 0){						// verifies if the vector is empty at a certain position
				neighbors[aux] = id;							// stores the detected neighbor in the empty position
				dbg("Boot", "Armazenado neighbors[%i]: %i \n", aux, neighbors[aux]); // debug to assist in the visualization of sensors
				aux = 0x07;												// Assign Value Assignment to Exit Loop Repeat
			}
		}
	}

		void sendMsg(uint8_t typeMsg, uint16_t idDestination){ 	// method of sending messages 
		
		switch(typeMsg){																				// verification of the sent message type

			case 1: 																							// SENSOR_ID
			if (!busy) {
					SENSOR_ID* btrpkt = (SENSOR_ID*)(call Packet.getPayload(&pkt, sizeof(SENSOR_ID)));
      		if (btrpkt == NULL) {
						return;
      		}
     			btrpkt->sensorId = TOS_NODE_ID;										// value assignment to message
      		if (call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(SENSOR_ID)) == SUCCESS) {
      	  	busy = TRUE;
      		}
    		}
			break;
		}
	}

//----------------- implementation of events ------------------



	event void Boot.booted() {

		// state WAIT SENSOR_ID
		call AMControl.start(); 		// call Timmer
		
  }

  event void AMControl.startDone(error_t err) {
    if (err == SUCCESS) {
      call Timer0.startPeriodic((TIMER_PERIOD_MILLI)*20) ; // Timmer
    }
    else {
      call AMControl.start();
    }
  }

	event void AMControl.stopDone(error_t err) {
  }

	event void Timer0.fired(){			//timer fired
		call Timer0.stop();

		if(TOS_NODE_ID == 1 && round){ //SENSOR_ID
			round = FALSE;
			sendMsg(1,0);
			call AMControl.start(); //WAIT SENSOR_ID
		}	
	}
		// Actions after the discovery of neighbors

  event void AMSend.sendDone(message_t* msg, error_t err) {
    if (&pkt == msg) {
      busy = FALSE;
    }
  }

	//event to receive messages
	event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len){

		call Timer0.stop();
    if (len == sizeof(SENSOR_ID)) {
      SENSOR_ID* btrpkt = (SENSOR_ID*)payload;
			discoveredNeighbors(btrpkt->sensorId);	// storage of the neighbor received through the discoveredNeighbors
			if (round){
				sendMsg(1,0);													// sending message through sendMsg
				round = FALSE;
			}
    }
		call AMControl.start();
    return msg;
  }
}
