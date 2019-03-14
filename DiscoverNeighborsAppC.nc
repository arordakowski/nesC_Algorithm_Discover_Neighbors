
#include "DiscoverNeighbors.h"

configuration DiscoverNeighborsAppC {
}
implementation {
	//GENERAL
  components MainC;
	components DiscoverNeighborsC as App;
	App -> MainC.Boot;
  
	//TIMMER
	components new TimerMilliC() as Timer0;
  App.Timer0 -> Timer0;
	
	//NETWORKING	
	components ActiveMessageC;
  components new AMSenderC(AM_DiscoverNeighbors);
  components new AMReceiverC(AM_DiscoverNeighbors);
  App.AMControl -> ActiveMessageC;
	App.Packet -> AMSenderC;
  App.AMPacket -> AMSenderC;
  App.AMSend -> AMSenderC;
  App.Receive -> AMReceiverC;

}

