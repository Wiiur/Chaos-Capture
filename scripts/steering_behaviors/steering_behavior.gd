extends Node3D
class_name SteeringBehavior3D

## Classe base pra todos os comportamentos de steering em 3D
## (Seek, Flee, Wander, etc.). Equivalente à "SteeringBehavior" 
## original do projeto 2D.
##
## 'active' permite ligar/desligar o comportamento sem remover o nó —
## é isso que o Beehave vai controlar pra decidir qual comportamento
## de movimento usar a cada momento.

var active: bool = true

## Multiplica a força desse comportamento antes de somar com os outros.
## Comportamentos "urgentes" (desviar de parede) devem ter peso maior
## que comportamentos "de objetivo" (fugir, vagar), pra vencer em
## situações de conflito, como um canto de mapa.
@export var weight: float = 1.0
