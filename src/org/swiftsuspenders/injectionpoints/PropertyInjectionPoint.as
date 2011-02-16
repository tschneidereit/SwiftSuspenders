/*
 * Copyright (c) 2009-2011 the original author or authors
 * 
 * Permission is hereby granted to use, modify, and distribute this file 
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders.injectionpoints
{
	import org.swiftsuspenders.InjectionRule;
	import org.swiftsuspenders.Injector;
	import org.swiftsuspenders.InjectorError;
	import org.swiftsuspenders.utils.SsInternal;

	public class PropertyInjectionPoint extends InjectionPoint
	{
		/*******************************************************************************************
		*								private properties										   *
		*******************************************************************************************/
		private var _propertyName : String;
		private var _injectionConfig : InjectionPointConfig;

		
		/*******************************************************************************************
		*								public methods											   *
		*******************************************************************************************/
		public function PropertyInjectionPoint(node : XML)
		{
			super(node);
		}
		
		override public function applyInjection(target : Object, injector : Injector) : Object
		{
			var rule : InjectionRule =
					injector.SsInternal::getRuleForInjectionPointConfig(_injectionConfig);
			var injection : Object = rule && rule.apply(injector);
			if (injection == null)
			{
				if (_injectionConfig.optional)
				{
					return target;
				}
				throw(new InjectorError(
						'Injector is missing a rule to handle injection into property "' +
						_propertyName + '" of object "' + target +
						'". Target dependency: "' + _injectionConfig.typeName +
								'", named "' + _injectionConfig.injectionName +
						'"'));
			}
			target[_propertyName] = injection;
			return target;
		}


		/*******************************************************************************************
		*								protected methods										   *
		*******************************************************************************************/
		override protected function initializeInjection(node : XML) : void
		{
			_injectionConfig = new InjectionPointConfig(
					node.parent().@type.toString(),
					node.arg.(@key == 'name').attribute('value').toString(),
					node.arg.(@key == 'optional' &&
							(@value == 'true' || @value == '1')).length() != 0);
			_propertyName = node.parent().@name.toString();
		}
	}
}