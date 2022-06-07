/*
Program for Grid Cartographer to import Ultima 2 Dungeon and Tower tile IDs into a map
@RikRetro on Twitter
*/
function main( args )
{
	if (args.Length() == 1) {
		GCConsole.Print("Usage: "+args[0]+" XStart YStart \n");
		return;
	}
	var customTilesIndexStart = 0;
	var rowStart = 0;
	var colStart = 0;
	if (args.Length() > 1) {
		customTilesIndexStart = args[1].ToInt(10);
	}
	if (args.Length() == 4) {
		colStart = args[2].ToInt(10);
		rowStart = args[3].ToInt(10);
	}

	GCConsole.Print("Custom Tiles start index is: " + customTilesIndexStart + "\n");
	var buf = GCBuffer.Create();
	GCBuffer.Prepare(buf, 256000);
	var res = GCImport.BufferAs(buf, "Select csv file with a list of custom tile IDs to import", "CSV", "Comma-Delimited Files");
	if (res != GCOK) {
		GCConsole.Print("Error opening file: " + res + "\n");
		return;
	}
	GCKernel.SetBlockingMode(true);
	GCBuffer.Seek(buf, 0);
	var idTile = "00";
	var delim = ",";
	var r = rowStart;
	var c = colStart;
	while (1) {
		idTile = GCBuffer.ReadChars(buf, 2);
		if (idTile == null) {
			break;
		}
		GCTile.Select(c,r);
		var intTile = idTile.ToInt(16);
		GCTile.Set({ Visible = true });
		switch (intTile) {
			case 0x80: /* full wall */
			{
				/* GCTile.Set({Terrain = { Type = 39, Color = 0 }}); */
				GCTile.Set({
					Elevation = 0,
					Terrain = { Type = 39, Color = 0 },
					Ceiling = false,
					FX = { B = false, Dark = false, G = false, R = false, S = true },
					InEdge = { Mode = 0 },
					Visible = true,
					Print = false
				});
				break;
			}
			case 0x10: /* up ladder */
			{
				GCTile.Set({Marker = { Type = 26, Color = 83, Switch = false }});
				break;
			}
			case 0x20: /* down ladder */
			{
				GCTile.Set({Marker = { Type = 27, Color = 83, Switch = false }});
				break;
			}
			case 0x30: /* ladder both ways */
			{
				GCTile.Set({Marker = { Type = 44, Color = 83, Switch = false }});
				break;
			}
			case 0x40: /* chest */
			{
				GCTile.Set({Marker = { Type = 46, Color = 83, Switch = false }});
				break;
			}
			case 0xC0: /* door */
			{
				GCTile.Set({
					Elevation = 0,
					Terrain = { Type = 39, Color = 0 },
					Ceiling = false,
					Marker = { Type = 134, Color = 83, Switch = false },
					FX = { B = false, Dark = false, G = false, R = false },
					/* InEdge = { Mode = 2, Style = 2, Color = 83 }, */
					Visible = true,
					Print = false
				});
				break;
			}
			case 0xE0: /* hidden door */
			{
				GCTile.Set({
					Elevation = 0,
					Terrain = { Type = 39, Color = 9 },
					Ceiling = false,
					/* Marker = { Type = 134, Color = 83, Switch = false }, */
					FX = { B = false, Dark = false, G = false, R = false },
					/* InEdge = { Mode = 2, Style = 29, Color = 83 }, */
					Visible = true,
					Print = false
				});
			/*
				GCTile.Set({Terrain = { Type = 39, Color = 10 }});
				GCTile.Set({Marker = { Type = 134, Color = 83, Switch = false }});
				*/
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
					c = colStart;
					GCConsole.Print(".");
					break;
				};
		}
	}
	GCConsole.Print("\n");
	GCKernel.SetBlockingMode(false);
}