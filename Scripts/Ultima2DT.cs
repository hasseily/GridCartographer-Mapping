using System;
using System.Diagnostics;
using System.Windows.Forms;
using System.IO;
using System.Collections.Generic;

/* Script to load a single Ultima 2 dungeon/tower map file
   and transform it into a csv file with the correct EGA tile indexes
   for loading into Grid Cartographer using SETTILESU2DT.NUT
   
   The dungeon/tower levels are 16x16. We want to display them in one 64x64 map,
   where the first 4 levels are on the top row, then 5-8, etc...
   */

class Script
{
    [STAThread]
    static public void Main(string[] args)
    {
		StreamWriter sw = new StreamWriter(@"C:\Users\hasse\OneDrive\Desktop\U2 Work\TEST_U2.csv");
		byte[] readText = File.ReadAllBytes(@"D:\GOG Games\Ultima 2\MAPG85");
		int i = 0;	// index into x
		int j = 0;	// index into y
		int k = 0;	// index into the level
		while (k < 16)
		{
			while (j < 16)
			{
				while (i < 16)
				{
					sw.Write((readText[i + (j*16) + (k*16*16)]).ToString("X2"));
					sw.Write(",");
					i++;
				}
				i = 0;
				while (i < 16)
				{
					sw.Write((readText[i + (j*16) + ((k+1)*16*16)]).ToString("X2"));
					sw.Write(",");
					i++;
				}
				i = 0;
				while (i < 16)
				{
					sw.Write((readText[i + (j*16) + ((k+2)*16*16)]).ToString("X2"));
					sw.Write(",");
					i++;
				}
				i = 0;
				while (i < 16)
				{
					sw.Write((readText[i + (j*16) + ((k+3)*16*16)]).ToString("X2"));
					if (i < 15)
					{
						sw.Write(",");
					}
					i++;
				}
				sw.Write("\n");
				i = 0;
				j ++;
			}
			j = 0;
			k += 4;
		}

        //		   sw.WriteLine($"<region id=\"1{tempLine[0]}\" name=\"{tempLine[1]}\" ground_floor=\"true\" start_floor=\"G\" auto_create=\"true\" >\n<grid width=\"{tempLine[2]}\" height=\"{tempLine[2]}\" tilex=\"1\" tiley=\"1\" repeating=\"false\" origin_tl=\"true\" />\n</region>");

        sw.Close();
	}
}