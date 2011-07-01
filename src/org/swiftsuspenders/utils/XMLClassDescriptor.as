/*
 * Copyright (c) 2011 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders.utils
{
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedSuperclassName;

	import org.swiftsuspenders.DescribeTypeReflector;
	import org.swiftsuspenders.InjectorError;

	public class XMLClassDescriptor extends ClassDescriptor
	{
		//----------------------       Private / Protected Properties       ----------------------//
		private var _xmlMetadata : XML;


		//----------------------               Public Methods               ----------------------//
		public function XMLClassDescriptor(
				descriptionsCache : Dictionary, reflector : DescribeTypeReflector, xmlConfig : XML)
		{
			super(descriptionsCache, reflector);
			_xmlMetadata = xmlConfig;
		}

		override public function getDescription(type : Class) : ClassDescription
		{
			var description : ClassDescription = super.getDescription(type);
			addParentInjectionPoints(description);
			return description;
		}

		//----------------------         Private / Protected Methods        ----------------------//
		override protected function getDescriptionXML(type : Class) : XML
		{
			var xml : XML = super.getDescriptionXML(type);

			// This is where we have to wire in the XML...
			if (_xmlMetadata)
			{
				createInjectionPointsFromConfigXML(xml);
			}
			return xml;
		}

		private function createInjectionPointsFromConfigXML(description : XML) : void
		{
			var node : XML;
			//first, clear out all "Inject" metadata, we want a clean slate to have the result
			//work the same in the Flash IDE and MXMLC
			for each (node in description..metadata.(@name=='Inject' || @name=='PostConstruct'))
			{
				delete node.parent().metadata.(@name=='Inject' || @name=='PostConstruct')[0];
			}

			//now, we create the new injection points based on the given xml file
			var className:String = description.factory.@type;
			for each (node in _xmlMetadata.type.(@name == className).children())
			{
				var metaNode : XML = <metadata/>;
				if (node.name() == 'postconstruct')
				{
					metaNode.@name = 'PostConstruct';
					if (node.@order.length())
					{
						metaNode.appendChild(<arg key='order' value={node.@order}/>);
					}
				}
				else
				{
					metaNode.@name = 'Inject';
					if (node.@injectionname.length())
					{
						metaNode.appendChild(<arg key='name' value={node.@injectionname}/>);
					}
					for each (var arg : XML in node.arg)
					{
						metaNode.appendChild(<arg key='name' value={arg.@injectionname}/>);
					}
				}
				var typeNode : XML;
				if (node.name() == 'constructor')
				{
					typeNode = description.factory[0];
				}
				else
				{
					typeNode = description.factory.*.(attribute('name') == node.@name)[0];
					if (!typeNode)
					{
						throw new InjectorError('Error in XML configuration: Class "' + className +
								'" doesn\'t contain the instance member "' + node.@name + '"');
					}
				}
				typeNode.appendChild(metaNode);
			}
		}

		private function addParentInjectionPoints(description : ClassDescription) : void
		{
			var parentClassName : String = getQualifiedSuperclassName(description.type);
			if (!parentClassName || parentClassName == 'Object')
			{
				return;
			}
			var parentClass : Class = Class(getDefinitionByName(parentClassName));
			var parentDescription : ClassDescription = getDescription(parentClass);
			var parentInjectionPoints : Array = parentDescription.injectionPoints;

			description.injectionPoints.unshift.apply(
					description.injectionPoints, parentInjectionPoints);
		}
	}
}