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

package org.swiftsuspenders.injectionpoints
{
	import flash.utils.Dictionary;
	
	import org.swiftsuspenders.InjectionConfig;
	import org.swiftsuspenders.Injector;
	import org.swiftsuspenders.InjectorError;

	public class PropertyInjectionPoint extends InjectionPoint
	{
		/*******************************************************************************************
		*								private properties										   *
		*******************************************************************************************/
		private var mappings : Dictionary;
		private var propertyName : String;
		private var propertyType : String;
		
		
		/*******************************************************************************************
		*								public methods											   *
		*******************************************************************************************/
		public function PropertyInjectionPoint(node : XML, injectorMappings : Dictionary)
		{
			super(node, injectorMappings);
		}
		
		override public function applyInjection(
			target : Object, injector : Injector, singletons : Dictionary) : Object
		{
			var config : InjectionConfig = mappings[propertyType];
			if (!config)
			{
				throw(
					new InjectorError(
						'Injector is missing a rule to handle injection into target ' + target + 
						'. Target dependency: ' + propertyType
					)
				);
			}
			var injection : Object = config.getResponse(target, injector, singletons);
			target[propertyName] = injection;
			return target;
		}


		/*******************************************************************************************
		*								protected methods										   *
		*******************************************************************************************/
		override protected function initializeInjection(node : XML, injectorMappings : Dictionary) : void
		{
			var mappings : Dictionary;
			if (node.hasOwnProperty('arg') && node.arg.(@key == 'name').length)
			{
				var name : String = node.arg.@value.toString();
				mappings = injectorMappings[name];
				if (!mappings)
				{
					injectorMappings[name] = new Dictionary();
				}
			}
			else
			{
				mappings = injectorMappings;
			}
			this.mappings = mappings;
			propertyType = node.parent().@type.toString();
			propertyName = node.parent().@name.toString();
		}
	}
}