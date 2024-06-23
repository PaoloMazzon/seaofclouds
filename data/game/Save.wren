class SaveImpl {
    construct new() {
        _volume = 1
    }

    volume { _volume }
    volume=(s) { _volume = s }
}

var Save = SaveImpl.new()