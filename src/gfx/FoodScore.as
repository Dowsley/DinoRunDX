﻿package gfx {		import flash.display.MovieClip;		import fx.ColorChange;		import supers.FX;		public class FoodScore extends FX {				private var valCC:ColorChange;		private var BirdFGColors:Array = [[255,255,255],[255,255,255],[0,255,255],[0,255,0],[0,0,255]];		private var LizGColors:Array = [[255,255,255],[120,255,120],[0,255,0],[0,255,120],[0,120,255]];		private var LizOColors:Array = [[255,255,255],[255,200,120],[255,255,0],[255,120,0],[255,0,0]];		private var LizPColors:Array = [[255,255,255],[100,50,150],[255,0,255],[0,0,255],[0,255,255]];		private var RunnerColors:Array = [[255,255,255],[255,120,120],[255,0,0],[255,120,0],[255,0,255]];		private var WormColors:Array = [[255,255,255],[255,120,120],[255,0,0],[255,120,0],[255,0,255]];		private var FishColors:Array = [[255,255,255],[255,200,100],[255,255,0],[255,0,0],[255,120,0]];		private var StegoColors:Array = [[255,255,255],[255,120,120],[255,0,0],[255,120,0],[255,0,255]];		private var CeraColors:Array = [[255,255,255],[120,255,120],[0,255,0],[0,255,120],[0,120,255]];		private var ParaColors:Array = [[255,255,255],[255,120,120],[255,0,0],[255,120,0],[255,0,255]];		private var a:Number;		private var d:int;		private var dino:Object;		private var yA:Number=0;		private var xA:Number=0;				override public function nulls() {						super.nulls();			dino=null;			valCC.nulls();			valCC=null;			BirdFGColors=null;			LizGColors=null;			LizOColors=null;			LizPColors=null;			RunnerColors=null;			WormColors=null;			FishColors=null;			StegoColors=null;			CeraColors=null;			ParaColors=null;					}				public var scoreVal:MovieClip;				public function FoodScore (o,br):void {						assignGFX(new _FoodScore);			scoreVal = graphic.scoreVal;			init (o,br,this);						//egg value			scoreVal.val.text="+"+brain.sys2.stats.foodVal;						valCC = new ColorChange (scoreVal);			d=0;			a=1.5;						dino=brain.dino;			this.y=dino.y;						}				public function main ():void {						//run functions common to all FX			mainFX ();						//flash and fade score val			d++;			if (d==2) {								d=0;				a-=.04;				var cl=this[o.foodTyp+"Colors"][rand(0,3)]				valCC.cChange ([cl[0],cl[1],cl[2],0,0,0,a]);							}						//position			yA-=.5;			xA-=dino.vel.x/5;			this.y=dino.y+yA;			this.x=dino.x+xA;					}			}	}