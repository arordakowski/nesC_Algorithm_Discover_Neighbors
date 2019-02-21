
#include "Timer.h"

module LcaC @safe()
{

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
implementation
{
	message_t pkt;
  bool busy = FALSE;
	bool round = TRUE; 
	uint16_t neighbors[7];
	uint16_t aux;
	uint16_t CH;

//----------------- implementation of calls  ------------------

	void discoveredNeighbors(uint16_t id){
		for(aux = 0x01; aux<0x07; aux++){
			if(neighbors[aux] == 0){
				neighbors[aux] = id;
				dbg("Boot", "Armazenado neighbors[%i]: %i \n", aux, neighbors[aux]); 
				aux = 0x05;
			}
		}
	}

		void sendMsg(uint8_t typeMsg, uint16_t idDestination){
		
		switch(typeMsg){		

			case 1: // SENSOR_ID
			if (!busy) {
					SENSOR_ID* btrpkt = (SENSOR_ID*)(call Packet.getPayload(&pkt, sizeof(SENSOR_ID)));
      		if (btrpkt == NULL) {
						return;
      		}
     			btrpkt->sensorId = TOS_NODE_ID;
      		if (call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(SENSOR_ID)) == SUCCESS) {
      	  	busy = TRUE;
      		}
    		}
			break;
		}
	}

//----------------- implementation of events ------------------



	event void Boot.booted() {

		call AMControl.start(); //WAIT SENSOR_ID
		
  }

  event void AMControl.startDone(error_t err) {
    if (err == SUCCESS) {
      call Timer0.startPeriodic((TIMER_PERIOD_MILLI)*20) ;
    }
    else {
      call AMControl.start();
    }
  }

	event void AMControl.stopDone(error_t err) {
  }

event void Timer0.fired(){
		call Timer0.stop();

	if(TOS_NODE_ID == 1 && round){ //SENSOR_ID
			CH = TOS_NODE_ID;
			round = FALSE;
			sendMsg(1,0);
			dbg("Boot", "send SENSOR_ID\n");
			call AMControl.start(); //WAIT SENSOR_ID
		}	

		dbg("Boot", "OK, TIMMER FINISH \n");
}

  event void AMSend.sendDone(message_t* msg, error_t err) {
    if (&pkt == msg) {
      busy = FALSE;
    }
  }

	event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len){

		call Timer0.stop();
    if (len == sizeof(SENSOR_ID)) {
      SENSOR_ID* btrpkt = (SENSOR_ID*)payload;
			discoveredNeighbors(btrpkt->sensorId);
			if (round){
				sendMsg(1,0);
				round = FALSE;
				dbg("Boot","OK");
			}
    }
		call AMControl.start();
    return msg;
  }
}
