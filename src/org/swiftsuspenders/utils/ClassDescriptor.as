/*
 * Copyright (c) 2011 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders.utils
{
	import flash.utils.Dictionary;

	import flash.utils.describeType;

	import org.swiftsuspenders.InjectorError;
	import org.swiftsuspenders.injectionpoints.ConstructorInjectionPoint;
	import org.swiftsuspenders.injectionpoints.InjectionPoint;
	import org.swiftsuspenders.injectionpoints.InjectionPointConfig;
	import org.swiftsuspenders.injectionpoints.MethodInjectionPoint;
	import org.swiftsuspenders.injectionpoints.NoParamsConstructorInjectionPoint;
	import org.swiftsuspenders.injectionpoints.PostConstructInjectionPoint;
	import org.swiftsuspenders.injectionpoints.PropertyInjectionPoint;

	public class ClassDescriptor
	{
		//----------------------       Private / Protected Properties       ----------------------//
		private var _descriptionsCache : Dictionary;


		//----------------------               Public Methods               ----------------------//
		public function ClassDescriptor(descriptionsCache : Dictionary)
		{
			_descriptionsCache = descriptionsCache;
		}

		public function getDescription(type : Class) : ClassDescription
		{
			//get injection points or cache them if this target's class wasn't encountered before
			var description : ClassDescription = _descriptionsCache[type];
			if (description)
			{
				return description;
			}
			const descriptionXML : XML = getDescriptionXML(type);
			const factory : XML = descriptionXML.factory[0];
			if (descriptionXML.@name != 'Object' && factory.extendsClass.length() == 0)
			{
				throw new InjectorError('Interfaces can\'t be used as instantiatable classes.');
			}

			const injectionPoints : Array = [];
			var node : XML;

			//get constructor injections
			var ctorInjectionPoint : InjectionPoint;
			node = factory.constructor[0];
			if (node)
			{
				ctorInjectionPoint = new ConstructorInjectionPoint(node, type);
			}
			else
			{
				ctorInjectionPoint = new NoParamsConstructorInjectionPoint();
			}
			var injectionPoint : InjectionPoint;
			//get injection points for variables and setters
			for each (node in factory.*.
					(name() == 'variable' || name() == 'accessor').metadata.(@name == 'Inject'))
			{
				var config : InjectionPointConfig  = new InjectionPointConfig(
						node.parent().@type.toString(),
						node.arg.(@key == 'name').attribute('value').toString(),
						node.arg.(@key == 'optional' &&
								(@value == 'true' || @value == '1')).length() != 0);
				var propertyName : String = node.parent().@name.toString();
				injectionPoint = new PropertyInjectionPoint(config, propertyName);
				injectionPoints.push(injectionPoint);
			}

			//get injection points for methods
			for each (node in factory.method.metadata.(@name == 'Inject'))
			{
				injectionPoint = new MethodInjectionPoint(node);
				injectionPoints.push(injectionPoint);
			}

			//get post construct methods
			var postConstructMethodPoints : Array = [];
			for each (node in factory.method.metadata.(@name == 'PostConstruct'))
			{
				injectionPoint = new PostConstructInjectionPoint(
						node.parent().@name, int(node.arg.(@key == 'order').@value));
				postConstructMethodPoints.push(injectionPoint);
			}
			if (postConstructMethodPoints.length > 0)
			{
				postConstructMethodPoints.sortOn("order", Array.NUMERIC);
				injectionPoints.push.apply(injectionPoints, postConstructMethodPoints);
			}

			description = new ClassDescription(type, ctorInjectionPoint, injectionPoints);
			_descriptionsCache[type] = description;
			return description;
		}

		
		//----------------------         Private / Protected Methods        ----------------------//
		protected function getDescriptionXML(type : Class) : XML
		{
			return describeType(type);
		}
	}
}