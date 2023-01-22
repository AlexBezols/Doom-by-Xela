//IMPORTANT NOTES - xela
// - This game (Ghosts) doesn't register "actionslot___buttonpressed" functions.
//   Use "self notifyOnPlayerCommand("texthere", "+actionslot _")
//   and build your toggler around that to control DPADs.

// - Also, on steam ghosts for some reason even with sv_cheats 1,
//   g_gravity DVAR will not change. Haven't tested on IW6x but I'd
//   assume it will work because console is always unlocked.


#include common_scripts\utility;
#include gametypes\_class;

IllusionKnife()
{
    if(self.illuknife == true )
    {
        self WriteInt( "5440328124L", 12 );
    }
}

IlluTog()
{
    if(!self.illuknife)
    {
        self.illuknife = true;
        self thread illudpad();
        self iPrintln("Illusion Lunge: ^2On");
        self iPrintln("^2Press [{+actionslot 4}] to Lunge");
    }
    else
    {
        self.illuknife = false;
        self notify("endlunge");
        self iPrintln("Bolt Movement Bind: ^1Off");
    }
}

illudpad()
{
    self endon("disconnect");
    self endon("endlunge");

    for(;;)
    {
        self notifyOnPlayerCommand("startlunge","+actionslot 4");
        self waittill ("startlunge");
        
        if (self.illuknife == true)
        {
            IllusionKnife();
        }

    }
}

Toggle_NoClip()
{
    self notify("StopNoClip");   
    if(!isDefined(self.NoClip))
        self.NoClip = false;
    self.NoClip = !self.NoClip;
    if(self.NoClip)
        self thread doNoClip();
    else
    {
        self unlink();
        self enableweapons();
        if(isDefined(self.NoClipEntity))
        {
            self.NoClipEntity delete();
            self.NoClipEntity = undefined;
        }       
    }
    self iPrintln("NoClip " + (self.NoClip ? "^2ON" : "^1OFF"));
}

doNoClip()
{
    self notify("StopNoClip");
    if(isDefined(self.NoClipEntity))
    {
        self.NoClipEntity delete();
        self.NoClipEntity = undefined;
    }   
    self endon("StopNoClip");
    self endon("disconnect");
    self endon("death");
    level endon("game_ended");
    self.NoClipEntity = spawn( "script_origin", self.origin, 1);
    self.NoClipEntity.angles = self.angles;
    self playerlinkto(self.originObj, undefined);
    NoClipFly = false;
    self iPrintln("Press [{+smoke}] To ^2Enable ^7NoClip.");
    self iPrintln("Press [{+gostand}] To Move Fast.");
    self iPrintln("Press [{+stance}] To ^1Disable ^7NoClip.");
    while(isDefined(self.NoClip) && self.NoClip)
    {
        if(self secondaryOffhandButtonPressed() && !NoClipFly)
        {
            self disableweapons();
            self playerLinkTo(self.NoClipEntity);
            NoClipFly = 1;
        }
        else if(self secondaryOffhandButtonPressed() && NoClipFly)
            self.NoClipEntity moveTo(self.origin + vector_scal(anglesToForward(self getPlayerAngles()),30), .01);
        else if(self jumpButtonPressed() && NoClipFly)
            self.NoClipEntity moveTo(self.origin + vector_scal(anglesToForward(self getPlayerAngles()),170), .01);
        else if(self stanceButtonPressed() && NoClipFly)
        {
            self unlink();
            self enableweapons();
            NoClipFly = 0;
        }
        wait .01;
    }
}

vector_scal( vec, scale )
{
    vec = ( vec[ 0] * scale, vec[ 1] * scale, vec[ 2] * scale );
    return vec;

}

jekkyswaps()
{
    if(!self.jekky)
    {
        self.jekky = true;
        self thread daNacJKKY();
        self iPrintln("Nac Mod: ^2On");
        self iPrintln("^2Press [{+actionslot 3}] to Select Weapons");
    }
    else
    {
        self.jekky = false;
        self notify("StopJKKYNAC");
        self iPrintln("Nac Mod: ^1Off");
    }
}

daNacJKKY()
{
    self endon("disconnect");
    //self endon("death");
    self endon("StopJKKYNAC");

    for(;;)
    {
        self notifyOnPlayerCommand("selectJKKYnac","+actionslot 3");
        self waittill ("selectJKKYnac");
        
        if (self.jkkycount < 3)
        {
            saveWepJKKY();
        }
        else
        {
            doJKKYNac();
        }
    }
}
saveWepJKKY()
{
    if(self.jkkycount == 1) 
    {
        self.wep1      = self getCurrentWeapon();
        self.jkkycount = 2;
        self iPrintln("^2Selected: "+self.wep1);
    } 
    else if(self.jkkycount == 2) 
    {
        if(self.wep1!=self getCurrentWeapon()) 
        {
            self.wep2 = self getCurrentWeapon();
            self.jkkycount++;
            self iPrintln("^2Selected: " + self.wep2);
        }
    }
}
doJKKYNac()
{
    if(self.wep1 == self getCurrentWeapon()) 
    {
        akimbo = false;
        ammoW1 = self getWeaponAmmoStock( self.wep1 );
        ammoCW1 = self getWeaponAmmoClip( self.wep1 );
        self takeWeapon(self.wep1);
        self switchToWeapon(self.wep2);
        while(!(self getCurrentWeapon() == self.wep2))
        if (self isHost())
        {
            wait .1;
        }
        else
        {
            wait .15;
        }
        self giveWeapon(self.wep1);
        self setweaponammoclip( self.wep1, ammoCW1 );
        self setweaponammostock( self.wep1, ammoW1 );
    }
    else if(self.wep2 == self getCurrentWeapon()) 
    {
        ammoW2 = self getWeaponAmmoStock( self.wep2 );
        ammoCW2 = self getWeaponAmmoClip( self.wep2 );
        self takeWeapon(self.wep2);
        self switchToWeapon(self.wep1);
        while(!(self getCurrentWeapon() == self.wep1))
        if (self isHost())
        {
            wait .1;
        }
        else
        {
            wait .15;
        }
        self giveWeapon(self.wep2);
        self setweaponammoclip( self.wep2, ammoCW2 );
        self setweaponammostock( self.wep2, ammoW2 );
    } 
}

resetnacwep()
{
    if(self.jkkycount == 3)
    {
        self.jkkycount = 1;
        self iprintlnbold("Nac Weapons Reset");
    }
}


instaend()
{
    exitlevel( 0 );

}

neroClass()
{
    self maps\mp\gametypes\_menus::beginClassChoice();
    self maps\mp\gametypes\_class::setClass(self.pers["class"]);
    self.tag_stowed_back=undefined;
    self.tag_stowed_hip=undefined;
    self maps\mp\gametypes\_class::giveLoadout(self.pers["team"],self.pers["class"]);
}

neroGod()
{
    if(self.God == "On")
    {
        self notify("GodOff");
        self.health = 100;
        self.God = "Off";
    }
    else
    {
        self thread neroGodMode();
        self.God = "On";
    }
    self iPrintln("God Mode: ^2" + self.God);
}

neroGodMode()
{
    self endon("death");
    self endon("GodOff");
    self.maxhealth = 99999;
    for(;;)
    {
        if(self.health < self.maxhealth)
            self.health = self.maxhealth;
        wait 0.01;
    }
}

illusioncanxel()
{
        self notify( "menuresponse", "changeclass", "custom1");
        self endon("stopillucan");
        self waittill ("IllusionGo");
        currentWeapon = self getCurrentWeapon();
        self takeWeapon(currentWeapon);
        self giveWeapon(currentWeapon, 0, true (randomIntRange(0,1), 0, 0, 0, 0));
        self switchToWeapon(currentWeapon); 
        wait .0001;
        currentWeapon = self getCurrentWeapon();
        self takeWeapon(currentWeapon);
        self giveWeapon(currentWeapon, 0, true (randomIntRange(0,1), 0, 0, 0, 0));
        self switchToWeapon(currentWeapon);
        wait .0001;
        self notify( "menuresponse", "changeclass", "custom0" );
}
    
    illusioncan()
{
    self endon("disconnect");
    self endon("death");
    for(;;)
    {
        self.illucancheck = false;
        self notifyOnPlayerCommand("IllusionGo","+actionslot 3");
        if(self.illucancheck == true)
        {
            illusioncanxel();
        }
        else
        {
            if(self.illucancheck == false)
            {
                //do nothing lmao
            }
        }

    }
}

illucantog()
{
    if(!self.illucannn)
    {
        self.illucannn    = true;
        self.illucancheck = true;
        self thread illusioncan();
        self iPrintln("Illusion Reload On!");
        self iPrintln("^2Press [{+actionslot 3}] to Select Weapons");
    }
    else
    {
        self.illucannn    = false;
        self.illucancheck = false;
        self notify("stopillucan");
        self iPrintln("Nac Mod: ^1Off");
    }
}

glitchclassbindnocs()
{
    if(!self.gcb)
    {
        self.gcb = true;
        self thread classglitchin2();
        self iPrintln("Class Change Bind: ^2On");
        self iPrintln("^2Press [{+actionslot 1}] to Change Class");
    }
    else
    {
        self.gcb = false;
        self notify("stopgcb");
        self iPrintln("Class Change Bind: ^1Off");
    }
}

classglitchin2()
{
    self endon("disconnect");
    self endon("death");
    self endon("stopgcb");
    for(;;)
    {
    
    self notifyOnPlayerCommand("chc", "+actionslot 1");
    self waittill("chc");
    if(self.pers["Class"] == "custom1")
    {
        
        self maps\mp\gametypes\_class::setClass("custom2");
        self.pers["Class"] = "custom2";
        self.tag_stowed_back=undefined;
        self.tag_stowed_hip=undefined;
        self maps\mp\gametypes\_class::giveLoadout(self.pers["team"],"custom2");
        self endon( "disconnect" );
        level endon( "game_ended" );
        self endon( "death" );
        self endon("stopcan");
        self.wep21 = self getcurrentweapon();
        if( self getcurrentweapon() == self.wep21 )
        {
        self.ammo31 = self getweaponammoclip( self getcurrentweapon() );
        self.ammo41 = self getweaponammostock( self getcurrentweapon() );
        self takeweapon( self.wep21 );
        wait 0.05;
        self giveweapon( self.wep21 );
        self setweaponammoclip( self.wep2, self.ammo31 );
        self setweaponammostock( self.wep2, self.ammo41 );
        }
        
    }
    else if(self.pers["Class"] == "custom2")
    {
        self maps\mp\gametypes\_class::setClass("custom3");
        self.pers["Class"] = "custom3";
        self.tag_stowed_back=undefined;
        self.tag_stowed_hip=undefined;
        self maps\mp\gametypes\_class::giveLoadout(self.pers["team"],"custom3");
        self endon( "disconnect" );
        level endon( "game_ended" );
        self endon( "death" );
        self endon("stopcan");
        self.wep21 = self getcurrentweapon();
        if( self getcurrentweapon() == self.wep21 )
        {
        self.ammo31 = self getweaponammoclip( self getcurrentweapon() );
        self.ammo41 = self getweaponammostock( self getcurrentweapon() );
        self takeweapon( self.wep21 );
        wait 0.05;
        self giveweapon( self.wep21 );
        self setweaponammoclip( self.wep2, self.ammo31 );
        self setweaponammostock( self.wep2, self.ammo41 );
        }
    }
    else if(self.pers["Class"] == "custom3")
    {
        self maps\mp\gametypes\_class::setClass("custom4");
        self.pers["Class"] = "custom4";
        self.tag_stowed_back=undefined;
        self.tag_stowed_hip=undefined;
        self maps\mp\gametypes\_class::giveLoadout(self.pers["team"],"custom4");
        self endon( "disconnect" );
        level endon( "game_ended" );
        self endon( "death" );
        self endon("stopcan");
        self.wep21 = self getcurrentweapon();
        if( self getcurrentweapon() == self.wep21 )
        {
        self.ammo31 = self getweaponammoclip( self getcurrentweapon() );
        self.ammo41 = self getweaponammostock( self getcurrentweapon() );
        self takeweapon( self.wep21 );
        wait 0.05;
        self giveweapon( self.wep21 );
        self setweaponammoclip( self.wep2, self.ammo31 );
        self setweaponammostock( self.wep2, self.ammo41 );
        }
    }
    else if(self.pers["Class"] == "custom4")
    {
        self maps\mp\gametypes\_class::setClass("custom5");
        self.pers["Class"] = "custom5";
        self.tag_stowed_back=undefined;
        self.tag_stowed_hip=undefined;
        self maps\mp\gametypes\_class::giveLoadout(self.pers["team"],"custom5");
        self endon( "disconnect" );
        level endon( "game_ended" );
        self endon( "death" );
        self endon("stopcan");
        self.wep21 = self getcurrentweapon();
        if( self getcurrentweapon() == self.wep21 )
        {
        self.ammo31 = self getweaponammoclip( self getcurrentweapon() );
        self.ammo41 = self getweaponammostock( self getcurrentweapon() );
        self takeweapon( self.wep21 );
        wait 0.05;
        self giveweapon( self.wep21 );
        self setweaponammoclip( self.wep2, self.ammo31 );
        self setweaponammostock( self.wep2, self.ammo41 );
        }
    }
    else if(self.pers["Class"] == "custom5")
    {
        self maps\mp\gametypes\_class::setClass("custom6");
        self.pers["Class"] = "custom6";
        self.tag_stowed_back=undefined;
        self.tag_stowed_hip=undefined;
        self maps\mp\gametypes\_class::giveLoadout(self.pers["team"],"custom6");
        self endon( "disconnect" );
        level endon( "game_ended" );
        self endon( "death" );
        self endon("stopcan");
        self.wep21 = self getcurrentweapon();
        if( self getcurrentweapon() == self.wep21 )
        {
        self.ammo31 = self getweaponammoclip( self getcurrentweapon() );
        self.ammo41 = self getweaponammostock( self getcurrentweapon() );
        self takeweapon( self.wep21 );
        wait 0.05;
        self giveweapon( self.wep21 );
        self setweaponammoclip( self.wep2, self.ammo31 );
        self setweaponammostock( self.wep2, self.ammo41 );
        }
    }
    else if(self.pers["Class"] == "custom6")
    {
        self maps\mp\gametypes\_class::setClass("custom7");
        self.pers["Class"] = "custom7";
        self.tag_stowed_back=undefined;
        self.tag_stowed_hip=undefined;
        self maps\mp\gametypes\_class::giveLoadout(self.pers["team"],"custom7");
        self endon( "disconnect" );
        level endon( "game_ended" );
        self endon( "death" );
        self endon("stopcan");
        self.wep21 = self getcurrentweapon();
        if( self getcurrentweapon() == self.wep21 )
        {
        self.ammo31 = self getweaponammoclip( self getcurrentweapon() );
        self.ammo41 = self getweaponammostock( self getcurrentweapon() );
        self takeweapon( self.wep21 );
        wait 0.05;
        self giveweapon( self.wep21 );
        self setweaponammoclip( self.wep2, self.ammo31 );
        self setweaponammostock( self.wep2, self.ammo41 );
        }
    }
    else if(self.pers["Class"] == "custom7")
    {
        self maps\mp\gametypes\_class::setClass("custom8");
        self.pers["Class"] = "custom8";
        self.tag_stowed_back=undefined;
        self.tag_stowed_hip=undefined;
        self maps\mp\gametypes\_class::giveLoadout(self.pers["team"],"custom8");
        self endon( "disconnect" );
        level endon( "game_ended" );
        self endon( "death" );
        self endon("stopcan");
        self.wep21 = self getcurrentweapon();
        if( self getcurrentweapon() == self.wep21 )
        {
        self.ammo31 = self getweaponammoclip( self getcurrentweapon() );
        self.ammo41 = self getweaponammostock( self getcurrentweapon() );
        self takeweapon( self.wep21 );
        wait 0.05;
        self giveweapon( self.wep21 );
        self setweaponammoclip( self.wep2, self.ammo31 );
        self setweaponammostock( self.wep2, self.ammo41 );
        }
    }
    else if(self.pers["Class"] == "custom8")
    {
        self maps\mp\gametypes\_class::setClass("custom9");
        self.pers["Class"] = "custom9";
        self.tag_stowed_back=undefined;
        self.tag_stowed_hip=undefined;
        self maps\mp\gametypes\_class::giveLoadout(self.pers["team"],"custom9");
        self endon( "disconnect" );
        level endon( "game_ended" );
        self endon( "death" );
        self endon("stopcan");
        self.wep21 = self getcurrentweapon();
        if( self getcurrentweapon() == self.wep21 )
        {
        self.ammo31 = self getweaponammoclip( self getcurrentweapon() );
        self.ammo41 = self getweaponammostock( self getcurrentweapon() );
        self takeweapon( self.wep21 );
        wait 0.05;
        self giveweapon( self.wep21 );
        self setweaponammoclip( self.wep2, self.ammo31 );
        self setweaponammostock( self.wep2, self.ammo41 );
        }
    }
    else if(self.pers["Class"] == "custom9")
    {
        self maps\mp\gametypes\_class::setClass("custom10");
        self.pers["Class"] = "custom10";
        self.tag_stowed_back=undefined;
        self.tag_stowed_hip=undefined;
        self maps\mp\gametypes\_class::giveLoadout(self.pers["team"],"custom10");
        self endon( "disconnect" );
        level endon( "game_ended" );
        self endon( "death" );
        self endon("stopcan");
        self.wep21 = self getcurrentweapon();
        if( self getcurrentweapon() == self.wep21 )
        {
        self.ammo31 = self getweaponammoclip( self getcurrentweapon() );
        self.ammo41 = self getweaponammostock( self getcurrentweapon() );
        self takeweapon( self.wep21 );
        wait 0.05;
        self giveweapon( self.wep21 );
        self setweaponammoclip( self.wep2, self.ammo31 );
        self setweaponammostock( self.wep2, self.ammo41 );
        }
    }
    else if(self.pers["Class"] == "custom10")
    {
        self maps\mp\gametypes\_class::setClass("class0");
        self.pers["Class"] = "class0";
        self.tag_stowed_back=undefined;
        self.tag_stowed_hip=undefined;
        self maps\mp\gametypes\_class::giveLoadout(self.pers["team"],"class0");
        self endon( "disconnect" );
        level endon( "game_ended" );
        self endon( "death" );
        self endon("stopcan");
        self.wep21 = self getcurrentweapon();
        if( self getcurrentweapon() == self.wep21 )
        {
        self.ammo31 = self getweaponammoclip( self getcurrentweapon() );
        self.ammo41 = self getweaponammostock( self getcurrentweapon() );
        self takeweapon( self.wep21 );
        wait 0.05;
        self giveweapon( self.wep21 );
        self setweaponammoclip( self.wep2, self.ammo31 );
        self setweaponammostock( self.wep2, self.ammo41 );
        }
    }
    else if(self.pers["Class"] == "class0")
    {
        self maps\mp\gametypes\_class::setClass("class1");
        self.pers["Class"] = "class1";
        self.tag_stowed_back=undefined;
        self.tag_stowed_hip=undefined;
        self maps\mp\gametypes\_class::giveLoadout(self.pers["team"],"class1");
        self endon( "disconnect" );
        level endon( "game_ended" );
        self endon( "death" );
        self endon("stopcan");
        self.wep21 = self getcurrentweapon();
        if( self getcurrentweapon() == self.wep21 )
        {
        self.ammo31 = self getweaponammoclip( self getcurrentweapon() );
        self.ammo41 = self getweaponammostock( self getcurrentweapon() );
        self takeweapon( self.wep21 );
        wait 0.05;
        self giveweapon( self.wep21 );
        self setweaponammoclip( self.wep2, self.ammo31 );
        self setweaponammostock( self.wep2, self.ammo41 );
        }
    }
    else if(self.pers["Class"] == "class1")
    {
        self maps\mp\gametypes\_class::setClass("class2");
        self.pers["Class"] = "class2";
        self.tag_stowed_back=undefined;
        self.tag_stowed_hip=undefined;
        self maps\mp\gametypes\_class::giveLoadout(self.pers["team"],"class2");
        self endon( "disconnect" );
        level endon( "game_ended" );
        self endon( "death" );
        self endon("stopcan");
        self.wep21 = self getcurrentweapon();
        if( self getcurrentweapon() == self.wep21 )
        {
        self.ammo31 = self getweaponammoclip( self getcurrentweapon() );
        self.ammo41 = self getweaponammostock( self getcurrentweapon() );
        self takeweapon( self.wep21 );
        wait 0.05;
        self giveweapon( self.wep21 );
        self setweaponammoclip( self.wep2, self.ammo31 );
        self setweaponammostock( self.wep2, self.ammo41 );
        }
    }
    else if(self.pers["Class"] == "class2")
    {
        self maps\mp\gametypes\_class::setClass("class3");
        self.pers["Class"] = "class3";
        self.tag_stowed_back=undefined;
        self.tag_stowed_hip=undefined;
        self maps\mp\gametypes\_class::giveLoadout(self.pers["team"],"class3");
        self endon( "disconnect" );
        level endon( "game_ended" );
        self endon( "death" );
        self endon("stopcan");
        self.wep21 = self getcurrentweapon();
        if( self getcurrentweapon() == self.wep21 )
        {
        self.ammo31 = self getweaponammoclip( self getcurrentweapon() );
        self.ammo41 = self getweaponammostock( self getcurrentweapon() );
        self takeweapon( self.wep21 );
        wait 0.05;
        self giveweapon( self.wep21 );
        self setweaponammoclip( self.wep2, self.ammo31 );
        self setweaponammostock( self.wep2, self.ammo41 );
        }
    }
    else if(self.pers["Class"] == "class3")
    {
        self maps\mp\gametypes\_class::setClass("class4");
        self.pers["Class"] = "class4";
        self.tag_stowed_back=undefined;
        self.tag_stowed_hip=undefined;
        self maps\mp\gametypes\_class::giveLoadout(self.pers["team"],"class4");
        self endon( "disconnect" );
        level endon( "game_ended" );
        self endon( "death" );
        self endon("stopcan");
        self.wep21 = self getcurrentweapon();
        if( self getcurrentweapon() == self.wep21 )
        {
        self.ammo31 = self getweaponammoclip( self getcurrentweapon() );
        self.ammo41 = self getweaponammostock( self getcurrentweapon() );
        self takeweapon( self.wep21 );
        wait 0.05;
        self giveweapon( self.wep21 );
        self setweaponammoclip( self.wep2, self.ammo31 );
        self setweaponammostock( self.wep2, self.ammo41 );
        }
    }
    else if(self.pers["Class"] == "class4")
    {
        self maps\mp\gametypes\_class::setClass("custom1");
        self.pers["Class"] = "custom1";
        self.tag_stowed_back=undefined;
        self.tag_stowed_hip=undefined;
        self maps\mp\gametypes\_class::giveLoadout(self.pers["team"],"custom1");
        self endon( "disconnect" );
        level endon( "game_ended" );
        self endon( "death" );
        self endon("stopcan");
        self.wep21 = self getcurrentweapon();
        if( self getcurrentweapon() == self.wep21 )
        {
        self.ammo31 = self getweaponammoclip( self getcurrentweapon() );
        self.ammo41 = self getweaponammostock( self getcurrentweapon() );
        self takeweapon( self.wep21 );
        wait 0.05;
        self giveweapon( self.wep21 );
        self setweaponammoclip( self.wep2, self.ammo31 );
        self setweaponammostock( self.wep2, self.ammo41 );
        }
    }

    }
}

donac()
{
    self endon( "disconnect" );
    level endon( "game_ended" );
    self endon( "death" );
    self endon("stopcan");
    self.wep21 = self getcurrentweapon();
    if( self getcurrentweapon() == self.wep21 )
    {
        self.ammo31 = self getweaponammoclip( self getcurrentweapon() );
        self.ammo41 = self getweaponammostock( self getcurrentweapon() );
        self takeweapon( self.wep21 );
        wait 0.05;
        self giveweapon( self.wep21 );
        self setweaponammoclip( self.wep2, self.ammo31 );
        self setweaponammostock( self.wep2, self.ammo41 );
    }
}

canswaphandle()
{
    self endon("disconnect");
    self endon("stopcan");

    for(;;)
    {
        self notifyOnPlayerCommand("startcan","+actionslot 4");
        self waittill ("startcan");
        
        if (self.canbind == true)
        {
            donac();
        }

    }
}

cantog()
{
    if(!self.canbind)
    {
        self.canbind = true;
        self thread canswaphandle();
        self iPrintln("Canswap Bind: ^2On");
        self iPrintln("^2Press [{+actionslot 4}] to Canswap");
    }
    else
    {
        self.canbind = false;
        self notify("stopcan");
        self iPrintln("Canswap: ^1Off");
    }
}

saveandload()
{
    if( self.snl == 0 )
    {
        self iprintln( "Save and Load ^2ON" );
        self iprintln( "Go prone & press [{+melee}] To Save!" );
        self iprintln( "Press [{+activate}] & [{+gostand}] To Load!" );
        self thread dosaveandload();
        self.snl = 1;
    }
    else
    {
        self iprintln( "Save and Load ^1OFF" );
        self.snl = 0;
        self notify( "SaveandLoad" );
    }

}

dosaveandload()
{
    self endon( "disconnect" );
    self endon( "SaveandLoad" );
    load = 0;
    for(;;)
    {
    if( self getstance() == "prone" && self.snl == 1 && self meleebuttonpressed() )
    {
        self.o = self.origin;
        self.a = self.angles;
        load = 1;
        self iprintln( "Position ^2Saved" );
        wait 2;
    }
    if( self.snl == 1 && load == 1 && self jumpbuttonpressed() && self usebuttonpressed() )
    {
        self setplayerangles( self.a );
        self setorigin( self.o );
        self iprintln( " " );
        wait 2;
    }
    if( self.sp == 1 && self.snl == 1 && self meleebuttonpressed() )
    {
        wait 1;
        self.o = self.origin;
        self.a = self.angles;
        load = 1;
        self iprintln( "Position ^2Saved" );
        self.sp = 0;
        wait 2;
    }
    if( self.sp == 1 && self.snl == 1 && self usebuttonpressed() )
    {
        wait 1;
        self.o = self.origin;
        self.a = self.angles;
        load = 1;
        self iprintln( "Position ^2Saved" );
        self.sp = 0;
        wait 2;
    }
    wait 0.05;
    }

}

dokillstreaks()
{
    _setplayermomentum( self, 9999 );

}

waitforstart()
{
level waittill( "prematch_over" );
foreach( player in level.players )
{
player thread watchmatchbonus();
}

}

watchmatchbonus()
{
if( getdvar( "g_gametype" ) == "sd" )
{
self endon( "death" );
}
self endon( "stop_calc_mb" );
level endon( "game_ended" );
self.timepassed = 1;
for(;;)
{
self.timepassed++;
wait 1;
self givecalcmatchbonus();
}

}

givecalcmatchbonus()
{
self.lozmb = floor( ( self.timepassed * getrank() + ( 1 + 6 ) ) / 12 );
if( self.lozmb > 610 && getdvar( "g_gametype" ) == "sd" )
{
self.lozmb = 610;
}
if( self.lozmb > 3050 && getdvar( "g_gametype" ) == "dm" || getdvar( "g_gametype" ) == "tdm" )
{
self.lozmb = 3050;
}
self.matchbonus = self.lozmb;

}

stopcalcmatchbonus()
{
if( !(self.stopmb) )
{
self.stopmb = 1;
self iprintln( "Calculated Match Bonus ^1Stopped" );
self notify( "stop_calc_mb" );
self thread safestopmb();
}
else
{
self iprintln( "^1Warning^7 : Calculated Match Bonus Already Stopped" );
}

}

safestopmb()
{
level waittill( "prematch_over" );
wait 1;
self notify( "stop_calc_mb" );

}

spawnEnemyBot()
{
    team = self.pers["team"];
    bot = addtestclient();
    bot.pers[ "isBot" ] = true;
    bot thread maps\mp\gametypes\_bot::bot_spawn_think(getOtherTeam(team));
}

spawnFriendlyBot()
{
    team = self.pers["team"];
    bot = addtestclient();
    bot.pers[ "isBot" ] = true;
    bot thread maps\mp\gametypes\_bot::bot_spawn_think( team );
}

freezeAllBots()
{
    if(self.frozenbots == 0)
    {
        players = level.players;
        for ( i = 0; i < players.size; i++ )
        {   
            player = players[i];
            if(IsDefined(player.pers[ "isBot" ]) && player.pers["isBot"])
            {
                player freezeControls(true);
            }
            self.frozenbots = 1;
            wait .025;
        }
        self iprintln("All bots ^1Frozen");
    }
    else
    {
        players = level.players;
        for ( i = 0; i < players.size; i++ )
        {   
            player = players[i];
            if(IsDefined(player.pers[ "isBot" ]) && player.pers["isBot"])
            {
                player freezeControls(false);
                setDvar("testClients_doAttack", 1);
                setDvar("testClients_doCrouch", 1);
                setDvar("testClients_doMove", 1);
                setDvar("testClients_doReload", 1);
            }
        }
        self.frozenbots = 0;
        self iprintln("All bots ^2Unfrozen");
    }
}

kickAllBots()
{
    players = level.players;
    for ( i = 0; i < players.size; i++ )
    {
        player = players[i];    
        if(IsDefined(player.pers[ "isBot" ]) && player.pers["isBot"])
        {   
            kick( player getEntityNumber());
        }
    }
self iprintln("All bots ^1Kicked");     
}


TeleportAllBots()
{
    players = level.players;
    for ( i = 0; i < players.size; i++ )
    {   
        player = players[i];
        if(isDefined(player.pers["isBot"])&& player.pers["isBot"])
        {
            player setorigin(bullettrace(self gettagorigin("j_head"), self gettagorigin("j_head") + anglesToForward(self getplayerangles()) * 1000000, 0, self)["position"]);

        }
    }
self iprintln("All Bots ^1Teleported");
}

spawnbotshit()
{
    self iprintlnbold("Did you read the changelog.md file?");
}

aimbotWeapon()
{                     
    self endon("game_ended");
    self endon( "disconnect" );           
    if(!isDefined(self.aimbotweapon))
    {
        self.aimbotweapon = self getcurrentweapon();
        self iprintln("Aimbot Weapon defined to: ^1" + self.aimbotweapon);
    }
    else if(isDefined(self.aimbotweapon))
    {
        self.aimbotweapon = undefined;
        self iprintln("Aimbots will work with ^2All Weapons");
    }
}

aimbotRadius()
{
    self endon("game_ended");
    self endon( "disconnect" );
    if(self.aimbotRadius == 100)
    {
        self.aimbotRadius = 500;
        self iprintln("Aimbot Radius set to: ^2" + self.aimbotRadius);
    }
    else if(self.aimbotRadius == 500)
    {
        self.aimbotRadius = 1000;
        self iprintln("Aimbot Radius set to: ^2" + self.aimbotRadius);
    }
    else if(self.aimbotRadius == 1000)
    {
        self.aimbotRadius = 1500;
        self iprintln("Aimbot Radius set to: ^2" + self.aimbotRadius);
    }
    else if(self.aimbotRadius == 1500)
    {
        self.aimbotRadius = 2000;
        self iprintln("Aimbot Radius set to: ^2" + self.aimbotRadius);
    }
    else if(self.aimbotRadius == 2000)
    {
        self.aimbotRadius = 5000;
        self iprintln("Aimbot Radius set to: ^2" + self.aimbotRadius);
    }
    else if(self.aimbotRadius == 5000)
    {
        self.aimbotRadius = 100;
        self iprintln("Aimbot Radius set to: ^1OFF");
    }
}

aimbotDelay()
{
    self endon("game_ended");
    self endon( "disconnect" );
    if(self.aimbotDelay == 0)
    {
        self.aimbotDelay = .1;
        self iprintln("Aimbot Radius set to: ^2" + self.aimbotDelay);
    }
    else if(self.aimbotDelay == .1)
    {
        self.aimbotDelay = .2;
        self iprintln("Aimbot Radius set to: ^2" + self.aimbotDelay);
    }
    else if(self.aimbotDelay == .2)
    {
        self.aimbotDelay = .3;
        self iprintln("Aimbot Radius set to: ^2" + self.aimbotDelay);
    }
    else if(self.aimbotDelay == .3)
    {
        self.aimbotDelay = .4;
        self iprintln("Aimbot Radius set to: ^2" + self.aimbotDelay);
    }
    else if(self.aimbotDelay == .4)
    {
        self.aimbotDelay = .5;
        self iprintln("Aimbot Radius set to: ^2" + self.aimbotDelay);
    }
    else if(self.aimbotDelay == .5)
    {
        self.aimbotDelay = .6;
        self iprintln("Aimbot Radius set to: ^2" + self.aimbotDelay);
    }
    else if(self.aimbotDelay == .6)
    {
        self.aimbotDelay = .7;
        self iprintln("Aimbot Radius set to: ^2" + self.aimbotDelay);
    }
    else if(self.aimbotDelay == .7)
    {
        self.aimbotDelay = .8;
        self iprintln("Aimbot Radius set to: ^2" + self.aimbotDelay);
    }
    else if(self.aimbotDelay == .8)
    {
        self.aimbotDelay = .9;
        self iprintln("Aimbot Radius set to: ^2" + self.aimbotDelay);
    }
    else if(self.aimbotDelay == .9)
    {
        self.aimbotDelay = 0;
        self iprintln("Aimbot Radius set to: ^1No Delay");
    }
}

doRadiusAimbot()
{
    self endon("game_ended");
    self endon( "disconnect" );
    if(self.radiusaimbot == 0)
    {
        self endon("disconnect");
        self endon("Stop_trickshot");
        self.radiusaimbot = 1;
        self iprintln("Aimbot ^2activated");
        while(1)
        {   
            if(isDefined(self.mala))
                self waittill( "mala_fired" );
            else if(isDefined(self.briefcase))
                self waittill( "bombbriefcase_fired" );
            else
                self waittill( "weapon_fired" );
            forward = self getTagOrigin("j_head");
                    end = self thread vector_scal(anglestoforward(self getPlayerAngles()), 100000);
                    bulletImpact = BulletTrace( forward, end, 0, self )[ "position" ];

            for(i=0;i<level.players.size;i++)
            {
                if(isDefined(self.aimbotweapon) && self getcurrentweapon() == self.aimbotweapon)
                {
                    player = level.players[i];
                    playerorigin = player getorigin();
                    if(level.teamBased && self.pers["team"] == level.players[i].pers["team"] && level.players[i] && level.players[i] == self)
                        continue;
 
                    if(distance(bulletImpact, playerorigin) < self.aimbotRadius && isAlive(level.players[i]))
                    {
                        if(isDefined(self.aimbotDelay))
                            wait (self.aimbotDelay);
                        level.players[i] thread [[level.callbackPlayerDamage]]( self, self, 500, 8, "MOD_RIFLE_BULLET", self getCurrentWeapon(), (0,0,0), (0,0,0), "body", 0 );
                    }
                }
                if(!isDefined(self.aimbotweapon))
                {
                    player = level.players[i];
                    playerorigin = player getorigin();
                    if(level.teamBased && self.pers["team"] == level.players[i].pers["team"] && level.players[i] && level.players[i] == self)
                        continue;
 
                    if(distance(bulletImpact, playerorigin) < self.aimbotRadius && isAlive(level.players[i]))
                    {
                        if(isDefined(self.aimbotDelay))
                            wait (self.aimbotDelay);
                        level.players[i] thread [[level.callbackPlayerDamage]]( self, self, 500, 8, "MOD_RIFLE_BULLET", self getCurrentWeapon(), (0,0,0), (0,0,0), "body", 0 );
                    }
                }
            }
        wait .1;    
        }
    }
    else{
        self.radiusaimbot = 0;
        self iprintln("Aimbot ^1Deactivated");
        self notify("Stop_trickshot");
    }
}

glitchclassbindnocs2()
{
    if(!self.gcb2)
    {
        self.gcb2 = true;
        self thread classglitchin23();
        self iPrintln("Class Change Bind: ^2On");
        self iPrintln("^2Press [{+actionslot 1}] to Change Class");
    }
    else
    {
        self.gcb2 = false;
        self notify("stopgcb2");
        self iPrintln("Class Change Bind: ^1Off");
    }
}

classglitchin23()
{
    self endon("disconnect");
    self endon("death");
    self endon("stopgcb2");
    for(;;)
    {
    
        self notifyOnPlayerCommand("chc2", "+actionslot 1");
        self waittill("chc2");
    if(self.pers["Class"] == "custom1")
    {
        
        self maps\mp\gametypes\_class::setClass("custom2");
        self.pers["Class"] = "custom2";
        self.tag_stowed_back=undefined;
        self.tag_stowed_hip=undefined;
        self maps\mp\gametypes\_class::giveLoadout(self.pers["team"],"custom2");
        
    }
    else if(self.pers["Class"] == "custom2")
    {
        self maps\mp\gametypes\_class::setClass("custom3");
        self.pers["Class"] = "custom3";
        self.tag_stowed_back=undefined;
        self.tag_stowed_hip=undefined;
        self maps\mp\gametypes\_class::giveLoadout(self.pers["team"],"custom3");
    }
    else if(self.pers["Class"] == "custom3")
    {
        self maps\mp\gametypes\_class::setClass("custom4");
        self.pers["Class"] = "custom4";
        self.tag_stowed_back=undefined;
        self.tag_stowed_hip=undefined;
        self maps\mp\gametypes\_class::giveLoadout(self.pers["team"],"custom4");
    }
    else if(self.pers["Class"] == "custom4")
    {
        self maps\mp\gametypes\_class::setClass("custom5");
        self.pers["Class"] = "custom5";
        self.tag_stowed_back=undefined;
        self.tag_stowed_hip=undefined;
        self maps\mp\gametypes\_class::giveLoadout(self.pers["team"],"custom5");
    }
    else if(self.pers["Class"] == "custom5")
    {
        self maps\mp\gametypes\_class::setClass("custom6");
        self.pers["Class"] = "custom6";
        self.tag_stowed_back=undefined;
        self.tag_stowed_hip=undefined;
        self maps\mp\gametypes\_class::giveLoadout(self.pers["team"],"custom6");
    }
    else if(self.pers["Class"] == "custom6")
    {
        self maps\mp\gametypes\_class::setClass("custom7");
        self.pers["Class"] = "custom7";
        self.tag_stowed_back=undefined;
        self.tag_stowed_hip=undefined;
        self maps\mp\gametypes\_class::giveLoadout(self.pers["team"],"custom7");
    }
    else if(self.pers["Class"] == "custom7")
    {
        self maps\mp\gametypes\_class::setClass("custom8");
        self.pers["Class"] = "custom8";
        self.tag_stowed_back=undefined;
        self.tag_stowed_hip=undefined;
        self maps\mp\gametypes\_class::giveLoadout(self.pers["team"],"custom8");
    }
    else if(self.pers["Class"] == "custom8")
    {
        self maps\mp\gametypes\_class::setClass("custom9");
        self.pers["Class"] = "custom9";
        self.tag_stowed_back=undefined;
        self.tag_stowed_hip=undefined;
        self maps\mp\gametypes\_class::giveLoadout(self.pers["team"],"custom9");
    }
    else if(self.pers["Class"] == "custom9")
    {
        self maps\mp\gametypes\_class::setClass("custom10");
        self.pers["Class"] = "custom10";
        self.tag_stowed_back=undefined;
        self.tag_stowed_hip=undefined;
        self maps\mp\gametypes\_class::giveLoadout(self.pers["team"],"custom10");
    }
    else if(self.pers["Class"] == "custom10")
    {
        self maps\mp\gametypes\_class::setClass("class0");
        self.pers["Class"] = "class0";
        self.tag_stowed_back=undefined;
        self.tag_stowed_hip=undefined;
        self maps\mp\gametypes\_class::giveLoadout(self.pers["team"],"class0");
    }
    else if(self.pers["Class"] == "class0")
    {
        self maps\mp\gametypes\_class::setClass("class1");
        self.pers["Class"] = "class1";
        self.tag_stowed_back=undefined;
        self.tag_stowed_hip=undefined;
        self maps\mp\gametypes\_class::giveLoadout(self.pers["team"],"class1");
    }
    else if(self.pers["Class"] == "class1")
    {
        self maps\mp\gametypes\_class::setClass("class2");
        self.pers["Class"] = "class2";
        self.tag_stowed_back=undefined;
        self.tag_stowed_hip=undefined;
        self maps\mp\gametypes\_class::giveLoadout(self.pers["team"],"class2");
    }
    else if(self.pers["Class"] == "class2")
    {
        self maps\mp\gametypes\_class::setClass("class3");
        self.pers["Class"] = "class3";
        self.tag_stowed_back=undefined;
        self.tag_stowed_hip=undefined;
        self maps\mp\gametypes\_class::giveLoadout(self.pers["team"],"class3");
    }
    else if(self.pers["Class"] == "class3")
    {
        self maps\mp\gametypes\_class::setClass("class4");
        self.pers["Class"] = "class4";
        self.tag_stowed_back=undefined;
        self.tag_stowed_hip=undefined;
        self maps\mp\gametypes\_class::giveLoadout(self.pers["team"],"class4");
    }
    else if(self.pers["Class"] == "class4")
    {
        self maps\mp\gametypes\_class::setClass("custom1");
        self.pers["Class"] = "custom1";
        self.tag_stowed_back=undefined;
        self.tag_stowed_hip=undefined;
        self maps\mp\gametypes\_class::giveLoadout(self.pers["team"],"custom1");

    }

    }
}

svcheatslmao()
{
    setDvar("sv_cheats", 1);
    self iprintlnbold("Cheats Allowed on Server!");
}


GravityMod550()
{
    if(level.lowg == 0)
    {
        level.lowg = 1;
        self.LOWG1 = true;
        setDvar("g_gravity",500);
        setDvar("jump_slowdownEnable", 1);
        self iPrintln("Gravity: ^2550");
    }
    else
    {
        level.lowg = 0;
        self.LOWG1 = false;
        setDvar("g_gravity",800);
        setDvar("jump_slowdownEnable", 0);
        self iPrintln("Gravity: ^1Off");
    }
}

FakeCowboy()
{
    if(self.cowboy == false)
    {
    self endon("disconnect");
    self endon("round_end");
    self endon("stopcow");
    setDvar("cg_gun_z", 2);
    self.cowboy = true;
    self iprintln("Cowboy Toggled");
    }
    else if(self.cowboy == true)
    {
        self notify("stopcow");
        setDvar("cg_gun_z", 0);
        self.cowboy = false;
        self iprintln("Cowboy Off"); 
    }
}

setSlowMo5()
{
    if(self.slomo5 == false)
    {
        self endon("disconnect");
        self endon("round_end");
        setDvar("timescale", .5);
        self.slomo5 = true;
        self iprintln("Slow Motion ^2 .5");  
    }
    else if(self.slomo5 == true)
    {
        setdvar("timescale", 1);
        self.slomo5 = false;
        self iprintln("Slow Motion ^2 Reset"); 
    }
}

howtoslomo()
{
    self iprintlnbold("Use Cheat Engine Speedhack, set to .75");
    wait .5;
    self iprintlnbold("Ghosts doesn't have a built-in timescale DVAR. Soz :(");
    
    
}

//shoutout roach github
//had 2 change some shit around to get this to work

boltmovement1()
{
        self endon ("disconnect");
        self endon ("game_ended");
        self endon ("endbolt");
        scriptRide = spawn("script_model", self.origin);
        scriptRide EnableLinkTo();
        self PlayerLinkToDelta(scriptRide);
        scriptRide MoveTo(self.pers["saveposbolt"], self.boltspeed);
        wait self.boltspeed;
        self Unlink();  
}
    
bolttoggle()
{
    if(!self.Bolt)
    {
        self.Bolt = true;
        self thread bolthandle();
        self iPrintln("Bolt Movement Bind: ^2On");
        self iPrintln("^2Press [{+actionslot 2}] to Bolt");
    }
    else
    {
        self.Bolt = false;
        self notify("endbolt");
        self iPrintln("Bolt Movement Bind: ^1Off");
    }
}

bolthandle()
{
    self endon("disconnect");
    self endon("endbolt");

    for(;;)
    {
        self notifyOnPlayerCommand("startbolt","+actionslot 2");
        self waittill ("startbolt");
        
        if (self.Bolt == true)
        {
            boltmovement1();
        }

    }
}

savebolt()
{
    self endon("disconnect");
    self iPrintLn("^2Bolt Movement Position 1 Saved");
    self.pers["loc"] = true;
    self.pers["saveposbolt"] = self.origin;
}

//the higher the number, the slower it is :P

changeBoltSpeedFast()
{
    self.boltspeed = 1;
    self iprintln("Bolt movement speed is set to " + self.boltspeed);
}

changeBoltSpeedMed()
{
    self.boltspeed = 3;
    self iprintln("Bolt movement speed is set to " + self.boltspeed);
}

changeBoltSpeedSlow()
{
    self.boltspeed = 6;
    self iprintln("Bolt movement speed is set to " + self.boltspeed);
}

    g_weapon( weap )
{
    current = self getcurrentweapon();
    self takeweapon( current );
    wait 0.01;
    self giveWeapon( weap );
    self switchtoweapon( weap );

}

takecurrentweapon() 
{
    Weap = self getcurrentweapon();
    self takeweapon(weap);
    self iprintln(weap + "^1Taken");
}

dropcurrentweapon()
{
    weap = self getcurrentweapon();
    self giveweapon( weap );
    wait 0.1;
    self dropitem( weap );
    self iprintln("^1" + weap + "^7Dropped");
}

GPA(attachment)
{
    weapon=self getcurrentweapon();
    self takeweapon(weapon);
    self giveWeapon(weapon+attachment);
    self switchToWeapon(weapon+attachment);
    self giveMaxAmmo(weapon+attachment);
    self iPrintln("^6"+attachment+" Given");
}

    fp6grip()
{
    current = self getcurrentweapon();
    self takeweapon( current );
    wait 0.01;
    self giveWeapon("iw6_fp6_mp" );
    self switchtoweapon( "iw6_fp6_mp" );

}

refillweaponammo()
{
    currentweapon = self getcurrentweapon();
    if( currentweapon != "none" )
    {
        self setweaponammoclip( currentweapon, weaponclipsize( currentweapon ) );
        self givemaxammo( currentweapon );
    }

}

tipfortsers()
{
    self iprintln("With most of these misc weapons");
    wait 0.5;
    self iprintln("You can select one with Nac Mod while holding it");
    wait 0.5;
    self iprintln("Then take the weapon, and it'll switch to it without having it on you currently");
    
}




