﻿using System;
using System.Collections.Generic;
using System.Text;

namespace Typemaker.ObjectTree
{
	public static class ObjectTreeFactory
	{
		public static IObjectTree CreateObjectTree() => new ObjectTree(new BaseObject());

		public static void AddAstToObjectTree(IObjectTree objectTree)
		{
		}
	}
}