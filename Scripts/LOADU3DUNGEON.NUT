/*
Program for Grid Cartographer to import a full U3 dungeon from the script Ultima3_dungeons.cs
@RikRetro on Twitter

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
			var intTile = idTile.ToInt(10);
			switch (intTile) {
				case 20: /* full wall */
				{
					GCTile.Set({Terrain = { Type = 39, Color = 15 }});
					break;
				}
				case 1: /* trap */
				{
					GCTile.Set({Marker = { Type = 51, Color = 83 }});
					break;
				}
				case 2: /* misty writing */
				{
					GCTile.Set({Marker = { Type = 25, Color = 83 }});
					break;
				}
				case 4: /* up ladder */
				{
					GCTile.Set({Marker = { Type = 26, Color = 83 }});
					break;
				}
				case 8: /* down ladder */
				{
					GCTile.Set({Marker = { Type = 27, Color = 83 }});
					break;
				}
				case 10: /* chest */
				{
					GCTile.Set({Marker = { Type = 46, Color = 83 }});
					break;
				}
				case 30: /* door */
				{
					GCTile.Set({Marker = { Type = 134, Color = 83 }});
					break;
				}
				case 28: /* hidden door */
				{
					GCTile.Set({Terrain = { Type = 39, Color = 9 }});
					//GCTile.Set({Marker = { Type = 134, Color = 83 }});
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
						GCConsole.Print(".");
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