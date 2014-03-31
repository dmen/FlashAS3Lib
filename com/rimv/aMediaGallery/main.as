/**
	 * IGALLERYX: ADVANCED MEDIA GALLERY
	 * @author RimV | www.mymedia-art.com 
	 * For any inquiry please contact me via my flashden profile page: www.flashden.net/user/RimV
	 * Please do not send a direct message to my email address if you haven't contacted me via the link above. This is to ensure that you did purchase the file
*/

package com.rimv.aMediaGallery 
{
	
	// flash api
	import flash.events.*;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.display.*;
	import flash.text.*;
	import flash.net.*;
	import flash.ui.Mouse;
	import flash.system.fscommand;
	
	// pv3d import
	import org.papervision3d.cameras.*;
	import org.papervision3d.scenes.Scene3D;
    import org.papervision3d.render.BasicRenderEngine;
	import org.papervision3d.view.Viewport3D;
	import org.papervision3d.objects.DisplayObject3D;
	
    // TweenMax
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	
	// extra
	import com.rimv.aMediaGallery.*;
	import com.rimv.utils.*;
	import com.hydrotik.queueloader.QueueLoader;
	import com.hydrotik.queueloader.QueueLoaderEvent;
	
	public class main extends MovieClip
	{
		private var myGallery:aMediaGallery;
			
		// pv3d parameters
		private var scene:Scene3D;
		private var viewport:Viewport3D;
		private var renderer:BasicRenderEngine;
		private var camera:Camera3D;
		
		// misc vars
		private var mainXMLPath:String = "xml/aMediaGallery.xml";
		private var mainXMLData:XML;
		private var cssPath:String = "css/styles.css" // CSS path
		private var configObject:Object = new Object();
		private var categoryXML = [];
		private var cID:Number;
		private var comboDistance:Number;
		private var shortDesDistance:Number;
		private var ssClipDistance:Number;
		private var controlDistance:Number;
		private var cFMDistance:Number;
		private var menuOverCheck:Boolean = false;
		private var css:StyleSheet = new StyleSheet(); // StyleSheet
		private var mouseHolder:MovieClip;
		private var isClick:Boolean = false;
		private var swfLoader:Loader;
		public var insPane:MovieClip;
		
		// image loader
		private var imgLoader:QueueLoader;
		
		//_________________________________ main contructor
		
		public function main() 
		{
			addEventListener(Event.ADDED_TO_STAGE, addedToStage, false, 0, true);
		}
		
		private function addedToStage(e:Event):void
		{
			// Align , scale Stage to full fill screen
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			fscommand("fullscreen","true");
			Mouse.hide();
			// initialize 3D parameters
			scene = new Scene3D();
			renderer = new BasicRenderEngine();
			camera = new Camera3D(60);
			camera.target = DisplayObject3D.ZERO;
			camera.z = -(camera.zoom * camera.focus);
			
			// misc setup
			removeChild(display);
			removeChild(categoryMenu);
			removeChild(preloadThumbnail);
			removeChild(dScroller);
			removeChild(dTScroller);
			removeChild(ssClip);
			removeChild(shortDes);
			removeChild(fullBut);
			removeChild(mp3Player);
			removeChild(videoPlayer);
			cFM.visible = false;
			
			// load main XML
			var xmlLoader:XMLLoader = new XMLLoader();
			xmlLoader.load(mainXMLPath);
			xmlLoader.addEventListener(XMLLoaderEvent.LOADED, xmlLoaded);
			
			// load description area stylesheet	
			initStyleSheet();
			// stage resize - reposition
			stage.addEventListener(Event.RESIZE, stageResize);
			stage.addEventListener(KeyboardEvent.KEY_UP, keyControl, false, 0, true);	
		}
		
		private function keyControl(e:KeyboardEvent):void
		{
			var kc:int = e.keyCode;
			
			if (kc == 97 || kc == 65 || kc == 49){
				myGallery.keyMove(-1);
			}
			if (kc == 98  || kc == 66 || kc == 50){
				myGallery.keyMove(1);
			}	
			//if (kc == 51){
				//myGallery.keyClose();
			//}				
			if (kc == 32 || kc == 67){
				//trace("SPACE BAR")
				myGallery.keyLoad();
			}
		}		
		
		// load aMediaGallery.xml
		private function xmlLoaded(e:XMLLoaderEvent):void
		{
			// retrieve xml data
			mainXMLData = e.xmlObjectData;
			
			// read general config
			configObject.backgroundColor = Number(mainXMLData.generalConfig.@backgroundColor);
			configObject.backgroundColor1 = Number(mainXMLData.generalConfig.@backgroundColor1);
			configObject.backgroundColor2 = Number(mainXMLData.generalConfig.@backgroundColor2);
			configObject.customBackground = String(mainXMLData.generalConfig.@customBackground);
			configObject.smoothing = Boolean(mainXMLData.generalConfig.@smoothing == "true");
			configObject.quality = Number(mainXMLData.generalConfig.@quality);
			configObject.switchEasing = mainXMLData.generalConfig.@switchEasing;
			configObject.switchDuration = Number(mainXMLData.generalConfig.@switchDuration);
			configObject.flipEasing = mainXMLData.generalConfig.@flipEasing;
			configObject.flipDuration = Number(mainXMLData.generalConfig.@flipDuration);
			configObject.fullScreenEnable = Boolean(mainXMLData.generalConfig.@fullScreenEnable == "true");
			configObject.randomDistribution = Boolean(mainXMLData.generalConfig.@randomDistribution == "true");
			configObject.mouseScrollingSpeed = Number(mainXMLData.generalConfig.@mouseScrollingSpeed);
			configObject.mouseSensitive = Number(mainXMLData.generalConfig.@mouseSensitive);
			configObject.startFromCenter = Boolean(mainXMLData.generalConfig.@startFromCenter == "true");
			configObject.descriptionWidth = Number(mainXMLData.generalConfig.@descriptionWidth);
			configObject.descriptionHeight = Number(mainXMLData.generalConfig.@descriptionHeight);
			configObject.linkTarget = String(mainXMLData.generalConfig.@linkTarget);
			configObject.useCategory = Boolean(mainXMLData.generalConfig.@useCategory == "true");
			configObject.useInstructionPane = Boolean(mainXMLData.generalConfig.@useInstructionPane == "true");
			configObject.useLongDescription = Boolean(mainXMLData.generalConfig.@useLongDescription == "true");
			configObject.controlDistanceFromCenter = Number(mainXMLData.generalConfig.@controlDistanceFromCenter);
			comboDistance = Number(mainXMLData.generalConfig.@comboxMenuDistanceFromCenter);
			shortDesDistance = Number(mainXMLData.generalConfig.@shortDescriptionDistanceFromCenter);
			ssClipDistance = Number(mainXMLData.generalConfig.@slideShowDistanceFromCenter);
			cFMDistance = Number(mainXMLData.generalConfig.@cFMDistanceFromCenter);
			
			// add, resize, center viewport
			viewport = new Viewport3D(Number(mainXMLData.generalConfig.@viewWidth), Number(mainXMLData.generalConfig.@viewHeight), false, true);
			viewport.buttonMode = true;
			viewport.alpha = 0;
			viewport.x = (stage.stageWidth - viewport.viewportWidth) * .5;
			viewport.y = (stage.stageHeight - viewport.viewportHeight) * .5;
			
			// background cover
			bgCover0.x = bgCover0.y = 0;
			bgCover0.width = stage.stageWidth;
			bgCover0.height = stage.stageHeight;
			bgCover0.x = bgCover0.y = 0;
			bgCover1.width = stage.stageWidth;
			bgCover1.height = viewport.viewportHeight + 50;
			bgCover1.x = 0;
			bgCover1.y = (stage.stageHeight - bgCover1.height) * .5;
			addChild(bgCover1);
			bgCover2.bg.width = stage.stageWidth;
			bgCover2.bg.height = viewport.viewportHeight;
			bgCover2.x = 0;
			bgCover2.y = (stage.stageHeight - bgCover2.height) * .5;
			addChild(bgCover2);
			addChild(viewport);
			// or custom background
			if (configObject.customBackground != "")
			{
				// load custom background
				imgLoader = new QueueLoader();
				imgLoader.addItem(configObject.customBackground, bgCover2);
				imgLoader.addEventListener(QueueLoaderEvent.ITEM_COMPLETE, imgLoaded);
				imgLoader.execute();
			}
			
			//instruction pane
			if (configObject.useLongDescription) 
			{
				insPane = insPane0;
				removeChild(insPane1);
			}
			else
			{
				insPane = insPane1;
				removeChild(insPane0);
			}
			
			addChild(insPane);
			insPane.x = Math.round(stage.stageWidth * .5);
			insPane.y = Math.round(stage.stageHeight * .5);
			insPane.visible = false;
			insPane.visibleStatus = configObject.useInstructionPane;
			insPane.isOver = false;
			insPane.dontshow.buttonMode = insPane.ok.buttonMode = true;
			insPane.addEventListener(MouseEvent.ROLL_OVER, insPaneOver);
			insPane.addEventListener(MouseEvent.ROLL_OUT, insPaneOut);
			insPane.dontshow.addEventListener(MouseEvent.CLICK, dontShowClick);
			insPane.ok.addEventListener(MouseEvent.CLICK, okClick);
			
			// grab cursor
			bgCover2.g0.visible = bgCover2.g1.visible = false;
			//CustomCursor.assignCursor(bgCover2.g0, bgCover2.g1, bgCover2);
			//MouseControl.assignClip(bgCover2);
			
			// background color
			TweenMax.to(bgCover0, 0, { tint:configObject.backgroundColor } );
			TweenMax.to(bgCover1, 0, { tint:configObject.backgroundColor1 } );
			TweenMax.to(bgCover2.bg, 0, { tint:configObject.backgroundColor2 } );
			
			// description background color
			TweenMax.to(sCover, 0, { tint:Number(mainXMLData.generalConfig.@descriptionColor) } );
			// description config
			var cObject:Object = new Object();
			cObject.width = configObject.descriptionWidth;
			cObject.height = configObject.descriptionHeight;
			cObject.paddingX = Number(mainXMLData.generalConfig.@paddingX);
			cObject.paddingY = Number(mainXMLData.generalConfig.@paddingY);
			cObject.scrollerDistance = Number(mainXMLData.generalConfig.@scrollerDistance);
			cObject.scrollerHeight = Number(mainXMLData.generalConfig.@scrollerHeight);
			cObject.backgroundAlpha = Number(mainXMLData.generalConfig.@backgroundAlpha);
			cObject.autoCenter = "true"
			cObject.mouseWheelSpeed = Number(mainXMLData.generalConfig.@mouseWheelSpeed);
			cObject.easing = Number(mainXMLData.generalConfig.@easing);
			// text scroller
			dTScroller.config(cObject);
			dTScroller.closeBut.x = configObject.descriptionWidth - 60;
			dTScroller.closeBut.y = -20;
			addChild(dTScroller);
			dTScroller.visible = false;
			
			// thumbnail scroller
			dScroller.resize(Number(mainXMLData.generalConfig.@scrollerLength));
			dScroller.x = (stage.stageWidth - dScroller.width) * .5;
			dScroller.y = viewport.y + viewport.viewportHeight;
			addChild(dScroller);
			dScroller.visible = false;
			
			// preload thumbnail
			preloadThumbnail.x = Math.round(stage.stageWidth  * .5);
			preloadThumbnail.y = Math.round(stage.stageHeight * .5);
			
			// setup category menu
			categoryMenu.addEventListener(SimpleComboBoxEvent.ON_CLICK, menuClick);
			categoryMenu.addEventListener(MouseEvent.ROLL_OVER, menuOver);
			categoryMenu.addEventListener(MouseEvent.ROLL_OUT, menuOut);
			for (var i:Number = 0; i < mainXMLData.category.length(); i++)
			{
				categoryMenu.addMenuItem(mainXMLData.category[i].@title);
			}
			categoryMenu.alignItem("center");
			categoryMenu.x = Math.round((stage.stageWidth - categoryMenu.width) * .5);
			categoryMenu.y = Math.round(stage.stageHeight * .5 - comboDistance);
			if (configObject.useCategory) addChild(categoryMenu);
			
			// setup control menu
			setupControl();
			
			// short description
			addChild(shortDes);
			shortDes.width = Number(mainXMLData.generalConfig.@shortDescriptionWidth);
			shortDes.height = Number(mainXMLData.generalConfig.@shortDescriptionHeight);
			shortDes.x = (stage.stageWidth - shortDes.width) * .5;
			shortDes.y = stage.stageHeight * .5 + shortDesDistance;
			shortDes.alpha = 0;
			
			//click for more
			cFM.x = Math.round(stage.stageWidth * .5);
			cFM.y = Math.round(stage.stageHeight * .5) - cFMDistance;
			
			// fullscreen but
			//DM Added check if configObject is set...
			if(configObject.fullScreenEnable){
				addChild(fullBut);
				fullBut.buttonMode = true;
				fullBut.x = stage.stageWidth * .5 + 400;
				fullBut.y = stage.stageHeight * .5 + 200;
				fullBut.addEventListener(MouseEvent.CLICK, fullButPress);
			}
			
			// slideshow clip
			ssClip.x = stage.stageWidth * .5;
			ssClip.y = 633;//stage.stageHeight * .5 - ssClipDistance;
			
			// disable layer
			addChild(disableLayer);
			disableLayer.alpha = 0;
			disableLayer.visible = false;
			disableLayer.width = stage.stageWidth;
			disableLayer.height = stage.stageHeight;
			disableLayer.x = disableLayer.y = 0;
			
			// load first category
			cID = 0;
			loadCategory(0);
		}
		
		// custom img background loaded
		private function imgLoaded(e:QueueLoaderEvent):void
		{
			bgCover2.addChild(bgCover2.g0);
			bgCover2.addChild(bgCover2.g1);
		}
		
		private function insPaneOver(e:MouseEvent):void
		{
			insPane.isOver = true;
		}
		
		private function insPaneOut(e:MouseEvent):void
		{
			insPane.isOver = false;
		}
		
		private function dontShowClick(e:MouseEvent):void
		{
			insPane.visible = false;
			insPane.visibleStatus = false;
			disableLayer.visible = false;
			disableLayer.alpha = 0;
			stage.addEventListener(MouseEvent.MOUSE_DOWN, myGallery.startInteractive, false, 0, true);
		}
		
		private function okClick(e:MouseEvent):void
		{
			insPane.visible = false;
			disableLayer.visible = false;
			disableLayer.alpha = 0;
			stage.addEventListener(MouseEvent.MOUSE_DOWN, myGallery.startInteractive, false, 0, true);
		}
		
		private function fullButPress(e:Event):void
		{
			if (stage.displayState == StageDisplayState.NORMAL)
			{
				fullBut.zin.visible = false;
				stage.displayState = StageDisplayState.FULL_SCREEN;
			}
			else
			{
				fullBut.zin.visible = true;
				stage.displayState = StageDisplayState.NORMAL;
			}
		}
		
		private function menuClick(e:SimpleComboBoxEvent):void
		{
			if (e.index != -1)
			{
				isClick = true;
				categoryMenu.hideMenuItem();
				if (myGallery.isSlideShow)
				{
					myGallery.slideShow.stop();
					myGallery.myTween.pause();
					ssClip.visible = false;
				}
				
				addChild(disableLayer);
				disableLayer.alpha = 0;
				disableLayer.visible = true;
				TweenMax.to(viewport, 0.25, { 	alpha:0, 
												overwrite:1, 
												onComplete:function():void
												{
													loadCategory(e.index);
												}
							});
			}
		}
		
		private function menuOver(e:Event):void
		{
			menuOverCheck = true;
			TweenMax.to(viewport, 0.25, { alpha:0.25, overwrite:1 } );
			if (myGallery.isSlideShow) 
			{
				ssClip.visible = false;
			}
		}
		
		private function menuOut(e:Event):void
		{
			menuOverCheck = false;
			if (!isClick) TweenMax.to(viewport, 0.25, { alpha:1, overwrite:1 } ); else isClick = false;
			if (myGallery.isSlideShow) 
			{
				ssClip.visible = true;
			}
		}
		
		private function loadCategory(idx:Number):void
		{
			cID = idx;
			//MouseControl.stop();
			if (categoryXML[idx] == undefined)
			{
				// show preloader
				addChild(preloadThumbnail);
				preloadThumbnail.x = Math.round(stage.stageWidth  * .5);
				preloadThumbnail.y = Math.round(stage.stageHeight * .5);
				preloadThumbnail.content.text = "LOADING XML...";
				shortDes.visible = false;
				// load main XML
				var xmlLoader:XMLLoader = new XMLLoader();
				xmlLoader.load(mainXMLData.category[idx].@xmlSource);
				xmlLoader.addEventListener(XMLLoaderEvent.LOADED, categoryXMLLoaded);
			}
			else
			{
				myGallery.disposeGallery();
				shortDes.visible = false;
				myGallery.createGallery(categoryXML[cID], String(mainXMLData.category[cID].@type));
			}
		}
		
		private function categoryXMLLoaded(e:XMLLoaderEvent):void
		{
			categoryXML[cID] = e.xmlObjectData;
			if (myGallery != null)
			{
				myGallery.disposeGallery();
			}
			else
			{
				myGallery = new aMediaGallery(scene, viewport, renderer, camera, configObject);
			}
			shortDes.visible = false;
			addChild(myGallery);
			myGallery.createGallery(categoryXML[cID], String(mainXMLData.category[cID].@type));
		}
		
		// Control thumbnail roll over / out interactive
		private function setupControl():void
		{
			with (control)
			{
				infoBut.visible = configObject.useLongDescription;
				closeBut.buttonMode = preBut.buttonMode = nextBut.buttonMode = infoBut.buttonMode = true;
				closeBut.addEventListener(MouseEvent.ROLL_OVER, butRollOver);
				closeBut.addEventListener(MouseEvent.ROLL_OUT, butRollOut);
				preBut.addEventListener(MouseEvent.ROLL_OVER, butRollOver);
				preBut.addEventListener(MouseEvent.ROLL_OUT, butRollOut);
				nextBut.addEventListener(MouseEvent.ROLL_OVER, butRollOver);
				nextBut.addEventListener(MouseEvent.ROLL_OUT, butRollOut);
				infoBut.addEventListener(MouseEvent.ROLL_OVER, butRollOver);
				infoBut.addEventListener(MouseEvent.ROLL_OUT, butRollOut);
			}
		}
		
		private function butRollOver(e:MouseEvent):void
		{
			TweenMax.to(e.target, 0.75, { width:60, height:60, ease:Elastic.easeOut } );
			//if (!myGallery.stageDown)
				TweenMax.to(e.target.parent, 0.75, { alpha:1, ease:Quint.easeOut, overwrite:1 } );
		}
		
		private function butRollOut(e:MouseEvent):void
		{
			TweenMax.to(e.target, 0.75, { width:50, height:50, ease:Elastic.easeOut } );
		}
		
		// load stylesheet and apply to description field
		private function initStyleSheet():void
		{
			// load external css
			var req:URLRequest = new URLRequest(cssPath);
			var loader:URLLoader = new URLLoader();
			loader.load(req);
			loader.addEventListener(Event.COMPLETE, cssLoaded);
		}
		
		private function cssLoaded(e:Event):void
		{
			css.parseCSS(e.target.data);
			dTScroller.container.content.styleSheet = css;
			shortDes.styleSheet = css;
		}
		
		// stage resize - reposition component
		private function stageResize(e:Event):void
		{
			//center element
			viewport.x = (stage.stageWidth - viewport.viewportWidth) * .5;
			viewport.y = (stage.stageHeight - viewport.viewportHeight) * .5;
			dScroller.x = (stage.stageWidth - dScroller.width) * .5;
			dScroller.y = viewport.y + viewport.viewportHeight;
			categoryMenu.x = Math.round((stage.stageWidth - categoryMenu.width) * .5);
			preloadThumbnail.x = Math.round(stage.stageWidth  * .5);
			preloadThumbnail.y = Math.round(stage.stageHeight * .5);
			categoryMenu.x = Math.round((stage.stageWidth - categoryMenu.width) * .5);
			categoryMenu.y = Math.round(stage.stageHeight * .5 - comboDistance);
			bgCover0.x = bgCover0.y = 0;
			bgCover0.width = stage.stageWidth;
			bgCover0.height = stage.stageHeight;
			bgCover0.x = bgCover0.y = 0;
			bgCover1.width = stage.stageWidth;
			bgCover1.x = 0;
			bgCover1.y = (stage.stageHeight - bgCover1.height) * .5;
			bgCover2.width = stage.stageWidth;
			bgCover2.x = 0;
			bgCover2.y = (stage.stageHeight - bgCover2.height) * .5;
			control.alpha = 0;
			control.x = Math.round(stage.stageWidth * .5) + 30 * Number(!control.infoBut.visible);
			control.y = Math.round(stage.stageHeight * .5) + configObject.controlDistanceFromCenter;
			dTScroller.x = Math.round((stage.stageWidth - configObject.descriptionWidth) * .5);
			dTScroller.y = Math.round((stage.stageHeight - configObject.descriptionHeight) * .5);
			sCover.x = Math.round(stage.stageWidth * .5);
			sCover.y = Math.round(stage.stageHeight * .5);
			shortDes.x = (stage.stageWidth - shortDes.width) * .5;
			shortDes.y = stage.stageHeight * .5 + shortDesDistance;
			disableLayer.width = stage.stageWidth;
			disableLayer.height = stage.stageHeight;
			disableLayer.x = disableLayer.y  = 0;
			fullBut.x = stage.stageWidth * .5 + 400;
			fullBut.y = stage.stageHeight * .5 + 200;
			ssClip.x = stage.stageWidth * .5;
			ssClip.y = 633;//stage.stageHeight * .5 - ssClipDistance;
			mp3Player.x = (stage.stageWidth - mp3Player.width) * .5;
			mp3Player.y = (stage.stageHeight - mp3Player.height) * .5;
			videoPlayer.x = (stage.stageWidth - videoPlayer.width) * .5;
			videoPlayer.y = (stage.stageHeight - videoPlayer.height) * .5;
			insPane.x = Math.round(stage.stageWidth * .5);
			insPane.y = Math.round(stage.stageHeight * .5);
			cFM.x = Math.round(stage.stageWidth * .5);
			cFM.y = Math.round(stage.stageHeight * .5) - cFMDistance;
			if (myGallery.swfLoader != null)
			{
				myGallery.swfLoader.x = (stage.stageWidth - myGallery.w) * .5;
				myGallery.swfLoader.y = (stage.stageHeight - myGallery.h) * .5;
			}
		} 
		   
	}
	
}