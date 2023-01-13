﻿package supers {		import flash.geom.Point;		public class Circle {		public var pos:Point;   	// position		public var o:Object;   	    // data object		public var ph:Object;		// physics data		public var brain:Object; 	// ref to brain		public var roomA:Array;		// current room array		public var roomID:String;	// current room		public var inter:Boolean=true;		public var big:Boolean=false;	//circle check		public var NN:Boolean=false;	//near near var?				// shortcuts		private var rnd;		private var randm;				//////////////////////////////////////////////////		//////////////////////////////////////////////////				// constructor		public function Circle () {						// init shortcuts			rnd = Math.round;			randm = Math.random;					}				//////////////////////////////////////////////////		//////////////////////////////////////////////////				// initialize		public function init(obj,br):void {						//init vars			o = obj;						//brain ref			brain = br;						//position			pos = new Point (o.px,o.py);						//current room			roomA = new Array (Math.ceil(o.px/brain.sDim.w),Math.ceil(o.py/brain.sDim.h));			roomID = "r"+roomA[0]+"_"+roomA[1];						//physics data			ph = { }					}				// delete this object reference in the brain lib   	    public function deleteObj():void {						o.ex=false;			inter=false;			brain.deleteObj(this);					}				public function nulls () {						for (var p in ph) { delete ph[p] }			if (!o.rData&&!o.addToRD)  { for (var oo in o) { delete o[oo] } }						pos=null;			o=null;			ph=null			roomA=null;			brain=null;			rnd=null;			randm=null;					}				// remove the roomData that contains this object		public function deleteData():void {						brain.deleteData(roomID,o.id);					}				// delete all		public function deleteAll() {						if (o.rData) { brain.deleteData(roomID,o.id) }			deleteObj();					}				// this item's room has been deleted		public function roomDeleted():void {						deleteObj();					}				// room added (not relevant to circles but needed to avoid errors)		public function roomAdded():void {					}				//final actions		public function finalActions():void {											}				////////////////////////////////////////////////////////////				// give a rounded random number		public function rand(min:int, max:int):int {						return (rnd(randm()*(max-min))+min);					}		// give an unrounded random number		public function rand2(min:Number, max:Number):Number {						return (randm()*(max-min))+min;					}			}			}