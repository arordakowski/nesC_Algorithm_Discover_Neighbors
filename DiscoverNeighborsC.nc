
#include "Timer.h"

module DiscoverNeighborsC @safe(){
	
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
	uint16_t neighbors[7];	// sensor neighbors vector (set the size according to the number of nodes in the network)
	uint16_t aux;						// auxiliary counter for repeat loops
	uint8_t nextState;

//----------------- implementation of methods  ------------------

	void discoveredNeighbors(uint16_t id){ 	// method storage neighbor in vector
		for(aux = 0x01; aux<0x07; aux++){			// set the control according to the size of the vector
			if(neighbors[aux] == 0){						// verifies if the vector is empty at a certain position
				neighbors[aux] = id;							// stores the detected neighbor in the empty position
				dbg("Boot", "==> (%i)\n", id);
				aux = 0x07;												// Assign Value Assignment to Exit Loop Repeat
			}
		}
	}

	void sendMsg(){ 	// method of sending messages 
		SENSOR_ID* btrpkt = (SENSOR_ID*)(call Packet.getPayload(&pkt, sizeof(SENSOR_ID)));
  	btrpkt->sensorId = TOS_NODE_ID;										// value assignment to message
   	call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(SENSOR_ID));
	}
	

//----------------- implementation of states ------------------

	void FINISH(){
		nextState = 4; // State 4: FINISH
		//store_ACK_neighbors
		dbg("Boot", "FINISH\n");
	}

	void ACK_Neighbor_List(){
		nextState = 3; // State 3: ACK_Neighbor_List
		//sendMsg_ACK(); //ACK MSG
		dbg("Boot", "ACK\n");
		FINISH();
	}

	void Form_Neighbor_List(){
		nextState = 2; // State 2: Form_Neighbor_List
		call Timer0.startOneShot(TIMER_PERIOD_MILLI) ; 	// timmer
	}

	void Wait_First_Sensor_ID(){
		nextState = 1; // State 1: Wait_First_Sensor_ID
	}

	void INI(){
	
		if(TOS_NODE_ID == 1){
			nextState = 0;
			call Timer0.startOneShot(TIMER_PERIOD_MILLI); 	// timmer
		}
		else{
			Wait_First_Sensor_ID();
		}
	}

//----------------- implementation of events ------------------

	event void Boot.booted() {
		call AMControl.start(); 		// initialize Radio
		INI(); 
  }

  event void AMControl.startDone(error_t err) {
  	 
		if(err == SUCCESS) {
			dbg("Boot","APPL: started\n");
		}
		else {
			printf("APPL start error\n");
		}
  }

	event void Timer0.fired(){			//timer fired
	
		if(nextState == 0){
			sendMsg();
			Wait_First_Sensor_ID();
		}
		else if(nextState == 2){
			ACK_Neighbor_List();
		}	
	}

	//event to receive messages
	event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len){

		SENSOR_ID* btrpkt = (SENSOR_ID*)payload;
		
		if(nextState == 1){
			discoveredNeighbors(btrpkt->sensorId);	// storage of the neighbor received through the discoveredNeighbors
			sendMsg();														// sending message through sendMsg
			Form_Neighbor_List();
		} 
		else if(nextState == 2){
			discoveredNeighbors(btrpkt->sensorId);	// storage of the neighbor received through the discoveredNeighbors
    }

	return msg;
  }

	event void AMControl.stopDone(error_t err) {
  }

  event void AMSend.sendDone(message_t* msg, error_t err) {
  }
}
