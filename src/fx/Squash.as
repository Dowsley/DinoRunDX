﻿package fx {		import flash.display.MovieClip;		public class Squash {				private var clip:MovieClip;		private var c:uint=0;				public function Squash (clip:MovieClip):void {						this.clip=clip;			//clip.ph.r-=9;						clip.app=clip.baseApp="squa";					}				public function main () {						c++;									//remove?			if (c>=18) {								remove();							} else {								clip.accelMax=0;							}					}				public function remove () {						if (clip.accelMaxBase<.9) { clip.accelMaxBase=.9 }			clip.accelMax=clip.accelMaxBase;			clip.velXMax=14*clip.accelMax;			clip.app=clip.baseApp="";			clip.removeSYS ("squash");			clip=null;					}			}	}