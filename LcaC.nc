
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
				dbg ("Boot","\tneighbors[%i]: %i\n", aux, neighbors[aux]);					
				aux = 0x07;												// Assign Value Assignment to Exit Loop Repeat
			}
		}
	}

	void sendMsg(){ 	// method of sending messages 

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
	}
	
//----------------- implementation of events ------------------

	event void Boot.booted() {
		// state INI
			call AMControl.start(); 		// initialize Radio
		
  }

  event void AMControl.startDone(error_t err) {
    if (err == SUCCESS) {
			if(TOS_NODE_ID == 1){															// id = 1
      	call Timer0.startOneShot(TIMER_PERIOD_MILLI) ; 	// timmer
			}
    }
    else {
      call AMControl.start();
    }
  }

	event void AMControl.stopDone(error_t err) {
  }

	event void Timer0.fired(){			//timer fired

		if(TOS_NODE_ID == 1 && round){ 
			round = FALSE;
			sendMsg();									//send SENSOR_ID - broadcast
		}
	}
		
  event void AMSend.sendDone(message_t* msg, error_t err) {
    if (&pkt == msg) {
      busy = FALSE;								// message sended, busy = False
    }
  }

	//event to receive messages
	event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len){
		
		if (len == sizeof(SENSOR_ID)) {
      SENSOR_ID* btrpkt = (SENSOR_ID*)payload;
			discoveredNeighbors(btrpkt->sensorId);	// storage of the neighbor received through the discoveredNeighbors
			if (round){
				sendMsg();														// sending message through sendMsg
				round = FALSE;
			}
    }
    return msg;
  }
}
