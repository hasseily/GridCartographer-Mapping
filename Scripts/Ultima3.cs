using System;
using System.Diagnostics;
using System.Windows.Forms;
using System.IO;
using System.Collections.Generic;

/* Script to load the Ultima 3 non-dungeon maps
   and transform them into csv files with the correct tile ids
   for loading into Grid Cartographer using SETTILES.NUT

Pulled from https://wiki.ultimacodex.com/wiki/Ultima_III_internal_formats :

The .IMG files are simple:
Each of these files contains an 11*11 tile image. Each byte represents a tile number.

Sosaria and Ambrosia are as follows:

offset      length      purpose
0x0         0x1000      64*64 world map
0x1000      0x180       not used
0x1180      0x20        tile number of monster 1-32;  divide by 4 to get real tile number
0x11A0      0x20        tile number of tile under monster 1-32;  divide by 4 to get real tile number
0x11C0      0x20        x coordinate of monster 1-32
0x11E0      0x20        y coordinate of monster 1-32
0x1200      0x20        movement flag of monster 1-32
0x1220      0x1         x coordinate of whirlpool
0x1221      0x1         y coordinate of whirlpool
0x1222      0x1         signed byte to add to x coordinate of whirlpool; possible values: 0, 1, 0xFF
0x1223      0x1         signed byte to add to y coordinate of whirlpool; possible values: 0, 1, 0xFF
0x1224      0x1         current phase of left moon; ranges from 0-7
0x1225      0x1         current phase of right moon; ranges from 0-7
0x1226      0x1         current sub-phase of left moon; ranges from 0-0xB
0x1227      0x1         current sub-phase of right moon; ranges from 0-3

Monsters, horses, ships, chests
U3 stores the location of these objects by writing them directly into the map.

Monsters
Monsters are stored as basetile_number*4. The map tile under the monster is stored in the table at 0x11A0.

Horses
Horses are stored as 0x28 == horse_tile*4. The tile under the horse can only be 0x1, because you can only dismount a horse on a grass tile.

Ships
Ships are stored as 0x2C == ship_tile*4. The tile under the ship can only be 0x0.

Chests
The map tile under the chest is encoded in the lowest 2 bits of the tile: 0x24 == chest_tile*4 + 0 --> chest on bricks (tile 0x8) 0x25 == chest_tile*4 + 1 --> chest on grass (tile 0x1) 0x26 == chest_tile*4 + 2 --> chest on forest (tile 0x2) 0x27 == chest_tile*4 + 3 --> chest on deep forest (tile 0x3) Monsters can't walk onto chests, so there can only be one chest per map square.

   */

class Script
{
    [STAThread]
    static public void Main(string[] args)
    {
		var pathPrefix = @"C:\Users\hasse\OneDrive\Desktop\U2 Work\Ultima 3\";

		// .ULT maps (not dungeons)
		{
			String[] imgFiles = {"SOSARIA", "AMBROSIA", "BRITISH", "DAWN", "DEATH", "DEVIL", "EXODUS",
								"FAWN", "GREY", "LCB", "MONTOR_E", "MONTOR_W", "MOON", "YEW"};
			foreach(var imgFile in imgFiles)
			{
				StreamWriter sw = new StreamWriter(pathPrefix + $"U3_{imgFile}.csv");
				byte[] readText = File.ReadAllBytes(@"D:\GOG Games\Ultima 3\"+ $"{imgFile}.ULT");

				for (var p=0; p < 64*64; p++)	// the first 64x64 bytes are the static map
				{
					int s = (int)readText[p];
					// remove all non-tile items from the map
					switch (s)
					{
						case 0x24:	// chest on bricks
							s = 0x8 * 4;
							break;
						case 0x25:	// chest on grass
							s = 0x1 * 4;
							break;
						case 0x26:	// chest on forest
							s = 0x2 * 4;
							break;
						case 0x27:	// chest on deep forest
							s = 0x3 * 4;
							break;
						case 0x28:	// horse, only on grass tile
							s = 0x1 * 4;
							break;
						case 0x2c:	// ship, only on water
							s = 0x0 * 4;
							break;
						case 0x30:	// whirlpool, only on water
							s = 0x0 * 4;
							break;
						case 0x88:	// moongate. On grass only?
							s = 0x1 * 4;
							break;
					}
					readText[p] = (byte)s;
				}
				
				// Remove the monsters
				for (var m=0; m < 32; m++)
				{
					var cx = (int)readText[0x11c0 + m];		// x coord of monster m
					var cy = (int)readText[0x11e0 + m];		// y coord of monster m
					readText[cx + (cy*64)] = (byte)((int)readText[0x11A0] / 4);
				}
				
				
				// Now print out the cleaned map
				int i = 0;
				for(var p=0; p < 64*64; p++)
				{
					int s = (int)readText[p];
					sw.Write((s / 4).ToString("X2"));
					i++;
					if (i == 64)
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
		}
		
		
		// Brand/Fountain/Shrine/Time "maps"
		{
			String[] imgFiles = {"BRAND", "FOUNTAIN", "SHRINE", "TIME"};
			foreach(var imgFile in imgFiles)
			{
				StreamWriter sw = new StreamWriter(pathPrefix + $"U3_{imgFile}.csv");
				byte[] readText = File.ReadAllBytes(@"D:\GOG Games\Ultima 3\"+ $"{imgFile}.IMG");

				int i = 0;
				for(var p=0; p < 11*11; p++)
				{
					int s = (int)readText[p];
					sw.Write(s.ToString("X2"));
					i++;
					if (i == 11)
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

		}

	}
}
