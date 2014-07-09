package com.tastenkunst.as3.video {
	import flash.events.*;
	import flash.media.*;
	import flash.system.*;
	import flash.utils.*	
	
	/**
	 * Camera Manager, 
	 * 
	 * @author Marcel Klammer, 2012
	 * 
	 * 7/3/14 - DM removed timerHardware check and logic as it was goofy
	 */
	public class CameraManager {
		
		//private const _timerHardwareCheck:Timer = new Timer(2000,1);
		
		private var _camera:Camera;
		private var _handler:ICameraHandler;//implements onCameraActive/onCameraInactive methods

		public function CameraManager($handler:ICameraHandler = null) 
		{
			handler = $handler;
		}
		
		/** Initializes the Camera. */
		public function initCamera():void 
		{
			_camera = Camera.getCamera();
			
			if(_camera != null) {
				//_timerHardwareCheck.stop();
				//_camera.removeEventListener(StatusEvent.STATUS, onStatus);
	            _camera.addEventListener(StatusEvent.STATUS, onStatus);
				
				if (_handler) _handler.onCameraActive(_camera);
			}/*
			} else {
				_timerHardwareCheck.removeEventListener(TimerEvent.TIMER, onCheckRecordMedia);
				_timerHardwareCheck.addEventListener(TimerEvent.TIMER, onCheckRecordMedia);
				_timerHardwareCheck.start();
			}			*/
		}
		
		public function getCamera():Camera
		{
			return _camera;			
		}
		
		/** Checks onTimer, whether a Camera is available. */
		/*private function onCheckRecordMedia(e:Event):void 
		{
			if(_camera == null) {
				_camera = Camera.getCamera();
			}
			if(_camera != null) {
				initCamera();
			}
		}*/
		
		/** Calls the muteCheck, if the status changed. */
		private function onStatus(e:StatusEvent):void 
		{
            muteCheck();
        }
		
        /** Checks, whether the Camera is muted of not and calls ICameraHandler functions. */
        private function muteCheck():void 
		{
			if(_camera == null || _camera.muted) {
				if(_handler) _handler.onCameraInactive();
				Security.showSettings(SecurityPanel.PRIVACY);
            } else {
				if(_handler) _handler.onCameraActive(_camera);
			}
		}
		
		/** Returns the current ICameraHandler. */
		public function get handler():ICameraHandler 
		{
			return _handler;
		}
		
		/** Sets the ICameraHandler. */
		public function set handler(handler:ICameraHandler):void 
		{
			_handler = handler;
		}
	}
}
