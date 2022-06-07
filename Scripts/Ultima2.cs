using System;
using System.Diagnostics;
using System.Windows.Forms;
using System.IO;
using System.Collections.Generic;

/* Script to load a single Ultima 2 map file (not dungeon/tower)
   and transform it into a csv file with the correct EGA tile indexes
   for loading into Grid Cartographer using SETTILESU2.NUT
   */

class Script
{
    [STAThread]
    static public void Main(string[] args)
    {
		StreamWriter sw = new StreamWriter(@"C:\Users\hasse\OneDrive\Desktop\U2 Work\TEST_U2.csv");
		byte[] readText = File.ReadAllBytes(@"D:\GOG Games\Ultima 2\MAPX10");
		int i = 0;
        foreach(byte s in readText)
        {
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
        //		   sw.WriteLine($"<region id=\"1{tempLine[0]}\" name=\"{tempLine[1]}\" ground_floor=\"true\" start_floor=\"G\" auto_create=\"true\" >\n<grid width=\"{tempLine[2]}\" height=\"{tempLine[2]}\" tilex=\"1\" tiley=\"1\" repeating=\"false\" origin_tl=\"true\" />\n</region>");

        sw.Close();
	}
}