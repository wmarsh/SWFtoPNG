//	Copyright Wayne Marsh 2010 (http://marshgames.com/)
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

package Convert 
{
	import flash.display.*;
	import flash.events.*;
	import flash.filesystem.*;
	import flash.geom.Point;
	import flash.utils.ByteArray;
	import flash.utils.getQualifiedClassName;
	
	import mx.graphics.codec.PNGEncoder;
	
	public class WriteProcess extends EventDispatcher
	{
		private var _clip:MovieClip;
		
		private var _outputPath:String, _name:String;
		
		private var _drawnFrames:Array = [];
		private var _frameNumbers:Array = [];
		
		private var _contentWidth:int, _contentHeight:int;
		
		private var _crop:Boolean;
		
		private var _centerRegMark:Boolean;
		
		private var _remaining:int;
		
		public function WriteProcess()
		{
		}
		
		public function processClip(clip:MovieClip, width:int, height:int, outputPath:String, name:String, crop:Boolean, centerRegMark:Boolean):void
		{
			if (_clip) throw new Error("Already processing");
			
			_clip = clip;
			_clip.gotoAndStop(1);
			
			_contentWidth = width;
			_contentHeight = height;
			
			_outputPath = outputPath;
			_name = name;
			
			_frameNumbers = [];
			
			_crop = crop;
			
			_centerRegMark = centerRegMark;
			
			_clip.addEventListener(Event.ENTER_FRAME, enterFrame);
			
			_remaining = _clip.totalFrames;
			
			_clip.play();
			
			dispatchEvent(new Event("processingChanged", true, true));
		}
		
		private function drawCurrentFrame():void
		{
			var bmp:BitmapData = new BitmapData(_contentWidth, _contentHeight, true, 0);
			bmp.draw(_clip, _clip.transform.matrix);
			
			_drawnFrames.push(bmp);
			_frameNumbers.push(_clip.currentFrame);
		}
		
		// We have to do this on an enterFrame event btw,
		// because _clip.gotoAndStop() doesn't update until
		// the global playhead move & render happens
		private function enterFrame(e:Event):void
		{						
			if (_remaining-- > 0)
			{
				trace("draw", getQualifiedClassName(_clip), _clip.currentFrame);
				drawCurrentFrame();
			}
			else
			{
				trace("write", getQualifiedClassName(_clip));
				
				if (_crop)
				{
					var regCenter:Point;
					if (_centerRegMark)
					{
						regCenter = new Point(_clip.x, _clip.y);
					}
					
					var cropped:Array = CropBitmaps(_drawnFrames, regCenter);
					DisposeBitmaps(_drawnFrames);
					_drawnFrames = cropped;
				}
				
				writeFiles();
				
				DisposeBitmaps(_drawnFrames);
				_drawnFrames = [];
				
				_clip.removeEventListener(Event.ENTER_FRAME, enterFrame);
				_clip = null;
				dispatchEvent(new Event("processingChanged", true, true));
				
				dispatchEvent(new Event(Event.COMPLETE, true, true));
			}
			
			dispatchEvent(new Event("progressChanged", true, true));
		}
		
		private function writeFiles():void
		{
			for (var i:int = 0; i < _drawnFrames.length; i++)
			{
				writeFile(_drawnFrames[i], _frameNumbers[i], _outputPath, _name);
			}
		}
		
		private function writeFile(src:BitmapData, number:int, path:String, name:String):void
		{
			var file:File = new File;
			file.nativePath = path + "/" + name + "_" + String(number) + ".png";
			
			var encoder:PNGEncoder = new PNGEncoder;
			var encoded:ByteArray = encoder.encode(src);
			
			var fileStream:FileStream = new FileStream();
			fileStream.open(file, FileMode.WRITE);
			fileStream.writeBytes(encoded, 0);
			
			fileStream.close();
		}
		
		private static function DisposeBitmaps(bitmaps:Array):void
		{
			for each (var b:BitmapData in bitmaps)
			{
				b.dispose();
			}
		}
		
		[Bindable(event="processingChanged")]
		public function get processing():Boolean
		{
			return _clip != null;
		}
		
		// I can't believe I have to provided data to the progress bar in this ridiculous way
		public function get bytesLoaded():int {if (_clip) return _clip.currentFrame; return 0;}
		public function get bytesTotal():int {if (_clip) return _clip.totalFrames; return 1;}
	}
	
}