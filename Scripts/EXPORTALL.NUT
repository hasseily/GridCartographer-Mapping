/*
Exports all floors of all regions into PNG
*/
function main( args )
{
	// init
	var nFloors = 1;
	var nRegions = GCRegion.Count();
	GCKernel.SetBlockingMode(true);
	
	var iReg = 0;
	var iFloor = 0;
	var i = 1;

	while (iReg < GCRegion.Count())
	{
		GCRegion.Select(iReg);
		GCConsole.Print("Current region is: " + GCRegion.Active() + "\n");
		iFloor = GCFloor.Lowest();
		
		while (GCFloor.Exists(iFloor))
		{
			GCFloor.Select(iFloor);
			var ff = i.ToString();
			if (i < 10)
			{
				ff = "0"+i.ToString();
			}
			var fName = "D:\\Downloads\\U2\\" + ff + " - " + GCRegion.Name() + " - " + GCFloor.Name() + ".png";
			var res = GCExport.Image(fName);
			if (res != 0)
			{
				GCConsole.Print("Error " + res + " saving " + fName + "\n");
			}
			iFloor++;
			i++;
		}
		iReg++;
	}
	// deinit
	GCKernel.SetBlockingMode(false);
	
}