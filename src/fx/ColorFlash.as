﻿package fx {		import flash.display.MovieClip;	import flash.geom.ColorTransform;		public class ColorFlash {				private var clip:MovieClip;		private var ct:ColorTransform;		private var cData:Object;		private var cv:Object;		private var endF:String;				public function ColorFlash (clip:MovieClip,cData:Array,endF:String):void {						this.clip=clip;			this.cData=cData;			this.endF=endF;			ct = clip.transform.colorTransform;						initCV();									}				private function initCV () {						cv={								cnt:0,				m:cData[0][2],				ro:cData[0][0][0],				roI:(cData[0][1][0]-cData[0][0][0])/cData[0][2],				go:cData[0][0][1],				goI:(cData[0][1][1]-cData[0][0][1])/cData[0][2],				bo:cData[0][0][2],				boI:(cData[0][1][2]-cData[0][0][2])/cData[0][2],				rm:cData[0][0][3],				rmI:(cData[0][1][3]-cData[0][0][3])/cData[0][2],				gm:cData[0][0][4],				gmI:(cData[0][1][4]-cData[0][0][4])/cData[0][2],				bm:cData[0][0][5],				bmI:(cData[0][1][5]-cData[0][0][5])/cData[0][2],				am:cData[0][0][6],				amI:(cData[0][1][6]-cData[0][0][6])/cData[0][2]							}					}				public function main () {						ct.redOffset = cv.ro+cv.roI*cv.cnt;			ct.greenOffset = cv.go+cv.goI*cv.cnt;			ct.blueOffset = cv.bo+cv.boI*cv.cnt;			ct.redMultiplier = cv.rm+cv.rmI*cv.cnt;			ct.greenMultiplier = cv.gm+cv.gmI*cv.cnt;			ct.blueMultiplier = cv.bm+cv.bmI*cv.cnt;			ct.alphaMultiplier = cv.am+cv.amI*cv.cnt;			clip.transform.colorTransform = ct;						cv.cnt++;			if (cv.cnt>cv.m) {								cData.splice(0,1);				if (cData.length==0) {										remove();					if (endF!="") { clip[endF]()  }									} else {										initCV();									}							}					}				public function remove () {						clip.removeSYS ("colorFlash");			clip = null;			ct = null;			cData = null;			cv = null;					}			}	}