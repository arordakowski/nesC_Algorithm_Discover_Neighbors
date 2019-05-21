
module Coordinator(){

	uses{
 	 interface Boot;
 	 interface Packet;
 	 interface  AMSend;
 	 interface  Receive;
 	 interface  SplitControl as AMControl;
 	 interface  Timer<TMilli> as Timer0;
 	 interface compSensor as ComponentsSensor;
 	 interface compLibMSG as ComponentsLibMessage;
 	}
 
}
implementation{

message_t pkt;
const tFlood = 25;
const tExit = 0.10;
const local = ptBR;
uint16_t myID  = compSensor->getSensorId();
list<uint16_t> listSensorAnnouncements;
uint16_t msgID;

void state_INI(){
if( myID == 0 ){
msgID = compLibMSG->GetNextMsgId();
broadcast(SENSORID, msgID, myID); ===== Aqui deve ser o método sendMSG()
compLibMSG->addSeenMsg(SENSORID, msgID);
}
WaitFirstSensorID();
}

void state_WaitFirstSensorID(){
listSensorAnnouncements.insert(ID);
if( !compLibMSG->seenMsg(SENSORID, msgId) ){
compLibMSG->seenMsg(SENSORID, msgId);
broadcast(SENSORID, msgID, myID); ===== Aqui deve ser o método sendMSG()
}
FormNeighborList();
}

void state_FormNeighborList(){
 call Timer0.startOneShot(tFlood);
listSensorAnnouncements.insert(ID);
ACKNeighborList();
}

void state_ACKNeighborList(){
ACKSENSORIDcompLibMSG->GetNextMsgId()listSensorAnnouncementmyIDStoreNeighborList();
}

void state_StoreNeighborList(){
 call Timer0.startOneShot(tExit);
listSensorAnnouncementsif( anId == myID ){
compSensor->listKnownNeighbors.insert(fromID);
}
exit();
}

 // ===== Começam aqui os eventos do nesC =====

event void Boot.booted() {
 call AMControl.start(); 	// initialize Radio
}

event void AMControl.startDone(error_t err) {
}
event void Timer0.fired(){	   //timer fired 
}

//event to receive messages 
 event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len){
}
return msg;
}

event void AMControl.stopDone(error_t err) {}

event void AMSend.sendDone(message_t* msg, error_t err) {}


}