/*
 * Copyright (c) 2009 the original author or authors
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

	/**
	 * @author tschneidereit
	 */
	public class Reflector
	{
		/*******************************************************************************************
		*								public methods											   *
		*******************************************************************************************/
		public function Reflector()
		{
		}

		public function classExtendsOrImplements(classOrClassName : Object, 
			superclass : Class, application : ApplicationDomain = null) : Boolean
		{
            var superclassName : String = getQualifiedClassName(superclass);

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

			// trace("describeType(actualClass): " + (describeType(actualClass)));
            var factoryDescription : XML = describeType(actualClass).factory[0];

			return (factoryDescription.children().(
            	name() == "implementsInterface" || name() == "extendsClass").(
            	attribute("type") == superclassName).length() > 0);
		}

		public function getClass(
			value : *, applicationDomain : ApplicationDomain = null) : Class
		{
			if (value is Class)
			{
				return value;
			}
			return value.constructor;
		}

		public function getFQCN(value : *, replaceColons : Boolean = false) : String
		{
			var fqcn:String;
			if (value is String)
			{
				fqcn = value;
				if (replaceColons)
				{
					fqcn = fqcn.replace('::', '.');
				}
				else if (fqcn.indexOf('::') == -1 && fqcn.indexOf('.') > -1)
				{
					var parts:Array = fqcn.split('.');
					var lastPart:String = parts.pop();
					fqcn = parts.join('.') + '::' + lastPart;
				}
			}
			else
			{
				fqcn = getQualifiedClassName(value);
				if (replaceColons)
				{
					fqcn = fqcn.replace('::', '.');
				}
			}
			return fqcn;
		}
	}
}