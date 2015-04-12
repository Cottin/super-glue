R = require 'ramda'

{find, all} = R # auto_require:funp

# ----------------------------------------------------------------------------------------------------------
# GENERAL (for all requests)
# ----------------------------------------------------------------------------------------------------------
isWaiting = (cursor) -> cursor?.value?()?.state == 'waiting'
isSuccessful = (cursor) -> cursor?.value?()?.state == 'success'
hasError = (cursor) -> cursor?.value?()?.state == 'error'

hasFinished = R.or isSuccessful, hasError


# ----------------------------------------------------------------------------------------------------------
# EXPOSURE
# ----------------------------------------------------------------------------------------------------------
Req = {isWaiting, isSuccessful, hasError, hasFinished}

# TODO: find better solution for this
window.Req = Req

module.exports = Req
