package com.gmrmarketing.speed
{
	import fl.data.DataProvider;
	import fl.controls.*;
	import fl.containers.*;
	import fl.controls.listClasses.*;
	import fl.controls.dataGridClasses.*;
	import fl.controls.progressBarClasses.*;
	import fl.core.UIComponent;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import com.blurredistinction.validators.EmailValidator;
	import com.greensock.TweenLite;
	import com.gmrmarketing.utilities.SwearFilter;
	

	public class UserData extends MovieClip
	{
		private var makers:Array;
		private var carMakers:DataProvider;
		private var emVal:EmailValidator;
		private var swearFilter:SwearFilter;
		
		
		public function UserData()
		{
			emVal = new EmailValidator();
			swearFilter = new SwearFilter();
			
			makers = new Array({label:"not listed"},{label:"AC"},{label:"AM General"},{label:"AMC"},{label:"Abarth"},{label:"Abbott-Detroit"},{label:"Acura"},{label:"Aermacchi"},{label:"Airstream"},{label:"Alba"},{label:"Alfa Romeo"},{label:"Allard"},{label:"Allstate"},{label:"American"},{label:"American Austin"},{label:"American LaFrance"},{label:"Amilcar"},{label:"Amphicar"},{label:"Anglia"},{label:"Apollo"},{label:"Aprilia"},{label:"Ariel"},{label:"Arnolt-Bristol"},{label:"Arnolt-MG"},{label:"Aston Martin"},{label:"Astra"},{label:"Auburn"},{label:"Audi"},{label:"Austin"},{label:"Austin Bantam"},{label:"Austin-Healey"},{label:"Auto Union"},{label:"Autobianchi"},{label:"Autocar"},{label:"Avanti"},{label:"BMW"},{label:"BSA"},{label:"Baci"},{label:"Bantam"},{label:"Beck"},{label:"Bentley"},{label:"Benz"},{label:"Berkeley"},{label:"Bitter"},{label:"Bizzarrini"},{label:"Bluebird"},{label:"Bobsy"},{label:"Boss Hoss"},{label:"Brabham"},{label:"Brewster"},{label:"Bricklin"},{label:"Bristol"},{label:"Bugatti"},{label:"Buick"},{label:"CAV"},{label:"Cadillac"},{label:"Calthorpe"},{label:"Case"},{label:"Chalmers"},{label:"Checker"},{label:"Cheetah"},{label:"Chevrolet"},{label:"Chevron"},{label:"Chrysler"},{label:"Cisitalia"},{label:"Citroen"},{label:"Clenet"},{label:"Cleveland"},{label:"Club Car"},{label:"Coast"},{label:"Cobra"},{label:"Contemporary"},{label:"Continental"},{label:"Cooper"},{label:"Cooper-Monaco"},{label:"Cord"},{label:"Crosley"},{label:"Cushman"},{label:"DKW"},{label:"Daewoo"},{label:"Daimler"},{label:"Darracq"},{label:"Datsun"},{label:"Davis"},{label:"DeLorean"},{label:"DeSoto"},{label:"DeTomaso"},{label:"Delage"},{label:"Delahaye"},{label:"Denzel"},{label:"Detroit Electric"},{label:"Devin"},{label:"Diamond T"},{label:"Divco"},{label:"Dodge"},{label:"Dolson"},{label:"Dort"},{label:"Dragster"},{label:"Dual Ghia"},{label:"Ducati"},{label:"Duesenberg"},{label:"Earl"},{label:"Edsel"},{label:"Elden"},{label:"Electric Car Co"},{label:" LLC"},{label:"Elva"},{label:"Enzmann"},{label:"Essex"},{label:"Excalibur"},{label:"Facel"},{label:"Facel Vega"},{label:"Featherlite"},{label:"Federal"},{label:"Ferrari"},{label:"Fiat"},{label:"Fiat-Abarth"},{label:"Figoni et Falaschi"},{label:"Fina-Sport"},{label:"Flajole"},{label:"Flint"},{label:"Ford"},{label:"Fordson"},{label:"Formula"},{label:"Franklin"},{label:"Frazer"},{label:"Frontenac"},{label:"GEM"},{label:"GM"},{label:"GMC"},{label:"Gatsby"},{label:"Geo"},{label:"Ghia"},{label:"Ginetta"},{label:"Gobron-Brillie"},{label:"Goggomobil"},{label:"Graham"},{label:"Graham-Paige"},{label:"Griffith"},{label:"Gurney"},{label:"Harley-Davidson"},{label:"Haulmark"},{label:"Healey"},{label:"Henderson"},{label:"Henney"},{label:"Hillman"},{label:"Hispano-Suiza"},{label:"Honda"},{label:"Horch"},{label:"Hudson"},{label:"Humber"},{label:"Hummer"},{label:"Hupmobile"},{label:"Hyundai"},{label:"Imperial"},{label:"Indian"},{label:"Indy Race Cars"},{label:"Infiniti"},{label:"Intermeccanica"},{label:"International"},{label:"Invicta"},{label:"Iso"},{label:"Isotta-Fraschini"},{label:"Isuzu"},{label:"Italia"},{label:"Jaguar"},{label:"Jeep"},{label:"Jensen"},{label:"Jensen-Healey"},{label:"Jewett"},{label:"John Deere"},{label:"Johnson"},{label:"Kaiser"},{label:"Kaiser-Frazer"},{label:"Kawasaki"},{label:"Kenworth"},{label:"Kia"},{label:"Kingsley"},{label:"Kissel"},{label:"Kleiber"},{label:"Kougar"},{label:"Kurtis"},{label:"LaDawri"},{label:"LaSalle"},{label:"Lafayette"},{label:"Lagonda"},{label:"Lamborghini"},{label:"Lancia"},{label:"Land Rover"},{label:"LeGrand"},{label:"Legends"},{label:"Lexus"},{label:"Lincoln"},{label:"Lister"},{label:"Locomobile"},{label:"Lola"},{label:"London"},{label:"Lotus"},{label:"Lozier"},{label:"Lucenti"},{label:"MG"},{label:"Mack"},{label:"Marmon"},{label:"Marquette"},{label:"Maserati"},{label:"Maxwell"},{label:"Maybach"},{label:"Mazda"},{label:"McCormick"},{label:"McLaren"},{label:"Mercedes-Benz"},{label:"Mercer"},{label:"Mercury"},{label:"Merkur"},{label:"Messerschmitt"},{label:"Metropolitan"},{label:"Metz"},{label:"Midland"},{label:"Mini"},{label:"Mitchell"},{label:"Mitsubishi"},{label:"Mixed"},{label:"Moline"},{label:"Moretti"},{label:"Morgan"},{label:"Morris"},{label:"Mosler"},{label:"Mustang"},{label:"Nash"},{label:"Nash-Healey"},{label:"Nissan"},{label:"Norton"},{label:"OSCA"},{label:"Oakland"},{label:"Oldsmobile"},{label:"Opel"},{label:"Overland"},{label:"Pace American"},{label:"Packard"},{label:"Pagani"},{label:"Paige"},{label:"Panhard"},{label:"Panoz"},{label:"Panther"},{label:"Peerless"},{label:"Pegaso"},{label:"Peugeot"},{label:"Phoenix"},{label:"Piaggio"},{label:"Pierce"},{label:"Pierce-Arrow"},{label:"Plymouth"},{label:"Pontiac"},{label:"Pope-Waverly"},{label:"Porsche"},{label:"Prevost"},{label:"Puma"},{label:"RUF"},{label:"Radical"},{label:"Rambler"},{label:"Range Rover"},{label:"Rauch and Lang"},{label:"Reliable Dayton"},{label:"Reliant"},{label:"Renault"},{label:"Reo"},{label:"Reynard"},{label:"Riley"},{label:"Rolls-Royce"},{label:"Rover"},{label:"Saab"},{label:"Saleen"},{label:"Saturn"},{label:"Shadow"},{label:"Shay"},{label:"Shelby"},{label:"Shirdlu"},{label:"Siata"},{label:"Silver Streak"},{label:"Singer"},{label:"Smart"},{label:"Sprint"},{label:"Stanley"},{label:"Stanley Steamer"},{label:"Star"},{label:"Starcraft"},{label:"Stearns-Knight"},{label:"Sterling"},{label:"Stevens-Duryea"},{label:"Stoddard-Dayton"},{label:"Studebaker"},{label:"Stutz"},{label:"Subaru"},{label:"Sunbeam"},{label:"Superformance"},{label:"Suzuki"},{label:"TVR"},{label:"Talbot-Lago"},{label:"Tatra"},{label:"Templar"},{label:"Terraplane"},{label:"Thiokol"},{label:"Thomas Flyer"},{label:"Tiffany"},{label:"Tojeiro"},{label:"Toledo"},{label:"Toyota"},{label:"Trident"},{label:"Triumph"},{label:"Turner"},{label:"Unspecified"},{label:"Vanden Plas"},{label:"Vanguard"},{label:"Vauxhall"},{label:"Velie"},{label:"Veritas"},{label:"Vespa"},{label:"Victoria"},{label:"Victory"},{label:"Voisin"},{label:"Volkswagen"},{label:"Volvo"},{label:"Walker"},{label:"Wanderer"},{label:"Ward LaFrance"},{label:"Waverly Electric"},{label:"Whippet"},{label:"White"},{label:"Whizzer"},{label:"Willys"},{label:"Willys-Knight"},{label:"Willys-Overland"},{label:"Wilton"},{label:"Winton"},{label:"Woods"},{label:"Yamaha"},{label:"Yugo"},{label:"ZIS"},{label:"Zimmer "} );
			carMakers = new DataProvider(makers);
			carMake.dataProvider = carMakers;
			
			carYear.maxChars = 4;
			carYear.restrict = "0-9";
			
			var fieldRestrict:String = "a-zA-Z0-9' &%\\-@.";
			
			firstName.tabIndex = 1;
			firstName.restrict = fieldRestrict;
			
			lastName.tabIndex = 2;
			lastName.restrict = fieldRestrict;
			
			email.tabIndex = 3;
			email.restrict = fieldRestrict;
			
			carName.tabIndex = 4;
			carName.maxChars = 18;
			carName.restrict = fieldRestrict;
			
			carYear.tabIndex = 5;
			
			carModel.tabIndex = 6;
			carModel.maxChars = 14;
			carModel.restrict = fieldRestrict;
			
			restoreTime.tabIndex = 7;
			restoreTime.maxChars = 4;
			restoreTime.restrict = "0-9";
			
			carMake.tabIndex = 0;
			btnNext.tabIndex = 0;
			
			addListeners();
			startText.theText.text = "Start your custom trading card";
			
			addEventListener(Event.REMOVED_FROM_STAGE, removeListeners, false, 0, true);
		}
		
		public function editMode():void
		{
			startText.theText.text = "Edit your custom trading card";
		}
		
		public function addListeners():void
		{
			hideGlow();
			btnNext.buttonMode = true;
			btnNext.addEventListener(MouseEvent.CLICK, validate, false, 0, true);
			btnNext.addEventListener(MouseEvent.MOUSE_OVER, showGlow, false, 0, true);
			btnNext.addEventListener(MouseEvent.MOUSE_OUT, hideGlow, false, 0, true);
		}
		
		public function getData():Object 
		{
			var o:Object = new Object();
			o.firstName = firstName.text;
			o.lastName = lastName.text;
			o.email = email.text;
			o.carName = carName.text;
			o.carYear = carYear.text;
			o.carMake = carMake.selectedItem.label;
			o.carModel = carModel.text;
			o.restoreTime = restoreTime.text;
			
			return o;
		}
		
		
		private function showGlow(e:MouseEvent):void
		{
			TweenLite.to(btnNext.redArrow, .5, { alpha:1 } );
		}
		
		
		private function hideGlow(e:MouseEvent = null):void
		{
			TweenLite.to(btnNext.redArrow, .5, { alpha:0 } );
		}
		
		
		private function removeListeners(e:Event):void
		{
			btnNext.removeEventListener(MouseEvent.CLICK, validate);
			btnNext.removeEventListener(MouseEvent.MOUSE_OVER, showGlow);
			btnNext.removeEventListener(MouseEvent.MOUSE_OUT, hideGlow);			
			removeEventListener(Event.REMOVED_FROM_STAGE, removeListeners);
		}
		
		
		private function validate(e:MouseEvent):void
		{			
			if (firstName.text.length == 0) {
				showError("Please enter your first name");
				return;
			}
			if (swearFilter.containsSwear(firstName.text, "dick")) {
				firstName.text = "";
				showError("No profanity is allowed");
				return;
			}
			if (lastName.text.length == 0) {
				showError("Please enter your last name");
				return;
			}
			if (swearFilter.containsSwear(lastName.text)) {
				lastName.text = "";
				showError("No profanity is allowed");
				return;
			}
			if (!emVal.validate(email.text)) {
				showError("Please enter a valid email address");
				return;
			}
			if (carName.text.length == 0) {
				showError("Please enter a car name");
				return;
			}
			if (swearFilter.containsSwear(carName.text)) {
				carName.text = "";
				showError("No profanity is allowed");
				return;
			}
			if (carYear.text.length != 4) {
				showError("Please enter the full car year");
				return;
			}
			if (carModel.text.length == 0) {
				showError("Please enter the car model");
				return;
			}
			if (swearFilter.containsSwear(carModel.text)) {
				carModel.text = "";
				showError("No profanity is allowed");
				return;
			}
			if (restoreTime.text.length == 0) {
				showError("Please enter the restoration time");
				return;
			}
			
			dispatchEvent(new Event("userDataEntered"));
		}		
		
		
		private function showError(msg:String):void
		{
			errorMessage.text = msg;
			errorMessage.alpha = 1;
			TweenLite.to(errorMessage, 2, { alpha:0, delay:2 } );
		}
	}
	
}