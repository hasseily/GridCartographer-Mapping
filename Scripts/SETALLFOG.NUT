/*
Sets everything to have fog of war. Every level, every region.
*/
function main( args )
{
	// init
	var nFloors = 1;
	var nRegions = GCRegion.Count();
	GCKernel.SetBlockingMode(true);
	
	var iReg = 0;
	var iFloor = 0;

	while (iReg < GCRegion.Count())
	{
		GCRegion.Select(iReg);
		GCConsole.Print("Current region is: " + GCRegion.Active() + "\n");
		iFloor = GCFloor.Lowest();
		
		while (GCFloor.Exists(iFloor))
		{
			GCFloor.Select(iFloor);
			GCConsole.Print("    Floor " + GCFloor.Active() + "\n");
			var bounds = GCFloor.FindBound();
			if (bounds.edge_only_left)
			{
				bounds.min_x = bounds.min_x + 1;
			}
			if (bounds.edge_only_top)
			{
				bounds.min_y = bounds.min_y + 1;
			}
			
			GCTile.Select(bounds.min_x, bounds.min_y);
			while (GCTile.ActiveY() <= bounds.max_y){
				while (GCTile.ActiveX() <= bounds.max_x){
					GCTile.Set({ Visible = false });
					GCTile.Select(GCTile.ActiveX() + 1, GCTile.ActiveY());
				}
				GCTile.Select(0, GCTile.ActiveY() + 1);
			}
			iFloor++;
		}
		iReg++;
	}
	// deinit
	GCKernel.SetBlockingMode(false);
	
}