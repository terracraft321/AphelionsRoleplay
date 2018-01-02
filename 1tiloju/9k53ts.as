/* 9k53ts.as
 * author: Aphelion
 */

#include "38p58pt.as";

bool onServerProcessChat( CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player )
{
	if (player is null) return true;

	CBlob@ blob = player.getBlob();
	if    (blob is null) return true;

	string[] args = text_in.split(" ");
	if      (args[0] == "/sign")
	{
		string username = player.getUsername();
		string text = text_in.substr(6);

		if (text == "")
		{
			cmdSendMessage(username, "Usage: /sign [text]");
		}
		else if (text.size() > 100)
		{
			cmdSendMessage(username, "Message cannot contain more than 100 characters.");
		}
		else
		{
			CBlob@[] overlapping;

			if (blob.getOverlapping(@overlapping))
			{
				for(uint i = 0; i < overlapping.length; i++)
				{
					CBlob@ b = overlapping[i];
					if    (b !is null && b.getName() == "sign" && b.getTeamNum() == blob.getTeamNum())
					{
						b.set_string("text", text);
						b.Sync("text", true);

			            cmdSendMessage(username, "Signpost updated.");
						return true;
					}
				}
			}

			cmdSendMessage(username, "Signpost not found.");
		}
	}
	return true;
}
