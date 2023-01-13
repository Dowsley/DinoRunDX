﻿package base {		import flash.display.DisplayObject;	import flash.display.MovieClip;	import flash.display.Sprite;		import datas.VectorData;		import fx.ColorChange;		import util.WorldFactory;
		public class World extends Sprite {				private var brain:Brain;	//ref to brain		private var factory:WorldFactory;	//world factory		public  var cWorld:String;	//current world		public  var cRooms:Array;	//current visible rooms		//public  var rData:Object;	//ref to room data		public  var sArr:Object;	//how screens are arranged for this world		public var xNum:uint;		//num of screens x		public var yNum:uint;		//num of screens y		public var shakeMag:Number=0;		public var shakeC:int=0;		public var fga:Array;		public var xxa:Array;		public var sp:String="";				//gfx layers		public var doomBG:Sprite;	//doom clouds BG		public var bgx:Sprite;		//for things that dont darken from doom		public var bg:Sprite;		//main terrain		public var main:Sprite;		//chars + fx		public var fg:Sprite;		//foreground for terrain		public var fgx:Sprite;		//foreground for terrain (no dark)		public var doomFG:Sprite;	//doom clouds FG				//scrollin vars		private var w:uint;		private var h:uint;		public var xMax:int;		private var yMax:int;		private var ovx:uint;		private var ovy:uint;		private var sxm:Number=0;		private var sym:Number=0;		public var ya2:Number=0;				public var roomRefs:Object;				//colors		public var doomBGCC:ColorChange;		public var bgCC:ColorChange;		public var mainCC:ColorChange;		public var fgCC:ColorChange;				public var instantReveal:Array = [];		//////////////////////////////////////////////////		//////////////////////////////////////////////////				public function World (brain):void {						fga=["s3_3R2", "s3_4R1", "spA1_1", "spA2_1", "s1_1T1", "s1_1S1B", "s1_1S2B", "s1_1S3B", "s1_1S5B", "s1_3T1", "s1_1T2", "s1_3T2", "s2_1T1", "s2_2T1", 				 "s3_1T1", "s3_1T2", "s3_3T2", "s3_3T1", "spX1_2", "spX1_2B", "spX2_2", "spF2_1", "spF1_1", "s2_3T1", "spI1_1", "spI3_1", "spX1_2H", "spX1_2BH", "spX2_2H",				 "s0_2T1", "s0_3T1", "s0_4T1", "s1_0T1", "s1_2T1", "s4_2T1", "s1_1G1", "s4_3T2", "spG4_3", "spG5_3", "spG6_3", "spG7_3", "spG8_3",				 "spJ5_2", "spJ3_3", "spJ5_4", "spJ6_4", "spJ7_5", "spJ8_5", "spJ10_5", "spJ11_5", "spJ5_6", "spJ6_6", "spJ9_6", "spJ4_3", "spJ10_4", "spJ9_5", "spJ4_5",				 "spK4_1", "spK5_1", "spK6_1", "spK7_1", "spK8_1", "spK2_1", "spK1_1", "spD3_6",				 "spN15_1","spN8_2","spN9_2","spN11_2","spN14_2","spN15_2","spN17_2","spN18_2","spN7_3","spN8_3","spN9_3","spN11_3","spN12_3","spN13_3",				 "spN14_3","spN15_3","spN17_3","spN18_3","spN5_4","spN6_4","spN7_4","spN8_4","spN9_4","spN10_4","spN11_4","spN12_4","spN13_4","spN15_4","spN16_4","spN18_4","spN19_4",				 "spN2_5","spN3_5", "spN4_5","spN5_5","spN10_5","spN12_5","spN14_5","spN15_5","spN16_5","spN18_5","spN19_5","spN20_5","spN21_5","spN22_5","spN23_5","spO1_1",				 "spL2_1", "spL4_1", "spL3_2", "spL4_2","s0_3G3","s2_4G3","s3_0G4","spQ1_2","spQ2_2","spT3_2","spT5_2","spT2_1", "spBB4_1","spCC3_2","spCC5_2","spCC6_2","spCC10_2","spCC11_2",//"spCC2_3","spCC6_3","spCC8_3","spCC10_3"				 "spDD2_1","spDD3_1","spDD4_1","spDD2_2","spDD3_2","spDD4_2","spDD5_2",				 "s1_1V1","s1_1V2","s1_3V1","s3_1V1","s2_1V1","s1_2V1","s1_2V2","s2_1V2","s2_2V1","s3_3V1","s0_2V1","s2_0V1","spFF1_1","spFF2_1","spFF3_1",				 "spEE6_1","spEE7_1","spEE8_1","spEE6_2","spEE7_2","spEE8_2","spEE6_5","spEE7_5",				 "spEE6_4B","spEE7_4B","spEE8_4B","spEE9_4B","spEE4_5B","spEE5_5B","spEE6_5B","spEE7_5B","spEE8_5","spEE8_5B","spEE9_5B","spEE4_6B","spEE5_6B","spEE8_6B","spEE9_B6","spEE10_6B","spEE10_6","spEE11_6B","spEE12_6B",				 "spXB2_3","spXB3_3","spXB4_3","spXC1_1","spXC1_1B","spXC3_2","spXC5_2","spXC3_4","spXC4_4","spXC5_4","spXE1_1","spXE2_1","spXE3_1","spXE4_1","spXE5_1","spXE1_2","spXE6_2",				 "spXD2_1","spXD3_1","spXD1_2","spXD2_2","spXD3_2","spXD1_3","spXD2_3","spXD3_3","spXD1_3B"]//removed:"spXC2_3"			//			xxa=["spC1_1", "spC2_1", "spC3_1", "spD5_1", "spD6_1", "spD8_2", "spD7_3", "spD8_3", "spD6_4", "spD7_4", 				"spD5_5", "spD6_5", "spD3_6", "spD4_6", "spD5_6", "spX2_1", "spX1_2", "spX1_2B", "spX2_2", "spX3_2", "spF2_1", "spD5_2", "spX2_1H", "spX1_2H", "spX1_2BH", "spX2_2H", "spX3_2H",				 "spF3_1", "spG3_3", "spJ3_3", "spJ4_3", "spJ5_3", "spJ6_3", "spJ7_3",  "spJ9_3", "spJ2_4", "spJ3_4", "spJ4_4","spJ5_4","spJ6_4","spJ7_4","spJ8_4","spJ9_4","spJ10_4","spJ11_4",				 "spJ2_5", "spJ3_5", "spJ4_5", "spJ5_5", "spJ6_5", "spJ7_5", "spJ8_5", "spJ9_5", "spJ10_5", "spJ11_5",				 "spJ4_6", "spJ5_6", "spJ6_6", "spJ7_6", "spJ9_6", "spJ10_6", "spJ11_6", "spJ10_3","spJ11_3","spJ11_4",				 "spN8_3","spN9_3","spN15_3","spN18_3","spN10_4","spN13_4",				 "spN16_3","spN17_3","spN7_4","spN8_4","spN9_4","spN14_4","spN15_4","spN16_4","spN5_5","spN6_5","spN7_5","spN8_5","spN9_5","spN10_5","spN11_5",				 "spN12_5","spN13_5","spN14_5","spN15_5","spN16_5","spN17_5","spN18_5","spN19_5",				 "spL4_1","spL3_2","spL4_2","spS4_1","spS5_1","spS1_2","spS2_2","spS3_2","spS4_2","spS5_2","spS2_3","spS3_3","spT3_1","spT3_2",				 "spCC2_2","spCC3_2","spCC4_2","spCC5_2","spCC1_3","spCC2_3","spCC3_3","spCC4_3","spCC5_3","spCC6_3","spCC7_3","spCC8_3","spCC9_3","spCC10_3","spCC11_3","spCC12_3",				 "spDD2_1","spDD3_1","spDD4_1","spDD2_2","spDD3_2","spDD4_2","spDD5_2",				 "spEE7_1","spEE8_1","spEE6_2","spEE7_2","spEE8_2","spEE7_3","spEE8_3","spEE9_3B","spEE1_4","spEE2_4",				 "spEE5_4B","spEE6_4B","spEE7_4B","spEE8_4B","spEE9_4B","spEE1_5","spEE2_5","spEE3_5","spEE4_5","spEE4_5B","spEE5_5","spEE5_5B","spEE6_5","spEE6_5B","spEE7_5","spEE7_5B",				 "spEE8_5","spEE8_5B","spEE9_5","spEE9_5B","spEE10_5","spEE10_5B","spEE11_5","spEE11_5B",				 "spEE3_6B","spEE4_6B","spEE5_6B","spEE6_6B","spEE8_6B","spEE9_6B","spEE10_6","spEE10_6B","spEE11_6B","spEE12_6B",				 "spXB3_1","spXB2_2","spXB3_2","spXB4_2","spXB1_3","spXB1_3B","spXB2_3","spXB3_3","spXB4_3","spXC1_1","spXC1_1B","spXC1_2","spXC2_1",,"spXC2_2","spXC3_2","spXC4_2","spXC2_3","spXC3_3","spXC4_3","spXC3_4","spXC4_4",				 "spH2_1","spP1_1","spR1_1","spAA1_1","spAA2_1","spBB3_1","spBB4_1","s3_3V1"]//"spD1_1","spJ8_3",						//init vars			ovx=ovy=1000;			cRooms=[];			roomRefs={};						//ref to brain			this.brain=brain;						//define room width and height			w=brain.sDim.w;			h=brain.sDim.h;						//world factory			factory = new WorldFactory();					//levels			doomBG = new Sprite();			bgx = new Sprite();			bg = new Sprite();			main = new Sprite();			fgx = new Sprite();			fg = new Sprite();			doomFG = new Sprite();			addChild (doomBG);			addChild (bgx);			addChild (bg);			addChild (main);			addChild (fgx);			addChild (fg);			addChild (doomFG);						//colors			doomBGCC = new ColorChange (doomBG);			bgCC = new ColorChange (bg);			mainCC = new ColorChange (main);			fgCC = new ColorChange (fg);					}				public function adjNight() {						if (brain.S.night) {								doomBGCC.cChange ([0,0,0,0,0,0,1]);				bgCC.cChange ([0,0,0,0,0,0,1]);				mainCC.cChange ([0,0,0,0,0,0,1]);				fgCC.cChange ([0,0,0,0,0,0,1]);							}					}				//alter world		public function alter (roomID,screen) {						if (brain.S.mod!="MP") { brain.sys.wData.undo[roomID]=sArr[roomID] }			sArr[roomID]=screen;					}				public function removeRooms () {						for each (var room in cRooms) { deleteRoom (room,false) }			cRooms=[];					}				public function remove2() {						//other			var clips:Array=["doomBG","bgx","bg","main","fg","doomFG"]			for each (var clip:String in clips) { dissolve(this[clip],this) }						cRooms=null;			sArr=null;			fga=null;			xxa=null;			doomBG = null;			bgx = null;			bg = null;			main = null;			fg = null;			doomFG = null;						//misc			factory=null;			//rData=null;			brain=null;			roomRefs=null;						//colors			doomBGCC.nulls();			bgCC.nulls();			mainCC.nulls();			fgCC.nulls();			doomBGCC = null;			bgCC = null;			mainCC = null;			fgCC = null;					}				private function dissolve (clip,par) {						if (clip is Sprite) {								var nc:int=clip.numChildren;				for (var i:int=0; i<nc; i++) { dissolve (clip.getChildAt(0),clip) }				par.removeChild (clip);							}					}				// switch to a new world		public function switchWorld (world,retry):String {						//set current world			cWorld = world;			cRooms=[];			//new vData and screen arrangement			var lvlstr:String=brain.sys.vData.defineWorld (world, retry);						//update game info			//brain.sys.inter.vData = brain.sys.vData.v[cWorld];						//define new room data			//rData = brain.sys.rData.r[cWorld];						//define world bounds			xNum=brain.S.xNum;			yNum=brain.S.yNum;			xMax=((xNum-1)*w*-1);			yMax=((yNum-1)*h*-1);						//bg			brain.worldBG.switchWorld (cWorld,xNum,yNum,retry);							//inital cam position			x=-1*((brain.S.BC)?2400:(1100-400));			y=-1*((brain.S.BC)?100:(brain.dinoY-600));						return lvlstr;					}				private var vHack:Boolean= false;					//add room to game area		private function addRoom (pos) {			//create BG			var tmpBG:MovieClip = factory.create (cWorld+brain.S.colorV);			tmpBG.scaleX = 1.002;//SEAMS			tmpBG.scaleY = 1.002;//SEAMS									//define IDs			var room:String = (sp=="V2" && !vHack?"b":"")+"r"+pos[0]+"_"+pos[1];			var screen:String = sArr[room];			if (screen == null) {				trace ("null screen :",room);				return;			}						//halloween sanctuary			if ((brain.S.df || brain.S.aut || brain.S.gh) && screen.indexOf("spX") != -1) {				if (brain.S.gh && brain.S.mod=="MP") {									} else {					screen+="H";				}			}									//super volcano adjust			//position and add to display + roomRefs			tmpBG.x=(pos[0]-1)*brain.sDim.w;			tmpBG.y=(pos[1]-1)*brain.sDim.h;			tmpBG.bgc=brain.S.bg;			//trace (room,screen);			//hack			if (screen == "spEE12_6B") {				vHack = true;			}			try { 				tmpBG.gotoAndStop (screen);			} catch (e) {trace ("/////////////screen error",screen)}						//autumn trees			if (brain.S.aut) {			var nc:int = tmpBG.numChildren;				for (var i:int = 0; i < nc; i++) {					var clip:DisplayObject = tmpBG.getChildAt(i);					if (clip is MovieClip && (clip as MovieClip).totalFrames == 2) {						(clip as MovieClip).gotoAndStop (2);					}				}			}									//special events for adding this screen			if (screen=="spU1_1") {				tmpBG.endID=brain.S.colorV+brain.S.lvl;				if (brain.S.mod == "Halloween") {					tmpBG.endID=brain.S.colorV+"H";				}				tmpBG.endRock.gotoAndStop (tmpBG.endID)			}						bg.addChildAt(tmpBG,0);			roomRefs[room]= { bg:tmpBG };						//create FG?			if (fga.indexOf(screen)!=-1) {								//trace ("fga");								var tmpFG:MovieClip = factory.create (cWorld+"FG"+brain.S.colorV);				tmpFG.scaleX = 1.002;//SEAMS				tmpFG.scaleY = 1.002;//SEAMS				tmpFG.x=tmpBG.x;				tmpFG.y=tmpBG.y;				tmpFG.sp=sp;												try { 					tmpFG.gotoAndStop (screen);				} catch (e) {trace ("/////////////screen fg error",screen)}									if (instantReveal.indexOf(screen) != -1) {					tmpFG.cover.visible=false;					if (screen == "spEE7_2")						tmpFG.extra.visible = true				} else if (screen == "spEE7_2") {					tmpFG.extra.visible = false;				}								//autumn trees				if (brain.S.aut) {					var nc:int = tmpFG.numChildren;					for (var i:int = 0; i < nc; i++) {						var clip:DisplayObject = tmpFG.getChildAt(i);						if (clip is MovieClip && (clip as MovieClip).totalFrames == 2) {							(clip as MovieClip).gotoAndStop (2);						}					}				}								fg.addChild(tmpFG);				roomRefs[room].fg = tmpFG;															}						//create layer XX?			if (xxa.indexOf(screen)!=-1 || screen=="spEE8_6") {							//	trace ("xxa");								var tmpXX:MovieClip = factory.create (cWorld+"X");				tmpXX.scaleX = 1.002;				tmpXX.scaleY = 1.002;				tmpXX.x=tmpBG.x;				tmpXX.y=tmpBG.y;				try { 					tmpXX.gotoAndStop (screen);				} catch (e) {trace ("/////////////screen xx error",screen)}									bgx.addChild(tmpXX);				roomRefs[room].xx = tmpXX;								//trace (screen,room);							}						//for each element in room data for this room : if it doesnt exist, create it,  else tell it the room was added			for each (var item:Object in brain.sys.rData.r.World1[room]) {								if (!item.ex) {										item.rData=true;					brain.create (item);									} else {										if (brain.lib[item.nam]!=undefined) {											var refs:Array = brain.lib[item.nam].refs;						for each (var ref:Object in refs) {														if (item.id==ref.o.id) {																ref.roomAdded();								break;															}													}											}									}							}					}				//delete a room		public function deleteRoom (pos,reset,roomOverride=null) {						//define IDs			var room:String = roomOverride?roomOverride:"r"+pos[0]+"_"+pos[1];			var b:Boolean=true; 			for (var rm in roomRefs) { if (room==rm) { b=false } }			if (b && roomOverride==null) { room="b"+room }			var screen:String = sArr[room];						if (screen == null) {				return;			}			//remove from display and roomRefs			if (roomOverride == null) {				bg.removeChild (roomRefs[room].bg);				roomRefs[room].bg=null;				if (roomRefs[room].fg!=undefined) { fg.removeChild (roomRefs[room].fg); roomRefs[room].fg=null }				if (roomRefs[room].xx!=undefined) { bgx.removeChild (roomRefs[room].xx); roomRefs[room].xx=null }				delete roomRefs[room];			}						if (!reset) {								//alert room items that this room is deleted				for each (var item:Object in brain.sys.rData.r.World1[room]) {										if (brain.lib[item.nam]!=undefined) {												var refs:Array = brain.lib[item.nam].refs;						for each (var ref:Object in refs) {														if (item.id==ref.o.id) {																if (ref.o.ex) {																		ref.roomDeleted();									break;																	}															}													}											}									}							}		}		// move camera		public function moveCam (o) {						var px:Number=o.pos.x;//+50,80,100(PG)			var py:Number=o.pos.y;			var rvx:Number = (o.riding!=null)?o.riding.vel.x:o.vel.x;			var rvy:Number = (o.riding!=null)?o.riding.vel.y:o.vel.y;			rvx*=brain.hc;			rvy*=brain.hc;									var vx=Math.ceil((1-x-sxm)/w);			var vy=Math.ceil((1-y-sym)/h);						if (vx!=ovx||vy!=ovy) {								//visible rooms has changed...  add and delete rooms				//define temp visible rooms array				var tRooms:Array;				if (Brain.wide) {					tRooms = [[vx-1,vy],[vx-1,vy+1],[vx-1,vy+2],[vx,vy],[vx,vy+1],[vx,vy+2],[vx+1,vy],[vx+1,vy+1],[vx+1,vy+2],[vx+2,vy],[vx+2,vy+1],[vx+2,vy+2]];				} else if (Brain.tall) {					tRooms = [[vx,vy-1],[vx,vy],[vx,vy+1],[vx,vy+2],[vx+1,vy],[vx+1,vy+1],[vx+1,vy+2],[vx+2,vy],[vx+2,vy+1],[vx+2,vy+2]];				} else {					tRooms = [[vx,vy],[vx,vy+1],[vx,vy+2],[vx+1,vy],[vx+1,vy+1],[vx+1,vy+2],[vx+2,vy],[vx+2,vy+1],[vx+2,vy+2]];				}				//remove rooms that are not in bounds				for (var i:uint=0; i<tRooms.length; i++) {										var tR:Array = tRooms[i];					if (tR[0]==0||tR[1]==0||tR[0]*w>((xMax*-1)+w)||tR[1]*h>((yMax*-1)+h)) {												tRooms.splice (i,1);						i--;											}									}								//compare tRooms and cRooms to decide what rooms should attached and deleted				//adding				for each (var tRoom:Array in tRooms) {					var exists:Boolean=false;					for each (var cRoom:Array in cRooms) {						if (tRoom[0]==cRoom[0]&&tRoom[1]==cRoom[1]) {							exists=true;							break;						}					}					if (!exists) {						addRoom (tRoom);					}				}								//deleting				for each (var cRoom2:Array in cRooms) {					var exists2:Boolean=false;					for each (var tRoom2:Array in tRooms) {						if (cRoom2[0]==tRoom2[0]&&cRoom2[1]==tRoom2[1]) {							exists2=true;							break;						}					}					if (!exists2) {												deleteRoom (cRoom2,false);					}				}								cRooms=tRooms.slice();				}					ovx=vx;			ovy=vy;						//shake?			if (shakeC>-1) {								shakeC--;				shakeMag=shakeC/20;						}						//move cam			var vxA=(rvx*45);			if (vxA>600) { vxA=600 }			if (vxA<-600) { vxA=-600 }			var twx:int=((0-px)+w/2)-vxA;			if (twx>-801) { twx=-801 }			var xm = Config.WEB ? 60 : 160;			if (twx<xMax+xm) { twx=xMax+xm }			sxm+=(twx-x)/100;			sxm*=.8;			//			var ya:Number=(o.vel.y>0)?(rvy*30):(o.near?rvy*5:0);			var twy:int=((0-py)+h/2)-ya+75+ya2;			if (twy>0) { twy=0 }			if (twy<yMax) { twy=yMax }			sym+=(twy-y)/100;			sym*=.8;						//shake?			if (shakeMag>4) { shakeMag=4 }			sxm+=rand(-2*shakeMag,2*shakeMag);			sym+=rand(-2*shakeMag,2*shakeMag);						x=x+sxm;			y=y+sym;						if (brain.S.pk) {				y+=5;			} else if (brain.S.df) {				y-=2;			}						brain.worldBG.moveCam ((x*-1),(y*-1));					}				//random number		private function rand(min:Number, max:Number):Number {			return (Math.random()*(max-min))+min;		}	}	}