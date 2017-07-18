package com.gmrmarketing.katyperry.witness
{
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.filters.*;	
	import flash.media.*;
	import net.hires.debug.Stats;
	import com.chargedweb.utils.MatrixUtil;
	
	
	public class Main extends MovieClip
	{	
		private var pm:Primatte;
		private var mainContainer:Sprite;

		
		public function Main()
		{
			mainContainer = new Sprite();
			addChildAt(mainContainer,1);
			
			pm = new Primatte();
			pm.container = mainContainer; 
			pm.show();
			
			addChild(new Stats());
			
			btn.addEventListener(MouseEvent.MOUSE_DOWN, toggleSampling, false, 0, true);
			btnTake.addEventListener(MouseEvent.MOUSE_DOWN, takePic, false, 0, true);
		}


		private function toggleSampling(e:MouseEvent):void
		{
			var l:Boolean = pm.toggleCam();
			
			if(!l){
				//no mask - showing cam only
				stage.addEventListener(MouseEvent.MOUSE_DOWN, sampleColor);
			}else{
				stage.removeEventListener(MouseEvent.MOUSE_DOWN, sampleColor);
			}
		}


		private function sampleColor(e:MouseEvent):void
		{
			var col:Array = pm.hueValueAtPoint(new Point(mouseX,mouseY));
			hVal.text = col[0].toString();
			trace("lum:", col[2]);
			pm.setKeyValue(col[0], parseFloat(threshVal.text));
		}


		private function takePic(e:MouseEvent):void
		{
			var wh:BitmapData = new BitmapData(960,540,false,0xffffff);
			var pink:BitmapData = new pinkData();	//458x540

			//user image - crop to face circle
			var im:BitmapData = pm.pic;//full size from camera - 960x540
			var userCrop:BitmapData = new BitmapData(460,540,true,0x00000000);
			userCrop.copyPixels(im, new Rectangle(250, 0, 460, 540), new Point(0, 0), null, null, true);
			
			userCrop.applyFilter(userCrop, userCrop.rect, new Point(),  MatrixUtil.setContrast(10));
			userCrop.applyFilter(userCrop, userCrop.rect, new Point(),  MatrixUtil.setBrightness(10));
			//userCrop.applyFilter(userCrop, userCrop.rect, new Point(),  MatrixUtil.setSaturation(30));			
			
			var sm1:Matrix = new Matrix();
			sm1.scale(.92, .92);		
			
			var sm2:Matrix = new Matrix();
			sm2.scale(.96,.96);
			
			var userEighty:BitmapData = new BitmapData(userCrop.width * sm1.a, userCrop.height * sm1.d, true, 0x00000000);
			var pinkEighty:BitmapData = new BitmapData(userCrop.width * sm2.a, userCrop.height * sm2.d, true, 0x00000000);
			
			var userNinety:BitmapData = new BitmapData(userCrop.width * sm2.a, userCrop.height * sm2.d, true, 0x00000000);
			var pinkNinety:BitmapData = new BitmapData(userCrop.width * sm2.a, userCrop.height * sm2.d, true, 0x00000000);			
			
			userEighty.draw(userCrop, sm1, null, null, null, true);
			pinkEighty.draw(pink, sm2, null, null, null, true);
			
			userNinety.draw(userCrop, sm2, null, null, null, true);
			pinkNinety.draw(pink, sm2, null, null, null, true);			
			
			wh.copyPixels(pink, pink.rect, new Point(230, 0), null, null, true);
			wh.copyPixels(userEighty, userEighty.rect, new Point(210, 45), null, null, true);
			wh.copyPixels(pink, pink.rect, new Point(303, 0), null, null, true);
			wh.copyPixels(userNinety, userNinety.rect, new Point(283, 22), null, null, true);
			wh.copyPixels(pink, pink.rect, new Point(370, 0), null, null, true);
			wh.copyPixels(userCrop, userCrop.rect, new Point(350, 0), null, null, true);
			
			var b:Bitmap = new Bitmap(wh);
			addChild(b);
		}


	}
	
}