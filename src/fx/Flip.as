﻿package fx {		import flash.display.MovieClip;		import base.Brain;
		public class Flip {				private var clip:MovieClip;		private var rollI:int;		private var rollC:int=-1;		private var ang:Number=0;		private var vv:Number;		private var brain:Object;				public function Flip (clip:MovieClip,vv,br:Object):void {						this.clip=clip;			this.vv=vv;			clip.vel.x+=clip.rand(-.75*vv,.75*vv);			clip.vel.y+=clip.rand(-1*vv,-3);			if (clip.vel.y<-10) { clip.vel.y=-10 }			clip.inter=false;			rollI=clip.rand(0,1);			brain = br;		}				public function main () {						if (!brain)				return;						clip.vel.x*=.98;						//roll it			rollC++;			if (rollC>rollI) {								rollC=-1;				ang=(clip.vel.x>0)?ang-15:ang+15;				if (ang<0) { ang=345 }				if (ang>345) { ang=0 }				clip.master.body.gotoAndStop ("flip"+ang);							}						if (brain.S.sl && brain.S.mod!="MP") {				brain.create ({nam:"Blood", px:clip.x+brain.rand(-5,5), py:clip.y+brain.rand(-5,5), vx:brain.rand(-1,1), vy:brain.rand(-2,0), depth:["world","main"]})			}						if (clip.y-clip.brain.dino.y>300) { remove() }											}				public function remove () {						clip.removeSYS ("flip"); 			clip.deleteAll(); 			clip=null;			brain = null;					}			}	}