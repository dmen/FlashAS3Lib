package com.tastenkunst.as3.video {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.PixelSnapping;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.media.Camera;
	import flash.media.Video;
	import flash.net.NetStream;
	
	/**
	 * The VideoManager uses the Camera reference to draw into a BitmapData. 
	 * BRF works only with 640x480 BitmapData size.
	 * 
	 * @author Marcel Klammer
	 */
	public class VideoManager1280x960 {
		
		/** Width of the video. If you use another value than 640, make sure, that BRF gets a BitmapData, that is 640px in width. */
		public const VIDEO_WIDTH : int = 1280;
		/** Height of the video. If you use another value than 480, make sure, that BRF gets a BitmapData, that is 480px in height. */
		public const VIDEO_HEIGHT : int = 960;
		/** Web cam frame rate. */
		public const VIDEO_FRAMERATE : int = 30;
		
	 	private const _video : Video = new Video(VIDEO_WIDTH, VIDEO_HEIGHT);
		private const _videoData : BitmapData = new BitmapData(VIDEO_WIDTH, VIDEO_HEIGHT, false, 0x000000);		
		private const _videoMatrix : Matrix = new Matrix(-1, 0, 0, 1, VIDEO_WIDTH);
		private const _videoBitmap : Bitmap = new Bitmap(_videoData, PixelSnapping.AUTO, true);
		private const _videoContainer : Sprite = new Sprite();
		private const _imageBitmap : Bitmap = new Bitmap(null, PixelSnapping.AUTO, true);
				
		private var _camera : Camera;
		private var _netStream : NetStream;
		private var _image : BitmapData;
		private var _mirrored : Boolean;

		private var _handler : IVideoHandler;

		public function VideoManager1280x960($handler : IVideoHandler = null, $mirrored : Boolean = true) 
		{
			handler = $handler;
			mirrored = $mirrored;
			_videoContainer.addChild(_video);
			_videoContainer.addChild(_imageBitmap);
		}
		/** Starts the drawing of the video. */
		public function start() : void {
			//stop();
			_video.addEventListener(Event.ENTER_FRAME, render);
		}
		/** Stops the drawing of the video. */
		public function stop() : void {
			_video.removeEventListener(Event.ENTER_FRAME, render);
		}
		/** Attaches either a Camera or a NetStream object as input. */
		public function attachInput(camera : Camera = null, netStream : NetStream = null, image : BitmapData = null) : void {
			_camera = camera;
			_netStream = netStream;
			_image = image;
			
			if(_camera) {
				_camera.setMode(VIDEO_WIDTH, VIDEO_HEIGHT, VIDEO_FRAMERATE);
				_video.attachCamera(_camera);
				
				start();
			} else if(_netStream) {
				_video.attachNetStream(_netStream);
				
				start();
			} else if(_image) {
				_imageBitmap.bitmapData = _image;
				start();
			}
		}
        /** Removes the attached input (Camera or NetStream). */
        public function detachInput() : void {
			stop();
			
			if(_camera) {
				_video.attachCamera(null);
				_camera = null;
			} 
			if(_netStream) {
				_video.attachNetStream(null);
				_netStream = null;
			}
			if(_image) {
				_imageBitmap.bitmapData = null;
				_image = null;
			}
			_video.clear();
        }
		/** Draws the video into the videoData and calls onVideoUpdate. */
		public function render(e:Event = null) : void 
		{
			_videoData.lock();
			_videoData.draw(_videoContainer, _videoMatrix);			
			_videoData.unlock();
			
			if(_handler) _handler.onVideoUpdate();
		}
		/** Sets whether the video is drawn mirrored or not. */
		public function set mirrored(mirrored : Boolean) : void {
			_mirrored = mirrored;
			
			if(mirrored) {
				_videoMatrix.a = -1;
				_videoMatrix.tx = VIDEO_WIDTH;
			} else {
				_videoMatrix.a = 1;
				_videoMatrix.tx = 0;
			}
		}
		/** Returns whether the video is mirrored or not. */
		public function get mirrored() : Boolean {
			return _mirrored;
		}
		/** Sets the IVideoHandler. */
		public function set handler(handler : IVideoHandler) : void {
			_handler = handler;
		}
		/** The current IVideoHandler, if there is one, null otherwise. */
		public function get handler() : IVideoHandler {
			return _handler;
		}
		/** The BitmapData object the video gets drawn to. */
		public function get videoData() : BitmapData {
			return _videoData;
		}		
		/** The current Camera object, if there is one, null otherwise. */
		public function get camera() : Camera {
			return _camera;
		}
		/** The current NetStream object, if there is one, null otherwise. */
		public function get netStream() : NetStream {
			return _netStream;
		}
		/** The current attached input BitmapData */
		public function get image() : BitmapData {
			return _image;
		}
		/** A Bitmap, that can be used to display the video data. */
		public function get videoBitmap() : Bitmap {
			return _videoBitmap;
		}
	}
}
