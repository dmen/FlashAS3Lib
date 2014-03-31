package com.tastenkunst.as3.video {
	import flash.events.Event;
	import flash.events.StatusEvent;
	import flash.events.TimerEvent;
	import flash.media.Camera;
	import flash.system.Security;
	import flash.system.SecurityPanel;
	import flash.utils.Timer;
	
	/**
	 * Camera Manager, 
	 * 
	 * @author Marcel Klammer, 2012
	 */
	public class CameraManager {
		
		private const _timerHardwareCheck : Timer = new Timer(2000);
		
		private var _camera : Camera;
		private var _handler : ICameraHandler;

		public function CameraManager(handler : ICameraHandler = null) {
			this.handler = handler;
		}		
		/** Initializes the Camera. */
		public function initCamera() : void {
			_camera = Camera.getCamera();
			
			if(_camera != null) {
				_timerHardwareCheck.stop();
				_camera.removeEventListener(StatusEvent.STATUS, onStatus);
	            _camera.addEventListener(StatusEvent.STATUS, onStatus);
				
				if(_handler) _handler.onCameraActive(_camera); 
			} else {
				_timerHardwareCheck.removeEventListener(TimerEvent.TIMER, onCheckRecordMedia);
				_timerHardwareCheck.addEventListener(TimerEvent.TIMER, onCheckRecordMedia);
				_timerHardwareCheck.start();
			}			
		}
		public function getCamera():Camera
		{
			return _camera;			
		}
		/** Checks onTimer, whether a Camera is available. */
		private function onCheckRecordMedia(event : Event) : void {
			if(_camera == null) {
				_camera = Camera.getCamera();
			}
			if(_camera != null) {
				initCamera();
			}
		}
		/** Calls the muteCheck, if the status changed. */
		private function onStatus(event : StatusEvent) : void {
            muteCheck();
        }
        /** Checks, whether the Camera is muted of not and calls ICameraHandler functions. */
        private function muteCheck() : void {
			if(_camera == null || _camera.muted) {
				if(_handler) _handler.onCameraInactive();
				Security.showSettings(SecurityPanel.PRIVACY);
            } else {
				if(_handler) _handler.onCameraActive(_camera);
			}
		}
		/** Returns the current ICameraHandler. */
		public function get handler() : ICameraHandler {
			return _handler;
		}
		/** Sets the ICameraHandler. */
		public function set handler(handler : ICameraHandler) : void {
			_handler = handler;
		}
	}
}
