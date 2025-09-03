@tool
extends Resource
class_name  DataCinematic

## array de nodepaths para llamar funciones
var listNodePaths:Array[NodePath]
## array de nodepaths que su ruta es un animation player para ejecutar animacion
var listAnimationPaths:Array[NodePath]

#region Autoload
## Señal de espera para un dialogo de un autoload
var dialogSignal:String
## Nombre del autoload para ejecutar un dialogo
var dialogAutoload:String
## Metodo del autoload para ejecutar dialogo
var dialogMethod:String
#endregion Autoload

## Ruta del CVS para buscar el dialogo
var dialogFile:String
