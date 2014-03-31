package com.gmrmarketing.website
{
	import flash.display.LoaderInfo; //for flashvars
	
	import flash.display.MovieClip;
	import flash.events.*;
	
	import away3d.cameras.*;
	import away3d.materials.*;

	import away3d.containers.View3D;
	import away3d.primitives.Cube;
	import away3d.materials.BitmapMaterial;
	import away3d.materials.utils.SimpleShadow;
	import away3d.materials.BitmapFileMaterial;
	
	import away3d.core.utils.Cast;
	import gs.TweenLite;
	import gs.plugins.*;
	
	import flash.display.Stage;	
	import flash.display.StageScaleMode;
	import flash.display.StageAlign;
	
	import flash.net.navigateToURL;	
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	
	public class ClientCube extends MovieClip
	{
		private var viewport:View3D;
		private var cube:Cube;
		private var shadow1:SimpleShadow;
			
		private var language:String; //flashvars
		private var basePath:String; //language plus path delimeter - like: en/
		
		private var xmlLoader:URLLoader;
		
		private var textForm:TextFormat = new TextFormat();
		
		
		public function ClientCube()
		{
			//flashvars
			if (loaderInfo.parameters.language == undefined) {
				language = "en"; //default to english
			}
			basePath = language + "/"; //prepended to image path from xml
			
			TweenPlugin.activate([TintPlugin]);

			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;

			background.width = stage.stageWidth;
			background.height = stage.stageHeight;
			
			logo.addEventListener(MouseEvent.CLICK, gotoHomepage);			
			logo.buttonMode = true;
			
			viewCaseBtn.buttonMode = true;
			viewCaseBtn.addEventListener(MouseEvent.MOUSE_OVER, tintBtn);
			viewCaseBtn.addEventListener(MouseEvent.MOUSE_OUT, untintBtn);
			viewCaseBtn.addEventListener(MouseEvent.CLICK, gotoCaseStudies);
			
			xmlLoader = new URLLoader();
			var req:URLRequest = new URLRequest("clientcube.xml");			
			xmlLoader.addEventListener(Event.COMPLETE, XMLLoaded, false, 0, true);
			xmlLoader.load(req);
			
			//AWAY 3D
			viewport = new View3D({x:750, y:225});
			addChild(viewport);	
			
			stage.addEventListener(Event.RESIZE, onStageResize);
		}

		
		private function XMLLoaded(e:Event):void
		{
			xmlLoader.removeEventListener(Event.COMPLETE, XMLLoaded);
			var theXML:XML = new XML(e.target.data);
			
			//use device fonts for chinese
			if (language == "ch") {
				theTitle.embedFonts = false;
				subTitle.embedFonts = false;				
				theBody.embedFonts = false;
				viewCaseBtn.theText.embedFonts = false;
			}
			
			theTitle.autoSize = TextFieldAutoSize.LEFT;
			textForm.letterSpacing = -.6;
			theTitle.htmlText = theXML.title;
			theTitle.setTextFormat(textForm);
						
			subTitle.y = theTitle.y + theTitle.textHeight + 18;
			subTitle.htmlText = theXML.subtitle;
			theBody.y = subTitle.y + subTitle.textHeight + 15;
			theBody.autoSize = TextFieldAutoSize.LEFT;			
			theBody.htmlText = theXML.body;
				
			viewCaseBtn.y = theBody.y + theBody.textHeight + 20;
			viewCaseBtn.theText.htmlText = theXML.button;
			
			cube = new Cube( { width:175, height:175, depth:175, segmentsH:4, segmentsW:4 } );			
			
			var side1:BitmapFileMaterial = new BitmapFileMaterial(theXML.image1.toString());
			var side2:BitmapFileMaterial = new BitmapFileMaterial(theXML.image2.toString());
			var side3:BitmapFileMaterial = new BitmapFileMaterial(theXML.image3.toString());
			var side4:BitmapFileMaterial = new BitmapFileMaterial(theXML.image4.toString());
			
			side1.smooth = true;
			side2.smooth = true;
			side3.smooth = true;
			side4.smooth = true;
			
			cube.cubeMaterials.left = side1;		
			cube.cubeMaterials.right = side2;
			cube.cubeMaterials.front = side3;
			cube.cubeMaterials.back = side4;			
			
			shadow1 = new SimpleShadow(cube, 0x50CCCCCC, 50, -125, -125)

			viewport.scene.addChild(cube);
			
			addEventListener(Event.ENTER_FRAME, renderThis);
		}
		
		
		private function onStageResize(event:Event):void
		{
			background.width = stage.stageWidth;
			background.height = stage.stageHeight;	
		}

		
		private function tintBtn(e:MouseEvent)
		{
			TweenLite.to(viewCaseBtn, .5, {tint:0x595C63});
		}		
		
		
		private function untintBtn(e:MouseEvent)
		{
			TweenLite.to(viewCaseBtn, .5, {tint:0xE5AA28});
		}
		
		
		private function gotoHomepage(event:MouseEvent):void 
		{
			navigateToURL(new URLRequest("../default.aspx"), "_parent");
		} 

		
		private function gotoCaseStudies(event:MouseEvent):void 
		{
			navigateToURL(new URLRequest("../casestudies.aspx"), "_parent");
		} 
		
		
		/**
		 * Called by ENTER_FRAME event
		 * rotates cube and renders the scene
		 * 
		 * @param	e
		 */
		private function renderThis(e:Event):void 
		{		
			cube.rotationY +=.3;			
			viewport.camera.moveTo(cube.x,cube.y,cube.z);
			viewport.camera.moveBackward(550);
			viewport.render();			
			shadow1.apply(viewport.scene); 
		}
	}
}