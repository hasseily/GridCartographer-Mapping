using System;
using System.Diagnostics;
using System.Windows.Forms;
using System.IO;
using System.Collections.Generic;

/* Script to load the Ultima 3 dungeon maps
   and transform them into csv files
   for loading into Grid Cartographer using a special dungeon script
   There are no tiles here, the dungeons are 3D.

Pulled from https://wiki.ultimacodex.com/wiki/Ultima_III_internal_formats :

Offset	Length	Purpose
0x0		0x100	16*16 map of level 1
0x100	0x100	16*16 map of level 2
...		...		...
0x700	0x100	16*16 map of level 8
0x800	n*0x2	sign text offsets; n = 8, add 0x800 to get the real offset
0x810	0x80	sign texts; every sign text is a null-terminated ASCII string

There is at most one sign per dungeon level. To find out the text for a sign, use (dungeon_level-1) as an index into the table at 0x800.

// My own analysis of the bytes:
00: Empty
01: Trap
02: Misty Writing
04: Ladder up
08: Ladder down
10: Chest
20: Solid Wall
28: Hidden Door
30: Door

   */

class Script
{
    [STAThread]
    static public void Main(string[] args)
    {
		var pathPrefix = @"C:\Users\hasse\OneDrive\Desktop\U2 Work\Ultima 3\";

		// .ULT maps (not dungeons)
		{
			String[] imgFiles = {"DARDIN", "FIRE", "M", "MINE", "P", "PERINIAN", "TIME"};
			foreach(var imgFile in imgFiles)
			{
				StreamWriter sw = new StreamWriter(pathPrefix + $"U3_DUNGEON_{imgFile}.csv");
				byte[] readText = File.ReadAllBytes(@"D:\GOG Games\Ultima 3\"+ $"{imgFile}.ULT");

				// the first 8x16x16 bytes are the static map
				int i = 0;
				for (var lv=0; lv < 8; lv++)	// 8 levels
				{
					for (var p=lv*16*16; p < (lv+1)*16*16; p++)
					{
						int s = (int)readText[p];
						sw.Write((s / 4).ToString("X2"));
						i++;
						if (i == 16)
						{
							sw.Write("\n");
							i = 0;
						}
						else
						{
							sw.Write(",");
						}
						//Console.WriteLine(s);
					}
				}
				
				sw.Write("\n");
				// Then save the text strings for each level
				for (var s = 0; s < 8; s++)
				{
					String signString = "";
					var sOffset = (int)readText[0x800 + 2*s];
					char a;
					int k = 0;
					while (true)	// read the c-style string
					{
						a = (char)readText[sOffset + 0x800 + k];
						if (a == '\0')
							break;
						signString += a;
						k++;
					};
					if (signString.Length < 2)
						signString = "";
					sw.Write($"{s}:{signString}\n");
				}
				
				sw.Close();
			}
		}

	}
}
