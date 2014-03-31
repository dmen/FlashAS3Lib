package com.rimv.aMediaGallery
{
	// pv3d import
	import flash.net.*;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import org.papervision3d.materials.BitmapMaterial;
	import org.papervision3d.materials.MovieMaterial;
	import org.papervision3d.objects.DisplayObject3D;
    import org.papervision3d.objects.primitives.Plane;
	import org.papervision3d.view.stats.StatsView;
	import org.papervision3d.events.InteractiveScene3DEvent;
	import org.papervision3d.view.Viewport3D;
	import org.papervision3d.scenes.Scene3D;
	import org.papervision3d.render.BasicRenderEngine;
	import org.papervision3d.cameras.*;
	import org.papervision3d.view.stats.StatsView;
	
    // TweenMax
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	
	// flash library
	import flash.events.*;
	import flash.display.*;
	import flash.text.TextField;
	import flash.filters.*;
	import flash.geom.*;
	import flash.system.*;
	
	// RimV libs
	import com.rimv.utils.*;
	
	public class aMediaGallery extends MovieClip
	{
		// 3D variables
		public var scene:Scene3D;
		public var viewport:Viewport3D;
		public var renderer:BasicRenderEngine;
		public var camera:Camera3D;
		
		// general configs
		private var quality, switchDuration, flipDuration, mouseScrollingSpeed:Number;
		private var smoothing, precise, randomDistribution:Boolean;
				
		// gallery configs
		private var refDistance, refInf1, refInf2, refDens1, refDens2:Number;
		
		// misc vars
		public var configObject:Object;
		public var data:XML;
		private var TOTAL, count:Number;
		private var indexTrack:Dictionary;
		private var dData = []; // distribute data
		private var refMaker:Reflection;
		public var cID:Number = 0;
		private var flippingEnable:Boolean;
		private var backPlane:Plane;
		private var backMat:MovieMaterial;
		private var loadedQueue = [];
		private var fullLoaded = [];
		private var q, q0:Number;
		private var sTimer:Timer;
		public var slideShow:Timer;
		private var ssDelay:Number;
		public var isSlideShow:Boolean;
		private var XO, YO, OX, OY:Number;
		public var myTween:TweenMax;
		private var yPos:Number;
		private var pivot:String;
		private var mc:MovieClip = new MovieClip();
		private var isMouseUp:Boolean;
		private var control:MovieClip;
		private var cOver:Boolean = false;
		private var useScroller:Boolean = false;
		private var pOver:Boolean = false;
		private var type:String;
		public var swfLoader:Loader;
		public var w, h:Number;
		public var stageDown:Boolean = false;
		private var isClosed:Boolean = false;
		private var transparent:Boolean;
		private var photoPrecise:Boolean;
		private var photoSmooth:Boolean;
		public var thisThingIsLoaded:Boolean = false;
		
		// reference movie clip
		private var preloadThumbnail, dScroller, backClip, mp3Player, videoPlayer, lastClip, closeVideoBtn:MovieClip;
				
		// Apply 3D parameters in contructor
		public function aMediaGallery(scene:Scene3D, viewport:Viewport3D, renderer:BasicRenderEngine, camera:Camera3D, configObject:Object)
		{
			// retrieve data
			this.scene = scene;
			this.viewport = viewport;
			this.renderer = renderer;
			this.camera = camera;
			this.configObject = configObject;
			quality = configObject.quality;
			
			trace("aMediaGallery");
		}
		
		// create gallery based on passed XML data
		public function createGallery(data:XML, type:String):void
		{
			// retrieve data
			this.data = data;
			this.type = type;
			refDistance = Number(data.config.@refDistance);
			refInf1 = Number(data.config.@refInf1);
			refInf2 = Number(data.config.@refInf2);
			refDens1 = Number(data.config.@refDens1);
			refDens2 = Number(data.config.@refDens2);
			flippingEnable = Boolean(data.config.@flippingEnable == "true");
			isSlideShow = Boolean(data.config.@slideShow == "true");
			ssDelay = Number(data.config.@slideShowDelay);
			pivot = String(data.config.@pivotPoint);
			useScroller = Boolean(data.config.@useScroller == "true");
			transparent = Boolean(data.config.@photoTransparent == "true");
			photoPrecise = Boolean(data.config.@precise == "true");
			photoSmooth = Boolean(data.config.@smoothing == "true");
			refMaker = new Reflection(refInf1, refInf2, refDens1, refDens2, transparent, configObject.backgroundColor2);
			if (transparent) addChild(refMaker);
			// mp3 configuration
			if (type == "mp3")
			{
				mp3Player = this.parent["mp3Player"];
				this.parent.addChild(mp3Player);
				mp3Player.visible = false;
				mp3Player.alpha = 0;
				mp3Player.bufferTime = Number(data.config.@bufferTime);
				mp3Player.SpectrumLineColor = Number(data.config.@SpectrumLineColor);
				mp3Player.SpectrumLineWidth = Number(data.config.@SpectrumLineWidth);
				mp3Player.x = (stage.stageWidth - mp3Player.width) * .5;
				mp3Player.y = (stage.stageHeight - mp3Player.height) * .5;
				mp3Player.visible = false;
				mp3Player.addEventListener(MouseEvent.MOUSE_OVER, playerOver);
				mp3Player.addEventListener(MouseEvent.MOUSE_OUT, playerOut);
			}
			//video configuration
			else
			if (type == "video")
			{
				videoPlayer = this.parent["videoPlayer"];
				this.parent.addChild(videoPlayer);
				videoPlayer.visible = false;
				videoPlayer.alpha = 0;
				videoPlayer.videoWidth = Number(data.config.@videoWidth);
				videoPlayer.videoHeight = Number(data.config.@videoHeight);
				videoPlayer.bufferTime = Number(data.config.@bufferTime);
				videoPlayer.x = (stage.stageWidth - videoPlayer.width) * .5;
				videoPlayer.y = (stage.stageHeight - videoPlayer.height) * .5;
				videoPlayer.addEventListener(MouseEvent.MOUSE_OVER, playerOver);
				videoPlayer.addEventListener(MouseEvent.MOUSE_OUT, playerOut);
				videoPlayer.addEventListener("videoIsDone", closePress);
			}
			
			indexTrack = new Dictionary(true);
			count = 0;
			cID = 0;
			// thumbnail preloader / dScroller reference
			preloadThumbnail = this.parent["preloadThumbnail"];
			dScroller = this.parent["dScroller"];
			// total item
			dScroller.TOTAL = TOTAL = data.items.item.length();
			// thumbnail preloader
			this.parent.addChild(preloadThumbnail);
			preloadThumbnail.content.text = "LOADING THUMBNAIL 0 / " + TOTAL;
			preloadThumbnail.x = stage.stageWidth * .5;
			preloadThumbnail.y = stage.stageHeight * .5;
			// intialize distribute data
			initDistributedData();
			// load thumbnail
			loadedQueue = [];
			q = q0 = 0;
			// turn disable layer on
			this.parent["disableLayer"].visible = true;
			for (var i:Number = 0; i < TOTAL; i++)
			{
				var loader:Loader = new Loader();
				loader.load(new URLRequest(data.items.item[i].small.@src));
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, thumbnailLoaded, false, 0, true);
				indexTrack[loader] = i;
			}
			// enter frame check data load
			addEventListener(Event.ENTER_FRAME, onDataLoading, false, 0, true);
			
			// sTimer - 3d render manager
			sTimer = new Timer(1000, 1);
			sTimer.addEventListener(TimerEvent.TIMER_COMPLETE, stopRendering, false, 0, true);
		}
		
		// Thumbnail loaded - create 3D item
		private function thumbnailLoaded(e:Event):void
		{
			loadedQueue[q++] = e.target.loader;
		}
		
		// check if there is new loaded object on enter frame
		private function onDataLoading(e:Event):void
		{
			if (loadedQueue[q0] != undefined)
			{
				removeEventListener(Event.ENTER_FRAME, onDataLoading);
				// create new 3D object
				preloadThumbnail.content.text = "LOADING THUMBNAIL " + (++count) + "/ " + TOTAL;
				
				var ob = loadedQueue[q0];
				var idx:Number = indexTrack[ob];
				// create bitmap material
				var bm:BitmapData = new BitmapData(ob.width, ob.height, transparent, 0x000000);
				bm.draw(ob);
				var bMat:BitmapMaterial = new BitmapMaterial(bm, photoPrecise);
				bMat.smooth = photoSmooth;
				bMat.interactive = true;
				bMat.doubleSided = false;
				// create plane / 3d items
				var container:DisplayObject3D = new DisplayObject3D();
				var p:Plane = new Plane(bMat, ob.width, ob.height, configObject.quality, configObject.quality);
				container.x = dData[idx].x;
				//container.y = dData[idx].y;
				container.z = dData[idx].z;
				container.rotationY = dData[idx].rotationY;
				container.rotationX = dData[idx].rotationX;
				container.extra = new Object();
				container.extra.index = idx;
				container.extra.target = idx;
				container.extra.width = ob.width;
				container.extra.height = ob.height;
				
				// interactive adds on internal plane
				p.addEventListener( InteractiveScene3DEvent.OBJECT_RELEASE, onItemRelease, false, 0, true );
				p.addEventListener( InteractiveScene3DEvent.OBJECT_OVER, onItemOver, false, 0, true );
				p.addEventListener( InteractiveScene3DEvent.OBJECT_OUT, onItemOut, false, 0, true );			
				
				p.name = "plane";
				container.addChild(p);
				container.name = "item" + idx;
				scene.addChild(container);
				
				// pivot point
				if (pivot == "bottom")	p.y = ob.height * .5;
				else
				if (pivot == "top") p.y = -ob.height * .5;
				container.y = -p.y;
				
				// Create new reflection Bitmap Data 
				var bmp:BitmapData = new BitmapData( ob.width, ob.height, transparent, 0x000000);
				// Flip vertical
				var m:Matrix = new Matrix();
				m.createBox(1, -1, 0, 0, ob.height);
				bmp.draw( ob, m );
				
				// create reflexion plane
				var bm2:BitmapMaterial = new BitmapMaterial(refMaker.createReflection(ob));
				bm2.doubleSided = false;
				bm2.smooth = false;
				var refContainer:DisplayObject3D = new DisplayObject3D();
				var p2:Plane = new Plane(bm2, ob.width, ob.height);
				
				p2.name = "refPlane";
				refContainer.addChild(p2);
				refContainer.name = "ref" + idx;
				scene.addChild(refContainer);
				
				// pivot point
				p2.y = -p.y;
				
				refContainer.x = container.x;
				refContainer.z = container.z
				refContainer.y = -refDistance - container.y ;
				refContainer.rotationY = container.rotationY;
				refContainer.rotationX = -container.rotationX;
				container.extra.ref = refContainer;
				
				// remove loader object
				indexTrack[ob] = null;
				loadedQueue[q0] = null;
				ob = null;
				q0++;
				
				// force garbage collector
				try {
				   new LocalConnection().connect('foo');
				   new LocalConnection().connect('foo');
				} 
				catch (e:*) { }
				
				// total thumbnail load complete
				if (count == TOTAL)
				{
					yPos = container.y;
					// remove thumbnail preloader
					this.parent.removeChild(preloadThumbnail);
					// setup mousewheel, scroller
					stage.addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler, false, 0, true);
					dScroller.addEventListener(DynamicScrollerEvent.ONCHANGE, scrollerChange, false, 0, true);
					// fade in viewport
					TweenMax.to(viewport, 3, { alpha:1, overwrite:1 } );
					// start from center
					if (configObject.startFromCenter)
					{
						dScroller.value = .5;
						switchItem(Math.floor(TOTAL * .5));
					}
					else
					{
						this.parent["shortDes"].htmlText = data.items.item[0].shortDescription.text();
						// update short description
						TweenMax.to(this.parent["shortDes"], 0.75, { 	alpha:1,
																		startAt: { alpha:0 },
																		overwrite:1
						});
						renderer.renderScene(scene, camera, viewport);
					}
					// flipping enable - create back plane
					if (flippingEnable)
					{
						// array holds full object
						fullLoaded = [];
						backClip = this.parent["back"];
						with (backClip)
						{
							nextSym.visible = preSym.visible = infoSym.visible = closeSym.visible = false;
						}
						backMat = new MovieMaterial(backClip, false, false, true);
						backMat.smooth = true;
						backMat.doubleSided = false;
						backPlane =  new Plane(backMat, 220, 220);
						backPlane.z = 1;
						backPlane.rotationY = 180;
					}
					this.parent["disableLayer"].visible = false;
					this.parent["shortDes"].visible = true;
					// no scroller
					if (!useScroller)
					{
						stage.addEventListener(MouseEvent.MOUSE_DOWN, stageMouseDown, false, 0, true);
						stage.addEventListener(MouseEvent.MOUSE_UP, stageMouseUp, false, 0, true);
						this.parent["dScroller"].visible = false;
						//MouseControl.start();
					}
					else
					{
						this.parent["dScroller"].visible = true;
					}
					// slideshow
					if (isSlideShow) 
					{
						this.parent.addChild(this.parent["ssClip"]);
						this.parent["ssClip"].front.scaleX = 0;
						this.parent["ssClip"].visible = true;
						slideShow = new Timer(ssDelay * 1000, 0);
						slideShow.addEventListener(TimerEvent.TIMER, timerHandler, false, 0, true);
						slideShow.start();
						myTween = new TweenMax(this.parent["ssClip"].front, ssDelay, { scaleX:1, loop:0 } );
					}
					else
					{
						if (this.parent.contains(this.parent["ssClip"])) this.parent.removeChild(this.parent["ssClip"]);
					}
					// click for more
					this.parent.addChild(this.parent["cFM"]);
					if (configObject.useCategory) this.parent.addChild(this.parent["categoryMenu"]);
					this.parent["cFM"].visible = true;
					this.parent["cFM"].alpha = 0;
				}
				else
				addEventListener(Event.ENTER_FRAME, onDataLoading, false, 0, true);
			}
		}
		
		// item distribute data
		private function initDistributedData():void
		{
			dData = []; // distribute data
			var halfItemDisplay:Number = Math.floor(Number(data.config.@numItemDisplay) * .5);
			var angle:Number = Number(data.config.@angle);
			var distX0:Number = Number(data.config.@distX0);
			var distX1:Number = Number(data.config.@distX1);
			var distY0:Number = Number(data.config.@distY0);
			var distY1:Number = Number(data.config.@distY1);
			var distZ0:Number = Number(data.config.@distZ0);
			var distZ1:Number = Number(data.config.@distZ1);
			var distAngle:Number = Number(data.config.@distAngle);
		
			dData[0] = new Object();
			dData[0].rotationX = dData[0].rotationY = dData[0].x = dData[0].y = dData[0].z = 0;
			var temp;
			for (var i:Number = 1; i < TOTAL; i++)
			{
				// upper half
				dData[i] = new Object();
				dData[i].rotationY = angle;
				dData[i].x = (i - 1) * distX1 + distX0;
				dData[i].y = (i - 1) * distY1 + distY0;
				dData[i].z = (i - 1) * distZ1 + distZ0;
				
				// distAngle
				temp = i * distAngle; 
				if (temp > 90) temp = 90;
				dData[i].rotationX = temp;
				if (i > halfItemDisplay) dData[i].rotationX = 90;
				
				// lower half
				dData[-i] = new Object();
				dData[-i].rotationY = -angle;
				dData[-i].x = -dData[i].x;
				dData[-i].y = dData[i].y;
				dData[-i].z = dData[i].z;
				dData[-i].rotationX = dData[i].rotationX;
			}
		}
		
		// dispose / eliminate gallery
		public function disposeGallery():void
		{
			TweenMax.killAll();
			// remove listener
			removeEventListener(Event.ENTER_FRAME, rendering);
			stage.removeEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler);
			dScroller.removeEventListener(DynamicScrollerEvent.ONCHANGE, scrollerChange);
			// destroy plane / 3d display object
			if (flippingEnable)
			{
				backPlane.material.interactive = false; 
				backPlane.material.destroy();
				backPlane.material = null;
				if (backPlane.parent != null) backPlane.parent.removeChild(backPlane);
				backPlane = null;
			}
			this.parent["cFM"].visible = false;
			for (var i:Number = 0; i < TOTAL; i++)
			{
				// item
				var con:DisplayObject3D = scene.getChildByName("item" + i);
				var p = con.getChildByName("plane");
				p.material.interactive = false; 
				p.material.destroy();
				p.material = null;
				p.removeEventListener( InteractiveScene3DEvent.OBJECT_RELEASE, onItemRelease);
				p.removeEventListener( InteractiveScene3DEvent.OBJECT_OVER, onItemOver);
				p.removeEventListener( InteractiveScene3DEvent.OBJECT_OUT, onItemOut);
				con.removeChild(p);
				p = null;
				
				// reflection
				var refCon:DisplayObject3D = scene.getChildByName("ref" + i);
				var p1 = refCon.getChildByName("refPlane");
				p1.material.destroy();
				p1.material = null;
				refCon.removeChild(p1);
				scene.removeChildByName("ref" + i);
				p1 = null;
				refCon = null;
				
				//full
				if (con.getChildByName("full") != null)
				{
					var f = con.getChildByName("full");
					f.material.interactive = false; 
					f.material.destroy();
					f.material = null;
					//f.removeEventListener( InteractiveScene3DEvent.OBJECT_RELEASE, onItemRelease);
					f.removeEventListener( MouseEvent.MOUSE_OVER, fullItemOver);
					f.removeEventListener( MouseEvent.MOUSE_OUT, fullItemOut);
					con.removeChild(f);
					scene.removeChildByName("item" + i);
					con.extra.ref = null;
					f = null;
					con = null;
				}
			}
			
			// no scroller
			if (!useScroller)
			{
				stage.removeEventListener(MouseEvent.MOUSE_DOWN, stageMouseDown);
				stage.removeEventListener(MouseEvent.MOUSE_UP, stageMouseUp);
			}
				
			// force garbage collector
			try {
			
               new LocalConnection().connect('foo');
               new LocalConnection().connect('foo');
            } catch (e:*) { }
			
			if (isSlideShow)
			{
				slideShow.removeEventListener(TimerEvent.TIMER, timerHandler);
				slideShow.stop();
				myTween.pause();
			}
			sTimer.stop();
			sTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, stopRendering);
			sTimer = null;
		}
		
		//________________________________________ Gallery Interactivity
		
		public function onItemRelease(e:InteractiveScene3DEvent = null):void
		{
			trace("LOAD VIDEO")
			if (cID != e.target.parent.extra.index) 
			{
				dScroller.value = e.target.parent.extra.index / (TOTAL - 1);
				switchItem(e.target.parent.extra.index);			}
			else
			{
				if (flippingEnable)
				{
					stage.removeEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler);
					if (!useScroller) stage.removeEventListener(MouseEvent.MOUSE_DOWN, stageMouseDown);
					if (isSlideShow) 
					{
						slideShow.stop();
						this.parent["ssClip"].visible = false;
						myTween.pause();
					}
					flipItem(e.target as Plane);
				}
				// open link
				else
				navigateToURL(new URLRequest((data.items.item[cID].link.@src)), configObject.linkTarget);
			}
		}
		
		private function onItemOver(e:InteractiveScene3DEvent):void
		{
			if (cID == e.target.parent.extra.index)
				TweenMax.to(this.parent["cFM"], 0.5, { alpha:1 } );
		}
		
		private function onItemOut(e:InteractiveScene3DEvent):void
		{
			if (cID == e.target.parent.extra.index)
				TweenMax.to(this.parent["cFM"], 0.5, { alpha:0 } );
		}
		
		private function switchItem(idx:Number):void
		{
			//trace("switch item", idx);
			cID = idx;
			var container = scene.getChildByName("item" + idx) as DisplayObject3D;
			
			renderManager(configObject.switchDuration + 0.25);
			// Tween to center
			var delta:Number = -container.extra.target;
			for (var i:Number = 0; i < TOTAL; i++)
			{
				var con2 = scene.getChildByName("item" + i) as DisplayObject3D;
				var target:Number = con2.extra.target + delta;
				con2.extra.target = target;
				
				TweenMax.to(con2, configObject.switchDuration, 
									{ 	x:dData[target].x,
										z:dData[target].z,
										rotationY:dData[target].rotationY,
										rotationX:dData[target].rotationX,
										ease:Quint.easeOut,
										overwrite:1,
										onUpdateParams:[con2],
										onUpdate:function(con2:DisplayObject3D):void
										{
											con2.extra.ref.x = con2.x;
											con2.extra.ref.z = con2.z;
											con2.extra.ref.rotationX = -con2.rotationX;
											con2.extra.ref.rotationY = con2.rotationY;
										}
				});
			}
			this.parent["shortDes"].htmlText = data.items.item[cID].shortDescription.text();
			// update short description
			TweenMax.to(this.parent["shortDes"], 0.75, { 	alpha:1,
															startAt: { alpha:0 },
															overwrite:1
			});
		}
		
		// flip to open full version
		private function flipItem(target:Plane):void
		{
			var container = target.parent;
			// add back material to center object
			if (backPlane.parent != null ) backPlane.parent.removeChild(backPlane);
			container.addChild(backPlane);
			with (backClip)
			{
				infoSym.visible = closeSym.visible = nextSym.visible = preSym.visible = false;
				backClip.background.rotation = 0;
			}
			backMat.drawBitmap();
			renderManager(configObject.flipDuration + 0.25);
			// hide scroller / category menu
			this.parent["categoryMenu"].visible = dScroller.visible = false;
			// hide short description
			this.parent["shortDes"].visible = false;
			// flip all objects
			var pl;
			for (var i:Number = 0; i < TOTAL; i++)
			{
				pl = scene.getChildByName("item" + i);
				TweenMax.to(pl, configObject.flipDuration, 
									{	bezierThrough:[ { rotationX:-40, y:yPos + 30 },
											{ rotationX:0, rotationY:180, y:0 },
											  ], 
									ease:Quint.easeOut,
									onUpdateParams:[pl],
									onUpdate:function(pl:DisplayObject3D):void
									{
										pl.extra.ref.y = -refDistance - pl.y;
										pl.extra.ref.rotationX = -pl.rotationX;
										pl.extra.ref.rotationY = pl.rotationY;
									}
							});
			}
			// load full version or open a loaded one
			TweenMax.to(this, 0, { 	delay:configObject.flipDuration * .5, 
									onComplete:loadFullVersion
			});
			//MouseControl.start();
			this.parent["cFM"].visible = false;
		}
		
		// load full version of item
		private function loadFullVersion():void
		{
			thisThingIsLoaded = true;
			this.parent.addChild(preloadThumbnail);
			preloadThumbnail.content.text = "LOADING ...";
			preloadThumbnail.x = stage.stageWidth * .5;
			preloadThumbnail.y = stage.stageHeight * .5 - 145;
			backClip.preloader.reset();
			backMat.drawBitmap();
			var loader:Loader = new Loader();
			loader.load(new URLRequest(data.items.item[cID].full.@src));
			loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onProgress);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
			
		}
		
		// on load progress - update preloader
		private function onProgress(e:ProgressEvent):void
		{
			backClip.preloader.value = (e.bytesLoaded / e.bytesTotal) * 100;
			// update movie material
			backMat.drawBitmap();
		}
		
		// load complete, add full object to stage
		private function onComplete(e:Event):void
		{
			fullLoaded[cID] = true;
			// center item
			var cob = scene.getChildByName("item" + cID);
			// loaded object
			var ob = e.target.loader;
			// hide original thumb
			var p0 = cob.getChildByName("plane");
			p0.visible = false;
			if (type == "swf")
			{
				w = Number(data.items.item[cID].dimension.@width);
				h = Number(data.items.item[cID].dimension.@height);
				if (swfLoader != null)
				{
					if (this.parent.contains(swfLoader)) this.parent.removeChild(swfLoader);
					swfLoader = null;
				}
				swfLoader = ob;
				this.parent.addChild(swfLoader);
				swfLoader.visible = false;
				swfLoader.alpha = 0;
				swfLoader.x = (stage.stageWidth - w) * .5;
				swfLoader.y = (stage.stageHeight - h) * .5;
			}
			else
			{
				w = ob.width;
				h = ob.height;
			}
			// create plane to hold ob
			var bm:BitmapData = new BitmapData(w, h, transparent, 0x000000);
			bm.draw(ob);
			var bMat:BitmapMaterial = new BitmapMaterial(bm, true);
			bMat.smooth = photoSmooth;
			bMat.interactive = true;
			bMat.doubleSided = false; 
			var p:Plane = new Plane(bMat, w, h, 1, 1);
			p.useOwnContainer = true;
			p.addEventListener( MouseEvent.MOUSE_OVER, fullItemOver, false, 0, true );
			p.addEventListener( MouseEvent.MOUSE_OUT, fullItemOut, false, 0, true );
			// add to center container
			cob.addChild(p, "full");
			// remove preloader
			this.parent.removeChild(this.parent["preloadThumbnail"]);
			doFlipping();
		}
		
		// flip item to back 
		private function doFlipping():void
		{
			var container:DisplayObject3D = scene.getChildByName("item" + cID);
			var p = container.getChildByName("plane");
			var f = container.getChildByName("full");
			p.visible = false;
			f.visible = true;
			renderManager(1.25);
			TweenMax.to(container, 1, { rotationX:0, rotationY:0, x:0, y:0,
										ease:Quint.easeOut, 
										onComplete:function():void
										{
											backClip.preloader.reset();
											backMat.drawBitmap();
											//control.visible = true;
											//TweenMax.to(control, 0.75, { alpha:1, ease:Quint.easeOut } );
											//TweenMax.to(control, 0.75,{	alpha:0, delay:1, ease:Quint.easeOut});
											openInsPane();
											openTypeFunction();
										},
										overwrite:1
										} );
			// add controllermouseenabled
			control = this.parent["control"];
			this.parent.addChild(control);
			control.x = Math.round(stage.stageWidth * .5) + 30 * Number(!control.infoBut.visible);
			control.y = Math.round(stage.stageHeight * .5) + configObject.controlDistanceFromCenter;
			control.visible = false;
			control.alpha = 0;
			isClosed = false;
			stageDown = false;
			// start advanced interactive
			control.addEventListener(MouseEvent.MOUSE_OVER, controlOver, false, 0, true);
			control.addEventListener(MouseEvent.MOUSE_OUT, controlOut, false, 0, true);
			control.infoBut.addEventListener(MouseEvent.CLICK, infoPress, false, 0, true);
			control.closeBut.addEventListener(MouseEvent.CLICK, closePress, false, 0, true);
			control.nextBut.addEventListener(MouseEvent.CLICK, nextPress, false, 0, true);
			control.preBut.addEventListener(MouseEvent.CLICK, prePress, false, 0, true);
			// long description
			var d = this.parent["dTScroller"];
			d.applyText(data.items.item[cID].longDescription.text());
			d.visible = false;
			// center position
			d.x = Math.round((stage.stageWidth - configObject.descriptionWidth) * .5);
			d.y = Math.round((stage.stageHeight - configObject.descriptionHeight) * .5);
			// add close button interactive
			d.closeBut.addEventListener(MouseEvent.CLICK, closeInfo);
		}
		
		private function openInsPane():void
		{
			//insPane
			var insPane = this.parent["insPane"];
			if (insPane.visibleStatus)
			{
				this.parent.addChild(this.parent["disableLayer"]);
				this.parent.addChild(this.parent["fullBut"]);
				TweenMax.to(this.parent["disableLayer"], 0.25, { autoAlpha:0.8 } );
				this.parent.addChild(insPane);
				TweenMax.to(insPane, 0.25, { autoAlpha:1 } );
			}
			else
			stage.addEventListener(MouseEvent.MOUSE_DOWN, startInteractive, false, 0, true);
		}
		
		private function controlOver(e:MouseEvent):void
		{
			cOver = true;
		}
		
		private function controlOut(e:MouseEvent):void
		{
			cOver = false;
		}
		
		// advanced interactive
		public function startInteractive(e:MouseEvent = null):void
		{
			trace("*************startInteractive***************")
			/*stageDown = true;
			if (!cOver && !pOver && !this.parent["insPane"].isOver)
			{
				control.visible = false;
				pausePlayer();
				renderManager(1);
				TweenMax.to(scene.getChildByName("item" + cID), 0.75, { z:100, ease:Quint.easeOut } );
				OX = stage.mouseX;
				OY = stage.mouseY;
				isMouseUp = false;
				stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMove, false, 0, true);
				stage.addEventListener(MouseEvent.MOUSE_UP, mouseUp, false, 0, true);
			}*/
			//else
			//stage.addEventListener(MouseEvent.MOUSE_UP, mouseUp2, false, 0, true);
		}
		
		private function mouseUp2(e:MouseEvent):void
		{
			stageDown = false;
		}
		
		public function keyMove(dir:int):void
		{
			if (!thisThingIsLoaded){
				cID += dir;		
				
				if (cID < 0) { cID = 0; }
				if (cID > TOTAL - 1) { cID = TOTAL -1;}
				
				switchItem(cID);
				slideShow.reset();
				slideShow.start();
				this.parent["ssClip"].visible = true;
				myTween.restart();
			}
			
		}
		/*public function keyClose(){
			closePress();
			}*/
		public function keyLoad():void
		{
			//trace("CURRENT ITEM = "+cID);
			if (thisThingIsLoaded){
				closePress();
				slideShow.reset();
				slideShow.start();
				this.parent["ssClip"].visible = true;
				myTween.restart();				
			}else{
				loadFullVersion();
				slideShow.stop();
				this.parent["ssClip"].visible = false;			
			}
			//sTimer.stop();
			//sTimer.reset();
		}
		
		// rotate 3d item based on mouse position
		private function mouseMove(e:MouseEvent):void
		{			
			var dX = (stage.mouseX - OX) / configObject.mouseSensitive;
			var dY = (stage.mouseY - OY) / configObject.mouseSensitive;
			trace(dX);
			if (dX > 1) dX = 1; else
			if (dX < -1) dX = -1;
			if (dY > 1) dY = 1; else
			if (dY < -1) dY = -1;
			
			mc.visible = false;
			renderManager(0.75);
			if (Math.abs(dX) > Math.abs(dY))
			{
				if (dX > 0) 
				{	backClip.nextSym.visible = true;
					mc = backClip.nextSym;
				} 
				else
				if (dX < 0) 
				{
					backClip.preSym.visible = true;
					mc = backClip.preSym;
				}
				backClip.background.rotation = 0;
				backMat.drawBitmap();
				TweenMax.to(scene.getChildByName("item" + cID), 0.5, { 	rotationY:180 * dX, rotationX:0,  ease:Quint.easeOut, onComplete:checkAngle } );
			}
			else
			{
				if (dY < 0) 
				{	backClip.closeSym.visible = true;
					mc = backClip.closeSym;
				} 
				else
				if (dY > 0) 
				{
					if (!configObject.useLongDescription) return;
					backClip.infoSym.visible = true;
					mc = backClip.infoSym;
				}
				backClip.background.rotation = 180;
				backMat.drawBitmap();
				TweenMax.to(scene.getChildByName("item" + cID), 0.5, { 	rotationX:180 * dY, rotationY:0, ease:Quint.easeOut, onComplete:checkAngle  } );
			}
		}
		
		private function mouseUp(e:MouseEvent):void
		{
			stageDown = false;
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUp);
			renderManager(1);
			TweenMax.to(scene.getChildByName("item" + cID), 0.75, { z:0, ease:Quint.easeOut, overwrite:1 } );
			isMouseUp = true;
			//control.visible = true;
			checkAngle();

			
		}
		
		private function checkAngle():void
		{
			if (isMouseUp)
			{
				var c = scene.getChildByName("item" + cID);
				if (c.rotationX > 90) 
				{
					// info
					TweenMax.to(c, 0.25, { 	z:0, rotationX:180, 
											rotationY:0, ease:Quint.easeOut,
											overwrite:1
											} );
					control.visible = false;
					pausePlayer();
					callInfo();
				}
				else
				if (c.rotationX < -90) 
				{
					// close
					TweenMax.to(c, 0.25, { 	z:0, rotationX:-180, 
											rotationY:0, ease:Quint.easeOut } );
					control.visible = false;
					closeTypeFunction();
					callClose();
				}
				else
				if (c.rotationY > 90) 
				{
					// next
					TweenMax.to(c, 0.25, { 	z:0, rotationX:0, 
											rotationY:180, ease:Quint.easeOut
											} );
					control.visible = false;
					TweenMax.to(this, 0, { delay:0.25, onComplete:callLoadItem, onCompleteParams:["right", (cID == TOTAL - 1) ? 0 : (cID + 1)] } );
				}
				else
				if (c.rotationY < -90) 
				{
					// previous
					TweenMax.to(c, 0.25, { 	z:0, rotationX:0, 
											rotationY: -180, ease:Quint.easeOut
											} );
					control.visible = false;
					TweenMax.to(this, 0, { delay:0.25, onComplete:callLoadItem, onCompleteParams:["left", (cID == 0) ? TOTAL - 1 : (cID - 1)] } );
				}
				else
				{
					// no change
					TweenMax.to(c, 0.25, { 	z:0, rotationX:0, 
											rotationY:0, ease:Quint.easeOut
											} );
					//control.visible = false;
					resumePlayer();
				}
			}
		}
		
		private function fullItemOver(e:InteractiveScene3DEvent):void
		{
			//if (!stageDown && !isClosed)
			TweenMax.to(control, 0.5, { alpha:1, ease:Quint.easeOut, overwrite:1 } );
		}
		
		private function fullItemOut(e:InteractiveScene3DEvent):void
		{
			TweenMax.to(control, 0.5, { alpha:0, ease:Quint.easeOut, overwrite:1} );
		}
		
		//________________________________________________________ 	Item info
		
		private function infoPress(e:MouseEvent):void
		{
			pausePlayer();
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, startInteractive);
			addChild(this.parent["disableLayer"]);
			this.parent["disableLayer"].visible = true;
			// info
			mc.visible = false;
			backClip.infoSym.visible = true;
			mc = backClip.infoSym;
			backClip.background.rotation = 180;
			backMat.drawBitmap();
			renderManager(1);
			TweenMax.to(scene.getChildByName("item" + cID), 
								0.75, { 	z:0, rotationX:180, 
									rotationY:0, ease:Quint.easeOut,
									overwrite:1
									} );
			control.visible = false;
			TweenMax.to(this, 0, { delay:0.5, onComplete:callInfo } );
		}
		
		private function callInfo():void
		{
			control.visible = false;
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, startInteractive);
			var s:MovieClip = this.parent["sCover"];
			this.parent.addChild(s);
			s.x = stage.stageWidth * .5;
			s.y = stage.stageHeight * .5;
			s.visible = true;
			TweenMax.to(s, 0.75, { 	width:configObject.descriptionWidth, 
									height:configObject.descriptionHeight,
									alpha:1, ease:Quint.easeOut
								});
								
			// apply textfield
			var d = this.parent["dTScroller"];
			this.parent.addChild(d);
			// fade in
			d.visible = true;
			TweenMax.to(d, 2, { alpha:1, ease:Quint.easeOut, startAt:{alpha:0} } );
		}
		
		// close info turn back to full item
		private function closeInfo(e:MouseEvent):void
		{
			resumePlayer();
			// hide background
			var s:MovieClip = this.parent["sCover"];
			TweenMax.to(s, 0.75, { 	width:220, 
									height:220,
									autoAlpha:0, ease:Quint.easeOut
								});
								
			// hide description
			var d = this.parent["dTScroller"];
			TweenMax.to(d, 0.75, { 	autoAlpha:0, 
									ease:Quint.easeOut 
								} );
			// flip 3d item backs
			renderManager(1);
			TweenMax.to(scene.getChildByName("item" + cID), 0.75, 
								{ 	z:0, rotationX:0, 
									rotationY:0, ease:Quint.easeOut,
									overwrite:1,
									onComplete:function():void
									{
										stage.addEventListener(MouseEvent.MOUSE_DOWN, startInteractive);
									}
								} );
			//control.visible = true;
			this.parent["disableLayer"].visible = false;
		}
		
		//________________________________________________________ 	Item close
		
		private function closePress(e:* = null):void
		{
			closeTypeFunction();
			//NN Add
			thisThingIsLoaded = false;
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, startInteractive);
			addChild(this.parent["disableLayer"]);
			this.parent["disableLayer"].visible = true;
			// info
			mc.visible = false;
			backClip.closeSym.visible = true;
			mc = backClip.closeSym;
			backClip.background.rotation = 180;
			backMat.drawBitmap();
			renderManager(1);
			//TweenMax.to(scene.getChildByName("item" + cID),0.75, { 	z:0, rotationX:-180, rotationY:0, ease:Quint.easeOut,overwrite:1} );
			//TweenMax.to(this, 0, { delay:0.25, onComplete:callClose } );
			callClose();
			control.visible = false;
		}
		
		private function callClose():void
		{
			isClosed = true;
			control.visible = false;
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, startInteractive);
			// remove back material to center object
			var cob = scene.getChildByName("item" + cID);
			// show scroller / category menu / short description
			this.parent["categoryMenu"].visible = true;
			if (useScroller) dScroller.visible = true;
			dScroller.value = cID / (TOTAL - 1);
			// update short description with new cID
			this.parent["shortDes"].visible = true;
			this.parent["shortDes"].htmlText = data.items.item[cID].shortDescription.text();
			// show front thumb
			var p0 = cob.getChildByName("plane");
			p0.visible = true;
			var p1 = cob.getChildByName("full");
			p1.visible = false;
			// flip all item to front
			var pl;
			renderManager(1);
			for (var i:Number = 0; i < TOTAL; i++)
			{
				if (i != cID)
				{
					pl = scene.getChildByName("item" + i);
					TweenMax.to(pl, 0.75, 
										{	delay:0.25,
											x:dData[pl.extra.target].x,
											y:yPos, 
											z:dData[pl.extra.target].z,
											rotationY:dData[pl.extra.target].rotationY,
											rotationX:dData[pl.extra.target].rotationX,
											ease:Quint.easeOut,
											onUpdateParams:[pl],
											onUpdate:function(pl:DisplayObject3D):void
											{
												pl.extra.ref.y = -refDistance - pl.y;
												pl.extra.ref.rotationX = -pl.rotationX;
												pl.extra.ref.rotationY = pl.rotationY;
											}
										});
				}
			}
			
			TweenMax.to(cob, 0.75, 
										{	delay:0.25,
											rotationY:0,
											rotationX:0,
											x:0,
											y:yPos,
											ease:Quint.easeOut,
											onUpdateParams:[cob],
											onUpdate:function(cob:DisplayObject3D):void
											{
												cob.extra.ref.y = -refDistance - cob.y;
												cob.extra.ref.rotationX = -cob.rotationX;
												cob.extra.ref.rotationY = cob.rotationY;
											},
											onComplete:function():void
											{
												stage.addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler);
											}
										});
			TweenMax.to(this, 0, { delay:0.75, onComplete:function():void { stage.addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler); }} );
			this.parent["disableLayer"].visible = false;
			if (!useScroller) 
			{
				stage.addEventListener(MouseEvent.MOUSE_DOWN, stageMouseDown, false, 0, true);
			}
			//else
			//MouseControl.stop();
			
			if (isSlideShow) 
			{
				slideShow.reset();
				slideShow.start();
				this.parent["ssClip"].visible = true;
				myTween.restart();
			}
			this.parent["cFM"].visible = true;
		}
		
		//________________________________________________________ 	Open Item
		
		public function nextPress(e:MouseEvent = null):void
		{
			// disable interactive
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, startInteractive);
			addChild(this.parent["disableLayer"]);
			this.parent["disableLayer"].visible = true;
			// next
			mc.visible = false;
			backClip.nextSym.visible = true;
			mc = backClip.nextSym;
			backClip.background.rotation = 0;
			backMat.drawBitmap();
			renderManager(1);
			TweenMax.to(scene.getChildByName("item" + cID), 
								0.75, { 	z:0, rotationY:180, 
									rotationX:0, ease:Quint.easeOut,
									overwrite:1
									} );
			control.visible = false;
			var idx = (cID == TOTAL - 1) ? 0 : (cID + 1);
			TweenMax.to(this, 0, { delay:0.5, onComplete:callLoadItem, onCompleteParams:["right", idx] } );
			pausePlayer();
		}
		
		public function prePress(e:MouseEvent = null):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, startInteractive);
			addChild(this.parent["disableLayer"]);
			this.parent["disableLayer"].visible = true;
			// pre
			mc.visible = false;
			backClip.preSym.visible = true;
			mc = backClip.preSym;
			backClip.background.rotation = 0;
			backMat.drawBitmap();
			renderManager(1);
			TweenMax.to(scene.getChildByName("item" + cID), 
								0.75, { 	z:0, rotationY:-180, 
									rotationX:0, ease:Quint.easeOut,
									overwrite:1
									} );
			control.visible = false;
			var idx = (cID == 0) ? TOTAL - 1 : (cID - 1);
			TweenMax.to(this, 0, { delay:0.5, onComplete:callLoadItem, onCompleteParams:["left", idx] } );
			pausePlayer();
		}
		
		private function callLoadItem(direction:String, idx:Number):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, startInteractive);
			var cob = scene.getChildByName("item" + cID);
			// remove black material, hide full version
			var p0 = cob.getChildByName("plane");
			p0.visible = true;
			var p1 = cob.getChildByName("full");
			p1.visible = false;
			cob.removeChild(backPlane);
			cID = idx;
			var pl;
			cob = scene.getChildByName("item" + cID);
			var t = cob.extra.target;
			for (var i:Number = 0; i < TOTAL; i++)
			{
				pl = scene.getChildByName("item" + i);
				pl.extra.target -= t;
				pl.x = dData[pl.extra.target].x,
				pl.y = dData[pl.extra.target].y, 
				pl.z = dData[pl.extra.target].z,
				pl.rotationY = 180,
				pl.rotationX = 0,
				pl.extra.ref.x = pl.x;
				pl.extra.ref.z = pl.z;
				pl.extra.ref.rotationX = -pl.rotationX;
				pl.extra.ref.rotationY = pl.rotationY;
			}
			if (direction == "left") 
			{
				cob.rotationY = -180;
				cob.extra.ref.rotationY = pl.rotationY;
			}
			cob.addChild(backPlane);
			with (backClip)
			{
				infoSym.visible = closeSym.visible = nextSym.visible = preSym.visible = false;
				backClip.background.rotation = 0;
			}
			backMat.drawBitmap();
			loadFullVersion();
			this.parent["disableLayer"].visible = false;
			
		}
		
		// scroll base on mouse position
		private function stageMouseDown(e:MouseEvent):void
		{
			//XO = stage.mouseX;
			//YO = cID;
			//stage.addEventListener(MouseEvent.MOUSE_MOVE, startDragging, false, 0, true);
		}
		
		private function stageMouseUp(e:MouseEvent):void
		{
			//stage.removeEventListener(MouseEvent.MOUSE_MOVE, startDragging);
		}
		
		//private function startDragging(e:MouseEvent):void
		//{
			//var temp =YO + Math.round((stage.mouseX - XO) * .05);
			//temp = (temp < 0) ? 0 : temp;
			//temp = (temp >= TOTAL) ? TOTAL - 1 : temp;
			//switchItem(temp);
		//}
		
		// scroll mouswheel to switch item
		private function mouseWheelHandler(e:MouseEvent):void
		{
			TweenMax.to(this.parent["cFM"], 0.25, { alpha:0, overwrite:1 } );
			var value = e.delta / 3;
			if (cID + value >= 0 && cID + value < TOTAL) cID += value;
			dScroller.value = cID / (TOTAL - 1);
			switchItem(cID);
		}
		
		private function scrollerChange(e:DynamicScrollerEvent):void
		{
			cID = Math.round(dScroller.value * (TOTAL - 1));
			switchItem(cID);
		}
		
		
		// 3d render
		private function rendering(e:Event):void
		{
			renderer.renderScene(scene, camera, viewport);
		}
				
		private function startRendering():void
		{
			addEventListener(Event.ENTER_FRAME, rendering, false, 0, true);
		}
		
		private function stopRendering(e:TimerEvent):void
		{
			removeEventListener(Event.ENTER_FRAME, rendering);
		}
		
		private function renderManager(duration:Number):void
		{
			sTimer.stop();
			sTimer.reset();
			sTimer.delay = duration * 1000;
			startRendering();
			sTimer.start();
		}
		
		// Slide show timer
		private function timerHandler(e:TimerEvent):void
		{
			var temp = cID;
			temp = (temp == TOTAL - 1) ? 0 : ++temp;
			dScroller.value = temp / (TOTAL - 1);
			myTween.restart();
			switchItem(temp);
		}
		
		private function openTypeFunction():void
		{
			switch (type)
			{
				case "mp3":	TweenMax.to(mp3Player, 0.5, { autoAlpha:1 } );
							mp3Player.source = String(data.items.item[cID].mp3.@src);
							mp3Player.length = Number(data.items.item[cID].length.@value);
							mp3Player.playMP3();
							break;
				case "video":
							TweenMax.to(videoPlayer, 0.5, { autoAlpha:1 } );
							videoPlayer.source = String(data.items.item[cID].video.@src);
							videoPlayer.playVideo();
							break;
				case "swf":
							TweenMax.to(swfLoader, 0.5, { autoAlpha:1 } );
							TweenMax.to(viewport, 0.5, { autoAlpha:0 } );
							break;
			}
			
		}
		
		private function closeTypeFunction():void
		{
			switch (type)
			{
				case "mp3":	mp3Player.stopMP3(null);
							TweenMax.to(mp3Player, 0.5, { autoAlpha:0 } );
							break;
				case "video":
							videoPlayer.stopVideo();
							TweenMax.to(videoPlayer, 0.5, { autoAlpha:0 } );
							break;
				case "swf":
							TweenMax.to(viewport, 0.5, { autoAlpha:1 } );
							this.parent.removeChild(swfLoader);
							swfLoader = null;
							break;
			}
		}
		
		private function resumePlayer():void
		{
			switch (type)
			{
				case "mp3":	mp3Player.playMP3(null);
							TweenMax.to(mp3Player, 0.5, { autoAlpha:1 } );
							break;
				case "video":	
							videoPlayer.playVideo(null);
							TweenMax.to(videoPlayer, 0.5, { autoAlpha:1 } );
							break;
				case "swf":
							TweenMax.to(swfLoader, 0.5, { autoAlpha:1 } );
							TweenMax.to(viewport, 0.5, { autoAlpha:0 } );
							break;
			}
		}
		
		private function pausePlayer():void
		{
			switch (type)
			{
				case "mp3":	mp3Player.pauseMP3(null);
							TweenMax.to(mp3Player, 0.5, { autoAlpha:0 } );
							break;
				case "video":	
							videoPlayer.pauseVideo(null);
							TweenMax.to(videoPlayer, 0.5, { autoAlpha:0 } );
							break;
				case "swf":
							TweenMax.to(swfLoader, 0.5, { autoAlpha:0 } );
							TweenMax.to(viewport, 0.5, { autoAlpha:1 } );
							break;
			}
		}
		
		// roll over player 
		private function playerOver(e:MouseEvent):void
		{
			pOver = true;
		}
		
		private function playerOut(e:MouseEvent):void
		{
			pOver = false;
		}
		

		
	}

	
}