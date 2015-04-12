R = require 'ramda'
OO = require './OO'
{apply, compose, length, eq, where, all, gt} = R #auto_require:funp


RestObjectEither = (restObjects, noun, msgChild, manyChild) ->
	if !isa(Array, restObjects) then restObjects = [restObjects]
	if arguments.length > 4 then throw new "eitherElement can't have a third child"
	msg = switch 
		when any OO.isWaiting, restObjects then "Loading #{noun}..."
		when any OO.hasError restObjects then "Error while loading #{noun}!"
		when any compose(eq(undefined), invoker(0, 'value')), restObjects then "There are no #{noun} not loaded."
		when all compose(gt(0), length), restObjects then "No #{noun} found on server"
	if msg
		msgChild(msg)
	else
		manyChild('test')

RestObjectFork = (restObjects, forks) ->
	if !isa(Array, restObjects) then restObjects = [restObjects]

	switch 
		when any Req.isWaiting, restObjects then forks.isWaiting()
		when any Req.hasError restObjects then forks.hasError(restObjects)
		when any compose(eq(undefined), invoker(0, 'value')), restObjects then forks.isNotLoaded.apply this
		when all compose(gt(0), length), restObjects then forks.zero.apply this
		else forks.many.apply this

ui = {RestObjectEither, RestObjectFork}

module.exports = ui


# # todo: where to put this
# status = (valueF, getF) ->
# 	isWaiting = Req.isWaiting getF
# 	hasError = Req.hasError getF
# 	isNotLoaded = valueF() == undefined
# 	zero = length(valueF()) == 0
# 	many = length(valueF()) > 0
# 	return {isWaiting, hasError, isNotLoaded, zero, many}
