package {
	import flash.display.Sprite;
	import flash.display.StageScaleMode;
	import com.mapquest.tilemap.*;
	//import com.adobe.viewsource.ViewSource;


	public class AS3Map extends Sprite {
		
	public function AS3Map():void 
	{
	// create a new TileMap object, passing your platform key
	var map:TileMap = new TileMap("Fmjtd%7Cluua2quzn9%2C20%3Do5-hzys1");

	//set the size of the map
	map.size = new Size(600, 450);

	//add the map to the sprite.
	addChild(map);
	}
}
}