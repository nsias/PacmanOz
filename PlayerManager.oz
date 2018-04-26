functor
import
   Pacman000random
   Ghost000random
   Pacman085smart
   Ghost085smart
   Pacman085random
   Ghost085random
   Pacman061other
   Ghost061other
   Pacman042random
   Ghost042random
export
   playerGenerator:PlayerGenerator
define
   PlayerGenerator
in
   % Kind is one valid name to describe the wanted player, ID is either the <pacman> ID, either the <ghost> ID corresponding to the player
   fun{PlayerGenerator Kind ID}
      case Kind
      of pacman000random then {Pacman000random.portPlayer ID}
      [] ghost000random then {Ghost000random.portPlayer ID}
      [] pacman085smart then {Pacman085smart.portPlayer ID}
      [] ghost085smart then {Ghost085smart.portPlayer ID}
      [] pacman085random then {Pacman085random.portPlayer ID}
      [] ghost085random then {Ghost085random.portPlayer ID}
      [] pacman061other then {Pacman061other.portPlayer ID}
      [] ghost061other then {Ghost061other.portPlayer ID}
      [] pacman042random then {Pacman042random.portPlayer ID}
      [] ghost042random then {Ghost042random.portPlayer ID}

      end
   end
end
