/*
 * Copyright (c) 2009 the original author or authors
 * 
 * Permission is hereby granted to use, modify, and distribute this file 
 * in accordance with the terms of the license agreement accompanying it.
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
		
		override public function applyInjection(target : Object) : Object
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
			var injection : Object = config.getResponse();
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
				injectionName = node.arg.@value.toString();
				mappings = injectorMappings[injectionName];
				if (!mappings)
				{
					mappings = injectorMappings[injectionName] = new Dictionary();
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