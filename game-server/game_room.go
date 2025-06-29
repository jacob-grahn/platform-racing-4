package main

// GameRoom is a room for playing the game.
type GameRoom struct {
	BaseRoom
}

// NewGameRoom creates a new game room.
func NewGameRoom(name, hostID string) *GameRoom {
	return &GameRoom{
		BaseRoom: BaseRoom{
			Name:       name,
			HostID:     hostID,
			MembersID:  []string{hostID},
			MaxUpdates: 99999,
		},
	}
}

// HandleUpdate handles updates for the game room.
func (r *GameRoom) HandleUpdate(update *Update, h *Hub) {
	r.BaseRoom.HandleUpdate(update, h, r.handleSpecificUpdate)
}

func (r *GameRoom) handleSpecificUpdate(update *Update, h *Hub) {
	switch Module(update.Module) {
	case PositionModule:
		// Handle position updates
	case ChatModule:
		// simply pass the chat message along
	default:
		h.setError(update, UnknownModuleErrorMessage, update.ID)
	}
}
