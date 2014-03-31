package com.gmrmarketing.holiday2013
{
	import com.tastenkunst.as3.brf.BRFStatus;
	import com.tastenkunst.as3.brf.BRFUtils;
	import com.tastenkunst.as3.brf.examples.BRFBasicWebcam;

	import flash.display.*;	
	import flash.events.*;
	import flash.filters.*;
	import flash.geom.*;
	import com.gmrmarketing.utilities.Slider;
	import com.dmennenoh.keyboard.KeyBoard;
	import com.dmennenoh.keyboard.ChristmasKeyboard;
	import com.gmrmarketing.holiday2012.WebServices;
	import com.greensock.TweenMax;
	import com.gmrmarketing.utilities.Validator;
	/**
	 * Shape mask viewer takes uv data and texture to view the mask
	 * using the face shape. The mouth is cut out.
	 * 
	 * There are some more texture examples in the assets folder.
	 * 
	 * Or generate your own textures using the ShapeMaskExporter.
	 * 
	 * @author Marcel Klammer, 2011
	 */
	public class ShapeMaskViewer extends BRFBasicWebcam {
		
		[Embed(source="assets/texture.png")]
		public var IMAGE_SANTA : Class;
		[Embed(source="assets/texture_mrsclaus.png")]
		public var IMAGE_MRSCLAUS : Class;
		[Embed(source="assets/texture_elf.png")]
		public var IMAGE_ELF : Class;
		
		[Embed(source="assets/uv.txt", mimeType="application/octet-stream")]
		public var UVDATA_SANTA : Class;
		[Embed(source="assets/uv_mrsclaus.txt", mimeType="application/octet-stream")]
		public var UVDATA_MRSCLAUS : Class;
		[Embed(source="assets/uv_plain_guy.txt", mimeType="application/octet-stream")]
		public var UVDATA_ELF : Class;
		
		private const _outlinePoints : Vector.<Point> = new Vector.<Point>(21, true);
		private const _mouthHolePoints : Vector.<Point> = new Vector.<Point>(11, true);
		private var _uvData : Vector.<Number>;
		private var _texture : BitmapData;
		private var _containerDrawMask : Sprite;
		private var _drawMask : Graphics;
		
		
		//DM
		private var mainContainer:Sprite;//holds piccontainer and adornment containers
		private var picContainer:Sprite;//holds capturs from the face sdk - place into mainContainer
		private var beardHolder:Sprite;//holds current beard - place into mainContainer
		private var hatHolder:Sprite;//holds current hat - place into mainContainer
		private var antlerHolder:Sprite; //holds antlers - place into mainContainer
		private var glassesHolder:Sprite;//holds current glasses - place into mainContainer
		private var borderHolder:Sprite;//holds current border - place into mainContainer
		private var logoHolder:Sprite;//holds gmr logo - place into mainContainer
		private var bg:MovieClip;
		private var btnTakePic:MovieClip;
		private var btnDone:MovieClip;
		private var btnDelete:MovieClip;		
		private var btnClearAll:MovieClip;	
		private var face1:MovieClip;
		private var face2:MovieClip;
		private var face3:MovieClip;
		private var hat1:MovieClip;
		private var hat2:MovieClip;
		private var hat3:MovieClip;
		private var hat4:MovieClip;
		private var hat5:MovieClip;
		private var hat6:MovieClip;
		private var hat7:MovieClip;
		private var hat8:MovieClip;
		private var hat9:MovieClip;
		private var hat10:MovieClip;
		private var hat11:MovieClip;
		private var hat12:MovieClip;
		private var hat13:MovieClip;
		private var hat14:MovieClip;
		private var antlers1:MovieClip;
		private var antlers2:MovieClip;
		private var antlers3:MovieClip;
		private var beard1:MovieClip;
		private var beard2:MovieClip;
		private var beard3:MovieClip;
		private var beard4:MovieClip;
		private var glasses1:MovieClip;
		private var glasses2:MovieClip;
		private var glasses3:MovieClip;
		private var border1:MovieClip;
		private var border2:MovieClip;
		private var border3:MovieClip;
		private var border4:MovieClip;
		private var border5:MovieClip;
		private var border6:MovieClip;//for no border
		
		
		private var scaleSlider:MovieClip;
		private var scaleTrack:MovieClip;
		private var scaler:Slider;
		private var rotSlider:MovieClip;
		private var rotTrack:MovieClip;
		private var rot:Slider;
		private var currentScaleObject:DisplayObjectContainer;
		
		private var kbd:KeyBoard;
		private var kbdXML:ChristmasKeyboard;
		private var emailDlg:MovieClip;
		private var web:WebServices;
		private var thanks:MovieClip;
		private var valid:MovieClip;
		
		//end DM
		
		
		public function ShapeMaskViewer() {
			
			super();
			trace("SMV");
			setFace((new IMAGE_SANTA() as Bitmap).bitmapData, Vector.<Number>((new UVDATA_SANTA()).toString().split(",")));			
		}

		override public function initVideoHandling() : void {
			super.initVideoHandling();
			_containerVideo.addChild(_videoManager.videoBitmap);
		}

		override public function initGUI() : void 
		{
			super.initGUI();
			
			x = 22;
			y = 20;
			
			//DM
			mainContainer = new Sprite();
			mainContainer.x = 675;
			mainContainer.y = 0;
			addChild(mainContainer);			
			picContainer = new Sprite();
			hatHolder = new Sprite();
			beardHolder = new Sprite();
			glassesHolder = new Sprite();
			antlerHolder = new Sprite();
			borderHolder = new Sprite();
			logoHolder = new Sprite();
			borderHolder.mouseEnabled = false;
			borderHolder.mouseChildren = false;
			mainContainer.addChild(picContainer);			
			mainContainer.addChild(hatHolder);
			mainContainer.addChild(antlerHolder);
			mainContainer.addChild(beardHolder);
			mainContainer.addChild(glassesHolder);
			mainContainer.addChild(borderHolder);
			mainContainer.addChild(logoHolder);
			
			var logo = new mcGMR();
			logoHolder.addChild(logo);
			logo.x = 556;
			logo.y = 396;
			
			beardHolder.addEventListener(MouseEvent.MOUSE_DOWN, moveBeardBegin, false, 0, true);
			hatHolder.addEventListener(MouseEvent.MOUSE_DOWN, moveHatBegin, false, 0, true);
			glassesHolder.addEventListener(MouseEvent.MOUSE_DOWN, moveGlassesBegin, false, 0, true);
			antlerHolder.addEventListener(MouseEvent.MOUSE_DOWN, moveAntlersBegin, false, 0, true);
			
			bg = new background();//lib clip
			bg.x = -23;
			bg.y = -20;
			addChild(bg);
			bg.mouseEnabled = false;
			bg.mouseChildren = false;
			
			btnTakePic = new btnGeneric();
			btnTakePic.x = 500;
			btnTakePic.y = 520;
			btnTakePic.width = 140;
			btnTakePic.height = 60;
			btnTakePic.alpha = 0;
			addChild(btnTakePic);
			btnTakePic.addEventListener(MouseEvent.MOUSE_DOWN, takePic);
			
			btnDone = new btnGeneric();
			btnDone.x = 1055;
			btnDone.y = 935;
			btnDone.alpha = 0;
			addChild(btnDone);
			btnDone.addEventListener(MouseEvent.MOUSE_DOWN, finished);
			
			btnDelete = new btnGeneric();
			btnDelete.x = 965;
			btnDelete.y = 520;
			btnDelete.width = 170;
			btnDelete.height = 60;
			btnDelete.alpha = 0;
			addChild(btnDelete);
			btnDelete.addEventListener(MouseEvent.MOUSE_DOWN, removeAdorn);
			
			btnClearAll = new btnGeneric();
			btnClearAll.x = 1170;
			btnClearAll.y = 520;
			btnClearAll.width = 150;
			btnClearAll.height = 60;
			btnClearAll.alpha = 0;
			addChild(btnClearAll);
			btnClearAll.addEventListener(MouseEvent.MOUSE_DOWN, resetImage);
			
			//faces
			face1 = new btnGeneric();
			face2 = new btnGeneric();
			face3 = new btnGeneric();
			
			face1.x = 0;
			face1.y = 520;
			face1.width = 100;
			face1.height = 129;
			face1.alpha = 0;
			addChild(face1);
			face1.addEventListener(MouseEvent.MOUSE_DOWN, addFace1);
			
			face2.x = 146;
			face2.y = 520;
			face2.width = 100;
			face2.height = 110;
			face2.alpha = 0;
			addChild(face2);
			face2.addEventListener(MouseEvent.MOUSE_DOWN, addFace2);
			
			face3.x = 285;
			face3.y = 520;
			face3.width = 100;
			face3.height = 100;
			face3.alpha = 0;
			addChild(face3);
			face3.addEventListener(MouseEvent.MOUSE_DOWN, addFace3);
			
			//hats
			hat1 = new btnGeneric();
			hat2 = new btnGeneric();
			hat3 = new btnGeneric();
			hat4 = new btnGeneric();
			hat5 = new btnGeneric();
			hat6 = new btnGeneric();
			hat7 = new btnGeneric();
			hat8 = new btnGeneric();
			hat9 = new btnGeneric();
			hat10 = new btnGeneric();
			hat11 = new btnGeneric();
			hat12 = new btnGeneric();
			hat13 = new btnGeneric();
			hat14 = new btnGeneric();
			
			hat1.x = 1358;
			hat1.y = 9;
			hat1.width = 83;
			hat1.height = 72;
			hat1.alpha = 0;
			addChild(hat1);
			hat1.addEventListener(MouseEvent.MOUSE_DOWN, addHat1);
			
			hat2.x = 1468;
			hat2.y = 9;
			hat2.width = 86;
			hat2.height = 72;
			hat2.alpha = 0;
			addChild(hat2);
			hat2.addEventListener(MouseEvent.MOUSE_DOWN, addHat2);
			
			hat3.x = 1585;
			hat3.y = 9;
			hat3.width = 88;
			hat3.height = 72;
			hat3.alpha = 0;
			addChild(hat3);
			hat3.addEventListener(MouseEvent.MOUSE_DOWN, addHat3);
			
			hat4.x = 1695;
			hat4.y = 9;
			hat4.width = 78;
			hat4.height = 65;
			hat4.alpha = 0;
			addChild(hat4);
			hat4.addEventListener(MouseEvent.MOUSE_DOWN, addHat4);
			
			hat5.x = 1792;
			hat5.y = 9;
			hat5.width = 89;
			hat5.height = 78;
			hat5.alpha = 0;
			addChild(hat5);
			hat5.addEventListener(MouseEvent.MOUSE_DOWN, addHat5);
			
			hat6.x = 1366;
			hat6.y = 148;
			hat6.width = 82;
			hat6.height = 80;
			hat6.alpha = 0;
			addChild(hat6);
			hat6.addEventListener(MouseEvent.MOUSE_DOWN, addHat6);
			
			hat7.x = 1479;
			hat7.y = 148;
			hat7.width = 77;
			hat7.height = 75;
			hat7.alpha = 0;
			addChild(hat7);
			hat7.addEventListener(MouseEvent.MOUSE_DOWN, addHat7);
			
			hat8.x = 1592;
			hat8.y = 148;
			hat8.width = 76;
			hat8.height = 76;
			hat8.alpha = 0;
			addChild(hat8);
			hat8.addEventListener(MouseEvent.MOUSE_DOWN, addHat8);
			
			hat9.x = 1705;
			hat9.y = 148;
			hat9.width = 76;
			hat9.height = 83;
			hat9.alpha = 0;
			addChild(hat9);
			hat9.addEventListener(MouseEvent.MOUSE_DOWN, addHat9);
			
			hat10.x = 1803;
			hat10.y = 148;
			hat10.width = 80;
			hat10.height = 89;
			hat10.alpha = 0;
			addChild(hat10);
			hat10.addEventListener(MouseEvent.MOUSE_DOWN, addHat10);
			
			//mrs claus hat1
			hat11.x = 1357;
			hat11.y = 270;
			hat11.width = 112;
			hat11.height = 102;
			hat11.alpha = 0;
			addChild(hat11);
			hat11.addEventListener(MouseEvent.MOUSE_DOWN, addHat11);
			
			hat12.x = 1501;
			hat12.y = 270;
			hat12.width = 106;
			hat12.height = 102;
			hat12.alpha = 0;
			addChild(hat12);
			hat12.addEventListener(MouseEvent.MOUSE_DOWN, addHat12);
			
			hat13.x = 1642;
			hat13.y = 270;
			hat13.width = 97;
			hat13.height = 104;
			hat13.alpha = 0;
			addChild(hat13);
			hat13.addEventListener(MouseEvent.MOUSE_DOWN, addHat13);
			
			hat14.x = 1773;
			hat14.y = 270;
			hat14.width = 105;
			hat14.height = 101;
			hat14.alpha = 0;
			addChild(hat14);
			hat14.addEventListener(MouseEvent.MOUSE_DOWN, addHat14);
			
			//antlers
			antlers1 = new btnGeneric();
			antlers2 = new btnGeneric();
			antlers3 = new btnGeneric();
			
			antlers1.x = 1362;
			antlers1.y = 420;
			antlers1.width = 140;
			antlers1.height = 69;
			antlers1.alpha = 0;
			addChild(antlers1);
			antlers1.addEventListener(MouseEvent.MOUSE_DOWN, addAntlers1);
			
			antlers2.x = 1543;
			antlers2.y = 420;
			antlers2.width = 157;
			antlers2.height = 72;
			antlers2.alpha = 0;
			addChild(antlers2);
			antlers2.addEventListener(MouseEvent.MOUSE_DOWN, addAntlers2);
			
			antlers3.x = 1734;
			antlers3.y = 420;
			antlers3.width = 144;
			antlers3.height = 75;
			antlers3.alpha = 0;
			addChild(antlers3);
			antlers3.addEventListener(MouseEvent.MOUSE_DOWN, addAntlers3);
			
			//glasses
			glasses1 = new btnGeneric();
			glasses2 = new btnGeneric();
			glasses3 = new btnGeneric();
			
			glasses1.x = 1356;
			glasses1.y = 514;
			glasses1.width = 156;
			glasses1.height = 66;
			glasses1.alpha = 0;
			addChild(glasses1);
			glasses1.addEventListener(MouseEvent.MOUSE_DOWN, addGlasses1);
			
			glasses2.x = 1533;
			glasses2.y = 514;
			glasses2.width = 161;
			glasses2.height = 66;
			glasses2.alpha = 0;
			addChild(glasses2);
			glasses2.addEventListener(MouseEvent.MOUSE_DOWN, addGlasses2);
			
			glasses3.x = 1716;
			glasses3.y = 514;
			glasses3.width = 164;
			glasses3.height = 64;
			glasses3.alpha = 0;
			addChild(glasses3);
			glasses3.addEventListener(MouseEvent.MOUSE_DOWN, addGlasses3);
			
			//beards			
			beard1 = new btnGeneric();
			beard2 = new btnGeneric();
			beard3 = new btnGeneric();
			beard4 = new btnGeneric();
			
			beard1.x = 1366;
			beard1.y = 622;
			beard1.width = 133;
			beard1.height = 95;
			beard1.alpha = 0;
			addChild(beard1);
			beard1.addEventListener(MouseEvent.MOUSE_DOWN, addBeard1);
			
			beard2.x = 1531;
			beard2.y = 622;
			beard2.width = 101;
			beard2.height = 95;
			beard2.alpha = 0;
			addChild(beard2);
			beard2.addEventListener(MouseEvent.MOUSE_DOWN, addBeard2);
			
			beard3.x = 1662;
			beard3.y = 622;
			beard3.width = 104;
			beard3.height = 95;
			beard3.alpha = 0;
			addChild(beard3);
			beard3.addEventListener(MouseEvent.MOUSE_DOWN, addBeard3);
			
			beard4.x = 1789;
			beard4.y = 622;
			beard4.width = 92;
			beard4.height = 83;
			beard4.alpha = 0;
			addChild(beard4);
			beard4.addEventListener(MouseEvent.MOUSE_DOWN, addBeard4);
			
			//borders
			border1 = new btnGeneric();
			border2 = new btnGeneric();
			border3 = new btnGeneric();
			border4 = new btnGeneric();
			border5 = new btnGeneric();
			border6 = new btnGeneric();
			
			border1.x = 1371;
			border1.y = 768;
			border1.width = 140;
			border1.height = 105;
			border1.alpha = 0;
			addChild(border1);
			border1.addEventListener(MouseEvent.MOUSE_DOWN, addBorder1);
			
			border2.x = 1548;
			border2.y = 768;
			border2.width = 140;
			border2.height = 105;
			border2.alpha = 0;
			addChild(border2);
			border2.addEventListener(MouseEvent.MOUSE_DOWN, addBorder2);
			
			border3.x = 1728;
			border3.y = 768;
			border3.width = 140;
			border3.height = 105;
			border3.alpha = 0;
			addChild(border3);
			border3.addEventListener(MouseEvent.MOUSE_DOWN, addBorder3);
			
			border4.x = 1371;
			border4.y = 920;
			border4.width = 140;
			border4.height = 105;
			border4.alpha = 0;
			addChild(border4);
			border4.addEventListener(MouseEvent.MOUSE_DOWN, addBorder4);
			
			border5.x = 1548;
			border5.y = 920;
			border5.width = 140;
			border5.height = 105;
			border5.alpha = 0;
			addChild(border5);
			border5.addEventListener(MouseEvent.MOUSE_DOWN, addBorder5);
			
			border6.x = 1728;
			border6.y = 920;
			border6.width = 140;
			border6.height = 105;
			border6.alpha = 0;
			addChild(border6);
			border6.addEventListener(MouseEvent.MOUSE_DOWN, clearBorder);
						
			scaleTrack = new mcTrack();
			scaleTrack.x = 850;
			scaleTrack.y = 620;//640
			addChild(scaleTrack);
			
			scaleSlider = new mcSlider();
			scaleSlider.x = 1075;
			scaleSlider.y = 600;//613
			addChild(scaleSlider);
			
			scaler = new Slider(scaleSlider, scaleTrack);
			scaler.addEventListener(Slider.DRAGGING, scaleUpdate, false, 0, true);
			
			rotTrack = new mcTrack();
			rotTrack.x = 850;
			rotTrack.y = 665;
			addChild(rotTrack);
			
			rotSlider = new mcSlider();
			rotSlider.x = 1075;
			rotSlider.y = 645;
			addChild(rotSlider);
			
			rot = new Slider(rotSlider, rotTrack);
			rot.addEventListener(Slider.DRAGGING, rotUpdate, false, 0, true);
			
			kbd = new KeyBoard();
			kbdXML = new ChristmasKeyboard();			
			kbd.setKeyFile(kbdXML.getXML());
			
			emailDlg = new mcEmail();//61,660
			thanks = new mcThanks();
			thanks.x = 686;
			thanks.y = 347;
			valid = new mcValid();
			valid.x = 686;
			valid.y = 347;
			
			web = new WebServices();
			web.setServiceURL("http://holiday.thesocialtab.net/holidays/service");
			
			//END DM
			_containerDrawMask = new Sprite();			
			_containerDrawMask.filters = [new BlurFilter(6, 6, BitmapFilterQuality.HIGH)];
			_containerDrawMask.cacheAsBitmap = true;
			_drawMask = _containerDrawMask.graphics;
			_containerDraw.cacheAsBitmap = true;
			_containerDraw.mask = _containerDrawMask;
			addChild(_containerDrawMask);
		}
		
		private function addFace1(e:MouseEvent):void
		{
			setFace((new IMAGE_SANTA() as Bitmap).bitmapData, Vector.<Number>((new UVDATA_SANTA()).toString().split(",")));
		}
		
		private function addFace2(e:MouseEvent):void
		{
			setFace((new IMAGE_MRSCLAUS() as Bitmap).bitmapData, Vector.<Number>((new UVDATA_MRSCLAUS()).toString().split(",")));
		}
		
		private function addFace3(e:MouseEvent):void
		{
			setFace((new IMAGE_ELF() as Bitmap).bitmapData, Vector.<Number>((new UVDATA_ELF()).toString().split(",")));
		}
		
		
		private function removeAdorn(e:MouseEvent):void
		{
			if(currentScaleObject){
				while (currentScaleObject.numChildren) {
					currentScaleObject.removeChildAt(0);
				}
			}
		}
		
		private function takePic(e:MouseEvent):void
		{
			var bmd:BitmapData = new BitmapData(stage.stageWidth, stage.stageHeight);
			bmd.draw(stage);
			
			var crop:BitmapData = new BitmapData(640, 480);
			crop.copyPixels(bmd, new Rectangle(22, 20, 640, 480), new Point(0, 0));
			var cropImage = new Bitmap(crop);
			while (picContainer.numChildren) {
				picContainer.removeChildAt(0);
			}
			picContainer.addChild(cropImage);
		}
		
		//called when done/email is pressed
		private function finished(e:MouseEvent):void
		{
			btnDone.removeEventListener(MouseEvent.MOUSE_DOWN, finished);
			btnDone.addEventListener(MouseEvent.MOUSE_DOWN, sendEmail);
			showKbd();
		}
		private function addHat1(e:MouseEvent):void
		{
			clearHat();
			hatHolder.addChild(new mcHat1());
			resetHat();
		}		
		private function addHat2(e:MouseEvent):void
		{
			clearHat();
			hatHolder.addChild(new mcHat2());
			resetHat();
		}		
		private function addHat3(e:MouseEvent):void
		{
			clearHat();
			hatHolder.addChild(new mcHat3());
			resetHat();
		}
		private function addHat4(e:MouseEvent):void
		{
			clearHat();
			hatHolder.addChild(new mcHat4());
			resetHat();
		}	
		private function addHat5(e:MouseEvent):void
		{
			clearHat();
			hatHolder.addChild(new mcHat5());
			resetHat();
		}
		private function addHat6(e:MouseEvent):void
		{
			clearHat();
			hatHolder.addChild(new mcHat6());
			resetHat();
		}	
		private function addHat7(e:MouseEvent):void
		{
			clearHat();
			hatHolder.addChild(new mcHat7());
			resetHat();
		}	
		private function addHat8(e:MouseEvent):void
		{
			clearHat();
			hatHolder.addChild(new mcHat8());
			resetHat();
		}	
		private function addHat9(e:MouseEvent):void
		{
			clearHat();
			hatHolder.addChild(new mcHat9());
			resetHat();
		}			
		private function addHat10(e:MouseEvent):void
		{
			clearHat();
			hatHolder.addChild(new mcHat10());
			resetHat();
		}	
		private function addHat11(e:MouseEvent):void
		{
			clearHat();
			hatHolder.addChild(new mcHat11());
			resetHat();
		}	
		private function addHat12(e:MouseEvent):void
		{
			clearHat();
			hatHolder.addChild(new mcHat12());
			resetHat();
		}	
		private function addHat13(e:MouseEvent):void
		{
			clearHat();
			hatHolder.addChild(new mcHat13());
			resetHat();
		}	
		private function addHat14(e:MouseEvent):void
		{
			clearHat();
			hatHolder.addChild(new mcHat14());
			resetHat();
		}	
		private function clearHat():void
		{
			while (hatHolder.numChildren) {
				hatHolder.removeChildAt(0);
			}
		}
		private function resetHat():void
		{	
			currentScaleObject = hatHolder;
			hatHolder.x = 320;
			hatHolder.y = 140;
			scaler.reset();
			rot.reset();
			hatHolder.scaleX = hatHolder.scaleY = 1;
			hatHolder.rotation = 0;
		}
		private function moveHatBegin(e:MouseEvent):void		
		{
			hatHolder.startDrag(false, new Rectangle(0, 0, 640, 480));
			currentScaleObject = hatHolder;
			_stage.addEventListener(MouseEvent.MOUSE_UP, moveHatEnd, false, 0, true);
		}
		private function moveHatEnd(e:MouseEvent):void
		{
			hatHolder.stopDrag();
		}
		//antlers
		private function addAntlers1(e:MouseEvent):void
		{
			clearAntlers();
			antlerHolder.addChild(new mcAntlers1());
			resetAntlers();
		}	
		private function addAntlers2(e:MouseEvent):void
		{
			clearAntlers();
			antlerHolder.addChild(new mcAntlers2());
			resetAntlers();
		}
		private function addAntlers3(e:MouseEvent):void
		{
			clearAntlers();
			antlerHolder.addChild(new mcAntlers3());
			resetAntlers();
		}
		private function clearAntlers():void
		{
			while (antlerHolder.numChildren) {
				antlerHolder.removeChildAt(0);
			}
		}
		private function resetAntlers():void
		{	
			currentScaleObject = antlerHolder;
			antlerHolder.x = 320;
			antlerHolder.y = 200;
			scaler.reset();
			rot.reset();
			antlerHolder.scaleX = antlerHolder.scaleY = 1;
			antlerHolder.rotation = 0;
		}
		private function moveAntlersBegin(e:MouseEvent):void		
		{
			antlerHolder.startDrag(false, new Rectangle(0, 0, 640, 480));
			currentScaleObject = antlerHolder;
			_stage.addEventListener(MouseEvent.MOUSE_UP, moveAntlersEnd, false, 0, true);
		}
		private function moveAntlersEnd(e:MouseEvent):void
		{
			antlerHolder.stopDrag();
		}
		private function addBeard1(e:MouseEvent):void
		{
			clearBeard();
			beardHolder.addChild(new mcBeard1());
			resetBeard();
		}		
		private function addBeard2(e:MouseEvent):void
		{
			clearBeard();
			beardHolder.addChild(new mcBeard2());
			resetBeard();
		}		
		private function addBeard3(e:MouseEvent):void
		{
			clearBeard();
			beardHolder.addChild(new mcBeard3());
			resetBeard();
		}
		private function addBeard4(e:MouseEvent):void
		{
			clearBeard();
			beardHolder.addChild(new mcBeard4());
			resetBeard();
		}
		//empties beardHolder
		private function clearBeard():void
		{
			while (beardHolder.numChildren) {
				beardHolder.removeChildAt(0);
			}
		}
		private function resetBeard():void
		{	
			currentScaleObject = beardHolder;
			beardHolder.x = 320;
			beardHolder.y = 240;
			scaler.reset();
			rot.reset();
			beardHolder.scaleX = beardHolder.scaleY = 1;
			beardHolder.rotation = 0;
		}
		private function moveBeardBegin(e:MouseEvent):void		
		{
			beardHolder.startDrag(false, new Rectangle(0, 0, 640, 480));
			currentScaleObject = beardHolder;
			_stage.addEventListener(MouseEvent.MOUSE_UP, moveBeardEnd, false, 0, true);
		}
		private function moveBeardEnd(e:MouseEvent):void
		{
			beardHolder.stopDrag();
		}
		private function addGlasses1(e:MouseEvent):void
		{
			clearGlasses();
			glassesHolder.addChild(new mcGlasses1());
			resetGlasses();
		}		
		private function addGlasses2(e:MouseEvent):void
		{
			clearGlasses();
			glassesHolder.addChild(new mcGlasses2());
			resetGlasses();
		}
		private function addGlasses3(e:MouseEvent):void
		{
			clearGlasses();
			glassesHolder.addChild(new mcGlasses3());
			resetGlasses();
		}
		private function clearGlasses():void
		{
			while (glassesHolder.numChildren) {
				glassesHolder.removeChildAt(0);
			}
		}
		private function resetGlasses():void
		{	
			currentScaleObject = glassesHolder;
			glassesHolder.x = 320;
			glassesHolder.y = 200;
			scaler.reset();
			rot.reset();
			glassesHolder.scaleX = glassesHolder.scaleY = 1;
			glassesHolder.rotation = 0;
		}
		private function moveGlassesBegin(e:MouseEvent):void		
		{
			glassesHolder.startDrag(false, new Rectangle(0, 0, 640, 480));
			currentScaleObject = glassesHolder;
			_stage.addEventListener(MouseEvent.MOUSE_UP, moveGlassesEnd, false, 0, true);
		}
		private function moveGlassesEnd(e:MouseEvent):void
		{
			glassesHolder.stopDrag();
		}
		private function addBorder1(e:MouseEvent):void
		{
			clearBorder();
			borderHolder.addChild(new mcBorder1());
		}
		private function addBorder2(e:MouseEvent):void
		{
			clearBorder();
			borderHolder.addChild(new mcBorder2());
		}
		private function addBorder3(e:MouseEvent):void
		{
			clearBorder();
			borderHolder.addChild(new mcBorder3());
		}
		private function addBorder4(e:MouseEvent):void
		{
			clearBorder();
			borderHolder.addChild(new mcBorder4());
		}
		private function addBorder5(e:MouseEvent):void
		{
			clearBorder();
			borderHolder.addChild(new mcBorder5());
		}
		private function clearBorder(e:MouseEvent = null):void
		{
			while (borderHolder.numChildren) {
				borderHolder.removeChildAt(0);
			}
		}
		//listener for the scale slider
		private function scaleUpdate(e:Event):void
		{
			if(currentScaleObject){
				var s:Number = scaler.getPosition();
				s += .5; //set range from .5 to 1.5
				currentScaleObject.scaleX = currentScaleObject.scaleY = s;
			}
		}
		private function rotUpdate(e:Event):void
		{
			if(currentScaleObject){
				var s:Number = rot.getPosition();
				s -= .5; //set range from -.5 to .5
				currentScaleObject.rotation = s * 30;
			}
		}
		private function showKbd():void
		{
			if(!contains(kbd)){
				emailDlg.theText.text = "";
				addChild(emailDlg);
				emailDlg.x = 61;
				emailDlg.y = 660;
				addChild(kbd);
				kbd.x = 63;
				kbd.y = 730;
				kbd.setFocusFields([emailDlg.theText]);
				kbd.addEventListener(KeyBoard.SUBMIT, sendEmail, false, 0, true);
				emailDlg.btnCancel.addEventListener(MouseEvent.MOUSE_DOWN, cancelEmail, false, 0, true);
			}
		}
		private function cancelEmail(e:MouseEvent):void
		{
			emailDlg.btnCancel.removeEventListener(MouseEvent.MOUSE_DOWN, cancelEmail);
			closeKeyboard();
		}
		private function sendEmail(e:Event):void
		{
			if(Validator.isValidEmail(emailDlg.theText.text)){
				var bmd:BitmapData = new BitmapData(stage.stageWidth, stage.stageHeight);
				bmd.draw(stage);
				
				var crop:BitmapData = new BitmapData(640, 480);
				crop.copyPixels(bmd, new Rectangle(698, 20, 640, 480), new Point(0, 0));			
				
				web.addEventListener(WebServices.ADDED, closeKeyboard, false, 0, true);
				web.processImage(crop);//sets imageString in the object				
				web.queueImage(emailDlg.theText.text);//writs imageString and email to disk
				
			}else {
				addChild(valid);
				valid.alpha = 1;
				TweenMax.to(valid, 2, { alpha:0, delay:2, onComplete:killValid } )
			}
		}
		private function closeKeyboard(e:Event = null):void
		{
			btnDone.removeEventListener(MouseEvent.MOUSE_DOWN, sendEmail);
			btnDone.addEventListener(MouseEvent.MOUSE_DOWN, finished);			
			
			web.removeEventListener(WebServices.COMPLETE, closeKeyboard);
			
			if (contains(kbd)) {
				removeChild(emailDlg);
				removeChild(kbd);
			}
			if(e != null){
				addChild(thanks);
				thanks.alpha = 1;
				TweenMax.to(thanks, 2, { alpha:0, delay:2, onComplete:killThanks } );
			}
		}
		private function killThanks():void
		{
			if (contains(thanks)) {
				removeChild(thanks);
				resetImage();
			}
		}
		private function killValid():void
		{
			if (contains(valid)) {
				removeChild(valid);				
			}
		}
		private function resetImage(e:MouseEvent = null):void
		{
			clearBeard();
			clearBorder();
			clearGlasses();
			clearAntlers();
			clearHat();
			if(e == null){
				while (picContainer.numChildren) {
					picContainer.removeChildAt(0);
				}
			}
		}
		
		override public function onReadyBRF(event : Event = null) : void {
			_mouthHolePoints[0] = _brfManager.faceShape.pointsUpperLip[0];
			_mouthHolePoints[1] = _brfManager.faceShape.pointsLowerLip[5];
			_mouthHolePoints[2] = _brfManager.faceShape.pointsLowerLip[4];
			_mouthHolePoints[3] = _brfManager.faceShape.pointsLowerLip[3];
			_mouthHolePoints[4] = _brfManager.faceShape.pointsLowerLip[2];
			_mouthHolePoints[5] = _brfManager.faceShape.pointsLowerLip[1];
			_mouthHolePoints[6] = _brfManager.faceShape.pointsLowerLip[0];
			_mouthHolePoints[7] = _brfManager.faceShape.pointsUpperLip[4];
			_mouthHolePoints[8] = _brfManager.faceShape.pointsUpperLip[3];
			_mouthHolePoints[9] = _brfManager.faceShape.pointsUpperLip[2];
			_mouthHolePoints[10] = _brfManager.faceShape.pointsUpperLip[1];

			for (var i : int = 0; i < _outlinePoints.length; i++) {
				_outlinePoints[i] = new Point();
			}
			
			super.onReadyBRF(event);
		}

		override public function showResult(showAll : Boolean = false) : void {
			showAll; //just to avoid a warning in eclipse
			var i : int;
			var l : int;
			// no super.showResult() - we draw a mouth hole here
			//a custom drawing to get rid of the mouth
			if(_texture && _brfManager.task == BRFStatus.FACE_ESTIMATION) {
				BRFUtils.getFaceShapeVertices(_brfManager.faceShape);
				_draw.clear();
				//drawing the extracted texture
				_draw.lineStyle();
				_draw.beginBitmapFill(_texture);
				_draw.drawTriangles(_faceShapeVertices, _faceShapeTriangles, _uvData);
				_draw.endFill();
				
				//getting the outline of the face shape mask
				calculateFaceOutline();
				//drawing the outline of the face shape for the burry mask
				i = 1;
				l = _outlinePoints.length;
				_drawMask.clear();
				_drawMask.beginFill(0xff0000, 0.7);
				_drawMask.moveTo(_outlinePoints[0].x, _outlinePoints[0].y);
				while(i < l) {
					_drawMask.lineTo(_outlinePoints[i].x, _outlinePoints[i].y);
					i++;
				}
				_drawMask.lineTo(_outlinePoints[0].x, _outlinePoints[0].y);
				//and drawing the mouse whole into the blurry mask
				i = 1;
				l = _mouthHolePoints.length;
				_drawMask.moveTo(_mouthHolePoints[0].x, _mouthHolePoints[0].y);
				while(i < l) {
					_drawMask.lineTo(_mouthHolePoints[i].x, _mouthHolePoints[i].y);
					i++;
				}
				_drawMask.lineTo(_mouthHolePoints[0].x, _mouthHolePoints[0].y);
				_drawMask.endFill();
			}
		}
		
		
		
		private function calculateFaceOutline() : void {
			var shapePoints : Vector.<Point> = _brfManager.faceShape.shapePoints;
			var center : Point = shapePoints[67];
			var tmpPointShape : Point;
			var tmpPointOutline : Point;
			var fac : Number = 0.08;
			var i : int = 0;
			var l : int = 18;

			for (i = 0; i < l; i++) {
				tmpPointShape = shapePoints[i];
				tmpPointOutline = _outlinePoints[i];
				tmpPointOutline.x = tmpPointShape.x + (center.x - tmpPointShape.x) * fac;
				tmpPointOutline.y = tmpPointShape.y + (center.y - tmpPointShape.y) * fac;
			}
			var k : int = 23;
			l = _outlinePoints.length;
			for (; i < l; i++, k--) {
				tmpPointShape = shapePoints[k];
				tmpPointOutline = _outlinePoints[i];
				tmpPointOutline.x = tmpPointShape.x + (center.x - tmpPointShape.x) * fac;
				tmpPointOutline.y = tmpPointShape.y + (center.y - tmpPointShape.y) * fac;
			}
		}

		public function setFace(texture : BitmapData, uvData : Vector.<Number>) : void {
			_texture = texture;
			_uvData = uvData;
		}
	}
}