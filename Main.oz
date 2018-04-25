functor
import
   GUI
   Input
   PlayerManager
   Browser
   OS
define
   WindowPort

   %%%%%% INITIAL LIST %%%%%%
   AllPointInMap
   AllBonusInMap
   AllSpawnPacmanInMap
   AllSpawnGhostInMap
   AllPacmanPort
   AllGhostPort
   InitialPlayerState
   %%%%% INITIALISATION FUNCTIONs %%%%%%
   ListPositionInMap
   NewGhostPort
   NewPacmanPort
   NewPlayerState
   InitGame
   %%%%% UTILITARY FUNCTIONS %%%%%
   CreateOrder
   UpdateList
   NthFromList
   RemoveFromList
   GetMissingFromList
   %%%%% ALERT MESSAGE %%%%%
   AlertPosGhost
   AlertPosPacman
   AlertPointRemoved
   AlertDeathPacman
   AlertPointSpawn
   AlertBonusSpawn
   AlertBonusRemoved
   AlertDeathGhost
   AlertSetMode
   %%%%% SPAWN RESOLUTION %%%
   SpawnPoint
   SpawnBonus
   GetDeathPacman
   SpawnPacman
   GetDeathGhost
   SpawnGhost
   %%%%% ENCOUNTER RESOLUTION %%%
   MeetOpponent
   Kill
   %%%%% GAME %%%%%
   GameTurnByTurn
   IsEndGame
   GetWinner
in

  % TODO add additionnal function
%%%%%%%%%%% UTILITARY FUNCTIONS %%%%%%%%%%%
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

  fun {UpdateList L1 L2}
    fun {IsInList L X Count}
      case L of nil then
        0
      [] H|T then
        if X.id == H.id then
          Count
        else
          {IsInList T X Count+1}
        end
      end
    end

    fun {Update L1 L2}
      case L1 of nil then
        nil
      [] H|T then
        Nth = {IsInList L2 H 1}
      in
        if Nth > 0 then
          {List.nth L2 Nth}|{Update T L2}
        else
          H|{Update T L2}
        end
      end
    end
  in
    {Update L1 L2}
  end

  fun {NthFromList L X}
    fun{IsInList L X Count}
      case L of nil then
        0
      [] H|T then
        if X == H then
          Count
        else
          {IsInList T X Count+1}
        end
      end
    end
  in
    {IsInList L X 1}
  end

  fun {RemoveFromList L X}
    case L of nil then
      nil
    [] H|T then
      if X == H then
        {RemoveFromList T X}
      else
        H|{RemoveFromList T X}
      end
    end
  end

  fun {GetMissingFromList L1 L2}
    fun {IsRemovedInList X L2}
      case L2 of nil then
        true
      [] H|T then
        if H == X then
          false
        else
          {IsRemovedInList X T}
        end
      end
    end
  in
    case L1 of nil then
      nil
    [] H|T then
      if {IsRemovedInList H L2} then
        H|{GetMissingFromList T L2}
      else
        {GetMissingFromList T L2}
      end
    end
  end

%%%%%%%%%%% INITIALISATION FUNCTIONS %%%%%%%%%%%
  fun {ListPositionInMap Map Value}
    fun {FindPointRow Row Value X Y}
      case Row of nil then
        nil
      [] H|T then
        if H == Value then
          pt(x:X y:Y)|{FindPointRow T Value X+1 Y}
        else
          {FindPointRow T Value X+1 Y}
        end
      end
    end
    fun {FindPoint Map Value X Y}
      case Map of nil then
        nil
      [] H|T then
      P = {FindPointRow H Value X Y}
      in
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


  fun {NewPacmanPort}
    fun {AddPacmanPort Count}
      if Count > Input.nbPacman then
        nil
      else
        {PlayerManager.playerGenerator {List.nth Input.pacman Count} Count}|{AddPacmanPort Count+1}
      end
    end
  in
    {AddPacmanPort 1}
  end

  fun {NewGhostPort}
    fun {AddGhostPort Count}
      if Count > Input.nbGhost then
        nil
      else
        {PlayerManager.playerGenerator {List.nth Input.ghost Count} Count}|{AddGhostPort Count+1}
      end
    end
  in
    {AddGhostPort 1}
  end

  fun {NewPlayerState}
    fun {AddPacmanState Count}
      if Count > Input.nbPacman then
        nil
      else
        ID
        Port = {List.nth AllPacmanPort Count}
        Color = {List.nth Input.colorPacman Count}
        Name = {List.nth Input.pacman Count}
        Spawn = {List.nth AllSpawnPacmanInMap Count}
      in
        {Send Port getId(ID)}
        state(port:Port id:pacman(id:ID color:Color name:Name) pos:Spawn isDead:false)|{AddPacmanState Count+1}
      end
    end

    fun {AddGhostState Count}
      if Count > Input.nbGhost then
        nil
      else
        ID
        Port = {List.nth AllGhostPort Count}
        Color = {List.nth Input.colorGhost Count}
        Name = {List.nth Input.ghost Count}
        Spawn = {List.nth AllSpawnGhostInMap Count}
      in
        {Send Port getId(ID)}
        state(port:Port id:ghost(id:ID color:Color name:Name) pos:Spawn isDead:false)|{AddGhostState Count+1}
      end
    end

    GhostState
    PacmanState
  in
    GhostState = {AddGhostState 1}
    PacmanState = {AddPacmanState 1}
    {CreateOrder PacmanState GhostState}
  end

  proc {InitGame}
    proc {InitPlayer State}
      case State of nil then
        skip
      [] H|T then
        ID = H.id
        Port = H.port
        P = H.pos
      in
        {Send Port assignSpawn(P)}
        case {Record.label ID} of pacman then
          {Send WindowPort initPacman(ID)}
          {Send WindowPort spawnPacman(ID P)}
          {Send Port spawn(_ _)}
          {AlertPosPacman ID P}
        [] ghost then
          {Send WindowPort initGhost(ID)}
          {Send WindowPort spawnGhost(ID P)}
          {Send Port spawn(_ _)}
          {AlertPosGhost ID P}
        end
        {InitPlayer T}
      end
    end

      proc {InitPoint Point}
        case Point of nil then
          skip
        [] H|T then
          {Send WindowPort initPoint(H)}
          {Send WindowPort spawnPoint(H)}
          {AlertPointSpawn H}
          {InitPoint T}
        end
      end

      proc {InitBonus Bonus}
        case Bonus of nil then
          skip
        [] H|T then
          {Send WindowPort initBonus(H)}
          {Send WindowPort spawnBonus(H)}
          {AlertBonusSpawn H}
          {InitBonus T}
        end
      end

    in
      {InitPlayer InitialPlayerState}
      {InitPoint AllPointInMap}
      {InitBonus AllBonusInMap}
  end

%%%%%%%%%%%%%% GAME %%%%%%%%%%%%%%%
  fun {MeetOpponent State ID P}

    fun {Meet State ID P Count}
      case State of nil then
        nil
      [] H|T then
        if H.pos == P then
          case {Record.label ID} of 'pacman' then
            case {Record.label H.id} of 'ghost' then
              if H.isDead == false then
                Count|{Meet T ID P Count+1}
              else
                {Meet T ID P Count+1}
              end
            [] 'pacman' then
              {Meet T ID P Count+1}
            end
          [] 'ghost' then
            case {Record.label H.id} of 'pacman' then
              if H.isDead == false then
                Count|{Meet T ID P Count+1}
              else
                {Meet T ID P Count+1}
              end
            [] 'ghost' then
              {Meet T ID P Count+1}
            end
          end
        else
          {Meet T ID P Count+1}
        end
      end
    end
  in
  %TypeOpponent = {GetTypeOpponent ID}
  %{Browser.browse 'TypeOpponent :'#TypeOpponent}
  {Meet State ID P 1}
  end

  fun {Kill Killer AllState Victim P}
    proc {Killing Killer AllState Victim}
      case Victim of nil then skip
      [] H|T then
        VictimState = {List.nth AllState H}
        VictimPort = VictimState.port
        VictimID = VictimState.id
        NewScore
        NewLife
      in
        case {Record.label VictimID} of 'pacman' then
          {Send WindowPort hidePacman(VictimID)}
          {Send VictimPort gotKilled(_ NewLife NewScore)}
          {Send WindowPort scoreUpdate(VictimID NewScore)}
          {Send WindowPort lifeUpdate(VictimID NewLife)}
          {Send Killer.port killPacman(VictimID)}
          {AlertDeathPacman VictimID}
        [] 'ghost' then
          {Send WindowPort hideGhost(VictimID)}
          {Send VictimPort gotKilled()}
          {Send Killer.port killGhost(VictimID _ NewScore)}
          {Send WindowPort scoreUpdate(Killer.id NewScore)}
          {AlertDeathGhost VictimID}
        end
        {Killing Killer AllState T}
      end
    end

    fun {CreateUpdatedList Killer P State Victim Count}
      Length
    in
      {List.length Victim Length}
      if Count == 0 then
        state(port:Killer.port id:Killer.id pos:P isDead:false)|{CreateUpdatedList Killer P State Victim Count+1}
      elseif Count > Length then
        nil
      else
        S = {List.nth State {List.nth Victim Count}}
      in
        state(port:S.port id:S.id pos:S.pos isDead:true)|{CreateUpdatedList Killer P State Victim Count+1}
      end
    end
  in
    {Killing Killer AllState Victim}
    {CreateUpdatedList Killer P AllState Victim 1}
  end


%%%%%%%%%%%%% ALERT MESSAGE %%%%%%%%%%%%%
  proc {AlertPosGhost ID P}
    proc {Alert Port ID P}
      case Port of nil then
        skip
      [] H|T then
        {Send H ghostPos(ID P)}
        {Alert T ID P}
      end
    end
    in
      {Alert AllPacmanPort ID P}
    end

  proc {AlertPosPacman ID P}
    proc {Alert Port ID P}
      case Port of nil then
        skip
      [] H|T then
        {Send H pacmanPos(ID P)}
        {Alert T ID P}
      end
    end
    in
      {Alert AllGhostPort ID P}
  end

  proc {AlertPointRemoved P}
    proc {Alert Port P}
      case Port of nil then
        skip
      [] H|T then
        {Send H pointRemoved(P)}
        {Alert T P}
      end
    end
  in
    {Alert AllPacmanPort P}
  end

  proc {AlertBonusRemoved P}
    proc {Alert Port P}
      case Port of nil then
        skip
      [] H|T then
        {Send H bonusRemoved(P)}
        {Alert T P}
      end
    end
  in
    {Alert AllPacmanPort P}
  end

  proc {AlertDeathPacman ID}
    proc {Alert Port ID}
      case Port of nil then
        skip
      [] H|T then
        {Send H deathPacman(ID)}
        {Alert T ID}
      end
    end
  in
    {Alert AllGhostPort ID}
  end

  proc {AlertPointSpawn P}
    proc {Alert Port P}
      case Port of nil then
        skip
      [] H|T then
        {Send H pointSpawn(P)}
        {Alert T P}
      end
    end
  in
    {Alert AllPacmanPort P}
  end

  proc {AlertBonusSpawn P}
    proc {Alert Port P}
      case Port of nil then
        skip
      [] H|T then
        {Send H bonusSpawn(P)}
        {Alert T P}
      end
    end
  in
    {Alert AllPacmanPort P}
  end

  proc {AlertDeathGhost ID}
    proc {Alert Port ID}
      case Port of nil then
        skip
      [] H|T then
        {Send H deathGhost(ID)}
        {Alert T ID}
      end
    end
  in
    {Alert AllPacmanPort ID}
  end

  proc {AlertSetMode Hunt}
    proc {Alert Port Hunt}
      case Port of nil then
        skip
      [] H|T then
        {Send H setMode(Hunt)}
        {Alert T Hunt}
      end
    end
  in
    {Alert AllPacmanPort Hunt}
    {Alert AllGhostPort Hunt}
    {Send WindowPort setMode(Hunt)}
  end



%%%%%%%%%%%%% RESPAWN RESOLUTION %%%%%%%%%%%%%% TODO ALERT IN INIT  BONUS
  proc {SpawnPoint Point}
    case Point of nil then
      skip
    [] H|T then
      {Send WindowPort spawnPoint(H)}
      {AlertPointSpawn H}
      {SpawnPoint T}
    end
  end

  proc {SpawnBonus Bonus}
    case Bonus of nil then
      skip
    [] H|T then
      {Send WindowPort spawnBonus(H)}
      {AlertBonusSpawn H}
      {SpawnBonus T}
    end
  end

  fun {GetDeathPacman State}
    case State of nil then
      nil
    [] H|T then
      ID = H.id
    in
      case {Record.label ID} of 'pacman' then
        if H.isDead == true then
          H|{GetDeathPacman T}
        else
          {GetDeathPacman T}
        end
      [] 'ghost' then
        {GetDeathPacman T}
      end
    end
  end

  fun {SpawnPacman State}
    case State of nil then
      nil
    [] H|T then
      P
    in
      {Send H.port spawn(_ P)}
      case P of 'null' then
        state(port:H.port id:H.id pos:P isDead:true)|{SpawnPacman T}
      else
        {Send WindowPort spawnPacman(H.id P)}
        {AlertPosPacman H.id P}
        state(port:H.port id:H.id pos:P isDead:false)|{SpawnPacman T}
      end
    end
  end

  fun {SpawnGhost State}
    case State of nil then
      nil
    [] H|T then
      P
    in
      {Send H.port spawn(_ P)}
      {Send WindowPort spawnGhost(H.id P)}
      {AlertPosGhost H.id P}
      state(port:H.port id:H.id pos:P isDead:false)|{SpawnGhost T}
    end
  end

  fun {GetDeathGhost State}
    case State of nil then
      nil
    [] H|T then
      ID = H.id
    in
      case {Record.label ID} of 'ghost' then
        if H.isDead == true then
          H|{GetDeathGhost T}
        else
          {GetDeathGhost T}
        end
      [] 'pacman' then
        {GetDeathGhost T}
      end
    end
  end

  fun {IsEndGame State}
    case State of nil then
      true
    [] H|T then
      case {Record.label H.id} of 'ghost' then
        {IsEndGame T}
      [] 'pacman' then
        if H.isDead == true then
          {IsEndGame T}
        else
          false
        end
      end
    end
  end

  fun {GetWinner State}
    fun {CheckWinner State ID BestScore}
      case State of nil then
        ID
      [] H|T then
        case {Record.label H.id} of 'ghost' then
          {CheckWinner T ID BestScore}
        [] 'pacman' then
          Score
        in
          {Send H.port addPoint(0 _ Score)}
          if Score > BestScore then
            {CheckWinner T H.id Score}
          else
            {CheckWinner T ID BestScore}
          end
        end
      end
    end
    MinScore = ~(Input.nbLives * Input.penalityKill)
  in
    {CheckWinner State _ MinScore-1}
  end
%%%%%%%%%%%%% MAIN TURN BY TURN %%%%%%
proc {GameTurnByTurn AllState Point Bonus Hunt Round Turn}
%%%%%%% RESPAWN CHECK %%%%%%
  if Round == 0 then
    NewPoint
    NewBonus
    NewState
    NewHunt
  in
      if Turn mod Input.respawnTimePoint == 0 then
        PointRespawned = {GetMissingFromList AllPointInMap Point}
      in
        {SpawnPoint PointRespawned}
        NewPoint = AllPointInMap
      else
        NewPoint = Point
      end
      if Turn mod Input.respawnTimeBonus == 0 then
        BonusRespawned = {GetMissingFromList AllBonusInMap Bonus}
      in
        {SpawnBonus BonusRespawned}
        NewBonus = AllBonusInMap
      else
        NewBonus = Bonus
      end
      if Turn mod Input.respawnTimePacman == 0 andthen
        Turn mod Input.respawnTimeGhost == 0 then
        DeathPacman
        RevivedPacman
        NewState1
        DeathGhost
        RevivedGhost
      in
        DeathPacman = {GetDeathPacman AllState}
        RevivedPacman = {SpawnPacman DeathPacman}
        NewState1 = {UpdateList AllState RevivedPacman}
        DeathGhost = {GetDeathGhost AllState}
        RevivedGhost = {SpawnGhost DeathGhost}
        NewState = {UpdateList NewState1 RevivedGhost}
      elseif Turn mod Input.respawnTimePacman == 0 then
        DeathPacman
        RevivedPacman
      in
        DeathPacman = {GetDeathPacman AllState}
        RevivedPacman = {SpawnPacman DeathPacman}
        NewState = {UpdateList AllState RevivedPacman}
      elseif Turn mod Input.respawnTimeGhost == 0 then
        DeathGhost
        RevivedGhost
      in
        DeathGhost = {GetDeathGhost AllState}
        RevivedGhost = {SpawnGhost DeathGhost}
        NewState = {UpdateList AllState RevivedGhost}
      else
        NewState = AllState
      end
      if Turn - Hunt == Input.huntTime then
        NewHunt = 0
        {AlertSetMode 'classic'}
      else
        NewHunt = Hunt
      end
      if {IsEndGame NewState} andthen
        Turn mod Input.respawnTimePacman == 0 then
        IDWinner
      in
        IDWinner = {GetWinner NewState}
        {Browser.browse NewState}
        {Send WindowPort displayWinner(IDWinner)}
      else
        {Delay 200}
      {GameTurnByTurn NewState NewPoint NewBonus NewHunt Round+1 Turn}
      end
%%%%%%% NEW TURN %%%%%%%%%%%%
  elseif Round > (Input.nbPacman + Input.nbGhost) then
    {GameTurnByTurn AllState Point Bonus Hunt 0 Turn+1}
%%%%%%% ROUND %%%%%%%%%%%%%%
  else
    P
    State = {List.nth AllState Round}
    Port = State.port
    in
    {Send Port move(_ P)}
    case P of 'null' then
      {GameTurnByTurn AllState Point Bonus Hunt Round+1 Turn}
    else
      ID = State.id
      NewState
      NewAllState
      NewPoint
      NewBonus
      NewHunt
    in
      case {Record.label ID} of pacman then
        EncounterGhost = {MeetOpponent AllState ID P}
        GetPoint = {NthFromList Point P}
        GetBonus = {NthFromList Bonus P}
      in
        {Send WindowPort movePacman(ID P)}
        {AlertPosPacman ID P}
        %%%%% ENCOUNTER GHOST %%%%%
        case EncounterGhost of nil then
          %%%%% POINT %%%%%
          if GetPoint > 0 then
            PointRemoved = {List.nth Point GetPoint}
            NewScore
          in
            NewBonus = Bonus
            NewHunt = Hunt
            {Send WindowPort hidePoint(P)}
            {Send Port addPoint(Input.rewardPoint _ NewScore)}
            {Send WindowPort scoreUpdate(ID NewScore)}
            {AlertPointRemoved P}
            NewPoint = {RemoveFromList Point PointRemoved}
          elseif GetBonus > 0 then
            BonusRemoved = {List.nth Bonus GetBonus}
            {AlertSetMode 'hunt'}
          in
            NewPoint = Point
            {Send WindowPort hideBonus(P)}
            {AlertBonusRemoved P}
            NewBonus = {RemoveFromList Bonus BonusRemoved}
            NewHunt = Turn
          else
            NewPoint = Point
            NewBonus = Bonus
            NewHunt = Hunt
          end
          NewState = [state(port:Port id:ID pos:P isDead:false)]
        %%%%%% TO DO HUNT MODE %%%%
        [] H|T then
          LengthListGhost = {List.length EncounterGhost}
          Random  = ({OS.rand} mod LengthListGhost) + 1
          GetGhost = {List.nth EncounterGhost Random}
          GhostState = {List.nth AllState GetGhost}
          NewLife
          NewScore
        in
          NewBonus = Bonus
          NewHunt = Hunt
          NewPoint = Point
          if Hunt == 0 then
            {Send WindowPort hidePacman(ID)}
            {Send Port gotKilled(_ NewLife NewScore)}
            {Send WindowPort scoreUpdate(ID NewScore)}
            {Send WindowPort lifeUpdate(ID NewLife)}
            {Send GhostState.port killPacman(ID)}
            {AlertDeathPacman ID}
            NewState = [state(port:Port id:ID pos:P isDead:true)]
          else
            NewState ={Kill State AllState EncounterGhost P}
          end
        end
      [] ghost then
        EncounterPacman = {MeetOpponent AllState ID P}
      in
        NewPoint = Point
        NewBonus = Bonus
        NewHunt = Hunt
        {Send WindowPort moveGhost(ID P)}
        {AlertPosGhost ID P}
        %%%%% ENCOUNTER PACMAN %%%%%
        case EncounterPacman of nil then
          NewState = [state(port:Port id:ID pos:P isDead:false)]
          %%%%%% TO DO HUNT MODE %%%%
        [] H|T then
          LengthListPacman = {List.length EncounterPacman}
          Random  = ({OS.rand} mod LengthListPacman) + 1
          GetPacman = {List.nth EncounterPacman Random}
          PacmanState = {List.nth AllState GetPacman}
          NewScore
        in
          if Hunt == 0 then
            NewState = {Kill State AllState EncounterPacman P}
          else
            {Send WindowPort hideGhost(ID)}
            {Send Port gotKilled()}
            {Send PacmanState.port killGhost(ID _ NewScore)}
            {Send WindowPort scoreUpdate(PacmanState.id NewScore)}
            NewState = [state(port:Port id:ID pos:P isDead:true)]
          end
        end
      end

      %case NewAllState of _ then
      NewAllState = {UpdateList AllState NewState}
      %end
      {GameTurnByTurn NewAllState NewPoint NewBonus NewHunt Round+1 Turn}
    end
  end
end

   thread
      % Create port for window
      WindowPort = {GUI.portWindow}

      % Open window
      {Send WindowPort buildWindow}

      % TODO complete
      %%%%% INITIALISATION VALUE %%%%%
      AllPointInMap = {ListPositionInMap Input.map 0}
      AllBonusInMap = {ListPositionInMap Input.map 4}
      AllSpawnPacmanInMap = {ListPositionInMap Input.map 2}
      AllSpawnGhostInMap = {ListPositionInMap Input.map 3}
      AllPacmanPort = {NewPacmanPort}
      AllGhostPort = {NewGhostPort}
      InitialPlayerState = {NewPlayerState}
      {InitGame}
      if Input.isTurnByTurn then
        {GameTurnByTurn InitialPlayerState AllPointInMap AllBonusInMap 0 1 1}
      end
   end

end
%TODO Spawn point/bonus : if spawned, get it => Refactoring point + bonus
%TODO Spawnkill : if spawned, kill instantly => Refactoring again
%TODO : Plusieurs pacmans sur le même spawn idem ghost
