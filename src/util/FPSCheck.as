﻿package util {		import flash.events.TimerEvent;	import flash.events.Event;	import flash.utils.Timer;	public class FPSCheck {				private var f:int=0;		private var brain:Object;		private var timer:Timer;		public function FPSCheck(br) {						brain=br;			timer = new Timer (5000,1);			timer.addEventListener(TimerEvent.TIMER, getFPS);			timer.start();		}				public function main():void {						f++;		}				private function getFPS (ev) {						if (brain!=null) {								if (brain.dino!=null) {									brain.dino.addFPS ("",f/5,true);					brain.sys.MP.sendToRoom ("FR"+f/5);									}				remove();							}					}				public function remove () {						timer.stop();			timer.removeEventListener(TimerEvent.TIMER, getFPS);			timer=null;			brain.removeSYS2 ("fpsCheck");			brain=null;					}			}	}