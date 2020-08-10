#include <multicolors>
#include <sourcemod>
#include <sdktools>
#include <store>

#pragma tabsize 0

public Plugin myinfo = 
{
	name = "Crash Game",
	author = "Emur",
	description = "Crash game for players.",
	version = "1.0",
	url = "https://steamcommunity.com/id/EmurIsTaken/"
};
//CVars
Handle crash_time, crash_max, crash_min;

//Countdown
int seconds;

int onmenu[MAXPLAYERS + 1]; //To see is player on the panel or not.
int situation[MAXPLAYERS + 1]; //To see player's situation in the game.
int isstarted; //To see is game on or not.
int bet[MAXPLAYERS + 1], totalgained[MAXPLAYERS + 1];
float number; //The number that gets higher.
float x; // The number that is the limit.

public void OnPluginStart()
{
	//Trans
	LoadTranslations("crash.phrases.txt");
	
	//ConVars
	crash_time = CreateConVar("crash_time", "30", "How many seconds should it take to start.");
	crash_max = CreateConVar("crash_max", "10000", "Maximum amount of bets.");
	crash_min = CreateConVar("crash_min", "1", "Minimum amount of bets.");
	
	AutoExecConfig(true, "crash", "emur");
	
	//Commands
	RegConsoleCmd("sm_crash", crash, "Command to see the panel");
	
	seconds = GetConVarInt(crash_time);
	CreateTimer(1.0, maintimer, _, TIMER_REPEAT); //The timer that counts down.
}

public Action crash(int client, int args)
{
	if(args < 1)
	{
		onmenu[client] = 1;
		CreateTimer(0.1, crashpanel, client, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
    }
   	else if(situation[client] == 0 && args >= 1 && isstarted == 0)
	{
		//Classical bet shits.
		char arg1[32];
		GetCmdArg(1, arg1, sizeof(arg1));
		bet[client] = StringToInt(arg1);
		if(Store_GetClientCredits(client) < bet[client])
		{
			CPrintToChat(client, "{darkred}[SM] {default}%t", "Yetersizkredi");
			return Plugin_Handled;
	   	 }
	   	else if(bet[client] > GetConVarInt(crash_max))
		{
			CPrintToChat(client, "{darkred}[SM] {default}%t", "Yuksekbahis", GetConVarInt(crash_max));
			return Plugin_Handled;
	   	 }
	  	else if(bet[client] < GetConVarInt(crash_min))
	   	{
	    	CPrintToChat(client, "{darkred}[SM] {default}%t", "Endusukbahis", GetConVarInt(crash_min));
			return Plugin_Handled;
	    	}
	   	else
	   	{
	    	Store_SetClientCredits(client, Store_GetClientCredits(client) - bet[client]);
		  	situation[client] = 1;
		   	CPrintToChat(client, "{darkred}[SM] {default}%t", "bahisbasarili");
		}   	 
    	}
   	else if(situation[client] != 1 )
    	{
    	CPrintToChat(client, "{darkred}[SM] {default}%t", "zatenbahis");
   	 }
   	else if(isstarted == 1)
    	{
    	CPrintToChat(client, "{darkred}[SM] {default}%t", "isstartedd");
    	}
   	return Plugin_Stop;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
public Action maintimer(Handle timer)
{
	seconds--;
	if(seconds == 600 || seconds == 300 || seconds == 60 || seconds == 30 || seconds == 10 || seconds <= 3  && seconds > 0)
	{
		for(int i = 1; i <= MaxClients; i++)
		{
			if(onmenu[i] == 0 && IsClientInGame(i) && !IsFakeClient(i))
			{
		    	if(seconds > 60)
		    	{
				    int minutes = seconds / 60;
				    CPrintToChat(i, "{darkred}[SM] {default}%t", "sondakika", minutes);	    
	        	}
	        	else if(seconds == 60)
	        	{
	        		CPrintToChat(i, "{darkred}[SM] {default}%t", "1dakika");
	        	}
	        	else
	        	{
	        		if(seconds <= 3)
    				{
    					if(IsClientInGame(i) && !IsFakeClient(i) && situation[i] != 0 && onmenu[i] == 0)
    					{
    					
    						onmenu[i] = 1;
    						CreateTimer(0.1, crashpanel, i, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
        				}
    				}			
	    		   	CPrintToChat(i, "{darkred}[SM] {default}%t", "sonsaniye" ,seconds);	    
	        	}
	        }
	  	 }	
    }	
   	else if(seconds == 0)
    {
    	StartTheGame();
    }
  	return Plugin_Continue;
}

public void StartTheGame()
{
	isstarted = 1, number = 1.00; //Boring things.
	
	//Gets the X
	int luckynumber = GetRandomInt(1, 100);
	if(luckynumber <= 15)
	{
		x = GetRandomFloat(1.00, 1.25);
    }
   	else if(luckynumber <= 70 && luckynumber > 15)
    {
    	x = GetRandomFloat(1.25, 2.00);
    }
 	else if(luckynumber <= 98 && luckynumber > 70)
    {
    	x = GetRandomFloat(2.00, 10.00);
    }
 	else if (luckynumber <= 100 && luckynumber > 98)
    {
    	x = GetRandomFloat(6.00, 100.00);
    }
	
	CreateTimer(0.1, makeithigher, _, TIMER_REPEAT); // That boi will increase the number.
}

public Action makeithigher(Handle timer)
{
	if(number < x)
	{
		number = number + number/200; //Didn't want to increase it for the same number everytime. With this way its gets faster every second.
	}
	else
	{
	   	number = 0.0; //We need that for the loop.
	   	ResetIt();
	   	return Plugin_Stop;
	}
  	return Plugin_Continue;
}

public void ResetIt()
{
	CreateTimer(5.0, resettimer);
	for(int i = 1; i <= MaxClients; i++)
	{
		if(onmenu[i] == 1 && IsClientInGame(i) && !IsFakeClient(i))
		{
			EmitSoundToClient(i, "emur/crash/sifir.mp3"); //The sound that will make players break their keyboards. Yea that happened.
	    }
    }
}

public Action resettimer(Handle timer)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		bet[i] = 0;
   		situation[i] = 0;
    }
   	seconds = GetConVarInt(crash_time);
   	isstarted = 0;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
public Action crashpanel(Handle timer, any client)
{
	//I dont have any idea about this part.
	if(onmenu[client] == 1 && IsClientInGame(client) && !IsFakeClient(client))
	{
		char betword[64], gainedcredits[64];
		Format(betword, sizeof(betword), "%t", "bahis");
		Format(gainedcredits, sizeof(gainedcredits), "%t", "kazanilan");
		if(isstarted == 0)
		{
			char kalansaniye[32];
		    Format(kalansaniye, sizeof(kalansaniye), "|      %t: %ds", "basliyoroc", seconds);
		    Panel crashmenu_baslamadan = new Panel();
		    crashmenu_baslamadan.SetTitle("Crash");
		    crashmenu_baslamadan.DrawText("---------------------------------");
            crashmenu_baslamadan.DrawText("^");
            crashmenu_baslamadan.DrawText("|  ");
            crashmenu_baslamadan.DrawText("|  ");
            crashmenu_baslamadan.DrawText("|"); 
            crashmenu_baslamadan.DrawText(kalansaniye);
            crashmenu_baslamadan.DrawText("|  ");
            crashmenu_baslamadan.DrawText("|  ");
            crashmenu_baslamadan.DrawText("| __ __ __ __ __ __ __ __ ");
            crashmenu_baslamadan.DrawText("---------------------------------");
			if(situation[client] == 0)
			{
				char tobet[32];
				char command[32];
				Format(tobet, sizeof(tobet), "       %t", "bahisicin");
				Format(command, sizeof(command), "          %t", "komut");
				crashmenu_baslamadan.DrawText(tobet);
			    crashmenu_baslamadan.DrawText(command);
			    crashmenu_baslamadan.DrawText("---------------------------------");
		    }
		    else if(situation[client] == 1)
	        {
	    	    char buffer[64];
	    	    char buffer2[64];
	    	    Format(buffer, sizeof(buffer), "%s: %d", betword,bet[client]);
	    	    Format(buffer2, sizeof(buffer2), "%s: -",gainedcredits);
	    	    crashmenu_baslamadan.DrawText(buffer2);
	    	    crashmenu_baslamadan.DrawText(buffer);
	    	    crashmenu_baslamadan.DrawText("---------------------------------");
	        }
	        SetPanelCurrentKey(crashmenu_baslamadan, 9);
	        crashmenu_baslamadan.DrawItem("Close");
	        crashmenu_baslamadan.DrawText("---------------------------------");
	        crashmenu_baslamadan.Send(client, crashmenu, 1);
	        delete crashmenu_baslamadan;
	    }
	    else if(isstarted == 1)
	    {
	    	char numberZ[32], betZ[32], gainedZ[32];
	    	if(number != 0.0)
	    	{
		       Format(numberZ, sizeof(numberZ), "|                x%3.2f", number);
		    }
		    else
		    {
		    	Format(numberZ, sizeof(numberZ), "|                x%3.2f", x);
		    }
		    Format(betZ, sizeof(betZ), "%s: %d",betword, bet[client]);
		    Format(gainedZ, sizeof(gainedZ), "%s: %d",gainedcredits, RoundToFloor(bet[client] * number));
		    Panel crashmenu_aktif = new Panel();
		    crashmenu_aktif.SetTitle("Crash");
		    crashmenu_aktif.DrawText("---------------------------------");
            crashmenu_aktif.DrawText("^");
            crashmenu_aktif.DrawText("|  ");
            crashmenu_aktif.DrawText("|  ");
            crashmenu_aktif.DrawText("|"); 
            crashmenu_aktif.DrawText(numberZ);
            if(number != 0)
            {
                crashmenu_aktif.DrawText("|  ");
            }
            else
            {
            	crashmenu_aktif.DrawText("|              CRASH!");
            }
            crashmenu_aktif.DrawText("|  ");
            crashmenu_aktif.DrawText("| __ __ __ __ __ __ __ __ ");
            crashmenu_aktif.DrawText("---------------------------------");
            if(situation[client] == 0)
            {
            	SetPanelCurrentKey(crashmenu_aktif, 9);
            	crashmenu_aktif.DrawItem("Close");
            	crashmenu_aktif.DrawText("---------------------------------");
            	if(number != 0.0)
            	{
            	    crashmenu_aktif.Send(client, crashmenu, 1);
                }
                else
                {
                	crashmenu_aktif.Send(client, crashmenu, 5);                     	
                }
                delete crashmenu_aktif;     
            }
            else if(situation[client] == 1 || situation[client] == 2)
            {
            	if(situation[client] == 1)
            	{
            		crashmenu_aktif.DrawText(gainedZ);
                }
                else if(situation[client] == 2)
                {
                	char lastgain[32];
                	Format(lastgain, sizeof(lastgain), "%s: %d",gainedcredits, totalgained[client]);
                	crashmenu_aktif.DrawText(lastgain);
                }
            	crashmenu_aktif.DrawText(betZ);
            	crashmenu_aktif.DrawText("---------------------------------");
            	if(situation[client] == 1)
            	{
            		if(number != 0.0)
            		{
            			SetPanelCurrentKey(crashmenu_aktif, 9);
            		    crashmenu_aktif.DrawItem("Withdraw");
            		    crashmenu_aktif.DrawText("---------------------------------");
            		    crashmenu_aktif.Send(client, crashmenu_go, 1);
            		    delete crashmenu_aktif;
            	    }
            	    else
            	    {
            	    	SetPanelCurrentKey(crashmenu_aktif, 9);
            	    	crashmenu_aktif.DrawItem("Okey");
            	    	crashmenu_aktif.DrawText("---------------------------------");
            		    crashmenu_aktif.Send(client, crashmenu_go, 5);  
						delete crashmenu_aktif;            		    
            	    }
                }
                else if(situation[client] == 2)
                {
                	SetPanelCurrentKey(crashmenu_aktif, 9);
                	crashmenu_aktif.DrawItem("Close");
                	crashmenu_aktif.DrawText("---------------------------------");
                	if(number != 0.0)
                	{
                	    crashmenu_aktif.Send(client, crashmenu_go, 1);
                	    delete crashmenu_aktif;  
                	}
                	else
                	{
                		crashmenu_aktif.Send(client, crashmenu_go, 5);
                		delete crashmenu_aktif;  
                    }
                } 	
            }
	    }
    }
  	else
    {
    	return Plugin_Stop;
    }
  	return Plugin_Continue;

}

public int crashmenu_go(Menu menu, MenuAction action, int param1, int param2)
{
	if(action == MenuAction_Select)
	{
		if(situation[param1] == 1 && number == 0)
		{
			onmenu[param1] = 0;
	    }
	  	else if(situation[param1] == 1 && number != 0)
		{
			totalgained[param1] = RoundToFloor(bet[param1] * number);
			situation[param1] = 2;
			int newcredits = Store_GetClientCredits(param1) + totalgained[param1];
	   		Store_SetClientCredits(param1, newcredits);
	   		if(number > 5)
			{
				CPrintToChatAll("{darkred}[SM] %t", "5xkazandin", param1, number, totalgained[param1]);
		    }
		 	else
		    {
		    	EmitSoundToClient(param1, "emur/crash/kazandi.mp3");
		    	CPrintToChat(param1, "{darkred}[SM] %t", "1xkazandin", number, totalgained[param1]);
		    }
	    }
	 	else if(situation[param1] == 2)
		{
			onmenu[param1] = 0;
	    }
    }
  	else if(action == MenuAction_End)
    {
    }
  	else if(action == MenuAction_Cancel)
    {
    }
}

public int crashmenu(Menu menu, MenuAction action, int param1, int param2)
{
	if(action == MenuAction_Select)
	{
		onmenu[param1] = 0;
    }
  	else if(action == MenuAction_End)
    {
    }
  	else if(action == MenuAction_Cancel)
    {    
    }
}

public void OnMapStart()
{
	AddFileToDownloadsTable("sound/emurs/crash/sifir.mp3");
	AddFileToDownloadsTable("sound/emur/crash/kazandi.mp3");
	PrecacheSound("emur/crash/sifir.mp3");
	PrecacheSound("emur/crash/kazandi.mp3");
}

