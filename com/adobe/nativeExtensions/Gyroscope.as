////////////////////////////////////////////////////////////////////////////////////////////////////////	
//	ADOBE SYSTEMS INCORPORATED																		  //
//	Copyright 2011 Adobe Systems Incorporated														  //
//	All Rights Reserved.																			  //
//																									  //
//	NOTICE:  Adobe permits you to use, modify, and distribute this file in accordance with the		  //
//	terms of the Adobe license agreement accompanying it.  If you have received this file from a	  //
//	source other than Adobe, then your use, modification, or distribution of it requires the prior	  //
//	written permission of Adobe.																	  //
////////////////////////////////////////////////////////////////////////////////////////////////////////

package com.adobe.nativeExtensions
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.StatusEvent;
	import flash.events.TimerEvent; 
	import flash.external.ExtensionContext;
	import flash.utils.Timer;
	
	

    // The application using the Gyroscope extension can create multiple instances of
    // Gyroscope. However, the instances all use a singleton ExtensionContext object.
    //
    // The singleton ExtensionContext object listens for StatusEvent events that
    // the native implementation dispatches. These events contain the device's
    // gyroscope x,y,z data.
    //
    // However, each Gyroscope instance has its own interval timer. When the timer
    // expires, the Gyroscope instance dispatches a GyroscopeEvent that contains
    // the current x,y,z data.
    
    public class Gyroscope extends EventDispatcher {  
	
		private var interval:int = 100;
		private var intervalTimer:Timer = null;
		
		private static var _x:Number = 0;
		private static var _y:Number = 0;
		private static var _z:Number = 0;
		
		private static var refCount:int = 0;
        
		private static var extCtx:ExtensionContext = null;
        
        private static var isInstantiated:Boolean = false;
        
		private static var checkedIfSupported:Boolean = false;
        
		private static var supported:Boolean = false;
        
        
		
		// Gyroscope constructor
        //
        
        public function Gyroscope(){
			
			if (!isInstantiated){
				extCtx = ExtensionContext.createExtensionContext("com.adobe.gyroscope", null);
				
				if (extCtx != null){
					extCtx.call("init"); 
					
					if (!extCtx.call("gyroscopeStart", GyroscopeIntervalValue.INTERVAL_FASTEST)) {  
						throw new Error("Error while Starting Gyroscope"); 
					} 
					else {
						extCtx.addEventListener(StatusEvent.STATUS, onStatus);
					}
				} 
				
				isInstantiated = true;
			}
			
			if (extCtx != null) {
				refCount++;
				intervalTimer = new Timer(interval);
				intervalTimer.addEventListener(TimerEvent.TIMER,onInterval); 
				intervalTimer.start();
			}
			else{
				throw new Error("Error while instantiating Gyroscope Extension");
			}
		}
	
        // isSupported()
        //
        // Use this static method to determine whether the device
        // has gyroscope support.
        
        public static function get isSupported():Boolean {
			
			var ctx:ExtensionContext = null;
			
			if (checkedIfSupported == false) {
				
				// This time is the first time that isSupported() is called. 
				checkedIfSupported = true;
				
				ctx = ExtensionContext.createExtensionContext("com.adobe.gyroscope",null);
				
				if (ctx != null) {
					
					ctx.call("init"); 
					
					supported = ctx.call("gyroscopeSupport") as Boolean;
					
					trace("gyroscopeSupport Returned : " + supported); 
								
					ctx.dispose();
					ctx = null;
					return supported;
				}
				
				else{
					return false; 
				} 
				
			} 
			
			else {
				// Already checked if supported, so the value of supported is already set.
				return supported; 
			}
		}
		
		
        // isMuted()
        //
        // This method is for parity with the ActionScript class Accelerometer. However, it is not
        // yet implemented.
        
        public static function get isMuted():Boolean {
			
			return false;
		}
        
        
		
		// setRequestedUpdateInterval()
        //
		// Sets the rate in milliseconds at which this instance will receive gyroscope updates.
        
		public function setRequestedUpdateInterval( newInterval:int ):void {
			
			// Make sure the existing timer is not null. It shouldn't be.
			// Then stop the timer and start a new one with the new interval.
            
			if (intervalTimer != null) {
				
				intervalTimer.removeEventListener(TimerEvent.TIMER,onInterval);
				intervalTimer.stop();
				intervalTimer = null;
			}
			
			// Each instance of Gyroscope has its own interval timer.
			interval = newInterval;
			intervalTimer = new Timer(interval);
			intervalTimer.addEventListener(TimerEvent.TIMER, onInterval); 
			intervalTimer.start();
		}
		
        
        
		// dispose()
        //
        
        public function dispose():void {
			
			refCount --;
			
			// Make sure the refCount does not go negative -- the extension user could have an extra
			// call to dispose().
            
			if (refCount < 0) refCount = 0;
			
			if(refCount == 0) { 
			
				if (extCtx != null) {
					
					extCtx.call("gyroscopeStop");
					extCtx.removeEventListener(StatusEvent.STATUS,onStatus);
					extCtx.dispose();
					extCtx = null;
				}
			}
		}
		 
		
        
        // onStatus()
        // Event handler for the event that the native implementation dispatches.
        // The event contains the latest gyroscope x,y,z data.
        //
        
        private static function onStatus(e:StatusEvent):void {
			
			if (e.code == "CHANGE") {
				
				var vals:Array = e.level.split("&");
				var x:Number = Number(vals[0]); 
				var y:Number = Number(vals[1]);
				var z:Number = Number(vals[2]);
				_x = x;
				_y = y;
				_z = z;
			}
		}
		
		
        // onInterval()
        // Event handler for the interval timer for a Gyroscope instance.
        //
        
        private function onInterval(e:TimerEvent):void {
			
			// For each Gyroscope instance, at the requested interval,
			// dispatch the gyroscope data.
			
 			if (extCtx != null) {
				dispatchEvent(new GyroscopeEvent(GyroscopeEvent.UPDATE, _x, _y, _z));
			}
		}
	}
}