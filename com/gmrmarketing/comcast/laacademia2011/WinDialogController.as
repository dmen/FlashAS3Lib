package com.gmrmarketing.comcast.laacademia2011
{	
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import com.greensock.TweenLite;
	import flash.events.*;
	import flash.display.Bitmap;
	import flash.utils.Timer;
	
	
	public class WinDialogController extends EventDispatcher
	{
		public static const WIN_CLOSE:String = "winDialogClosed";
		
		private var dlg:MovieClip;
		private var container:DisplayObjectContainer;
		private var icon:Bitmap;
		private var dialogTimer:Timer;
		
		
		public function WinDialogController($container:DisplayObjectContainer)
		{
			dialogTimer = new Timer(45000, 1);
			dialogTimer.addEventListener(TimerEvent.TIMER, timerCloseDialog, false, 0, true);
			
			container = $container;			
			dlg = new winDialog(); //lib clip
		}
		
		
		public function showDialog(lang:String, tier:int):void
		{
			dlg.alpha = 0;
			container.addChild(dlg);			
			
			var prizeText:String;
			if (lang == "english") {
				prizeText = "You have revealed the XFINITY ";
			}else {
				prizeText = "Usted ha descubierto el símbolo de XFINITY ";
			}
			
			switch(tier) {
				case 1:
					icon = new Bitmap(new iconPhone());
					if (lang == "english") {
						prizeText += "Voice Icons";
					}else {
						prizeText += "Voz/Teléfono";
					}
					break;
				case 2:
					icon = new Bitmap(new iconMouse());
					if (lang == "english") {
						prizeText += "Internet Icons";
					}else {
						prizeText += "Internet";
					}
					break;
				case 3:
					icon = new Bitmap(new iconTV());
					if (lang == "english") {
						prizeText += "TV Icons";
					}else {
						prizeText += "TV";
					}
					break;
				case 4:
					icon = new Bitmap(new iconTriple());
					if (lang == "english") {
						prizeText += "Triple Play Bundle - TV, Internet and Voice.";
					}else {
						prizeText += "Triple Play - TV, Internet y Teléfono.";
					}
					break;
			}
			
			icon.width = icon.height = 138;
			icon.x = 478;
			icon.y = 271;
			dlg.addChild(icon);
			
			if (lang == "english") {
				dlg.title.text = "CONGRATULATIONS!";
				dlg.prize.text = prizeText;
				dlg.behalf.text = "Please accept a thank you gift.\nAsk our Brand Ambassador!\n\nWhile supplies last.";
				//dlg.behalf.text = "On behalf of XFINITY and LaAcademia you have won a prize.";
				//dlg.claim.text = "To claim your prize see the XFINITY representative behind the touch screen.";
				//dlg.thanks.text = "Thanks for playing the XFINITY Triple Play Scratch and Win";				
			}else {
				dlg.title.text = "Felicitaciones!";
				dlg.prize.text = prizeText;
				dlg.behalf.text = "Por favor acepte un regalo de agradecimiento.\n¡Contacte a nuestro Embajador de Marca!\n\nMientras esten disponibles.";
				//dlg.behalf.text = "Usted ha ganado un premio a nombre de XFINITY y La Academia.";
				//dlg.claim.text = "Para reclamar su premio por favor acceda a uno de los representantes detrás de la pantalla.";
				//dlg.thanks.text = "Gracias por jugar Raspa y Gana de XFINITY Triple Play.";
			}
			
			dlg.btnOK.addEventListener(MouseEvent.CLICK, closeDialog, false, 0, true);
			
			TweenLite.to(dlg, 1, { alpha:1 } );
			
			dialogTimer.start();
		}
		
		
		private function timerCloseDialog(e:TimerEvent):void
		{
			dialogTimer.reset();
			closeDialog();
		}
		
		
		private function closeDialog(e:MouseEvent = null):void
		{				
			dialogTimer.reset();
			dlg.btnOK.removeEventListener(MouseEvent.CLICK, closeDialog);
			TweenLite.to(dlg, 1, { alpha:0, onComplete:killDialog } );
		}
		
		
		
		private function killDialog():void
		{
			dlg.removeChild(icon);
			container.removeChild(dlg);
			dispatchEvent(new Event(WIN_CLOSE));
		}
		
	}
	
}