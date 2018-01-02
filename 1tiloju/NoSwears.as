//chat filter

array<string> wordreplace =
{
	//swears
	"fucker", 	"flipper",
	"fuck", 	"flip",
	"shitt", 	"poop",
	"shit", 	"poop",
	"crapp", 	"poop",
	"crap", 	"poop",
	"faggot", 	"professional",
	"dyke", 	"wall",
	"nigger", 	"friend",
	"gook", 	"friend",
	"sluts", 	"ladies",
	"slut", 	"lady",
	"bitches", 	"ladies",
	"bitch", 	"lady",
	"cunt", 	"cat",
	"minge", 	"cat",
	"twat", 	"cat",
	"pussy", 	"cat",
	"dick", 	"clown",
	"cock", 	"clown",
	"peen", 	"clown",
	"wank", 	"sing",
	"rape", 	"hurt",
};

bool isupper(u8 c)
{
	return (c >= 0x41 && c <= 0x5A);
}

u8 tolower(u8 c)
{
	if (isupper(c))
		c += 0x20;
	return c;
}

string tolower(string s)
{
	int len = s.size();
	for (int i = 0; i < len; i++)
		s[i] = tolower(s[i]);
	return s;
}

string KidSafeText(const string &in textIn)
{
	string text = textIn;
	string comparetext = tolower(textIn);

	for (uint i = 0; i < wordreplace.length - 1; i += 2)
	{
		int pos = 0;
		do
		{
			pos = comparetext.find(wordreplace[i]);
			if (pos != -1)
			{
				//replace in lowercase search string
				string before = pos > 0 ? comparetext.substr(0, pos) : "";
				string after = comparetext.substr(pos + wordreplace[i].size());
				comparetext = before + wordreplace[i + 1] + after;
				//replace in preserved-caps string
				before = pos > 0 ? text.substr(0, pos) : "";
				after = text.substr(pos + wordreplace[i].size());
				text = before + wordreplace[i + 1] + after;
			}
		}
		while (pos != -1);
	}

	return text;
}

bool onClientProcessChat(CRules@ this, const string &in textIn, string &out textOut, CPlayer@ player)
{
	if (!g_noswears) 		//no processing
	{
		textOut = textIn;
		return true;
	}

	textOut = KidSafeText(textIn);

	return true;
}

//can enable filter server-side too :)
bool onServerProcessChat(CRules@ this, const string &in textIn, string &out textOut, CPlayer@ player)
{
	if (!g_noswears) 		//no processing
	{
		textOut = textIn;
		return true;
	}

	textOut = KidSafeText(textIn);

	return true;
}
