/**
 * Controls mcReview dialog clip
 */
package com.gmrmarketing.sap.boulevard.avatar
{
	import flash.events.*;
	import flash.display.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import flash.filters.BlurFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.*;
	import flash.text.TextFormat;
	
	
	public class Review extends EventDispatcher
	{
		public static const RETAKE:String = "retakePressed";
		public static const SAVE:String = "savePressed";
		
		private var clip:MovieClip;
		private var btnRetake:MovieClip;
		private var container:DisplayObjectContainer;
		
		private var previewImage:Bitmap;
		private const logoPath:String = "nfl_logos/";
		private var sidebar:MovieClip;
		private var userImage:BitmapData;
		private var card:BitmapData;
		private var logo:Bitmap;
		
		private var userData:Object;
		
		private var color1:int; //top and bottom bar colors for the sidebar
		private var color2:int;
		
		
		public function Review()
		{
			clip = new mcReview();
			sidebar = new mcSidebar();//300x780 clip
		}
		
		
		public function setContainer($container:DisplayObjectContainer):void
		{
			container = $container;
		}
		
		/**
		 * From flare - image is displayed at 316,63 and is 1280x960
		 * with a 717 x 780 chunk for display to the user
		 * extract 717x780 chunk at 281,97
		 * @param	image 1280x960 image from Flare
		 */
		public function show(image:BitmapData, team:String, user:Object):void
		{
			if(container){
				if (!container.contains(clip)) {
					container.addChild(clip);
				}
			}			
			
			//need to get the two card colors depending on team:
			switch(team) {
				case "cardinals":
					color1 = 0x97233f; //red
					color2 = 0x002776; //dark blue
					break;
				case "falcons":
					color1 = 0xc60c30; //red
					color2 = 0x111c24; //black
					break;
				case "ravens":
					color1 = 0x241773; //blue
					color2 = 0x111c24; //black
					break;
				case "bills":
					color1 = 0x00338d; //blue
					color2 = 0xc60c30; //red
					break;
				case "panthers":
					color1 = 0x0088ce; //blue
					color2 = 0x111c24; //black
					break;
				case "bears":
					color1 = 0xdd4814; //orange
					color2 = 0x031e2f; //navy
					break;
				case "bengals":
					color1 = 0xf9461c; //orange
					color2 = 0x111c24; //black 17,28,36
					break;
				case "browns":
					color1 = 0xf9461c; //orange
					color2 = 0x332b2a; //brown
					break;
				case "cowboys":
					color1 = 0x003591; //blue
					color2 = 0x7a8f8a; //silver green
					break;
				case "broncos":
					color1 = 0xff6319; //orange
					color2 = 0x002147; //navy
					break;
				case "lions":
					color1 = 0x2a6ebb; //honolulu blue
					color2 = 0x85888b; //silver
					break;
				case "packers":
					color1 = 0x2c5e4f; //green
					color2 = 0xffb612; //gold
					break;
				case "texans":
					color1 = 0xb6061d; //red
					color2 = 0x00133e; //navy
					break;
				case "colts":
					color1 = 0x002395; //navy
					color2 = 0xffffff; //white
					break;
				case "jaguars":
					color1 = 0x006983; //teal
					color2 = 0xb88b00; //gold
					break;
				case "chiefs":
					color1 = 0xc60c30; //red
					color2 = 0xffb612; //gold
					break;
				case "dolphins":
					color1 = 0x006265; //aqua
					color2 = 0xf9461c; //coral
					break;
				case "vikings":
					color1 = 0x4b306a; //purple
					color2 = 0xffb612; //gold
					break;
				case "patriots":
					color1 = 0x002244; //navy
					color2 = 0xc60c30; //red
					break;
				case "saints":
					color1 = 0x968252; //gold
					color2 = 0x111c24; //black
					break;
				case "giants":
					color1 = 0x0b2265; //dark blue
					color2 = 0xa71930; //red
					break;
				case "jets":
					color1 = 0x2c5e4f; //hunter green
					color2 = 0xffffff; //white
					break;
				case "raiders":
					color1 = 0x85888b; //silver
					color2 = 0x111c24; //black 17,28,36
					break;
				case "eagles":
					color1 = 0x004953; //midnight green
					color2 = 0x111c24; //black 17,28,36
					break;
				case "steelers":
					color1 = 0xffb612; //gold
					color2 = 0x111c24; //black 17,28,36
					break;
				case "chargers":
					color1 = 0x002244; //navy
					color2 = 0xffb612; //gold
					break;
				case "seahawks":
					color1 = 0x00338d; //blue
					color2 = 0x0085424; //green
					break;
				case "49ers":
					color1 = 0x97233f; //cardinal red
					color2 = 0x8e6e4d; //metallic gold
					break;
				case "rams":
					color1 = 0x002147; //millenium blue
					color2 = 0x95774d; //new century gold
					break;
				case "buccaneers":
					color1 = 0xa71930; //buccaneer red
					color2 = 0x665c4f; //pewter
					break;
				case "titans":
					color1 = 0x4b92db; //blue
					color2 = 0x002147; //navy
					break;
				case "redskins":
					color1 = 0x822433; //burgundy
					color2 = 0xffb612; //gold
					break;
			}			
			//cardinals, falcons, ravens, bills, panthers, bears, bengals, browns, cowboys, broncos, lions, packers, texans, colts, jaguars, chiefs, dolphins, vikings, patriots, saints, giants, jets, raiders, eagles, steelers, chargers, seahawks, 49ers, rams, buccaneers, titans, redskins
			
			
			//{"FirstName":"antonio","LastName":"zugno","City":"Rochester","State":"NY","FavoriteTeam":"packers"}
			userData = user;
			
			//first extract user preview image from 1280x960 camera image
			//we take wider than we need, then move it left 81 pixels... this to compensate for the right card
			//edge being overlayed ontop of the photo
			userImage = new BitmapData(800, 780);
			userImage.copyPixels(image, new Rectangle(240, 95, 800, 780), new Point( -35, 0));
			//end up with a 719 x 780 image
			
			var blur:BitmapData = new blurMask();//lib image
			
			var blurImage:BitmapData = new BitmapData(719, 780);
			blurImage.copyPixels(userImage, new Rectangle(0, 0, 719, 780), new Point(0, 0));
			var blurFilter:BlurFilter = new BlurFilter(22, 22, 2);
			blurImage.applyFilter(blurImage, new Rectangle(0, 0, 719, 780), new Point(0, 0), blurFilter);
			
			userImage.copyPixels(blurImage, new Rectangle(0, 0, 719, 780), new Point(0, 0), blur, new Point(0, 0), true);
			
			var snowB:BitmapData = new snow();//lib clip
			userImage.copyPixels(snowB, new Rectangle(0, 0, 719, 780), new Point(0, 0),null,null,true);
			
			var l:Loader = new Loader();
			l.contentLoaderInfo.addEventListener(Event.COMPLETE, logoLoaded, false, 0, true);
			l.load(new URLRequest(logoPath + team + "_160.png"));
			//logoLoaded();
		}
		
		
		private function logoLoaded(e:Event = null):void
		{
			if(logo){
				if (sidebar.contains(logo)) {
					sidebar.removeChild(logo);
				}
			}
			
			logo = Bitmap(e.target.content);
			logo.smoothing = true;
			
			sidebar.addChild(logo);
			logo.x = 55 + Math.floor((250 - logo.width) * .5);
			logo.y = 550 + Math.floor((230 - logo.height) * .5);
			
			card = new BitmapData(935, 780);
			card.copyPixels(userImage, new Rectangle(0, 0, userImage.width, userImage.height), new Point(0, 0));
			/*
			sidebar.fname.text = "";
			sidebar.lname.text = "";
			sidebar.city.text = "";
			*/
			//set fname,lname,city text in sidebar
			sidebar.fname.text = String(userData.FirstName).charAt(0).toUpperCase() + String(userData.FirstName).substr(1);
			sidebar.lname.text = String(userData.LastName).charAt(0).toUpperCase() + String(userData.LastName).substr(1);
			sidebar.city.text = String(userData.City).toUpperCase() + ", " + String(userData.State).toUpperCase();
			
			//Fit text
			var nameFormat:TextFormat = sidebar.lname.getTextFormat();
			var cityFormat:TextFormat = sidebar.city.getTextFormat();

			while(sidebar.lname.textWidth > 198){	
				nameFormat.size = int(nameFormat.size) - 1;
				sidebar.lname.setTextFormat(nameFormat);
			}
			sidebar.fname.setTextFormat(nameFormat);

			//be sure city is a little smaller
			cityFormat.size = Math.max(int(nameFormat.size) - 12, 12);
			sidebar.city.setTextFormat(cityFormat);

			sidebar.lname.y = sidebar.fname.y + sidebar.fname.textHeight - 6;
			sidebar.city.y = sidebar.lname.y + sidebar.lname.textHeight - 3;
			//Fit Text
			
			TweenMax.to(sidebar.barTop, 0, { colorTransform: { tint:color1, tintAmount:1 }} );
			TweenMax.to(sidebar.barBottom, 0, { colorTransform: { tint:color2, tintAmount:1 }} );
			
			var sidebarBMD:BitmapData = new BitmapData(sidebar.width, 782, true, 0x00000000);
			sidebarBMD.draw(sidebar, null, null, null, null, true);
			
			card.copyPixels(sidebarBMD, new Rectangle(0, 0, sidebar.width, sidebar.height), new Point(card.width - sidebar.width, -1),null,null,true);
			
			var n:BitmapData = new BitmapData(794, 662);
			var m:Matrix = new Matrix();
			m.scale(.8491978, .8491978);
			n.draw(card, m, null, null, null, true);
			
			previewImage = new Bitmap(n);
			
			if (container) {
				container.addChild(previewImage);
			}
			previewImage.x = 268;
			previewImage.y = 218;
			
			clip.btnRetake.addEventListener(MouseEvent.MOUSE_DOWN, retake, false, 0, true);
			clip.btnSave.addEventListener(MouseEvent.MOUSE_DOWN, save, false, 0, true);
			
			clip.alpha = 0;			
			TweenMax.to(clip, 1, { alpha:1 } );
		}
		
		/**
		 * gets the full size - 935 x 780 card image
		 * @return
		 */
		public function getCard():BitmapData
		{
			return card;
		}
		
		public function hide():void		
		{			
			clip.btnRetake.removeEventListener(MouseEvent.MOUSE_DOWN, retake);
			clip.btnSave.removeEventListener(MouseEvent.MOUSE_DOWN, save);
			TweenMax.to(clip, .5, { alpha:0, y:0, eaase:Back.easeIn, onComplete:killRetake } );
			if(previewImage){
				TweenMax.to(previewImage, .5, { alpha:0 } );
			}
		}
		
		
		private function killRetake():void
		{
			if (container) {
				if (container.contains(clip)) {
					container.removeChild(clip);
				}
				if(previewImage){
					if (container.contains(previewImage)) {
						container.removeChild(previewImage);
					}
				}
			}		
		}
		
		
		private function retake(e:MouseEvent):void
		{
			dispatchEvent(new Event(RETAKE));
		}
		
		
		private function save(e:MouseEvent):void
		{
			dispatchEvent(new Event(SAVE));
		}
	}
	
}