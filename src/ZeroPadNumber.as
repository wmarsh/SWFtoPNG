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

package 
{
	public function ZeroPadNumber(number:Number, padding:uint):String
	{
		var s:String = String(number);
		
		while (s.length < padding + 1)
		{
			s = "0" + s;
		}
		
		return s;
	}
}