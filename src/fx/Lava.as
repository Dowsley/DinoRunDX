﻿package fx {		import supers.Circle;		public class Lava extends Circle {				public function Lava (o,br):void {			//init			super.init (o,br);						//extra physics properties			ph.sh = "circ";				//shape			ph.r = (o.lvl=="X")?240:80;	//radius			big=true;						}				public function main ():void {					}				public function hit (obj:Object) {						var vel=obj.vel;			var vv=Math.round(Math.sqrt((vel.x*vel.x)+(vel.y*vel.y)))			var l=rand2(0,vv/2);			for (var i:uint=1; i<l; i++) { brain.create ({nam:"LavaBit", px:pos.x+rand2(-20,20), py:pos.y, vx:rand2(vel.x-6,vel.x+6), vy:rand(-3*vv,0), depth:["world","main"]}) }					}											}	}