﻿package fx {		import supers.Circle;		public class Bones extends Circle {				public var bc:Boolean=false;				public function Bones (o,br):void {						//init			super.init (o,br);						//extra physics properties			ph.sh = "circ";		//shape			ph.r = 30;			//radius						}				public function main ():void {					}				public function hit (obj:Object) {						var vel=obj.vel;			var vv=Math.round(Math.sqrt((vel.x*vel.x)+(vel.y*vel.y)))			var l=rand(0,vv/4);			for (var i:uint=1; i<l; i++) { brain.create ({nam:"Bone", px:pos.x+rand2(-20,20), py:pos.y, vx:rand2(vel.x-6,vel.x+6), vy:rand(-2*vv,0), depth:["world","main"]}) }						if (!bc) {								bc=true;				brain.sys.audio.ply ("bone"+rand(1,4),.25,false);								if (brain.S.mod!="MP") {										var val:int=rand(3,6);					brain.sys2.stats.addBones (val);					brain.create ( {nam:"ScoreFloat", px:o.px, py:o.py, val:val, depth:["world","main"]} )									}							}					}				override public function roomDeleted():void {						if (bc) { deleteData() }			deleteObj();					}	}	}