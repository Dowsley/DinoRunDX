﻿package control
{
	
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import base.Brain;
	
	public class Keys
	{
		
		private var keyData:Array;
		private var keyData2:Array;
		private var targ:Object;
		private var brain:Brain;
		private var command:Boolean;
		
		public function Keys(t, b)
		{
			
			targ = t;
			brain = b;
			
			//add listeners
			targ.addEventListener(KeyboardEvent.KEY_DOWN, keyD);
			targ.addEventListener(KeyboardEvent.KEY_UP, keyU);
			
			//init keyData
			keyData = [];
		
		}
		
		public function addKeys(o)
		{
			
			keyData.push(o);
		
		}
		
		public function resetKeys()
		{
			
			keyData = [];
		
		}
		
		public function pauseKeys()
		{
			
			keyData2 = keyData.slice();
			keyData.splice(0, 1);
		
		}
		
		public function unpauseKeys()
		{
			
			keyData = keyData2.slice();
			keyData2 = [];
		
		}
		
		private function keyD(event:KeyboardEvent):void
		{
			
			//Brain.log(event.keyCode);
			
			if (event.keyCode == 27)
			{
				event.preventDefault();
			}
			
			if (event.ctrlKey)
			{
				if (event.keyCode == Keyboard.F)
				{// 
					brain.toggleFullScreen();
				}
				if (event.keyCode == Keyboard.L)
				{// 
					brain.toggleLog();
				}
				if (event.keyCode == Keyboard.E)
				{// 
					brain.dumpErrors();
				}
				if (event.keyCode == Keyboard.X)
				{// 
					brain.clearErrors();
				}
				if (event.keyCode == Keyboard.A)
				{// 
					brain.clearCheevos();
				}
				if (event.keyCode == Keyboard.S && event.shiftKey)
				{// 
					brain.sys2.stats.overrideGS();
				}
				return;
			}
			
			if (Brain.freeRun && (brain.gState == "game" || brain.gState == "win" || brain.gState == "endLevel" || Brain.escaped))
			{
				
				if (Brain.talkVisible)
				{
					if (event.keyCode == Keyboard.ENTER)
					{
						brain.freeRun_Talk_Submit();
					}
				}
				else
				{
					switch (event.keyCode)
					{
					case Keyboard.R: 
						brain.freeRun_Rain();
						break;
					case Keyboard.Y: 
						brain.freeRun_Dactyl(event.shiftKey);
						break;
					case Keyboard.O: 
						brain.freeRun_Meteorite(event.shiftKey);
						break;
					case Keyboard.B: 
						brain.freeRun_Boulder(event.shiftKey);
						break;
					case Keyboard.Z: 
						brain.freeRun_Stego(event.shiftKey);
						break;
					case Keyboard.X: 
						brain.freeRun_Doom();
						break;
					case Keyboard.TAB: 
						brain.freeRun_Talk();
						break;
					case Keyboard.P: 
						brain.freeRun_Para(event.shiftKey);
						break;
					case Keyboard.L: 
						brain.freeRun_Lizard();
						break;
					case Keyboard.C: 
						brain.freeRun_Cera(event.shiftKey);
						break;
					case Keyboard.H: 
						brain.freeRun_Wave();
						break;
					case Keyboard.T: 
						brain.freeRun_Sit();
						break;
					case Keyboard.G: 
						brain.freeRun_Gore();
						break;
					case Keyboard.I: 
						brain.freeRun_Info();
						break;
						/*case Keyboard.R: brain.freeRun_Rain(); break;
						   case Keyboard.R: brain.freeRun_Rain(); break;
						   case Keyboard.R: brain.freeRun_Rain(); break;
						   case Keyboard.R: brain.freeRun_Rain(); break;*/
					}
					
				}
				
			}
			
			keyDFunc(event.keyCode);
		
		}
		
		public function keyDFunc(code:int):void
		{
			for each (var keyO:Object in keyData)
			{
				
				if (keyO.exeD)
				{
					
					var vals:Object = keyO.vals;
					for (var i in vals)
					{
						
						if (vals[i].indexOf(code) != -1)
						{
							
							keyO.exe["keyD_" + i]();
							
						}
						
					}
					
				}
				
			}
		}
		
		private function canPauseWithSpace():Boolean
		{
			for each (var keyO:Object in keyData)
			{
				
				var vals:Object = keyO.vals;
				for (var i in vals)
				{
					
					if (vals[i].indexOf(32) != -1 && i == "P")
					{
						
						return true;
						
					}
					
				}
				
			}
			
			return false;
		}
		
		private function keyU(event:KeyboardEvent):void
		{
			
			if (Brain.talkVisible && event.keyCode == Keyboard.ESCAPE)
			{
				brain.interF.hideSpeech();
				return;
			}
			
			if (event.keyCode == Keyboard.ESCAPE && (brain.gState == "win" || brain.gState == "extinct"))
			{
				brain.keyU_R();
				return;
			}
			
			keyUFunc(event.keyCode);
		
		}
		
		public function keyUFunc(code:int):void
		{
			for each (var keyO:Object in keyData)
			{
				
				if (keyO.exeU)
				{
					
					var vals:Object = keyO.vals;
					for (var i in vals)
					{
						
						if (vals[i].indexOf(code) != -1)
						{
							
							keyO.exe["keyU_" + i]();
							
						}
						
					}
					
				}
				
			}
		}
	
	}

}