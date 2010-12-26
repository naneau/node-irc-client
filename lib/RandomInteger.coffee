# Quick 'n easy RandomInteger functions
class RandomInteger
    
    # Generate a random integer between start and end, note that end can not be returned itself, but start can
    between: (start, end) ->
        Math.floor start + Math.random() * end
        
    # Generate an integer between 0 and max, max itself will not be returned
    max: (max) ->
        RandomInteger::between 0, max
        
module.exports = RandomInteger;