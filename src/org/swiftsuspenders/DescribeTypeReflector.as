/*
 * Copyright (c) 2009-2011 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders
{
	import flash.system.ApplicationDomain;
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;

	import org.swiftsuspenders.injectionpoints.ConstructorInjectionPoint;

	import org.swiftsuspenders.injectionpoints.InjectionPoint;
	import org.swiftsuspenders.injectionpoints.InjectionPointConfig;
	import org.swiftsuspenders.injectionpoints.MethodInjectionPoint;
	import org.swiftsuspenders.injectionpoints.NoParamsConstructorInjectionPoint;
	import org.swiftsuspenders.injectionpoints.PostConstructInjectionPoint;
	import org.swiftsuspenders.injectionpoints.PropertyInjectionPoint;

	import org.swiftsuspenders.utils.getConstructor;

	public class DescribeTypeReflector
	{
		//----------------------       Private / Protected Properties       ----------------------//
		private var _currentType : Class;
		private var _currentFactoryXML : XML;

		//----------------------               Public Methods               ----------------------//
		public function classExtendsOrImplements(classOrClassName : Object,
			superclass : Class, application : ApplicationDomain = null) : Boolean
		{
            var actualClass : Class;
			
            if (classOrClassName is Class)
            {
                actualClass = Class(classOrClassName);
            }
            else if (classOrClassName is String)
            {
                try
                {
                    actualClass = Class(getDefinitionByName(classOrClassName as String));
                }
                catch (e : Error)
                {
                    throw new Error("The class name " + classOrClassName +
                    	" is not valid because of " + e + "\n" + e.getStackTrace());
                }
            }

            if (!actualClass)
            {
                throw new Error("The parameter classOrClassName must be a valid Class " +
                	"instance or fully qualified class name.");
            }

            if (actualClass == superclass)
                return true;

            var factoryDescription : XML = describeType(actualClass).factory[0];

			return (factoryDescription.children().(
            	name() == "implementsInterface" || name() == "extendsClass").(
            	attribute("type") == getQualifiedClassName(superclass)).length() > 0);
		}

		public function getClass(value : *, applicationDomain : ApplicationDomain = null) : Class
		{
			if (value is Class)
			{
				return value;
			}
			return getConstructor(value);
		}

		public function getFQCN(value : *, replaceColons : Boolean = false) : String
		{
			var fqcn:String;
			if (value is String)
			{
				fqcn = value;
				// Add colons if missing and desired.
				if (!replaceColons && fqcn.indexOf('::') == -1)
				{
					var lastDotIndex:int = fqcn.lastIndexOf('.');
					if (lastDotIndex == -1) return fqcn;
					return fqcn.substring(0, lastDotIndex) + '::' + fqcn.substring(lastDotIndex + 1);
				}
			}
			else
			{
				fqcn = getQualifiedClassName(value);
			}
			return replaceColons ? fqcn.replace('::', '.') : fqcn;
		}

		public function startReflection(type : Class) : void
		{
			_currentType = type;
			_currentFactoryXML = describeType(type).factory[0];
		}

		public function endReflection() : void
		{
			_currentType = null;
			_currentFactoryXML = null;
		}

		public function getCtorInjectionPoint() : InjectionPoint
		{
			const node : XML = _currentFactoryXML.constructor[0];
			if (!node)
			{
				if (_currentFactoryXML.parent().@name == 'Object'
						|| _currentFactoryXML.extendsClass.length() > 0)
				{
					return new NoParamsConstructorInjectionPoint();
				}
				return null;
			}
			var nameArgs : XMLList = node.parent().metadata.arg.(@key == 'name');
			/*
			 In many cases, the flash player doesn't give us type information for constructors until
			 the class has been instantiated at least once. Therefore, we do just that if we don't get
			 type information for at least one parameter.
			 */
			if (node.parameter.(@type == '*').length() == node.parameter.@type.length())
			{
				createDummyInstance(node, _currentType);
			}
			const parameters : Array = gatherMethodParameters(node.parameter, nameArgs);
			return new ConstructorInjectionPoint(parameters);
		}

		//----------------------         Private / Protected Methods        ----------------------//
		private function getOptionalFlagFromXMLNode(node : XML) : Boolean
		{
			return node.arg.(@key == 'optional' &&
					(@value == 'true' || @value == '1')).length() != 0;
		}

		private function gatherMethodParameters(
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

		public function addFieldInjectionPointsToList(injectionPoints : Array) : void
		{
			//get injection points for variables and setters
			for each (var node : XML in _currentFactoryXML.*.
					(name() == 'variable' || name() == 'accessor').metadata.(@name == 'Inject'))
			{
				var config : InjectionPointConfig  = new InjectionPointConfig(
						node.parent().@type,
						node.arg.(@key == 'name').attribute('value'),
						getOptionalFlagFromXMLNode(node));
				var propertyName : String = node.parent().@name;
				injectionPoints.push(new PropertyInjectionPoint(config, propertyName));
			}
		}

		public function addMethodInjectionPointsToList(injectionPoints : Array) : void
		{
			for each (var node : XML in _currentFactoryXML.method.metadata.(@name == 'Inject'))
			{
				const nameArgs : XMLList = node.arg.(@key == 'name');
				const parameters : Array =
						gatherMethodParameters(node.parent().parameter, nameArgs);
				injectionPoints.push(new MethodInjectionPoint(
						node.parent().@name, parameters, getOptionalFlagFromXMLNode(node)));
			}
		}

		public function addPostConstructMethodPointsToList(injectionPoints : Array) : void
		{
			const postConstructMethodPoints : Array = [];
			for each (var node : XML in
					_currentFactoryXML.method.metadata.(@name == 'PostConstruct'))
			{
				postConstructMethodPoints.push(new PostConstructInjectionPoint(
						node.parent().@name, int(node.arg.(@key == 'order').@value)));
			}
			if (postConstructMethodPoints.length > 0)
			{
				postConstructMethodPoints.sortOn("order", Array.NUMERIC);
				injectionPoints.push.apply(injectionPoints, postConstructMethodPoints);
			}
		}
	}
}