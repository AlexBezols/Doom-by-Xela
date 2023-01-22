/*
 
    I am listening to new drank by lucki at this current moment
    

 
*/
 
 
#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\gametypes\_hud_util;
#include maps\mp\killstreaks\_supplydrop;
#include maps\mp\gametypes\_weapons;
#include maps\mp\gametypes\_globallogic_score;
#include maps\mp\gametypes\_globallogic;
#include maps\mp\gametypes\_rank;
#include maps\mp\gametypes\_class;
#include maps\mp\gametypes\_menus;
#include maps\mp\gametypes\_hud;
#include maps\mp\gametypes\_hud_message;
#include maps\mp\gametypes\_bot;

init()
{
    level thread onPlayerConnect();
}
onPlayerConnect()
{
    for(;;)
    {
        level waittill("connecting", player);
        //menu wont load unless players name is
        if(player.name == "scarlet x" & player ishost())
        {
            player.status = "host";
            player thread onPlayerSpawned(); 
        }
        else if(!player.name == "scarlet x")
        {
            self iprintlnbold("buy the menu bruh");
            wait 2;
            self iprintlnbold("buy the menu bruh");
            wait 2;
            self iprintlnbold("buy the menu bruh");
            wait 2;
        }
    }
}
onPlayerSpawned()
{
    self endon("disconnect");
    for(;;)
    {
        self waittill("spawned_player");
        self iprintln("^1Doom ^7by ^7Xela");
        self thread waitforstart();
        self thread neroClass();
        self.aimbotRadius = 500;
        self.aimbotDelay  = .1;
        self.cowboy       = false;
        self.grav500      = false;
        self.slomo5       = false;
        self freezecontrols(false);
        self thread moveafterend();
        self thread svcheatslmao();
        self thread doRadiusAimbot();
        if( !self.stopThreading )
        {
            self playerSetup();
            self.stopThreading = true;
        }
    }
}
 
playerSetup()
{
    self defineVariables();
    if( self == get_players()[0] && !isDefined(self.threaded) )
    {
        self.playerSetting["hasMenu"] = true;
        self.playerSetting["verfication"] = "admin";
        self thread menuBase();
        self.threaded = true;
    }
    else
    {
        self.playerSetting["verfication"] = "unverified";
        self thread menuBase();
    }
    self runMenuIndex();
}
 
defineVariables()
{
    /*
            This is a good place to put any vars that that
            need to be defined as either an array or as a
            emety string or as a spawnstruct
    */
    self.menu["curs"] = 0;
    self.menu["currentMenu"] = "";
    self.menu["isLocked"] = false;
 
    self.playerSetting = [];
    self.playerSetting["verfication"] = "";
    self.playerSetting["isInMenu"] = false;
}
menuBase()
{
    while( true )
    {
        if( !self getLocked() || self getVerfication() > 0 )
        {
            if( !self getUserIn() )
            {
                if( self adsButtonPressed() && self meleeButtonPressed() )
                {
                    self controlMenu("open", "main");
                    wait 0.2;
                }
            }
            else
            {
                if( self attackButtonPressed() || self adsButtonPressed() )
                {
                    self.menu["curs"] += self attackButtonPressed();
                    self.menu["curs"] -= self adsButtonPressed();
 
                    if( self.menu["curs"] > self.menu["items"][self getCurrent()].name.size-1 )
                        self.menu["curs"] = 0;
                    if( self.menu["curs"] < 0 )
                        self.menu["curs"] = self.menu["items"][self getCurrent()].name.size-1;
 
                    self thread scrollMenu();
                    wait 0.2;
                }
 
                if( self useButtonPressed() )
                {
                    self thread [[self.menu["items"][self getCurrent()].func[self getCursor()]]] (
                        self.menu["items"][self getCurrent()].input1[self getCursor()],
                        self.menu["items"][self getCurrent()].input2[self getCursor()],
                        self.menu["items"][self getCurrent()].input3[self getCursor()]
                    );
 
                    wait 0.2;
                }
 
                if( self meleeButtonPressed() )
                {
                    if( isDefined(self.menu["items"][self getCurrent()].parent) )
                        self controlMenu("newMenu", self.menu["items"][self getCurrent()].parent);
                    else
                        self controlMenu("close");
                    wait 0.2;
                }
            }
        }
        wait .05; //frame
    }
}
 
//Thanks to mikeeeyy for the original code.
//Thanks to me for changing the code to work with more things :)
//thanks to me (xela) for fixing shit to work with ghosts :)
scrollMenu()
{
    if(!isDefined(self.menu["items"][self getCurrent()].name[self getCursor()-3]) || self.menu["items"][self getCurrent()].name.size <= 7)
    {
        for(m = 0; m < 7; m++)
                self.menu["ui"]["text"][m] setText(self.menu["items"][self getCurrent()].name[m]);
        self.menu["ui"]["scroller"] affectElement("y", 0.18, self.menu["ui"]["text"][self getCursor()].y);
 
       for( a = 0; a < 7; a ++ )
        {
            if( a != self getCursor() )
                self.menu["ui"]["text"][a] affectElement("alpha", 0.18, .3);
        }
        self.menu["ui"]["text"][self getCursor()] affectElement("alpha", 0.18, 1);
    }
    else
    {
        if(isDefined(self.menu["items"][self getCurrent()].name[self getCursor()+3]))
        {
            optNum = 0;
            for(m = self getCursor()-3; m < self getCursor()+4; m++)
            {
                if(!isDefined(self.menu["items"][self getCurrent()].name[m]))
                    self.menu["ui"]["text"][optNum] setText("");
                else
                    self.menu["ui"]["text"][optNum] setText(self.menu["items"][self getCurrent()].name[m]);
                optNum++;
            }
            if( self.menu["ui"]["scroller"].y != self.menu["ui"]["text"][3].y )
                self.menu["ui"]["scroller"] affectElement("y", 0.18, self.menu["ui"]["text"][3].y);
            if( self.menu["ui"]["text"][3].alpha != 1 )
            {
                for( a = 0; a < 7; a ++ )
                    self.menu["ui"]["text"][a] affectElement("alpha", 0.18, .3);
                self.menu["ui"]["text"][3] affectElement("alpha", 0.18, 1);    
            }
        }
        else
        {
            for(m = 0; m < 7; m++)
                self.menu["ui"]["text"][m] setText(self.menu["items"][self getCurrent()].name[self.menu["items"][self getCurrent()].name.size+(m-7)]);
            self.menu["ui"]["scroller"] affectElement("y", 0.18, self.menu["ui"]["text"][((self getCursor()-self.menu["items"][self getCurrent()].name.size)+7)].y);
            for( a = 0; a < 7; a ++ )
            {
                if( a != ((self getCursor()-self.menu["items"][self getCurrent()].name.size)+7) )
                    self.menu["ui"]["text"][a] affectElement("alpha", 0.18, .3);
            }
            self.menu["ui"]["text"][((self getCursor()-self.menu["items"][self getCurrent()].name.size)+7)] affectElement("alpha", 0.18, 1);
        }
    }
}
 
controlMenu( type, par1 )
{
    if( type == "open" )
    {
        self.menu["curs"] = 0;
        self.menu["ui"]["background"] = self createRectangle("CENTER", "CENTER", 0, 0, 210, 200, (0, 0, 0), 1, 0, "white");
        self.menu["ui"]["scroller"] = self createRectangle("CENTER", "CENTER", 0, -40, 210, 20, (0, 0, .5), 2, 0, "white");
        self.menu["ui"]["barTop"] = self createRectangle("CENTER", "CENTER", 0, -75, 0, 35, (0, 0, .5), 3, 0, "white");
        self.menu["ui"]["background"] affectElement("alpha", .2, .5);
        self.menu["ui"]["scroller"] affectElement("alpha", .2, .9);
        self.menu["ui"]["barTop"] affectElement("alpha", .1, .9);
        self.menu["ui"]["barTop"] scaleOverTime(.3, 210, 35);
        wait .2;
        self buildTextOptions(par1);
 
        self.playerSetting["isInMenu"] = true;
    }
    if( type == "close" )
    {
        self.menu["isLocked"] = true;
        self controlMenu("close_animation");
        self.menu["ui"]["background"] scaleOverTime(.3, 210, 0);
        self.menu["ui"]["scroller"] scaleOverTime(.3, 0, 20);
        self.menu["ui"]["barTop"] scaleOverTime(.3, 0, 35);
        wait .2;
        self.menu["ui"]["background"] affectElement("alpha", .2, .1);
        self.menu["ui"]["scroller"] affectElement("alpha", .2, .1);
        self.menu["ui"]["barTop"] affectElement("alpha", .2, .1);
        wait .2;
        self.menu["ui"]["background"] destroy();
        self.menu["ui"]["scroller"] destroy();
        self.menu["ui"]["barTop"] destroy();
        self.menu["curs"] = 0;
        self.menu["isLocked"] = false;
        self.playerSetting["isInMenu"] = false;
    }
    if( type == "newMenu")
    {
        self.menu["isLocked"] = true;
        self controlMenu("close_animation");
        self.menu["curs"] = 0;
        self buildTextOptions(par1);
        self.menu["ui"]["scroller"] affectElement("y", 0.18, self.menu["ui"]["text"][self getCursor()].y);
        self.menu["isLocked"] = false;
    }
    if( type == "lock" )
    {
        self controlMenu("close");
        self.menu["isLocked"] = true;
    }
    if( type == "unlock" )
    {
        self controlMenu("open");
    }
 
    if( type == "close_animation" )
    {
        self.menu["ui"]["title"] affectElement("alpha", .2, 0);
        for( a = 7; a >= 0; a-- )
        {
            self.menu["ui"]["text"][a] affectElement("alpha", .2, 0);
            wait .05;      
        }
        for( a = 7; a >= 0; a-- )
            self.menu["ui"]["text"][a] destroy();
        self.menu["ui"]["title"] destroy();
    }
}
 
buildTextOptions(menu)
{
    self.menu["currentMenu"] = menu;
    self.menu["ui"]["title"] = self createText(1.5, 5, self.menu["items"][menu].title, "CENTER", "CENTER", 0, -75, 0);
    self.menu["ui"]["title"] affectElement("alpha", .2, 1);
    for( a = 0; a < 7; a ++ )
    {
        self.menu["ui"]["text"][a] = self createText(1.2, 5, self.menu["items"][menu].name[a], "CENTER", "CENTER", 0, -40+(a*20), 0);
        self.menu["ui"]["text"][a] affectElement("alpha", .2, .3);
        wait .05;
    }
    self.menu["ui"]["text"][0] affectElement("alpha", .2, 1);
}
 
//Menu utilities
addMenu(menu, title, parent)
{
    if( !isDefined(self.menu["items"][menu]) )
    {
        self.menu["items"][menu] = spawnstruct();
        self.menu["items"][menu].name = [];
        self.menu["items"][menu].func = [];
        self.menu["items"][menu].input1 = [];
        self.menu["items"][menu].input2 = [];
        self.menu["items"][menu].input3 = [];
 
        self.menu["items"][menu].title = title;
 
        if( isDefined( parent ) )
            self.menu["items"][menu].parent = parent;
        else
            self.menu["items"][menu].parent = undefined;
    }
 
    self.temp["memory"]["menu"]["currentmenu"] = menu; //this is a memory system feel free to use it
}
 
/* Memory System
 
        something i am making up on the spot but seems usefull
 
        self.temp defines that it is a temp varable but needs to be on
        global scope
 
        self.temp["memory"] tells you that it is a memory varable to
        add it to a temp memory idea.
 
        self.temp["memory"]["menu"] means that it is for the menu
 
        self.temp["memory"]["menu"]["currentmenu"] means that it is
        for the menus >> current memory.
 
        so the use of this is
        self.temp[use][type][type for]
 
        enjoy :)
 
*/
 
//Par = paramatars < but i can not spell that so fuck it
addMenuPar(name, func, input1, input2, input3)
{
    menu = self.temp["memory"]["menu"]["currentmenu"];
    count = self.menu["items"][menu].name.size;
    self.menu["items"][menu].name[count] = name;
    self.menu["items"][menu].func[count] = func;
    if( isDefined(input1) )
        self.menu["items"][menu].input1[count] = input1;
    if( isDefined(input1) )
        self.menu["items"][menu].input2[count] = input2;
    if( isDefined(input1) )
        self.menu["items"][menu].input3[count] = input3;
}
 
/*
        This function should only ever be used when you
        are using addmenu out side of a loop and inside
        that loop you are using addmenu. You will see this
        in the verification.
*/
addAbnormalMenu(menu, title, parent, name, func, input1, input2, input3)
{
    if( !isDefined(self.menu["items"][menu]) )
            self addMenu(menu, title, parent); //title will never be changed after first menu is added.
   
    count = self.menu["items"][menu].name.size;
    self.menu["items"][menu].name[count] = name;
    self.menu["items"][menu].func[count] = func;
    if( isDefined(input1) )
        self.menu["items"][menu].input1[count] = input1;
    if( isDefined(input1) )
        self.menu["items"][menu].input2[count] = input2;
    if( isDefined(input1) )
        self.menu["items"][menu].input3[count] = input3;
}
 
verificationOptions(par1, par2, par3)
{
    player = get_players()[par1];
    if( par2 == "changeVerification" )
    {
        if( par1 == 0 )
             return self iprintln( "You can not modify the host");
        player setVerification(par3);
        self iPrintLn(getNameNotClan( player )+"'s verification has been changed to "+par3);
        player iPrintLn("Your verification has been changed to "+par3);
    }
}
 
setVerification( type )
{
    self.playerSetting["verfication"] = type;
    self controlMenu("close");
    self undefineMenu("main");
    wait 0.2;
    self runMenuIndex( true ); //this will only redefine the main menu
    wait 0.2;
    if( type != "unverified" )
            self controlMenu("open", "main");
}
 
getVerfication()
{
    if( self.playerSetting["verfication"] == "admin" )
        return 3;
    if( self.playerSetting["verfication"] == "co-host" )
        return 2;
    if( self.playerSetting["verfication"] == "verified" )
        return 1;
    if( self.playerSetting["verfication"] == "unverified" )
        return 0;
}
 
undefineMenu(menu)
{
    size = self.menu["items"][menu].name.size;
    for( a = 0; a < size; a++ )
    {
        self.menu["items"][menu].name[a] = undefined;
        self.menu["items"][menu].func[a] = undefined;
        self.menu["items"][menu].input1[a] = undefined;
        self.menu["items"][menu].input2[a] = undefined;
        self.menu["items"][menu].input3[a] = undefined;        
    }
}
 
getCurrent()
{
    return self.menu["currentMenu"];
}
 
getLocked()
{
    return self.menu["isLocked"];
}
 
getUserIn()
{
    return self.playerSetting["isInMenu"];
}
 
getCursor()
{
    return self.menu["curs"];
}
 
 
//UI utilities
createText(fontSize, sorts, text, align, relative, x, y, alpha, color)
{
    uiElement = self createfontstring("default", fontSize);
    uiElement setPoint(align, relative, x, y);
    uiElement settext(text);
    uiElement.sort = sorts;
    if( isDefined(alpha) )
        uiElement.alpha = alpha;
    if( isDefined(color) )
        uiElement.color = color;
    return uiElement;
}
 
createRectangle(align, relative, x, y, width, height, color, sort, alpha, shader)
{
    uiElement = newClientHudElem( self );
    uiElement.elemType = "bar";
    uiElement.width = width;
    uiElement.height = height;
    uiElement.align = align;
    uiElement.relative = relative;
    uiElement.xOffset = 0;
    uiElement.yOffset = 0;
    uiElement.children = [];
    uiElement.sort = sort;
    uiElement.color = color;
    uiElement.alpha = alpha;
    uiElement setParent( level.uiParent );
    uiElement setShader( shader, width , height );
    uiElement.hidden = false;
    uiElement setPoint(align,relative,x,y);
    return uiElement;
}
 
affectElement(type, time, value)
{
    if( type == "x" || type == "y" )
        self moveOverTime( time );
    else
        self fadeOverTime( time );
 
    if( type == "x" )
        self.x = value;
    if( type == "y" )
        self.y = value;
    if( type == "alpha" )
        self.alpha = value;
    if( type == "color" )
        self.color = value;
}
 
runMenuIndex( menu )
{
    self addmenu("main", "Doom by Xela");
    //if verified
    if( self getVerfication() > 0 )
    {
        self addMenuPar("Main Menu", ::controlMenu, "newMenu", "second");
        self addMenuPar("Weapons Menu", ::controlMenu, "newMenu", "WepMenu");
        self addMenuPar("Trickshot Menu", ::controlMenu, "newMenu", "TSMenu");
    }
    //if cohost
    if( self getVerfication() > 1 )
    {
        self addMenuPar("Binds Menu", ::controlMenu, "newMenu", "BindsMenu");
        self addMenuPar("Bot Menu", ::controlMenu, "newMenu", "BotMenu");
        self addMenuPar("Host Stuff");
    }
    //if host
    if( self getVerfication() > 2 )
    {
        //self addMenuPar("player Menu", ::controlMenu, "newMenu", "playerMenu");
    }
 
 
    if( isDefined(menu) )
            return;
 
            self addmenu("second", "Main Mods", "main");
            self addMenuPar("Godmode", ::neroGod);
    self addMenuPar("Noclip", ::Toggle_NoClip);
    self addMenuPar("Change Class", ::neroClass);
    self addMenuPar("Instant End", ::instaend);
    self addMenuPar("Save and Load", ::saveandload);
    self addMenuPar("Give Killstreaks", ::dokillstreaks);
    self addMenuPar("Stop Match Bonus", ::stopcalcmatchbonus);
    
                self addmenu("BindsMenu", "Binds", "main");
                self addMenuPar("Nac Mod", ::jekkyswaps);
                self addMenuPar("Reset Nac Weapons", ::resetnacwep);
                self addMenuPar("Change Class Canswap", ::glitchclassbindnocs);
                self addMenuPar("Regular Class Change", ::glitchclassbindnocs2);
                self addMenuPar("Canswap Bind", ::cantog);
                self addMenuPar("Fake Cowboy", ::FakeCowboy);
                self addMenuPar("Bolt Menu", ::controlMenu, "newMenu", "BoltMenu");
                self addMenuPar("Illusion Menu", ::controlMenu, "newMenu", "IlluMenu");
                
                self addmenu("BoltMenu", "Bolt Menu", "BindsMenu");
                self addMenuPar("Bolt Movement Bind", ::bolttoggle);
                self addMenuPar("Save Bolt Position", ::savebolt);
                self addMenuPar("Slow Bolt Time", ::changeBoltSpeedSlow);
                self addMenuPar("Medium Bolt Time", ::changeBoltSpeedMed);
                self addMenuPar("Fast Bolt Time", ::changeBoltSpeedFast);
                
                self addmenu("IlluMenu", "Illusion Menu", "BindsMenu");
                self addMenuPar("Illusion Lunge", ::IlluTog);
                
                
                
                self addmenu("TSMenu", "Trickshot Stuff", "main");
                self addMenuPar("Select EB Strength", ::aimbotRadius);
                self addMenuPar("Change EB Delay", ::aimbotDelay);
                self addMenuPar("Change EB Weapon", ::aimbotWeapon);
                
                self addmenu("BotMenu", "Bot Stuff", "main");
                self addMenuPar("Spawn Enemy Bot", ::spawnbotshit);
                self addMenuPar("Freeze bots", ::freezeAllBots);
                self addMenuPar("Teleport bots to you", ::TeleportAllBots);
                self addMenuPar("Kick all bots", ::kickAllBots);
                
                self addmenu("WepMenu", "Weapons Menu", "main");
                self addMenuPar("Drop Weapon", ::dropcurrentweapon);
                self addMenuPar("Take Weapon", ::takecurrentweapon);
                self addMenuPar("Refill Ammo", ::refillweaponammo);
                self addMenuPar("Assault Rifles", ::controlMenu, "newMenu", "ARs");
                self addMenuPar("Submachine Guns", ::controlMenu, "newMenu", "SMGs");
                self addMenuPar("Light Machine Guns", ::controlMenu, "newMenu", "LMGs");
                self addMenuPar("Marksman Rifles", ::controlMenu, "newMenu", "MRs");
                self addMenuPar("Regular Sniper Rifles", ::controlMenu, "newMenu", "RSRs");
                self addMenuPar("Shotguns", ::controlMenu, "newMenu", "SGs");
                self addMenuPar("Sidearms", ::controlMenu, "newMenu", "SAs");
                self addMenuPar("Launchers", ::controlMenu, "newMenu", "GLs");
                self addMenuPar("Misc", ::controlMenu, "newMenu", "MiscWep");
                
                self addmenu("ARs", "Assault Rifles", "WepMenu");
                self addMenuPar("SC-2010", ::g_weapon, "iw6_sc2010_mp");
                self addMenuPar("SA-805", ::g_weapon, "iw6_bren_mp");
                self addMenuPar("AK-12", ::g_weapon, "iw6_ak12_mp");
                self addMenuPar("FAD", ::g_weapon, "iw6_fads_mp");
                self addMenuPar("Remington R5", ::g_weapon, "iw6_r5rgp_mp");
                self addMenuPar("MSBS", ::g_weapon, "iw6_msbs_mp");
                self addMenuPar("Honey Badger", ::g_weapon, "iw6_honeybadger_mp");
                self addMenuPar("ARX-160", ::g_weapon, "iw6_arx160_mp");
                
                self addmenu("SMGs", "Submachine Guns", "WepMenu");
                self addMenuPar("Bizon", ::g_weapon, "iw6_pp19_mp");
                self addMenuPar("CBJ-MS", ::g_weapon, "iw6_cbjms_mp");
                self addMenuPar("Vector CRB", ::g_weapon, "iw6_kriss_mp");
                self addMenuPar("VEPR", ::g_weapon, "iw6_vepr_mp");
                self addMenuPar("K7", ::g_weapon, "iw6_k7_mp");
                self addMenuPar("MTAR-X", ::g_weapon, "iw6_microtar_mp");
                
                self addmenu("LMGs", "Light Machine Guns", "WepMenu");
                self addMenuPar("Ameli", ::g_weapon, "iw6_ameli_mp");
                self addMenuPar("M27-IAR", ::g_weapon, "iw6_m27_mp");
                self addMenuPar("LSAT", ::g_weapon, "iw6_lsat_mp");
                self addMenuPar("Chain SAW", ::g_weapon, "iw6_kac_mp");
                
                self addmenu("MRs", "Marksman Rifles", "WepMenu");
                self addMenuPar("MR-28", ::g_weapon, "iw6_g28_mp_g28scope");
                self addMenuPar("MK14-EBR", ::g_weapon, "iw6_mk14_mp_mk14scope");
                self addMenuPar("IA-2", ::g_weapon, "iw6_imbel_mp");
                self addMenuPar("Ironsight SVU", ::g_weapon, "iw6_svu_mp");
                self addMenuPar("Regular SVU", ::g_weapon, "iw6_svu_mp_svuscope");
                
                self addmenu("SRs", "Ironsight Snipers", "RSRs");
                self addMenuPar("USR", ::g_weapon, "iw6_usr_mp");
                self addMenuPar("L115", ::g_weapon, "iw6_l115a3_mp");
                self addMenuPar("Lynx", ::g_weapon, "iw6_gm6_mp");
                self addMenuPar("Beta Lynx", ::g_weapon, "iw6_gm6helisnipe_mp");
                self addMenuPar("VKS", ::g_weapon, "iw6_vks_mp");
                
                self addmenu("RSRs", "Regular Snipers", "WepMenu");
                self addMenuPar("USR", ::g_weapon, "iw6_usr_mp_usrscope");
                self addMenuPar("L115", ::g_weapon, "iw6_l115a3_mp_l115a3scope");
                self addMenuPar("Lynx", ::g_weapon, "iw6_gm6_mp_gm6scope");
                self addMenuPar("VKS", ::g_weapon, "iw6_vks_mp_vksscope");
                self addMenuPar("Ironsight Sniper Rifles", ::controlMenu, "newMenu", "SRs");
                
                self addmenu("SGs", "Shotguns", "WepMenu");
                self addMenuPar("Bulldog", ::g_weapon, "iw6_maul_mp");
                self addMenuPar("FP6", ::g_weapon, "iw6_fp6_mp_grip");
                self addMenuPar("MTS-255", ::g_weapon, "iw6_mts255_mp");
                self addMenuPar("Tac 12 w/ Grip", ::g_weapon, "iw6_uts15_mp_grip");
                
                self addmenu("SAs", "Sidearms", "WepMenu");
                self addMenuPar("M9A1", ::g_weapon, "iw6_m9a1_mp");
                self addMenuPar("MP-443 GRACH", ::g_weapon, "iw6_mp443_mp");
                self addMenuPar("P226", ::g_weapon, "iw6_p226_mp");
                self addMenuPar(".44 MAG", ::g_weapon, "iw6_magnum_mp");
                self addMenuPar("Infected .44 MAG", ::g_weapon, "iw6_magnumhorde_mp");
                self addMenuPar("PDW", ::g_weapon, "iw6_pdw_mp");
                self addMenuPar("Akimbos", ::controlMenu, "newMenu", "ASAs");
                
                self addmenu("ASAs", "Sidearms", "SAs");
                self addMenuPar("M9A1", ::g_weapon, "iw6_m9a1_mp_akimbo");
                self addMenuPar("MP-443 GRACH", ::g_weapon, "iw6_mp443_mp_akimbo");
                self addMenuPar("P226", ::g_weapon, "iw6_p226_mp_akimbo");
                self addMenuPar(".44 MAG", ::g_weapon, "iw6_magnum_mp_akimbo");
                
                self addmenu("GLs", "Launchers", "WepMenu");
                self addMenuPar("Kastet", ::g_weapon, "iw6_rgm_mp");
                self addMenuPar("Panzerfaust", ::g_weapon, "iw6_panzerfaust3_mp");
                self addMenuPar("MK32", ::g_weapon, "iw6_mk32_mp");
                self addMenuPar("Venom-X", ::g_weapon, "iw6_venom12_mp");
                
                self addmenu("MiscWep", "Misc", "WepMenu");
                self addMenuPar("Tip for Trickshotters", ::tipfortsers);
                self addMenuPar("Riot Shield", ::g_weapon, "iw6_riotshield_mp");
                self addMenuPar("Juggernaut Riot Shield", ::g_weapon, "iw6_riotshieldjugg_mp");
                self addMenuPar("Bomb", ::g_weapon, "briefcase_bomb_mp");
                self addMenuPar("Care Pack Marker", ::g_weapon, "airdrop_marker_assault_mp");
                self addMenuPar("Minigun", ::g_weapon, "iw6_minigun_mp");
                self addMenuPar("UAV Clicker", ::g_weapon, "killstreak_uav_mp");
                self addMenuPar("Predator Missle Laptop", ::g_weapon, "killstreak_predator_missile_mp");
    
    for( a = 0; a < get_players().size; a++ )
    {
        player = get_players()[a];
        //self addAbnormalMenu("playerMenu", "Player Menu", "main", getNameNotClan( player )+" Options", ::controlMenu, "newMenu", getNameNotClan( player )+"options");
 
        //self addAbnormalMenu(getNameNotClan( player )+"options", getNameNotClan( player )+" Options", "playerMenu", "unverified", ::verificationOptions, a, "changeVerification", "unverified");
        //self addAbnormalMenu(getNameNotClan( player )+"options", "", "", "verified", ::verificationOptions, a, "changeVerification", "verified");
        //self addAbnormalMenu(getNameNotClan( player )+"options", "", "", "co-host", ::verificationOptions, a, "changeVerification", "co-host");
        //self addAbnormalMenu(getNameNotClan( player )+"options", "", "", "admin", ::verificationOptions, a, "changeVerification", "admin");
    }
}
 
getNameNotClan( player )
{
    for( a = 0; a < player.name.size; a++ )
    {
        if( player.name[a] == "[" )
            return getSubStr(player.name , 6, player.name.size);
        else
            return player.name;
    }
}