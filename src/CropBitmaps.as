// 	Copyright Wayne Marsh 2010 (http://marshgames.com/)
//	
//	This file is part of SWFToPNG.
//	
//	SWFToPNG is free software: you can redistribute it and/or modify
//	it under the terms of the GNU General Public License as published by
//	the Free Software Foundation, either version 3 of the License, or
//	(at your option) any later version.
//	
//	SWFToPNG is distributed in the hope that it will be useful,
//	but WITHOUT ANY WARRANTY; without even the implied warranty of
//	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//	GNU General Public License for more details.
//	
//	You should have received a copy of the GNU General Public License
//	along with SWFToPNG.  If not, see <http://www.gnu.org/licenses/>.

package 
{
	import flash.geom.Rectangle;

	function CropBitmaps(bitmaps:Array):Array
	{
		var cropped:Array = [];
		
		var cropRect:Rectangle = FindBoundingRect(bitmaps);
		
		for (var i:int = 0; i < bitmaps.length; i++)
		{
			cropped.push(CropBitmap(bitmaps[i], cropRect));
		}
		
		return cropped;
	}
}

import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;

function CropBitmap(bitmap:BitmapData, cropRect:Rectangle):BitmapData
{
	var cropped:BitmapData = new BitmapData(cropRect.width, cropRect.height, true, 0);
	
	cropped.copyPixels(bitmap, cropRect, new Point(0, 0));
	
	return cropped;
}

function FindBoundingRect(bitmaps:Array):Rectangle
{
	var cropRect:Rectangle = new Rectangle;
	
	for each (var bmp:BitmapData in bitmaps)
	{
		var bounds:Rectangle = bmp.getColorBoundsRect(0xFF000000, 0, false);
		
		cropRect = cropRect.union(bounds);
	}
	
	return cropRect;
}