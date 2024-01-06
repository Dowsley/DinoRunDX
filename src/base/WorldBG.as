﻿package base
{
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.utils.getDefinitionByName;
	
	import datas.ImageAssets;
	
	import fx.ColorChange;
	
	import gfx.Cloud;
	
	import util.WorldFactory;
	
	public class WorldBG extends Sprite
	{
		
		private var brain:Brain;	//ref to brain
		private var factory:WorldFactory;	//world factory
		public var cWorld:String;	//current world
		public var cRooms:Object;	//current visible rooms
		public var xNum:uint;		//num of screens x
		public var yNum:uint;		//num of screens y
		private var w:uint;
		private var h:uint;
		private var xMax:int;
		private var yMax:int;
		private var ovx:uint;
		private var ovy:uint;
		private var sxm:Number = 0;
		private var sym:Number = 0;
		public var xFactor:Number;
		public var yFactor:Number;
		public var xA:int;
		
		public var legacy:Boolean = false;
		
		//gfx layers
		public var cl:Sprite;		//clouds
		public var bg:Sprite;		//background
		public var mg:Sprite;		//midground
		public var fg:Sprite;		//foreground
		
		private var roomRefs:Object;
		private var BGBounds:Object;
		private var cloudW:Object;
		
		//colors
		public var cc:ColorChange;
		
		//public var clcc:ColorChange;
		
		//////////////////////////////////////////////////
		//////////////////////////////////////////////////
		
		public function WorldBG(brain:Brain):void
		{
			
			//init vars
			ovx = ovy = 1000;
			cRooms = [];
			roomRefs = {};
			BGBounds = {A: [30, 2, 10, 7], J: [30, 2, 10, 7], B: [30, 2, 10, 7], C: [30, 2, 10, 7], D: [30, 2, 10, 7], F: [13, 2, 2, 20], G: [13, 2, 2, 20], H: [13, 2, 2, 20], I: [13, 2, 2, 20], N: [30, 2, 10, 7], O: [30, 2, 10, 7], P: [30, 2, 10, 7], Q: [13, 2, 2, 20], R: [13, 2, 2, 20], S: [13, 2, 2, 20], T: [11, 2, 2, 20], U: [11, 2, 2, 20], V: [11, 2, 2, 20], Y: [11, 2, 2, 20], W: [11, 2, 2, 20], X: [.5, 2, 2, 0]}
			cloudW = {c11: 60, c12: 129, c13: 186, c14: 186, c15: 150, c21: 60, c22: 129, c23: 186, c24: 186, c25: 150, c31: 309, c32: 321, c33: 129, c34: 333, c35: 150, c41: 441, c42: 129, c43: 485, c44: 333, c45: 150, c51: 60, c52: 129, c53: 186, c54: 186, c55: 150, c61: 309, c62: 321, c63: 129, c64: 333, c65: 150, c71: 441, c72: 129, c73: 485, c74: 333, c75: 150, c81: 309, c82: 321, c83: 129, c84: 333, c85: 150, c91: 210, c92: 513, c93: 486, c94: 186, c95: 513, c101: 210, c102: 513, c103: 486, c104: 186, c105: 513,
				
				c161: 1400 / 3, c162: 1400 / 3, c163: 2000 / 3, c164: 2300 / 3, c165: 1900 / 3,
				
				c201: 210, c202: 513, c203: 486, c204: 186, c205: 513, c211: 210, c212: 513, c213: 486, c214: 186, c215: 513, c221: 210, c222: 513, c223: 486, c224: 186, c225: 513, c231: 210, c232: 513, c233: 486, c234: 186, c235: 513, c241: 210, c242: 513, c243: 486, c244: 186, c245: 513, c251: 441, c252: 129, c253: 485, c254: 333, c255: 150, c261: 210, c262: 513, c263: 486, c264: 186, c265: 513, c271: 60, c272: 129, c273: 186, c274: 186, c275: 150, c281: 210, c202: 129, c203: 186, c204: 186, c205: 150,
				
				c301: 210, c302: 513, c303: 486, c304: 186, c305: 513}
			
			//ref to brain
			this.brain = brain;
			
			//define room width and height
			w = brain.sDim.w;
			h = brain.sDim.h;
			
			//world factory
			factory = new WorldFactory();
			
			//gfx layers
			
			bg = new Sprite();
			cl = new Sprite();
			mg = new Sprite();
			fg = new Sprite();
			addChild(bg);
			addChild(cl);
			addChild(mg);
			addChild(fg);
			
			//colors
			cc = new ColorChange(this);
		
		}
		
		public function removeRooms()
		{
			
			//remove rooms
			for each (var room in cRooms)
			{
				deleteRoom(room)
			}
			cRooms = [];
		
		}
		
		private function dissolve(clip, par)
		{
			
			if (clip is Sprite)
			{
				
				var nc:int = clip.numChildren;
				for (var i:int = 0; i < nc; i++)
				{
					dissolve(clip.getChildAt(0), clip)
				}
				par.removeChild(clip);
				
			}
		
		}
		
		public function remove2()
		{
			
			//other
			var clips:Array = ["cl", "bg", "mg", "fg"];
			for each (var clip:String in clips)
			{
				dissolve(this[clip], this)
			}
			
			//misc
			cl = null;
			bg = null;
			mg = null;
			fg = null;
			cc.nulls();
			cc = null;
			
			brain = null;
			factory = null;
			cRooms = null;
			factory = null;
			
			roomRefs = null;
			BGBounds = null;
			cloudW = null;
		
		}
		
		// switch to a new world
		public function switchWorld(world, wxNum, wyNum, retry):void
		{
			
			//set current world
			cWorld = world;
			
			//delete all current rooms and item in those rooms
			cRooms = [];
			
			//define world bounds + screen arrangement
			xNum = BGBounds[brain.S.bg][0];
			yNum = BGBounds[brain.S.bg][1];
			xMax = (xNum - 1) * w * -1;
			yMax = (yNum - 1) * h * -1;
			
			//set scroll proportions
			xFactor = (wxNum / xNum) + BGBounds[brain.S.bg][2];
			yFactor = ((wyNum + 5) / yNum) + BGBounds[brain.S.bg][3];
			if (!retry)
			{
				trace("///////////");
				
				xA = Math.round(Math.random() * (((xNum) - (wxNum / xFactor)) * brain.sDim.w));
				xA *= .15;
				//xA = 0;
				brain.S.bgxa = xA;
				
			}
			else
			{
				
				xA = brain.S.bgxa;
				
			}
		
		}
		
		//add room to game area
		private function addRoom(pos)
		{
			
			//create BG
			var tmpBG:MovieClip = factory.create(cWorld + "BG" + brain.S.bg);
			tmpBG.scaleX = 1.002;//SEAMS
			tmpBG.scaleY = 1.002;//SEAMS
			
			//define IDs
			var room:String = "bg" + pos[0] + "_" + pos[1];
			
			//position and add to display + roomRefs
			tmpBG.x = (pos[0] - 1) * w;
			tmpBG.y = (pos[1] - 1) * h + ((brain.S.mod == "PlanetD" && brain.S.night) || brain.S.PL ? 800 : 0);
			tmpBG.gotoAndStop(room);
			mg.addChild(tmpBG);
			roomRefs[room] = tmpBG;
			
			//clouds
			var l:uint = brain.rand(2, 8);
			if (brain.S.night)
			{
				l = 0
			} // no clouds at night
			for (var i:int = 0; i < l; i++)
			{
				
				var c:Cloud = new Cloud();
				var v:int = brain.rand(1, 5);
				c.speed = brain.rand2(.05, .15);
				c.w = cloudW["c" + brain.S.sky + "" + v];
				c.x = tmpBG.x + brain.rand(0, 600);
				c.y = tmpBG.y + brain.rand((pos[1] == 1) ? -200 : 0, 300);
				c.graphic.gotoAndStop(brain.S.sky + "_" + v);
				c.alpha = brain.rand2(.85, 1.1);
				cl.addChild(c);
				
			}
		
		}
		
		//delete a room
		private function deleteRoom(pos)
		{
			
			//define IDs
			var room:String = "bg" + pos[0] + "_" + pos[1];
			
			//remove from display and roomRefs
			mg.removeChild(roomRefs[room]);
			delete roomRefs[room];
		
		}
		private var bmpAdded:Boolean = false;
		private var bg1:Bitmap;
		private var bg1yo:int = 0;
		private var bg2yo:int = 0;
		
		private var icies:Array = ["A", "B", "C", "D", "E", "J", "K", "O", "P"];
		private var grasses:Array = ["F", ",G", "H", "I", "Q", "R", "S"];
		
		public function addBMP():void
		{
			var worldWidth:int = -xMax + xA;
			var totalWidth:int = 0;
			
			var bgVar:String = icies.indexOf(brain.S.bg) != -1 ? (Math.random() < .33 && !brain.S.sl && !brain.S.gh ? "0" : "1") : "1";
			var grass:Boolean = grasses.indexOf(brain.S.bg) != -1;
			
			var bmp1Class:Class = ImageAssets["BG_" + brain.S.bg + bgVar] as Class;
			var bmp2Class:Class = ImageAssets["BG_" + brain.S.bg + "2"] as Class;
			
			//bg1
			bg1 = new bmp1Class;
			bg.addChild(bg1);
			bg1.scaleX = bg1.scaleY = 3;
			bg1yo = 50;
			if (bgVar == "0")
			{
				bg1yo = 125;
			}
			if (grass)
			{
				bg1yo = 150;
			}
			
			//bg2
			do
			{
				var bmp:Bitmap = new bmp2Class;
				mg.addChild(bmp);
				bmp.scaleX = bmp.scaleY = 3;
				bmp.x = totalWidth;
				bmp.y = grass ? 75 : 125;
				totalWidth += bmp.width;
				if (totalWidth > worldWidth)
				{
					break;
				}
			} while (true);
		}
		
		private var lastVX:int = -1;
		private var cloudy:Boolean = false;
		
		// move camera
		public function moveCam(px, py)
		{
			
			if (!legacy && !bmpAdded)
			{
				addBMP();
				bmpAdded = true;
				cloudy = Math.random() < .5 || brain.S.gh;
			}
			
			//trace (xFactor,xA)
			
			px /= xFactor;
			py /= yFactor;
			px += xA;
			
			var sy:Number = 0 - (py);
			if (sy < -250)
			{
				sy = -150
			}
			if (sy > 0)
			{
				sy = 0
			}
			brain.sky.y = sy - 100;
			
			var vx:uint = Math.ceil((((px) + 1)) / w);
			var vy:uint = Math.ceil((((py - 100) + 1)) / h);
			
			if (legacy)
			{
				
				if (vx != ovx || vy != ovy)
				{
					
					//visible rooms has changed...  add and delete rooms
					//define temp visible rooms array
					var tRooms:Array;
					if (Brain.wide)
					{
						tRooms = [[vx - 1, vy], [vx - 1, vy + 1], [vx - 1, vy + 2], [vx, vy], [vx, vy + 1], [vx, vy + 2], [vx + 1, vy], [vx + 1, vy + 1], [vx + 1, vy + 2], [vx + 2, vy], [vx + 2, vy + 1], [vx + 2, vy + 2]];
					}
					else
					{
						var tRooms = [[vx, vy], [vx, vy + 1], [vx, vy + 2], [vx + 1, vy], [vx + 1, vy + 1], [vx + 1, vy + 2], [vx + 2, vy], [vx + 2, vy + 1], [vx + 2, vy + 2]];
					}
					//[vx-1,vy],[vx-1,vy+1],[vx-1,vy+2],
					//remove rooms that are not in bounds
					for (var i:uint = 0; i < tRooms.length; i++)
					{
						
						var tR:Array = tRooms[i];
						if (tR[0] == 0 || tR[1] == 0 || tR[0] * w > ((xMax * -1) + w) || tR[1] * h > ((yMax * -1) + h))
						{
							
							tRooms.splice(i, 1);
							i--;
							
						}
						
					}
					
					//compare tRooms and cRooms to decide what rooms should attached and deleted
					//adding
					for each (var tRoom:Array in tRooms)
					{
						var exists:Boolean = false;
						for each (var cRoom:Array in cRooms)
						{
							if (tRoom[0] == cRoom[0] && tRoom[1] == cRoom[1])
							{
								exists = true;
								break;
							}
						}
						if (!exists)
						{
							addRoom(tRoom);
						}
					}
					
					//deleting
					for each (var cRoom2:Array in cRooms)
					{
						var exists2:Boolean = false;
						for each (var tRoom2:Array in tRooms)
						{
							if (cRoom2[0] == tRoom2[0] && cRoom2[1] == tRoom2[1])
							{
								exists2 = true;
								break;
							}
						}
						if (!exists2)
						{
							
							deleteRoom(cRoom2);
						}
					}
					
					cRooms = tRooms.slice();
					
				}
				
			}
			
			//move world 
			x = (-1 * px);
			y = (-1 * py) + (legacy ? 150 : 0);
			
			//bg1
			if (!legacy)
			{
				bg1.x = x * -.5;
				bg1.y = y * -.5 + bg1yo;
				
				var init = lastVX == -1;
				
				if (vx > lastVX)
				{
					lastVX = vx;
					var l:uint = cloudy ? brain.rand(3, 10) : brain.rand(1, 3);
					if (init)
					{
						l *= 2;
					}
					if (brain.S.night)
					{
						l = 0
					} // no clouds at night
					var bgx = (vx) * w;
					var bgy = (vy) * h + ((brain.S.mod == "PlanetD" && brain.S.night) || brain.S.PL ? 800 : 0);
					for (var ii:int = 0; ii < l; ii++)
					{
						
						var cloud:Cloud = new Cloud();
						var v:int = brain.rand(1, 5);
						cloud.speed = brain.rand2(-.5, .75);
						var skyID:int = brain.S.sky;
						cloud.w = cloudW["c" + skyID + "" + v];
						if (init)
						{
							cloud.x = bgx + brain.rand(-800, 800);
						}
						else
						{
							cloud.x = bgx + brain.rand(100, 800);
						}
						
						cloud.y = bgy + brain.rand((vy == 1) ? -200 : -100, 350);
						
						cloud.graphic.gotoAndStop(skyID + "_" + v);
						cloud.alpha = brain.rand2(.5, .95);
						if (brain.S.gh)
						{
							cloud.alpha = brain.rand2(.05, .25);
						}
						cl.addChild(cloud);
						
					}
				}
			}
			
			//trace (x,y);
			
			//move clouds
			var nc:uint = cl.numChildren;
			for (var c:uint = 0; c < nc; c++)
			{
				
				var cld = cl.getChildAt(c);
				cld.x += cld.speed * ((brain.dino.accelR + .25) * .33);
				if (cld.x + cld.w + 100 < px)
				{
					cl.removeChildAt(c);
					c--;
					nc--
				}
				
			}
		
		}
	
	}

}

BG_I2
BG_I1