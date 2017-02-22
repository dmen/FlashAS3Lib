/**
 * Provides a single NetConnection object
 * maintains a persistent connection to the FMS application
 */
package com.gmrmarketing.esurance.sxsw_2014
{
	import flash.events.*;
	import flash.net.*;
	
	public class FMSConnector extends EventDispatcher
	{
		public static const FMS_CONNECTED:String = "ConnectedToFMS";		
		public static const FMS_DISCONNECTED:String = "DisconnectedFromFMS";
		private var connected:Boolean;
		private var nc:NetConnection;
		
		
		public function FMSConnector()
		{
			connected = false;
			
			nc = new NetConnection();
			nc.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus, false, 0, true);			
			nc.client = this;			
		}
		
		/**
		 * Connects to the application on the server
		 * dispatches FMS_CONNECTED when ready
		 */
		public function connect():void
		{
			nc.connect("rtmfp://localhost/esurance");
		}
		
		
		/**
		 * Returns the NetConnection object
		 * @return
		 */
		public function getConnection():NetConnection
		{
			return nc;
		}
		
		
		public function isConnected():Boolean
		{
			return connected;
		}
		
			
		private function onNetStatus(e:NetStatusEvent):void
		{
			trace("FMSCOnnector.netStatus():",e.info.code);
			if(e.info.code == "NetConnection.Connect.Success"){				
				dispatchEvent(new Event(FMS_CONNECTED));
				connected = true;
			}if(e.info.code == "NetConnection.Connect.Closed"){				
				dispatchEvent(new Event(FMS_DISCONNECTED));
				connected = false;
			}
		}
	}
	
}