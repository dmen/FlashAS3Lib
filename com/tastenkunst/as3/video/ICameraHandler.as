package com.tastenkunst.as3.video {
	import flash.media.Camera;
	/**
	 * @author Marcel Klammer, 2012
	 */
	public interface ICameraHandler {
		function onCameraActive(camera : Camera) : void;
		function onCameraInactive() : void;
	}
}
