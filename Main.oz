functor
import
   GUI
   Input
   PlayerManager
   Browser
define
   WindowPort
   %Additionnal function %
   PacmanPort
   NewPacman
   InitPacmanState
   ListPoint
   InitPacmanState
   ListBonusInMap
   ListPointInMap
   ListSpawnGhostInMap
   ListSpawnPacmanInMap
   PacmanState
   InitMap
   InitPacman
   GhostPort
   NewGhost
   GhostState
   InitGhostState
   InitGhost
   PlayerState
   PlayerPort
   PlayerPos
   PlayerDead
   CreateOrder
   CreateDeathList

   GameTurnByTurn
   SpawnAllPacman
   AlertPosPacman
   SpawnAllGhost
   AlertPosGhost
   AlertPosPoint
   AlertDeathPacman
   SpawnAllPoint
   AlertPosBonus
   SpawnAllBonus
   GetType
   IsInList
   RemoveToList
   AlertHidePoint
   UpdateList
   RespawnPoint
   CreateMissingList
   MeetSomeone
   MeetGhost
   MeetPacman
   IsDead

   PlrSpawn

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

   fun {UpdateList List NewElement NewNth}
     fun {UpdatingList List NewElement NewNth Count}
       case List of nil then nil
       [] H|T then
         if NewNth == Count then
           NewElement|{UpdatingList T NewElement NewNth Count+1}
         else
           H|{UpdatingList T NewElement NewNth Count+1}
         end
       end
     end
   in
     {UpdatingList List NewElement NewNth 1}
   end

   fun {IsInList L X}
     case L of nil then false
     [] H|T then
       if H == X then true
       else
         {IsInList T X}
       end
     end
   end

   fun {RemoveToList L X}
     case L of nil then nil
     [] H|T then
       if H == X then
         {RemoveToList T X}
       else
         H|{RemoveToList T X}
       end
     end
   end

   proc {AlertHidePoint PPort Pos}
     case PPort of nil then skip
     [] H|T then
       {Send H pointRemoved(Pos)}
       {AlertHidePoint T Pos}
     end
   end


   fun {CreateMissingList L1 L2}
     fun {IsMissing L X}
       case L of nil then true
       [] H|T then
         if H == X then false
         else
           {IsMissing T X}
         end
       end
     end
   in
     case L1 of nil then nil
     [] H|T then
       if {IsMissing L2 H} then
         H|{CreateMissingList T L2}
       else
         {CreateMissingList T L2}
       end
     end
   end

   proc {RespawnPoint GUI PPort NewPoint Point}
     L = {CreateMissingList NewPoint Point}
   in
     {SpawnAllPoint GUI L PPort}
   end


   fun {IsDead PlrDead N}
     fun {CheckDead PlrDead N Count}
      case PlrDead of nil then false
      [] H|T then
        if N == Count then
          if H == 1 then true
          else false
          end
        else
           {CheckDead T N Count+1}
         end
      end
     end
    in
      {CheckDead PlrDead N 1}
   end

   fun {MeetSomeone PosPlayer Pos Count}
     case PosPlayer of nil then 0
     [] H|T then
       if H == Pos then Count
       else
         {MeetSomeone T Pos Count+1}
       end
     end
   end

   fun {MeetGhost PlrState PosPlayer PlrDead Pos}
     N = {MeetSomeone PosPlayer Pos 1}
     State
   in
     if N == 0 then 0
     elseif {IsDead PlrDead N} then 0
     else
       State = {List.nth PlrState N}
       case {Record.label State} of ghost then N
       [] pacman then 0
       end
     end
   end

   fun {MeetPacman PlrState PosPlayer PlrDead Pos}
     N = {MeetSomeone PosPlayer Pos 1}
     State
   in
     if N == 0 then 0
     elseif {IsDead PlrDead N} then 0
     else
       State = {List.nth PlrState N}
       case {Record.label State} of ghost then 0
       [] pacman then N
       end
     end
   end

   proc {AlertDeathPacman GPort ID}
     case GPort of nil then skip
     [] H|T then
       {Send H deathPacman(ID)}
     end
   end

   fun {CreateDeathList PlrState}
     case PlrState of nil then nil
     [] H|T then
       0|{CreateDeathList T}
     end
   end

   fun {GetNthToList L Value}
     fun {GetNth L Value Count}
     case L of nil then nil
     [] H|T then
       if H == Value then
         Count|{GetNth T Value Count+1}
       else
         {GetNth T Value Count+1}
       end
      end
     end
   in
     {GetNth L Value 1}
   end

   fun {GetToList L1 N}
     case N of nil then nil
     [] H|T then
        {List.nth L1 H}|{GetToList L1 T}
     end
   end



   proc {GameTurnByTurn GUI Point PSpawn GSpawn Bonus PPort PState
GPort GState PlrState PlrPort PosPlayer PlrDead Round NbTurn}
     if NbTurn == 0 then
       PosPacman
       PosGhost
     in
       PosPacman = {SpawnAllPacman GUI PPort PState PSpawn GPort}
       PosGhost = {SpawnAllGhost GUI GPort GState GSpawn PPort}
       {SpawnAllPoint GUI Point PPort}
       {SpawnAllBonus GUI Bonus PPort}
       PlrDead = {CreateDeathList PlrState}
       PosPlayer = {CreateOrder PosPacman PosGhost}
       PlrSpawn = PosPlayer
       {GameTurnByTurn GUI Point PSpawn GSpawn Bonus PPort PState
    GPort GState PlrState PlrPort PosPlayer PlrDead Round NbTurn+1}
    elseif Round > (Input.nbPacman + Input.nbGhost) then
      {GameTurnByTurn GUI Point PSpawn GSpawn Bonus PPort PState
   GPort GState PlrState PlrPort PosPlayer PlrDead 0 NbTurn+1}
%%%%%%%%%% BEFORE NEW TURN => Check respawn %%%%%%%%%%%%%%
    elseif Round == 0 then
      NewPoint
    in
        if (NbTurn mod Input.respawnTimePoint) == 0 then
          NewPoint = ListPointInMap
          % TODO avoid spawn on ghost/pacman ?
          {RespawnPoint GUI PPort NewPoint Point}
        else
          NewPoint = Point
        end
           %%%%%%%%%%%% TODO Check Bonus respawn %%%%%%%%%%%
           %%%%%%%%%%%% TODO Check Player respawn %%%%%%%%%%%
           {Delay 100}
           {GameTurnByTurn GUI NewPoint PSpawn GSpawn Bonus PPort PState
        GPort GState PlrState PlrPort PosPlayer PlrDead Round+1 NbTurn+1}
%%%%%%%%%%%%%%%%%%%%% ROUND %%%%%%%%%%%%%%%%%%%%%%%%%
    else
        Port = {List.nth PlrPort Round}
        ID = {List.nth PlrState Round}
        Type = {GetType ID}
        NewPos
        IsAlive
        XX
        Meet
        Event
        NewPoint
        NewPosPlayer
        NewPlrDead
      in
        {Send Port move(IsAlive NewPos)}
        if IsAlive == 'null' then
          {GameTurnByTurn GUI Point PSpawn GSpawn Bonus PPort PState
       GPort GState PlrState PlrPort PosPlayer PlrDead Round+1 NbTurn+1}
        else
          if Type == 'Pacman' then
            {AlertPosPacman GPort ID NewPos}
            {Send GUI movePacman(ID NewPos)}
            Meet = {MeetGhost PlrState PosPlayer PlrDead NewPos}
            % TODO check if ghost is dead or not in MeetSomeone function
            if  Meet > 0 then
              GhostID = {List.nth PlrState Meet}
              GhostPort = {List.nth PlrPort Meet}
              ActualScore
              NewLife
              Z
            in
              {Browser.browse 'KILLLLLLLLLLED'}
              {Delay 5000}
              {Send Port gotKilled(Z NewLife ActualScore)}
              {Send GUI scoreUpdate(ID ActualScore)}
              {Send GUI lifeUpdate(ID NewLife)}
              {Send GhostPort killPacman(ID)}
              {Send GUI hidePacman(ID)}
              {AlertDeathPacman GPort ID}
              NewPoint = Point
              NewPlrDead = {UpdateList PlrDead 1 Round}
            else
              NewPlrDead = PlrDead
              Event = {List.nth {List.nth Input.map NewPos.y} NewPos.x}
              if Event == 0 then % IF POINT
                if {IsInList Point NewPos} then
                  ActualScore
                in
                  NewPoint = {RemoveToList Point NewPos}
                  {Send Port addPoint(Input.rewardPoint XX ActualScore)}
                  {Send GUI hidePoint(NewPos)}
                  {Send GUI scoreUpdate(ID ActualScore)}
                  {AlertHidePoint PPort NewPos}
                else
                  NewPoint = Point
                end
              elseif Event == 4 then %TODO IF BONUS
                NewPoint = Point
              else
                NewPoint = Point
              end
            end
          elseif Type == 'Ghost' then
            Meet
          in
            NewPoint = Point
            {AlertPosGhost PPort ID NewPos}
            {Send GUI moveGhost(ID NewPos)}
            Meet = {MeetPacman PlrState PosPlayer PlrDead NewPos}
            if Meet > 0 then
              PacmanID = {List.nth PlrState Meet}
              PacmanPort = {List.nth PlrPort Meet}
              ActualScore
              NewLife
              Z
            in
              {Browser.browse 'KILLLLLLLLLL'}
              {Delay 5000}
              {Send PacmanPort gotKilled(Z NewLife ActualScore)}
              {Send GUI scoreUpdate(PacmanID ActualScore)}
              {Send GUI lifeUpdate(PacmanID NewLife)}
              {Send Port killPacman(PacmanID)}
              {Send GUI hidePacman(PacmanID)}
              {AlertDeathPacman GPort PacmanID}
              NewPlrDead = {UpdateList PlrDead 1 Meet}
            else
              NewPlrDead = PlrDead
            end
          end
          NewPosPlayer = {UpdateList PosPlayer NewPos Round}
          {Browser.browse NewPlrDead}
          {Delay 200}
          {GameTurnByTurn GUI NewPoint PSpawn GSpawn Bonus PPort PState
GPort GState PlrState PlrPort NewPosPlayer NewPlrDead Round+1 NbTurn}
        end
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
        {GameTurnByTurn WindowPort ListPointInMap
ListSpawnPacmanInMap ListSpawnGhostInMap ListBonusInMap PacmanPort PacmanState
GhostPort GhostState PlayerState PlayerPort PlayerPos PlayerDead 1 0}
      end
   end
end
