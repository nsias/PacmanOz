functor
export
   isTurnByTurn:IsTurnByTurn
   nRow:NRow
   nColumn:NColumn
   map:Map
   respawnTimePoint:RespawnTimePoint
   respawnTimeBonus:RespawnTimeBonus
   respawnTimePacman:RespawnTimePacman
   respawnTimeGhost:RespawnTimeGhost
   rewardPoint:RewardPoint
   rewardKill:RewardKill
   penalityKill:PenalityKill
   nbLives:NbLives
   huntTime:HuntTime
   nbPacman:NbPacman
   pacman:Pacman
   colorPacman:ColorPacman
   nbGhost:NbGhost
   ghost:Ghost
   colorGhost:ColorGhost
   thinkMin:ThinkMin
   thinkMax:ThinkMax
define
   IsTurnByTurn
   NRow
   NColumn
   Map
   RespawnTimePoint
   RespawnTimeBonus
   RespawnTimePacman
   RespawnTimeGhost
   RewardPoint
   RewardKill
   PenalityKill
   NbLives
   HuntTime
   NbPacman
   Pacman
   ColorPacman
   NbGhost
   Ghost
   ColorGhost
   ThinkMin
   ThinkMax
in

%%%% Style of game %%%%

   IsTurnByTurn = true

%%%% Description of the map %%%%

   NRow = 9
   NColumn = 13
   Map = [[1 1 0 1 0 1 0 1 1 0 1 1 0]
	  [1 0 0 0 0 0 0 1 2 0 0 1 3]
	  [0 2 1 1 1 0 1 1 0 1 0 0 0]
	  [1 0 0 0 1 0 0 4 0 1 0 1 1]
	  [0 0 1 0 0 0 1 1 0 1 0 0 0]
	  [1 0 1 0 1 3 0 0 0 0 3 1 0]
	  [1 1 1 0 0 1 0 1 1 0 1 0 0]
	  [2 0 0 1 0 1 0 0 1 0 1 0 1]
	  [0 1 0 1 3 1 4 1 1 0 0 0 0]]
   
%%%% Respawn times %%%%

   RespawnTimePoint = 10
   RespawnTimeBonus = 15
   RespawnTimePacman = 5
   RespawnTimeGhost = 5

%%%% Rewards and penalities %%%%

   RewardPoint = 1
   RewardKill = 5
   PenalityKill = 5

%%%%

   NbLives = 2
   HuntTime = 10

%%%% Players description %%%%

   NbPacman = 3
   Pacman = [pacman085smart pacman085smart pacman085random]
   ColorPacman = [yellow red blue]
   NbGhost = 2
   Ghost = [ghost085smart ghost085smart]
   ColorGhost = [green white red]

%%%% Thinking parameters (only in simultaneous) %%%%

   ThinkMin = 500
   ThinkMax = 3000

end
