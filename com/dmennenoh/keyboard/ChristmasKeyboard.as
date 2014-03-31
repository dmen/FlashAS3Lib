package com.dmennenoh.keyboard
{
	
	
	public class ChristmasKeyboard
	{
		private var xml:XML;
		
		public function ChristmasKeyboard()
		{
			xml = 
<data>
  <keyboard>
    <setup>
      <mainbackground w="952" h="301" type="flat" gradienttype="smooth" r="24" color1="0x336699" color2="0x000066" borderWidth="1" borderColor="0x000000"/>
      <keybackground type="flat" gradienttype="smooth" r="20" color1="0xededed" color2="0xededed" borderWidth="1" borderColor="0x000000"/>
      <highlight color="0x0066ff" startAlpha="1"/>
      <font size="13" color="0x333333" name="arial"/>
      <keyTextNudge x="2" y="2" shiftX="1" shiftY="20"/>
    </setup>
    <keys>
      <key w="62" h="62" val="1" shiftval="!" showshiftval="true" x="20" y="20"/>
      <key w="62" h="62" val="2" shiftval="@" showshiftval="true" x="86" y="20"/>
      <key w="62" h="62" val="3" shiftval="#" showshiftval="true" x="152" y="20"/>
      <key w="62" h="62" val="4" shiftval="$" showshiftval="true" x="218" y="20"/>
      <key w="62" h="62" val="5" shiftval="%" showshiftval="true" x="284" y="20"/>
      <key w="62" h="62" val="6" shiftval="^" showshiftval="true" x="350" y="20"/>
      <key w="62" h="62" val="7" shiftval="&amp;" showshiftval="true" x="416" y="20"/>
      <key w="62" h="62" val="8" shiftval="*" showshiftval="true" x="482" y="20"/>
      <key w="62" h="62" val="9" shiftval="(" showshiftval="true" x="548" y="20"/>
      <key w="62" h="62" val="0" shiftval=")" showshiftval="true" x="614" y="20"/>
      <key w="62" h="62" val="-" shiftval="_" showshiftval="true" x="680" y="20"/>
      <key w="62" h="62" val="=" shiftval="+" showshiftval="true" x="746" y="20"/>
      <key w="120" h="62" val="Backspace" shiftval="Backspace" showshiftval="false" x="812" y="20"/>
      <key w="62" h="62" val="q" shiftval="Q" showshiftval="false" x="45" y="86"/>
      <key w="62" h="62" val="w" shiftval="W" showshiftval="false" x="111" y="86"/>
      <key w="62" h="62" val="e" shiftval="E" showshiftval="false" x="177" y="86"/>
      <key w="62" h="62" val="r" shiftval="R" showshiftval="false" x="243" y="86"/>
      <key w="62" h="62" val="t" shiftval="T" showshiftval="false" x="309" y="86"/>
      <key w="62" h="62" val="y" shiftval="Y" showshiftval="false" x="375" y="86"/>
      <key w="62" h="62" val="u" shiftval="U" showshiftval="false" x="441" y="86"/>
      <key w="62" h="62" val="i" shiftval="I" showshiftval="false" x="507" y="86"/>
      <key w="62" h="62" val="o" shiftval="O" showshiftval="false" x="573" y="86"/>
      <key w="62" h="62" val="p" shiftval="P" showshiftval="false" x="639" y="86"/>
      <key w="62" h="62" val="@" shiftval="@" showshiftval="false" x="706" y="86"/>
      <key w="120" h="62" val=".com" shiftval=".com" showshiftval="false" x="773" y="86"/>
      <key w="62" h="62" val="a" shiftval="A" showshiftval="false" x="70" y="152"/>
      <key w="62" h="62" val="s" shiftval="S" showshiftval="false" x="136" y="152"/>
      <key w="62" h="62" val="d" shiftval="D" showshiftval="false" x="202" y="152"/>
      <key w="62" h="62" val="f" shiftval="F" showshiftval="false" x="268" y="152"/>
      <key w="62" h="62" val="g" shiftval="G" showshiftval="false" x="334" y="152"/>
      <key w="62" h="62" val="h" shiftval="H" showshiftval="false" x="400" y="152"/>
      <key w="62" h="62" val="j" shiftval="J" showshiftval="false" x="466" y="152"/>
      <key w="62" h="62" val="k" shiftval="K" showshiftval="false" x="532" y="152"/>
      <key w="62" h="62" val="l" shiftval="L" showshiftval="false" x="598" y="152"/>
      <key w="62" h="62" val="'" shiftval="'" showshiftval="false" x="665" y="152"/>
      <key w="120" h="62" val="Submit" shiftval="Submit" showshiftval="false" x="732" y="152" color2="0x000000" type="flat" gradienttype="tight" color1="0x00cc00"/>
      <key w="120" h="62" val="Shift" shiftval="Shift" showshiftval="false" x="40" y="219"/>
      <key w="62" h="62" val="z" shiftval="Z" showshiftval="false" x="164" y="219"/>
      <key w="62" h="62" val="x" shiftval="X" showshiftval="false" x="230" y="219"/>
      <key w="62" h="62" val="c" shiftval="C" showshiftval="false" x="296" y="219"/>
      <key w="62" h="62" val="v" shiftval="V" showshiftval="false" x="362" y="219"/>
      <key w="62" h="62" val="b" shiftval="B" showshiftval="false" x="428" y="219"/>
      <key w="62" h="62" val="n" shiftval="N" showshiftval="false" x="494" y="219"/>
      <key w="62" h="62" val="m" shiftval="M" showshiftval="false" x="561" y="219"/>
      <key w="62" h="62" val="," shiftval="&lt;" showshiftval="false" x="628" y="219"/>
      <key w="62" h="62" val="." shiftval=">" showshiftval="false" x="695" y="219"/>
      <key w="167" h="62" val="@gmrmarketing.com" shiftval="@gmrmarketing.com" showshiftval="false" x="763" y="219"/>
    </keys>
  </keyboard>
</data>
		}
		
		public function getXML():XML
		{
			return xml;
		}
		
	}
	
}