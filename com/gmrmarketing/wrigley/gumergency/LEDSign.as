package com.gmrmarketing.wrigley.gumergency
{
	import flash.display.*;
	import flash.net.SharedObject;
	import flash.net.Socket;
	import flash.utils.*;
	import flash.events.*;
	
	public class LEDSign extends MovieClip 
	{
		private const LOCALHOST:String = "127.0.0.1"; //ip of serproxy
		
		private var so:SharedObject; //stores soData
		private var soData:Array; //chars per frame, frame speed
		private var charsPerFrame:int;
		private var frameSpeed:Number;
		
		private var socket:Socket;
		private var feed:FeedReader;
		private var connected:Boolean;//true when connected to serproxy
		private var manualRefresh:Boolean;
		
		
		
		public function LEDSign()
		{
			connected = false;
			manualRefresh = false;
			
			feed = new FeedReader();
			feed.addEventListener(FeedReader.COMPLETE, gotMessages, false, 0, true);
			feed.addEventListener(FeedReader.ERROR, feedError, false, 0, true);
			
			btnReset.addEventListener(MouseEvent.CLICK, doReset, false, 0, true);
			btnRefresh.addEventListener(MouseEvent.CLICK, doRefresh, false, 0, true);
			btnSave.addEventListener(MouseEvent.CLICK, saveData, false, 0, true);
			btnHelp.addEventListener(MouseEvent.CLICK, showHelp, false, 0, true);
			
			socket = new Socket();
			socket.addEventListener(IOErrorEvent.IO_ERROR, errorHandler, false, 0, true);
			socket.addEventListener(Event.CONNECT, doSocketConnect, false, 0, true);
			socket.addEventListener(Event.CLOSE, doSocketClose, false, 0, true);
			socket.addEventListener(Event.COMPLETE, onReady, false, 0, true);
			
			so = SharedObject.getLocal("ledData", "/");
			soData = so.data.data;
			if (soData == null) {
				soData = new Array(29, 2.4, 5333, 'n');//chars per frame, time per frame, port, test mode
				so.data.data = soData;
				so.flush();
			}
			chars.text = soData[0];
			speed.text = soData[1];
			port.text = soData[2];			
			testmode.text = soData[3] == 'y' ? 'y' : 'n';
			var tm:Boolean = soData[3] == 'y' ? true : false;
			feed.setTestMode(tm);
			
			socket.connect( LOCALHOST, soData[2] );
		}
		
		
		/**
		 * Sends reset packet to the sign
		 * @param	e
		 */
		private function doReset(e:MouseEvent):void
		{
			var bytes:ByteArray = new ByteArray();
			
			//FMODE 0 - makes sign react immediately
			bytes.writeByte(0x02); //STX
			bytes.writeByte(0x01); //sign address 0x00,0x00 for all signs
			bytes.writeByte(0x00);
			bytes.writeByte(0x43);
			bytes.writeByte(0x30); //0
			bytes.writeByte(0x03); //ETX
			var bcc:int = getBCC(bytes);			
			bytes.writeByte(bcc);		
			
			bytes.writeByte(0x02);//STX
			bytes.writeByte(0x01);//address
			bytes.writeByte(0x00);//...
			bytes.writeByte(0x41);//reset ('A')
			bytes.writeByte(0x03);//ETX
			
			bcc = getBCC(bytes);			
			bytes.writeByte(bcc);
			
			if (connected) {
				socket.writeBytes(bytes);
				socket.flush();
				
				log("\nSign was manually reset at" + String(new Date()));
				log("WAIT until POWER is displayed before pressing refresh.");				
				
				feed.resetTimer();
			}
		}
		
		
		private function doRefresh(e:MouseEvent):void
		{
			if (connected) {
				manualRefresh = true;
				feed.load();
				log("Manually refreshed feed at: " + String(new Date()));
			}
		}
		
		
		private function saveData(e:MouseEvent):void
		{
			so.data.data = [parseInt(chars.text), parseFloat(speed.text), parseInt(port.text), testmode.text];
			var tm:Boolean = soData[3] == 'y' ? true : false;			
			feed.setTestMode(tm);
			so.flush();
		}
		
		private function showHelp(e:MouseEvent):void
		{
			help.alpha = 1;
			help.btnClose.addEventListener(MouseEvent.CLICK, closeHelp, false, 0, true);
		}
		
		private function closeHelp(e:MouseEvent):void
		{
			help.alpha = 0;
			help.btnClose.removeEventListener(MouseEvent.CLICK, closeHelp);
		}
		
		
		/**
		 * Called by listener on feedReader when new messages have been retrieved
		 * @param	e
		 */
		private function gotMessages(e:Event):void
		{
			
			if (connected) {
				var m:String = feed.getNewMessages();
				//var m:String = feed.getMessages();
				log("Retrieved " + feed.getNumNewMessages() + " new messages.");				
				
				if (feed.getNumNewMessages() > 0) {
					log("Sending to sign");
					if (m != "") {
						var reg:RegExp = new RegExp("\n\n", "gi");
						m = m.replace(reg, "");
						
						reg = new RegExp("\n", "gi");
						m = m.replace(reg, "");
						
						//remove carriage returns
						reg = new RegExp("\r", "gi");
						m = m.replace(reg, "");
						
						reg = new RegExp("&amp;", "gi");
						m = m.replace(reg, "&");
						
						//double to single spaces
						reg = new RegExp("  ", "gi");
						m = m.replace(reg, " ");
						
						//em dash
						reg = new RegExp("–", "gi");
						m = m.replace(reg, "-");					
						
						//remove quotes
						reg = new RegExp("“", "gi");
						m = m.replace(reg, ""); 
						
						reg = new RegExp("”", "gi");
						m = m.replace(reg, "");		
						
						pushMessage(m);	//send to sign
						
						var charCount:int = m.length; //total number of character being displayed
						var numFrames:int = Math.round(charCount / soData[0]);					
						var totalTime:int = Math.round(numFrames * soData[1]);
						
						//trace("char count:", charCount, "num frames:", numFrames, "total time", totalTime);
						feed.refreshQueue(totalTime * 1000);//milliseconds
						log("Refreshing in " + totalTime + " seconds.");
					}
				}else {
					feed.refreshQueue(15000);
					log("Refreshing in 15 seconds.");
				}
			}
		}
		
		private function feedError(e:Event):void
		{
			log("=== Feed Error ===");
			log("Refreshing in 30 seconds.");
		}
		
		
		private function errorHandler(e:IOErrorEvent):void {   
			log("- " + e.text + "\n");
			log("Did you start Serproxy?");  
		   
		}
		
		
		private function doSocketConnect( e:Event ):void {
			log("Connection with Serproxy established.");			
			connected = true;
		}
		
		
		private function doSocketClose( e:Event ):void {
			log("Connection with Serproxy has been closed");
			connected = false;
		}
		
		
		private function onReady(e:Event):void
		{
			log("Message pushed to sign")
		}
		
		private function log(mess:String):void
		{
			theText.appendText(mess + "\n");
			theText.scrollV = theText.numLines;
		}
		
		
		/**
		 * Pushes the Message to the LED Sign
		 * @param	message String for sign to display
		 */
		public function pushMessage(message:String):void
		{
			var bytes:ByteArray = new ByteArray();
	
			var fileSize:uint = message.length + 18; //18 bytes between the header and the message body			
			
			//FMODE 1 or 0 depending on manualRefresh
			bytes.writeByte(0x02); //STX
			bytes.writeByte(0x01); //sign address 0x00,0x00 for all signs
			bytes.writeByte(0x00);
			bytes.writeByte(0x43); //C - File transfer mode
			if(manualRefresh){
				bytes.writeByte(0x30); // '0' --immediate
			}else {
				bytes.writeByte(0x31); // '1' --queue file
			}
			bytes.writeByte(0x03); //ETX
			var bcc:int = getBCC(bytes);			
			bytes.writeByte(bcc); //BCC
			
			manualRefresh = false;
			
			//MESSAGE PACKET
			bytes.writeByte(0x02); //STX
			bytes.writeByte(0x01); //sign address 0x00,0x00 for all signs
			bytes.writeByte(0x00);
			bytes.writeByte(0x33); //command - transmit file (3 - "char 3" is hex 0x33 - or decimal 51)
			bytes.writeByte(0x40); //null terminated file name @file.st1			
			bytes.writeByte(0x66);
			bytes.writeByte(0x69);
			bytes.writeByte(0x6C);
			bytes.writeByte(0x65);
			bytes.writeByte(0x2E);
			bytes.writeByte(0x73);
			bytes.writeByte(0x74);
			bytes.writeByte(0x31);
			bytes.writeByte(0x00);			
			
			//File Size - Not of File Size
			var LSB:uint;
			var MSB:uint;
			var notLSB:uint;
			var notMSB:uint;
			
			var n:String = (fileSize.toString(16));	//convert to hex		
			if(n.length > 2){
				var LSBs:String = n.substr(n.length - 2);
				var MSBs:String = n.substr(0, n.length - 2);
				LSB = parseInt("0x" + LSBs);
				MSB = parseInt("0x" + MSBs);
			}else {
				LSB = fileSize;
				MSB = 0x00;				
			}
			notLSB = ~LSB & 0xFF; //NOT / 1s COMPLEMENT
			notMSB = ~MSB & 0xFF;
			
			bytes.writeByte(LSB); //ok if 1 byte file size
			bytes.writeByte(MSB);			
			bytes.writeByte(notLSB);//not file size
			bytes.writeByte(notMSB);

			//all this forward is part of the file size = 18 bytes
			bytes.writeByte(0xF1);//font code 
			bytes.writeByte(0x01);
			bytes.writeByte(0x00);
			bytes.writeByte(0x00);

			bytes.writeByte(0x00);//padding
			bytes.writeByte(0x00);

			bytes.writeByte(0xF1);//travel speed
			bytes.writeByte(0x05);
			bytes.writeByte(0x09); //slowest
			bytes.writeByte(0x00);

			bytes.writeByte(0x00);//padding
			bytes.writeByte(0x00);

			bytes.writeByte(0xF0);//scroll left to right
			bytes.writeByte(0x10);

			bytes.writeByte(0x00);//padding
			bytes.writeByte(0x00);
			bytes.writeByte(0x00);
			bytes.writeByte(0x00);
			
			//now add the message body
			for(var i:int = 0; i < message.length; i++){				
				bytes.writeByte(message.charCodeAt(i));
			}
			
			//Final two bytes ETX and BCC
			bytes.writeByte(0x03); //ETX
			
			bcc = getBCC(bytes);			
			bytes.writeByte(bcc);
			
			//write the byte stream to the sign
			socket.writeBytes(bytes);
			socket.flush();  
		}
		
		
		/**
		 * Calculates the BCC
		 * The XOR of all bytes in the incoming ByteArray
		 * @param	ba
		 * @return 	BCC
		 */
		private function getBCC(ba:ByteArray):int
		{
			var bcc:int;
			for(var i:int = 0; i < ba.length; i++){	
				bcc = bcc ^ ba[i]; 
			}
			return bcc;
		}
		
	}
	
}