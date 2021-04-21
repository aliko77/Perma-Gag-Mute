#pragma semicolon 1

#define DEBUG
#define PLUGIN_AUTHOR "ali<.d"
#define PLUGIN_VERSION "1.00"

#include <sourcemod>
#include <sdktools>
#include <multicolors>
#include <basecomm>
#include <discord>
//#include <voiceannounce_ex>

#define WEBHOOK webhook
#pragma newdecls required

char mydata[PLATFORM_MAX_PATH];

int permamute[MAXPLAYERS + 1];
int permagag[MAXPLAYERS + 1];

ConVar g_tag;
char tag1[999];
ConVar g_webhook;
char webhook[999];

public Plugin myinfo = 
{
	name = "Perma Mute-Gag",
	author = PLUGIN_AUTHOR,
	description = "GÖTÜ YİYEN BUNUDA AÇSIN",
	version = PLUGIN_VERSION,
	url = "https://steamcommunity.com/id/alispw77"
};

public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	AutoExecConfig(true, "PermaGagMute", "alispw77");
	RegAdminCmd("sm_unmute", Command_unmute, ADMFLAG_CHAT);
	RegAdminCmd("sm_pmute", Command_Permamute, ADMFLAG_KICK);
	RegAdminCmd("sm_pgag", Command_Permagag, ADMFLAG_KICK);
	RegAdminCmd("sm_pungag", Command_Permaungag, ADMFLAG_KICK);
	RegAdminCmd("sm_punmute", Command_Permaunmute, ADMFLAG_KICK);
	RegConsoleCmd("sm_permagor", Command_Permagor);
	g_tag = CreateConVar("tag", "leaderclan", "Tagı giriniz");
	g_webhook = CreateConVar("webhook", "", "Discord WebHook Giriniz.", FCVAR_NOTIFY);
}

public void OnMapStart()
{
	BuildPath(Path_SM, mydata, sizeof(mydata), "configs/alispw77/PermaGagMute.txt");
}

public void OnClientPostAdminCheck(int client)
{
	PermamiControl(client);
}

/*public void OnClientSpeakingEx(client)
{
	if (permamute[client] == 1)
	{
		CPrintToChatAll("Bu oyuncu perma-muteli olduğu için konuşamaz.");
		BaseComm_SetClientMute(client, true);
	}
	PrintToChatAll("test");
	return;
}*/

void PermamiControl(int client)
{
	char buffer[128];
	char s_name[128];
	GetClientAuthId(client, AuthId_Steam2, buffer, sizeof(buffer));	
	Handle kv = CreateKeyValues("PermaGagMute");
	FileToKeyValues(kv, mydata);
	KvJumpToKey(kv, buffer, true);
	do
	{
		KvGetSectionName(kv, s_name, sizeof(s_name));
		if (StrEqual(buffer, s_name))
		{
			if (KvGetNum(kv, "PermaGag") == 1 && KvGetNum(kv, "PermaMute") == 1)
			{
				permagag[client] = 1;
				permamute[client] = 1;
				BaseComm_SetClientMute(client, true);
				BaseComm_SetClientGag(client, true);
			}
			else if (KvGetNum(kv, "PermaGag") == 1 && KvGetNum(kv, "PermaMute") == 0)
			{
				permagag[client] = 1;
				permamute[client] = 0;
				BaseComm_SetClientGag(client, true);
				KvDeleteKey(kv, "PermaMute");
				KvDeleteKey(kv,"Mutelenen Kisi");
			}
			else if (KvGetNum(kv, "PermaGag") == 0 && KvGetNum(kv, "PermaMute") == 1)
			{
				permagag[client] = 0;
				permamute[client] = 1;
				BaseComm_SetClientMute(client, true);
				BaseComm_SetClientGag(client, false);	
				KvDeleteKey(kv, "PermaGag");
				KvDeleteKey(kv,"Gaglanan Kisi");
			}
			else if (KvGetNum(kv, "PermaGag") == 0 && KvGetNum(kv, "PermaMute") == 0)
			{
				permagag[client] = 0;
				permamute[client] = 0;
				BaseComm_SetClientGag(client, false);
				KvDeleteThis(kv);
				KvRewind(kv);
				KeyValuesToFile(kv, mydata);
			}		
		}
	}
	while(KvGotoNextKey(kv));
	CloseHandle(kv);	
}

public Action Command_unmute(int client, int args)
{
	if (args > 0)
	{
		char arg1[128];
		int target;
		GetCmdArg(1, arg1, sizeof(arg1));
		target = FindTarget(client, arg1, true);
		if(permamute[target])
		{
			CPrintToChatAll("[%s] {orange}%N {green}Perma-Muteli olduğu için bu oyuncunun {orange}mute{green}'si açılamaz", tag1, target);
			CreateTimer(1.0, timer_mute, target);
			return Plugin_Handled;
		}	
	}
	return Plugin_Continue;
}

public Action timer_mute(Handle timer, any client){
	BaseComm_SetClientMute(client, true);
}

public Action Command_Permagor(int client, int args)
{
	if (args == 0)
	{
		GetConVarString(g_tag, tag1, sizeof(tag1));
		Handle menuhandle1 = CreateMenu(menu_bos, MenuAction_Select);
		SetMenuTitle(menuhandle1, "PermaGag-Mute'li Oyuncular");
		KeyValues kv = new KeyValues("PermaGagMute");
		SetMenuExitButton(menuhandle1, true);
		char sFile[PLATFORM_MAX_PATH];
		BuildPath(Path_SM, sFile, sizeof(sFile), "configs/alispw77/PermaGagMute.txt");
		
		if (!FileExists(sFile))
		{
			CPrintToChatAll("[%s] {orange}[PermaGag] \"%s\" bulunamadı!", tag1, sFile);
			return Plugin_Handled;
		}
		
		kv.ImportFromFile(sFile);
		
		if (!kv.GotoFirstSubKey())
		{
			CPrintToChatAll("[%s] {orange}PermaGag veya Muteli Kimse Yok", tag1);
			return Plugin_Handled;
		}
		
		char sBuffer[64];
		char kimbuyakisikli[128];
		char buffergag[64];
		char buffermute[64];
		char buffer_mevcut[64];
		do
		{
			kv.GetSectionName(sBuffer, sizeof(sBuffer));
			KvGetString(kv, "PermaGag", buffergag, sizeof(buffergag));
			KvGetString(kv, "PermaMute", buffermute, sizeof(buffermute));
			if (StrEqual(buffergag, "1") && StrEqual(buffermute, "1"))
			{
				KvGetString(kv, "Gaglanan Kisi", kimbuyakisikli, sizeof(kimbuyakisikli));
				if (strlen(kimbuyakisikli) > 0)
				{
					Format(buffer_mevcut, sizeof(buffer_mevcut), "%s [Perma-Gaglı ve Muteli]", kimbuyakisikli);
					AddMenuItem(menuhandle1, sBuffer, buffer_mevcut, 1);
				}
				else
				{
					KvGetString(kv, "Mutelenen Kisi", kimbuyakisikli, sizeof(kimbuyakisikli));
					Format(buffer_mevcut, sizeof(buffer_mevcut), "%s [Perma-Gaglı ve Muteli]", kimbuyakisikli);
					AddMenuItem(menuhandle1, sBuffer, buffer_mevcut, 1);
				}				
			}			
			else if (StrEqual(buffergag, "1"))
			{
				KvGetString(kv, "Gaglanan Kisi", kimbuyakisikli, sizeof(kimbuyakisikli));
				if (strlen(kimbuyakisikli) > 0)
				{
					Format(buffer_mevcut, sizeof(buffer_mevcut), "%s [Perma-Gaglı]", kimbuyakisikli);
					AddMenuItem(menuhandle1, sBuffer, buffer_mevcut, 1);
				}
				else
				{
					KvGetString(kv, "Mutelenen Kisi", kimbuyakisikli, sizeof(kimbuyakisikli));
					Format(buffer_mevcut, sizeof(buffer_mevcut), "%s [Perma-Gaglı]", kimbuyakisikli);
					AddMenuItem(menuhandle1, sBuffer, buffer_mevcut, 1);
				}
			}
			else if (StrEqual(buffermute, "1"))
			{
				KvGetString(kv, "Mutelenen Kisi", kimbuyakisikli, sizeof(kimbuyakisikli));
				if (strlen(kimbuyakisikli) > 0)
				{
					Format(buffer_mevcut, sizeof(buffer_mevcut), "%s [Perma-Muteli]", kimbuyakisikli);
					AddMenuItem(menuhandle1, sBuffer, buffer_mevcut, 1);
				}
				else
				{
					KvGetString(kv, "Gaglanan Kisi", kimbuyakisikli, sizeof(kimbuyakisikli));
					Format(buffer_mevcut, sizeof(buffer_mevcut), "%s [Perma-Muteli]", kimbuyakisikli);
					AddMenuItem(menuhandle1, sBuffer, buffer_mevcut, 1);
				}
			}			
		}
		while (kv.GotoNextKey());
		delete kv;
		DisplayMenu(menuhandle1, client, MENU_TIME_FOREVER);
	}
	return Plugin_Continue;
}

public int menu_bos(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		CloseHandle(menu);
	}
	
	if(action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

public Action Command_Permaungag(int client, int args)
{
	GetConVarString(g_tag, tag1, sizeof(tag1));
	char strTarget[20];	
	if (args < 1)
	{
		ReplyToCommand(client, "[%s] Kullanım: !pungag {green}nick", tag1);
		return Plugin_Handled;
	}
	GetCmdArg(1, strTarget, sizeof(strTarget));
	int target = FindTarget(client, strTarget, true);
	if(target == -1)
	{
		
		return Plugin_Handled;		
	}	
	if (permagag[target] == 0)
	{
		ReplyToCommand(client, "[%s] Bu oyuncunun zaten permagag'ı bulunmuyor.", tag1);
		return Plugin_Handled;
	}
	char buffer[128];
	char s_name[128];
	permagag[target] = 0;
	GetClientAuthId(target, AuthId_Steam2, buffer, sizeof(buffer));	
	Handle kv = CreateKeyValues("PermaGagMute");
	FileToKeyValues(kv, mydata);
	KvJumpToKey(kv, buffer, true);
	do
	{
		KvGetSectionName(kv, s_name, sizeof(s_name));
		if (StrEqual(buffer, s_name))
		{
			if (KvGetNum(kv, "PermaGag") == 1)
			{
				BaseComm_SetClientGag(target, false);
				ReplyToCommand(client, "[%s] %N kullanıcının perma-gagı kaldırıldı.", tag1, target);
				CPrintToChatAll("[%s] {orange}%N {green}adlı admin, {orange}%N {green}adlı kullanıcının perma-gag'ını kaldırdı.", tag1, client, target);
				KvDeleteKey(kv,"PermaGag");
				KvDeleteKey(kv,"Gag Atan Kisi");
				KvDeleteKey(kv,"Gaglanan Kisi");
				KvRewind(kv);
				KeyValuesToFile(kv, mydata);
			}				
		}
	}
	while(KvGotoNextKey(kv));
	CloseHandle(kv);
	return Plugin_Continue;
}

public Action Command_Permaunmute(int client, int args)
{
	GetConVarString(g_tag, tag1, sizeof(tag1));
	char strTarget[20];	
	if (args < 1)
	{
		ReplyToCommand(client, "[%s] Kullanım: {darkred}!punmute {green}nick", tag1);
		return Plugin_Handled;
	}
	GetCmdArg(1, strTarget, sizeof(strTarget));
	int target = FindTarget(client, strTarget, true);
	if(target == -1)
	{
		
		return Plugin_Handled;		
	}	
	if (permamute[target] == 0)
	{
		ReplyToCommand(client, "[%s] Bu oyuncunun zaten permamute'si bulunmuyor.", tag1);
		return Plugin_Handled;
	}
	char buffer[128];
	char s_name[128];
	permamute[target] = 0;
	GetClientAuthId(target, AuthId_Steam2, buffer, sizeof(buffer));	
	Handle kv = CreateKeyValues("PermaGagMute");
	FileToKeyValues(kv, mydata);
	KvJumpToKey(kv, buffer, true);
	do
	{
		KvGetSectionName(kv, s_name, sizeof(s_name));
		if (StrEqual(buffer, s_name))
		{
			if (KvGetNum(kv, "PermaMute") == 1)
			{
				BaseComm_SetClientMute(target, false);
				ReplyToCommand(client, "[%s] %N kullanıcının perma-mutesi kaldırıldı.", tag1, target);
				CPrintToChatAll("[%s] {orange}%N {green}adlı admin, {orange}%N {green}adlı kullanıcının perma-mute'sini kaldırdı.", tag1, client, target);
				KvDeleteKey(kv,"PermaMute");
				KvDeleteKey(kv,"Mute Atan Kisi");
				KvDeleteKey(kv,"Mutelenen Kisi");
				KvRewind(kv);
				KeyValuesToFile(kv, mydata);
			}				
		}
	}
	while(KvGotoNextKey(kv));
	CloseHandle(kv);	
	return Plugin_Continue;
}

public Action Command_Permagag(int client, int args)
{
	GetConVarString(g_tag, tag1, sizeof(tag1));
	char strTarget[20];
	char sebep[128];
	if (args < 2)
	{
		ReplyToCommand(client, "[%s] Kullanım: !pgag <nick> <sebep>", tag1);
		return Plugin_Handled;
	}
	GetCmdArg(1, strTarget, sizeof(strTarget));
	GetCmdArgString(sebep, sizeof(sebep)); 
	ReplaceString(sebep, sizeof(sebep), strTarget, "", false);
	int target = FindTarget(client, strTarget, true);
	if(target == -1)
	{
		
		return Plugin_Handled;		
	}	
	if (permagag[target] == 1)
	{
		ReplyToCommand(client, "[%s] Bu oyuncunun zaten permagag'ı bulunuyor.", tag1);
		return Plugin_Handled;
	}
	char buffer[128];
	char buffern[128];
	char buffern2[128];
	char atilankisi[128];
	char atankisi[128];
	char atilmazamani[128];
	permagag[target] = 1;
	GetClientAuthId(target, AuthId_Steam2, buffer, sizeof(buffer));
	GetClientName(client, buffern, sizeof(buffern));
	GetClientName(target, buffern2, sizeof(buffern2));
	BaseComm_SetClientGag(target, true);
	GetConVarString(g_webhook, webhook, sizeof(webhook));
	if (strlen(webhook) > 0)
	{
		char Tarih[128];
		FormatTime(Tarih, 128, "%d/%m/20%y", GetTime());
		char saat[128];
		FormatTime(saat, sizeof(saat), "%H:%M", GetTime());	
		DiscordWebHook hook = new DiscordWebHook(WEBHOOK);
		Format(atilankisi, sizeof(atilankisi), "%s",buffern2);
		Format(atankisi, sizeof(atankisi), "%s",buffern);
		Format(atilmazamani, sizeof(atilmazamani), "%s - %s", Tarih, saat);
		hook.SlackMode = true;
		
		hook.SetUsername("Perma Gag-Mute");
		
		MessageEmbed Embed = new MessageEmbed();
		
		Embed.SetColor("#ff0000");
		Embed.SetTitle("PermaGag");
		Embed.AddField("Atılma Zamanı:", atilmazamani, false);
		Embed.AddField("Perma Gag Atılan Kişi", atilankisi, true);
		Embed.AddField("Perma Gag'ı Atan Kişi", atankisi, true);
		Embed.AddField("Sebep:", sebep, false);
		Embed.SetAuthor("Author:alispw77");
		Embed.SetAuthorLink("https://steamcommunity.com/id/alikoc77/");
		Embed.SetAuthorIcon("https://i.ibb.co/bKnFpwV/Ads-z-removebg-preview.png");
		hook.Embed(Embed);
		
		hook.Send();
		delete hook;
	}
	Handle kv = CreateKeyValues("PermaGagMute");
	FileToKeyValues(kv, mydata);
	KvJumpToKey(kv, buffer, true);
	KvSetNum(kv, "PermaGag", permagag[target]);
	KvSetString(kv, "Gaglanan Kisi", buffern2);
	KvSetString(kv, "Gag Atan Kisi", buffern);
	KvRewind(kv);
	KeyValuesToFile(kv, mydata);
	CloseHandle(kv);	
	ReplyToCommand(client, "[%s] %N kullanıcısına perma-gag atıldı.", tag1, target);
	CPrintToChatAll("[%s] {orange}%N {green}adlı admin, {orange}%N {green}adlı kullanıcıya perma gag attı.", tag1, client, target);
	return Plugin_Continue;
}

public Action Command_Permamute(int client, int args)
{
	GetConVarString(g_tag, tag1, sizeof(tag1));
	char strTarget[20];
	char sebep[128];
	if (args < 2)
	{
		ReplyToCommand(client, "[%s] Kullanım: !pmute <nick> <sebep>", tag1);
		return Plugin_Handled;
	}
	GetCmdArg(1, strTarget, sizeof(strTarget));
	int target = FindTarget(client, strTarget, true);
	GetCmdArgString(sebep, sizeof(sebep)); 
	ReplaceString(sebep, sizeof(sebep), strTarget, "", false);
	if(target == -1)
	{
		
		return Plugin_Handled;		
	}	
	if (permamute[target] == 1)
	{
		ReplyToCommand(client, "[%s] Bu oyuncunun zaten perma-mute'si bulunuyor.", tag1);
		return Plugin_Handled;
	}
	char buffer[128];
	char buffern[128];
	char buffern2[128];
	char atilankisi[128];
	char atankisi[128];
	char atilmazamani[128];
	permamute[target] = 1;
	BaseComm_SetClientMute(target, true);
	GetClientAuthId(target, AuthId_Steam2, buffer, sizeof(buffer));
	GetClientName(client, buffern, sizeof(buffern));
	GetClientName(target, buffern2, sizeof(buffern2));
	if (strlen(webhook) > 0)
	{	
		char Tarih[512];	
		FormatTime(Tarih, 512, "%d/%m/20%y", GetTime());	
		char saat[512];
		FormatTime(saat, sizeof(saat), "%H:%M", GetTime());
		DiscordWebHook hook = new DiscordWebHook(WEBHOOK);
		Format(atilankisi, sizeof(atilankisi), "%s",buffern2);
		Format(atankisi, sizeof(atankisi), "%s",buffern);
		Format(atilmazamani, sizeof(atilmazamani), "%s - %s", Tarih, saat);
		hook.SlackMode = true;
		
		hook.SetUsername("Perma Gag-Mute");
		
		MessageEmbed Embed = new MessageEmbed();
		Embed.SetColor("#ff0000");
		Embed.SetTitle("PermaMute");
		Embed.AddField("Atılma Zamanı:", atilmazamani, false);
		Embed.AddField("Perma Mute Atılan Kişi", atilankisi, true);
		Embed.AddField("Perma Mute'yi Atan Kişi", atankisi, true);
		Embed.AddField("Sebep:", sebep, false);
		Embed.SetAuthor("Author:alispw77");
		Embed.SetAuthorLink("https://steamcommunity.com/id/alikoc77/");
		Embed.SetAuthorIcon("https://i.ibb.co/bKnFpwV/Ads-z-removebg-preview.png");
		hook.Embed(Embed);
		
		hook.Send();
		delete hook;
	}
	Handle kv = CreateKeyValues("PermaGagMute");
	FileToKeyValues(kv, mydata);
	KvJumpToKey(kv, buffer, true);
	KvSetNum(kv, "PermaMute", permamute[target]);
	KvSetString(kv, "Mutelenen Kisi", buffern2);
	KvSetString(kv, "Mute Atan Kisi", buffern);
	KvRewind(kv);
	KeyValuesToFile(kv, mydata);
	CloseHandle(kv);
	ReplyToCommand(client, "[%s] %N kullanıcısına perma-mute atıldı.", tag1, target);
	CPrintToChatAll("[%s] {orange}%N {green}adlı admin, {orange}%N {green}adlı kullanıcıya perma-mute attı.", tag1, client, target);
	return Plugin_Continue;
}

public Action OnClientSayCommand(int client, const char[] command, const char[] sArgs)
{
	if (permagag[client] == 1)
	{
		GetConVarString(g_tag, tag1, sizeof(tag1));
		CPrintToChat(client, "[%s] {orange}Perma Gaglandığınız İçin Yazı Yazma Hakkınız Yok.Sorun olduğunu düşünüyorsanız !dc'ye gelip bildirebilirsin.",tag1);
	}
	return Plugin_Continue;
}
