﻿package fx {		public class BGRed {				private var c:uint;		private var cMax:uint;		private var mid:Number;		private var m:Number;		private var inc:Number;		private var brain:Object;		private var d:String;				public function BGRed (brain:Object,d):void {						this.d=d;			this.cMax=(d=="bg")?brain.rand(25,50):brain.rand(40,100);			mid=cMax*.1;			m=1;			c=0;			this.brain=brain;		}				public function main () {						c++;			inc=(c<mid)?-1/mid:1/(cMax-mid);			m+=inc;			if (m>1) {m=1};			brain.sky.cc.cChange ([0,0,0,1,m,m,1]);			if (d=="fg") { brain.worldBG.cc.cChange ([0,0,0,1,m,m,1]) }						//end?			if (c>=cMax) {  brain.worldBG.cc.cChange ([0,0,0,1,1,1,1]) }			if (c>=cMax+20) { remove() }					}				public function remove () {						brain.removeSYS2 ("bgRed"); 			brain=null;					}	}	}