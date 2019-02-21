
#include "Lca.h"

configuration LcaAppC {
}
implementation {
	//GENERAL
  components MainC;
	components LcaC as App;
	App -> MainC.Boot;
  
	//TIMMER
	components new TimerMilliC() as Timer0;
  App.Timer0 -> Timer0;
	
	//NETWORKING	
	components ActiveMessageC;
  components new AMSenderC(AM_LCA);
  components new AMReceiverC(AM_LCA);
  App.AMControl -> ActiveMessageC;
	App.Packet -> AMSenderC;
  App.AMPacket -> AMSenderC;
  App.AMSend -> AMSenderC;
  App.Receive -> AMReceiverC;

}

