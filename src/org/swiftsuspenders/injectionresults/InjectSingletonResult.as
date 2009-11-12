/*
* Copyright (c) 2009 the original author or authors
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

package org.swiftsuspenders.injectionresults
{
	import flash.utils.Dictionary;
	
	import org.swiftsuspenders.InjectionConfig;
	import org.swiftsuspenders.Injector;

	public class InjectSingletonResult implements IInjectionResult
	{
		/*******************************************************************************************
		 *								private properties										   *
		 *******************************************************************************************/
		private var config:InjectionConfig;
		private var singletons:Dictionary;
		
		
		/*******************************************************************************************
		 *								public methods											   *
		 *******************************************************************************************/
		public function InjectSingletonResult(config:InjectionConfig)
		{
			this.config = config;
		}
		
		public function getResponse(injector : Injector, singletons : Dictionary) : Object
		{
			var usedSingletonsMap : Dictionary = singletons;
			var result:Object;
			this.singletons = singletons;
			if (config.injectionName)
			{
				usedSingletonsMap = updateSingletonsMap();
			}
			result = usedSingletonsMap[config.request];
			if (!result)
			{
				result = usedSingletonsMap[config.request] = injector.instantiate(Class(config.response));
			}	
			return result;
		}
		
		
		/*******************************************************************************************
		 *								private methods											   *
		 *******************************************************************************************/
		private function updateSingletonsMap():Dictionary
		{
			var usedSingletonsMap:Dictionary = singletons[config.injectionName];
			if (!usedSingletonsMap)
			{
				usedSingletonsMap = singletons[config.injectionName] = new Dictionary();
			}	
			return usedSingletonsMap;
		}
	}
}