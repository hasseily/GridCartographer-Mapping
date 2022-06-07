using System;
using System.Diagnostics;
using System.Windows.Forms;
using System.IO;
using System.Collections.Generic;

/* Script to load the Ultima 2 world map file
   and transform it into a csv file with the correct EGA tile indexes
   for loading into Grid Cartographer using SETTILESU1.NUT
   
   From https://gigi.nullneuron.net/ultima/u1/formats.php :
   
   The world map consists of 13104 bytes. The world map itself is 168x156 or 26208. Therefore, for each byte read in on the world map, the byte represents two tiles. The low 4 bits represent the first tile while the next four bits represent the second. The numbers themselves need no conversion and are simply offset into the tileset generated from the xxxtiles.bin file. For example, a value of '10' will equal a grass tile '1' followed by a water tile '0'.
   
   TCD.BIN contains the town and castle maps. They are stored as 10x38x18 [this info also comes from Johnny Wood's notes]. This means that towns and castles are 38 tiles wide and 18 tiles high, and there are 10 of them. This is because there are 8 different towns and 2 castles, and they are repeated across each continent.
   
   */

class Script
{
    [STAThread]
    static public void Main(string[] args)
    {
		var pathPrefix = @"C:\Users\hasse\OneDrive\Desktop\U2 Work\Ultima 1\";

		// World map
		{
			StreamWriter sw = new StreamWriter(pathPrefix + "U1_world.csv");
			byte[] readText = File.ReadAllBytes(@"D:\GOG Games\Ultima 1\MAP.bin");
			int i = 0;
			foreach(byte s in readText)
			{
				int sh = (s & 0xf0) >> 4;	// high 4 bits
				int sl = s & 0x0f;			// low 4 bits;
				// tile id 4 (castle) and tile id 7 (town) have 2 animation tiles
				// They have to be considered as one tile for the map
				if (sh > 4)
					sh++;
				if (sh > 7)
					sh++;
				if (sl > 4)
					sl++;
				if (sl > 7)
					sl++;
				sw.Write(sh.ToString("X2"));	// high 4 bits
				sw.Write(",");
				sw.Write(sl.ToString("X2"));	// low 4 bits
				i = i + 2;
				if (i == 168)
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

			sw.Close();
		}

		// Towns and castles
		{
			byte[] readText = File.ReadAllBytes(@"D:\GOG Games\Ultima 1\TCD.bin");

			for (var m = 0; m < 10; m++)	// map id
			{
				StreamWriter sw = new StreamWriter(pathPrefix + $"U1_town_{m}.csv");
				 // maps are 38x18, but on disk they're rotated 18x38
				 // So we have to go through each map column by column and transpose into rows
				for (var j = 0; j < 18; j++)
				{
					for (var i = 0; i < 38; i++)
					{
						byte s = readText[m*18*38 + j + i*18];
						if (s > 55)		// beyond the limit, set to black square
							s = 1;
						sw.Write((s + 56).ToString("X2"));		// town tiles are offset by 56 for GC (they're after the world tiles)
						if (i == 37)
						{
							sw.Write("\n");
						}
						else
						{
							sw.Write(",");
						}
						// Console.WriteLine(m);
					}
				}
				sw.Close();
			}
		}
	}
}
