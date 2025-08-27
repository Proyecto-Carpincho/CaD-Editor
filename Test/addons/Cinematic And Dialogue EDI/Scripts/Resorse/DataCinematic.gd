@tool
extends Resource
class_name  DataCinematic

## array de nodepaths para llamar funciones
var listNodePaths:Array[NodePath]
## array de nodepaths que su ruta es un animation player para ejecutar animacion
var listAnimationPaths:Array[NodePath]

#region Autoload
## Señal de espera para un dialogo de un autoload
var DialogSignal:String
## Nombre del autoload para ejecutar un dialogo
var DialogAutoload:String
## Metodo del autoload para ejecutar dialogo
var DialogMethod:String
#endregion Autoload

## Ruta del CVS para buscar el dialogo
var DialogFile:String
