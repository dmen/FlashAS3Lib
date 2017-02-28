package com.gmrmarketing.esurance.sxsw_2014
{
	import flash.ui.Mouse;
	import flash.display.*;
	import flash.events.*;
	import flash.utils.Timer;
	
	import com.gmrmarketing.esurance.sxsw_2014.SocketServer;
	import com.gmrmarketing.esurance.sxsw_2014.FMSConnector;
	import com.gmrmarketing.esurance.sxsw_2014.H264Recorder;
	import com.gmrmarketing.esurance.sxsw_2014.FLVRecorder;
	import com.gmrmarketing.esurance.sxsw_2014.Slideshow;
	import com.gmrmarketing.esurance.sxsw_2014.StaticSlideshow;
	import com.gmrmarketing.esurance.sxsw_2014.VideoDisplay;
	import com.gmrmarketing.esurance.sxsw_2014.Dialog;
	
	import com.gmrmarketing.utilities.GUID;
	import com.gmrmarketing.utilities.Strings;
	import com.gmrmarketing.utilities.AIRXML;
	
	
	public class Main extends MovieClip
	{
		private var fmsConnector:FMSConnector;//persistent netConnection object
		private var server:SocketServer;//small server for receiving start/stop messages from BB
		
		private var recorder:H264Recorder;
		private var videoDisplay:VideoDisplay;//for showing the live camera
		
		private var slideshow:StaticSlideshow;
		private var maxTimer:Timer;//keeps recording length to a max time (1 min)
		private var dialog:Dialog;
		private var config:AIRXML;
		
		
		public function Main()
		{	
			stage.displayState = StageDisplayState.FULL_SCREEN;
			stage.scaleMode = StageScaleMode.EXACT_FIT;
			Mouse.hide();
			
			maxTimer = new Timer(45000);
			maxTimer.addEventListener(TimerEvent.TIMER, stopRecording);			
			
			recorder = new H264Recorder();			
			
			slideshow = new StaticSlideshow();
			slideshow.setContainer(this);
			
			videoDisplay = new VideoDisplay();
			videoDisplay.setContainer(this);
			
			dialog = new Dialog();
			dialog.setContainer(this);
			
			config = new AIRXML();//reads config.xml - gets the image list for the slideshow
			config.addEventListener(Event.COMPLETE, init, false, 0, true);
			config.addEventListener(AIRXML.NOT_FOUND, noXML, false, 0, true);
			config.readXML();			
		}
		
		
		private function init(e:Event):void
		{
			var params:XML = config.getXML();
			slideshow.setXML(params.slideshow.image);
			trace("listening on port", params.port);
			server = new SocketServer(parseInt(params.port));
			server.addEventListener(SocketServer.CONNECT, clientConnected, false, 0, true);
			server.addEventListener(SocketServer.DISCONNECT, clientDisconnected, false, 0, true);
			server.addEventListener(SocketServer.MESSAGE, clientMessage, false, 0, true);
			
			fmsConnector = new FMSConnector();
			fmsConnector.addEventListener(FMSConnector.FMS_CONNECTED, FMSAvailable, false, 0, true);
			fmsConnector.addEventListener(FMSConnector.FMS_DISCONNECTED, FMSDisconnect, false, 0, true);
			fmsConnector.connect();
		}
		
		private function noXML(e:Event):void
		{
			dialog.show("ERROR: Config.xml file not found in application folder.");
		}
		
		
		private function FMSAvailable(e:Event):void
		{			
			trace("connected to FMS");
			//slideshow.init(fmsConnector.getConnection());			
			slideshow.show();
		}
		
		
		private function FMSDisconnect(e:Event):void
		{
			dialog.show("ERROR: FMS has disconnected.");
		}
		
		
		/**
		 * Called when a TCP client connects to the opened port in SocketServer
		 * @param	e
		 */
		private function clientConnected(e:Event):void
		{
			trace("client connected");
		}
		
		
		private function clientDisconnected(e:Event):void
		{
			trace("client disconnected");
		}
		
		
		private function clientMessage(e:Event):void
		{
			var m:String = Strings.removeLineBreaks(server.message);
			trace("message:",m);
			if(fmsConnector.isConnected()){
				if (m == "start") {
					slideshow.hide();
					recorder.startRecording(fmsConnector.getConnection(), GUID.create());//guid file name
					videoDisplay.show(recorder.getCamera());
					
					maxTimer.reset();
					maxTimer.start();//calls stopRecording() in 1 minute
				}
				
				if (m == "stop") {
					stopRecording();
				}
			}
		}
		
		
		private function stopRecording(e:TimerEvent = null):void
		{
			maxTimer.reset();
			recorder.stopRecording();
			videoDisplay.hide();									
			slideshow.show();
		}
		
	}
	
}