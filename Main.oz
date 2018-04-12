functor
import
   GUI
   Input
   PlayerManager
   Browser
   System
define
   WindowPort
   %Additionnal function %
   PacmanPort
   NewPacman
   LoadPacman
   InitPacmanState
   ListPoint
   InitPacmanState
   ListBonusInMap
   ListPointInMap
   ListWallInMap
   ListSpawnGhostInMap
   ListSpawnPacmanInMap
   PacmanState
   PosPlayer
   InitMap
   InitPacman
   GhostPort
   NewGhost
   GhostState
   InitGhostState
   InitGhost
   PlayerState
   PlayerPort
   CreateOrder

   GameTurnByTurn
   SpawnAllPacman
   AlertPosPacman
   SpawnAllGhost
   AlertPosGhost
   AlertPosPoint
   SpawnAllPoint
   AlertPosBonus
   SpawnAllBonus
   GetType
   Move
   UpdateList

in
%%%%%%%%%%%% Create Pacman %%%%%%%%%%%%%
    fun {NewPacman Count}
      if Count > Input.nbPacman then nil
      else
        {PlayerManager.playerGenerator {List.nth Input.pacman Count} Count}|{NewPacman Count+1}
      end
    end

    fun {InitPacmanState Player}
      fun {InitState Player Count}
        if Count > Input.nbPacman then nil
        else ID in
          {Send {List.nth Player Count} getId(ID)}
          pacman(id:ID color:{List.nth Input.colorPacman Count} name:{List.nth Input.pacman Count})|{InitState Player Count+1}
        end
      end
    in
      {InitState Player 1}
    end

    fun {ListPoint Map Value}
      fun {FindPointRow Row Value X Y}
        case Row of nil then
	         nil
           []H|T then
	          if H == Value then
	             pt(x:X y:Y)|{FindPointRow T Value X+1 Y}
	            else
	               {FindPointRow T Value X+1 Y}
	          end
          end
      end

      fun {FindPoint Map Value X Y}
        case Map of nil then nil
          []H|T then P in
	         P = {FindPointRow H Value X Y}
	        if P == nil then
	           {FindPoint T Value X Y+1}
	        else
	          {Append P {FindPoint T Value X Y+1}}
	         end
         end
       end
     in
       {FindPoint Map Value 1 1}
     end

     proc {InitMap Port Point Bonus}
        proc {InitPoint Port Point}
          case Point of nil then skip
            []H|T then
            {Send Port initPoint(H)}
            {InitPoint Port T}
          end
        end
        proc {InitBonus Port Bonus}
          case Bonus of nil then skip
          [] H|T then
            {Send Port initBonus(H)}
            {InitBonus Port T}
          end
        end
      in
        {InitPoint Port Point}
        {InitBonus Port Bonus}
     end

     proc {InitPacman Player GUI Spawn State}
       proc {InitSpawn Player GUI State Count}
         case Player of nil then skip
         [] H|T then
           ID = {List.nth State Count}
           P = {List.nth Spawn Count}
         in
           {Send GUI initPacman({List.nth State Count})}
           {Send H assignSpawn({List.nth Spawn Count})}
           {InitSpawn T GUI State Count+1}
         end
       end
     in
       {InitSpawn Player GUI State 1}
     end

     fun {NewGhost Count}
       if Count > Input.nbGhost then nil
       else
         {PlayerManager.playerGenerator {List.nth Input.ghost Count} Count}|{NewGhost Count+1}
       end
     end

     fun {InitGhostState Player}
       fun {InitState Player Count}
         if Count > Input.nbGhost then nil
         else ID in
           {Send {List.nth Player Count} getId(ID)}
           ghost(id:ID color:{List.nth Input.colorGhost Count} name:{List.nth Input.ghost Count})|{InitState Player Count+1}
         end
       end
     in
       {InitState Player 1}
     end



    proc {InitGhost Ghost GUI Spawn State}
       proc {InitSpawn Ghost GUI Spawn State Count}
         case Ghost of nil then skip
         [] H|T then
           ID = {List.nth State Count}
           P = {List.nth Spawn Count}
         in
           {Send GUI initGhost(ID)}
           {Send H assignSpawn(P)}
           {InitSpawn T GUI Spawn State Count+1}
       end
      end
    in
      {InitSpawn Ghost GUI Spawn State 1}
    end

    fun {CreateOrder Pacman Ghost}
      fun {PlaceGhost Pacman Ghost Count}
        if Count > Input.nbGhost then
          {PlacePacman Pacman Ghost Count+1}
        else
          {List.nth Ghost Count}|{PlacePacman Pacman Ghost Count+1}
        end
      end
      fun {PlacePacman Pacman Ghost Count}
        if Count > Input.nbPacman then nil
        else
          {List.nth Pacman Count}|{PlaceGhost Pacman Ghost Count}
        end
      end
    in
      {PlacePacman Pacman Ghost 1}
    end


%%%%%%%%%%%% Turn by turn functions %%%%%%%%%%%%%%%%%%%
   proc {AlertPosPacman GPort ID P}
     case GPort of nil then skip
     []H|T then
        {Send H pacmanPos(ID P)}
        {AlertPosPacman T ID P}
     end
   end

   fun {SpawnAllPacman GUI PPort PState PSpawn GPort}
     case PPort of nil then nil
     [] H|T then
       Count
       P
       ID
     in
       {Send H spawn(Count P)}
       ID = {List.nth PState Count}
       {Send GUI spawnPacman(ID P)}
       {AlertPosPacman GPort ID P}
       P|{SpawnAllPacman GUI T PState PSpawn GPort}
     end
   end

   proc {AlertPosGhost PPort ID P}
     case PPort of nil then skip
     [] H|T then
       {Send H ghostPos(ID P)}
       {AlertPosGhost T ID P}
     end
   end

   fun {SpawnAllGhost GUI GPort GState GSpawn PPort}
     case GPort of nil then nil
     [] H|T then
       Count
       P
       ID
     in
       {Send H spawn(Count P)}
       ID = {List.nth GState Count}
       {Send GUI spawnGhost(ID P)}
       {AlertPosGhost PPort ID P}
       P|{SpawnAllGhost GUI T GState GSpawn PPort}
     end
   end

   proc {AlertPosPoint Point PPort}
     case PPort of nil then skip
     [] H|T then
       {Send H pointSpawn(Point)}
       {AlertPosPoint Point T}
     end
   end

   proc {SpawnAllPoint GUI Point PPort}
     case Point of nil then skip
     [] H|T then
       {Send GUI spawnPoint(H)}
       {AlertPosPoint H PPort}
       {SpawnAllPoint GUI T PPort}
     end
   end

   proc {AlertPosBonus Bonus PPort}
     case PPort of nil then skip
     [] H|T then
       {Send H bonusSpawn(Bonus)}
     end
   end

   proc {SpawnAllBonus GUI Bonus PPort}
     case Bonus of nil then skip
     [] H|T then
       {Send GUI spawnBonus(H)}
       {AlertPosBonus H PPort}
       {SpawnAllBonus GUI T PPort}
     end
   end

   fun {GetType T}
     case {Record.label T} of pacman then
       'Pacman'
     [] ghost then
       'Ghost'
     end
   end

   fun {Move Player Port Wall InitPos}
     fun {IsWrongMove Pos InitPos}
       if Pos == InitPos
       orelse Pos.x > InitPos.x+1
       orelse Pos.x < InitPos.x-1
       orelse Pos.y > InitPos.y+1
       orelse Pos.y < InitPos.y-1 then true
       else
         false
       end
     end
     fun {IsOutOfBound Pos}
       if Pos.x < 1
       orelse Pos.y < 1
       orelse Pos.x > Input.nColumn-1
       orelse Pos.y > Input.nRow-1 then true
       else
         false
       end
     end
     fun {IsMovingToWall Pos Wall}
       case Wall of nil then false
       [] H|T then
         if H == Pos then
           true
         else
           {IsMovingToWall Pos T}
         end
       end
     end
     ID
     Pos
   in
     {Send Port move(ID Pos)}
     if {IsWrongMove Pos InitPos}
     orelse {IsOutOfBound Pos}
     orelse {IsMovingToWall Pos Wall} then
       {Browser.browse 'WRONG'}
       {Move Player Port Wall InitPos}
     else
       Pos
     end
   end

   fun {UpdateList List NewElement NewNth}
     fun {UpdatingList List NewElement NewNth Count}
       case List of nil then nil
       [] H|T then
         if Count == newNth then
           newElement|{UpdatingList T NewElement NewNth Count+1}
         else
           H|{UpdatingList T NewElement NewNth Count+1}
         end
       end
     end
   in
     {UpdatingList List NewElement NewNth 1}
   end
   proc {GameTurnByTurn GUI Point Wall PSpawn GSpawn Bonus PPort PState
GPort GState PlrState PlrPort PosPlayer Round NbTurn}
     if NbTurn == 0 then
       PosPacman
       PosGhost
     in
       PosPacman = {SpawnAllPacman GUI PPort PState PSpawn GPort}
       PosGhost = {SpawnAllGhost GUI GPort GState GSpawn PPort}
       {SpawnAllPoint GUI Point PPort}
       {SpawnAllBonus GUI Bonus PPort}
       PosPlayer = {CreateOrder PosPacman PosGhost}
       {GameTurnByTurn GUI Point Wall PSpawn GSpawn Bonus PPort PState
    GPort GState PlrState PlrPort PosPlayer Round NbTurn+1}
     end
%%%%%%%%%%%%%%%%%%%%% ROUND %%%%%%%%%%%%%%%%%%%%%%%%%
      if Round > (Input.nbPacman + Input.nbGhost) then
        {Delay 50}
        {GameTurnByTurn GUI Point Wall PSpawn GSpawn Bonus PPort PState
     GPort GState PlrState PlrPort PosPlayer 1 NbTurn+1}
      else
        Port = {List.nth PlrPort Round}
        ID = {List.nth PlrState Round}
        Type = {GetType ID}
        LastPos = {List.nth PosPlayer Round}
        NewPos
        NewPosPlayer
        X
      in %%%To do is alive
        %Maybe this function will be erase after teacher IA correction
        % THANKS PETER ....
        %NewPos = {Move ID Port Wall LastPos}
        {Send Port move(X NewPos)}
        %%To do east to west if outbound but no wall ?
        if Type == 'Pacman' then
          {AlertPosPacman GPort ID NewPos}
          {Send GUI movePacman(ID NewPos)}

          %%% If point
          %%%If bonus
        else
          {AlertPosGhost PPort ID NewPos}
          {Send GUI moveGhost(ID NewPos)}
        end
        NewPosPlayer = {UpdateList PosPlayer NewPos Round}
        {Delay 50}
        {GameTurnByTurn GUI Point Wall PSpawn GSpawn Bonus PPort PState
GPort GState PlrState PlrPort NewPosPlayer Round+1 NbTurn}
      end
   end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   thread
      % Create port for window
      WindowPort = {GUI.portWindow}

      % Open window
      {Send WindowPort buildWindow}

      % TODO complete

%%%%%%%%%  Game initialisaton %%%%%%%%%%%%%
      %%%%% Utilitary value initialisation %%%%%
      ListPointInMap = {ListPoint Input.map 0}
      ListWallInMap = {ListPoint Input.map 1}
      ListSpawnPacmanInMap = {ListPoint Input.map 2}
      ListSpawnGhostInMap = {ListPoint Input.map 3}
      ListBonusInMap = {ListPoint Input.map 4}
      PacmanPort = {NewPacman 1}
      PacmanState = {InitPacmanState PacmanPort}
      GhostPort = {NewGhost 1}
      GhostState = {InitGhostState GhostPort}
      PlayerState = {CreateOrder PacmanState GhostState}
      PlayerPort = {CreateOrder PacmanPort GhostPort}
      %%%%% Map initialisation %%%%%%%%%%%%%%%%%%
      {InitMap WindowPort ListPointInMap ListBonusInMap}
      {InitPacman PacmanPort WindowPort ListSpawnPacmanInMap PacmanState}
      {InitGhost GhostPort WindowPort ListSpawnGhostInMap GhostState}
%%%%%%%%%  Game launching %%%%%%%%%%%%%
      if Input.isTurnByTurn then
        {GameTurnByTurn WindowPort ListPointInMap ListWallInMap
ListSpawnPacmanInMap ListSpawnGhostInMap ListBonusInMap PacmanPort PacmanState
GhostPort GhostState PlayerState PlayerPort PosPlayer 1 0}
      end
   end
end
