/*
 * Copyright (c) 2009 the original author or authors
 * 
 * Permission is hereby granted to use, modify, and distribute this file 
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders.injectionpoints
{
	import flash.utils.getDefinitionByName;
	
	import org.swiftsuspenders.InjectionConfig;
	import org.swiftsuspenders.Injector;
	import org.swiftsuspenders.InjectorError;

	public class PropertyInjectionPoint extends InjectionPoint
	{
		/*******************************************************************************************
		*								private properties										   *
		*******************************************************************************************/
		private var propertyName : String;
		private var propertyType : String;
		private var m_injectionConfig : InjectionConfig;
		
		
		/*******************************************************************************************
		*								public methods											   *
		*******************************************************************************************/
		public function PropertyInjectionPoint(node : XML, injector : Injector)
		{
			super(node, injector);
		}
		
		override public function applyInjection(target : Object, injector : Injector) : Object
		{
			var injection : Object = m_injectionConfig.getResponse(injector);
			if (injection == null)
			{
				throw(
					new InjectorError(
						'Injector is missing a rule to handle injection into target ' + target + 
						'. Target dependency: ' + propertyType
					)
				);
			}
			target[propertyName] = injection;
			return target;
		}


		/*******************************************************************************************
		*								protected methods										   *
		*******************************************************************************************/
		override protected function initializeInjection(node : XML, injector : Injector) : void
		{
			propertyType = node.parent().@type.toString();
			propertyName = node.parent().@name.toString();
			m_injectionConfig = injector.getMapping(Class(injector.getApplicationDomain().getDefinition(propertyType)), 
				node.arg.attribute('value').toString());
		}
	}
}