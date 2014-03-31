package com.dmennenoh.elance.soccer
{
	import flash.display.*;
	import flash.events.*;
	import com.dmennenoh.elance.soccer.Player;	
	
	
	public class Main extends MovieClip
	{
		private var bg:MovieClip;
		private var playerDot:Sprite;
		private var players:Array;
		
		
		public function Main()
		{
			players = new Array();
			
			bg = new pitch(); //library clip
			bg.x = 100;
			bg.y = 0;
			addChild(bg);
			
			playerDot = new Sprite();
			playerDot.graphics.beginFill(0xff0000, 1);
			playerDot.graphics.drawCircle(0, 0, 15);
			playerDot.x = 20;
			playerDot.y = 50;
			addChild(playerDot);
			playerDot.addEventListener(MouseEvent.CLICK, addPlayer, false, 0, true);
		}
		
		
		private function addPlayer(e:MouseEvent):void
		{
			if(players.length < 11){
				var newPlayer:Player = new Player();
				newPlayer.x = 110;
				newPlayer.y = 110;
				addChild(newPlayer);
				players.push(newPlayer);
			}
		}
	
	}
	
}