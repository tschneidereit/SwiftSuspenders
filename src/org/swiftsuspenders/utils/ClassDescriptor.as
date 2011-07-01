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

			const injectionPoints : Array = [];
			var node : XML;
			var nameArgs : XMLList;
			var parameters : Array;

			//get constructor injections
			var ctorInjectionPoint : InjectionPoint;
			node = factory.constructor[0];
			if (node)
			{
				nameArgs = node.parent().metadata.arg.(@key == 'name');
				/*
				 In many cases, the flash player doesn't give us type information for constructors until
				 the class has been instantiated at least once. Therefore, we do just that if we don't get
				 type information for at least one parameter.
				 */
				if (node.parameter.(@type == '*').length() == node.parameter.@type.length())
				{
					createDummyInstance(node, type);
				}
				parameters = gatherMethodParameters(node.parameter, nameArgs);
				ctorInjectionPoint = new ConstructorInjectionPoint(parameters);
			}
			else if (descriptionXML.@name == 'Object' || factory.extendsClass.length() > 0)
			{
				ctorInjectionPoint = new NoParamsConstructorInjectionPoint();
			}
			var injectionPoint : InjectionPoint;
			//get injection points for variables and setters
			for each (node in factory.*.
					(name() == 'variable' || name() == 'accessor').metadata.(@name == 'Inject'))
			{
				var config : InjectionPointConfig  = new InjectionPointConfig(
						node.parent().@type,
						node.arg.(@key == 'name').attribute('value'),
						getOptionalFlagFromXMLNode(node));
				var propertyName : String = node.parent().@name;
				injectionPoint = new PropertyInjectionPoint(config, propertyName);
				injectionPoints.push(injectionPoint);
			}

			//get injection points for methods
			for each (node in factory.method.metadata.(@name == 'Inject'))
			{
				nameArgs = node.arg.(@key == 'name');
				parameters = gatherMethodParameters(node.parent().parameter, nameArgs);
				injectionPoint = new MethodInjectionPoint(
						node.parent().@name, parameters, getOptionalFlagFromXMLNode(node));
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

		private function getOptionalFlagFromXMLNode(node : XML) : Boolean
		{
			return node.arg.(@key == 'optional' &&
					(@value == 'true' || @value == '1')).length() != 0;
		}

		protected function gatherMethodParameters(
				parameterNodes : XMLList, nameArgs : XMLList) : Array
		{
			const length : uint = parameterNodes.length();
			const parameters : Array = new Array(length);
			for (var i : int = 0; i < length; i++)
			{
				var parameter : XML = parameterNodes[i];
				var injectionName : String = '';
				if (nameArgs[i])
				{
					injectionName = nameArgs[i].@value;
				}
				var parameterTypeName : String = parameter.@type;
				if (parameterTypeName == '*')
				{
					if (parameter.@optional == 'false' || parameter.@optional == '0')
					{
						//TODO: Find a way to trace name of affected class here
						throw new InjectorError('Error in method definition of injectee. ' +
								'Required parameters can\'t have type "*".');
					}
					else
					{
						parameterTypeName = null;
					}
				}
				parameters[i] = new InjectionPointConfig(
						parameterTypeName, injectionName, getOptionalFlagFromXMLNode(parameter));
			}
			return parameters;
		}
		
		private function createDummyInstance(constructorNode : XML, clazz : Class) : void
		{
			try
			{
				switch (constructorNode.children().length())
				{
					case 0 : (new clazz()); break;
					case 1 : (new clazz(null)); break;
					case 2 : (new clazz(null, null)); break;
					case 3 : (new clazz(null, null, null)); break;
					case 4 : (new clazz(null, null, null, null)); break;
					case 5 : (new clazz(null, null, null, null, null)); break;
					case 6 : (new clazz(null, null, null, null, null, null)); break;
					case 7 : (new clazz(null, null, null, null, null, null, null)); break;
					case 8 : (new clazz(null, null, null, null, null, null, null, null)); break;
					case 9 : (new clazz(null, null, null, null, null, null, null, null, null)); break;
					case 10 : (new clazz(null, null, null, null, null, null, null, null, null, null)); break;
				}
			}
			catch (error : Error)
			{
				trace('Exception caught while trying to create dummy instance for constructor ' +
						'injection. It\'s almost certainly ok to ignore this exception, but you ' +
						'might want to restructure your constructor to prevent errors from ' +
						'happening. See the SwiftSuspenders documentation for more details. ' +
						'The caught exception was:\n' + error);
			}
			constructorNode.setChildren(describeType(clazz).factory.constructor[0].children());
		}
	}
}