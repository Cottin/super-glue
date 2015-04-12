R = require 'ramda'

{compose, length, find, eq, all, gt} = R # auto_require:funp

# ----------------------------------------------------------------------------------------------------------
# STATE
# ----------------------------------------------------------------------------------------------------------
isWaiting = (object) -> object?.state?().state == 'waiting'
isSuccessful = (object) -> object?.state?().state == 'success'
hasError = (object) -> object?.state?().state == 'error'

hasFinished = R.or isSuccessful, hasError

state = (objects) -> 
	if !isa(Array, objects) then objects = [objects]
	switch 
		when any isWaiting, objects then 'isWaiting'
		when any hasError, objects then 'hasError'
		when any compose(eq(undefined), invoker(0, 'value')), objects then 'isNotLoaded'
		when all compose(gt(0), length), objects then 'zero'
		else 'many'


# ----------------------------------------------------------------------------------------------------------
# EXPOSURE
# ----------------------------------------------------------------------------------------------------------
OO = {isWaiting, isSuccessful, hasError, hasFinished, state}

# TODO: find better solution for this
window.OO = OO

module.exports = OO

