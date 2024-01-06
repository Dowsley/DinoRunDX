﻿package base
{
	
	//native
	import flash.desktop.NativeApplication;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.NativeWindowResize;
	import flash.display.PixelSnapping;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageDisplayState;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.NativeWindowBoundsEvent;
	import flash.events.TimerEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.Capabilities;
	import flash.ui.Keyboard;
	import flash.ui.Mouse;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	import control.Keys;
	
	import datas.GameData;
	import datas.InteractionData;
	import datas.NodeParser;
	import datas.RoomData;
	import datas.VectorData;
	import datas.World1Data;
	
	import fx.BGRed;
	import fx.Impact;
	import fx.Impact2;
	import fx.Rain;
	
	import gamestats.SteamStats;
	
	import gfx.InterF;
	import gfx.L1;
	import gfx.ProgBar;
	import gfx.Raptor;
	import gfx.Weather;
	
	import starling.events.ResizeEvent;
	
	import stats.GSInternal;
	
	import ui.UI;
	
	import util.AudioEngine;
	import util.Controller;
	import util.Doom;
	import util.FPSCheck;
	import util.Factory;
	import util.LevelStats;
	import util.Rndm;
	import util.Stats;
	
	[SWF(width = "900", height = "550", frameRate = "50", backgroundColor = "#000000")]
	//[SWF(width="801", height="450", frameRate="50", backgroundColor="#000000")]
	
	public class Brain extends Sprite
	{
		
		//////////////////
		public static const LINUX:Boolean = true;
		public static const ENABLE_ZINC:Boolean = false; // false for Mac App Store, true for D2D, MGS
		public static const PC:Boolean = false; // true for all PC versions, false for all others
		public static const ENABLE_UPDATES:Boolean = true; // false for D2D, MGS, App Store
		//////////////////
		
		public static var ERROR_LOG:Array = new Array();
		
		public static var loginU:String = "";
		public static var loginP:String = "";
		public static var saveLogin:Boolean = true;
		
		public static var useSeed:int = 0;
		public static var freeRun:Boolean = false;
		public static var freeRunSP:Boolean = false;
		public static var frDoom:Boolean = false;
		public static var frGore:Boolean = false;
		
		public static const MONITOR_W:int = Config.WEB ? 801 : Capabilities.screenResolutionX;
		public static const MONITOR_H:int = Config.WEB ? 450 : Capabilities.screenResolutionY;
		public static const FULLSCREEN:Boolean = true;
		public static const DIMENSIONS:Point = new Point(801, 450);
		public var screen:ScreenSettings;
		public static var mag:Number = 1;
		public var fullScreen:Boolean = false;
		private const BEGIN_LEVEL:int = Config.START_LEVEL; //0   6= volcano
		public static const DEBUG:Boolean = false;
		public static const SHORT:Boolean = Config.SHORT; //temp
		public static var c:int;
		public static var noFrenzy:Boolean = false;
		public static var wide:Boolean = false;
		public static var tall:Boolean = false;
		
		public static var left:int = 0;
		public static var top:int = 0;
		
		//main gfx container
		private var container:Sprite;
		private var bmp:Bitmap;
		
		//version data
		public var xgen:Boolean = false;
		//	public var SC:Boolean=true;
		public var VAR:String = "";//MJ,KG,DF,MC,700,600,SP,AR,XP,BF,UG,AG,WR,TT,MF,SS,PG
		
		// VARS
		// systems
		public var sys:Object;			//systems
		public var sys2:Object;			//looping systems
		public var lib:Object;	 		//game elements library
		public var c:uint;				//counter
		private var delO:Array;			//object garbage pile
		private var delC:Array;			//clip garbage pile
		private var timer:Timer;		//timer
		private var fTimer:Timer
		public var keys:Keys;			//keys
		private var ids:uint;			//id counter
		
		//misc
		public var sDim:Object;			//screen dimensions
		public var dino:Raptor;			//ref to dino
		private var camFocus:Object;	//ref to obj that camera follows
		public var dinoY:Number;		//dino start Y
		public var doom:Doom;			//doom!
		public var endLevel:Boolean;
		
		//settings
		public var gState:String;		//gameState : game,pause,win,extinct, etc
		public var S:Object;			//game settings
		private var useTimer = false;
		public var res:Boolean = false;
		public var ret:Boolean = false;
		public var goBeach:Boolean = false;
		public var mpGames:int = 0;
		
		//gfx layers
		public var sky:L1;				//layer 1 : behind all, doesnt move
		public var worldBG:WorldBG;		//layer 2 : background, birds, etc
		public var weather:Weather;		//layer 3 : lightning, etc
		public var world:World;			//layer 4 : foreground, chars, doom, etc
		public var interF:InterF;		//layer 5 : interface, info screens, etc, doesnt move
		public var progBar:ProgBar;		//MP progBar
		
		//MP
		public var rmDinos:Object;
		public var hc:Number = 1; // handicap
		public var mpids:int;
		public var slow:Boolean = false;
		public var lvlV:Boolean = false;
		public var con:Boolean = false;
		
		//API
		private var sTimer:Timer;
		
		//ZINC
		private var menuTimer:Timer;
		
		//new
		public static var dinoGrabbed:Boolean = false;
		private var bmpMatrix:Matrix = new Matrix();
		private var flipped:Boolean = false;
		public static var connection:Boolean = false;
		public var oldScreenState:String = "normal";
		
		public static var ticker:String = "";
		public static var newsID:int = 0;
		public static var news:String = "";
		public static var MPNews:String = "";
		public static var MPNewsID:int = 0;
		public static var showNews:Boolean = false;
		public static var showMPNews:Boolean = false;
		
		public var oldStageWidth:int = 801;
		public var oldStageHeight:int = 405;
		
		public static var goFS:Boolean = false;
		
		public static var APP_WIDTH:int = 801;
		public static var APP_HEIGHT:int = 450;
		
		public static var gameStats:*;
		public static var staticInterF:InterF;
		
		public static var MPMulti:int = 1;
		public static var ServerNum:int = 1;
		
		//
		////////////////////////////////////////////////////
		//
		public function Brain()
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		public function toggleLog():void
		{
			Config.SHOW_LOG = !Config.SHOW_LOG;
			if (Config.SHOW_LOG)
			{
				Brain.staticInterF.graphic.debug.y = 40;
				Brain.staticInterF.graphic.debug.visible = true;
				Brain.staticInterF.graphic.debug.txt.text = logTxt;
			}
			else
			{
				Brain.staticInterF.graphic.debug.y = -1000;
				Brain.staticInterF.graphic.debug.visible = false;
				Brain.staticInterF.graphic.debug.txt.text = "";
			}
		}
		
		public function dumpErrors():void
		{
			Brain.log(String(Brain.ERROR_LOG), true);
		}
		
		public function clearErrors():void
		{
			Brain.ERROR_LOG = [];
			sys2.stats.saveErrors();
			dumpErrors();
		}
		
		public function clearCheevos():void
		{
			sys2.stats.clearCheevos();
		}
		
		static public var logTxt:String = "";
		
		static public function log(str:*, replace:Boolean = false):void
		{
			trace(str);
			/*replace = false;
			   if (!Config.SHOW_LOG) {
			   Brain.staticInterF.graphic.debug.y = -1000;
			   Brain.staticInterF.graphic.debug.visible = false;
			   return;
			   } else {
			   Brain.staticInterF.graphic.debug.y = 40;
			   Brain.staticInterF.graphic.debug.visible = true;
			   }*/
			if (replace)
			{
				logTxt = "";
			}
			logTxt += (String(str) + " | ");
			if (Brain.staticInterF.graphic.debug.visible)
			{
				Brain.staticInterF.graphic.debug.txt.text = logTxt;
			}
		
		}
		
		static public function initGameStats():void
		{
			trace("init game stats");
			
			if (!Brain.gameStats)
			{
				if (Config.STEAM)
				{
					Brain.gameStats = new SteamStats();
					try
					{
						Brain.gameStats.init()
					}
					catch (e:Error)
					{
						Brain.log("no steam");
					}
				}
			}
		}
		
		static public function GSSubmitScore(score:int, category:String = "normal"):void
		{
			Brain.log("submit score " + score + " " + category);
			if (Brain.gameStats)
			{
				try
				{
					Brain.gameStats.submitScore(score, category);
				}
				catch (e:Error)
				{
				}
			}
		}
		
		static public function GSSubmitAch(id:String, percentComplete:Number):Boolean
		{
			Brain.log("submit ACH " + id);
			if (Brain.gameStats)
			{
				try
				{
					Brain.gameStats.submitAch(id, percentComplete);
					return true;
				}
				catch (e:Error)
				{
					return false
				}
			}
			return false;
		}
		
		public function submitHS()
		{
		
		}
		
		public function ssSubmit(e)
		{
			
			if (gState == "game")
			{
				submitHS()
			}
		
		}
		
		private function onResize(event:NativeWindowBoundsEvent):void
		{
			Brain.wide = false;
			Brain.tall = false;
			var ratio:Number = event.afterBounds.width / event.afterBounds.height;
			
			Brain.wide = ratio > 1.61;
			Brain.tall = ratio <= 1.33
			trace(ratio, Brain.wide, Brain.tall);
		}
		
		//free run
		static public var talkVisible:Boolean = false;
		
		public function freeRun_Doom(force:int = 0):void
		{
			
			if (force == 1)
			{
				Brain.frDoom = false;
			}
			else if (force == 2)
			{
				Brain.frDoom = true;
			}
			else
			{
				Brain.frDoom = !Brain.frDoom;
			}
			
			if (Brain.frDoom)
			{
				asteroid(null);
				doom.showFRDoom();
				if (S.mod == "MP" && force == 0)
				{
					sys.MP.sendToRoom("SD");
				}
			}
			else
			{
				doom.hideFRDoom();
				if (S.mod == "MP" && force == 0)
				{
					sys.MP.sendToRoom("HD");
				}
			}
		}
		
		public function freeRun_Talk():void
		{
			interF.talk();
		}
		
		public function freeRun_Talk_Submit():void
		{
			if (dino)
			{
				var txt:String = interF.talkSubmit();
				dino.showSpeech(txt);
				if (S.mod == "MP")
				{
					sys.MP.sendToRoom("TA" + txt);
				}
			}
		}
		
		public function freeRun_Rain():void
		{
			trace("freeRunRain");
			createRain();
			if (S.mod == "MP")
			{
				sys.MP.sendToRoom("RA");
			}
		}
		
		public function freeRun_Info():void
		{
			interF.toggleFRInfo();
		}
		
		public function freeRun_Gore(force:int = 0):void
		{
			
			if (force == 1)
			{
				Brain.frGore = false;
			}
			else if (force == 2)
			{
				Brain.frGore = true;
			}
			else
			{
				Brain.frGore = !Brain.frGore;
			}
			
			if (Brain.frGore)
			{
				dino.showGore();
				if (S.mod == "MP" && force == 0)
				{
					sys.MP.sendToRoom("SG");
				}
			}
			else
			{
				dino.hideGore();
				if (S.mod == "MP" && force == 0)
				{
					sys.MP.sendToRoom("HG");
				}
			}
		}
		
		public function freeRun_Dactyl(shift:Boolean = false):void  { createDactyls(1, 2, shift); }
		
		public function freeRun_Meteorite(shift:Boolean = false):void  { createMeteorite(shift); }
		
		public function freeRun_Boulder(shift:Boolean = false):void  { createBoulder(shift); }
		
		public function freeRun_Stego(shift:Boolean = false):void  { createStego(shift); }
		
		public function freeRun_Para(shift:Boolean = false):void  { createPara(shift); }
		
		public function freeRun_Lizard():void  { createLizard(); }
		
		public function freeRun_Cera(shift:Boolean = false):void  { createCera(shift); }
		
		public function freeRun_Wave():void
		{
			dino.wave();
			if (S.mod == "MP")
			{
				sys.MP.sendToRoom("WA");
			}
		}
		
		public function freeRun_Sit():void
		{
			dino.sit();
			if (S.mod == "MP")
			{
				sys.MP.sendToRoom("SI");
			}
		}
		
		//
		
		public function onExit(e:Event):void
		{
			sys2.stats.flushSaveBackup();
		}
		
		public function init(e:flash.events.Event)
		{
			
			try
			{
				
				if (Config.PARSE_NODES)
				{
					new NodeParser();
					return;
				}
				
				if (Config.WEB)
				{
					Config.STEAM = false;
					Config.HALLOWEEN = false;
				}
				
				stage.focus = this;
				stage.quality = "LOW";
				stage.nativeWindow.addEventListener(NativeWindowBoundsEvent.RESIZE, onResize);
				
				NativeApplication.nativeApplication.addEventListener(Event.EXITING, onExit);
				
				//stage.addEventListener(Event.RESIZE, onResize);
				container = new Sprite();
				if (!Config.RENDER_GAME_TO_BITMAP)
					addChild(container);
				
				//define screen dimensions
				sDim = {w: 801, h: 450}
				
				//main bitmap
				bmp = new Bitmap(new BitmapData(sDim.w, sDim.h, false, 0x000000), PixelSnapping.ALWAYS, false);
				if (Config.RENDER_GAME_TO_BITMAP)
					addChild(bmp);
				
				//systems
				sys = {};
				sys2 = {};
				lib = {};
				
				//settings
				S = {
					
					dif: "Medium", mod: "Challenge",//SpeedRun//Challenge//MP
					lvl: 0, MP: true, hats: false, gold: false
				
				}
				
				// timer
				if (useTimer)
				{
					
					fTimer = new Timer(15, 0);
					fTimer.addEventListener(TimerEvent.TIMER, mainLoop, false, 0, true);
					
				}
				
				// keys
				keys = new Keys(stage, this);//
				
				//controller
				if (!Config.WEB)
				{
					Controller.init(stage, this);
				}
				
				// interface
				interF = new InterF(this);
				Brain.staticInterF = interF;
				addChild(interF);
				interF.showScreen("main");
				gState = "pause";
				removeTabs();
				keys.addKeys({exe: interF, vals: {D: [13]}, exeD: false, exeU: true});
				
				// systems
				sys.MP = new MPManager(this);
				sys.audio = new AudioEngine(this, false);
				sys.gData = new GameData();
				sys.factory = new Factory();
				sys.inter = new Interactions(this);
				sys.iData = new InteractionData();
				sys.rData = new RoomData(this);
				sys.vData = new VectorData(this);
				sys.wData = new World1Data(this);
				sys2.stats = new Stats(this);
				
				addEventListener(Event.ENTER_FRAME, mainLoop, false, 0, true);
				
				//get news + check for internet connection
				xmlLoader = new URLLoader();
				xmlLoader.addEventListener(Event.COMPLETE, newsLoaded);
				xmlLoader.addEventListener(IOErrorEvent.IO_ERROR, connectError);
				xmlLoader.load(new URLRequest("http://www.pixeljam.com/dinorun/news.xml"));
				
				//game stats
				Brain.initGameStats();
				
			}
			catch (e:Error)
			{
				if (Config.LOG_ERRORS)
				{
					logError(Config.VERSION + e.getStackTrace());
				}
			}
		
		}
		
		public function logError(e:String):void
		{
			trace(e);
			if (Brain.ERROR_LOG.indexOf(e) == -1)
			{
				Brain.ERROR_LOG.push(e);
			}
			sys2.stats.saveErrors();
		}
		
		public function removeTabs():void
		{
			interF.graphic.tabEnabled = false;
			interF.graphic.tabChildren = false;
		}
		
		public function enableTabs():void
		{
			interF.graphic.tabEnabled = true;
			interF.graphic.tabChildren = true;
		}
		
		private var xmlLoader:URLLoader
		public static var updateNeeded:Boolean = false;
		public static var updateDesc:String = "";
		public static var updateShown:Boolean = false;
		
		private function connectError(e:IOErrorEvent)
		{
		
		}
		
		private function newsLoaded(event:flash.events.Event):void
		{
			Brain.connection = true;
			if (interF.current == "Main")
				interF.graphic.bt_HighScores.visible = true;
			
			var xml:XML = new XML(xmlLoader.data);
			
			/*if (Brain.ENABLE_ZINC && Brain.ENABLE_UPDATES) {
			   if (Config.VERSION < xml.attribute("num")) {
			   Brain.updateNeeded = true;
			   Brain.updateDesc = xml.attribute("desc");
			   if (interF.current == "Main" && !Brain.updateShown)
			   interF.showInterX ("Update");
			   if (interF.current == "Main")
			   interF.graphic.bt_update.visible = true;
			
			   };
			   }*/
			
			Brain.ticker = "                                                                                       ..." + xml.attribute("ticker" + (Config.STEAM ? "ST" : "")) + "                                                                                           ...";
			
			interF.startTicker();
			
			Brain.newsID = int(xml.attribute("newsID"));
			Brain.news = xml.attribute("news" + (Config.STEAM ? "ST" : ""));
			Brain.MPNewsID = int(xml.attribute("MPNewsID"));
			Brain.MPNews = xml.attribute("MPNews" + (Config.STEAM ? "ST" : ""));
			Brain.MPMulti = int(xml.attribute("MPMulti"));
			Brain.ServerNum = int(xml.attribute("ServerNum"));
			
			trace(Brain.newsID, sys2.stats.newsIDShown);
			trace(Brain.MPNewsID, sys2.stats.MPNewsIDShown);
			trace(Brain.ServerNum);
			
			if ((Brain.newsID > sys2.stats.newsIDShown || Config.FORCE_NEWS) && Brain.news != "")
			{
				Brain.showNews = true;
				interF.showNews();
				
			}
			if ((Brain.MPNewsID > sys2.stats.MPNewsIDShown || Config.FORCE_NEWS) && Brain.MPNews != "")
			{
				Brain.showMPNews = true;
			}
		
		}
		
		public function looper(what)
		{
			
			if (what == "stop")
			{
				
				if (gState != "pause")
				{
					if (useTimer)
					{
						fTimer.stop()
					}
					else
					{
						removeEventListener(Event.ENTER_FRAME, mainLoop)
					}
				}
				
			}
			else
			{
				
				if (useTimer)
				{
					fTimer.start()
				}
				else
				{
					addEventListener(Event.ENTER_FRAME, mainLoop, false, 0, true)
				}
				
			}
		
		}
		
		//
		//////////////////////////// KEY FUNCTIONS
		//
		
		//pause
		public function keyU_P():void
		{
			
			switch (gState)
			{
			
			case "pause": 
				//pause off
				gState = "game";
				interF.showScreen("pauseOff");
				dino.body.play();
				keys.unpauseKeys();
				break;
			
			case "game": 
				if (S.mod != "MP" && !Brain.talkVisible)
				{
					//pause on
					interF.showScreen("pauseOn");
					dino.body.stop();
					gState = "pause";
					keys.pauseKeys();
				}
				break;
			
			case "extinct": 
				//continue
				if (sys2.stats.cont != 0)
				{
					sys2.stats.cont--;
					newLevel(true, true)
				}
				break;
			
			case "endLevel": 
				//next level
				if (sys2.levelStats.go)
				{
					sys2.levelStats.remove();
					newLevel(false, true)
				}
				break;
			
			case "win": 
			case "escaped": 
				//restart and go to options
				if (S.mod == "SpeedRun")
				{
					interF.mem.opt = true;
					keyU_R()
				}
				break;
				
			}
		
		}
		
		//mute
		public static var allowMute:Boolean = true;
		
		public function keyU_M():void
		{
			
			if (Brain.allowMute && !Brain.talkVisible)
				sys.audio.mute();
		
		}
		
		//reset
		public function keyU_R():void
		{
			
			if (S.mod == "MP")
			{
				
				if (sys2.levelStatsMP != undefined)
				{
					sys2.levelStatsMP.remove()
				}
				restart();
				
			}
			else
			{
				
				if (gState == "win" || Brain.escaped)
				{
					sys2.levelStats.remove()
				}
				if ((gState != "game" && gState != "HS" && gState != "endLevel") || Brain.escaped)
				{
					restart();
				}
				
			}
		
		}
		
		public function asteroid(event:TimerEvent)
		{
			
			//asteroid activates impact function
			if (timer != null)
			{
				
				timer.removeEventListener(TimerEvent.TIMER, asteroid);
				timer.stop();
				timer = null;
				
			}
			
			create({nam: "Asteroid", px: dino.pos.x / worldBG.xFactor + worldBG.xA + (rand(100, 200)), py: (dino.pos.y / worldBG.yFactor) - 75, depth: ["worldBG", "bg"]})
		
		}
		
		public function initImpact()
		{
			
			if (S.mod == "MP")
			{
				if (interF.newRace.act)
				{
					sys.MP.C.send("IM")
				}
			}
			else
			{
				impact()
			}
		
		}
		
		public static var impacted:Boolean = false;
		
		public function impact()
		{
			
			Brain.impacted = true;
			sys.audio.ply("impact", .6, false);
			
			if (!Brain.freeRun)
			{
				//keys now here
				if (S.mod == "MP")
					keys.addKeys({exe: this, vals: {P: [32], R: [27], M: [77]}, exeD: false, exeU: true});
				else
					keys.addKeys({exe: this, vals: {P: [32, 27], R: [13], M: [77]}, exeD: false, exeU: true});
				
				if (S.mod == "MP")
				{
					
					interF.showScreen("go");
					sys.MP.startTime = getTimer();
					dino.mov = true;
					for each (var dn:Object in rmDinos)
					{
						dn.mov = true
					}
					doom.go = true;
					
				}
			}
			
			sys2.impact = new Impact(this);
			world.shakeC = 80;
			
			if (!Brain.freeRun)
			{
				timer = new Timer(500, 1);
				timer.addEventListener(TimerEvent.TIMER, startAction, false, 0, true);
				timer.start();
			}
		
		}
		
		public function impact2()
		{
			
			if (sys2.impact2 != undefined)
			{
				sys2.impact2.restart()
			}
			else
			{
				sys2.impact2 = new Impact2(this)
			}
		
		}
		
		public function startAction(event:TimerEvent)
		{
			
			timer.stop();
			timer.removeEventListener(TimerEvent.TIMER, startAction);
			timer = null;
			
			//theme music
			sys.audio.stopBG();
			sys.audio.startMusic();
			
			//birds?
			if (rand(0, 0) == 0)
			{
				createBirds(3, 15)
			}
			if (!S.df)
			{
				if (S.mod == "MP")
				{
					if (rand(0, 1) == 0)
					{
						createDactyls(1, 2);
					}
				}
				else
				{
					createDactyls(2, 4);
				}
			}
		
			//init keys for pause and reset
			//used to be here
		
		}
		
		public function resetFocus():void
		{
			stage.focus = this;
		}
		
		public function restart()
		{
			
			lvlV = false;
			S.testRun = false;
			interF.checkFRInfo();
			interF.hideSpeech();
			Brain.escaped = false;
			if (S.mod == "MP" && xgen && mpGames >= 2)
			{
				
				//show ad
				mpGames = 0;
				interF.current = "Ad";
				sys.MP.current = "Ad";
				gState = "Ad";
				interF.showInterX("Ad");
				
			}
			else
			{
				
				gState = "pause";
				sys.audio.solo = 0;
				sys.audio.stopBG();
				cleanup(true, false);
				interF.showScreen("main");
				interF.showInterX(1);
				keys.addKeys({exe: interF, vals: {D: [13]}, exeD: false, exeU: true});
				//looper("stop");
				
				//show milestones?
				if (sys2.stats.lvlMS.length != 0 && S.lastLvl)
				{
					interF.showMS()
				}
				
				//MP?
				trace(9999999);
				if (S.mod == "MP")
				{
					sys.MP.returnToLobby()
				}
				
			}
		
		}
		
		public function cleanup(lvl, retry)
		{
			
			if (!world)
				return;
			
			//reset systems
			keys.resetKeys();
			ids = 0;
			for each (var s in sys2)
			{
				s.remove()
			} // this will not remove stats
			
			//stop all sounds
			sys.audio.stp(1);
			sys.audio.stp(2);
			sys.audio.stp(3);
			sys.audio.stp(4);
			
			if (lvl)
			{
				
				world.removeRooms();
				worldBG.removeRooms();
				
				doom.removeClouds();
				
				deleteLib();
				emptyGarbage();
				
				world.remove2();
				worldBG.remove2();
				
				container.removeChild(sky);
				container.removeChild(worldBG);
				container.removeChild(weather);
				container.removeChild(world);
				if (S.mod != "Challenge")
				{
					removeProgBar()
				}
				
				sky = null;
				worldBG = null;
				weather = null;
				world = null;
				
				dino = null;
				rmDinos = null;
				camFocus = null;
				doom = null;
				
				lib = {};
				
				if (!retry)
				{
					
					sys.rData.resetData();
					sys.wData.resetData();
					sys.vData.resetData();
					
				}
				
			}
		
		}
		
		public function removeProgBar()
		{
			
			if (sys2.progBar != null)
			{
				
				interF.removeChild(sys2.progBar);
				sys2.progBar.nulls();
				delete sys2.progBar;
				
			}
		
		}
		
		public function traceWorld()
		{
			
			if (world != null)
			{
				
				var nc = world.numChildren;
				for (var i = 0; i < nc; i++)
				{
					
					var thing = world.getChildAt(i);
					//trace ("///"+i+thing)
					var nc2 = thing.numChildren;
					for (var i2 = 0; i2 < nc2; i2++)
					{
						
						var thing2 = thing.getChildAt(i2);
							//trace (thing2)
						
					}
					
				}
				
			}
		
		}
		
		public function startGame()
		{
			
			interF.stopTicker();
			
			Brain.impacted = false;
			Brain.escaped = false;
			
			if (Brain.ENABLE_ZINC) Mouse.hide();
			lvlV = true;
			sys.audio.ff = false;
			S.difNum = ["Easy", "Medium", "Hard", "Insane"].indexOf(S.dif) + 1;
			S.lvl = (S.mod == "SpeedRun") ? sys2.stats.speedRuns[0] : BEGIN_LEVEL;////////////////////////////////////////////////////////////////////////////
			sys2.stats.newGame(S.difNum);
			sys2.stats.saveGame();
			interF.current = "Race";
			newLevel(false, false);
		
		}
		
		public function initMPGame()
		{
			
			//define game vars
			S.difNum = [0, 2, 2, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4][sys.MP.Self.lvl];
			S.lvl = interF.newRace.zone;
			defineLvlSet(sys.gData.GD.MP[S.lvl], [0, .8, 1, 1.25, 1.5][S.difNum])
		
		}
		
		public function startMPGame()
		{
			
			interF.stopTicker();
			
			Brain.impacted = false;
			
			mpids = (interF.newRace.curP.indexOf(sys.MP.Self.id)) * 250;
			sys.MP.current = "race";
			S.difNum = [0, 2, 2, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4][sys.MP.Self.lvl];
			S.lvl = interF.newRace.zone;
			sys2.stats.newMPGame();
			newLevel(false, false);
			interF.current = "Race";
			//fps check
			newFPSCheck();
			sys.MP.startFPStimer();
		
		}
		
		public function newFPSCheck()
		{
			
			if (sys2.fpsCheck == undefined)
			{
				sys2.fpsCheck = new FPSCheck(this)
			}
		
		}
		
		//df = difficulty factor
		public function defineLvlSet(dat, df)
		{
			
			S.xNum = Math.round(dat.xNum * df);
			S.yNum = Math.round(dat.yNum * df);
			S.sp = dat.sp;
			S.st = dat.st;
			S.auto = false;
			if (dat.endID != undefined)
			{
				S.endID = dat.endID
			}
			S.spCH = Math.round(dat.spv[0] * df);
			S.spMX = Math.round(dat.spv[1] * df);
			S.lv = dat.lvl;
			S.bg = dat.col[1];
			
			//terrain guide
			S.tt = (dat.tt != undefined) ? dat.tt.slice() : ["G", "G", "R", "T", "T"];
			S.tg = dat.tg.slice();
			var bA:Array = dat.tg[0].slice();
			S.tg.shift();
			S.tg.unshift(bA);
			for (var ti = 0; ti < 2; ti++)
			{
				
				var oNum2 = S.tg[0][ti];
				S.tg[0].splice(ti, 1, Math.round(oNum2 * df))
				
			}
			for (var i = 1; i < S.tg.length; i += 2)
			{
				var oNum = S.tg[i];
				S.tg.splice(i, 1, Math.round(oNum * df));
				
			}
			//mandatory special area
			S.msp = {};
			S.msp.id = dat.msp.id;
			S.msp.px = Math.round(dat.msp.px * df);
			S.msp.py = Math.round(dat.msp.py * df);
			
			//special speedrun+MP exceptions
			S.LZ = (dat.opt.indexOf("LZ") > -1) ? true : false;
			S.SS = (dat.opt.indexOf("SS") > -1) ? true : false;
			S.CS = (dat.opt.indexOf("CS") > -1) ? true : false;
			S.JJ = (dat.opt.indexOf("JJ") > -1) ? true : false;
			S.NS = (dat.opt.indexOf("ns") > -1) ? true : false;
			
			//arrange new world if we are the MP creator
			if (S.mod == "MP")
			{
				
				checkSeed();
				
				//init world layers
				sky = new L1();
				worldBG = new WorldBG(this);
				weather = new Weather();
				world = new World(this);
				
				//create lvlSTR and arrange world
				var lvlSTR:String = world.switchWorld("World1", false);
				
				//split if over 8K, then send to players
				var l = Math.ceil(lvlSTR.length / 8000);
				
				for (var ii:int = 1; ii <= l; ii++)
				{
					sys.MP.sendToRoom("LD" + ((ii == l) ? "X" : ii) + "-" + S.xNum + "_" + S.yNum + "-" + lvlSTR.substr((ii - 1) * 8000, 8000))
				}
				;
				
			}
		
		}
		
		public function checkSeed():void
		{
			if (S.mod == "Challenge" && S.lvl != 1)
				return;
			if (Brain.useSeed)
			{
				Rndm.seed = useSeed;
			}
			else
			{
				Rndm.seed = Math.round(Math.random() * (999999 - 100000)) + 100000;
			}
		}
		
		public var forceHat:String = null;
		
		// MP function that calls startMPGame() when all level info is distributed
		
		public function newLevel(retry, lvl)
		{
			
			trace("new level");
			
			Brain.dinoGrabbed = false;
			//trace ("newLevel")
			sys.audio.solo = 0;
			//looper("stop");
			gState = "pause";
			hc = 1;
			endLevel = false;
			if (S.mod != "SpeedRun" && S.mod != "MP" && !retry)
			{
				S.lvl++
			}
			c = 0;
			sys2.stats.newLevel();
			
			cleanup(lvl, retry);
			
			trace("////", S.mod);
			
			//define level settings that MP creators don't send
			var df = (S.mod == "Challenge") ? 1 : [0, .8, 1, 1.25, 1.5][S.difNum];
			
			var dat:Object;
			switch (S.mod)
			{
			case "Challenge": 
				dat = sys.gData.GD[S.mod][S.dif]["Level" + S.lvl];
				S.lvls = sys.gData.GD[S.mod][S.dif].Levels;
				break;
			case "PlanetD": 
				dat = sys.gData.GD["Challenge"]["PlanetD"]["Level" + S.lvl];
				S.lvls = sys.gData.GD["Challenge"]["PlanetD"].Levels;
				break;
			case "SpeedRun": 
			case "MP": 
				dat = sys.gData.GD[S.mod][S.lvl];
				S.lvls = 1;
				break;
			case "Halloween": 
				dat = sys.gData.GD["Challenge"]["Halloween"]["Level" + S.lvl];
				S.lvls = sys.gData.GD["Challenge"]["Halloween"].Levels;
				break;
			}
			
			//var dat:Object=(S.mod=="Challenge")?sys.gData.GD[S.mod][S.PD ? "PlanetD" : S.dif]["Level"+S.lvl]:sys.gData.GD[S.mod][S.lvl];
			S.BC = (dat.opt.indexOf("bc") > -1) ? true : false;
			df = S.BC ? 1 : df;
			//
			S.mods = (S.mod == "MP") ? [] : sys2.stats.actMods.slice();
			if (S.mod == "MP" && !interF.newRace.act)
			{
			}
			else
			{
				S.xNum = Math.round(dat.xNum * df);
				S.yNum = Math.round(dat.yNum * df)
			}
			//S.lvls=(S.mod=="Challenge")?sys.gData.GD[S.mod][S.PD ? "PlanetD" : S.dif].Levels:1
			S.sky = dat.col[0];
			S.bg = dat.col[1];
			S.colorV = dat.col[2];
			S.bb = (dat.opt.indexOf("bb") > -1) ? true : false;
			S.rs = (dat.opt.indexOf("rs") > -1) ? true : false;
			S.mt = (dat.opt.indexOf("mt") > -1) ? true : false;
			S.tr = (dat.opt.indexOf("tr") > -1) ? true : false;
			S.pa = (dat.opt.indexOf("pa") > -1) ? true : false;
			
			forceHat = null;
			
			//gore
			S.gore = (dat.opt.indexOf("gr") > -1) ? true : false;
			//punpkins
			S.pk = (dat.opt.indexOf("pk") > -1) ? true : false;
			//if (S.pk)
			//forceHat = "hhc";
			
			//flyin
			S.fl = (dat.opt.indexOf("fl") > -1) ? true : false;
			//if (S.fl)
			//forceHat = "hha";
			
			//ghosts
			S.gh = (dat.opt.indexOf("gh") > -1) ? true : false;
			//if (S.gh)
			//forceHat = "ss";
			
			//dusk & slaughter
			S.dusk = (dat.opt.indexOf("nt2") > -1) ? true : false;
			S.sl = (dat.opt.indexOf("sl") > -1) ? true : false;
			//if (S.sl)
			//forceHat = "j";
			
			if (S.mod == "MP")
			{
				forceHat = null;
			}
			
			//doom follow
			S.df = (dat.opt.indexOf("df") > -1) ? true : false;
			//autumn
			S.aut = (dat.opt.indexOf("aut") > -1) ? true : false;
			
			S.lv = dat.lvl;
			S.dCH = (dat.dch != undefined) ? Math.round(dat.dch / df) : 0;
			S.rdCH = (dat.rdch != undefined) ? dat.rdch : 4000 - (S.lv * 500);
			S.rdCH = Math.round(S.rdCH / df);
			S.meteors = (S.mods.indexOf("H") != -1) ? true : false;
			S.mtCH = (S.meteors) ? 50 : Math.round((dat.mtch != undefined ? dat.mtch : (2000 - (S.lv * 250))) / df);
			S.night = ((S.mods.indexOf("G") != -1) || (dat.opt.indexOf("nt") != -1)) ? true : false;
			S.balloons = (S.mods.indexOf("F") != -1 || (dat.opt.indexOf("bl") != -1)) ? true : false;
			S.lowGrav = (S.mods.indexOf("E") != -1 || (dat.opt.indexOf("lg") != -1)) ? true : false;
			S.V = (S.colorV == "V") ? true : false;
			sys.audio.music = dat.music;
			
			if (dat.bonus != undefined)
			{
				S.winBonus = dat.bonus.slice()
			}
			interF.lvlName = dat.nam;
			interF.lvlDesc = dat.desc == undefined ? "" : dat.desc;
			
			//cheat flag?
			//trace ("/////check mods", S.mods)
			S.cheat = false;
			for each (var mod in S.mods)
			{
				if (["A", "B", "C", "D", "E", "F"].indexOf(mod) != -1)
				{
					S.cheat = true;
					break
				}
			}
			if (Brain.freeRun)
				S.cheat = true;
			
			//mode vars
			switch (S.mod)
			{
			
			case "Challenge": 
			case "PlanetD": 
			case "Halloween": 
				S.bm = dat.bm;
				S.ds = dat.ds;
				break;
			
			case "SpeedRun": 
				S.bm = 5 + S.lv + S.difNum;
				//S.ds=.00000001;
				S.ds = 7.5 + (S.lv * .16) + S.difNum;
				break;
			
			case "MP": 
				S.bm = 100;
				//S.ds=0.1;
				var rclvl:int = interF.newRace.lvl;
				if (rclvl > 5)
				{
					rclvl = 5
				}
				S.ds = 7 + (S.lv * .15) + (rclvl * .75);
				S.mtCH *= (2 / S.difNum);
				var l:int = sys.MP.Players.length;
				S.mtCH *= l;
				S.dCH *= l;
				S.rdCH *= l;
				break;
				
			}
			
			//overall dif adjust
			switch (S.mod)
			{
			
			case "MP": 
				S.ds += .1;
				break;
			case "SpeedRun": 
				S.ds += .2;
				break;
			case "Challenge": 
			case "PlanetD": 
			case "Halloween": 
				S.ds += .3;
				break;
				
			}
			
			if (S.balloons)
			{
				S.bm = 100
			}
			
			//special speedrun+MP exceptions
			S.LZ = (dat.opt.indexOf("LZ") > -1) ? true : false;
			S.SS = (dat.opt.indexOf("SS") > -1) ? true : false;
			S.CS = (dat.opt.indexOf("CS") > -1) ? true : false;
			S.HR = (dat.opt.indexOf("HR") > -1) ? true : false;
			S.PA = (dat.opt.indexOf("PA") > -1) ? true : false;
			S.RT = (dat.opt.indexOf("RT") > -1) ? true : false;
			S.HH = (dat.opt.indexOf("HH") > -1) ? true : false;
			S.RM = (dat.opt.indexOf("RM") > -1) ? true : false;
			S.ED = (dat.opt.indexOf("ED") > -1) ? true : false;
			S.SF = (dat.opt.indexOf("SF") > -1) ? true : false;
			S.NL = (dat.opt.indexOf("NL") > -1) ? true : false;
			S.PL = (dat.opt.indexOf("PL") > -1) ? true : false;
			S.BL = (dat.opt.indexOf("BL") > -1) ? true : false;
			S.NS = (dat.opt.indexOf("ns") > -1) ? true : false;
			
			trace("//********", S.NS);
			
			//if we arent the creator
			
			if (S.mod != "MP")
				interF.newRace.act = false;
			
			if (!interF.newRace.act)
			{
				
				//if its not multiplayer, get more vars
				if (S.mod != "MP")
				{
					defineLvlSet(dat, df)
				}
				
				//init world layers
				sky = new L1();
				worldBG = new WorldBG(this);
				weather = new Weather();
				world = new World(this);
				
				//make a new level
				checkSeed();
				world.switchWorld("World1", retry);
				
			}
			
			//adjust night bg
			if (S.night)
			{
				
				if (S.sky < 10 || S.sky == 30)
				{
					S.sky += 10
				}
				if (S.sky == 10)
				{
					S.sky = 21
				}
				switch (S.bg)
				{
				
				case "A": 
					S.bg = "N";
					break;
				case "B": 
					S.bg = "O";
					break;
				case "C": 
					S.bg = "P";
					break;
				case "F": 
					S.bg = "Q";
					break;
				case "G": 
					S.bg = "Q";
					break;
				case "H": 
					S.bg = "R";
					break;
				case "I": 
					S.bg = "S";
					break;
				
				case "T": 
					S.bg = "W";
					break;
				case "U": 
					S.bg = "Y";
					break;
				case "V": 
					S.bg = "Z";
					break;
					
				}
				
			}
			
			//sky color
			sky.graphic.gotoAndStop(S.sky);
			
			//add world elements to display
			container.addChild(sky);
			container.addChild(worldBG);
			container.addChild(weather);
			container.addChild(world);
			if (VAR == "MJ")
			{
				weather.x = -80;
				sky.x = -80
			}
			if (VAR == "KG")
			{
				weather.x = -50;
				sky.x = -50
			}
			setChildIndex(interF, this.numChildren - 1);
			
			//keys
			keys.addKeys({exe: interF, vals: {D: [13]}, exeD: false, exeU: true});
			
			//dino +(sys.MP.Self.id==101?200:0)
			//46000  / +1000   //1200+xa
			var xa:Number = (S.mod == "MP") ? (sys.MP.getPVar(sys.MP.Self.id, "indx") * 12) : 0;
			dino = create({nam: "Raptor", px: S.BC ? 2800 : 1200 + xa + Config.XO, py: S.BC ? 500 : (dinoY - 100 + Config.YO), remote: false, MP: (S.mod == "MP") ? true : false, clr: (S.mod == "MP") ? sys.MP.Self.clr : sys2.stats.clr, hat: (S.mod == "MP") ? sys.MP.Self.hat : sys2.stats.hat, depth: ["world", "main"]});
			
			//flip?
			//S.GL = dino.o.hat == "vv";
			if (S.GL)
			{
				flip();
				keys.addKeys({exe: dino, vals: {J: [40, 83], L: [37, 65], R: [39, 68], D: [38, 87], S: [16], 1: [49], 2: [50], 3: [51]}, exeD: true, exeU: true});//J:38,
			}
			else
			{
				unFlip();
				keys.addKeys({exe: dino, vals: {D: [40, 83], L: [37, 65], R: [39, 68], J: [38, 87], S: [16], 1: [49], 2: [50], 3: [51]}, exeD: true, exeU: true});//J:38,
				
			}
			
			//dino keys
			//camera on this player
			camFocus = dino;
			
			//extra MP dinos
			if (S.mod == "MP")
			{
				
				rmDinos = {};
				S.curP = interF.newRace.curP.slice();
				//trace ("///// CURP ",S.curP)
				for each (var id:String in S.curP)
				{
					
					var mpo:Object = sys.MP.getPVar(id, "obj");
					if (mpo == -1)
					{
						
						mpo = {nam: "Dino" + rand(1, 10000), id: id, clr: ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J"][rand(0, 9)], hat: "xx"};
						sys.MP.Players.push(mpo);
						
					}
					//trace (mpo.nam, mpo.clr, mpo.hat);
					if (id != sys.MP.Self.id)
					{
						rmDinos["d" + id] = create({nam: "Raptor", px: 1200 + (sys.MP.getPVar(id, "indx") * 12), py: dinoY - 100, remote: true, MP: true, mpID: id, mpNam: mpo.nam, clr: mpo.clr, hat: mpo.hat, depth: ["world", "main"]})
					}
					
				}
				
			}
			if (S.mod != "Challenge" && (S.showProg || S.mod == "MP"))
			{
				
				sys2.progBar = new ProgBar(dino, S.mod == "MP" ? rmDinos : {});
				sys2.progBar.x = 36 + (Config.WEB ? 0 : 50);
				sys2.progBar.y = 432 + (Config.WEB ? 0 : 50);
				interF.addChild(sys2.progBar);
				
			}
			
			///////////start level
			interF.showInterX(1);
			
			//DOOM
			doom = new Doom(this, S.mod == "MP" ? false : true);
			
			//action
			if ((S.lvl == 1 || S.mod == "SpeedRun" || S.mod == "MP") && !Brain.freeRun)
			{//&&S.lvl!="U"
				
				//incoming aasteroid
				if (S.mod == "MP")
				{
					interF.lvlName = "Get Ready..."
				}
				sys.audio.ply("incoming", .4, false);
				timer = new Timer(2500, 1);
				timer.addEventListener(TimerEvent.TIMER, asteroid, false, 0, true);
				timer.start();
				sys.audio.startBG(false);
				
			}
			else
			{
				
				//if (S.lvl=="U") { doom.go=false }
				
				//init keys for pause, reset, mute and auto-run
				if (S.mod == "MP")
				{
					keys.addKeys({exe: this, vals: {P: [32], R: [27], M: [77]}, exeD: false, exeU: true});
					if (Brain.freeRun)
					{
						sys.MP.startTime = getTimer();
						dino.mov = true;
						for each (var dn:Object in rmDinos)
						{
							dn.mov = true
						}
					}
				}
				else
				{
					keys.addKeys({exe: this, vals: {P: [32, 27], R: [13], M: [77]}, exeD: false, exeU: true});
				}
				
				//theme music
				sys.audio.stopBG();
				sys.audio.startMusic();
				
			}
			
			//special
			/*switch (S.mod+S.lvl) {
			
			   case "Challenge6":
			   createBirds (6,12)
			   break;
			
			   case "Challenge7":
			   createBirds (20,30)
			   break;
			
			   }*/
			
			interF.resetFuncs();
			if (!S.BC)
			{
				interF.showScreen("levelStart")
			}
			
			//define par
			sys2.stats.par = Math.round(((S.xNum * 801) - doom.px) / S.ds);
			
			//focus again
			if (VAR != "WR")
			{
				stage.focus = this
			}
			
			//start mainLoop
			gState = "game";
			//looper("start");
		
			// DEV UTILITIES
			///////////////////////////////////
		
			//fps = new FPSCounter();
			//fps.x = 10;
			//fps.y = 10;
			//addChild(fps);
		
		}
		
		private function unFlip():void
		{
			if (flipped)
			{
				bmpMatrix.scale(1, -1);
				bmpMatrix.translate(0, 450);
				flipped = false;
			}
		}
		
		private function flip():void
		{
			if (!flipped)
			{
				bmpMatrix.scale(1, -1);
				bmpMatrix.translate(0, 450);
				flipped = true;
			}
		}
		
		//SCREEN
		
		public function toggleFullScreen():void
		{
			stage.quality = StageQuality.LOW;
			//stage.scaleMode = StageScaleMode.NO_SCALE;
			
			if (fullScreen)
			{
				fullScreen = false;
				stage.displayState = StageDisplayState.NORMAL;
					//Brain.wide = false;
					//mag = 1;
					//adjustMag();
			}
			else
			{
				
				//Brain.left = 0 - (Brain.MONITOR_W - Brain.DIMENSIONS.x)/2;
				//Brain.top = 0 - (Brain.MONITOR_H - Brain.DIMENSIONS.y)/2;
				stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
				//this.onResize(null);
				//mag = (Math.floor((MONITOR_W - 801) / 267) * (1/3)) + 1;
				//adjustMag();
				fullScreen = true;
			}
		}
		
		public function adjustMag():void
		{
			var screenX:int = Brain.left + ((MONITOR_W - (801 * mag)) / 2);
			var screenY:int = Brain.top + ((MONITOR_H - (450 * mag)) / 2);
			bmp.scaleX = mag;
			bmp.scaleY = mag;
			interF.scaleX = mag;
			interF.scaleY = mag;
			bmp.x = interF.x = screenX;
			bmp.y = interF.y = screenY;
			
			if (mag == 1)
			{
				
			}
		}
		
		//
		//////////////////////////// MAIN LOOP
		//
		
		//TimerEvent
		private function mainLoop(event:flash.events.Event):void
		{
			
			if (stage.focus)
			{
				if (stage != stage.focus)
				{
					if (!stage.focus.root)
					{
						stage.focus = stage
					}
				}
			}
			
			oldStageWidth = stage.stageWidth;
			oldStageHeight = stage.stageHeight;
			
			interF.update();
			//trace (c++)
			
			if (gState != "pause")
			{
				
				try
				{
					
					c++;
					//fps.exe();
					
					//loop all sys2 items
					for each (var s:Object in sys2)
					{
						s.main()
					}
					
					// ACTIONS ON ALL LIB ITEMS
					for each (var a:Object in lib)
					{
						
						var ar:Object = a.refs
						
						//exe main function of every lib item
						for each (var r:Object in ar)
						{
							r.main()
						}
						
						//COLLISIONS + REACTIONS
						//define type A
						var id:Array = a.iData;
						if (id != null)
						{
							
							var ash:String = ar[0].ph.sh;
							var nn:Boolean = ar[0].NN
							
							//actions for every ref item
							var l:uint = ar.length;
							for (var i:uint = 0; i < l; i++)
							{
								
								var nW:Boolean;
								var nO:Boolean = false;
								var aa:Object = ar[i];
								if (aa.inter)
								{
									
									//define type B
									for (var k:uint = 0; k < id.length; k++)
									{
										
										var b:String = id[k].nam;
										var acts:Array = id[k].acts;
										if (b == "Room")
										{
											
											//room colliions
											nW = sys.inter[ash + (aa.o.typ == "Dino" ? "2" : "") + "_room"](aa, acts);
											
										}
										else if (lib[b] != undefined)
										{
											
											//object collisions
											var br:Object = lib[b].refs;
											var fn:String = ash + "_" + br[0].ph.sh;
											var ll:uint = br.length;
											var iii:uint = (ar[0] == br[0]) ? i + 1 : 0;
											//
											for (var ii:uint = iii; ii < ll; ii++)
											{
												
												var bb:Object = br[ii];
												if (bb.inter)
												{
													
													var nearO:Boolean = sys.inter[fn](aa, bb, acts);
													if (nearO)
													{
														nO = true
													}
													
												}
												
											}
											
										}
										
									}
									
									//near
									if (nn)
									{
										aa.near = (nW || nO) ? true : false;
										aa.nearG = nW;
									}
									
								}
								
							}
							
						}
						
						//FINAL FUNCTION OF ALL LIB ITEMS
						for each (var rr:Object in ar)
						{
							rr.finalActions()
						}
						
					}
					
					if (res)
					{
						res = false;
						restart();
						return
					}
					if (ret)
					{
						ret = false;
						newLevel(true, true);
						return
					}
					if (goBeach)
					{
						goBeach = false;
						newLevel(false, true);
						return
					}
					
					///////////WORLD ACTIVITIES
					
					//random stuff
					if (rand(0, 1000) == 0)
					{
						createBirds(1, 10)
					}
					if (rand(0, 5000) == 0)
					{
						createRain()
					}
					
					if (dino.y > 450)
					{
						
						if (rand(0, S.rdCH) == 0)
						{
							createDactylRed()
						}
						if (rand(0, ((S.dCH != 0) ? S.dCH : (dino.y / 2) + 200)) == 0)
						{
							createDactyls(1, 4)
						}
						if (rand(0, ((S.mt) ? 130 - (S.lv * 10) : (1250 - (S.lv * 150)))) == 0)
						{
							createMeteor()
						}
						if (rand(0, S.mtCH) == 0)
						{
							createMeteorite()
						}
						if (rand(0, ((S.PA) ? 130 - (S.lv * 10) : 2500)) == 0)
						{
							createPara()
						}
						if (S.V)
						{
							if (rand(0, 15) == 0)
							{
								createAsh(1, 3)
							}
						}
						
						//critters
						if (rand(0, (S.gh ? 150 : 300)) == 0)
						{
							createLizard2()
						}
						if (rand(0, 300) == 0)
						{
							createRunner2()
						}
						
						//special stuff
						if (S.LZ)
						{
							if (rand(0, 38 - (S.difNum * 4)) == 0)
							{
								createLizard()
							}
						}
						if (S.SS)
						{
							if (rand(0, 75 - (S.difNum * 5) + (S.NL ? 1000 : 0)) == 0)
							{
								createStego()
							}
						}
						if (S.CS)
						{
							if (rand(0, 80 - (S.difNum * 5) + (S.NL ? 1000 : 0)) == 0)
							{
								createCera()
							}
						}
						if (S.HR)
						{
							if (rand(0, 120 - (S.difNum * 10)) == 0)
							{
								createHR()
							}
						}
						if (S.BL)
						{
							if (rand(0, 50 - (S.difNum * 3)) == 0)
							{
								createHR(true)
							}
						}
						
						if (S.gh)
						{
							if (rand(0, 10) == 0)
							{
								createBone();
							}
							
						}
						
						if (S.df)
						{
							if (rand(0, 750) == 0)
							{
								createStego();
							}
						}
						
					}
					
					//DOOM!
					doom.main(dino.x, dino.y);
					
					//SCROLL WORLD
					world.moveCam(camFocus);
					
					//trace (gState);
					//switch to game state if escape sanctuary
					if (gState == "win" && !S.BC)
					{
						if (dino.x < (world.xMax * -1) - 2000)
						{
							Brain.escaped = true;
							gState = "escaped";
						}
					}
					
					//EMPTY GARBAGE
					emptyGarbage();
					
					//end level?
					if (endLevel && !doom.win)
					{
						if (S.mod == "MP")
						{
						}
						else
						{
							levelStats()
						}
					}
					
						//var a = null
						//trace (a.b);
					
						//error handling
				}
				catch (e:Error)
				{
					
					if (Config.LOG_ERRORS)
					{
						logError(Config.VERSION + e.getStackTrace());
					}
					else if (Config.SHOW_ERRORS)
					{
						interF.oops(Config.VERSION + e.getStackTrace());
						keys.resetKeys();
					}
					else
					{
						Brain.log(e.getStackTrace());
					}
					
				}
				
			}
			if (Config.RENDER_GAME_TO_BITMAP)
				bmp.bitmapData.draw(container, bmpMatrix, null, null, null, false);
		}
		
		public static var escaped:Boolean = false;
		
		// update remore objs
		public function updateRemoteObj(str)
		{
			
			var oA:Array = str.split(";");
			var nam:String = oA[0];
			var mpid:int = Number(oA[1]);
			if (lib[nam] != undefined)
			{
				
				var refs:Array = lib[nam].refs;
				for each (var obj:Object in refs)
				{
					if (obj.o.remote)
					{
						if (obj.o.mpid == mpid)
						{
							obj.remoteUpdate(oA[2], oA[3], oA[4], oA[5]);
							break
						}
					}
				}
				
			}
		
		}
		
		//
		//////////////////////////// CREATORS
		//
		
		public function createR(str)
		{
			
			//trace (str);
			var o:Object = {};
			var pms:Array = str.split(";");
			for each (var pm:String in pms)
			{
				
				var pA:Array = pm.split(":");
				o[pA[0]] = (pA[0] == "nam" || pA[0] == "rdt") ? pA[1] : Number(pA[1]);
				
			}
			
			//dont create this object if its too far away from us (or visible)
			var allow:Boolean = false;
			var distX:Number = o.px - dino.x;
			var distY:Number = o.py - dino.y;
			if (distX > (o.nam == "DactylFG" ? -2400 : -1600) && distX < 2400)
			{
				allow = true
			}
			if (distX > -200 && distX < 700 && distY > -300 && distY < 300)
			{
				allow = false
			}
			if (allow)
			{
				
				//if this is from rData, pass the actual rData object so we dont double create
				//also check for rd.ex since when dinos are neck and neck, room items may be created in the split second before the other dino broadcasts its creation
				if (o.rdt != "0")
				{
					
					for each (var rd:Object in sys.rData.r.World1[o.rdt])
					{
						
						if (o.nam == rd.nam && o.px == Math.round(rd.px) && !rd.ex)
						{
							
							rd.rData = true;
							rd.remote = true;
							
							//special additions
							if (o.am != undefined)
							{
								rd.am = o.am
							}
							rd.mpid = o.mpid;
							
							//create with regular function
							create(rd);
							break;
							
						}
						
					}
					
				}
				else
				{
					
					o.remote = true;
					o.rd = true;
					o.depth = ["world", "main"];
					create(o);
					
				}
				
			}
		
		}
		
		public function create(o:Object)
		{
			
			var tmpObj:Object;
			
			//dont allow too many boulders to be created, esp if doom is near
			var allow:Boolean = true;
			if (o.nam == "Boulder")
			{
				if (lib.Boulder != undefined)
				{
					
					if (!o.cr && !o.dact)
					{
						
						var bm = (doom.dif > 1500) ? S.bm : 0;
						if (lib.Boulder.refs.length > bm && o.drop != true)
						{
							allow = false
						}
						
						if (S.df)
							allow = false;
						
					}
					
				}
			}
			if (o.nam == "Meteorite")
			{
				if (lib.Meteorite != undefined)
				{
					
					if (!o.cr && o.lvl != 5)
					{
						
						var bm2 = (doom.dif > 1500) ? S.bm : 0;
						if (lib.Meteorite.refs.length > bm2)
						{
							allow = false
						}
						
						if (S.df)
							allow = false;
						
					}
					
				}
			}
			
			if (allow)
			{
				
				//assign id
				o.id = ids++;
				o.ex = true;
				
				// create obj
				tmpObj = sys.factory["create_" + o.nam](o, this);
				
				// add to display list?
				var depth:Array = tmpObj.o.depth;
				if (depth[0] != 0)
				{
					if (!o.front)
					{
						this[depth[0]][depth[1]].addChildAt(tmpObj, 0)
					}
					else
					{
						this[depth[0]][depth[1]].addChild(tmpObj)
					}
				}
				
				// add to library's proper type tracker and create new type if needed
				if (lib[o.nam] == undefined)
				{
					
					//init
					lib[o.nam] = {};
					lib[o.nam].refs = [];
					
					//add interaction data
					lib[o.nam].iData = sys.iData.main[o.nam];
					
						//interaction expections
					/*if (S.ED) {
					   if (o.nam == "Raptor") {
					   for (var i:int = 0; i < lib[o.nam].iData.length; i++) {
					   if (lib[o.nam].iData[i].nam == "DactylFG") {
					   lib[o.nam].iData.splice (i,1);
					   }
					   }
					   }
					   }*/
					
				}
				
				//push the object reference into library
				lib[o.nam].refs.push(tmpObj);
				
					//oc++;
					//trace ("create",tmpObj.o.nam,tmpObj.o.id,oc);
				
			}
			
			return tmpObj;
			tmpObj = null;
		
			//}
		
		}
		
		public function addClip(o)
		{
			
			var depth:Array = o.o.depth;
			if (depth[0] != 0)
			{
				this[depth[0]][depth[1]].addChild(o)
			}
		
		}
		
		// WIN!
		public function win()
		{
			
			if (Brain.freeRun && !doom.win)
			{
				if (S.mod == "MP")
				{
					var addScore:int = sys.MP.Self.lvl * Brain.MPMulti;
					sys.MP.Self.score += addScore;
					sys.MP.saveStats2();
					
					var txtAdd:String = "";
					var newLvl:int = sys.MP.getLvl(sys.MP.Self.score);
					if (newLvl > sys.MP.Self.lvl)
					{
						txtAdd = ", LEVEL UP" + (newLvl >= 6 ? " + NEW HAIR!" : "!")
					}
					
					interF.showFreerunMPPoints(addScore, txtAdd);
				}
				//gState="win";
				doom.win = true;
				return;
			}
			
			gState = "win";
			//adjust doom wall
			doom.win = true;
			//interface + stats
			if (S.mod != "MP")
			{
				interF.win();
				sys2.levelStats = new LevelStats(this, true)
			}
			else
			{
				sys.MP.finishRace()
			}
			sys2.stats.win();
			//cam adjust
			world.ya2 = 50;
			dino.str = true;
			//sound
			//sys.audio.ply ("safe",.5,true);
		
		}
		
		//end of level
		public function levelStats()
		{
			
			doom.win = true;
			gState = "endLevel";
			
			//stats
			sys2.levelStats = new LevelStats(this, false);
			interF.endLevel();
		
		}
		
		// GAME OVER
		public function gameOver()
		{
			
			if (S.mod == "MP")
			{
				
				sys.MP.sendToRoom("DD");
				if (sys2.levelStatsMP != undefined)
				{
					sys2.levelStatsMP.remove()
				}
				mpGames++;
			}
			
			if (S.mod == "MP")
			{
				sys2.progBar.doom2()
			}
			else if (S.showProg)
			{
				removeProgBar()
			}
			
			gState = "extinct";
			sys.audio.solo = 2;
			dino.noMov();
			dino.end = true;
			interF.showScreen("gameOver");
			
			Brain.frDoom = false;
		
		}
		
		//EXTRA CREATORS
		public function createBirds(min, max)
		{
			
			if (gState != "win" && doom.xMov != 0)
			{
				
				var num:uint = rand(min, max);
				for (var bd:uint = 1; bd <= num; bd++)
				{
					create({nam: "BirdBG", px: (dino.pos.x / worldBG.xFactor) - (rand(100, 300)) + worldBG.xA - (endLevel ? 500 : 0), py: dino.pos.y / worldBG.yFactor + (rand(-75, 125)), depth: ["worldBG", "fg"]})
				}
				
			}
		
		}
		
		public function createBF()
		{
			
			create({nam: "BirdFG", px: dino.pos.x + 300, py: dino.pos.y - 50, depth: ["world", "main"]})
		
		}
		
		public function createDactylRed()
		{
			
			if (!dino.ug && gState != "win" && (doom.xMov != 0 && doom.dif > 500 || Brain.freeRun))
			{
				
				var anyY:Boolean = S.HH && S.mod == "PlanetD" && Brain.dinoGrabbed;
				create({nam: "DactylRed", px: dino.pos.x + (Brain.freeRun ? 1000 : 1500), py: anyY ? rand(dino.pos.y - 250, dino.pos.y + 250) : dino.pos.y - 300, depth: ["world", "fg"]})
				
			}
		
		}
		
		public function createDactyls(min, max, red:Boolean = false)
		{
			
			if (red)
			{
				createDactylRed();
				return;
			}
			var allow:Boolean = true;
			if (S.mod == "MP")
			{
				
				for each (var dn:Object in rmDinos)
				{
					
					var dist:Number = dino.x - dn.x;
					if (dist < 1000 && dist > 200)
					{
						allow = false
					}
					
				}
				
			}
			if (!dino.ug && gState != "win" && (doom.xMov != 0 || Brain.freeRun) && allow)
			{
				
				//if (S.mod=="MP") { if (interF.newRace.act) {
				var num:uint = rand(min, max);
				if (S.pk)
				{
					num = 1
				}
				;
				var spawnBelow:Boolean = S.HH && Brain.dinoGrabbed;
				for (var bd:uint = 1; bd <= num; bd++)
				{
					create({nam: "DactylFG", px: dino.pos.x - rand(400, 500) - (endLevel ? 800 : 0), py: dino.pos.y + rand(-300, spawnBelow ? 300 : -50), front: true, depth: ["world", "main"]})
				}
					//}}
			}
			
			createBirds(1, S.HH ? 2 : 5);
		
		}
		
		public function createMeteor()
		{
			
			if (c > 250 && !S.BC)
			{
				
				var allow:Boolean = true;
				if (gState == "win" && S.endID == "XD")
				{
					allow = false
				}
				if (allow)
				{
					
					var d = (rand(0, 2) == 0) ? "bg" : "fg";
					create({nam: "Meteor", px: (dino.pos.x / worldBG.xFactor) + rand(-200, 300) + worldBG.xA, py: -200, d: d, depth: ["worldBG", d]})
					skyRed();
					
				}
				
			}
		
		}
		
		public function createMeteorite(large:Boolean = false)
		{
			
			if (!dino.ug && doom.dif > 500 && gState != "win" && c > 150 && dino.x < (world.xMax * -1) - 7500)
			{
				
				var dir:String = (rand(0, 1) == 0) ? "L" : "R";
				create({nam: "Meteorite", px: Math.round(dino.pos.x + (dino.vel.x * 30) + ((dir == "L") ? rand(-300, 300) : rand(200, 1000))), py: Math.round(dino.pos.y - 400), vx: Math.round(dino.vel.x / 2) + ((dir == "R") ? rand(-12, -3) : rand(6, 18)), vy: rand(0, 2), lvl: large ? 5 : rand(1, 3), rd: true, cr: true, depth: ["world", "fgx"]})
				skyRed();
				
			}
		
		}
		
		public function createBoulder(large:Boolean = false)
		{
			
			if (!dino.ug && doom.dif > 500 && gState != "win" && c > 150 && dino.x < (world.xMax * -1) - 5000)
			{
				
				var dir:String = (rand(0, 1) == 0) ? "L" : "R";
				create({nam: large ? "BoulderLG" : "Boulder", px: Math.round(dino.pos.x + (dino.vel.x * 30) + ((dir == "L") ? rand(-200, 0) : rand(0, 400))), py: Math.round(dino.pos.y - 400), vx: Math.round(dino.vel.x / 2) + ((dir == "R") ? rand(-10, -1) : rand(1, 10)), vy: rand(0, 2), lvl: rand(2, 5), rd: true, depth: ["world", "main"]})
				
			}
		
		}
		
		public function createHR(boulder:Boolean = false)
		{
			
			if (S.mod == "MP" && rand(0, 1) == 0)
			{
				return
			}
			
			if (!dino.ug && doom.dif > 500 && gState != "win" && c > 150 && dino.x < (world.xMax * -1) - 7500)
			{
				
				var r:int = rand(0, 10);
				if (boulder)
					r = 7;
				
				if (r >= 0 && r < 5)
				{
					
					//big from sky
					create({nam: "Meteorite", px: Math.round(dino.pos.x + rand(-300, 500)), py: Math.round(dino.pos.y - 400), vx: (dino.vel.x * .75) + rand(-10, 10), vy: rand(0, 4), lvl: 4, rd: true, cr: true, depth: ["world", "fgx"]})
					skyRed();
					
				}
				else if (r == 5)
				{
					
					//huge meteorite ahead
					create({nam: "Meteorite", px: Math.round(dino.pos.x + rand(1200, 1700)), py: Math.round(dino.pos.y - 400), vx: rand(2, 6), vy: rand(3, 5), lvl: 5, rd: true, cr: true, depth: ["world", "fgx"]})
					
				}
				else if (r > 5 && r < 10)
				{
					
					//big boulder ahead
					create({nam: "Boulder", px: Math.round(dino.pos.x + rand(1200, 1700)), py: boulder ? rand(dino.pos.y - 400, dino.pos.y - 200) : dino.pos.y - 400, vx: rand(1, 6), vy: rand(0, 4), lvl: boulder ? rand(3, 5) : 5, rd: true, cr: true, depth: ["world", "main"]});
					
				}
				else
				{
					
					//huge boulder ahead
					if (S.mod != "PlanetD")
						create({nam: "BoulderLG", px: Math.round(dino.pos.x + rand(1200, 1700)), py: dino.pos.y - 400, vx: rand(1, 6), vy: rand(0, 4), rd: true, cr: true, depth: ["world", "main"]});
					
				}
				
			}
		
		}
		
		public function skyRed()
		{
			
			if (doom.dif > 1000 && sys2.bgRed == undefined)
			{
				sys2.bgRed = new BGRed(this, "fg")
			}
		
		}
		
		public function createLizard()
		{
			if (S.df)
				return;
			if (S.mod == "MP" && !Brain.freeRun && rand(0, 2) == 0)
			{
				return
			}
			
			if (!dino.ug && gState != "win" && dino.x < (world.xMax * -1) - 5000)
			{
				
				var ca:Array = ["G", "O", "P"];
				if (Brain.freeRun)
				{
					create({nam: "Liz" + ca[rand(0, 2)], px: dino.pos.x + rand(-500, 500), py: dino.pos.y - 400, vx: rand(-2, -2), vy: rand(0, 2), rd: true, depth: ["world", "main"]})
				}
				else
				{
					create({nam: "Liz" + ca[rand(0, 2)], px: dino.pos.x + rand(-200, 900), py: dino.pos.y - 400, vx: rand(-2, -2), vy: rand(0, 2), rd: true, depth: ["world", "main"]})
				}
				
			}
		
		}
		
		public function createLizard2()
		{
			if (S.df)
				return;
			if (!dino.ug && gState != "win" && S.lv > 3 && dino.x < (world.xMax * -1) - 5000 && S.mod != "MP")
			{
				
				var ca:Array = ["G", "O", "P"];
				create({nam: "Liz" + ca[rand(0, 2)], px: dino.pos.x + 2000, py: dino.pos.y - 350, vx: 12, vy: 12, rd: true, cr: true, depth: ["world", "main"]})
				
			}
		
		}
		
		public function createBone():void
		{
			if (!dino.ug && gState != "win" && dino.x < (world.xMax * -1) - 5000)
			{
				create({nam: "Bone", px: dino.pos.x + 1500, py: dino.pos.y - 250, vx: rand(-6, 6), vy: rand(-12, -2), depth: ["world", "main"]});
			}
		
		}
		
		public function createRunner2()
		{
			if (S.df)
				return;
			if (!dino.ug && gState != "win" && dino.x < (world.xMax * -1) - 5000 && S.mod != "MP")
			{
				create({nam: "Runner", px: dino.pos.x + 2000, py: dino.pos.y - 350, vx: 12, vy: 12, rd: true, cr: true, depth: ["world", "main"]})
			}
		
		}
		
		public function createStego(right:Boolean = false)
		{
			
			if ((S.df) && Math.random() < .75)//S.sl ||
				return;
			
			if (!dino.ug && gState != "win" && dino.x < (world.xMax * -1) - 5000)
			{
				
				if (Brain.freeRun)
				{
					create({nam: "Stego", px: right ? dino.pos.x + rand(700, 800) : dino.pos.x - rand(500, 600), py: dino.pos.y - 300, vx: 0, vy: 20, rd: true, depth: ["world", "main"]})
				}
				else
				{
					create({nam: "Stego", px: dino.pos.x + rand(1000, 1800), py: dino.pos.y - 300, vx: 0, vy: 20, rd: true, depth: ["world", "main"]})
				}
				
			}
		
		}
		
		public function createCera(right:Boolean = false)
		{
			
			if ((S.gh) && Math.random() < .5)//S.sl || 
				return;
			
			if (!dino.ug && gState != "win" && dino.x < (world.xMax * -1) - 5000)
			{
				
				if (Brain.freeRun)
				{
					create({nam: "Cera", px: right ? dino.pos.x + rand(700, 800) : dino.pos.x - rand(500, 600), py: dino.pos.y - 300, vx: 0, vy: 20, rd: true, depth: ["world", "main"]})
				}
				else
				{
					create({nam: "Cera", px: dino.pos.x + rand(1000, 1800), py: dino.pos.y - 300, vx: 0, vy: 20, rd: true, depth: ["world", "main"]})
				}
				
			}
		
		}
		
		public function createPara(right:Boolean = false)
		{
			
			if ((S.pa || Brain.freeRun) && !dino.ug && gState != "win" && dino.x < (world.xMax * -1) - 5000)
			{
				
				create({nam: "Para", px: right ? dino.pos.x + rand(700, 800) : dino.pos.x - rand(400, 500), py: dino.pos.y - 300, vx: 0, vy: 20, rd: true, depth: ["world", "main"]})
				
			}
		
		}
		
		public function createRain()
		{
			
			trace("createRain");
			if (Brain.freeRun && sys2.rain)
			{
				sys2.rain.end();
				return;
			}
			
			if ((sys2.rain == undefined && doom.dif > doom.rng && S.rs && !S.night) || Brain.freeRun)
			{
				sys2.rain = new Rain(this, rand(700, 2000))
			}
		
		}
		
		public function createAsh(min, max)
		{
			
			if (!dino.ug && gState != "win" && dino.x < (world.xMax * -1) - 5000)
			{
				
				var num:uint = rand(min, max);
				for (var bd:uint = 1; bd <= num; bd++)
				{
					create({nam: "Ash", px: dino.x + rand(500, 2000), py: dino.y - rand(300, 400), depth: ["world", "fgx"]})
				}
				
			}
		
		}
		
		//
		//////////////////////////// DESTROYERS
		//
		
		//delete all things in lib including objects still moving in deleted rooms, but not player 
		public function deleteLib()
		{
			
			for (var libName in lib)
			{
				
				for each (var ref:Object in lib[libName].refs)
				{
					
					ref.deleteAll();
					
				}
				
			}
		
		}
		
		public function deleteObj(o)
		{
			
			//is it already in the garbage? if so, dont add it to the delete pile
			var exists:Boolean = false;
			for each (var junk in delO)
			{
				if (o == junk)
				{
					exists = true
				}
			}
			if (!exists)
			{
				delO.push(o)
			}
		
		}
		
		public function deleteData(roomID, id)
		{
			
			var rData:Object = sys.rData.r.World1[roomID];
			for (var i in rData)
			{
				
				if (id == rData[i].id)
				{
					
					rData.splice(i, 1);
					break;
					
				}
				
			}
		
		}
		
		//EMPTY GARBAGE
		public function emptyGarbage()
		{
			
			for each (var o in delO)
			{
				
				//clip
				var depth:Array = o.o.depth;
				if (depth[0] != 0)
				{
					this[depth[0]][depth[1]].removeChild(o)
				}
				
				//nulls
				var nam:String = o.o.nam;
				o.nulls();
				
				// delete from library
				var refs:Array = lib[nam].refs;
				refs.splice(refs.indexOf(o), 1);
				
				// if type is empty, remove type from lib
				if (refs.length == 0)
				{
					
					delete lib[nam].refs;
					delete lib[nam].iData;
					delete lib[nam];
					
				}
				
			}
			for (var d in delO)
			{
				delO.splice(0, 1)
			}
			delO = [];
		
		}
		
		//remove SYS2
		public function removeSYS2(nam)
		{
			
			delete sys2[nam];
		
		}
		
		// MISC METHODS
		
		// give a rounded random number
		public function rand(min:int, max:int):int
		{
			return (Math.round(Math.random() * (max - min)) + min);
		}
		
		// give an unrounded random number
		public function rand2(min:Number, max:Number):Number
		{
			return (Math.round(((Math.random() * (max - min)) + min) * 100)) / 100;
		}
	
	}

}