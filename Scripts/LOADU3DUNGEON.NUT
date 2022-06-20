/*
Program for Grid Cartographer to import a full U3 dungeon from the script Ultima3_dungeons.cs
@RikRetro on Twitter

From http://nodling.nullneuron.net/ultima/text/ultima3/u3tech_cga.txt :

Dungeon tiles:

0x00 = empty
0x01 = vision of the Time Lord
0x02 = fountain (type?)
0x03 = strange wind (extinguishes your torch)
0x04 = trap
0x05 = mark (type depends on dungeon)
0x06 = gremlins (they steal your food)
0x07 = (not used)
0x08 = sign (text depends on dungeon level)
0x10 = ladder up
0x20 = ladder down
0x30 = ladder up/down
0x40 = chest
0x50 = chest + ladder up (can't get chest)
0x60 = chest + ladder down (can't get chest)
0x70 = chest + ladder up/down (can't get chest)
0x80 = wall
0x90 = (not used)
0xA0 = illusionary wall
0xB0 = (not used)
0xC0 = door
0xD0 = (not used)
0xE0 = (not used)
0xF0 = (not used)

*/
function main( args )
{


	GCConsole.Print("\n");
	var buf = GCBuffer.Create();
	GCBuffer.Prepare(buf, 256000);
	var res = GCImport.BufferAs(buf, "Select csv file with an Ultima 3 dungeon data", "CSV", "Comma-Delimited Files");
	if (res != GCOK) {
		GCConsole.Print("Error opening file: " + res + "\n");
		return;
	}
	GCKernel.SetBlockingMode(true);
	
	var nFloors = 8;	// total # of floors
	var curFloor = -1;
	
	// Create n floors (disabled because crashes GC 2022.5 - Create the floors manually!)
	// GCFloor.Select(-1 * nFloors);
	// GCFloor.Create();
	
	// Load the floor data
	GCBuffer.Seek(buf, 0);
	var idTile = "00";
	var delim = ",";
	var r = 0;
	var c = 0;
	while (curFloor >= (-1 * nFloors))
	{
		GCFloor.Select(curFloor);
		GCTile.Select(0,0);
		GCFloor.Clear(GCFloor.CLEAR_ALL);
		while ((c + r*16) < 16*16)
		{
			idTile = GCBuffer.ReadChars(buf, 2);
			if (idTile == null) {
				break;
			}
			GCTile.Select(c,r);
			GCConsole.Print(idTile+",");
			var intTile = idTile.ToInt(16);
			switch (intTile) {
				case 0x01: /* vision of the Time Lord */
				{
					GCTile.Set({Marker = { Type = 24, Color = 83 }});
					break;
				}
				case 0x02: /* fountain (type?) */
				{
					GCTile.Set({Marker = { Type = 16, Color = 83 }});
					break;
				}
				case 0x03: /* strange wind (extinguishes your torch) */
				{
					GCTile.Set({ FX = { Dark = true } });
					break;
				}
				case 0x04: /* trap */
				{
					GCTile.Set({Marker = { Type = 51, Color = 83 }});
					break;
				}
				case 0x05: /* mark */
				{
					GCTile.Set({Marker = { Type = 127, Color = 83 }});
					break;
				}
				case 0x06: /* gremlins */
				{
					GCTile.Set({Marker = { Type = 14, Color = 83 }});
					break;
				}
				case 0x08: /* sign (misty writing) */
				{
					GCTile.Set({Marker = { Type = 25, Color = 83 }});
					break;
				}
				case 0x10: /* up ladder */
				case 0x50: /* chest + ladder up (can't get chest) */
				{
					GCTile.Set({Marker = { Type = 26, Color = 83 }});
					break;
				}
				case 0x20: /* down ladder */
				case 0x60: /* chest + ladder down (can't get chest) */
				{
					GCTile.Set({Marker = { Type = 27, Color = 83 }});
					break;
				}
				case 0x30: /* up+down ladder */
				case 0x70: /* chest + ladder up/down (can't get chest) */
				{
					GCTile.Set({Marker = { Type = 44, Color = 83 }});
					break;
				}
				case 0x40: /* chest */
				{
					GCTile.Set({Marker = { Type = 46, Color = 83 }});
					break;
				}
				case 0x80: /* full wall */
				{
					GCTile.Set({Terrain = { Type = 39, Color = 15 }});
					break;
				}
				case 0xa0: /* hidden door */
				{
					GCTile.Set({Terrain = { Type = 39, Color = 9 }});
					//GCTile.Set({Marker = { Type = 134, Color = 83 }});
					break;
				}
				case 0xc0: /* door */
				{
					GCTile.Set({Marker = { Type = 134, Color = 83 }});
					break;
				}
				case 0: /* empty */
				{
					break;
				}
				default:
				{
					GCConsole.Print("Found unknown tile type: "+intTile+"\n");
					break;
				}
			}
			
			delim = GCBuffer.ReadChars(buf,1);
			if (delim == null) {
				break;
			}
			switch (delim) {
				case "," :
					{
						c = c+1;
						//GCConsole.Print(c+" , "+r+"\n");
						break;
					};
				case "\r" :
						delim = GCBuffer.ReadChars(buf,1);
				case "\n" :
					{
						r = r+1;
						c = 0;
						GCConsole.Print("\n");
						break;
					};
			}
		}
		curFloor--;
		r = 0;
		c = 0;
	}
	
	GCConsole.Print("\n");
	GCKernel.SetBlockingMode(false);
}