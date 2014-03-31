package com.gmrmarketing.hp.spinner
{

	public class DefaultConfig
	{
		public function DefaultConfig()
		{
			
		}
		
		public static function getConfig():XML
		{
			var defaultConfig:XML = <data>
  <backgroundImage>SATC2_SpinGame_bg.png</backgroundImage>
  <spinnerImage xLoc="434" yLoc="380">hpspinner.png</spinnerImage>
  <spinnerCenter>hpLogo.png</spinnerCenter>
  <dialogImage>satc_dialog.png</dialogImage>
  <pointerLocation x="-135" y="240"/>
  <showMousePointer>false</showMousePointer>
  <numberOfSlices>8</numberOfSlices>
  <spinnerShadow>true</spinnerShadow>
  <handShadow>true</handShadow>
  <prizeTextShadow>true</prizeTextShadow>
  <dialogShadow>true</dialogShadow>
  <winTextShadow>true</winTextShadow>
  <fontPackage leading="10">font_futuraStd.swf</fontPackage>
  <bgParticles>false</bgParticles>
  <normalFriction>.96</normalFriction>
  <pointerFriction>.93</pointerFriction>
  <dialogAlpha>.94</dialogAlpha>
  <incompleteTurn color="ffffff">Whoops!
The wheel did not make a full turn. Please try again</incompleteTurn>
  <prizes textEdgeBuffer="35">
    <slice>
      <prizeText twoLine="no" addAngle="0" color="ffffff">Flash Drive</prizeText>
      <winText color="ffffff">Winner!
You won a HP 1GB USB Flash Drive</winText>
    </slice>
    <slice>
      <prizeText twoLine="no" addAngle="0" color="ffffff">Sorry</prizeText>
      <winText color="ffffff">Sorry you didn't win this time</winText>
    </slice>
    <slice>
      <prizeText twoLine="no" addAngle="0" color="ffffff">T-Shirt</prizeText>
      <winText color="ffffff">Winner!
You won an HP T-Shirt</winText>
    </slice>
    <slice>
      <prizeText twoLine="no" addAngle="0" color="ffffff">Sorry</prizeText>
      <winText color="ffffff">Sorry you didn't win this time</winText>
    </slice>
    <slice>
      <prizeText twoLine="no" addAngle="0" color="ffffff">Tote</prizeText>
      <winText color="ffffff">Winner!
You won an HP Tote</winText>
    </slice>
    <slice>
      <prizeText twoLine="no" addAngle="0" color="ffffff">Sorry</prizeText>
      <winText color="ffffff">Sorry you didn't win this time</winText>
    </slice>
    <slice>
      <prizeText twoLine="no" addAngle="0" color="ffffff">Spin Again</prizeText>
      <winText color="ffffff">Please spin again</winText>
    </slice>
    <slice>
      <prizeText twoLine="no" addAngle="0" color="ffffff">Sorry</prizeText>
      <winText color="ffffff">Sorry you didn't win this time</winText>
    </slice>
    <slice>
      <prizeText twoLine="no" addAngle="0" color="ffffff">Sorry</prizeText>
      <winText color="ffffff">Sorry you didn't win this time</winText>
    </slice>
    <slice>
      <prizeText twoLine="no" addAngle="0" color="ffffff">Sorry</prizeText>
      <winText color="ffffff">Sorry you didn't win this time</winText>
    </slice>
    <slice>
      <prizeText twoLine="no" addAngle="0" color="ffffff">Sorry</prizeText>
      <winText color="ffffff">Sorry you didn't win this time</winText>
    </slice>
    <slice>
      <prizeText twoLine="no" addAngle="0" color="ffffff">Sorry</prizeText>
      <winText color="ffffff">Sorry you didn't win this time</winText>
    </slice>
  </prizes>
</data>;
									
			return defaultConfig;
		}
		
	}
	
}