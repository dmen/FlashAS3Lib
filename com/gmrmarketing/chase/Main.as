package com.gmrmarketing.chase
{
	import flash.external.ExternalInterface; //for calling ffish scripts
	import com.gmrmarketing.utilities.Slider;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.*;
	import com.greensock.TweenMax;
	import com.gmrmarketing.utilities.XMLLoader;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.filters.DropShadowFilter;
	import flash.printing.PrintJob;
	import flash.printing.PrintJobOptions;
	import flash.utils.Timer;
	import com.gmrmarketing.utilities.CornerQuit;
	import flash.system.fscommand; //for fullscreen
	
	public class Main extends MovieClip
	{
		//four bonus sliders - captions defined by chaseconfig.xml
		private var sliderOne:Slider;
		private var sliderTwo:Slider;
		private var sliderThree:Slider;
		private var sliderFour:Slider;
		
		//two permanent sliders
		private var sliderKohls:Slider;
		private var sliderOnePercent:Slider;
		
		//four draggers
		private var dragOne:Loader;
		private var dragTwo:Loader;
		private var dragThree:Loader;
		private var dragFour:Loader;		
				
		private var page1:MovieClip; //intro page
		private var page2:MovieClip; //calculator page
		private var page3:MovieClip; //print page
		
		private var xmlLoader:XMLLoader;
		
		private var iconShadow:DropShadowFilter;
		private var cq:CornerQuit;
		
		private var pError:MovieClip; //print error dialog - lib clip
		
		
		public function Main()
		{
			page1 = new p1();
			page2 = new p2();
			page3 = new p3();
			
			iconShadow = new DropShadowFilter(0, 0, 0, 1, 5, 5, 1, 2);
			
			dragOne = new Loader();
			dragOne.filters = [iconShadow];
			dragTwo = new Loader();
			dragTwo.filters = [iconShadow];
			dragThree = new Loader();
			dragThree.filters = [iconShadow];
			dragFour = new Loader();
			dragFour.filters = [iconShadow];
			
			cq = new CornerQuit(false);
			cq.init(this, "ulur");
			cq.customLoc(2, new Point(1820, 0));
			cq.addEventListener(CornerQuit.CORNER_QUIT, quitApplication, false, 0, true);
			
			xmlLoader = new XMLLoader();
			xmlLoader.addEventListener(Event.COMPLETE, xmlLoaded, false, 0, true);
			xmlLoader.load("chaseconfig.xml");
		}
		
		private function xmlLoaded(e:Event):void
		{
			var theXML:XML = xmlLoader.getXML();
			var slides:XMLList = theXML.slide;
			
			page2.caption1.htmlText = slides[0].caption;
			page2.caption2.htmlText = slides[1].caption;
			page2.caption3.htmlText = slides[2].caption;
			page2.caption4.htmlText = slides[3].caption;
			
			dragOne.load(new URLRequest(slides[0].icon));
			dragOne.contentLoaderInfo.addEventListener(Event.COMPLETE, smoothIcon, false, 0, true);
			dragTwo.load(new URLRequest(slides[1].icon));
			dragTwo.contentLoaderInfo.addEventListener(Event.COMPLETE, smoothIcon, false, 0, true);
			dragThree.load(new URLRequest(slides[2].icon));
			dragThree.contentLoaderInfo.addEventListener(Event.COMPLETE, smoothIcon, false, 0, true);
			dragFour.load(new URLRequest(slides[3].icon));
			dragFour.contentLoaderInfo.addEventListener(Event.COMPLETE, smoothIcon, false, 0, true);
			
			dragOne.x = 86;
			dragOne.y = 264;
			dragTwo.x = 86;
			dragTwo.y = 368;
			dragThree.x = 86;
			dragThree.y = 475;
			dragFour.x = 86;
			dragFour.y = 580;
			
			page2.addChild(dragOne);
			page2.addChild(dragTwo);
			page2.addChild(dragThree);
			page2.addChild(dragFour);
			
			doPage1();
		}
		
		private function smoothIcon(e:Event):void
		{
			var target:Loader = e.currentTarget.loader as Loader;
			Bitmap(target.content).smoothing = true;			
		}
		
		private function doPage1(e:TimerEvent = null):void
		{		
			//kills animated dots on print screen
			TweenMax.killAll();
			
			addChild(page1);
			cq.moveToTop();
			
			page1.alpha = 0;
			page1.btnNext.addEventListener(MouseEvent.MOUSE_DOWN, doPage2, false, 0, true);			
			TweenMax.to(page1, .5, { alpha:1, onComplete:removePage3 } );
		}
		
		private function removePage1():void
		{
			if (contains(page1)) {
				removeChild(page1);
			}
			page2.btnPrint.addEventListener(MouseEvent.MOUSE_DOWN, doPage3, false, 0, true);
		}
		private function removePage2():void
		{
			if (contains(page2)) {
				removeChild(page2);
			}
		}
		private function removePage3():void
		{
			if (contains(page3)) {
				removeChild(page3);
			}
		}
		
		private function doPage2(e:MouseEvent):void
		{	
			dragOne.contentLoaderInfo.removeEventListener(Event.COMPLETE, smoothIcon);
			dragTwo.contentLoaderInfo.removeEventListener(Event.COMPLETE, smoothIcon);
			dragThree.contentLoaderInfo.removeEventListener(Event.COMPLETE, smoothIcon);
			dragFour.contentLoaderInfo.removeEventListener(Event.COMPLETE, smoothIcon);
			
			page1.btnNext.removeEventListener(MouseEvent.MOUSE_DOWN, doPage2);
			
			addChild(page2);
			cq.moveToTop();
			
			page2.alpha = 0;
			TweenMax.to(page2, .5, { alpha:1, onComplete:removePage1 } );
			
			page2.barKohls.scaleX = 0;
			page2.barOnePercent.scaleX = 0;
			
			sliderOne = new Slider(dragOne, page2.genericTrack);
			sliderTwo = new Slider(dragTwo, page2.genericTrack);
			sliderThree = new Slider(dragThree, page2.genericTrack);
			sliderFour = new Slider(dragFour, page2.genericTrack);
			
			sliderKohls = new Slider(page2.dragKohls, page2.genericTrack);
			sliderOnePercent = new Slider(page2.dragOnePercent, page2.genericTrack);
			
			sliderOne.addEventListener(Slider.DRAGGING, updateBarOne, false, 0, true);
			sliderTwo.addEventListener(Slider.DRAGGING, updateBarTwo, false, 0, true);
			sliderThree.addEventListener(Slider.DRAGGING, updateBarThree, false, 0, true);
			sliderFour.addEventListener(Slider.DRAGGING, updateBarFour, false, 0, true);
			
			sliderKohls.addEventListener(Slider.DRAGGING, updateKohlsBar, false, 0, true);
			sliderOnePercent.addEventListener(Slider.DRAGGING, updateOnePercentBar, false, 0, true);
			
			//reset slider positions
			dragOne.x = 86;			
			dragTwo.x = 86;			
			dragThree.x = 86;			
			dragFour.x = 86;
			page2.dragKohls.x = 86;
			page2.dragOnePercent.x = 86;
			
			updateBarOne();
			updateBarTwo();
			updateBarThree();
			updateBarFour();
			updateKohlsBar();
			updateOnePercentBar();
		}
		

		private function updateBarOne(e:Event = null):void
		{
			page2.barOne.scaleX = sliderOne.getPosition();
			page2.spendOne.text = "$" + String(getAmount(sliderOne.getPosition()));
			updateTotal();
		}
		private function updateBarTwo(e:Event = null):void
		{
			page2.barTwo.scaleX = sliderTwo.getPosition();	
			page2.spendTwo.text = "$" + String(getAmount(sliderTwo.getPosition()));
			updateTotal();
		}
		private function updateBarThree(e:Event = null):void
		{
			page2.barThree.scaleX = sliderThree.getPosition();	
			page2.spendThree.text = "$" + String(getAmount(sliderThree.getPosition()));
			updateTotal();
		}
		private function updateBarFour(e:Event = null):void
		{
			page2.barFour.scaleX = sliderFour.getPosition();	
			page2.spendFour.text = "$" + String(getAmount(sliderFour.getPosition()));
			updateTotal();
		}
		private function updateKohlsBar(e:Event = null):void
		{
			page2.barKohls.scaleX = sliderKohls.getPosition();	
			page2.spendKohls.text = "$" + String(getAmount(sliderKohls.getPosition()));
			updateTotal();
		}
		private function updateOnePercentBar(e:Event = null):void
		{
			page2.barOnePercent.scaleX = sliderOnePercent.getPosition();	
			page2.spendOnePercent.text = "$" + String(getAmount(sliderOnePercent.getPosition()));
			updateTotal();
		}
		
		/**
		 * returns 0 - 2000 based on the slider position of 0 - 1
		 * @param	sliderValue
		 * @return
		 */
		private function getAmount(sliderValue:Number):int
		{
			var t:int = Math.round(20000 * sliderValue / 100);
			return t * 10;
		}

		
		private function updateTotal():void
		{
			//total minus one percent slider
			var tot:int = getAmount(sliderOne.getPosition()) + getAmount(sliderTwo.getPosition()) + getAmount(sliderThree.getPosition())+ getAmount(sliderFour.getPosition()) + getAmount(sliderKohls.getPosition());	
			var leftOver:int = 0;
			if (tot > 500) {
				leftOver = tot - 500;
			}			
			
			var onePerTotal:int = getAmount(sliderOnePercent.getPosition());
			
			page2.spendTotal.text = "$" + String(tot + onePerTotal);
			page2.spendQuarterly.text = "$" + String((tot + onePerTotal) * 3);			
			
			var maxMonthlyTotal:int = Math.min(500, tot); 
			var quarterlyCashBack:Number = Math.ceil(maxMonthlyTotal * 3 * .05);
			page2.cashBackQuarterly.text = "$" + String(quarterlyCashBack);
			
			var kohlsSpend:int = getAmount(sliderKohls.getPosition());
			var kohlsMax:int = Math.min(500, kohlsSpend);
			var kohlsBack:Number = Math.ceil(kohlsMax * 3 * .05);
			page2.cashBackKohls.text = "$" + String(kohlsBack);
			
			//cashBackOnePercent
			var onePer:Number = 0;
			if (leftOver > 0) {			
				onePer = Math.ceil(leftOver * 3 * .01);				
			}
			
			var onePerBack:Number = Math.ceil(onePerTotal * 3 * .01);
			
			page2.cashBackOnePercent.text = "$" + String(onePer + onePerBack);			
			
			//cashBackTotal
			page2.cashBackTotal.text = "$" + String(quarterlyCashBack + kohlsBack + onePer + onePerBack);			
		}
		
		
		
		/**
		 * Called by pressing the print button on page 2
		 * @param	e
		 */
		private function doPage3(e:MouseEvent):void
		{
			addChild(page3);
			cq.moveToTop();
			
			page3.alpha = 0;
			page3.dots.dot1.alpha = 1;
			page3.dots.dot2.alpha = 1;
			page3.dots.dot3.alpha = 1;
			TweenMax.to(page3, .5, { alpha:1, onComplete:removePage2 } );
			
			TweenMax.to(page3.dots.dot1,.5,{alpha:0,repeat:-1,yoyo:true});
			TweenMax.to(page3.dots.dot2,.5,{alpha:0,delay:.1,repeat:-1,yoyo:true});
			TweenMax.to(page3.dots.dot3, .5, { alpha:0, delay:.2, repeat: -1, yoyo:true } );
			
			//Use for Production
			//TweenMax.delayedCall(.5, print);
			//Use for Web - no print.
			TweenMax.delayedCall(.5, printComplete);
		}
		
		
		private function print():void
		{
			if(pError){
				if (contains(pError)) {
					removeChild(pError);
					pError.btnYes.removeEventListener(MouseEvent.MOUSE_DOWN, print);
					pError.btnNo.removeEventListener(MouseEvent.MOUSE_DOWN, closePrintErrorDialog);
				}
			}
			
			var printJob:PrintJob = new PrintJob();
			
			var printClip:MovieClip = new MovieClip();
			var recData:BitmapData = new receipt();
			//var recData:BitmapData = new BitmapData(600, 1380, false, 0xffffff00);
			//add amount saved from page2
			var ct:ColorTransform = new ColorTransform();
			ct.color = 0x000000;
			
			var textData:BitmapData = new BitmapData(480, 115, true, 0x00000000);
			textData.draw(page2.cashBackTotal, null, ct);
			
			var m:Matrix = new Matrix();
			//m.rotate(Math.PI / 2);
			m.translate(140, 392);
			m.scale(.95, .95);
			
			recData.draw(textData, m, null, null, null, true);
			
			var rec:Bitmap = new Bitmap(recData);			
			printClip.addChild(rec);
			
			//addChild(printClip);
			
			if (printJob.start()) {
				
				//use this trace to get the printers proper page size
				//only works after printJob.start() is called
				//trace(printJob.pageWidth, printJob.pageHeight);
				
				//printJob.pageWidth
				if (printClip.width > 225) {
				   printClip.width = 225;
				   printClip.scaleY = printClip.scaleX;
				}

				var ok:int = 0;
				try{
					printJob.addPage(printClip);
					ok = 1;
					
				}catch (e:Error) {
					ok = 0;
					printFailed();
				}
				
				if (ok == 1) {
					printJob.send();
					printComplete();
				}else {
					printFailed();
				}
				
			}else {
				printFailed();
			}						
		}
		
		private function printComplete():void
		{
			var pTimer:Timer = new Timer(6000, 1);
			pTimer.addEventListener(TimerEvent.TIMER, doPage1, false, 0, true);
			pTimer.start();
		}
		
		private function printFailed():void
		{
			pError = new printErrorDialog(); //lib clip
			addChild(pError);			
			pError.x = 650;
			pError.y = 300;
			pError.btnYes.addEventListener(MouseEvent.MOUSE_DOWN, print, false, 0, true);
			pError.btnNo.addEventListener(MouseEvent.MOUSE_DOWN, closePrintErrorDialog, false, 0, true);
		}
		
		private function closePrintErrorDialog(e:MouseEvent):void
		{
			if(pError){
				if (contains(pError)) {
					removeChild(pError);
				}
				pError.btnYes.removeEventListener(MouseEvent.MOUSE_DOWN, print);
				pError.btnNo.removeEventListener(MouseEvent.MOUSE_DOWN, closePrintErrorDialog);
			}
			doPage1();
		}
		/**
		 * Called by listener on cQuit that listens for the eight corner clicks
		 * calls quit function in SWFKit
		 * @param	e
		 */
		private function quitApplication(e:Event):void
		{			
			//ExternalInterface.call("ffish_run", "doquit");
			fscommand("quit");
		}

	}
	
}